////
////  Example
////  man.li
////
////  Created by man.li on 11/11/2018.
////  Copyright © 2020 man.li. All rights reserved.
////
//
//#import "_DebugMonitor.h"
//#import "_GCDTimerManager.h"
//
//static NSString * const timerName = @"CocoaDebug_GCDTimerManager";
//
//@implementation _DebugMonitor
//
//#pragma mark - public
//- (void)startMonitoring {
//    [[_GCDTimerManager sharedInstance] scheduledDispatchTimerWithName:timerName timeInterval:1.0 queue:nil repeats:YES fireInstantly:YES action:^{
//        if (self.valueBlock) {
//            self.valueBlock([self getValue]);
//        }
//    }];
//}
//
//- (void)stopMonitoring {
//    [[_GCDTimerManager sharedInstance] cancelTimerWithName:timerName];
//}
//
//#pragma mark - private
//- (float)getValue {
//    return 0.0;
//}
//
//#pragma mark - dealloc
//- (void)dealloc {
//    [[_GCDTimerManager sharedInstance] cancelTimerWithName:timerName];
//}
//
//@end
