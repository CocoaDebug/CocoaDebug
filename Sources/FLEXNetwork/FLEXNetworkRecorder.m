//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
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

//liman
@property (nonatomic, strong) dispatch_queue_t concurrent_queue;

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
        
        //liman
        self.concurrent_queue = dispatch_queue_create("com.liman.cocoadebug", DISPATCH_QUEUE_CONCURRENT);
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
    //liman
    __weak FLEXNetworkRecorder *weakSelf = self;
    
    __block NSArray<FLEXNetworkTransaction *> *transactions = nil;
    dispatch_sync(self.queue, ^{
        transactions = [weakSelf.orderedTransactions copy];
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
    
    //liman
    __weak FLEXNetworkRecorder *weakSelf = self;

    dispatch_async(self.queue, ^{
        FLEXNetworkTransaction *transaction = [[FLEXNetworkTransaction alloc] init];
        transaction.requestID = requestID;
        transaction.request = request;
        transaction.startTime = startDate;

        [weakSelf.orderedTransactions insertObject:transaction atIndex:0];
        [weakSelf.networkTransactionsForRequestIdentifiers setObject:transaction forKey:requestID];
        transaction.transactionState = FLEXNetworkTransactionStateAwaitingResponse;

        [weakSelf postNewTransactionNotificationWithTransaction:transaction];
    });
}

- (void)recordResponseReceivedWithRequestID:(NSString *)requestID response:(NSURLResponse *)response
{
    NSDate *responseDate = [NSDate date];

    //liman
    __weak FLEXNetworkRecorder *weakSelf = self;
    
    dispatch_async(self.queue, ^{
        FLEXNetworkTransaction *transaction = weakSelf.networkTransactionsForRequestIdentifiers[requestID];
        if (!transaction) {
            return;
        }
        transaction.response = response;
        transaction.transactionState = FLEXNetworkTransactionStateReceivingData;
        transaction.latency = -[transaction.startTime timeIntervalSinceDate:responseDate];

        [weakSelf postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordDataReceivedWithRequestID:(NSString *)requestID dataLength:(int64_t)dataLength
{
    //liman
    __weak FLEXNetworkRecorder *weakSelf = self;
    
    dispatch_async(self.queue, ^{
        FLEXNetworkTransaction *transaction = weakSelf.networkTransactionsForRequestIdentifiers[requestID];
        if (!transaction) {
            return;
        }
        transaction.receivedDataLength += dataLength;

        [weakSelf postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordLoadingFinishedWithRequestID:(NSString *)requestID responseBody:(NSData *)responseBody
{
    NSDate *finishedDate = [NSDate date];

    //liman
    __weak FLEXNetworkRecorder *weakSelf = self;
    
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
                
                [weakSelf postUpdateNotificationForTransaction:transaction];
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
        
        [weakSelf postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordLoadingFailedWithRequestID:(NSString *)requestID error:(NSError *)error
{
    //liman
    __weak FLEXNetworkRecorder *weakSelf = self;
    
    dispatch_async(self.queue, ^{
        FLEXNetworkTransaction *transaction = weakSelf.networkTransactionsForRequestIdentifiers[requestID];
        if (!transaction) {
            return;
        }
        transaction.transactionState = FLEXNetworkTransactionStateFailed;
        transaction.duration = -[transaction.startTime timeIntervalSinceNow];
        transaction.error = error;

        [weakSelf postUpdateNotificationForTransaction:transaction];
    });
}

- (void)recordMechanism:(NSString *)mechanism forRequestID:(NSString *)requestID
{
    //liman
    __weak FLEXNetworkRecorder *weakSelf = self;
    
    dispatch_async(self.queue, ^{
        FLEXNetworkTransaction *transaction = weakSelf.networkTransactionsForRequestIdentifiers[requestID];
        if (!transaction) {
            return;
        }
        transaction.requestMechanism = mechanism;

        [weakSelf postUpdateNotificationForTransaction:transaction];
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
    __weak FLEXNetworkRecorder *weakSelf = self;
    
    //栅栏
    dispatch_barrier_async(self.concurrent_queue, ^{
        [weakSelf _handleFLEXNetworkTransaction:transaction];
    });
    
    //信号量
//    dispatch_semaphore_t sem = dispatch_semaphore_create(1);
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [weakSelf _handleFLEXNetworkTransaction:transaction];
//        dispatch_semaphore_signal(sem);
//    });
//    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}

//liman
- (void)_handleFLEXNetworkTransaction:(FLEXNetworkTransaction *)transaction
{
    if (![NetworkHelper shared].isEnable) {
        return;
    }
    
    if (transaction.transactionState != FLEXNetworkTransactionStateFinished && transaction.transactionState != FLEXNetworkTransactionStateFailed) {
        return;
    }
    
    
//    FLEXNetworkTransactionStateUnstarted,
//    FLEXNetworkTransactionStateAwaitingResponse,
//    FLEXNetworkTransactionStateReceivingData,
//    FLEXNetworkTransactionStateFinished,
//    FLEXNetworkTransactionStateFailed
    
    
    HttpModel *model = [[HttpModel alloc] init];
    model.requestId = transaction.requestID;
//    model.url = transaction.request.URL;
    
    NSURL *url = transaction.request.URL;
    if (url) {
        model.url = url;
    }
    
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
    
    model.size = [NSByteCountFormatter stringFromByteCount:transaction.receivedDataLength countStyle:NSByteCountFormatterCountStyleBinary];
    
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
        //https://httpcodes.co/status/
        switch (model.statusCode.integerValue) {
            case 100:
                model.errorDescription = @"Informational :\nClient should continue with request";
                model.errorLocalizedDescription = @"Continue";
                break;
            case 101:
                model.errorDescription = @"Informational :\nServer is switching protocols";
                model.errorLocalizedDescription = @"Switching Protocols";
                break;
            case 102:
                model.errorDescription = @"Informational :\nServer has received and is processing the request";
                model.errorLocalizedDescription = @"Processing";
                break;
            case 103:
                model.errorDescription = @"Informational :\nresume aborted PUT or POST requests";
                model.errorLocalizedDescription = @"Checkpoint";
                break;
            case 122:
                model.errorDescription = @"Informational :\nURI is longer than a maximum of 2083 characters";
                model.errorLocalizedDescription = @"Request-URI too long";
                break;
            case 300:
                model.errorDescription = @"Redirection :\nMultiple options for the resource delivered";
                model.errorLocalizedDescription = @"Multiple Choices";
                break;
            case 301:
                model.errorDescription = @"Redirection :\nThis and all future requests directed to the given URI";
                model.errorLocalizedDescription = @"Moved Permanently";
                break;
            case 302:
                model.errorDescription = @"Redirection :\nTemporary response to request found via alternative URI";
                model.errorLocalizedDescription = @"Found";
                break;
            case 303:
                model.errorDescription = @"Redirection :\nPermanent response to request found via alternative URI";
                model.errorLocalizedDescription = @"See Other";
                break;
            case 304:
                model.errorDescription = @"Redirection :\nResource has not been modified since last requested";
                model.errorLocalizedDescription = @"Not Modified";
                break;
            case 305:
                model.errorDescription = @"Redirection :\nContent located elsewhere, retrieve from there";
                model.errorLocalizedDescription = @"Use Proxy";
                break;
            case 306:
                model.errorDescription = @"Redirection :\nSubsequent requests should use the specified proxy";
                model.errorLocalizedDescription = @"Switch Proxy";
                break;
            case 307:
                model.errorDescription = @"Redirection :\nConnect again to different URI as provided";
                model.errorLocalizedDescription = @"Temporary Redirect";
                break;
            case 308:
                model.errorDescription = @"Redirection :\nConnect again to a different URI using the same method";
                model.errorLocalizedDescription = @"Permanent Redirect";
                break;
            case 400:
                model.errorDescription = @"Client Error :\nRequest cannot be fulfilled due to bad syntax";
                model.errorLocalizedDescription = @"Bad Request";
                break;
            case 401:
                model.errorDescription = @"Client Error :\nAuthentication is possible but has failed";
                model.errorLocalizedDescription = @"Unauthorized";
                break;
            case 402:
                model.errorDescription = @"Client Error :\nPayment required, reserved for future use";
                model.errorLocalizedDescription = @"Payment Required";
                break;
            case 403:
                model.errorDescription = @"Client Error :\nServer refuses to respond to request";
                model.errorLocalizedDescription = @"Forbidden";
                break;
            case 404:
                model.errorDescription = @"Client Error :\nRequested resource could not be found";
                model.errorLocalizedDescription = @"Not Found";
                break;
            case 405:
                model.errorDescription = @"Client Error :\nRequest method not supported by that resource";
                model.errorLocalizedDescription = @"Method Not Allowed";
                break;
            case 406:
                model.errorDescription = @"Client Error :\nContent not acceptable according to the Accept headers";
                model.errorLocalizedDescription = @"Not Acceptable";
                break;
            case 407:
                model.errorDescription = @"Client Error :\nClient must first authenticate itself with the proxy";
                model.errorLocalizedDescription = @"Proxy Authentication Required";
                break;
            case 408:
                model.errorDescription = @"Client Error :\nServer timed out waiting for the request";
                model.errorLocalizedDescription = @"Request Timeout";
                break;
            case 409:
                model.errorDescription = @"Client Error :\nRequest could not be processed because of conflict";
                model.errorLocalizedDescription = @"Conflict";
                break;
            case 410:
                model.errorDescription = @"Client Error :\nResource is no longer available and will not be available again";
                model.errorLocalizedDescription = @"Gone";
                break;
            case 411:
                model.errorDescription = @"Client Error :\nRequest did not specify the length of its content";
                model.errorLocalizedDescription = @"Length Required";
                break;
            case 412:
                model.errorDescription = @"Client Error :\nServer does not meet request preconditions";
                model.errorLocalizedDescription = @"Precondition Failed";
                break;
            case 413:
                model.errorDescription = @"Client Error :\nRequest is larger than the server is willing or able to process";
                model.errorLocalizedDescription = @"Request Entity Too Large";
                break;
            case 414:
                model.errorDescription = @"Client Error :\nURI provided was too long for the server to process";
                model.errorLocalizedDescription = @"Request-URI Too Long";
                break;
            case 415:
                model.errorDescription = @"Client Error :\nServer does not support media type";
                model.errorLocalizedDescription = @"Unsupported Media Type";
                break;
            case 416:
                model.errorDescription = @"Client Error :\nClient has asked for unprovidable portion of the file";
                model.errorLocalizedDescription = @"Requested Range Not Satisfiable";
                break;
            case 417:
                model.errorDescription = @"Client Error :\nServer cannot meet requirements of Expect request-header field";
                model.errorLocalizedDescription = @"Expectation Failed";
                break;
            case 418:
                model.errorDescription = @"Client Error :\nI'm a teapot";
                model.errorLocalizedDescription = @"I'm a Teapot";
                break;
            case 420:
                model.errorDescription = @"Client Error :\nTwitter rate limiting";
                model.errorLocalizedDescription = @"Enhance Your Calm";
                break;
            case 421:
                model.errorDescription = @"Client Error :\nMisdirected Request";
                model.errorLocalizedDescription = @"Misdirected Request";
                break;
            case 422:
                model.errorDescription = @"Client Error :\nRequest unable to be followed due to semantic errors";
                model.errorLocalizedDescription = @"Unprocessable Entity";
                break;
            case 423:
                model.errorDescription = @"Client Error :\nResource that is being accessed is locked";
                model.errorLocalizedDescription = @"Locked";
                break;
            case 424:
                model.errorDescription = @"Client Error :\nRequest failed due to failure of a previous request";
                model.errorLocalizedDescription = @"Failed Dependency";
                break;
            case 426:
                model.errorDescription = @"Client Error :\nClient should switch to a different protocol";
                model.errorLocalizedDescription = @"Upgrade Required";
                break;
            case 428:
                model.errorDescription = @"Client Error :\nOrigin server requires the request to be conditional";
                model.errorLocalizedDescription = @"Precondition Required";
                break;
            case 429:
                model.errorDescription = @"Client Error :\nUser has sent too many requests in a given amount of time";
                model.errorLocalizedDescription = @"Too Many Requests";
                break;
            case 431:
                model.errorDescription = @"Client Error :\nServer is unwilling to process the request";
                model.errorLocalizedDescription = @"Request Header Fields Too Large";
                break;
            case 444:
                model.errorDescription = @"Client Error :\nServer returns no information and closes the connection";
                model.errorLocalizedDescription = @"No Response";
                break;
            case 449:
                model.errorDescription = @"Client Error :\nRequest should be retried after performing action";
                model.errorLocalizedDescription = @"Retry With";
                break;
            case 450:
                model.errorDescription = @"Client Error :\nWindows Parental Controls blocking access to webpage";
                model.errorLocalizedDescription = @"Blocked by Windows Parental Controls";
                break;
            case 451:
                model.errorDescription = @"Client Error :\nThe server cannot reach the client's mailbox";
                model.errorLocalizedDescription = @"Wrong Exchange server";
                break;
            case 499:
                model.errorDescription = @"Client Error :\nConnection closed by client while HTTP server is processing";
                model.errorLocalizedDescription = @"Client Closed Request";
                break;
            case 500:
                model.errorDescription = @"Server Error :\ngeneric error message";
                model.errorLocalizedDescription = @"Internal Server Error";
                break;
            case 501:
                model.errorDescription = @"Server Error :\nserver does not recognise method or lacks ability to fulfill";
                model.errorLocalizedDescription = @"Not Implemented";
                break;
            case 502:
                model.errorDescription = @"Server Error :\nserver received an invalid response from upstream server";
                model.errorLocalizedDescription = @"Bad Gateway";
                break;
            case 503:
                model.errorDescription = @"Server Error :\nserver is currently unavailable";
                model.errorLocalizedDescription = @"Service Unavailable";
                break;
            case 504:
                model.errorDescription = @"Server Error :\ngateway did not receive response from upstream server";
                model.errorLocalizedDescription = @"Gateway Timeout";
                break;
            case 505:
                model.errorDescription = @"Server Error :\nserver does not support the HTTP protocol version";
                model.errorLocalizedDescription = @"HTTP Version Not Supported";
                break;
            case 506:
                model.errorDescription = @"Server Error :\ncontent negotiation for the request results in a circular reference";
                model.errorLocalizedDescription = @"Variant Also Negotiates";
                break;
            case 507:
                model.errorDescription = @"Server Error :\nserver is unable to store the representation";
                model.errorLocalizedDescription = @"Insufficient Storage";
                break;
            case 508:
                model.errorDescription = @"Server Error :\nserver detected an infinite loop while processing the request";
                model.errorLocalizedDescription = @"Loop Detected";
                break;
            case 509:
                model.errorDescription = @"Server Error :\nbandwidth limit exceeded";
                model.errorLocalizedDescription = @"Bandwidth Limit Exceeded";
                break;
            case 510:
                model.errorDescription = @"Server Error :\nfurther extensions to the request are required";
                model.errorLocalizedDescription = @"Not Extended";
                break;
            case 511:
                model.errorDescription = @"Server Error :\nclient needs to authenticate to gain network access";
                model.errorLocalizedDescription = @"Network Authentication Required";
                break;
            case 526:
                model.errorDescription = @"Server Error :\nThe origin web server does not have a valid SSL certificate";
                model.errorLocalizedDescription = @"Invalid SSL certificate";
                break;
            case 598:
                model.errorDescription = @"Server Error :\nnetwork read timeout behind the proxy";
                model.errorLocalizedDescription = @"Network Read Timeout Error";
                break;
            case 599:
                model.errorDescription = @"Server Error :\nnetwork connect timeout behind the proxy";
                model.errorLocalizedDescription = @"Network Connect Timeout Error";
                break;
            default:
                break;
        }
    }
    
    return model;
}

@end
