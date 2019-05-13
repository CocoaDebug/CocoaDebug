// Protocol Buffers - Google's data interchange format
// Copyright 2015 Google Inc.  All rights reserved.
// https://developers.google.com/protocol-buffers/
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
// copyright notice, this list of conditions and the following disclaimer
// in the documentation and/or other materials provided with the
// distribution.
//     * Neither the name of Google Inc. nor the names of its
// contributors may be used to endorse or promote products derived from
// this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <Foundation/Foundation.h>

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(_GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define _GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if _GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/_Any.pbobjc.h>
 #import <Protobuf/_Duration.pbobjc.h>
 #import <Protobuf/_Timestamp.pbobjc.h>
#else
 #import "_Any.pbobjc.h"
 #import "_Duration.pbobjc.h"
 #import "_Timestamp.pbobjc.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Errors

/** NSError domain used for errors. */
extern NSString *const _GPBWellKnownTypesErrorDomain;

/** Error code for NSError with _GPBWellKnownTypesErrorDomain. */
typedef NS_ENUM(NSInteger, _GPBWellKnownTypesErrorCode) {
  /** The type_url could not be computed for the requested _GPBMessage class. */
  _GPBWellKnownTypesErrorCodeFailedToComputeTypeURL = -100,
  /** type_url in a Any doesn’t match that of the requested _GPBMessage class. */
  _GPBWellKnownTypesErrorCodeTypeURLMismatch = -101,
};

#pragma mark - _GPBTimestamp

/**
 * Category for _GPBTimestamp to work with standard Foundation time/date types.
 **/
@interface _GPBTimestamp (GBPWellKnownTypes)

/** The NSDate representation of this _GPBTimestamp. */
@property(nonatomic, readwrite, strong) NSDate *date;

/**
 * The NSTimeInterval representation of this _GPBTimestamp.
 *
 * @note: Not all second/nanos combinations can be represented in a
 * NSTimeInterval, so getting this could be a lossy transform.
 **/
@property(nonatomic, readwrite) NSTimeInterval timeIntervalSince1970;

/**
 * Initializes a _GPBTimestamp with the given NSDate.
 *
 * @param date The date to configure the _GPBTimestamp with.
 *
 * @return A newly initialized _GPBTimestamp.
 **/
- (instancetype)initWithDate:(NSDate *)date;

/**
 * Initializes a _GPBTimestamp with the given NSTimeInterval.
 *
 * @param timeIntervalSince1970 Time interval to configure the _GPBTimestamp with.
 *
 * @return A newly initialized _GPBTimestamp.
 **/
- (instancetype)initWithTimeIntervalSince1970:(NSTimeInterval)timeIntervalSince1970;

@end

#pragma mark - _GPBDuration

/**
 * Category for _GPBDuration to work with standard Foundation time type.
 **/
@interface _GPBDuration (GBPWellKnownTypes)

/**
 * The NSTimeInterval representation of this _GPBDuration.
 *
 * @note: Not all second/nanos combinations can be represented in a
 * NSTimeInterval, so getting this could be a lossy transform.
 **/
@property(nonatomic, readwrite) NSTimeInterval timeInterval;

/**
 * Initializes a _GPBDuration with the given NSTimeInterval.
 *
 * @param timeInterval Time interval to configure the _GPBDuration with.
 *
 * @return A newly initialized _GPBDuration.
 **/
- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval;

// These next two methods are deprecated because GBPDuration has no need of a
// "base" time. The older methods were about symmetry with GBPTimestamp, but
// the unix epoch usage is too confusing.

/** Deprecated, use timeInterval instead. */
@property(nonatomic, readwrite) NSTimeInterval timeIntervalSince1970
    __attribute__((deprecated("Use timeInterval")));
/** Deprecated, use initWithTimeInterval: instead. */
- (instancetype)initWithTimeIntervalSince1970:(NSTimeInterval)timeIntervalSince1970
    __attribute__((deprecated("Use initWithTimeInterval:")));

@end

#pragma mark - _GPBAny

/**
 * Category for _GPBAny to help work with the message within the object.
 **/
@interface _GPBAny (GBPWellKnownTypes)

/**
 * Convenience method to create a _GPBAny containing the serialized message.
 * This uses type.googleapis.com/ as the type_url's prefix.
 *
 * @param message  The message to be packed into the _GPBAny.
 * @param errorPtr Pointer to an error that will be populated if something goes
 *                 wrong.
 *
 * @return A newly configured _GPBAny with the given message, or nil on failure.
 */
+ (nullable instancetype)anyWithMessage:(nonnull _GPBMessage *)message
                                  error:(NSError **)errorPtr;

/**
 * Convenience method to create a _GPBAny containing the serialized message.
 *
 * @param message       The message to be packed into the _GPBAny.
 * @param typeURLPrefix The URL prefix to apply for type_url.
 * @param errorPtr      Pointer to an error that will be populated if something
 *                      goes wrong.
 *
 * @return A newly configured _GPBAny with the given message, or nil on failure.
 */
+ (nullable instancetype)anyWithMessage:(nonnull _GPBMessage *)message
                          typeURLPrefix:(nonnull NSString *)typeURLPrefix
                                  error:(NSError **)errorPtr;

/**
 * Initializes a _GPBAny to contain the serialized message. This uses
 * type.googleapis.com/ as the type_url's prefix.
 *
 * @param message  The message to be packed into the _GPBAny.
 * @param errorPtr Pointer to an error that will be populated if something goes
 *                 wrong.
 *
 * @return A newly configured _GPBAny with the given message, or nil on failure.
 */
- (nullable instancetype)initWithMessage:(nonnull _GPBMessage *)message
                                   error:(NSError **)errorPtr;

/**
 * Initializes a _GPBAny to contain the serialized message.
 *
 * @param message       The message to be packed into the _GPBAny.
 * @param typeURLPrefix The URL prefix to apply for type_url.
 * @param errorPtr      Pointer to an error that will be populated if something
 *                      goes wrong.
 *
 * @return A newly configured _GPBAny with the given message, or nil on failure.
 */
- (nullable instancetype)initWithMessage:(nonnull _GPBMessage *)message
                           typeURLPrefix:(nonnull NSString *)typeURLPrefix
                                   error:(NSError **)errorPtr;

/**
 * Packs the serialized message into this _GPBAny. This uses
 * type.googleapis.com/ as the type_url's prefix.
 *
 * @param message  The message to be packed into the _GPBAny.
 * @param errorPtr Pointer to an error that will be populated if something goes
 *                 wrong.
 *
 * @return Whether the packing was successful or not.
 */
- (BOOL)packWithMessage:(nonnull _GPBMessage *)message
                  error:(NSError **)errorPtr;

/**
 * Packs the serialized message into this _GPBAny.
 *
 * @param message       The message to be packed into the _GPBAny.
 * @param typeURLPrefix The URL prefix to apply for type_url.
 * @param errorPtr      Pointer to an error that will be populated if something
 *                      goes wrong.
 *
 * @return Whether the packing was successful or not.
 */
- (BOOL)packWithMessage:(nonnull _GPBMessage *)message
          typeURLPrefix:(nonnull NSString *)typeURLPrefix
                  error:(NSError **)errorPtr;

/**
 * Unpacks the serialized message as if it was an instance of the given class.
 *
 * @note When checking type_url, the base URL is not checked, only the fully
 *       qualified name.
 *
 * @param messageClass The class to use to deserialize the contained message.
 * @param errorPtr     Pointer to an error that will be populated if something
 *                     goes wrong.
 *
 * @return An instance of the given class populated with the contained data, or
 *         nil on failure.
 */
- (nullable _GPBMessage *)unpackMessageClass:(Class)messageClass
                                      error:(NSError **)errorPtr;

@end

NS_ASSUME_NONNULL_END
