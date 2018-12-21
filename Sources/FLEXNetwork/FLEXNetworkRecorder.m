//
//  FLEXNetworkRecorder.m
//  Flipboard
//
//  Created by Ryan Olson on 2/4/15.
//  Copyright (c) 2015 Flipboard. All rights reserved.
//

#import "FLEXNetworkRecorder.h"
//#import "FLEXNetworkCurlLogger.h"
#import "FLEXNetworkTransaction.h"
#import "FLEXUtility.h"
//#import "FLEXResources.h"
#import "NetworkHelper.h"
#import "OCLoggerFormat.h"
//#import "NSObject+CocoaDebug.h"

NSString *const kFLEXNetworkRecorderNewTransactionNotification = @"kFLEXNetworkRecorderNewTransactionNotification";
NSString *const kFLEXNetworkRecorderTransactionUpdatedNotification = @"kFLEXNetworkRecorderTransactionUpdatedNotification";
NSString *const kFLEXNetworkRecorderTransactionsClearedNotification = @"kFLEXNetworkRecorderTransactionsClearedNotification";
//NSString *const kFLEXNetworkRecorderUserInfoTransactionKey = @"transaction"; //liman
NSString *const kFLEXNetworkRecorderResponseCacheLimitDefaultsKey = @"com.flex.responseCacheLimit";

@interface FLEXNetworkRecorder ()

@property (nonatomic, strong) NSCache *responseCache;
@property (nonatomic, strong) NSMutableArray<FLEXNetworkTransaction *> *orderedTransactions;
@property (nonatomic, strong) NSMutableDictionary<NSString *, FLEXNetworkTransaction *> *networkTransactionsForRequestIdentifiers;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation FLEXNetworkRecorder

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.responseCache = [[NSCache alloc] init];
        NSUInteger responseCacheLimit = [[[NSUserDefaults standardUserDefaults] objectForKey:kFLEXNetworkRecorderResponseCacheLimitDefaultsKey] unsignedIntegerValue];
        if (responseCacheLimit) {
            [self.responseCache setTotalCostLimit:responseCacheLimit];
        } else {
            // Default to 25 MB max. The cache will purge earlier if there is memory pressure.
            [self.responseCache setTotalCostLimit:25 * 1024 * 1024];
        }
        self.orderedTransactions = [NSMutableArray array];
        self.networkTransactionsForRequestIdentifiers = [NSMutableDictionary dictionary];

        // Serial queue used because we use mutable objects that are not thread safe
        self.queue = dispatch_queue_create("com.flex.FLEXNetworkRecorder", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (instancetype)defaultRecorder
{
    static FLEXNetworkRecorder *defaultRecorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultRecorder = [[[self class] alloc] init];
    });
    return defaultRecorder;
}

#pragma mark - Public Data Access

- (NSUInteger)responseCacheByteLimit
{
    return [self.responseCache totalCostLimit];
}

- (void)setResponseCacheByteLimit:(NSUInteger)responseCacheByteLimit
{
    [self.responseCache setTotalCostLimit:responseCacheByteLimit];
    [[NSUserDefaults standardUserDefaults] setObject:@(responseCacheByteLimit) forKey:kFLEXNetworkRecorderResponseCacheLimitDefaultsKey];
}

- (NSArray<FLEXNetworkTransaction *> *)networkTransactions
{
    __block NSArray<FLEXNetworkTransaction *> *transactions = nil;
    dispatch_sync(self.queue, ^{
        transactions = [self.orderedTransactions copy];
    });
    return transactions;
}

- (NSData *)cachedResponseBodyForTransaction:(FLEXNetworkTransaction *)transaction
{
    return [self.responseCache objectForKey:transaction.requestID];
}

//liman
//- (void)clearRecordedActivity
//{
//    dispatch_async(self.queue, ^{
//        [self.responseCache removeAllObjects];
//        [self.orderedTransactions removeAllObjects];
//        [self.networkTransactionsForRequestIdentifiers removeAllObjects];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:kFLEXNetworkRecorderTransactionsClearedNotification object:self];
//        });
//    });
//}

#pragma mark - Network Events

