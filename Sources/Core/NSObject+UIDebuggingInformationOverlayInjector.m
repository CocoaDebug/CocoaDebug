//
//  DebugMan.h
//  PhiSpeaker
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Phicomm. All rights reserved.
//

@import UIKit;
@import Foundation;
@import ObjectiveC.runtime;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma clang diagnostic ignored "-Wundeclared-selector"

#pragma mark - Section 0 - Private Declarations

@interface NSObject()
- (void)_setWindowControlsStatusBarOrientation:(BOOL)orientation;
@end

#pragma mark - Section 1 - FakeWindowClass

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

#pragma mark - Section 2 - Initialization

@implementation NSObject (UIDebuggingInformationOverlayInjector)

+ (void)load
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class cls = NSClassFromString(@"UIDebuggingInformationOverlay");
    
    [FakeWindowClass swizzleOriginalSelector:@selector(init) withSizzledSelector:@selector(initSwizzled) forClass:cls isClassMethod:NO];
//    [self swizzleOriginalSelector:@selector(prepareDebuggingOverlay) withSizzledSelector:@selector(prepareDebuggingOverlaySwizzled) forClass:cls isClassMethod:YES];
  });
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
  
  method_exchangeImplementations(originalMethod, swizzledMethod);
}

#pragma mark - Section 3 - prepareDebuggingOverlay
/*
+ (void)prepareDebuggingOverlaySwizzled
{
  Class cls = NSClassFromString(@"UIDebuggingInformationOverlay");
  SEL sel = @selector(prepareDebuggingOverlaySwizzled);
  Method m = class_getClassMethod(cls, sel); 

  IMP imp =  method_getImplementation(m);
  void (*methodOffset) = (void *)((imp + (long)27));
  void *returnAddr = &&RETURNADDRESS;
  
  __asm__ __volatile__(
      "pushq  %0\n\t"
      "pushq  %%rbp\n\t"
      "movq   %%rsp, %%rbp\n\t"
      "pushq  %%r15\n\t"
      "pushq  %%r14\n\t"
      "pushq  %%r13\n\t"
      "pushq  %%r12\n\t"
      "pushq  %%rbx\n\t"
      "pushq  %%rax\n\t"
      "jmp  *%1\n\t"
      :
      : "r" (returnAddr), "r" (methodOffset));
  
  RETURNADDRESS: ;
}
*/
@end

#pragma clang diagnostic pop




