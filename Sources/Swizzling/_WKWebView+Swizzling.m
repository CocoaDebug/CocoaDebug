//
//  WKWebView+Swizzling.m
//  1233213
//
//  Created by man.li on 2019/1/8.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <objc/runtime.h>
#import "_ObjcLog.h"
#import "_NetworkHelper.h"

@interface WKWebView () <WKScriptMessageHandler>

@end

@implementation WKWebView (_Swizzling)

#pragma mark - life
+ (void)load {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"enableWKWebViewMonitoring_CocoaDebug"]) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            SEL original_sel = @selector(initWithFrame:configuration:);
            SEL replaced_sel = @selector(replaced_initWithFrame:configuration:);
            Method original_method = class_getInstanceMethod([self class], original_sel);
            Method replaced_method = class_getInstanceMethod([self class], replaced_sel);
            if (!class_addMethod([self class], original_sel, method_getImplementation(replaced_method), method_getTypeEncoding(replaced_method))) {
                method_exchangeImplementations(original_method, replaced_method);
            }
            
            /*********************************************************************************************************************************/
            
            SEL original_sel2 = NSSelectorFromString(@"dealloc");
            SEL replaced_sel2 = @selector(replaced_dealloc);
            Method original_method2 = class_getInstanceMethod([self class], original_sel2);
            Method replaced_method2 = class_getInstanceMethod([self class], replaced_sel2);
            if (!class_addMethod([self class], original_sel2, method_getImplementation(replaced_method2), method_getTypeEncoding(replaced_method2))) {
                method_exchangeImplementations(original_method2, replaced_method2);
            }
        });
    }
}

#pragma mark - replaced method
- (void)replaced_dealloc {
    //WKWebView
    [_ObjcLog logWithFile:"[WKWebView]" function:"" line:0 color:[UIColor redColor] message:@"-------------------------------- dealloc --------------------------------"];
}

- (instancetype)replaced_initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    //WKWebView
    [_ObjcLog logWithFile:"[WKWebView]" function:"" line:0 color:[_NetworkHelper shared].mainColor message:@"----------------------------------- init -----------------------------------"];
    
    [self log:configuration];
    [self error:configuration];
    [self warn:configuration];
    [self debug:configuration];
    [self info:configuration];
    
    return [self replaced_initWithFrame:frame configuration:configuration];
}

#pragma mark - private
- (void)log:(WKWebViewConfiguration *)configuration {
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

- (void)error:(WKWebViewConfiguration *)configuration {
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

- (void)warn:(WKWebViewConfiguration *)configuration {
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

- (void)debug:(WKWebViewConfiguration *)configuration {
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

- (void)info:(WKWebViewConfiguration *)configuration {
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



#pragma mark - WKScriptMessageHandler
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [_ObjcLog logWithFile:"[WKWebView]" function:[message.name UTF8String] line:0 color:[UIColor whiteColor] message:message.body];
}
#pragma clang diagnostic pop

@end
