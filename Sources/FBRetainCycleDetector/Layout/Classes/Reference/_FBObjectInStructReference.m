//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_FBObjectInStructReference.h"

#import "_FBClassStrongLayoutHelpers.h"

@implementation _FBObjectInStructReference
{
  NSUInteger _index;
  NSArray<NSString *> *_namePath;
}

- (instancetype)initWithIndex:(NSUInteger)index
                     namePath:(NSArray<NSString *> *)namePath
{
  if (self = [super init]) {
    _index = index;
    _namePath = namePath;
  }

  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"[in_struct; index: %td]", _index];
}

#pragma mark - _FBObjectReference

- (id)objectReferenceFromObject:(id)object
{
  return _FBExtractObjectByOffset(object, _index);
}

- (NSUInteger)indexInIvarLayout
{
  return _index;
}

- (NSArray<NSString *> *)namePath
{
  return _namePath;
}

@end
