//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_DebugConsoleLabel.h"

@interface _DebugConsoleLabel ()

@property (nonatomic, strong) UIFont *mainFont;
@property (nonatomic, strong) UIFont *subFont;

@end

@implementation _DebugConsoleLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefault];
    }
    return self;
}

- (void)setDefault {
    self.textAlignment = NSTextAlignmentCenter;
    self.userInteractionEnabled = NO;
    self.adjustsFontSizeToFitWidth = YES;
    
    self.mainFont = [UIFont fontWithName:@"Menlo" size:14];
    if (self.mainFont) {
        self.subFont = [UIFont fontWithName:@"Menlo" size:4];
    } else {
        self.mainFont = [UIFont fontWithName:@"Courier" size:14];
        self.subFont = [UIFont fontWithName:@"Courier" size:4];
    }
}

- (void)updateLabelWith:(_DebugToolLabelType)labelType value:(float)value {
    if (labelType == _DebugToolLabelTypeMemory) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.attributedText = [self memoryAttributedStringWith:value];
        });
        
    } else if (labelType == _DebugToolLabelTypeCPU) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.attributedText = [self cpuAttributedStringWith:value];
        });
        
    } else if (labelType == _DebugToolLabelTypeFPS) {
        self.attributedText = [self fpsAttributedStringWith:value];
    }
}

#pragma mark - NSAttributedString

- (NSAttributedString *)fpsAttributedStringWith:(float)fps {
    CGFloat progress = fps / 60.0;
    UIColor *color = [UIColor colorWithHue:0.27 * (progress - 0.2) saturation:1 brightness:0.9 alpha:1];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d FPS",(int)round(fps)]];
    [text addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, text.length - 3)];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(text.length - 3, 3)];
    [text addAttribute:NSFontAttributeName value:self.mainFont range:NSMakeRange(0, text.length)];
    [text addAttribute:NSFontAttributeName value:self.subFont range:NSMakeRange(text.length - 4, 1)];
    return text;
}

- (NSAttributedString *)memoryAttributedStringWith:(float)memory {
    CGFloat progress = memory / 350;
    UIColor *color = [self getColorByPercent:progress];;
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.1f M",memory]];
    [text addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, text.length - 1)];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(text.length - 1, 1)];
    [text addAttribute:NSFontAttributeName value:self.mainFont range:NSMakeRange(0, text.length)];
    [text addAttribute:NSFontAttributeName value:self.subFont range:NSMakeRange(text.length - 2, 1)];
    return text;
}

- (NSAttributedString *)cpuAttributedStringWith:(float)cpu {
    CGFloat progress = cpu / 100;
    UIColor *color = [self getColorByPercent:progress];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d%% CPU",(int)round(cpu)]];
    [text addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, text.length - 3)];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(text.length - 3, 3)];
    [text addAttribute:NSFontAttributeName value:self.mainFont range:NSMakeRange(0, text.length)];
    [text addAttribute:NSFontAttributeName value:self.subFont range:NSMakeRange(text.length - 4, 1)];
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
