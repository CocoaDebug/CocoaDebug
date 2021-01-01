//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface _DebugConsoleLabel : UILabel

- (void)updateLabelWithValue:(float)value;

- (NSAttributedString *)fpsAttributedStringWith:(float)fps;

@end
