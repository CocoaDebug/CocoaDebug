//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "_OCLogModel.h"

@interface _OCLogHelper : NSObject

@property (nonatomic, assign) BOOL enable;

+ (instancetype)shared;

- (void)handleLogWithFile:(NSString *)file function:(NSString *)function line:(NSInteger)line message:(NSString *)message color:(UIColor *)color type:(CocoaDebugToolType)type;

@end
