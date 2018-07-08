//
//  CocoaDebug.swift
//  demo
//
//  Created by CocoaDebug on 26/11/2017.
//  Copyright © 2018 CocoaDebug. All rights reserved.
//

#import "NSString+CocoaDebug.h"

@implementation NSString (CocoaDebug)

- (CGFloat)cocoaDebug_heightWithFont:(UIFont *)font constraintToWidth:(CGFloat)width
{
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil];
    
    return rect.size.height;
}

@end
