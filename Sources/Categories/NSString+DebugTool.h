//
//  DebugTool.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (DebugTool)

//计算NSString高度
- (CGFloat)heightWithFont:(UIFont *)font constraintToWidth:(CGFloat)width;

@end
