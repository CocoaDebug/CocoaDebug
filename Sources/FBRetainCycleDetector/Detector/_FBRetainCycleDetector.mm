//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <stack>
#import <unordered_map>
#import <unordered_set>

#import "_FBNodeEnumerator.h"
#import "_FBObjectiveCGraphElement.h"
#import "_FBObjectiveCObject.h"
#import "_FBRetainCycleDetector+Internal.h"
#import "_FBRetainCycleUtils.h"
#import "_FBStandardGraphEdgeFilters.h"

static const NSUInteger k_FBRetainCycleDetectorDefaultStackDepth = 10;

@implementation _FBRetainCycleDetector
{
  NSMutableArray *_candidates;
  _FBObjectGraphConfiguration *_configuration;
  NSMutableSet *_objectSet;
}

- (instancetype)initWithConfiguration:(_FBObjectGraphConfiguration *)configuration
{
  if (self = [super init]) {
    _configuration = configuration;
    _candidates = [NSMutableArray new];
    _objectSet = [NSMutableSet new];
  }

  return self;
}

- (instancetype)init
{
  return [self initWithConfiguration:
          [[_FBObjectGraphConfiguration alloc] initWithFilterBlocks:_FBGetStandardGraphEdgeFilters()
                                               shouldInspectTimers:YES]];
}

- (void)addCandidate:(id)candidate
{
  _FBObjectiveCGraphElement *graphElement = _FBWrapObjectGraphElement(nil, candidate, _configuration);
  if (graphElement) {
    [_candidates addObject:graphElement];
  }
}

- (NSSet<NSArray<_FBObjectiveCGraphElement *> *> *)findRetainCycles
{
  return [self findRetainCyclesWithMaxCycleLength:k_FBRetainCycleDetectorDefaultStackDepth];
}

- (NSSet<NSArray<_FBObjectiveCGraphElement *> *> *)findRetainCyclesWithMaxCycleLength:(NSUInteger)length
{
  NSMutableSet<NSArray<_FBObjectiveCGraphElement *> *> *allRetainCycles = [NSMutableSet new];
  for (_FBObjectiveCGraphElement *graphElement in _candidates) {
    NSSet<NSArray<_FBObjectiveCGraphElement *> *> *retainCycles = [self _findRetainCyclesInObject:graphElement
                                                                                      stackDepth:length];
    [allRetainCycles unionSet:retainCycles];
  }
  [_candidates removeAllObjects];
  [_objectSet removeAllObjects];

  // Filter cycles that have been broken down since we found them.
  // These are false-positive that were picked-up and are transient cycles.
  NSMutableSet<NSArray<_FBObjectiveCGraphElement *> *> *brokenCycles = [NSMutableSet set];
  for (NSArray<_FBObjectiveCGraphElement *> *itemCycle in allRetainCycles) {
    for (_FBObjectiveCGraphElement *element in itemCycle) {
      if (element.object == nil) {
        // At least one element of the cycle has been removed, thus breaking
        // the cycle.
        [brokenCycles addObject:itemCycle];
        break;
      }
    }
  }
  [allRetainCycles minusSet:brokenCycles];

  return allRetainCycles;
}

- (NSSet<NSArray<_FBObjectiveCGraphElement *> *> *)_findRetainCyclesInObject:(_FBObjectiveCGraphElement *)graphElement
                                                                 stackDepth:(NSUInteger)stackDepth
{
  NSMutableSet<NSArray<_FBObjectiveCGraphElement *> *> *retainCycles = [NSMutableSet new];
  _FBNodeEnumerator *wrappedObject = [[_FBNodeEnumerator alloc] initWithObject:graphElement];

  // We will be doing DFS over graph of objects

  // Stack will keep current path in the graph
  NSMutableArray<_FBNodeEnumerator *> *stack = [NSMutableArray new];

  // To make the search non-linear we will also keep
  // a set of previously visited nodes.
  NSMutableSet<_FBNodeEnumerator *> *objectsOnPath = [NSMutableSet new];

  // Let's start with the root
  [stack addObject:wrappedObject];

  while ([stack count] > 0) {
    // Algorithm creates many short-living objects. It can contribute to few
    // hundred megabytes memory jumps if not handled correctly, therefore
    // we're gonna drain the objects with our autoreleasepool.
    @autoreleasepool {
      // Take topmost node in stack and mark it as visited
      _FBNodeEnumerator *top = [stack lastObject];

      // We don't want to retraverse the same subtree
      if (![objectsOnPath containsObject:top]) {
        if ([_objectSet containsObject:@([top.object objectAddress])]) {
          [stack removeLastObject];
          continue;
        }
        // Add the object address to the set as an NSNumber to avoid
        // unnecessarily retaining the object
        [_objectSet addObject:@([top.object objectAddress])];
      }

      [objectsOnPath addObject:top];

      // Take next adjecent node to that child. Wrapper object can
      // persist iteration state. If we see that node again, it will
      // give us new adjacent node unless it runs out of them
      _FBNodeEnumerator *firstAdjacent = [top nextObject];
      if (firstAdjacent) {
        // Current node still has some adjacent not-visited nodes

        BOOL shouldPushToStack = NO;

        // Check if child was already seen in that path
        if ([objectsOnPath containsObject:firstAdjacent]) {
          // We have caught a retain cycle

          // Ignore the first element which is equal to firstAdjacent, use firstAdjacent
          // we're doing that because firstAdjacent has set all contexts, while its
          // first occurence could be a root without any context
          NSUInteger index = [stack indexOfObject:firstAdjacent];
          NSInteger length = [stack count] - index;

          if (index == NSNotFound) {
            // Object got deallocated between checking if it exists and grabbing its index
            shouldPushToStack = YES;
          } else {
            NSRange cycleRange = NSMakeRange(index, length);
            NSMutableArray<_FBNodeEnumerator *> *cycle = [[stack subarrayWithRange:cycleRange] mutableCopy];
            [cycle replaceObjectAtIndex:0 withObject:firstAdjacent];

            // 1. Unwrap the cycle
            // 2. Shift to lowest address (if we omit that, and the cycle is created by same class,
            //    we might have duplicates)
            // 3. Shift by class (lexicographically)

            [retainCycles addObject:[self _shiftToUnifiedCycle:[self _unwrapCycle:cycle]]];
          }
        } else {
          // Node is clear to check, add it to stack and continue
          shouldPushToStack = YES;
        }

        if (shouldPushToStack) {
          if ([stack count] < stackDepth) {
            [stack addObject:firstAdjacent];
          }
        }
      } else {
        // Node has no more adjacent nodes, it itself is done, move on
        [stack removeLastObject];
        [objectsOnPath removeObject:top];
      }
    }
  }
  return retainCycles;
}

