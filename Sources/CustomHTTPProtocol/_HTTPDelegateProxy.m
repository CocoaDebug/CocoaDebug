//
//  _HTTPDelegateProxy.m
//  CocoaDebug
//
//  Created by zhaoguoqing on 2020/9/2.
//

#import "_HTTPDelegateProxy.h"
#import "_Swizzling.h"
#import "_NetworkHelper.h"
#import "_HttpDatasource.h"
#import "NSObject+CocoaDebug.h"
#import <objc/runtime.h>


static void *kTaskStartDateKey;
typedef void (^DataTaskCompletionHander)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);
typedef void (^DownloadTaskCompletionHander)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error);
typedef NSURLSession *(SessionConstructor)(id, SEL, NSURLSessionConfiguration *, id, NSOperationQueue *);
typedef NSURLSession *(^SessionConstructorBlock)(id, NSURLSessionConfiguration *, id, NSOperationQueue *);
typedef id (DataTaskConstructor)(id, SEL, id, DataTaskCompletionHander);
typedef id (UploadTaskConstructor)(id, SEL, id, id, DataTaskCompletionHander);
typedef id (DownloadTaskConstructor)(id, SEL, id, DownloadTaskCompletionHander);

typedef NSURLConnection *(URLConnectionConstructor)(id, SEL, NSURLRequest *, id);
typedef NSURLConnection *(^URLConnectionConstructorBlock)(id, NSURLRequest *, id);
typedef NSURLConnection *(URLConnectionConstructor2)(id, SEL, NSURLRequest *, id, BOOL);
typedef NSURLConnection *(^URLConnectionConstructorBlock2)(id, NSURLRequest *, id, BOOL);

typedef NSData *(URLConnectionSyncConstructor)(id, SEL, NSURLRequest *, NSURLResponse **, NSError **);
typedef NSData *(^URLConnectionSyncConstructorBlock)(id, NSURLRequest *, NSURLResponse **, NSError **);
typedef void (^URLConnectionAsyncConstructorCompletionBlock)(NSURLResponse *, NSData *, NSError *);
typedef void (URLConnectionAsyncConstructor)(id, SEL, NSURLRequest *, NSOperationQueue *, URLConnectionAsyncConstructorCompletionBlock);
typedef void (^URLConnectionAsyncConstructorBlock)(id, NSURLRequest *, NSOperationQueue *, URLConnectionAsyncConstructorCompletionBlock);
typedef void(URLConnectionStart)(id, SEL);


@interface NSURLSessionTask (CacheData)
@property(nonatomic, strong) NSMutableData *cachedata;
@end

@interface _HTTPDelegateProxy ()
@property(nonatomic, weak) id originalDelegate;

- (instancetype)initWithOriginalDelegate: (id)originalDelegate;

+ (void)recordHTTPRequest:(NSURLRequest *)request response: (NSURLResponse *)response receiveData:(NSData *)receiveData startDate:(NSDate *)startDate error:(NSError *)error;
+ (_HttpModel *)handleError:(NSError *)error model:(_HttpModel *)model;
@end

@interface _URLSessionDelegateProxy ()
<NSURLSessionDelegate,
NSURLSessionTaskDelegate,
NSURLSessionDataDelegate,
NSURLSessionStreamDelegate,
NSURLSessionDownloadDelegate,
NSURLSessionWebSocketDelegate>

+ (void)prepareSwizzleResumeMethod;
+ (void)swizzleResumeMethodForClass:(Class)theClass;
+ (void)swizzleSessionConstructor;
+ (void)swizzleSessionGeneratorDataTaskWithBlocks;
+ (void)swizzleDataTaskWithSel:(SEL)sel;
@end

@interface _URLConnectionDelegateProxy ()
<NSURLConnectionDelegate,
NSURLConnectionDataDelegate,
NSURLConnectionDownloadDelegate>
@property(nonatomic, strong) NSMutableData *cachedata;
@property(nonnull, strong) NSURLResponse *response;

