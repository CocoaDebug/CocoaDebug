//
//  _PrintfHook.m
//  Example_Swift
//
//  Created by man.li on 7/26/19.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_OCLogHelper.h"
#import "_fishhook.h"

@interface _PrintfHook : NSObject

@end

@implementation _PrintfHook

static void (*original_printf)(const char *, ...);


void god_printf(const char *format, ...) {
    
    //avoid crash
    if (!format) {return;}
    
    //
    original_printf(format);

    //
    NSString *str = [NSString stringWithUTF8String:format];
    
    //
    [_OCLogHelper.shared handleLogWithFile:@"" function:@"" line:999999999 message:str color:[UIColor whiteColor] type:CocoaDebugToolTypeNone];
}


+ (void)load {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disableLogMonitoring_CocoaDebug"]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            struct rcd_rebinding printf_rebinding = { "printf", god_printf, (void *)&original_printf };
            rcd_rebind_symbols((struct rcd_rebinding[1]){printf_rebinding}, 1);
        });
    }
}

@end
