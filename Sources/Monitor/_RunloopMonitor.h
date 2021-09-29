//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface _RunloopMonitor : NSObject
//@property (nonatomic, copy, class) NSString * version;
+ (instancetype)shared;

- (void)beginMonitor;

- (void)endMonitor;

@end

NS_ASSUME_NONNULL_END
