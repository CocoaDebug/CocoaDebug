//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "UIApplication+_LeaksFinder.h"
#import "NSObject+_LeaksFinder.h"
#import <objc/runtime.h>

extern const void *const kLatestSenderKey;

@implementation UIApplication (_LeaksFinder)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSEL:@selector(sendAction:to:from:forEvent:) withSEL:@selector(swizzled_sendAction:to:from:forEvent:)];
    });
}

- (BOOL)swizzled_sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event {
    objc_setAssociatedObject(self, kLatestSenderKey, @((uintptr_t)sender), OBJC_ASSOCIATION_RETAIN);
    
    return [self swizzled_sendAction:action to:target from:sender forEvent:event];
}

@end
