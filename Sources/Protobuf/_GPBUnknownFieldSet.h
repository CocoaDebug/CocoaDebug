//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

@class _GPBUnknownField;

NS_ASSUME_NONNULL_BEGIN

/**
 * A collection of unknown fields. Fields parsed from the binary representation
 * of a message that are unknown end up in an instance of this set. This only
 * applies for files declared with the "proto2" syntax. Files declared with the
 * "proto3" syntax discard the unknown values.
 **/
@interface _GPBUnknownFieldSet : NSObject<NSCopying>

/**
 * Tests to see if the given field number has a value.
 *
 * @param number The field number to check.
 *
 * @return YES if there is an unknown field for the given field number.
 **/
- (BOOL)hasField:(int32_t)number;

/**
 * Fetches the _GPBUnknownField for the given field number.
 *
 * @param number The field number to look up.
 *
 * @return The _GPBUnknownField or nil if none found.
 **/
- (nullable _GPBUnknownField *)getField:(int32_t)number;

/**
 * @return The number of fields in this set.
 **/
- (NSUInteger)countOfFields;

/**
 * Adds the given field to the set.
 *
 * @param field The field to add to the set.
 **/
- (void)addField:(_GPBUnknownField *)field;

/**
 * @return An array of the _GPBUnknownFields sorted by the field numbers.
 **/
- (NSArray<_GPBUnknownField *> *)sortedFields;

@end

NS_ASSUME_NONNULL_END
