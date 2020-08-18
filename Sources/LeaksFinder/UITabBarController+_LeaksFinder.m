//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "UITabBarController+_LeaksFinder.h"
#import "NSObject+_LeaksFinder.h"

#if _INTERNAL_MLF_ENABLED

@implementation UITabBarController (_LeaksFinder)

- (BOOL)willDealloc {
    if (![super willDealloc]) {
        return NO;
    }
    
    [self willReleaseChildren:self.viewControllers];
    
    return YES;
}

@end

#endif
