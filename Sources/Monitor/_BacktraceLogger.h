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

+ (NSString *)lxd_backtraceOfAllThread;
+ (NSString *)lxd_backtraceOfMainThread;
+ (NSString *)lxd_backtraceOfCurrentThread;
+ (NSString *)lxd_backtraceOfNSThread:(NSThread *)thread;

+ (void)lxd_logMain;
+ (void)lxd_logCurrent;
+ (void)lxd_logAllThread;

@end
