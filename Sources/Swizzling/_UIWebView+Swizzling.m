//
//  UIWebView+Swizzling.m
//  Example_Objc
//
//  Created by man on 2019/1/9.
//  Copyright © 2019年 liman. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import <objc/runtime.h>
#import "_ObjcLog.h"
#import "_NetworkHelper.h"

@implementation UIWebView (_Swizzling)

#pragma mark - life
+ (void)load {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disableHTMLConsoleMonitoring_CocoaDebug"]) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            SEL original_sel = @selector(initWithFrame:);
            SEL replaced_sel = @selector(replaced_initWithFrame:);
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
    //UIWebView
    [_ObjcLog logWithFile:"[UIWebView]" function:"" line:0 color:[UIColor redColor] unicodeToChinese:NO message:@"-------------------------------- dealloc --------------------------------"];
}

- (instancetype)replaced_initWithFrame:(CGRect)frame {
    //UIWebView
    [_ObjcLog logWithFile:"[UIWebView]" function:"" line:0 color:[_NetworkHelper shared].mainColor unicodeToChinese:NO message:@"----------------------------------- init -----------------------------------"];
    
    //
    dispatch_async(dispatch_get_main_queue(), ^{
        
        JSContext *context = [self valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        context[@"console"][@"log"] = ^(JSValue *message) {
            [_ObjcLog logWithFile:"[UIWebView]" function:"log" line:0 color:[UIColor whiteColor] unicodeToChinese:NO message:message];
        };
        context[@"console"][@"error"] = ^(JSValue *message) {
            [_ObjcLog logWithFile:"[UIWebView]" function:"error" line:0 color:[UIColor whiteColor] unicodeToChinese:NO message:message];
        };
        context[@"console"][@"warn"] = ^(JSValue *message) {
            [_ObjcLog logWithFile:"[UIWebView]" function:"warn" line:0 color:[UIColor whiteColor] unicodeToChinese:NO message:message];
        };
        context[@"console"][@"debug"] = ^(JSValue *message) {
            [_ObjcLog logWithFile:"[UIWebView]" function:"debug" line:0 color:[UIColor whiteColor] unicodeToChinese:NO message:message];
        };
        context[@"console"][@"info"] = ^(JSValue *message) {
            [_ObjcLog logWithFile:"[UIWebView]" function:"info" line:0 color:[UIColor whiteColor] unicodeToChinese:NO message:message];
        };
    });

    return [self replaced_initWithFrame:frame];
}

@end