- (void)recordRequestWillBeSentWithRequestID:(NSString *)requestID request:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    for (NSString *host in self.hostBlacklist) {
        if ([request.URL.host hasSuffix:host]) {
            return;
        }
    }
    
    NSDate *startDate = [NSDate date];

    if (redirectResponse) {
        [self recordResponseReceivedWithRequestID:requestID response:redirectResponse];
        [self recordLoadingFinishedWithRequestID:requestID responseBody:nil];
    }

    dispatch_async(self.queue, ^{
        FLEXNetworkTransaction *transaction = [[FLEXNetworkTransaction alloc] init];
        transaction.requestID = requestID;
        transaction.request = request;
        transaction.startTime = startDate;

        [self.orderedTransactions insertObject:transaction atIndex:0];
        [self.networkTransactionsForRequestIdentifiers setObject:transaction forKey:requestID];
        transaction.transactionState = FLEXNetworkTransactionStateAwaitingResponse;

        [self postNewTransactionNotificationWithTransaction:transaction];
    });
}

- (void)recordResponseReceivedWithRequestID:(NSString *)requestID response:(NSURLResponse *)response
{
    NSDate *responseDate = [NSDate date];

    dispatch_async(self.queue, ^{
        FLEXNetworkTransaction *transaction = self.networkTransactionsForRequestIdentifiers[requestID];
        if (!transaction) {
            return;
        }
        transaction.response = response;
        transaction.transactionState = FLEXNetworkTransactionStateReceivingData;
        transaction.latency = -[transaction.startTime timeIntervalSinceDate:responseDate];

        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordDataReceivedWithRequestID:(NSString *)requestID dataLength:(int64_t)dataLength
{
    dispatch_async(self.queue, ^{
        FLEXNetworkTransaction *transaction = self.networkTransactionsForRequestIdentifiers[requestID];
        if (!transaction) {
            return;
        }
        transaction.receivedDataLength += dataLength;

        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordLoadingFinishedWithRequestID:(NSString *)requestID responseBody:(NSData *)responseBody
{
    NSDate *finishedDate = [NSDate date];

    dispatch_async(self.queue, ^{
        FLEXNetworkTransaction *transaction = self.networkTransactionsForRequestIdentifiers[requestID];
        if (!transaction) {
            return;
        }
        transaction.transactionState = FLEXNetworkTransactionStateFinished;
        transaction.duration = -[transaction.startTime timeIntervalSinceDate:finishedDate];

        BOOL shouldCache = [responseBody length] > 0;
        if (!self.shouldCacheMediaResponses) {
            NSArray<NSString *> *ignoredMIMETypePrefixes = @[ @"audio", @"image", @"video" ];
            for (NSString *ignoredPrefix in ignoredMIMETypePrefixes) {
                shouldCache = shouldCache && ![transaction.response.MIMEType hasPrefix:ignoredPrefix];
            }
        }
        
        if (shouldCache) {
            [self.responseCache setObject:responseBody forKey:requestID cost:[responseBody length]];
        }

        NSString *mimeType = transaction.response.MIMEType;
        if ([mimeType hasPrefix:@"image/"] && [responseBody length] > 0) {
            // Thumbnail image previews on a separate background queue
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                NSInteger maxPixelDimension = [[UIScreen mainScreen] scale] * 32.0;
//                transaction.responseThumbnail = [FLEXUtility thumbnailedImageWithMaxPixelDimension:maxPixelDimension fromImageData:responseBody];
                
                //liman
                transaction.imageData = responseBody;
                
                [self postUpdateNotificationForTransaction:transaction];
            });
        }
        //liman
//          else if ([mimeType isEqual:@"application/json"]) {
//            transaction.responseThumbnail = [FLEXResources jsonIcon];
//        } else if ([mimeType isEqual:@"text/plain"]){
//            transaction.responseThumbnail = [FLEXResources textPlainIcon];
//        } else if ([mimeType isEqual:@"text/html"]) {
//            transaction.responseThumbnail = [FLEXResources htmlIcon];
//        } else if ([mimeType isEqual:@"application/x-plist"]) {
//            transaction.responseThumbnail = [FLEXResources plistIcon];
//        } else if ([mimeType isEqual:@"application/octet-stream"] || [mimeType isEqual:@"application/binary"]) {
//            transaction.responseThumbnail = [FLEXResources binaryIcon];
//        } else if ([mimeType rangeOfString:@"javascript"].length > 0) {
//            transaction.responseThumbnail = [FLEXResources jsIcon];
//        } else if ([mimeType rangeOfString:@"xml"].length > 0) {
//            transaction.responseThumbnail = [FLEXResources xmlIcon];
//        } else if ([mimeType hasPrefix:@"audio"]) {
//            transaction.responseThumbnail = [FLEXResources audioIcon];
//        } else if ([mimeType hasPrefix:@"video"]) {
//            transaction.responseThumbnail = [FLEXResources videoIcon];
//        } else if ([mimeType hasPrefix:@"text"]) {
//            transaction.responseThumbnail = [FLEXResources textIcon];
//        }
        
        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordLoadingFailedWithRequestID:(NSString *)requestID error:(NSError *)error
{
    dispatch_async(self.queue, ^{
        FLEXNetworkTransaction *transaction = self.networkTransactionsForRequestIdentifiers[requestID];
        if (!transaction) {
            return;
        }
        transaction.transactionState = FLEXNetworkTransactionStateFailed;
        transaction.duration = -[transaction.startTime timeIntervalSinceNow];
        transaction.error = error;

        [self postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordMechanism:(NSString *)mechanism forRequestID:(NSString *)requestID
{
    dispatch_async(self.queue, ^{
        FLEXNetworkTransaction *transaction = self.networkTransactionsForRequestIdentifiers[requestID];
        if (!transaction) {
            return;
        }
        transaction.requestMechanism = mechanism;

        [self postUpdateNotificationForTransaction:transaction];
    });
}

#pragma mark Notification Posting

- (void)postNewTransactionNotificationWithTransaction:(FLEXNetworkTransaction *)transaction
{
    //liman
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSDictionary<NSString *, id> *userInfo = @{ kFLEXNetworkRecorderUserInfoTransactionKey : transaction };
//        [[NSNotificationCenter defaultCenter] postNotificationName:kFLEXNetworkRecorderNewTransactionNotification object:self userInfo:userInfo];
//    });
    
    [self handleFLEXNetworkTransaction:transaction];
}

- (void)postUpdateNotificationForTransaction:(FLEXNetworkTransaction *)transaction
{
    //liman
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSDictionary<NSString *, id> *userInfo = @{ kFLEXNetworkRecorderUserInfoTransactionKey : transaction };
//        [[NSNotificationCenter defaultCenter] postNotificationName:kFLEXNetworkRecorderTransactionUpdatedNotification object:self userInfo:userInfo];
//    });
    
    [self handleFLEXNetworkTransaction:transaction];
}


//liman
- (void)handleFLEXNetworkTransaction:(FLEXNetworkTransaction *)transaction
{
    if (![NetworkHelper shared].isEnable) {
        return;
    }
    
    if (transaction.transactionState != FLEXNetworkTransactionStateFinished && transaction.transactionState != FLEXNetworkTransactionStateFailed) {
        return;
    }
    
    HttpModel *model = [[HttpModel alloc] init];
    model.requestId = transaction.requestID;
    model.url = transaction.request.URL;
    model.method = transaction.request.HTTPMethod;
    model.mineType = transaction.response.MIMEType;
    model.responseData = [[FLEXNetworkRecorder defaultRecorder] cachedResponseBodyForTransaction:transaction];
    model.startTime = transaction.startTime;
    model.totalDuration = [NSString stringWithFormat:@"%f (s)", transaction.duration];
    model.errorDescription = transaction.error.description;
    model.errorLocalizedDescription = transaction.error.localizedDescription;
    model.requestHeaderFields = transaction.request.allHTTPHeaderFields;
    model.isImage = [transaction.response.MIMEType rangeOfString:@"image"].location != NSNotFound;
    model.imageData = transaction.imageData;
    model.requestData = transaction.cachedRequestBody;
//    NSData *data = transaction.request.HTTPBody;
//    if (data) {
//        model.requestData = data;
//    }
//    NSInputStream *stream = transaction.request.HTTPBodyStream;
//    if (stream) {
//        model.requestData = [NSData dataWithInputStream:stream];
//    }
    
    if ([transaction.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)transaction.response;
        model.responseHeaderFields = response.allHeaderFields;
        model.statusCode = [NSString stringWithFormat:@"%ld", (long)response.statusCode];
    }
    
    if (transaction.response.MIMEType == nil) {
        model.isImage = NO;
    }
    
    NSUInteger length = [model.url.absoluteString length];
    if (length > 4) {
        NSString *str = [model.url.absoluteString substringFromIndex: length - 4];
        if ([str isEqualToString:@".png"] || [str isEqualToString:@".PNG"] || [str isEqualToString:@".jpg"] || [str isEqualToString:@".JPG"] || [str isEqualToString:@".gif"] || [str isEqualToString:@".GIF"]) {
            model.isImage = YES;
        }
    }
    if (length > 5) {
        NSString *str = [model.url.absoluteString substringFromIndex: length - 5];
        if ([str isEqualToString:@".jpeg"] || [str isEqualToString:@".JPEG"]) {
            model.isImage = YES;
        }
    }
    
    //处理500,404等错误
    model = [self handleError:transaction.error model:model];
    
    if ([[HttpDatasource shared] addHttpRequset:model]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHttp_CocoaDebug" object:nil userInfo:@{@"statusCode":model.statusCode}];
    }
}

//处理500,404等错误
- (HttpModel *)handleError:(NSError *)error model:(HttpModel *)model
{
    if (!error) {
        //https://httpstatuses.com/
        switch (model.statusCode.integerValue) {
            case 100:
                model.errorDescription = @"Informational :\nThe initial part of a request has been received and has not yet been rejected by the server. The server intends to send a final response after the request has been fully received and acted upon.";
                model.errorLocalizedDescription = @"Continue";
                break;
            case 101:
                model.errorDescription = @"Informational :\nThe server understands and is willing to comply with the client's request, via the Upgrade header field1, for a change in the application protocol being used on this connection.";
                model.errorLocalizedDescription = @"Switching Protocols";
                break;
            case 102:
                model.errorDescription = @"Informational :\nAn interim response used to inform the client that the server has accepted the complete request, but has not yet completed it.";
                model.errorLocalizedDescription = @"Processing";
                break;
            case 300:
                model.errorDescription = @"Redirection :\nThe target resource has more than one representation, each with its own more specific identifier, and information about the alternatives is being provided so that the user (or user agent) can select a preferred representation by redirecting its request to one or more of those identifiers.";
                model.errorLocalizedDescription = @"Multiple Choices";
                break;
            case 301:
                model.errorDescription = @"Redirection :\nThe target resource has been assigned a new permanent URI and any future references to this resource ought to use one of the enclosed URIs.";
                model.errorLocalizedDescription = @"Moved Permanently";
                break;
            case 302:
                model.errorDescription = @"Redirection :\nThe target resource resides temporarily under a different URI. Since the redirection might be altered on occasion, the client ought to continue to use the effective request URI for future requests.";
                model.errorLocalizedDescription = @"Found";
                break;
            case 303:
                model.errorDescription = @"Redirection :\nThe server is redirecting the user agent to a different resource, as indicated by a URI in the Location header field, which is intended to provide an indirect response to the original request.";
                model.errorLocalizedDescription = @"See Other";
                break;
            case 304:
                model.errorDescription = @"Redirection :\nA conditional GET or HEAD request has been received and would have resulted in a 200 OK response if it were not for the fact that the condition evaluated to false.";
                model.errorLocalizedDescription = @"Not Modified";
                break;
            case 305:
                model.errorDescription = @"Redirection :\nDefined in a previous version of this specification and is now deprecated, due to security concerns regarding in-band configuration of a proxy.";
                model.errorLocalizedDescription = @"Use Proxy";
                break;
            case 307:
                model.errorDescription = @"Redirection :\nThe target resource resides temporarily under a different URI and the user agent MUST NOT change the request method if it performs an automatic redirection to that URI.";
                model.errorLocalizedDescription = @"Temporary Redirect";
                break;
            case 308:
                model.errorDescription = @"Redirection :\nThe target resource has been assigned a new permanent URI and any future references to this resource ought to use one of the enclosed URIs.";
                model.errorLocalizedDescription = @"Permanent Redirect";
                break;
            case 400:
                model.errorDescription = @"Client Error :\nThe server cannot or will not process the request due to something that is perceived to be a client error (e.g., malformed request syntax, invalid request message framing, or deceptive request routing).";
                model.errorLocalizedDescription = @"Bad Request";
                break;
            case 401:
                model.errorDescription = @"Client Error :\nThe request has not been applied because it lacks valid authentication credentials for the target resource.";
                model.errorLocalizedDescription = @"Unauthorized";
                break;
            case 402:
                model.errorDescription = @"Client Error :\nReserved for future use.";
                model.errorLocalizedDescription = @"Payment Required";
                break;
            case 403:
                model.errorDescription = @"Client Error :\nThe server understood the request but refuses to authorize it.";
                model.errorLocalizedDescription = @"Forbidden";
                break;
            case 404:
                model.errorDescription = @"Client Error :\nThe origin server did not find a current representation for the target resource or is not willing to disclose that one exists.";
                model.errorLocalizedDescription = @"Not Found";
                break;
            case 405:
                model.errorDescription = @"Client Error :\nThe method received in the request-line is known by the origin server but not supported by the target resource.";
                model.errorLocalizedDescription = @"Method Not Allowed";
                break;
            case 406:
                model.errorDescription = @"Client Error :\nThe target resource does not have a current representation that would be acceptable to the user agent, according to the proactive negotiation header fields received in the request1, and the server is unwilling to supply a default representation.";
                model.errorLocalizedDescription = @"Not Acceptable";
                break;
            case 407:
                model.errorDescription = @"Client Error :\nSimilar to 401 Unauthorized, but it indicates that the client needs to authenticate itself in order to use a proxy.";
                model.errorLocalizedDescription = @"Proxy Authentication Required";
                break;
            case 408:
                model.errorDescription = @"Client Error :\nThe server did not receive a complete request message within the time that it was prepared to wait.";
                model.errorLocalizedDescription = @"Request Timeout";
                break;
            case 409:
                model.errorDescription = @"Client Error :\nThe request could not be completed due to a conflict with the current state of the target resource. This code is used in situations where the user might be able to resolve the conflict and resubmit the request.";
                model.errorLocalizedDescription = @"Conflict";
                break;
            case 410:
                model.errorDescription = @"Client Error :\nThe target resource is no longer available at the origin server and that this condition is likely to be permanent.";
                model.errorLocalizedDescription = @"Gone";
                break;
            case 411:
                model.errorDescription = @"Client Error :\nThe server refuses to accept the request without a defined Content-Length1.";
                model.errorLocalizedDescription = @"Length Required";
                break;
            case 412:
                model.errorDescription = @"Client Error :\nOne or more conditions given in the request header fields evaluated to false when tested on the server.";
                model.errorLocalizedDescription = @"Precondition Failed";
                break;
            case 413:
                model.errorDescription = @"Client Error :\nThe server is refusing to process a request because the request payload is larger than the server is willing or able to process.";
                model.errorLocalizedDescription = @"Payload Too Large";
                break;
            case 414:
                model.errorDescription = @"Client Error :\nThe server is refusing to service the request because the request-target1 is longer than the server is willing to interpret.";
                model.errorLocalizedDescription = @"Request-URI Too Long";
                break;
            case 415:
                model.errorDescription = @"Client Error :\nThe origin server is refusing to service the request because the payload is in a format not supported by this method on the target resource.";
                model.errorLocalizedDescription = @"Unsupported Media Type";
                break;
            case 416:
                model.errorDescription = @"Client Error :\nNone of the ranges in the request's Range header field1 overlap the current extent of the selected resource or that the set of ranges requested has been rejected due to invalid ranges or an excessive request of small or overlapping ranges.";
                model.errorLocalizedDescription = @"Requested Range Not Satisfiable";
                break;
            case 417:
                model.errorDescription = @"Client Error :\nThe expectation given in the request's Expect header field1 could not be met by at least one of the inbound servers.";
                model.errorLocalizedDescription = @"Expectation Failed";
                break;
            case 418:
                model.errorDescription = @"Client Error :\nAny attempt to brew coffee with a teapot should result in the error code \"418 I'm a teapot\". The resulting entity body MAY be short and stout.";
                model.errorLocalizedDescription = @"I'm a teapot";
                break;
            case 421:
                model.errorDescription = @"Client Error :\nThe request was directed at a server that is not able to produce a response. This can be sent by a server that is not configured to produce responses for the combination of scheme and authority that are included in the request URI.";
                model.errorLocalizedDescription = @"Misdirected Request";
                break;
            case 422:
                model.errorDescription = @"Client Error :\nThe server understands the content type of the request entity (hence a 415 Unsupported Media Type status code is inappropriate), and the syntax of the request entity is correct (thus a 400 Bad Request status code is inappropriate) but was unable to process the contained instructions.";
                model.errorLocalizedDescription = @"Unprocessable Entity";
                break;
            case 423:
                model.errorDescription = @"Client Error :\nThe source or destination resource of a method is locked.";
                model.errorLocalizedDescription = @"Locked";
                break;
            case 424:
                model.errorDescription = @"Client Error :\nThe method could not be performed on the resource because the requested action depended on another action and that action failed.";
                model.errorLocalizedDescription = @"Failed Dependency";
                break;
            case 426:
                model.errorDescription = @"Client Error :\nThe server refuses to perform the request using the current protocol but might be willing to do so after the client upgrades to a different protocol.";
                model.errorLocalizedDescription = @"Upgrade Required";
                break;
            case 428:
                model.errorDescription = @"Client Error :\nThe origin server requires the request to be conditional.";
                model.errorLocalizedDescription = @"Precondition Required";
                break;
            case 429:
                model.errorDescription = @"Client Error :\nThe user has sent too many requests in a given amount of time (\"rate limiting\").";
                model.errorLocalizedDescription = @"Too Many Requests";
                break;
            case 431:
                model.errorDescription = @"Client Error :\nThe server is unwilling to process the request because its header fields are too large. The request MAY be resubmitted after reducing the size of the request header fields.";
                model.errorLocalizedDescription = @"Request Header Fields Too Large";
                break;
            case 444:
                model.errorDescription = @"Client Error :\nA non-standard status code used to instruct nginx to close the connection without sending a response to the client, most commonly used to deny malicious or malformed requests.";
                model.errorLocalizedDescription = @"Connection Closed Without Response";
                break;
            case 451:
                model.errorDescription = @"Client Error :\nThe server is denying access to the resource as a consequence of a legal demand.";
                model.errorLocalizedDescription = @"Unavailable For Legal Reasons";
                break;
            case 499:
                model.errorDescription = @"Client Error :\nA non-standard status code introduced by nginx for the case when a client closes the connection while nginx is processing the request.";
                model.errorLocalizedDescription = @"Client Closed Request";
                break;
            case 500:
                model.errorDescription = @"Server Error :\nThe server encountered an unexpected condition that prevented it from fulfilling the request.";
                model.errorLocalizedDescription = @"Internal Server Error";
                break;
            case 501:
                model.errorDescription = @"Server Error :\nThe server does not support the functionality required to fulfill the request.";
                model.errorLocalizedDescription = @"Not Implemented";
                break;
            case 502:
                model.errorDescription = @"Server Error :\nThe server, while acting as a gateway or proxy, received an invalid response from an inbound server it accessed while attempting to fulfill the request.";
                model.errorLocalizedDescription = @"Bad Gateway";
                break;
            case 503:
                model.errorDescription = @"Server Error :\nThe server is currently unable to handle the request due to a temporary overload or scheduled maintenance, which will likely be alleviated after some delay.";
                model.errorLocalizedDescription = @"Service Unavailable";
                break;
            case 504:
                model.errorDescription = @"Server Error :\nThe server, while acting as a gateway or proxy, did not receive a timely response from an upstream server it needed to access in order to complete the request.";
                model.errorLocalizedDescription = @"Gateway Timeout";
                break;
            case 505:
                model.errorDescription = @"Server Error :\nThe server does not support, or refuses to support, the major version of HTTP that was used in the request message.";
                model.errorLocalizedDescription = @"HTTP Version Not Supported";
                break;
            case 506:
                model.errorDescription = @"Server Error :\nThe server has an internal configuration error: the chosen variant resource is configured to engage in transparent content negotiation itself, and is therefore not a proper end point in the negotiation process.";
                model.errorLocalizedDescription = @"Variant Also Negotiates";
                break;
            case 507:
                model.errorDescription = @"Server Error :\nThe method could not be performed on the resource because the server is unable to store the representation needed to successfully complete the request.";
                model.errorLocalizedDescription = @"Insufficient Storage";
                break;
            case 508:
                model.errorDescription = @"Server Error :\nThe server terminated an operation because it encountered an infinite loop while processing a request with \"Depth: infinity\". This status indicates that the entire operation failed.";
                model.errorLocalizedDescription = @"Loop Detected";
                break;
            case 510:
                model.errorDescription = @"Server Error :\nThe policy for accessing the resource has not been met in the request. The server should send back all the information necessary for the client to issue an extended request.";
                model.errorLocalizedDescription = @"Not Extended";
                break;
            case 511:
                model.errorDescription = @"Server Error :\nThe client needs to authenticate to gain network access.";
                model.errorLocalizedDescription = @"Network Authentication Required";
                break;
            case 599:
                model.errorDescription = @"Server Error :\nThis status code is not specified in any RFCs, but is used by some HTTP proxies to signal a network connect timeout behind the proxy to a client in front of the proxy.";
                model.errorLocalizedDescription = @"Network Connect Timeout Error";
                break;
            default:
                break;
        }
    }
    
    return model;
}

@end
