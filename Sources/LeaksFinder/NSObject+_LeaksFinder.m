//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "NSObject+_LeaksFinder.h"
#import "_LeakedObjectProxy.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "FBRetainCycleDetector.h"

static const void *const kViewStackKey = &kViewStackKey;
static const void *const kParentPtrsKey = &kParentPtrsKey;
const void *const kLatestSenderKey = &kLatestSenderKey;

//是否开启所有属性的检查
static const void *const kLeakCheckedKey = &kLeakCheckedKey;

@implementation NSObject (_LeaksFinder)

- (BOOL)willDealloc {
    if ([self isKindOfClass:[UIView class]]) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"enableMemoryLeaksMonitoring_UIView_CocoaDebug"]) {
            return NO; //UIView
        }
    } else {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"enableMemoryLeaksMonitoring_UIViewController_CocoaDebug"]) {
            return NO; //UIViewController
        }
    }
    
    NSString *className = NSStringFromClass([self class]);
    if ([[NSObject classNamesWhitelist] containsObject:className]) {
        return NO;
    }
    
    NSNumber *senderPtr = objc_getAssociatedObject([UIApplication sharedApplication], kLatestSenderKey);
    if ([senderPtr isEqualToNumber:@((uintptr_t)self)]) {
        return NO;
    }
    
    __weak id weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong id strongSelf = weakSelf;
        [strongSelf assertNotDealloc];
    });
    
    return YES;
}

- (void)assertNotDealloc {
    if ([_LeakedObjectProxy isAnyObjectLeakedAtPtrs:[self parentPtrs]]) {
        return;
    }
    [_LeakedObjectProxy addLeakedObject:self];
    
    NSString *className = NSStringFromClass([self class]);
    NSLog(@"Possibly Memory Leak.\nIn case that %@ should not be dealloced, override -willDealloc in %@ by returning NO.\nView-ViewController stack: %@", className, className, [self viewStack]);
}

- (void)willReleaseObject:(id)object relationship:(NSString *)relationship {
    if ([relationship hasPrefix:@"self"]) {
        relationship = [relationship stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:@""];
    }
    NSString *className = NSStringFromClass([object class]);
    className = [NSString stringWithFormat:@"%@(%@), ", relationship, className];
    
    [object setViewStack:[[self viewStack] arrayByAddingObject:className]];
    [object setParentPtrs:[[self parentPtrs] setByAddingObject:@((uintptr_t)object)]];
    [object willDealloc];
}

- (void)willReleaseChild:(id)child {
    if (!child) {
        return;
    }
    
    [self willReleaseChildren:@[ child ]];
}

- (void)willReleaseChildren:(NSArray *)children {
    NSArray *viewStack = [self viewStack];
    NSSet *parentPtrs = [self parentPtrs];
    for (id child in children) {
        NSString *className = NSStringFromClass([child class]);
        [child setViewStack:[viewStack arrayByAddingObject:className]];
        [child setParentPtrs:[parentPtrs setByAddingObject:@((uintptr_t)child)]];
        [child willDealloc];
    }
}

- (NSArray *)viewStack {
    NSArray *viewStack = objc_getAssociatedObject(self, kViewStackKey);
    if (viewStack) {
        return viewStack;
    }
    
    NSString *className = NSStringFromClass([self class]);
    return @[ className ];
}

- (void)setViewStack:(NSArray *)viewStack {
    objc_setAssociatedObject(self, kViewStackKey, viewStack, OBJC_ASSOCIATION_RETAIN);
}

- (NSSet *)parentPtrs {
    NSSet *parentPtrs = objc_getAssociatedObject(self, kParentPtrsKey);
    if (!parentPtrs) {
        parentPtrs = [[NSSet alloc] initWithObjects:@((uintptr_t)self), nil];
    }
    return parentPtrs;
}

- (void)setParentPtrs:(NSSet *)parentPtrs {
    objc_setAssociatedObject(self, kParentPtrsKey, parentPtrs, OBJC_ASSOCIATION_RETAIN);
}

