//
//  CocoaDebug
//  liman
//
//  Created by liman 02/02/2023.
//  Copyright © 2023 liman. All rights reserved.
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
