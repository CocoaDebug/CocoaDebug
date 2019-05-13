//
//  WKWebView+Swizzling.m
//  1233213
//
//  Created by man on 2019/1/8.
//  Copyright © 2019年 man. All rights reserved.
//

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}



#import <WebKit/WebKit.h>
#import <objc/runtime.h>
#import "ObjcLog.h"

@interface WKWebView ()<WKScriptMessageHandler>

@end

@implementation WKWebView (Swizzling)

#pragma mark - life
+ (void)load
{
    dispatch_main_async_safe(^{
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            Class theClass = [self class];
            SEL original_sel = @selector(initWithFrame:configuration:);
            SEL replaced_sel = @selector(replaced_initWithFrame:configuration:);
            Method original_method = class_getInstanceMethod(theClass, original_sel);
            Method replaced_method = class_getInstanceMethod(theClass, replaced_sel);
            
            if (!class_addMethod(theClass, original_sel, method_getImplementation(replaced_method), method_getTypeEncoding(replaced_method))) {
                method_exchangeImplementations(original_method, replaced_method);
            }
        });
    })
}

#pragma mark - replaced method
- (instancetype)replaced_initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disableHTMLConsoleMonitoring_CocoaDebug"])
    {
        [configuration.userContentController removeAllUserScripts];
        
        [self log:configuration];
        [self error:configuration];
        [self warn:configuration];
        [self debug:configuration];
        [self info:configuration];
    }
    
    return [self replaced_initWithFrame:frame configuration:configuration];
}

#pragma mark - private
- (void)log:(WKWebViewConfiguration *)configuration
{
    [configuration.userContentController removeScriptMessageHandlerForName:@"log"];
    [configuration.userContentController addScriptMessageHandler:self name:@"log"];
    //rewrite the method of console.log
    NSString *jsCode = @"console.log = (function(oriLogFunc){\
    return function(str)\
    {\
    window.webkit.messageHandlers.log.postMessage(str);\
    oriLogFunc.call(console,str);\
    }\
    })(console.log);";
    //injected the method when H5 starts to create the DOM tree
    [configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
}

- (void)error:(WKWebViewConfiguration *)configuration
{
    [configuration.userContentController removeScriptMessageHandlerForName:@"error"];
    [configuration.userContentController addScriptMessageHandler:self name:@"error"];
    //rewrite the method of console.error
    NSString *jsCode = @"console.error = (function(oriLogFunc){\
    return function(str)\
    {\
    window.webkit.messageHandlers.error.postMessage(str);\
    oriLogFunc.call(console,str);\
    }\
    })(console.error);";
    //injected the method when H5 starts to create the DOM tree
    [configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
}

- (void)warn:(WKWebViewConfiguration *)configuration
{
    [configuration.userContentController removeScriptMessageHandlerForName:@"warn"];
    [configuration.userContentController addScriptMessageHandler:self name:@"warn"];
    //rewrite the method of console.warn
    NSString *jsCode = @"console.warn = (function(oriLogFunc){\
    return function(str)\
    {\
    window.webkit.messageHandlers.warn.postMessage(str);\
    oriLogFunc.call(console,str);\
    }\
    })(console.warn);";
    //injected the method when H5 starts to create the DOM tree
    [configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
}

- (void)debug:(WKWebViewConfiguration *)configuration
{
    [configuration.userContentController removeScriptMessageHandlerForName:@"debug"];
    [configuration.userContentController addScriptMessageHandler:self name:@"debug"];
    //rewrite the method of console.debug
    NSString *jsCode = @"console.debug = (function(oriLogFunc){\
    return function(str)\
    {\
    window.webkit.messageHandlers.debug.postMessage(str);\
    oriLogFunc.call(console,str);\
    }\
    })(console.debug);";
    //injected the method when H5 starts to create the DOM tree
    [configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
}

- (void)info:(WKWebViewConfiguration *)configuration
{
    [configuration.userContentController removeScriptMessageHandlerForName:@"info"];
    [configuration.userContentController addScriptMessageHandler:self name:@"info"];
    //rewrite the method of console.info
    NSString *jsCode = @"console.info = (function(oriLogFunc){\
    return function(str)\
    {\
    window.webkit.messageHandlers.info.postMessage(str);\
    oriLogFunc.call(console,str);\
    }\
    })(console.info);";
    //injected the method when H5 starts to create the DOM tree
    [configuration.userContentController addUserScript:[[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
}



#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [ObjcLog logWithFile:"[WKWebView]" function:[message.name UTF8String] line:0 color:[UIColor whiteColor] unicodeToChinese:NO message:message.body];
}

#pragma clang diagnostic pop

@end
