//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_FBObjectiveCNSCFTimer.h"

#import <objc/runtime.h>

#import "_FBRetainCycleDetector.h"
#import "_FBRetainCycleUtils.h"

@implementation _FBObjectiveCNSCFTimer

#if _INTERNAL_RCD_ENABLED

typedef struct {
  long _unknown; // This is always 1
  id target;
  SEL selector;
  NSDictionary *userInfo;
} __FBNSCFTimerInfo_Struct;

- (NSSet *)allRetainedObjects
{
  // Let's retain our timer
  __attribute__((objc_precise_lifetime)) NSTimer *timer = self.object;

  if (!timer) {
    return nil;
  }

  NSMutableSet *retained = [[super allRetainedObjects] mutableCopy];

  CFRunLoopTimerContext context;
  CFRunLoopTimerGetContext((CFRunLoopTimerRef)timer, &context);

  // If it has a retain function, let's assume it retains strongly
  if (context.info && context.retain) {
    __FBNSCFTimerInfo_Struct info_Struct = *(__FBNSCFTimerInfo_Struct *)(context.info);
    if (info_Struct.target) {
      _FBObjectiveCGraphElement *element = _FBWrapObjectGraphElementWithContext(self, info_Struct.target, self.configuration, @[@"target"]);
      if (element) {
        [retained addObject:element];
      }
    }
    if (info_Struct.userInfo) {
      _FBObjectiveCGraphElement *element = _FBWrapObjectGraphElementWithContext(self, info_Struct.userInfo, self.configuration, @[@"userInfo"]);
      if (element) {
        [retained addObject:element];
      }
    }
  }

  return retained;
}

#endif // _INTERNAL_RCD_ENABLED

@end
