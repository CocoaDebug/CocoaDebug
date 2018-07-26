//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

//***************** Private API *****************
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma clang diagnostic ignored "-Wundeclared-selector"

@import UIKit;
@import Foundation;
@import ObjectiveC.runtime;

@interface NSObject()
- (void)_setWindowControlsStatusBarOrientation:(BOOL)orientation;
@end

@interface FakeWindowClass : UIWindow
@end

@implementation FakeWindowClass

- (instancetype)initSwizzled
{
  if (self = [super init]) {
      [self _setWindowControlsStatusBarOrientation:NO];
  }
  return self;
}

@end

@implementation NSObject (UIDebuggingInformationOverlay)

+ (void)load
{
    if (@available(iOS 11.0, *)) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class cls = NSClassFromString(@"UIDebuggingInformationOverlay");
            [FakeWindowClass swizzleOriginalSelector:@selector(init) withSizzledSelector:@selector(initSwizzled) forClass:cls isClassMethod:NO];
        });
    } else {
        // Fallback on earlier versions
    }
}

+ (void)swizzleOriginalSelector:(SEL)originalSelector withSizzledSelector:(SEL)swizzledSelector forClass:(Class)class isClassMethod:(BOOL)isClassMethod
{
    Method originalMethod;
    Method swizzledMethod;

    if (isClassMethod) {
        originalMethod = class_getClassMethod(class, originalSelector);
        swizzledMethod = class_getClassMethod([self class], swizzledSelector);
    } else {
        originalMethod = class_getInstanceMethod(class, originalSelector);
        swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
    }
    
    if (!class_addMethod([self class], swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod)))
    {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
#pragma clang diagnostic pop
//***************** Private API *****************
