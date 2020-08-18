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

- (void)updateLabelWithValue:(float)value {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.attributedText = [self memoryAttributedStringWith:value];
    });
}

#pragma mark - NSAttributedString
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
