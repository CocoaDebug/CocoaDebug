//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, _DebugToolLabelType) {
    _DebugToolLabelTypeFPS,
    _DebugToolLabelTypeMemory,
    _DebugToolLabelTypeCPU
};

@interface _WHDebugConsoleLabel : UILabel

- (void)updateLabelWith:(_DebugToolLabelType)labelType value:(float)value;

@end
