//
//  CocoaDebug
//  liman
//
//  Created by liman 02/02/2023.
//  Copyright © 2023 liman. All rights reserved.
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