+ (void)swizzleStart;
+ (void)swizzleURLConnectionConstructor;
@end


@implementation _URLSessionDelegateProxy

+ (void)load {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disableNetworkMonitoring_CocoaDebug"]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self prepareSwizzleResumeMethod];
            [self swizzleSessionConstructor];
            [self swizzleSessionGeneratorDataTaskWithBlocks];
        });
    }
}

+ (void)prepareSwizzleResumeMethod {
    /// Copy from AFNetWoring
    /**
     WARNING: Trouble Ahead
     https://github.com/AFNetworking/AFNetworking/pull/2702
     */
    if (NSClassFromString(@"NSURLSessionTask")) {
        /**
         iOS 7 and iOS 8 differ in NSURLSessionTask implementation, which makes the next bit of code a bit tricky.
         Many Unit Tests have been built to validate as much of this behavior has possible.
         Here is what we know:
         - NSURLSessionTasks are implemented with class clusters, meaning the class you request from the API isn't actually the type of class you will get back.
         - Simply referencing `[NSURLSessionTask class]` will not work. You need to ask an `NSURLSession` to actually create an object, and grab the class from there.
         - On iOS 7, `localDataTask` is a `__NSCFLocalDataTask`, which inherits from `__NSCFLocalSessionTask`, which inherits from `__NSCFURLSessionTask`.
         - On iOS 8, `localDataTask` is a `__NSCFLocalDataTask`, which inherits from `__NSCFLocalSessionTask`, which inherits from `NSURLSessionTask`.
         - On iOS 7, `__NSCFLocalSessionTask` and `__NSCFURLSessionTask` are the only two classes that have their own implementations of `resume` and `suspend`, and `__NSCFLocalSessionTask` DOES NOT CALL SUPER. This means both classes need to be swizzled.
         - On iOS 8, `NSURLSessionTask` is the only class that implements `resume` and `suspend`. This means this is the only class that needs to be swizzled.
         - Because `NSURLSessionTask` is not involved in the class hierarchy for every version of iOS, its easier to add the swizzled methods to a dummy class and manage them there.
         
         Some Assumptions:
         - No implementations of `resume` or `suspend` call super. If this were to change in a future version of iOS, we'd need to handle it.
         - No background task classes override `resume` or `suspend`
         
         The current solution:
         1) Grab an instance of `__NSCFLocalDataTask` by asking an instance of `NSURLSession` for a data task.
         2) Grab a pointer to the original implementation of `af_resume`
         3) Check to see if the current class has an implementation of resume. If so, continue to step 4.
         4) Grab the super class of the current class.
         5) Grab a pointer for the current class to the current implementation of `resume`.
         6) Grab a pointer for the super class to the current implementation of `resume`.
         7) If the current class implementation of `resume` is not equal to the super class implementation of `resume` AND the current implementation of `resume` is not equal to the original implementation of `af_resume`, THEN swizzle the methods
         8) Set the current class to the super class, and repeat steps 3-8
         */
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wnonnull"
        NSURLSessionDataTask *localDataTask = [session dataTaskWithURL:nil];
#pragma clang diagnostic pop
        IMP originalAFResumeIMP = method_getImplementation(class_getInstanceMethod([self class], @selector(cocoaDebug_resume)));
        Class currentClass = [localDataTask class];
        
        while (class_getInstanceMethod(currentClass, @selector(resume))) {
            Class superClass = [currentClass superclass];
            IMP classResumeIMP = method_getImplementation(class_getInstanceMethod(currentClass, @selector(resume)));
            IMP superclassResumeIMP = method_getImplementation(class_getInstanceMethod(superClass, @selector(resume)));
            if (classResumeIMP != superclassResumeIMP &&
                originalAFResumeIMP != classResumeIMP) {
                [self swizzleResumeMethodForClass:currentClass];
            }
            currentClass = [currentClass superclass];
        }
        
        [localDataTask cancel];
        [session finishTasksAndInvalidate];
    }
}

