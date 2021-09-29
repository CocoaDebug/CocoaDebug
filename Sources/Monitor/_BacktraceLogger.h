//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  @brief  线程堆栈上下文输出
 */
@interface _BacktraceLogger : NSObject

+ (NSString *)cocoadebug_backtraceOfAllThread;
+ (NSString *)cocoadebug_backtraceOfMainThread;
+ (NSString *)cocoadebug_backtraceOfCurrentThread;
+ (NSString *)cocoadebug_backtraceOfNSThread:(NSThread *)thread;

+ (void)cocoadebug_logMain;
+ (void)cocoadebug_logCurrent;
+ (void)cocoadebug_logAllThread;

@end
