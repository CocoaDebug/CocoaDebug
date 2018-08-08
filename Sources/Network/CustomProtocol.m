//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "CustomProtocol.h"
#import "NetworkHelper.h"
#import "HttpDatasource.h"
#import "NSObject+CocoaDebug.h"
#import "Swizzling.h"
#import "CacheStoragePolicy.h"

#define kProtocolKey   @"CustomProtocol"

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}


typedef NSURLSessionConfiguration *(*SessionConfigConstructor)(id,SEL);

static SessionConfigConstructor orig_defaultSessionConfiguration;
static SessionConfigConstructor orig_ephemeralSessionConfiguration;

static NSURLSessionConfiguration *replaced_defaultSessionConfiguration(id self, SEL _cmd)
{
    NSURLSessionConfiguration *config = orig_defaultSessionConfiguration(self,_cmd);
    
    if ([config respondsToSelector:@selector(protocolClasses)] && [config respondsToSelector:@selector(setProtocolClasses:)]) {
        NSMutableArray *urlProtocolClasses = [NSMutableArray arrayWithArray:config.protocolClasses];
        Class protoCls = CustomProtocol.class;
        if (![urlProtocolClasses containsObject:protoCls]) {
            [urlProtocolClasses insertObject:protoCls atIndex:0];
        }
        
        config.protocolClasses = urlProtocolClasses;
    }
    
    return config;
}

static NSURLSessionConfiguration *replaced_ephemeralSessionConfiguration(id self, SEL _cmd)
{
    NSURLSessionConfiguration *config = orig_ephemeralSessionConfiguration(self,_cmd);
    
    if ([config respondsToSelector:@selector(protocolClasses)] && [config respondsToSelector:@selector(setProtocolClasses:)]) {
        NSMutableArray *urlProtocolClasses = [NSMutableArray arrayWithArray:config.protocolClasses];
        Class protoCls = CustomProtocol.class;
        if (![urlProtocolClasses containsObject:protoCls]) {
            [urlProtocolClasses insertObject:protoCls atIndex:0];
        }
        
        config.protocolClasses = urlProtocolClasses;
    }
    
    return config;
}

#pragma mark -------------------------------------------------------------------------------------

@interface CustomProtocol() <NSURLSessionDataDelegate>
@property (atomic, strong) NSURLSession          *session;
@property (atomic, strong) NSURLSessionDataTask  *task;
@property (atomic, strong) NSURLResponse         *response;
@property (atomic, strong) NSMutableData         *data;
@property (atomic, strong) NSError               *error;
@property (atomic, assign) NSTimeInterval        startTime;
@end

@implementation CustomProtocol


#pragma mark - init
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        orig_defaultSessionConfiguration = (SessionConfigConstructor)replaceMethod(@selector(defaultSessionConfiguration), (IMP)replaced_defaultSessionConfiguration, [NSURLSessionConfiguration class], YES);
        
        orig_ephemeralSessionConfiguration = (SessionConfigConstructor)replaceMethod(@selector(ephemeralSessionConfiguration), (IMP)replaced_ephemeralSessionConfiguration, [NSURLSessionConfiguration class], YES);
    });
}

#pragma mark - protocol
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    
    if ([NSURLProtocol propertyForKey:kProtocolKey inRequest:request] ) {
        return NO;
    }
    
    if ([[NetworkHelper shared] onlyURLs].count > 0) {
        NSString* url = [request.URL.absoluteString lowercaseString];
        for (NSString* _url in [NetworkHelper shared].onlyURLs) {
            if ([url rangeOfString:[_url lowercaseString]].location != NSNotFound)
                return YES;
        }
        return NO;
    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading
{
    self.data = [NSMutableData data];
    self.startTime = [[NSDate date] timeIntervalSince1970];
    
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:kProtocolKey inRequest:mutableReqeust];
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    self.task = [self.session dataTaskWithRequest:mutableReqeust];
    [self.task resume];
}

