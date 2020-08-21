//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^UpdateValueBlock)(float value);

@interface _DebugMonitor : NSObject

@property (nonatomic, copy) UpdateValueBlock valueBlock;

- (void)startMonitoring;
- (void)stopMonitoring;

@end
