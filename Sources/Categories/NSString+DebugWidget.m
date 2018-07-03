//
//  DebugWidget.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "NSString+DebugWidget.h"

@implementation NSString (DebugWidget)

- (CGFloat)debugWidget_heightWithFont:(UIFont *)font constraintToWidth:(CGFloat)width
{
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil];
    
    return rect.size.height;
}

@end
