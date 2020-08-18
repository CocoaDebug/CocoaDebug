//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_GPBArray.h"

@class _GPBMessage;

//%PDDM-DEFINE DECLARE_ARRAY_EXTRAS()
//%ARRAY_INTERFACE_EXTRAS(Int32, int32_t)
//%ARRAY_INTERFACE_EXTRAS(UInt32, uint32_t)
//%ARRAY_INTERFACE_EXTRAS(Int64, int64_t)
//%ARRAY_INTERFACE_EXTRAS(UInt64, uint64_t)
//%ARRAY_INTERFACE_EXTRAS(Float, float)
//%ARRAY_INTERFACE_EXTRAS(Double, double)
//%ARRAY_INTERFACE_EXTRAS(Bool, BOOL)
//%ARRAY_INTERFACE_EXTRAS(Enum, int32_t)

//%PDDM-DEFINE ARRAY_INTERFACE_EXTRAS(NAME, TYPE)
//%#pragma mark - NAME
//%
//%@interface _GPB##NAME##Array () {
//% @package
//%  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
//%}
//%@end
//%

//%PDDM-EXPAND DECLARE_ARRAY_EXTRAS()
// This block of code is generated, do not edit it directly.

#pragma mark - Int32

@interface _GPBInt32Array () {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

#pragma mark - UInt32

@interface _GPBUInt32Array () {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

#pragma mark - Int64

@interface _GPBInt64Array () {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

#pragma mark - UInt64

@interface _GPBUInt64Array () {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

#pragma mark - Float

@interface _GPBFloatArray () {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

#pragma mark - Double

@interface _GPBDoubleArray () {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

#pragma mark - Bool

@interface _GPBBoolArray () {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

#pragma mark - Enum

@interface _GPBEnumArray () {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

//%PDDM-EXPAND-END DECLARE_ARRAY_EXTRAS()

#pragma mark - NSArray Subclass

@interface _GPBAutocreatedArray : NSMutableArray {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end
