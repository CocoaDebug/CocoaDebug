//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "_WHDebugMonitor.h"

@implementation _WHDebugMonitor {
    NSTimer *_timer;
}

WHSingletonM()

- (void)startMonitoring {
    [self stopMonitoring];
    _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateValue) userInfo:nil repeats:YES];
    [_timer fire];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)updateValue {
    if (self.valueBlock) {
        self.valueBlock([self getValue]);
    }
}

- (float)getValue {
    return 0.0;
}

- (void)stopMonitoring {
    [_timer invalidate];
    _timer = nil;
}

@end