// Turn all enumerators into object graph elements
- (NSArray<_FBObjectiveCGraphElement *> *)_unwrapCycle:(NSArray<_FBNodeEnumerator *> *)cycle
{
  NSMutableArray *unwrappedArray = [NSMutableArray new];
  for (_FBNodeEnumerator *wrapped in cycle) {
    [unwrappedArray addObject:wrapped.object];
  }

  return unwrappedArray;
}

// We do that so two cycles can be recognized as duplicates
- (NSArray<_FBObjectiveCGraphElement *> *)_shiftToUnifiedCycle:(NSArray<_FBObjectiveCGraphElement *> *)array
{
  return [self _shiftToLowestLexicographically:[self _shiftBufferToLowestAddress:array]];
}

- (NSArray<NSString *> *)_extractClassNamesFromGraphObjects:(NSArray<_FBObjectiveCGraphElement *> *)array
{
  NSMutableArray *arrayOfClassNames = [NSMutableArray new];

  for (_FBObjectiveCGraphElement *obj in array) {
    [arrayOfClassNames addObject:[obj classNameOrNull]];
  }

  return arrayOfClassNames;
}

/**
 The problem this circular shift solves is when we have few retain cycles for different runs that
 are technically the same cycle shifted. Object instances are different so if objects A and B
 create cycle, but on one run the address of A is lower than B, and on second B is lower than A,
 we will get a duplicate we have to get rid off.

 For that not to happen we use the circular shift that is smallest lexicographically when
 looking at class names.

 The version of this algorithm is pretty inefficient. It just compares given shifts and
 tries to find the smallest one. Doing something faster here is premature optimisation though
 since the retain cycles are usually arrays of length not bigger than 10 and there is not a lot
 of them (like 100 per run tops).

 If that ever occurs to be a problem for future reference use lexicographically minimal
 string rotation algorithm variation.
 */
- (NSArray<_FBObjectiveCGraphElement *> *)_shiftToLowestLexicographically:(NSArray<_FBObjectiveCGraphElement *> *)array
{
  NSArray<NSString *> *arrayOfClassNames = [self _extractClassNamesFromGraphObjects:array];

  NSArray<NSString *> *copiedArray = [arrayOfClassNames arrayByAddingObjectsFromArray:arrayOfClassNames];
  NSUInteger originalLength = [arrayOfClassNames count];

  NSArray *currentMinimalArray = arrayOfClassNames;
  NSUInteger minimumIndex = 0;

  for (NSUInteger i = 0; i < originalLength; ++i) {
    NSArray<NSString *> *nextSubarray = [copiedArray subarrayWithRange:NSMakeRange(i, originalLength)];
    if ([self _compareStringArray:currentMinimalArray
                        withArray:nextSubarray] == NSOrderedDescending) {
      currentMinimalArray = nextSubarray;
      minimumIndex = i;
    }
  }

  NSRange minimumArrayRange = NSMakeRange(minimumIndex,
                                          [array count] - minimumIndex);
  NSMutableArray<_FBObjectiveCGraphElement *> *minimumArray = [[array subarrayWithRange:minimumArrayRange] mutableCopy];
  [minimumArray addObjectsFromArray:[array subarrayWithRange:NSMakeRange(0, minimumIndex)]];
  return minimumArray;
}

- (NSComparisonResult)_compareStringArray:(NSArray<NSString *> *)a1
                                withArray:(NSArray<NSString *> *)a2
{
  // a1 and a2 should be the same length
  for (NSUInteger i = 0; i < [a1 count]; ++i) {
    NSString *s1 = a1[i];
    NSString *s2 = a2[i];

    NSComparisonResult comparision = [s1 compare:s2];
    if (comparision != NSOrderedSame) {
      return comparision;
    }
  }

  return NSOrderedSame;
}

- (NSArray<_FBObjectiveCGraphElement *> *)_shiftBufferToLowestAddress:(NSArray<_FBObjectiveCGraphElement *> *)cycle
{
  NSUInteger idx = 0, lowestAddressIndex = 0;
  size_t lowestAddress = NSUIntegerMax;
  for (_FBObjectiveCGraphElement *obj in cycle) {
    if ([obj objectAddress] < lowestAddress) {
      lowestAddress = [obj objectAddress];
      lowestAddressIndex = idx;
    }

    idx++;
  }

  if (lowestAddressIndex == 0) {
    return cycle;
  }

  NSRange cycleRange = NSMakeRange(lowestAddressIndex, [cycle count] - lowestAddressIndex);
  NSMutableArray<_FBObjectiveCGraphElement *> *array = [[cycle subarrayWithRange:cycleRange] mutableCopy];
  [array addObjectsFromArray:[cycle subarrayWithRange:NSMakeRange(0, lowestAddressIndex)]];
  return array;
}

@end
