//
//  CocoaDebug+Extension.m
//  Example_Objc
//
//  Created by iCeBlink on 2018/11/7.
//  Copyright © 2018 liman. All rights reserved.
//

#import "CocoaDebug+Extension.h"

@implementation CocoaDebug (Extension)

+ (void)objcLogWithFile:(const char *)file
               function:(NSString *)function
                   line:(NSUInteger)line
                  color:(UIColor *)color
                message:(id)format, ...
{
    va_list args;
    
    if (format)
    {
        if ([format isKindOfClass:[NSString class]])
        {
            va_start(args, format);
            
            NSString *wholeMsg = [[NSString alloc] initWithFormat:format arguments:args];
            
            va_end(args);
            
            va_start(args, format);
            
            [LogHelper.shared objcHandleLogWithFile:[NSString stringWithUTF8String:file] function:function line:line message:wholeMsg color:color];
            
            va_end(args);
        }
        else
        {
            [LogHelper.shared objcHandleLogWithFile:[NSString stringWithUTF8String:file] function:function line:line message:[NSString stringWithFormat:@"%@",format] color:color];
        }
        
    }
}

@end