- (void)stopLoading
{
    if (self.task) {
        [self.task cancel];
        self.task = nil;
        self.session = nil;
    }
    
    
    if (![NetworkHelper shared].isEnable) {
        return;
    }
    
    
    HttpModel* model = [[HttpModel alloc] init];
    model.url = self.request.URL;
    model.method = self.request.HTTPMethod;
    model.mineType = self.response.MIMEType;
    if (self.request.HTTPBody) {
        model.requestData = self.request.HTTPBody;
    }
    if (self.request.HTTPBodyStream) {//liman
        NSData* data = [NSData dataWithInputStream:self.request.HTTPBodyStream];
        model.requestData = data;
    }
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)self.response;
    model.statusCode = [NSString stringWithFormat:@"%d",(int)httpResponse.statusCode];
    model.responseData = self.data;
    model.isImage = [self.response.MIMEType rangeOfString:@"image"].location != NSNotFound;
    
    //时间
    NSTimeInterval startTimeDouble = self.startTime;
    NSTimeInterval endTimeDouble = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval durationDouble = fabs(endTimeDouble - startTimeDouble);
    
    model.startTime = [NSString stringWithFormat:@"%f", startTimeDouble];
    model.endTime = [NSString stringWithFormat:@"%f", endTimeDouble];
    model.totalDuration = [NSString stringWithFormat:@"%f (s)", durationDouble];
    
    
    model.errorDescription = self.error.description;
    model.errorLocalizedDescription = self.error.localizedDescription;
    model.requestHeaderFields = self.request.allHTTPHeaderFields;
    
    if ([self.response isKindOfClass:[NSHTTPURLResponse class]]) {
        model.responseHeaderFields = ((NSHTTPURLResponse *)self.response).allHeaderFields;
    }
    
    if (self.response.MIMEType == nil) {
        model.isImage = NO;
    }
    
    if ([model.url.absoluteString length] > 4) {
        NSString *str = [model.url.absoluteString substringFromIndex: [model.url.absoluteString length] - 4];
        if ([str isEqualToString:@".png"] || [str isEqualToString:@".PNG"] || [str isEqualToString:@".jpg"] || [str isEqualToString:@".JPG"] || [str isEqualToString:@".gif"] || [str isEqualToString:@".GIF"]) {
            model.isImage = YES;
        }
    }
    if ([model.url.absoluteString length] > 5) {
        NSString *str = [model.url.absoluteString substringFromIndex: [model.url.absoluteString length] - 5];
        if ([str isEqualToString:@".jpeg"] || [str isEqualToString:@".JPEG"]) {
            model.isImage = YES;
        }
    }
    
    //处理500,404等错误
    model = [self handleError:self.error model:model];
    
    
    if ([[HttpDatasource shared] addHttpRequset:model])
    {
        dispatch_main_async_safe(^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHttp_CocoaDebug" object:nil userInfo:@{@"statusCode":model.statusCode}];
        })
    }
}

