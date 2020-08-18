//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_FBNodeEnumerator.h"

#import "_FBObjectiveCGraphElement.h"

@implementation _FBNodeEnumerator
{
  NSSet *_retainedObjectsSnapshot;
  NSEnumerator *_enumerator;
}

- (instancetype)initWithObject:(_FBObjectiveCGraphElement *)object
{
  if (self = [super init]) {
    _object = object;
  }

  return self;
}

- (_FBNodeEnumerator *)nextObject
{
  if (!_object) {
    return nil;
  } else if (!_retainedObjectsSnapshot) {
    _retainedObjectsSnapshot = [_object allRetainedObjects];
    _enumerator = [_retainedObjectsSnapshot objectEnumerator];
  }

  _FBObjectiveCGraphElement *next = [_enumerator nextObject];

  if (next) {
    return [[_FBNodeEnumerator alloc] initWithObject:next];
  }

  return nil;
}

- (BOOL)isEqual:(id)object
{
  if ([object isKindOfClass:[_FBNodeEnumerator class]]) {
    _FBNodeEnumerator *enumerator = (_FBNodeEnumerator *)object;
    return [self.object isEqual:enumerator.object];
  }

  return NO;
}

- (NSUInteger)hash
{
  return [self.object hash];
}

@end
