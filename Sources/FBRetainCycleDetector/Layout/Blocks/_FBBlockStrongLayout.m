//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#if __has_feature(objc_arc)
#error This file must be compiled with MRR. Use -fno-objc-arc flag.
#endif

#import "_FBBlockStrongLayout.h"

#import <objc/runtime.h>

#import "_FBBlockInterface.h"
#import "_FBBlockStrongRelationDetector.h"

/**
 We will be blackboxing variables that the block holds with our own custom class,
 and we will check which of them were retained.

 The idea is based on the approach Circle uses:
 https://github.com/mikeash/Circle
 https://github.com/mikeash/Circle/blob/master/Circle/CircleIVarLayout.m
 */
static NSIndexSet *_GetBlockStrongLayout(void *block) {
  struct BlockLiteral *blockLiteral = block;

  /**
   BLOCK_HAS_CTOR - Block has a C++ constructor/destructor, which gives us a good chance it retains
   objects that are not pointer aligned, so omit them.

   !BLOCK_HAS_COPY_DISPOSE - Block doesn't have a dispose function, so it does not retain objects and
   we are not able to blackbox it.
   */
  if ((blockLiteral->flags & BLOCK_HAS_CTOR)
      || !(blockLiteral->flags & BLOCK_HAS_COPY_DISPOSE)) {
    return nil;
  }

  void (*dispose_helper)(void *src) = blockLiteral->descriptor->dispose_helper;
  const size_t ptrSize = sizeof(void *);

  // Figure out the number of pointers it takes to fill out the object, rounding up.
  const size_t elements = (blockLiteral->descriptor->size + ptrSize - 1) / ptrSize;

  // Create a fake object of the appropriate length.
  void *obj[elements];
  void *detectors[elements];

  for (size_t i = 0; i < elements; ++i) {
    _FBBlockStrongRelationDetector *detector = [_FBBlockStrongRelationDetector new];
    obj[i] = detectors[i] = detector;
  }

  @autoreleasepool {
    dispose_helper(obj);
  }

  // Run through the release detectors and add each one that got released to the object's
  // strong ivar layout.
  NSMutableIndexSet *layout = [NSMutableIndexSet indexSet];

  for (size_t i = 0; i < elements; ++i) {
    _FBBlockStrongRelationDetector *detector = (_FBBlockStrongRelationDetector *)(detectors[i]);
    if (detector.isStrong) {
      [layout addIndex:i];
    }

    // Destroy detectors
    [detector trueRelease];
  }

  return layout;
}

NSArray *_FBGetBlockStrongReferences(void *block) {
  if (!_FBObjectIsBlock(block)) {
    return nil;
  }
  
  NSMutableArray *results = [NSMutableArray new];

  void **blockReference = block;
  NSIndexSet *strongLayout = _GetBlockStrongLayout(block);
  [strongLayout enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    void **reference = &blockReference[idx];

    if (reference && (*reference)) {
      id object = (id)(*reference);

      if (object) {
        [results addObject:object];
      }
    }
  }];

  return [results autorelease];
}

static Class _BlockClass() {
  static dispatch_once_t onceToken;
  static Class blockClass;
  dispatch_once(&onceToken, ^{
      void (^testBlock)(void) = [^{} copy];
    blockClass = [testBlock class];
    while(class_getSuperclass(blockClass) && class_getSuperclass(blockClass) != [NSObject class]) {
      blockClass = class_getSuperclass(blockClass);
    }
    [testBlock release];
  });
  return blockClass;
}

BOOL _FBObjectIsBlock(void *object) {
  Class blockClass = _BlockClass();
  
  Class candidate = object_getClass((__bridge id)object);
  return [candidate isSubclassOfClass:blockClass];
}
