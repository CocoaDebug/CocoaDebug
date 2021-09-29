//
//  _NSLogHook.m
//  Example_Swift
//
//  Created by man 7/26/19.
//  Copyright © 2020 man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_OCLogHelper.h"
#import "_fishhook.h"
//#import <React/RCTLog.h>
//#import "RCTLog.h"

@interface _NSLogHook : NSObject

@end

@implementation _NSLogHook

static void (*_original_nslog)(NSString *format, ...);

#pragma mark - hooks
void cocoadebug_nslog(NSString *format, ...)
{
    if (![format isKindOfClass:[NSString class]]) {return;}
    
    va_list vl;
    va_start(vl, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:vl];
    
    @try {
        _original_nslog(str);
    } @catch(NSException *exception) {
        
    } @finally {
        
    }
    
    @try {
        [_OCLogHelper.shared handleLogWithFile:@"" function:@"" line:999999999 message:str color:[UIColor whiteColor] type:CocoaDebugToolTypeNone];
    } @catch(NSException *exception) {
        
    } @finally {
        
    }
    
    va_end(vl);
}

#pragma mark - load
+ (void)load
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"enableLogMonitoring_CocoaDebug"]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            struct rebinding nslog_rebinding = {"NSLog",cocoadebug_nslog,(void*)&_original_nslog};
            rebind_symbols((struct rebinding[1]){nslog_rebinding}, 1);
        });
    }
}

//#pragma mark - RN
//void _RCTLogJavaScriptInternal(RCTLogLevel level, NSString *message)
//{
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"enableRNMonitoring_CocoaDebug"]) {return;}
//    if (![message isKindOfClass:[NSString class]]) {return;}
////    if (level != RCTLogLevelError && level != RCTLogLevelInfo) {return;}
//
//    NSString *levelStr = @"";
//
//    switch (level) {
////        case RCTLogLevelTrace:
////            levelStr = @"[RCTLogTrace]";
////            break;
//        case RCTLogLevelInfo:
//            levelStr = @"[RCTLogInfo]";
//            break;
//        case RCTLogLevelWarning:
//            levelStr = @"[RCTLogWarn]";
//            break;
//        case RCTLogLevelError:
//            levelStr = @"[RCTLogError]";
//            break;
////        case RCTLogLevelFatal:
////            levelStr = @"[RCTLogFatal]";
//            break;
//        default:
//            break;
//    }
//
//    [_OCLogHelper.shared handleLogWithFile:[NSString stringWithFormat:@"%@\n", levelStr] function:@"" line:-1 message:message color:[UIColor whiteColor] type:CocoaDebugToolTypeRN];
//}

@end

