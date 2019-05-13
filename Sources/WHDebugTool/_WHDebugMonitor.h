//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#define WHSingletonH() +(instancetype)sharedInstance;
#define WHSingletonM() static id _instance;\
+ (instancetype)sharedInstance {\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        _instance = [[self alloc] init];\
    });\
    return _instance;\
}

#import <Foundation/Foundation.h>

typedef void(^UpdateValueBlock)(float value);

@interface _WHDebugMonitor : NSObject

WHSingletonH()

@property (nonatomic, copy) UpdateValueBlock valueBlock;

- (void)startMonitoring;
- (void)stopMonitoring;

@end
