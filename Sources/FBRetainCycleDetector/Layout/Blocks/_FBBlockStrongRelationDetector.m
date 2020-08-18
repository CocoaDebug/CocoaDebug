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

#import "_FBBlockStrongRelationDetector.h"

#import <objc/runtime.h>

static void byref_keep_nop(struct _block_byref_block *dst, struct _block_byref_block *src) {}
static void byref_dispose_nop(struct _block_byref_block *param) {}

@implementation _FBBlockStrongRelationDetector

- (oneway void)release
{
  _strong = YES;
}

- (id)retain
{
  return self;
}

+ (id)alloc
{
  _FBBlockStrongRelationDetector *obj = [super alloc];

  // Setting up block fakery
  obj->forwarding = obj;
  obj->byref_keep = byref_keep_nop;
  obj->byref_dispose = byref_dispose_nop;

  return obj;
}

- (oneway void)trueRelease
{
  [super release];
}

- (void *)forwarding
{
  return self->forwarding;
}

@end
