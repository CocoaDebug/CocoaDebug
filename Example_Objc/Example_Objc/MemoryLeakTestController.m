//
//  ViewController.m
//  Example_Objc
//
//  Created by man on 8/11/20.
//  Copyright © 2020 man. All rights reserved.
//

#import "MemoryLeakTestController.h"

@interface MemoryLeakTestController () {
    NSTimer *_timer;
}

@end

@implementation MemoryLeakTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(doPoll) userInfo:nil repeats:YES];
}

- (void)stopPolling {
    [_timer invalidate];
    _timer = nil;
}

- (void)doPoll {
    //Do Something
}

- (void)dealloc {
    [_timer invalidate];
}

@end
