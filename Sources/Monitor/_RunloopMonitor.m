//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import "_RunloopMonitor.h"
#import "_BacktraceLogger.h"

// 定义延迟时间 毫秒
static int64_t const OUT_TIME = 100 * NSEC_PER_MSEC;
// before wait 的超时时间
static NSTimeInterval const WAIT_TIME = 0.5;

@interface _RunloopMonitor () {
    @public
    CFRunLoopObserverRef observer;
    CFRunLoopActivity currentActivity;
    dispatch_semaphore_t semaphore;
    BOOL isMonitoring;
}
@end

static void runloopObserverCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    //_RunloopMonitor * monitor = (__bridge _RunloopMonitor*)info;
    [_RunloopMonitor shared]->currentActivity = activity;
    
//    switch (activity) {
//        case kCFRunLoopEntry:
//            NSLog(@"##### %@", @"kCFRunLoopEntry");
//            break;
//        case kCFRunLoopBeforeTimers:
//            NSLog(@"##### %@", @"kCFRunLoopBeforeTimers");
//            break;
//        case kCFRunLoopBeforeSources:
//            NSLog(@"##### %@", @"kCFRunLoopBeforeSources");
//            break;
//        case kCFRunLoopBeforeWaiting:
//            NSLog(@"##### %@", @"kCFRunLoopBeforeWaiting");
//            break;
//        case kCFRunLoopAfterWaiting:
//            NSLog(@"##### %@", @"kCFRunLoopAfterWaiting");
//            break;
//        case kCFRunLoopExit:
//            NSLog(@"##### %@", @"kCFRunLoopExit");
//            break;
//        default:
//            break;
//    }
    
    dispatch_semaphore_t sema = [_RunloopMonitor shared]->semaphore;
    dispatch_semaphore_signal(sema);
}

@implementation _RunloopMonitor

+ (instancetype)shared {
    static id ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[super allocWithZone:NSDefaultMallocZone()] init];
    });
    return ins;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shared];
}

- (void)dealloc {
    [self endMonitor];
    [super dealloc];
}

- (void)beginMonitor {
    
    if ([_RunloopMonitor shared]->isMonitoring) return;
    
    [_RunloopMonitor shared]->isMonitoring = YES;
    
    // 创建观察者
    CFRunLoopObserverContext context = {
        0,
        (__bridge void*)self,
        &CFRetain,
        &CFRelease,
        NULL
    };
    //static CFRunLoopObserverRef observer;
    observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &runloopObserverCallback, &context);
    
    // 观察主线程
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    
    // 在子线程中监控卡顿
    semaphore = dispatch_semaphore_create(0); //同步?
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 开启持续的loop来监控
        while ([_RunloopMonitor shared]->isMonitoring) {
            if ([_RunloopMonitor shared]->currentActivity == kCFRunLoopBeforeWaiting)
            {
                // 处理休眠前事件观测
                __block BOOL timeOut = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    timeOut = NO; // timeOut任务
                });
                [NSThread sleepForTimeInterval:WAIT_TIME];
                // WAIT_TIME 时间后,如果 timeOut任务 任未执行, 则认为主线程前面的任务执行时间过长导致卡顿
                if (timeOut) {
                    [_BacktraceLogger cocoadebug_logMain];
                }
            }
            else
            {
                // 处理 Timer,Source,唤醒后事件
                // 同步等待时间内,接收到信号result=0, 超时则继续往下执行并且result!=0
                long result = dispatch_semaphore_wait([_RunloopMonitor shared]->semaphore, dispatch_time(DISPATCH_TIME_NOW, OUT_TIME));
                if (result != 0) { // 超时
                    if (![_RunloopMonitor shared]->observer) {
                        [[_RunloopMonitor shared] endMonitor];
                        continue;
                    }
                    if ([_RunloopMonitor shared]->currentActivity == kCFRunLoopBeforeSources ||
                        [_RunloopMonitor shared]->currentActivity == kCFRunLoopAfterWaiting  ||
                        [_RunloopMonitor shared]->currentActivity == kCFRunLoopBeforeTimers) {
                        
                        [_BacktraceLogger cocoadebug_logMain];
                    }
                }
            }
        }
    });
    
}

- (void)endMonitor {
    if (!observer) return;
    if (!isMonitoring) return;
    isMonitoring = NO;
    
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    CFRelease(observer);
    observer = nil;
}

@end
