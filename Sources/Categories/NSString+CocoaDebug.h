//
//  CocoaDebug.swift
//  demo
//
//  Created by CocoaDebug on 26/11/2017.
//  Copyright © 2018 CocoaDebug. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (CocoaDebug)

//计算NSString高度
- (CGFloat)cocoaDebug_heightWithFont:(UIFont *)font constraintToWidth:(CGFloat)width;

@end
