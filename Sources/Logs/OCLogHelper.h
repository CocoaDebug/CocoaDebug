//
//  OCLogHelper.h
//  Example_Objc
//
//  Created by man on 2018/12/14.
//  Copyright © 2018年 liman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OCLogHelper : NSObject

@property (nonatomic, assign) BOOL enable;

+ (instancetype)shared;

- (void)handleLogWithFile:(NSString *)file function:(NSString *)function line:(NSInteger)line message:(NSString *)message color:(UIColor *)color;

@end
