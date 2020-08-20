//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_DebugFPSMonitor.h"

@interface _DebugFPSMonitor()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSTimeInterval lastTimestamp;
@property (nonatomic, assign) NSInteger performTimes;

@end

@implementation _DebugFPSMonitor

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)startMonitoring {
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTicks:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)displayLinkTicks:(CADisplayLink *)link {
    if (_lastTimestamp == 0) {
        _lastTimestamp = link.timestamp;
        return;
    }
    _performTimes ++;
    NSTimeInterval interval = link.timestamp - _lastTimestamp;
    if (interval < 1) { return; }
    _lastTimestamp = link.timestamp;
    float fps = _performTimes / interval;
    _performTimes = 0;
    if (self.valueBlock) {
        self.valueBlock(fps);
    }
}

- (void)stopMonitoring {
    [_displayLink invalidate];
}

@end
