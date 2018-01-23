//
//  JxbHttpProtocol.m
//  JxbHttpProtocol
//
//  Created by Peter Jin  on 15/11/12.
//  Copyright (c) 2015年 Mail:i@Jxb.name. All rights reserved.
//

#import "JxbHttpProtocol.h"
#import "JxbDebugTool.h"
#import "JxbHttpDatasource.h"
#import "NSData+DebugMan.h"
#import "MethodSwizzling.h"

#define myProtocolKey   @"JxbHttpProtocol"

typedef NSURLSessionConfiguration*(*SessionConfigConstructor)(id,SEL);
static SessionConfigConstructor orig_defaultSessionConfiguration;

static NSURLSessionConfiguration* SWHttp_defaultSessionConfiguration(id self, SEL _cmd)
{
    // call original method
    NSURLSessionConfiguration* config = orig_defaultSessionConfiguration(self,_cmd);
    
    
    
    if (   [config respondsToSelector:@selector(protocolClasses)]
        && [config respondsToSelector:@selector(setProtocolClasses:)]){
        NSMutableArray * urlProtocolClasses = [NSMutableArray arrayWithArray:config.protocolClasses];
        Class protoCls = JxbHttpProtocol.class;
        if (![urlProtocolClasses containsObject:protoCls]){
            [urlProtocolClasses insertObject:protoCls atIndex:0];
        }
        
        config.protocolClasses = urlProtocolClasses;
    }
    
    
    
    return config;
}

@interface JxbHttpProtocol()<NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) NSTimeInterval  startTime;
@end

@implementation JxbHttpProtocol



#pragma mark - protocol
+ (void)load {//liman
    orig_defaultSessionConfiguration = (SessionConfigConstructor)ReplaceMethod(
                                                                               @selector(defaultSessionConfiguration),
                                                                               (IMP)SWHttp_defaultSessionConfiguration,
                                                                               [NSURLSessionConfiguration class],
                                                                               YES);
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    
    if ([NSURLProtocol propertyForKey:myProtocolKey inRequest:request] ) {
        return NO;
    }
    
    if ([[JxbDebugTool shareInstance] onlyURLs].count > 0) {
        NSString* url = [request.URL.absoluteString lowercaseString];
        for (NSString* _url in [JxbDebugTool shareInstance].onlyURLs) {
            if ([url rangeOfString:[_url lowercaseString]].location != NSNotFound)
                return YES;
        }
        return NO;
    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:myProtocolKey inRequest:mutableReqeust];
    return [mutableReqeust copy];
}

- (void)startLoading {
    self.data = [NSMutableData data];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.connection = [[NSURLConnection alloc] initWithRequest:[[self class] canonicalRequestForRequest:self.request] delegate:self startImmediately:YES];
#pragma clang diagnostic pop
    self.startTime = [[NSDate date] timeIntervalSince1970];
}

- (void)stopLoading {
    [self.connection cancel];
    
    JxbHttpModel* model = [[JxbHttpModel alloc] init];
    model.url = self.request.URL;
    model.method = self.request.HTTPMethod;
    model.mineType = self.response.MIMEType;
    if (self.request.HTTPBody) {
        NSData* data = self.request.HTTPBody;
        if ([[JxbDebugTool shareInstance] isHttpRequestEncrypt]) {
            if ([[JxbDebugTool shareInstance] delegate] && [[JxbDebugTool shareInstance].delegate respondsToSelector:@selector(decryptJson:)]) {
                data = [[JxbDebugTool shareInstance].delegate decryptJson:self.request.HTTPBody];
            }
        }
        model.requestData = data;
    }
    if (self.request.HTTPBodyStream) {//liman
        NSData* data = [NSData dataWithInputStream:self.request.HTTPBodyStream];
        model.requestData = data;
    }
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)self.response;
    model.statusCode = [NSString stringWithFormat:@"%d",(int)httpResponse.statusCode];
    model.responseData = self.data;
    model.isImage = [self.response.MIMEType rangeOfString:@"image"].location != NSNotFound;
    model.totalDuration = [NSString stringWithFormat:@"%f (s)",[[NSDate date] timeIntervalSince1970] - self.startTime];
    model.startTime = [NSString stringWithFormat:@"%f",self.startTime];
    
    
    model.errorDescription = self.error.description;
    model.errorLocalizedDescription = self.error.localizedDescription;
    model.headerFields = self.request.allHTTPHeaderFields;
    
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
    
    
    
    if ([[JxbHttpDatasource shareInstance] addHttpRequset:model])
    {
        GCD_DELAY_AFTER(0.1, ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHttp_DebugMan" object:nil userInfo:@{@"statusCode":model.statusCode}];
        });
    }
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[self client] URLProtocol:self didFailWithError:error];
    self.error = error;
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    self.response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [[self client] URLProtocol:self didLoadData:data];
    [self.data appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[self client] URLProtocolDidFinishLoading:self];
}
@end

