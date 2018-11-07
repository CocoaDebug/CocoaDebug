//
//  CocoaDebug+Extension.h
//  Example_Objc
//
//  Created by iCeBlink on 2018/11/7.
//  Copyright © 2018 liman. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@class CocoaDebug;

@interface CocoaDebug (Extension)

+ (void)objcLogWithFile:(const char *)file
               function:(NSString *)function
                   line:(NSUInteger)line
                  color:(UIColor *)color
                message:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
