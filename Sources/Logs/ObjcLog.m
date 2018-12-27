//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "ObjcLog.h"
#import "OCLogHelper.h"

@implementation ObjcLog

+ (void)logWithFile:(const char *)file
           function:(NSString *)function
               line:(NSUInteger)line
              color:(UIColor *)color
   unicodeToChinese:(BOOL)unicodeToChinese
            message:(id)format, ...
{
    if (format)
    {
        va_list args;
        va_start(args, format);
        
        if ([format isKindOfClass:[NSString class]])
        {
            NSLogv(format, args);
            [OCLogHelper.shared handleLogWithFile:[NSString stringWithUTF8String:file] function:function line:line message:[[NSString alloc] initWithFormat:format arguments:args] color:color unicodeToChinese:unicodeToChinese];
        }
        else
        {
            NSLogv([NSString stringWithFormat:@"%@",format], args);
            [OCLogHelper.shared handleLogWithFile:[NSString stringWithUTF8String:file] function:function line:line message:[NSString stringWithFormat:@"%@",format] color:color unicodeToChinese:unicodeToChinese];
        }
        
        va_end(args);
    }
}

@end
