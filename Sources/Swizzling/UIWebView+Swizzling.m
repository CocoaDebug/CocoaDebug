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
            SEL original_sel = @selector(initWithFrame:);
            SEL replaced_sel = @selector(replaced_initWithFrame:);
            Method original_method = class_getInstanceMethod(theClass, original_sel);
            Method replaced_method = class_getInstanceMethod(theClass, replaced_sel);
            
            if (!class_addMethod(theClass, original_sel, method_getImplementation(replaced_method), method_getTypeEncoding(replaced_method))) {
                method_exchangeImplementations(original_method, replaced_method);
            }
        });
    })
}

#pragma mark - replaced method
- (instancetype)replaced_initWithFrame:(CGRect)frame {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disableHTMLConsoleMonitoring_CocoaDebug"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            JSContext *context = [self valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
            context[@"console"][@"log"] = ^(JSValue *message) {
                [ObjcLog logWithFile:"[UIWebView]" function:"log" line:0 color:[UIColor whiteColor] unicodeToChinese:NO message:message];
            };
            context[@"console"][@"error"] = ^(JSValue *message) {
                [ObjcLog logWithFile:"[UIWebView]" function:"error" line:0 color:[UIColor whiteColor] unicodeToChinese:NO message:message];
            };
            context[@"console"][@"warn"] = ^(JSValue *message) {
                [ObjcLog logWithFile:"[UIWebView]" function:"warn" line:0 color:[UIColor whiteColor] unicodeToChinese:NO message:message];
            };
            context[@"console"][@"debug"] = ^(JSValue *message) {
                [ObjcLog logWithFile:"[UIWebView]" function:"debug" line:0 color:[UIColor whiteColor] unicodeToChinese:NO message:message];
            };
            context[@"console"][@"info"] = ^(JSValue *message) {
                [ObjcLog logWithFile:"[UIWebView]" function:"info" line:0 color:[UIColor whiteColor] unicodeToChinese:NO message:message];
            };
        });
    }

    return [self replaced_initWithFrame:frame];
}

@end
