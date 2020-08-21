//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, _DebugToolLabelType) {
    _DebugToolLabelTypeFPS,
    _DebugToolLabelTypeMemory,
    _DebugToolLabelTypeCPU
};

@interface _DebugConsoleLabel : UILabel

- (void)updateLabelWith:(_DebugToolLabelType)labelType value:(float)value;

- (NSAttributedString *)fpsAttributedStringWith:(float)fps;
- (NSAttributedString *)memoryAttributedStringWith:(float)memory;
- (NSAttributedString *)cpuAttributedStringWith:(float)cpu;

@end
