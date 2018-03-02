//
//  DebugMan.h
//  PhiSpeaker
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Phicomm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (DebugMan)

//计算NSString高度
- (CGFloat)heightWithFont:(UIFont *)font constraintToWidth:(CGFloat)width;

@end
