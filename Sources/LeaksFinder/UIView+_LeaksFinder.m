//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "UIView+_LeaksFinder.h"
#import "NSObject+_LeaksFinder.h"

@implementation UIView (_LeaksFinder)

- (BOOL)willDealloc {
    if (![super willDealloc]) {
        return NO;
    }
    
    [self willReleaseChildren:self.subviews];
    
    return YES;
}

@end
