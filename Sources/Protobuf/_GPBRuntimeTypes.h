//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "_GPBBootstrap.h"

@class _GPBEnumDescriptor;
@class _GPBMessage;
@class _GPBInt32Array;

/**
 * Verifies that a given value can be represented by an enum type.
 * */
typedef BOOL (*_GPBEnumValidationFunc)(int32_t);

/**
 * Fetches an EnumDescriptor.
 * */
typedef _GPBEnumDescriptor *(*_GPBEnumDescriptorFunc)(void);

/**
 * Magic value used at runtime to indicate an enum value that wasn't know at
 * compile time.
 * */
enum {
  k_GPBUnrecognizedEnumeratorValue = (int32_t)0xFBADBEEF,
};

/**
 * A union for storing all possible Protobuf values. Note that owner is
 * responsible for memory management of object types.
 * */
typedef union {
  BOOL valueBool;
  int32_t valueInt32;
  int64_t valueInt64;
  uint32_t valueUInt32;
  uint64_t valueUInt64;
  float valueFloat;
  double valueDouble;
  _GPB_UNSAFE_UNRETAINED NSData *valueData;
  _GPB_UNSAFE_UNRETAINED NSString *valueString;
  _GPB_UNSAFE_UNRETAINED _GPBMessage *valueMessage;
  int32_t valueEnum;
} _GPBGenericValue;

/**
 * Enum listing the possible data types that a field can contain.
 *
 * @note Do not change the order of this enum (or add things to it) without
 *       thinking about it very carefully. There are several things that depend
 *       on the order.
 * */
typedef NS_ENUM(uint8_t, _GPBDataType) {
  /** Field contains boolean value(s). */
  _GPBDataTypeBool = 0,
  /** Field contains unsigned 4 byte value(s). */
  _GPBDataTypeFixed32,
  /** Field contains signed 4 byte value(s). */
  _GPBDataTypeSFixed32,
  /** Field contains float value(s). */
  _GPBDataTypeFloat,
  /** Field contains unsigned 8 byte value(s). */
  _GPBDataTypeFixed64,
  /** Field contains signed 8 byte value(s). */
  _GPBDataTypeSFixed64,
  /** Field contains double value(s). */
  _GPBDataTypeDouble,
  /**
   * Field contains variable length value(s). Inefficient for encoding negative
   * numbers – if your field is likely to have negative values, use
   * _GPBDataTypeSInt32 instead.
   **/
  _GPBDataTypeInt32,
  /**
   * Field contains variable length value(s). Inefficient for encoding negative
   * numbers – if your field is likely to have negative values, use
   * _GPBDataTypeSInt64 instead.
   **/
  _GPBDataTypeInt64,
  /** Field contains signed variable length integer value(s). */
  _GPBDataTypeSInt32,
  /** Field contains signed variable length integer value(s). */
  _GPBDataTypeSInt64,
  /** Field contains unsigned variable length integer value(s). */
  _GPBDataTypeUInt32,
  /** Field contains unsigned variable length integer value(s). */
  _GPBDataTypeUInt64,
  /** Field contains an arbitrary sequence of bytes. */
  _GPBDataTypeBytes,
  /** Field contains UTF-8 encoded or 7-bit ASCII text. */
  _GPBDataTypeString,
  /** Field contains message type(s). */
  _GPBDataTypeMessage,
  /** Field contains message type(s). */
  _GPBDataTypeGroup,
  /** Field contains enum value(s). */
  _GPBDataTypeEnum,
};

enum {
  /**
   * A count of the number of types in _GPBDataType. Separated out from the
   * _GPBDataType enum to avoid warnings regarding not handling _GPBDataType_Count
   * in switch statements.
   **/
  _GPBDataType_Count = _GPBDataTypeEnum + 1
};

/** An extension range. */
typedef struct _GPBExtensionRange {
  /** Inclusive. */
  uint32_t start;
  /** Exclusive. */
  uint32_t end;
} _GPBExtensionRange;
