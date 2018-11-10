//
//  CocoaDebugLog.h
//  Example_Objc
//
//  Created by man on 2018/11/10.
//  Copyright © 2018年 liman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CocoaDebugLog : NSObject

+ (void)objcLogWithFile:(const char *)file
               function:(NSString *)function
                   line:(NSUInteger)line
                  color:(UIColor *)color
                message:(id)format, ...;

@end
