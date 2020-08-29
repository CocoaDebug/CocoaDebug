//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "UINavigationController+_LeaksFinder.h"
#import "NSObject+_LeaksFinder.h"
#import <objc/runtime.h>

static const void *const kPoppedDetailVCKey = &kPoppedDetailVCKey;

@implementation UINavigationController (_LeaksFinder)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleSEL:@selector(pushViewController:animated:) withSEL:@selector(swizzled_pushViewController:animated:)];
        [self swizzleSEL:@selector(popViewControllerAnimated:) withSEL:@selector(swizzled_popViewControllerAnimated:)];
        [self swizzleSEL:@selector(popToViewController:animated:) withSEL:@selector(swizzled_popToViewController:animated:)];
        [self swizzleSEL:@selector(popToRootViewControllerAnimated:) withSEL:@selector(swizzled_popToRootViewControllerAnimated:)];
        [self swizzleSEL:@selector(setViewControllers:animated:) withSEL:@selector(swizzled_setViewControllers:animated:)];
    });
}

- (void)swizzled_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.splitViewController) {
        id detailViewController = objc_getAssociatedObject(self, kPoppedDetailVCKey);
        if ([detailViewController isKindOfClass:[UIViewController class]]) {
            [detailViewController willDealloc];
            objc_setAssociatedObject(self, kPoppedDetailVCKey, nil, OBJC_ASSOCIATION_RETAIN);
        }
    }
    
    [self swizzled_pushViewController:viewController animated:animated];
}

- (UIViewController *)swizzled_popViewControllerAnimated:(BOOL)animated {
    UIViewController *poppedViewController = [self swizzled_popViewControllerAnimated:animated];
    
    if (!poppedViewController) {
        return nil;
    }
    
    // Detail VC in UISplitViewController is not dealloced until another detail VC is shown
    if (self.splitViewController &&
        self.splitViewController.viewControllers.firstObject == self &&
        self.splitViewController == poppedViewController.splitViewController) {
        objc_setAssociatedObject(self, kPoppedDetailVCKey, poppedViewController, OBJC_ASSOCIATION_RETAIN);
        return poppedViewController;
    }
    
    // VC is not dealloced until disappear when popped using a left-edge swipe gesture
    if (animated) {
        id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.transitionCoordinator;
        [transitionCoordinator animateAlongsideTransition: ^(__unused id<UIViewControllerTransitionCoordinatorContext> context) {
        }
        completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            if (!context.isCancelled) {
                [poppedViewController willDealloc];
            }
        }];
    } else {
        [poppedViewController willDealloc];
    }
    
    return poppedViewController;
}

- (NSArray<UIViewController *> *)swizzled_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSArray<UIViewController *> *poppedViewControllers = [self swizzled_popToViewController:viewController animated:animated];
    
    for (UIViewController *viewController in poppedViewControllers) {
        [viewController willDealloc];
    }
    
    return poppedViewControllers;
}

- (NSArray<UIViewController *> *)swizzled_popToRootViewControllerAnimated:(BOOL)animated {
    NSArray<UIViewController *> *poppedViewControllers = [self swizzled_popToRootViewControllerAnimated:animated];
    
    for (UIViewController *viewController in poppedViewControllers) {
        [viewController willDealloc];
    }
    
    return poppedViewControllers;
}

- (void)swizzled_setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    NSArray *prev = [self.viewControllers copy];
    [self swizzled_setViewControllers:viewControllers animated:animated];

    NSSet *set = [NSSet setWithArray:viewControllers];
    for (UIViewController *v in prev) {
        if (![set containsObject:v]) {
            [v willDealloc];
        }
    }
}

- (BOOL)willDealloc {
    if (![super willDealloc]) {
        return NO;
    }
    
    [self willReleaseChildren:self.viewControllers];
    
    return YES;
}

@end
