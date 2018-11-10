//
//  CocoaDebugLog.m
//  Example_Objc
//
//  Created by man on 2018/11/10.
//  Copyright © 2018年 liman. All rights reserved.
//

#import "CocoaDebugLog.h"
//#import "Example_Swift-Swift.h"

@implementation CocoaDebugLog

+ (void)objcLogWithFile:(const char *)file
               function:(NSString *)function
                   line:(NSUInteger)line
                  color:(UIColor *)color
                message:(id)format, ...
{
    if (format)
    {
        va_list args;
        
        va_start(args, format);
        
        if ([format isKindOfClass:[NSString class]])
        {
            NSLogv(format, args);
            [LogHelper.shared objcHandleLogWithFile:[NSString stringWithUTF8String:file] function:function line:line message:[[NSString alloc] initWithFormat:format arguments:args] color:color];
        }
        else
        {
            NSLogv([NSString stringWithFormat:@"%@",format], args);
            [LogHelper.shared objcHandleLogWithFile:[NSString stringWithUTF8String:file] function:function line:line message:[NSString stringWithFormat:@"%@",format] color:color];
        }
        
        va_end(args);
    }
}

@end
