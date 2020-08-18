//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_DebugMonitor.h"

@implementation _DebugMonitor {
    NSThread *_thread;
    NSTimer *_timer;
}

#pragma mark - public
- (void)startMonitoring {
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadMain) object:nil];
    [_thread setName:@"MemoryMonitor_CocoaDebug"];
    _timer = [[NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(updateMemory) userInfo:nil repeats:YES] retain];
    [_thread start];
}

- (void)stopMonitoring {
    [_timer invalidate];
    [_timer release];
    if (_thread) {
        [_thread release];
    }
}

#pragma mark - private
- (float)getValue {
    return 0.0;
}

#pragma mark - target action
- (void)threadMain {
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] run];
    [_timer fire];
}

- (void)updateMemory {
    if (self.valueBlock) {
        self.valueBlock([self getValue]);
    }
}

@end
