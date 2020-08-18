//
//  _NSLogHook.m
//  Example_Swift
//
//  Created by man.li on 7/26/19.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import "_OCLogHelper.h"
#import "fishhook.h"

@interface _NSLogHook : NSObject

@end

@implementation _NSLogHook

static void (*orig_nslog)(NSString *format, ...);


void my_nslog(NSString *format, ...) {
    
    /* 方法1 */
    va_list vl;
    va_start(vl, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:vl];
//    va_end(vl);
    orig_nslog(str);
    
    
    /* 方法2 */
//    va_list va;
//    va_start(va, format);
//    NSLogv(format, va);
//    va_end(va);


    [_OCLogHelper.shared handleLogWithFile:@"" function:@"" line:999999999 message:str color:[UIColor whiteColor] type:CocoaDebugToolTypeNone];

    va_end(vl);
}


+ (void)load {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disableLogMonitoring_CocoaDebug"]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            struct rcd_rebinding nslog_rebinding = {"NSLog",my_nslog,(void*)&orig_nslog};
            rcd_rebind_symbols((struct rcd_rebinding[1]){nslog_rebinding}, 1);
        });
    }
}

@end
