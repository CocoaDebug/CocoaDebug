//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "UITouch+_LeaksFinder.h"
#import "NSObject+_LeaksFinder.h"
#import <objc/runtime.h>

extern const void *const kLatestSenderKey;

@implementation UITouch (_LeaksFinder)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSEL:@selector(setView:) withSEL:@selector(swizzled_setView:)];
    });
}

- (void)swizzled_setView:(UIView *)view {
    [self swizzled_setView:view];
    
    if (view) {
        objc_setAssociatedObject([UIApplication sharedApplication],
                                 kLatestSenderKey,
                                 @((uintptr_t)view),
                                 OBJC_ASSOCIATION_RETAIN);
    }
}

@end
