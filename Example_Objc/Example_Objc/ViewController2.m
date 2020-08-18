//
//  ViewController.m
//  Example_Objc
//
//  Created by man on 8/11/20.
//  Copyright © 2020 man. All rights reserved.
//

#import "ViewController2.h"

@interface ViewController2 () {
    NSTimer *_timer;
}

@end

@implementation ViewController2

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
