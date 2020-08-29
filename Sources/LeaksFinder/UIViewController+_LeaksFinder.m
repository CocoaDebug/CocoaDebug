//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "UIViewController+_LeaksFinder.h"
#import "NSObject+_LeaksFinder.h"
#import <objc/runtime.h>

@implementation UIViewController (_LeaksFinder)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSEL:@selector(dismissViewControllerAnimated:completion:) withSEL:@selector(swizzled_dismissViewControllerAnimated:completion:)];
    });
}

- (void)swizzled_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self swizzled_dismissViewControllerAnimated:flag completion:completion];
    
    UIViewController *dismissedViewController = self.presentedViewController;
    if (!dismissedViewController && self.presentingViewController) {
        dismissedViewController = self;
    }
    
    if (!dismissedViewController) return;
    
    // present出来的VC, dismiss的时候, 系统会多持有几秒? 为了避免频繁的误报, 给他多一点时间dealloc
    __weak id weakVC = dismissedViewController;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong id strongVC = weakVC;
        [strongVC willDealloc];
    });
}

- (BOOL)willDealloc {
    if (![super willDealloc]) {
        return NO;
    }
    
    [self willReleaseChildren:self.childViewControllers];
    [self willReleaseChild:self.presentedViewController];
    
    if (self.isViewLoaded) {
        [self willReleaseChild:self.view];
    }
    
    //是否开启所有属性的检查
    [self willReleaseIvarList];
    
    return YES;
}

@end
