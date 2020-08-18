//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_FBRetainCycleUtils.h"

#import <objc/runtime.h>

#import "_FBBlockStrongLayout.h"
#import "_FBClassStrongLayout.h"
#import "_FBObjectiveCBlock.h"
#import "_FBObjectiveCGraphElement.h"
#import "_FBObjectiveCNSCFTimer.h"
#import "_FBObjectiveCObject.h"
#import "_FBObjectGraphConfiguration.h"

static BOOL _ShouldBreakGraphEdge(_FBObjectGraphConfiguration *configuration,
                                  _FBObjectiveCGraphElement *fromObject,
                                  NSString *byIvar,
                                  Class toObjectOfClass) {
  for (_FBGraphEdgeFilterBlock filterBlock in configuration.filterBlocks) {
    if (filterBlock(fromObject, byIvar, toObjectOfClass) == _FBGraphEdgeInvalid) {
      return YES;
    }
  }

  return NO;
}

_FBObjectiveCGraphElement *_FBWrapObjectGraphElementWithContext(_FBObjectiveCGraphElement *sourceElement,
                                                              id object,
                                                              _FBObjectGraphConfiguration *configuration,
                                                              NSArray<NSString *> *namePath) {
  if (_ShouldBreakGraphEdge(configuration, sourceElement, [namePath firstObject], object_getClass(object))) {
    return nil;
  }
  _FBObjectiveCGraphElement *newElement;
  if (_FBObjectIsBlock((__bridge void *)object)) {
    newElement = [[_FBObjectiveCBlock alloc] initWithObject:object
                                             configuration:configuration
                                                  namePath:namePath];
  } else {
    if ([object_getClass(object) isSubclassOfClass:[NSTimer class]] &&
        configuration.shouldInspectTimers) {
      newElement = [[_FBObjectiveCNSCFTimer alloc] initWithObject:object
                                                   configuration:configuration
                                                        namePath:namePath];
    } else {
      newElement = [[_FBObjectiveCObject alloc] initWithObject:object
                                                configuration:configuration
                                                     namePath:namePath];
    }
  }
  return (configuration && configuration.transformerBlock) ? configuration.transformerBlock(newElement) : newElement;
}

_FBObjectiveCGraphElement *_FBWrapObjectGraphElement(_FBObjectiveCGraphElement *sourceElement,
                                                   id object,
                                                   _FBObjectGraphConfiguration *configuration) {
  return _FBWrapObjectGraphElementWithContext(sourceElement, object, configuration, nil);
}
