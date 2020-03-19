//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_ObjcLog.h"
#import "_OCLogHelper.h"
#import "_NSObject+CocoaDebug.h"
#import <JavaScriptCore/JavaScriptCore.h>

@implementation _ObjcLog

+ (void)logWithFile:(const char *)file
           function:(const char *)function
               line:(NSUInteger)line
              color:(UIColor *)color
   unicodeToChinese:(BOOL)unicodeToChinese
            message:(id)format, ...
{
    
    //unicode转换为中文
    if (format && [format isKindOfClass:[NSString class]] && unicodeToChinese) {
        format = [NSString unicodeToChinese:format];
    }
    
    
    
    if (format)
    {
        va_list args;
        va_start(args, format);
        
        if ([format isKindOfClass:[NSString class]])
        {
//            NSLogv(format, args);
            [_OCLogHelper.shared handleLogWithFile:[NSString stringWithUTF8String:file] function:[NSString stringWithUTF8String:function] line:line message:[[NSString alloc] initWithFormat:format arguments:args] color:color type:CocoaDebugToolTypeNone];
        }
        else if ([format isKindOfClass:[JSValue class]])
        {
            id format_ = [format toString];
            if ([format_ isEqualToString:@"[object Object]"])
            {
                format_ = [format toDictionary];
//                NSLogv([NSString stringWithFormat:@"%@",format_], args);
                [_OCLogHelper.shared handleLogWithFile:[NSString stringWithUTF8String:file] function:[NSString stringWithUTF8String:function] line:line message:[NSString stringWithFormat:@"%@",format_] color:color type:CocoaDebugToolTypeNone];
            }
            else
            {
//                NSLogv([NSString stringWithFormat:@"%@",format], args);
                [_OCLogHelper.shared handleLogWithFile:[NSString stringWithUTF8String:file] function:[NSString stringWithUTF8String:function] line:line message:[NSString stringWithFormat:@"%@",format] color:color type:CocoaDebugToolTypeNone];
            }
        }
        else
        {
//            NSLogv([NSString stringWithFormat:@"%@",format], args);
            [_OCLogHelper.shared handleLogWithFile:[NSString stringWithUTF8String:file] function:[NSString stringWithUTF8String:function] line:line message:[NSString stringWithFormat:@"%@",format] color:color type:CocoaDebugToolTypeNone];
        }
        
        va_end(args);
    }
}

@end