#pragma mark - NSURLSessionDataDelegate
//解决发送IP地址的HTTPS请求 证书验证
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    if (!challenge) {
        return;
    }
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        // 构造一个 NSURLCredential 发送给发送方
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        // 对于其他验证方法直接进行处理流程
        [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [[self client] URLProtocol:self didLoadData:data];
    [self.data appendData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    self.response = response;
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        [[self client] URLProtocol:self didFailWithError:error];
        self.error = error;
    } else {
        [[self client] URLProtocolDidFinishLoading:self];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler
{
    //重定向 状态码 >=300 && < 400
    if (response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger status = httpResponse.statusCode;
        if (status >= 300 && status < 400) {
            [self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
            // 记得设置成nil，要不然正常请求会请求两次
            request = nil;
        }
    }
    
    completionHandler(request);
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    if (error) {
        [[self client] URLProtocol:self didFailWithError:error];
        self.error = error;
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    [[self client] URLProtocolDidFinishLoading:self];
}

#pragma mark - helper
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











/*
 
 //
 //  Example
 //  man
 //
 //  Created by man on 11/11/2018.
 //  Copyright © 2018 man. All rights reserved.
 //
 
 #import "CustomProtocol.h"
 #import "NetworkHelper.h"
 #import "HttpDatasource.h"
 #import "NSObject+CocoaDebug.h"
 #import "Swizzling.h"
 #import "CacheStoragePolicy.h"
 
 #define kProtocolKey   @"CustomProtocol"
 
 #define dispatch_main_async_safe(block)\
 if ([NSThread isMainThread]) {\
 block();\
 } else {\
 dispatch_async(dispatch_get_main_queue(), block);\
 }
 
 
 typedef NSURLSessionConfiguration *(*SessionConfigConstructor)(id,SEL);
 
 static SessionConfigConstructor orig_defaultSessionConfiguration;
 static SessionConfigConstructor orig_ephemeralSessionConfiguration;
 //static SessionConfigConstructor orig_backgroundSessionConfiguration; //Deprecated
 //static SessionConfigConstructor orig_backgroundSessionConfigurationWithIdentifier;
 
 
 static NSURLSessionConfiguration *replaced_defaultSessionConfiguration(id self, SEL _cmd)
 {
 NSURLSessionConfiguration *config = orig_defaultSessionConfiguration(self,_cmd);
 
 if ([config respondsToSelector:@selector(protocolClasses)] && [config respondsToSelector:@selector(setProtocolClasses:)]) {
 NSMutableArray *urlProtocolClasses = [NSMutableArray arrayWithArray:config.protocolClasses];
 Class protoCls = CustomProtocol.class;
 if (![urlProtocolClasses containsObject:protoCls]) {
 [urlProtocolClasses insertObject:protoCls atIndex:0];
 }
 
 config.protocolClasses = urlProtocolClasses;
 }
 
 return config;
 }
 
 static NSURLSessionConfiguration *replaced_ephemeralSessionConfiguration(id self, SEL _cmd)
 {
 NSURLSessionConfiguration *config = orig_ephemeralSessionConfiguration(self,_cmd);
 
 if ([config respondsToSelector:@selector(protocolClasses)] && [config respondsToSelector:@selector(setProtocolClasses:)]) {
 NSMutableArray *urlProtocolClasses = [NSMutableArray arrayWithArray:config.protocolClasses];
 Class protoCls = CustomProtocol.class;
 if (![urlProtocolClasses containsObject:protoCls]) {
 [urlProtocolClasses insertObject:protoCls atIndex:0];
 }
 
 config.protocolClasses = urlProtocolClasses;
 }
 
 return config;
 }
 
 //Deprecated
 //static NSURLSessionConfiguration *replaced_backgroundSessionConfiguration(id self, SEL _cmd)
 //{
 //    NSURLSessionConfiguration *config = orig_backgroundSessionConfiguration(self,_cmd);
 //
 //    if ([config respondsToSelector:@selector(protocolClasses)] && [config respondsToSelector:@selector(setProtocolClasses:)]) {
 //        NSMutableArray *urlProtocolClasses = [NSMutableArray arrayWithArray:config.protocolClasses];
 //        Class protoCls = CustomProtocol.class;
 //        if (![urlProtocolClasses containsObject:protoCls]) {
 //            [urlProtocolClasses insertObject:protoCls atIndex:0];
 //        }
 //
 //        config.protocolClasses = urlProtocolClasses;
 //    }
 //
 //    return config;
 //}
 
 //static NSURLSessionConfiguration *replaced_backgroundSessionConfigurationWithIdentifier(id self, SEL _cmd)
 //{
 //    NSURLSessionConfiguration *config = orig_backgroundSessionConfigurationWithIdentifier(self,_cmd);
 //
 //    if ([config respondsToSelector:@selector(protocolClasses)] && [config respondsToSelector:@selector(setProtocolClasses:)]) {
 //        NSMutableArray *urlProtocolClasses = [NSMutableArray arrayWithArray:config.protocolClasses];
 //        Class protoCls = CustomProtocol.class;
 //        if (![urlProtocolClasses containsObject:protoCls]) {
 //            [urlProtocolClasses insertObject:protoCls atIndex:0];
 //        }
 //
 //        config.protocolClasses = urlProtocolClasses;
 //    }
 //
 //    return config;
 //}
 
 #pragma mark -------------------------------------------------------------------------------------
 
 @interface CustomProtocol() <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
 @property (atomic, strong) NSURLConnection  *connection;
 @property (atomic, strong) NSURLResponse    *response;
 @property (atomic, strong) NSMutableData    *data;
 @property (atomic, strong) NSError          *error;
 @property (atomic, assign) NSTimeInterval   startTime;
 @end
 
 @implementation CustomProtocol
 
 
 #pragma mark - init
 + (void)load
 {
 static dispatch_once_t onceToken;
 dispatch_once(&onceToken, ^{
 
 orig_defaultSessionConfiguration = (SessionConfigConstructor)replaceMethod(@selector(defaultSessionConfiguration), (IMP)replaced_defaultSessionConfiguration, [NSURLSessionConfiguration class], YES);
 
 orig_ephemeralSessionConfiguration = (SessionConfigConstructor)replaceMethod(@selector(ephemeralSessionConfiguration), (IMP)replaced_ephemeralSessionConfiguration, [NSURLSessionConfiguration class], YES);
 
 //Deprecated
 //        orig_backgroundSessionConfiguration = (SessionConfigConstructor)replaceMethod(@selector(backgroundSessionConfiguration:), (IMP)replaced_backgroundSessionConfiguration, [NSURLSessionConfiguration class], YES);
 
 //        orig_backgroundSessionConfigurationWithIdentifier = (SessionConfigConstructor)replaceMethod(@selector(backgroundSessionConfigurationWithIdentifier:), (IMP)replaced_backgroundSessionConfigurationWithIdentifier, [NSURLSessionConfiguration class], YES);
 });
 }
 
 #pragma mark - protocol
 + (BOOL)canInitWithRequest:(NSURLRequest *)request
 {
 if (![request.URL.scheme isEqualToString:@"http"] &&
 ![request.URL.scheme isEqualToString:@"https"]) {
 return NO;
 }
 
 if ([NSURLProtocol propertyForKey:kProtocolKey inRequest:request] ) {
 return NO;
 }
 
 if ([[NetworkHelper shared] onlyURLs].count > 0) {
 NSString* url = [request.URL.absoluteString lowercaseString];
 for (NSString* _url in [NetworkHelper shared].onlyURLs) {
 if ([url rangeOfString:[_url lowercaseString]].location != NSNotFound)
 return YES;
 }
 return NO;
 }
 
 return YES;
 }
 
 + (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
 {
 return request;
 }
 
 + (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
 {
 return [super requestIsCacheEquivalent:a toRequest:b];
 }
 
 - (void)startLoading
 {
 self.data = [NSMutableData data];
 self.startTime = [[NSDate date] timeIntervalSince1970];
 
 NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
 [NSURLProtocol setProperty:@YES forKey:kProtocolKey inRequest:mutableReqeust];
 self.connection = [NSURLConnection connectionWithRequest:mutableReqeust delegate:self];
 }
 
 - (void)stopLoading
 {
 if (self.connection) {
 [self.connection cancel];
 self.connection = nil;
 }
 
 
 if (![NetworkHelper shared].isEnable) {
 return;
 }
 
 
 HttpModel* model = [[HttpModel alloc] init];
 model.url = self.request.URL;
 model.method = self.request.HTTPMethod;
 model.mineType = self.response.MIMEType;
 if (self.request.HTTPBody) {
 model.requestData = self.request.HTTPBody;
 }
 if (self.request.HTTPBodyStream) {//liman
 NSData* data = [NSData dataWithInputStream:self.request.HTTPBodyStream];
 model.requestData = data;
 }
 
 NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)self.response;
 model.statusCode = [NSString stringWithFormat:@"%d",(int)httpResponse.statusCode];
 model.responseData = self.data;
 model.isImage = [self.response.MIMEType rangeOfString:@"image"].location != NSNotFound;
 
 //时间
 NSTimeInterval startTimeDouble = self.startTime;
 NSTimeInterval endTimeDouble = [[NSDate date] timeIntervalSince1970];
 NSTimeInterval durationDouble = fabs(endTimeDouble - startTimeDouble);
 
 model.startTime = [NSString stringWithFormat:@"%f", startTimeDouble];
 model.endTime = [NSString stringWithFormat:@"%f", endTimeDouble];
 model.totalDuration = [NSString stringWithFormat:@"%f (s)", durationDouble];
 
 
 model.errorDescription = self.error.description;
 model.errorLocalizedDescription = self.error.localizedDescription;
 model.requestHeaderFields = self.request.allHTTPHeaderFields;
 
 if ([self.response isKindOfClass:[NSHTTPURLResponse class]]) {
 model.responseHeaderFields = ((NSHTTPURLResponse *)self.response).allHeaderFields;
 }
 
 if (self.response.MIMEType == nil) {
 model.isImage = NO;
 }
 
 if ([model.url.absoluteString length] > 4) {
 NSString *str = [model.url.absoluteString substringFromIndex: [model.url.absoluteString length] - 4];
 if ([str isEqualToString:@".png"] || [str isEqualToString:@".PNG"] || [str isEqualToString:@".jpg"] || [str isEqualToString:@".JPG"] || [str isEqualToString:@".gif"] || [str isEqualToString:@".GIF"]) {
 model.isImage = YES;
 }
 }
 if ([model.url.absoluteString length] > 5) {
 NSString *str = [model.url.absoluteString substringFromIndex: [model.url.absoluteString length] - 5];
 if ([str isEqualToString:@".jpeg"] || [str isEqualToString:@".JPEG"]) {
 model.isImage = YES;
 }
 }
 
 //处理500,404等错误
 model = [self handleError:self.error model:model];
 
 
 if ([[HttpDatasource shared] addHttpRequset:model])
 {
 dispatch_main_async_safe(^{
 [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHttp_CocoaDebug" object:nil userInfo:@{@"statusCode":model.statusCode}];
 })
 }
 }
 
 
 
 #pragma mark - NSURLConnectionDelegate
 - (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
 {
 if (!error) {
 [[self client] URLProtocolDidFinishLoading:self];
 } else {
 [[self client] URLProtocol:self didFailWithError:error];
 self.error = error;
 }
 }
 
 - (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
 {
 return YES;
 }
 
 //解決發送IP地址的HTTPS請求 證書驗證
 - (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
 {
 if (!challenge) {
 return;
 }
 
 if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
 //構造一個NSURLCredential發送給發起方
 NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
 [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
 } else {
 //對於其他驗證方法直接進行處理流程
 [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
 }
 }
 
 #pragma GCC diagnostic push
 #pragma clang diagnostic ignored "-Wdeprecated-implementations"
 - (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
 {
 [[self client] URLProtocol:self didReceiveAuthenticationChallenge:challenge];
 }
 - (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
 {
 [[self client] URLProtocol:self didCancelAuthenticationChallenge:challenge];
 }
 - (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
 {
 if ([[protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust]) {
 return YES;
 }
 return NO;
 }
 #pragma GCC diagnostic pop
 
 
 
 #pragma mark - NSURLConnectionDataDelegate
 - (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
 {
 NSURLCacheStoragePolicy cacheStoragePolicy = NSURLCacheStorageNotAllowed;
 if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
 cacheStoragePolicy = CacheStoragePolicyForRequestAndResponse(connection.originalRequest, (NSHTTPURLResponse *) response);
 }
 
 [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:cacheStoragePolicy];
 self.response = response;
 }
 
 - (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
 {
 [[self client] URLProtocol:self didLoadData:data];
 [self.data appendData:data];
 }
 
 - (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
 {
 //    [[self client] URLProtocol:self cachedResponseIsValid:cachedResponse];
 return cachedResponse;
 }
 
 - (void)connectionDidFinishLoading:(NSURLConnection *)connection
 {
 [[self client] URLProtocolDidFinishLoading:self];
 }
 
 - (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
 {
 //重定向 状态码 >=300 && < 400
 if (response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
 NSInteger status = httpResponse.statusCode;
 if (status >= 300 && status < 400) {
 [self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
 //记得设置成nil，要不然正常请求会请求两次
 request = nil;
 }
 }
 return request;
 }
 
 //- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
 //{
 //
 //}
 
 //- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request
 //{
 //
 //}
 
 #pragma mark - helper
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
 //            case 200:
 //                model.errorDescription = @"Success :\nThe request has succeeded.";
 //                model.errorLocalizedDescription = @"OK";
 //                break;
 //            case 201:
 //                model.errorDescription = @"Success :\nThe request has been fulfilled and has resulted in one or more new resources being created.";
 //                model.errorLocalizedDescription = @"Created";
 //                break;
 //            case 202:
 //                model.errorDescription = @"Success :\nThe request has been accepted for processing, but the processing has not been completed. The request might or might not eventually be acted upon, as it might be disallowed when processing actually takes place.";
 //                model.errorLocalizedDescription = @"Accepted";
 //                break;
 //            case 203:
 //                model.errorDescription = @"Success :\nThe request was successful but the enclosed payload has been modified from that of the origin server's 200 OK response by a transforming proxy1.";
 //                model.errorLocalizedDescription = @"Non-authoritative Information";
 //                break;
 //            case 204:
 //                model.errorDescription = @"Success :\nThe server has successfully fulfilled the request and that there is no additional content to send in the response payload body.";
 //                model.errorLocalizedDescription = @"No Content";
 //                break;
 //            case 205:
 //                model.errorDescription = @"Success :\nThe server has fulfilled the request and desires that the user agent reset the \"document view\", which caused the request to be sent, to its original state as received from the origin server.";
 //                model.errorLocalizedDescription = @"Reset Content";
 //                break;
 //            case 206:
 //                model.errorDescription = @"Success :\nThe server is successfully fulfilling a range request for the target resource by transferring one or more parts of the selected representation that correspond to the satisfiable ranges found in the request's Range header field1.";
 //                model.errorLocalizedDescription = @"Partial Content";
 //                break;
 //            case 207:
 //                model.errorDescription = @"Success :\nA Multi-Status response conveys information about multiple resources in situations where multiple status codes might be appropriate.";
 //                model.errorLocalizedDescription = @"Multi-Status";
 //                break;
 //            case 208:
 //                model.errorDescription = @"Success :\nUsed inside a DAV: propstat response element to avoid enumerating the internal members of multiple bindings to the same collection repeatedly.";
 //                model.errorLocalizedDescription = @"Already Reported";
 //                break;
 //            case 226:
 //                model.errorDescription = @"Success :\nThe server has fulfilled a GET request for the resource, and the response is a representation of the result of one or more instance-manipulations applied to the current instance.";
 //                model.errorLocalizedDescription = @"IM Used";
 //                break;
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
 

 
 */





