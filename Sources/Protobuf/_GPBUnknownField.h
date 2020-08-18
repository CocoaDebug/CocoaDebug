//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

@class _GPBCodedOutputStream;
@class _GPBUInt32Array;
@class _GPBUInt64Array;
@class _GPBUnknownFieldSet;

NS_ASSUME_NONNULL_BEGIN
/**
 * Store an unknown field. These are used in conjunction with
 * _GPBUnknownFieldSet.
 **/
@interface _GPBUnknownField : NSObject<NSCopying>

/** Initialize a field with the given number. */
- (instancetype)initWithNumber:(int32_t)number;

/** The field number the data is stored under. */
@property(nonatomic, readonly, assign) int32_t number;

/** An array of varint values for this field. */
@property(nonatomic, readonly, strong) _GPBUInt64Array *varintList;

/** An array of fixed32 values for this field. */
@property(nonatomic, readonly, strong) _GPBUInt32Array *fixed32List;

/** An array of fixed64 values for this field. */
@property(nonatomic, readonly, strong) _GPBUInt64Array *fixed64List;

/** An array of data values for this field. */
@property(nonatomic, readonly, strong) NSArray<NSData*> *lengthDelimitedList;

/** An array of groups of values for this field. */
@property(nonatomic, readonly, strong) NSArray<_GPBUnknownFieldSet*> *groupList;

/**
 * Add a value to the varintList.
 *
 * @param value The value to add.
 **/
- (void)addVarint:(uint64_t)value;
/**
 * Add a value to the fixed32List.
 *
 * @param value The value to add.
 **/
- (void)addFixed32:(uint32_t)value;
/**
 * Add a value to the fixed64List.
 *
 * @param value The value to add.
 **/
- (void)addFixed64:(uint64_t)value;
/**
 * Add a value to the lengthDelimitedList.
 *
 * @param value The value to add.
 **/
- (void)addLengthDelimited:(NSData *)value;
/**
 * Add a value to the groupList.
 *
 * @param value The value to add.
 **/
- (void)addGroup:(_GPBUnknownFieldSet *)value;

@end

NS_ASSUME_NONNULL_END
