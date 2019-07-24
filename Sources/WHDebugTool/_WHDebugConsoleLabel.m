//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "_WHDebugConsoleLabel.h"

@implementation _WHDebugConsoleLabel {
    UIFont *_font;
    UIFont *_subFont;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) { [self setDefault]; }
    return self;
}

- (void)setDefault {
    self.textAlignment = NSTextAlignmentCenter;
    self.userInteractionEnabled = NO;
    self.adjustsFontSizeToFitWidth = YES;
    
    _font = [UIFont fontWithName:@"Menlo" size:14];
    if (_font) {
        _subFont = [UIFont fontWithName:@"Menlo" size:4];
    } else {
        _font = [UIFont fontWithName:@"Courier" size:14];
        _subFont = [UIFont fontWithName:@"Courier" size:4];
    }
}

- (void)updateLabelWith:(_DebugToolLabelType)labelType value:(float)value {
    switch (labelType) {
        case _DebugToolLabelTypeFPS:
            self.attributedText = [self fpsAttributedStringWith:value];
            break;
        case _DebugToolLabelTypeMemory:
            self.attributedText = [self memoryAttributedStringWith:value];
            break;
        case _DebugToolLabelTypeCPU:
            self.attributedText = [self cpuAttributedStringWith:value];
            break;
        default:
            break;
    }
}

#pragma mark - NSAttributedString

- (NSAttributedString *)fpsAttributedStringWith:(float)fps {
    CGFloat progress = fps / 60.0;
    UIColor *color = [UIColor colorWithHue:0.27 * (progress - 0.2) saturation:1 brightness:0.9 alpha:1];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d FPS",(int)round(fps)]];
    [text addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, text.length - 3)];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(text.length - 3, 3)];
    [text addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, text.length)];
    [text addAttribute:NSFontAttributeName value:_subFont range:NSMakeRange(text.length - 4, 1)];
    return text;
}

- (NSAttributedString *)memoryAttributedStringWith:(float)memory {
    CGFloat progress = memory / 350;
    UIColor *color = [self getColorByPercent:progress];;
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.1f M",memory]];
    [text addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, text.length - 1)];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(text.length - 1, 1)];
    [text addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, text.length)];
    [text addAttribute:NSFontAttributeName value:_subFont range:NSMakeRange(text.length - 2, 1)];
    return text;
}

- (NSAttributedString *)cpuAttributedStringWith:(float)cpu {
    CGFloat progress = cpu / 100;
    UIColor *color = [self getColorByPercent:progress];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d%% CPU",(int)round(cpu)]];
    [text addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, text.length - 3)];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(text.length - 3, 3)];
    [text addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, text.length)];
    [text addAttribute:NSFontAttributeName value:_subFont range:NSMakeRange(text.length - 4, 1)];
    return text;
}

#pragma mark - Color

- (UIColor*)getColorByPercent:(CGFloat)percent {
    NSInteger r = 0, g = 0, one = 255 + 255;
    if (percent < 0.5) {
        r = one * percent;
        g = 255;
    }
    if (percent >= 0.5) {
        g = 255 - ((percent - 0.5 ) * one) ;
        r = 255;
    }
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:0 alpha:1];
}

@end
