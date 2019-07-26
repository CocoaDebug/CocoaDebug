//
//  _NSLogHook.m
//  Example_Swift
//
//  Created by man on 7/26/19.
//  Copyright © 2019 man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import "_fishhook.h"
#import "_OCLogHelper.h"

@interface NSLogHook : NSObject

@end

@implementation NSLogHook

static void (*orig_nslog)(NSString *format, ...);

void my_nslog(NSString *format, ...) {
    /*方法一*/
//    va_list vl;
//    va_start(vl, format);
//    NSString *str = [[NSString alloc] initWithFormat:format arguments:vl];
//    va_end(vl);
//    orig_nslog(str);
    
    /*方法二*/
    va_list va;
    va_start(va, format);
    NSLogv(format, va);
//    va_end(va);
    
    
    
    [_OCLogHelper.shared handleLogWithFile:@"" function:@"" line:999999999 message:[[NSString alloc] initWithFormat:format arguments:va] color:[UIColor whiteColor]];
    
    va_end(va);
}

+ (void)load {
    struct rebinding nslog_rebinding = {"NSLog",my_nslog,(void*)&orig_nslog};
    rebind_symbols((struct rebinding[1]){nslog_rebinding}, 1);
}

@end