/// Copy from AFNetWoring
+ (void)swizzleResumeMethodForClass:(Class)theClass {
    Method afResumeMethod = class_getInstanceMethod(self, @selector(cocoaDebug_resume));
    if (class_addMethod(theClass, @selector(cocoaDebug_resume),  method_getImplementation(afResumeMethod),  method_getTypeEncoding(afResumeMethod))) {
        Method originalMethod = class_getInstanceMethod(theClass, @selector(resume));
        Method swizzledMethod = class_getInstanceMethod(theClass, @selector(cocoaDebug_resume));
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

/// Copy from AFNetWoring
/// Record start date
- (void)cocoaDebug_resume {
    [self cocoaDebug_resume];
    objc_setAssociatedObject(self, &kTaskStartDateKey, [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


/// Delegate Proxy
+ (void)swizzleSessionConstructor {
    SEL sel = @selector(sessionWithConfiguration:delegate:delegateQueue:);
    __block SessionConstructor *originalSessionConstructor;
    SessionConstructorBlock replacedSessionConstructor = ^(id __self, NSURLSessionConfiguration *configuration, id delegate, NSOperationQueue *queue) {
        if (![_NetworkHelper shared].isNetworkEnable) {
            return originalSessionConstructor(__self, sel, configuration, delegate, queue);
        }
        id privateDelegate = [[self alloc] initWithOriginalDelegate:delegate];
        return originalSessionConstructor(__self, sel, configuration, privateDelegate, queue);
    };
    originalSessionConstructor = (SessionConstructor *)replaceMethod(sel, imp_implementationWithBlock(replacedSessionConstructor), [NSURLSession class], YES);
}

/*
 * data task convenience methods.  These methods create tasks that
 * bypass the normal delegate calls for response and data delivery,
 * and provide a simple cancelable asynchronous interface to receiving
 * data.  Errors will be returned in the NSURLErrorDomain,
 * see <Foundation/NSURLError.h>.  The delegate, if any, will still be
 * called for authentication challenges.
 */
+ (void)swizzleSessionGeneratorDataTaskWithBlocks {
    [self swizzleDataTaskWithSel: @selector(dataTaskWithRequest:completionHandler:)];
    [self swizzleDataTaskWithSel:@selector(dataTaskWithURL:completionHandler:)];
    [self swizzleUploadTaskWithSel:@selector(uploadTaskWithRequest:fromData:completionHandler:)];
    [self swizzleUploadTaskWithSel:@selector(uploadTaskWithRequest:fromFile:completionHandler:)];
    [self swizzleDownloadTaskWithSel:@selector(downloadTaskWithURL:completionHandler:)];
    [self swizzleDownloadTaskWithSel:@selector(downloadTaskWithRequest:completionHandler:)];
    [self swizzleDownloadTaskWithSel:@selector(downloadTaskWithResumeData:completionHandler:)];
}

+ (void)swizzleDataTaskWithSel:(SEL)sel {
    __block DataTaskConstructor *originalMethod;
    id (^replacedMethod)(id, id, DataTaskCompletionHander) = ^(id __self, id unuse, DataTaskCompletionHander completionHandler) {
        __block NSURLSessionTask *returnTask;
        DataTaskCompletionHander proxyCompletionHandler =  ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
            NSDate *startDate = objc_getAssociatedObject(returnTask, &kTaskStartDateKey);
            [self recordHTTPRequest:returnTask.currentRequest response:returnTask.response receiveData:data startDate:startDate error:error];
            if (completionHandler) {// fix crash
                completionHandler(data, response, error);
            }
        };
        returnTask = originalMethod(__self, sel, unuse, proxyCompletionHandler);
        return returnTask;
    };
    originalMethod = (DataTaskConstructor *)replaceMethod(sel, imp_implementationWithBlock(replacedMethod), [NSURLSession class], NO);
}

+ (void)swizzleUploadTaskWithSel:(SEL)sel {
    __block UploadTaskConstructor *originalMethod;
    id (^replacedMethod)(id, id, id, DataTaskCompletionHander) = ^(id __self, id unuse1, id unuse2, DataTaskCompletionHander completionHandler) {
        __block NSURLSessionTask *returnTask;
        DataTaskCompletionHander proxyCompletionHandler =  ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
            NSDate *startDate = objc_getAssociatedObject(returnTask, &kTaskStartDateKey);
            [self recordHTTPRequest:returnTask.currentRequest response:returnTask.response receiveData:data startDate:startDate error:error];
            if (completionHandler) {// fix crash
                completionHandler(data, response, error);
            }
        };
        returnTask = originalMethod(__self, sel, unuse1, unuse2, proxyCompletionHandler);
        return returnTask;
    };
    originalMethod = (UploadTaskConstructor *)replaceMethod(sel, imp_implementationWithBlock(replacedMethod), [NSURLSession class], NO);
}

+ (void)swizzleDownloadTaskWithSel:(SEL)sel {
    __block DownloadTaskConstructor * originalMethod;
    id (^replacedMethod)(id, id, DownloadTaskCompletionHander) = ^(id __self, id unuse, DownloadTaskCompletionHander completionHandler) {
        __block NSURLSessionTask *returnTask;
        DownloadTaskCompletionHander proxyCompletionHandler =  ^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error){
            NSDate *startDate = objc_getAssociatedObject(returnTask, &kTaskStartDateKey);
            NSMutableData *receiveData = [NSMutableData data];
            if (location) {
                [receiveData appendData:[NSData dataWithContentsOfURL:location]];
            }
            [self recordHTTPRequest:returnTask.currentRequest response:returnTask.response receiveData:[NSData data] startDate:startDate error:error];
            if (completionHandler) {// fix crash
                completionHandler(location, response, error);
            }
        };
        returnTask = originalMethod(__self, sel, unuse, proxyCompletionHandler);
        return returnTask;
    };
    originalMethod = (DownloadTaskConstructor *)replaceMethod(sel, imp_implementationWithBlock(replacedMethod), [NSURLSession class], NO);
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (self.originalDelegate && [self.originalDelegate conformsToProtocol:@protocol(NSURLSessionDataDelegate)] &&[self.originalDelegate respondsToSelector:@selector(URLSession:dataTask:didReceiveData:)]) {
        [(id<NSURLSessionDataDelegate>)self.originalDelegate URLSession: session dataTask: dataTask didReceiveData: data];
    }
    [dataTask.cachedata appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if (self.originalDelegate && [self.originalDelegate conformsToProtocol:@protocol(NSURLSessionTaskDelegate)] &&[self.originalDelegate respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
        [(id<NSURLSessionTaskDelegate>)self.originalDelegate URLSession:session task:task didCompleteWithError:error];
    }
    NSDate *startDate = objc_getAssociatedObject(task, &kTaskStartDateKey);
    [self.class recordHTTPRequest:task.currentRequest response:task.response receiveData:task.cachedata startDate:startDate error:error];
}

// implement this can clear warning
- (void)URLSession:(nonnull NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location {
    if (self.originalDelegate && [self.originalDelegate conformsToProtocol:@protocol(NSURLSessionDownloadDelegate)] &&[self.originalDelegate respondsToSelector:@selector(URLSession:downloadTask:didFinishDownloadingToURL:)]) {
        [(id<NSURLSessionDownloadDelegate>)self.originalDelegate URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
    }
    if (location != nil && downloadTask.cachedata.length == 0) {
        [downloadTask.cachedata appendData:[NSData dataWithContentsOfURL:location]];
    }
}

@end

@implementation _URLConnectionDelegateProxy

- (instancetype)initWithOriginalDelegate:(id)originalDelegate {
    self = [super initWithOriginalDelegate:originalDelegate];
    if (self) {
        _cachedata = [NSMutableData data];
    }
    return self;
}

+ (void)load {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disableNetworkMonitoring_CocoaDebug"]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self swizzleStart];
            // 两个初始化方法都要替换, 相互没有调用
            [self swizzleURLConnectionConstructor];
            [self swizzleURLConnectionConstructor2];
            // 这两个两个构造器不会调用delegate
            [self swizzleURLConnectionSyncConstructor];
            [self swizzleURLConnectionAsyncConstructor];
        });
    }
}

+ (void)swizzleStart {
    SEL sel = @selector(start);
    __block URLConnectionStart *originalURLConnectionStart;
    void (^replacedURLConnectionStart)(id) = ^(id __self) {
        originalURLConnectionStart(__self, sel);
        objc_setAssociatedObject(__self, &kTaskStartDateKey, [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    };
    originalURLConnectionStart = (URLConnectionStart *)replaceMethod(sel, imp_implementationWithBlock(replacedURLConnectionStart), [NSURLConnection class], NO);
}

+ (void)swizzleURLConnectionConstructor {
    SEL sel = @selector(initWithRequest:delegate:);
    __block URLConnectionConstructor *originalURLConnectionConstructor;
    URLConnectionConstructorBlock replacedURLConnectionConstructor = ^(id __self, NSURLRequest *request, id delegate) {
        if (![_NetworkHelper shared].isNetworkEnable) {
            return originalURLConnectionConstructor(__self, sel, request, delegate);
        }
        if ([delegate isKindOfClass:self]) {
            return originalURLConnectionConstructor(__self, sel, request, delegate);
        }
        id privateDelegate = [[self alloc] initWithOriginalDelegate:delegate];
        return originalURLConnectionConstructor(__self, sel, request, privateDelegate);
    };
    originalURLConnectionConstructor = (URLConnectionConstructor *)replaceMethod(sel, imp_implementationWithBlock(replacedURLConnectionConstructor), [NSURLConnection class], NO);
}

+ (void)swizzleURLConnectionConstructor2 {
    SEL sel = @selector(initWithRequest:delegate:startImmediately:);
    __block URLConnectionConstructor2 *originalURLConnectionConstructor;
    URLConnectionConstructorBlock2 replacedURLConnectionConstructor = ^(id __self, NSURLRequest *request, id delegate, BOOL s) {
        if (![_NetworkHelper shared].isNetworkEnable) {
            return originalURLConnectionConstructor(__self, sel, request, delegate, s);
        }
        if ([delegate isKindOfClass:self]) {
            return originalURLConnectionConstructor(__self, sel, request, delegate, s);
        }
        if (s) {
            objc_setAssociatedObject(__self, &kTaskStartDateKey, [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        id privateDelegate = [[self alloc] initWithOriginalDelegate:delegate];
        return originalURLConnectionConstructor(__self, sel, request, privateDelegate, s);
    };
    originalURLConnectionConstructor = (URLConnectionConstructor2 *)replaceMethod(sel, imp_implementationWithBlock(replacedURLConnectionConstructor), [NSURLConnection class], NO);
}

+ (void)swizzleURLConnectionSyncConstructor {
    SEL sel = @selector(sendSynchronousRequest:returningResponse:error:);
    __block URLConnectionSyncConstructor *originalURLConnectionSyncConstructor;
    URLConnectionSyncConstructorBlock replacedURLConnectionSyncConstructor = ^(id __self, NSURLRequest *request, NSURLResponse **response, NSError **error) {
        if (![_NetworkHelper shared].isNetworkEnable) {
            return originalURLConnectionSyncConstructor(__self, sel, request, response, error);
        }
        NSDate *startDate = [NSDate date];
        NSData *originalReturnValue = originalURLConnectionSyncConstructor(__self, sel, request, response, error);
        [self recordHTTPRequest:request response:*response receiveData:originalReturnValue startDate:startDate error:*error];
        return originalReturnValue;
    };
    originalURLConnectionSyncConstructor = (URLConnectionSyncConstructor *)replaceMethod(sel, imp_implementationWithBlock(replacedURLConnectionSyncConstructor), [NSURLConnection class], YES);
}

+ (void)swizzleURLConnectionAsyncConstructor {
    SEL sel = @selector(sendAsynchronousRequest:queue:completionHandler:);
    __block URLConnectionAsyncConstructor *originalURLConnectionAsyncConstructor;
    URLConnectionAsyncConstructorBlock replacedURLConnectionSyncConstructor = ^(id __self, NSURLRequest *request, NSOperationQueue *queue, URLConnectionAsyncConstructorCompletionBlock block) {
        if (![_NetworkHelper shared].isNetworkEnable) {
            originalURLConnectionAsyncConstructor(__self, sel, request, queue, block);
            return;
        }
        __block NSDate *startDate = [NSDate date];
        URLConnectionAsyncConstructorCompletionBlock proxyBlock = ^(NSURLResponse *response, NSData *data, NSError *error) {
            if (block) block(response, data, error);
            [self recordHTTPRequest:request response:response receiveData:data startDate:startDate error:error];
        };
        originalURLConnectionAsyncConstructor(__self, sel, request, queue, proxyBlock);
    };
    originalURLConnectionAsyncConstructor = (URLConnectionAsyncConstructor *)replaceMethod(sel, imp_implementationWithBlock(replacedURLConnectionSyncConstructor), [NSURLConnection class], YES);
}


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (self.originalDelegate && [self.originalDelegate conformsToProtocol:@protocol(NSURLConnectionDelegate)] &&[self.originalDelegate respondsToSelector:@selector(connection:didFailWithError:)]) {
        [(id<NSURLConnectionDelegate>)self.originalDelegate connection:connection didFailWithError:error];
    }
    NSDate *startDate = objc_getAssociatedObject(self, &kTaskStartDateKey);
    [self.class recordHTTPRequest:connection.currentRequest response:nil receiveData:self.cachedata startDate:startDate error:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (self.originalDelegate && [self.originalDelegate conformsToProtocol:@protocol(NSURLConnectionDataDelegate)] &&[self.originalDelegate respondsToSelector:@selector(connection:didReceiveResponse:)]) {
        [(id<NSURLConnectionDataDelegate>)self.originalDelegate connection:connection didReceiveResponse:response];
    }
    self.response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (self.originalDelegate && [self.originalDelegate conformsToProtocol:@protocol(NSURLConnectionDataDelegate)] &&[self.originalDelegate respondsToSelector:@selector(connection:didReceiveData:)]) {
        [(id<NSURLConnectionDataDelegate>)self.originalDelegate connection:connection didReceiveData:data];
    }
    [self.cachedata appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.originalDelegate && [self.originalDelegate conformsToProtocol:@protocol(NSURLConnectionDataDelegate)] &&[self.originalDelegate respondsToSelector:@selector(connectionDidFinishLoading:)]) {
        [(id<NSURLConnectionDataDelegate>)self.originalDelegate connectionDidFinishLoading:connection];
    }
    NSDate *startDate = objc_getAssociatedObject(connection, &kTaskStartDateKey);
    [self.class recordHTTPRequest:connection.currentRequest response:self.response receiveData:self.cachedata startDate:startDate error:nil];
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *) destinationURL {
    if (self.originalDelegate && [self.originalDelegate conformsToProtocol:@protocol(NSURLConnectionDownloadDelegate)] &&[self.originalDelegate respondsToSelector:@selector(connectionDidFinishDownloading:destinationURL:)]) {
        [(id<NSURLConnectionDownloadDelegate>)self.originalDelegate connectionDidFinishDownloading:connection destinationURL:destinationURL];
    }
    NSDate *startDate = objc_getAssociatedObject(connection, &kTaskStartDateKey);
    if (destinationURL != nil && self.cachedata.length == 0) {
        [self.cachedata appendData:[NSData dataWithContentsOfURL:destinationURL]];
    }
    [self.class recordHTTPRequest:connection.currentRequest response:self.response receiveData:self.cachedata startDate:startDate error:nil];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (sel_isEqual(aSelector, @selector(connectionDidFinishDownloading:destinationURL:))) {
        return [self.originalDelegate respondsToSelector:aSelector];
    } else {
        if ([super respondsToSelector:aSelector]) {
            return true;
        } else {
            return [self.originalDelegate respondsToSelector:aSelector];
        }
    }
}

@end


@implementation _HTTPDelegateProxy

- (instancetype)initWithOriginalDelegate: (id)originalDelegate {
    self = [self init];
    if (self) {
        _originalDelegate = originalDelegate;
    }
    return self;
}

+ (void)recordHTTPRequest:(NSURLRequest *)request response: (NSURLResponse *)response receiveData:(NSData *)receiveData startDate:(NSDate *)startDate error:(NSError *)error {
    if (![_NetworkHelper shared].isNetworkEnable) {
        return;
    }
    if (!request.URL) {
        // fix crash
        // _HttpModel url cannot be nil
        return;
    }
    
    _HttpModel* model = [[_HttpModel alloc] init];
    model.url = request.URL;
    model.method = request.HTTPMethod;
    model.mineType = response.MIMEType;
    if (request.HTTPBody) {
        model.requestData = request.HTTPBody;
    }
    if (request.HTTPBodyStream) {//liman
        model.requestData = [NSData dataWithInputStream:request.HTTPBodyStream];
    }
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    model.statusCode = [NSString stringWithFormat:@"%d",(int)httpResponse.statusCode];
    model.responseData = receiveData;
    model.size = [[NSByteCountFormatter new] stringFromByteCount:receiveData.length];
    model.isImage = [httpResponse.MIMEType rangeOfString:@"image"].location != NSNotFound;
    
    //时间
    NSTimeInterval startTimeDouble = startDate.timeIntervalSince1970;
    NSTimeInterval endTimeDouble = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval durationDouble = fabs(endTimeDouble - startTimeDouble);
    
    model.startTime = [NSString stringWithFormat:@"%f", startTimeDouble];
    model.endTime = [NSString stringWithFormat:@"%f", endTimeDouble];
    model.totalDuration = [NSString stringWithFormat:@"%f (s)", durationDouble];
    
    model.errorDescription = error.description;
    model.errorLocalizedDescription = error.localizedDescription;
    model.requestHeaderFields = request.allHTTPHeaderFields;
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        model.responseHeaderFields = ((NSHTTPURLResponse *)response).allHeaderFields;
    }
    
    if (response.MIMEType == nil) {
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
    model = [self handleError:error model:model];
    
    
    if ([[_HttpDatasource shared] addHttpRequset:model])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHttp_CocoaDebug" object:nil userInfo:@{@"statusCode":model.statusCode}];
    }
}

//处理500,404等错误
+ (_HttpModel *)handleError:(NSError *)error model:(_HttpModel *)model {
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

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return true;
    } else {
        return [self.originalDelegate respondsToSelector:aSelector];
    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    id target = [super forwardingTargetForSelector:aSelector];
    if (!target) {
        target = self.originalDelegate;
    }
    return target;
}


@end

@implementation NSURLSessionTask (CacheData)
static void *kSessionTaskCacheDataKey;
- (void)setCachedata:(NSMutableData *)cachedata {
    objc_setAssociatedObject(self, &kSessionTaskCacheDataKey, cachedata, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableData *)cachedata {
    NSMutableData *data = objc_getAssociatedObject(self, &kSessionTaskCacheDataKey);
    if (!data) {
        data = [NSMutableData data];
        objc_setAssociatedObject(self, &kSessionTaskCacheDataKey, data, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return data;
}


@end
