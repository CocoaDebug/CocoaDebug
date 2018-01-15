//
//  JxbUrlSessionHook_NSURLSessionAsynchronousConvenience.m
//  JxbHttpProtocol
//
//  Created by Peter on 16/8/18.
//  Copyright © 2016年 Peter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JxbUrlSessionHook_NSURLSessionAsynchronousConvenience.h"
#import <objc/runtime.h>
#import "JxbHttpDatasource.h"
#import "NSURLRequest+Identify.h"

@interface JxbUrlSessionHook_NSURLSessionAsynchronousConvenience()

@end

@implementation JxbUrlSessionHook_NSURLSessionAsynchronousConvenience

#pragma mark - 加载hook
+ (void)load {
    Class cls = NSClassFromString(@"NSURLSession");
    [self swizzling_dataTaskWithURL:cls];
    [self swizzling_dataTaskWithRequest:cls];
    [self swizzling_uploadTaskFromFileWithRequest:cls];
    [self swizzling_uploadTaskFromDataWithRequest:cls];
    [self swizzling_downloadTaskWithRequest:cls];
    [self swizzling_downloadTaskWithURL:cls];
    [self swizzling_downloadTaskWithResumeData:cls];
}

#pragma mark - hook处理
+ (void)swizzling_dataTaskWithURL:(Class)cls {
    SEL selector = @selector(dataTaskWithURL:completionHandler:);
    SEL swizzledSelector = @selector(dataTaskWithURL_swizzling:completionHandler:);
    [self replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls];
}

+ (void)swizzling_dataTaskWithRequest:(Class)cls {
    SEL selector = @selector(dataTaskWithRequest:completionHandler:);
    SEL swizzledSelector = @selector(dataTaskWithRequest_swizzling:completionHandler:);
    [self replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls];
}

+ (void)swizzling_uploadTaskFromFileWithRequest:(Class)cls {
    SEL selector = @selector(uploadTaskWithRequest:fromFile:completionHandler:);
    SEL swizzledSelector = @selector(uploadTaskWithRequest_swizzling:fromFile:completionHandler:);
    [self replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls];
}

+ (void)swizzling_uploadTaskFromDataWithRequest:(Class)cls {
    SEL selector = @selector(uploadTaskWithRequest:fromData:completionHandler:);
    SEL swizzledSelector = @selector(uploadTaskWithRequest_swizzling:fromData:completionHandler:);
    [self replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls];
}

+ (void)swizzling_downloadTaskWithRequest:(Class)cls {
    SEL selector = @selector(downloadTaskWithRequest:completionHandler:);
    SEL swizzledSelector = @selector(downloadTaskWithRequest_swizzling:completionHandler:);
    [self replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls];
}

+ (void)swizzling_downloadTaskWithURL:(Class)cls {
    SEL selector = @selector(downloadTaskWithURL:completionHandler:);
    SEL swizzledSelector = @selector(downloadTaskWithURL_swizzling:completionHandler:);
    [self replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls];
}

+ (void)swizzling_downloadTaskWithResumeData:(Class)cls {
    SEL selector = @selector(downloadTaskWithResumeData:completionHandler:);
    SEL swizzledSelector = @selector(downloadTaskWithResumeData_swizzling:completionHandler:);
    [self replaceImplementationOfSelector:selector withSelector:swizzledSelector forClass:cls];
}

#pragma mark - hook替换函数
- (NSURLSessionDataTask *)dataTaskWithURL_swizzling:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
     
    return [self dataTaskWithURL_swizzling:url completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)dataTaskWithRequest_swizzling:(NSURLRequest *)request completionHandler:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler {
    
    NSURLSessionDataTask *task = [self dataTaskWithRequest_swizzling:request completionHandler:completionHandler];
    NSURLRequest *req = task.originalRequest;
    
    
    req.requestId = [[NSUUID UUID] UUIDString];
    req.startTime = @([[NSDate date] timeIntervalSince1970]);
    
     
    
    return task;
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest_swizzling:(NSURLRequest *)request fromFile:(NSURL *)fileURL completionHandler:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler {
     
    return [self uploadTaskWithRequest_swizzling:request fromFile:fileURL completionHandler:completionHandler];
}

- (NSURLSessionUploadTask *)uploadTaskWithRequest_swizzling:(NSURLRequest *)request fromData:(nullable NSData *)bodyData completionHandler:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler {
     
    return [self uploadTaskWithRequest_swizzling:request fromData:bodyData completionHandler:completionHandler];
}

- (NSURLSessionDownloadTask *)downloadTaskWithRequest_swizzling:(NSURLRequest *)request completionHandler:(void (^)(NSURL * location, NSURLResponse * response, NSError * error))completionHandler {
     
    return [self downloadTaskWithRequest_swizzling:request completionHandler:completionHandler];
}

- (NSURLSessionDownloadTask *)downloadTaskWithURL_swizzling:(NSURL *)url completionHandler:(void (^)(NSURL * location, NSURLResponse * response, NSError * error))completionHandler {
     
    return [self downloadTaskWithURL_swizzling:url completionHandler:completionHandler];
}

- (NSURLSessionDownloadTask *)downloadTaskWithResumeData_swizzling:(NSData *)resumeData completionHandler:(void (^)(NSURL * location, NSURLResponse * response, NSError * error))completionHandler {
     
    return [self downloadTaskWithResumeData_swizzling:resumeData completionHandler:completionHandler];
}

#pragma mark - Hook
+ (void)replaceImplementationOfSelector:(SEL)selector withSelector:(SEL)swizzledSelector forClass:(Class)cls {
    Method oldMethod = class_getInstanceMethod(cls, selector);
    const char * types = method_getTypeEncoding(oldMethod);
    IMP implementation = class_getMethodImplementation([self class], swizzledSelector);
    if (oldMethod) {
        class_addMethod(cls, swizzledSelector, implementation, types);
        Method newMethod = class_getInstanceMethod(cls, swizzledSelector);
        method_exchangeImplementations(oldMethod, newMethod);
    } else {
        class_addMethod(cls, selector, implementation, types);
    }
}
@end
