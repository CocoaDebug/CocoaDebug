//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_FBIvarReference.h"

@implementation _FBIvarReference

- (instancetype)initWithIvar:(Ivar)ivar
{
  if (self = [super init]) {
    _name = @(ivar_getName(ivar));
    _type = [self _convertEncodingTo_Type:ivar_getTypeEncoding(ivar)];
    _offset = ivar_getOffset(ivar);
    _index = _offset / sizeof(void *);
    _ivar = ivar;
  }

  return self;
}

- (_FB_Type)_convertEncodingTo_Type:(const char *)typeEncoding
{
  if (typeEncoding[0] == '{') {
    return _FBStruct_Type;
  }

  if (typeEncoding[0] == '@') {
    // It's an object or block

    // Let's try to determine if it's a block. Blocks tend to have
    // @? typeEncoding. Docs state that it's undefined type, so
    // we should still verify that ivar with that type is a block
    if (strncmp(typeEncoding, "@?", 2) == 0) {
      return _FBBlock_Type;
    }

    return _FBObject_Type;
  }

  return _FBUnknown_Type;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"[%@, index: %lu]", _name, (unsigned long)_index];
}

#pragma mark - _FBObjectReference

- (NSUInteger)indexInIvarLayout
{
  return _index;
}

- (id)objectReferenceFromObject:(id)object
{
  return object_getIvar(object, _ivar);
}

- (NSArray<NSString *> *)namePath
{
  return @[@(ivar_getName(_ivar))];
}

@end