+ (NSMutableSet *)classNamesWhitelist {
    static NSMutableSet *whitelist = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        whitelist = [NSMutableSet setWithObjects:
                     
                     @"UIFieldEditor",
                     @"UINavigationBar",
                     @"UIAlertController",

                     @"_UIAlertControllerActionView",
                     @"_UIVisualEffectBackdropView",
                     @"_UIAlertControllerTextField",
                     @"_UIAlertControllerView",
                     
                     nil];
        
        // System's bug since iOS 10 and not fixed yet up to this ci.
        NSString *systemVersion = [UIDevice currentDevice].systemVersion;
        if ([systemVersion compare:@"10.0" options:NSNumericSearch] != NSOrderedAscending) {
            [whitelist addObject:@"UISwitch"];
        }
    });
    return whitelist;
}

//+ (void)addClassNamesToWhitelist:(NSArray *)classNames {
//    [[self classNamesWhitelist] addObjectsFromArray:classNames];
//}

+ (void)swizzleSEL:(SEL)originalSEL withSEL:(SEL)swizzledSEL {

    // Just find a place to set up FBRetainCycleDetector.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [FBAssociationManager hook];
        });
    });
    
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, originalSEL);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSEL);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSEL,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSEL,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


#pragma mark - 是否开启所有属性的检查
- (BOOL)leakChecked {
    NSNumber *leak = objc_getAssociatedObject(self, kLeakCheckedKey);
    return [leak boolValue];
}

- (void)setLeakChecked:(BOOL)leakChecked {
    objc_setAssociatedObject(self, kLeakCheckedKey, @(leakChecked),OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)continueCheckObjecClass:(Class)objectClass {
    if (!objectClass) {
        return NO;
    }

    NSBundle *bundle = [NSBundle bundleForClass:objectClass];
    if (bundle != [NSBundle mainBundle]) {
        return NO;
    }

    return YES;

}

- (void)willReleaseIvarLisWithTargetObjectClass:(id)targetObjectClass {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"enableMemoryLeaksMonitoring_MemberVariables_CocoaDebug"]) {
        return; //Member Variables
    }
    
    if (!targetObjectClass) {
        return;
    }
    NSArray *viewStack = [self viewStack];
    NSSet *parentPtrs = [self parentPtrs];

    unsigned int outCount = 0;
    Ivar * ivars = class_copyIvarList(targetObjectClass, &outCount);
    NSString *stringType = nil;

    for (unsigned int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        const char * name = ivar_getName(ivar);
        const char * type = ivar_getTypeEncoding(ivar);
        stringType = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        //非NSObject类型不用继续遍历
        if ((!name) || ![stringType hasPrefix:@"@"] || [stringType isEqualToString:@"@"]) {
            continue;
        }

        id value = nil;

        @try {
            value =  [self valueForKey:[NSString stringWithUTF8String:name]];
        } @catch (NSException *exception) {
            NSLog(@"class %@ valueForKey:%s throw NSException,",NSStringFromClass([targetObjectClass class]),name);
        }

        if (![value continueCheckObjecClass:[value class]]) {
            continue;
        }

        NSString *className = NSStringFromClass([value class]);
        [value setViewStack:[viewStack arrayByAddingObject:className]];
        [value setParentPtrs:[parentPtrs setByAddingObject:@((uintptr_t)value)]];
        [value willDealloc];
        [value willReleaseIvarList];

    }
    free(ivars);
}

- (void)willReleaseIvarList {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"enableMemoryLeaksMonitoring_MemberVariables_CocoaDebug"]) {
        return; //Member Variables
    }
    
    [self setLeakChecked:YES];

    if (![self continueCheckObjecClass:[self class]]) {
        return;
    }
    [self willReleaseIvarLisWithTargetObjectClass:[self class]];

    if (![self continueCheckObjecClass:[self superclass]]) {
        return;
    }
    [self willReleaseIvarLisWithTargetObjectClass:[self superclass]];
}

@end
