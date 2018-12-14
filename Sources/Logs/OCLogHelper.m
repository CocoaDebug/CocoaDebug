//
//  OCLogHelper.m
//  Example_Objc
//
//  Created by man on 2018/12/14.
//  Copyright © 2018年 liman. All rights reserved.
//

#import "OCLogHelper.h"

@implementation OCLogHelper

+ (instancetype)shared
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)handleLogWithFile:(NSString *)file function:(NSString *)function line:(NSInteger)line message:(NSString *)message color:(UIColor *)color
{
    if (!self.enable) {
        return;
    }
}

@end
