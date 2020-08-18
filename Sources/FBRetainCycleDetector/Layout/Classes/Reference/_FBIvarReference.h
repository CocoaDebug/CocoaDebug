//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <objc/runtime.h>

#import <Foundation/Foundation.h>

#import "_FBObjectReference.h"

typedef NS_ENUM(NSUInteger, _FB_Type) {
  _FBObject_Type,
  _FBBlock_Type,
  _FBStruct_Type,
  _FBUnknown_Type,
};

@interface _FBIvarReference : NSObject <_FBObjectReference>

@property (nonatomic, copy, readonly, nullable) NSString *name;
@property (nonatomic, readonly) _FB_Type type;
@property (nonatomic, readonly) ptrdiff_t offset;
@property (nonatomic, readonly) NSUInteger index;
@property (nonatomic, readonly, nonnull) Ivar ivar;

- (nonnull instancetype)initWithIvar:(nonnull Ivar)ivar;

@end
