//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_FBStandardGraphEdgeFilters.h"

#import <objc/runtime.h>

#import <UIKit/UIKit.h>

#import "_FBObjectiveCGraphElement.h"
#import "_FBRetainCycleDetector.h"

_FBGraphEdgeFilterBlock _FBFilterBlockWithObjectIvarRelation(Class aCls, NSString *ivarName) {
  return _FBFilterBlockWithObjectToManyIvarsRelation(aCls, [NSSet setWithObject:ivarName]);
}

_FBGraphEdgeFilterBlock _FBFilterBlockWithObjectToManyIvarsRelation(Class aCls,
                                                                  NSSet<NSString *> *ivarNames) {
  return ^(_FBObjectiveCGraphElement *fromObject,
           NSString *byIvar,
           Class toObjectOfClass){
    if (aCls &&
        [[fromObject objectClass] isSubclassOfClass:aCls]) {
      // If graph element holds metadata about an ivar, it will be held in the name path, as early as possible
      if ([ivarNames containsObject:byIvar]) {
        return _FBGraphEdgeInvalid;
      }
    }
    return _FBGraphEdgeValid;
  };
}

_FBGraphEdgeFilterBlock _FBFilterBlockWithObjectIvarObjectRelation(Class fromClass, NSString *ivarName, Class toClass) {
  return ^(_FBObjectiveCGraphElement *fromObject,
           NSString *byIvar,
           Class toObjectOfClass) {
    if (toClass &&
        [toObjectOfClass isSubclassOfClass:toClass]) {
      return _FBFilterBlockWithObjectIvarRelation(fromClass, ivarName)(fromObject, byIvar, toObjectOfClass);
    }
    return _FBGraphEdgeValid;
  };
}

NSArray<_FBGraphEdgeFilterBlock> *_FBGetStandardGraphEdgeFilters() {
#if _INTERNAL_RCD_ENABLED
  static Class heldActionClass;
  static Class transitionContextClass;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    heldActionClass = NSClassFromString(@"UIHeldAction");
    transitionContextClass = NSClassFromString(@"_UIViewControllerOneToOneTransitionContext");
  });

  return @[_FBFilterBlockWithObjectIvarRelation([UIView class], @"_subviewCache"),
           _FBFilterBlockWithObjectIvarRelation(heldActionClass, @"m_target"),
           _FBFilterBlockWithObjectToManyIvarsRelation([UITouch class],
                                                      [NSSet setWithArray:@[@"_view",
                                                                            @"_gestureRecognizers",
                                                                            @"_window",
                                                                            @"_warpedIntoView"]]),
           _FBFilterBlockWithObjectToManyIvarsRelation(transitionContextClass,
                                                      [NSSet setWithArray:@[@"_toViewController",
                                                                            @"_fromViewController"]])];
#else
  return nil;
#endif // _INTERNAL_RCD_ENABLED
}
