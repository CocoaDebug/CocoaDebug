//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//


//***************** Private API *****************
#import "CocoaDebug.h"

@import UIKit;
@import Foundation;
@import ObjectiveC.runtime;

@interface NSObject()
- (void)_setWindowControlsStatusBarOrientation:(BOOL)orientation;
@end

@interface _FakeWindowClass : UIWindow
@end

@implementation _FakeWindowClass

- (instancetype)initSwizzled {
  if (self = [super init]) {
      [self _setWindowControlsStatusBarOrientation:NO];
  }
  return self;
}

@end

@implementation NSObject (_UIDebuggingInformationOverlay)

+ (void)load {
    #ifdef DEBUG
        if (@available(iOS 11.0, *)) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                Class cls = NSClassFromString(@"UIDebuggingInformationOverlay");
                [_FakeWindowClass swizzleOriginalSelector:@selector(init) withSizzledSelector:@selector(initSwizzled) forClass:cls isClassMethod:NO];
            });
        } else {
            // Fallback on earlier versions
        }
    #endif
}


+ (void)swizzleOriginalSelector:(SEL)originalSelector withSizzledSelector:(SEL)swizzledSelector forClass:(Class)class isClassMethod:(BOOL)isClassMethod {
    Method originalMethod;
    Method swizzledMethod;

    if (isClassMethod) {
        originalMethod = class_getClassMethod(class, originalSelector);
        swizzledMethod = class_getClassMethod([self class], swizzledSelector);
    } else {
        originalMethod = class_getInstanceMethod(class, originalSelector);
        swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
    }
    
    if (!class_addMethod([self class], swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
//***************** Private API *****************
