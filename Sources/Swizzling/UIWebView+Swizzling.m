//
//  UIWebView+Swizzling.m
//  Example_Objc
//
//  Created by man on 2019/1/9.
//  Copyright © 2019年 liman. All rights reserved.
//

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}



#import <JavaScriptCore/JavaScriptCore.h>
#import <objc/runtime.h>
#import "ObjcLog.h"

@implementation UIWebView (Swizzling)


#pragma mark - life
+ (void)load
{
    dispatch_main_async_safe(^{
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            Class theClass = [self class];
            SEL original_sel = @selector(webView:shouldStartLoadWithRequest:navigationType:);
            SEL replaced_sel = @selector(replaced_webView:shouldStartLoadWithRequest:navigationType:);
            Method original_method = class_getInstanceMethod(theClass, original_sel);
            Method replaced_method = class_getInstanceMethod(theClass, replaced_sel);
            
            if (!class_addMethod(theClass, original_sel, method_getImplementation(replaced_method), method_getTypeEncoding(replaced_method))) {
                method_exchangeImplementations(original_method, replaced_method);
            }
        });
    })
}



#pragma mark - replaced method
- (BOOL)replaced_webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"console"][@"log"] = ^(JSValue *message) {
        [ObjcLog logWithFile:"" function:"log" line:0 color:[UIColor whiteColor] unicodeToChinese:NO message:message];
    };
    context[@"console"][@"error"] = ^(JSValue *message) {
        [ObjcLog logWithFile:"" function:"error" line:0 color:[UIColor whiteColor] unicodeToChinese:NO message:message];
    };
    context[@"console"][@"warn"] = ^(JSValue *message) {
        [ObjcLog logWithFile:"" function:"warn" line:0 color:[UIColor whiteColor] unicodeToChinese:NO message:message];
    };
    context[@"console"][@"debug"] = ^(JSValue *message) {
        [ObjcLog logWithFile:"" function:"debug" line:0 color:[UIColor whiteColor] unicodeToChinese:NO message:message];
    };
    
    
    return [self replaced_webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}

@end
