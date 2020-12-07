//
//  _NSLogHook.m
//  Example_Swift
//
//  Created by man.li on 7/26/19.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_OCLogHelper.h"
#import "_fishhook.h"
//#import <React/RCTLog.h>

@interface _NSLogHook : NSObject

@end

@implementation _NSLogHook

static void (*_original_nslog)(NSString *format, ...);



void cocoadebug_nslog(NSString *format, ...) {
    
    //avoid crash
    if (![format isKindOfClass:[NSString class]]) {
        return;
    }
    
    //
    va_list vl;
    va_start(vl, format);
    NSString *str = [[NSString alloc] initWithFormat:format arguments:vl];
    
    //
    _original_nslog(str);
    
    //
    @try {
        [_OCLogHelper.shared handleLogWithFile:@"" function:@"" line:999999999 message:str color:[UIColor whiteColor] type:CocoaDebugToolTypeNone];
    } @catch(NSException *exception) {
        
    } @finally {
        
    }
    
    //
    va_end(vl);
}



+ (void)load {
    
    //nslog
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disableLogMonitoring_CocoaDebug"]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            struct rcd_rebinding nslog_rebinding = {"NSLog",cocoadebug_nslog,(void*)&_original_nslog};
            rcd_rebind_symbols((struct rcd_rebinding[1]){nslog_rebinding}, 1);
        });
    }
    
    
    //RN
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"disableRNMonitoring_CocoaDebug"]) {
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//
//            RCTSetLogFunction(^(RCTLogLevel level, RCTLogSource source, NSString *fileName, NSNumber *lineNumber, NSString *message) {
//                if (![message isKindOfClass:[NSString class]]) {
//                    return;
//                }
//
//                if (level != RCTLogLevelError && level != RCTLogLevelInfo) {
//                    return;
//                }
//
//                //1.
//                NSString *levelStr = @"";
//                switch (level) {
//                    case RCTLogLevelTrace:
//                        levelStr = @"[RCTLogTrace]";
//                        break;
//                    case RCTLogLevelInfo:
//                        levelStr = @"[RCTLogInfo]";
//                        break;
//                    case RCTLogLevelWarning:
//                        levelStr = @"[RCTLogWarn]";
//                        break;
//                    case RCTLogLevelError:
//                        levelStr = @"[RCTLogError]";
//                        break;
//                    case RCTLogLevelFatal:
//                        levelStr = @"[RCTLogFatal]";
//                        break;
//                    default:
//                        break;
//                }
//
//                //2.
//                NSString *fileStr = [[(fileName ?: @"") componentsSeparatedByString:@"/"] lastObject] ?: @"";
//                if ([lineNumber isKindOfClass:[NSNumber class]]) {
//                    fileStr = [NSString stringWithFormat:@"%@[%ld]", fileStr, (long)[lineNumber integerValue]];
//                }
//
//                //3.
//                fileStr = [NSString stringWithFormat:@"%@%@\n", fileStr, levelStr];
//
//                //4.
//                if (source == RCTLogSourceJavaScript)
//                {
//                    //`RCTLogSourceJavaScript`
//                    [_OCLogHelper.shared handleLogWithFile:fileStr function:@"" line:-1 message:message color:[UIColor whiteColor] type:CocoaDebugToolTypeRN];
//                }
//                else
//                {
//                    //`RCTLogSourceNative` or unknow
//                    [_OCLogHelper.shared handleLogWithFile:fileStr function:@"" line:-1 message:message color:[UIColor systemOrangeColor] type:CocoaDebugToolTypeRN];
//                }
//            });
//        });
//    }
}

@end
