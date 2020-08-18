//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

@class _GPBMessage;
@class _GPBExtensionRegistry;

NS_ASSUME_NONNULL_BEGIN

CF_EXTERN_C_BEGIN

/**
 * @c _GPBCodedInputStream exception name. Exceptions raised from
 * @c _GPBCodedInputStream contain an underlying error in the userInfo dictionary
 * under the _GPBCodedInputStreamUnderlyingErrorKey key.
 **/
extern NSString *const _GPBCodedInputStreamException;

/** The key under which the underlying NSError from the exception is stored. */
extern NSString *const _GPBCodedInputStreamUnderlyingErrorKey;

/** NSError domain used for @c _GPBCodedInputStream errors. */
extern NSString *const _GPBCodedInputStreamErrorDomain;

/**
 * Error code for NSError with @c _GPBCodedInputStreamErrorDomain.
 **/
typedef NS_ENUM(NSInteger, _GPBCodedInputStreamErrorCode) {
  /** The size does not fit in the remaining bytes to be read. */
  _GPBCodedInputStreamErrorInvalidSize = -100,
  /** Attempted to read beyond the subsection limit. */
  _GPBCodedInputStreamErrorSubsectionLimitReached = -101,
  /** The requested subsection limit is invalid. */
  _GPBCodedInputStreamErrorInvalidSubsectionLimit = -102,
  /** Invalid tag read. */
  _GPBCodedInputStreamErrorInvalidTag = -103,
  /** Invalid UTF-8 character in a string. */
  _GPBCodedInputStreamErrorInvalidUTF8 = -104,
  /** Invalid VarInt read. */
  _GPBCodedInputStreamErrorInvalidVarInt = -105,
  /** The maximum recursion depth of messages was exceeded. */
  _GPBCodedInputStreamErrorRecursionDepthExceeded = -106,
};

CF_EXTERN_C_END

/**
 * Reads and decodes protocol message fields.
 *
 * The common uses of protocol buffers shouldn't need to use this class.
 * @c _GPBMessage's provide a @c +parseFromData:error: and
 * @c +parseFromData:extensionRegistry:error: method that will decode a
 * message for you.
 *
 * @note Subclassing of @c _GPBCodedInputStream is NOT supported.
 **/
@interface _GPBCodedInputStream : NSObject

/**
 * Creates a new stream wrapping some data.
 *
 * @param data The data to wrap inside the stream.
 *
 * @return A newly instanced _GPBCodedInputStream.
 **/
+ (instancetype)streamWithData:(NSData *)data;

/**
 * Initializes a stream wrapping some data.
 *
 * @param data The data to wrap inside the stream.
 *
 * @return A newly initialized _GPBCodedInputStream.
 **/
- (instancetype)initWithData:(NSData *)data;

/**
 * Attempts to read a field tag, returning zero if we have reached EOF.
 * Protocol message parsers use this to read tags, since a protocol message
 * may legally end wherever a tag occurs, and zero is not a valid tag number.
 *
 * @return The field tag, or zero if EOF was reached.
 **/
- (int32_t)readTag;

/**
 * @return A double read from the stream.
 **/
- (double)readDouble;
/**
 * @return A float read from the stream.
 **/
- (float)readFloat;
/**
 * @return A uint64 read from the stream.
 **/
- (uint64_t)readUInt64;
/**
 * @return A uint32 read from the stream.
 **/
- (uint32_t)readUInt32;
/**
 * @return An int64 read from the stream.
 **/
- (int64_t)readInt64;
/**
 * @return An int32 read from the stream.
 **/
- (int32_t)readInt32;
/**
 * @return A fixed64 read from the stream.
 **/
- (uint64_t)readFixed64;
/**
 * @return A fixed32 read from the stream.
 **/
- (uint32_t)readFixed32;
/**
 * @return An enum read from the stream.
 **/
- (int32_t)readEnum;
/**
 * @return A sfixed32 read from the stream.
 **/
- (int32_t)readSFixed32;
/**
 * @return A fixed64 read from the stream.
 **/
- (int64_t)readSFixed64;
/**
 * @return A sint32 read from the stream.
 **/
- (int32_t)readSInt32;
/**
 * @return A sint64 read from the stream.
 **/
- (int64_t)readSInt64;
/**
 * @return A boolean read from the stream.
 **/
- (BOOL)readBool;
/**
 * @return A string read from the stream.
 **/
- (NSString *)readString;
/**
 * @return Data read from the stream.
 **/
- (NSData *)readBytes;

/**
 * Read an embedded message field value from the stream.
 *
 * @param message           The message to set fields on as they are read.
 * @param extensionRegistry An optional extension registry to use to lookup
 *                          extensions for message.
 **/
- (void)readMessage:(_GPBMessage *)message
  extensionRegistry:(nullable _GPBExtensionRegistry *)extensionRegistry;

/**
 * Reads and discards a single field, given its tag value.
 *
 * @param tag The tag number of the field to skip.
 *
 * @return NO if the tag is an endgroup tag (in which case nothing is skipped),
 *         YES in all other cases.
 **/
- (BOOL)skipField:(int32_t)tag;

/**
 * Reads and discards an entire message. This will read either until EOF or
 * until an endgroup tag, whichever comes first.
 **/
- (void)skipMessage;

/**
 * Check to see if the logical end of the stream has been reached.
 *
 * @note This can return NO when there is no more data, but the current parsing
 *       expected more data.
 *
 * @return YES if the logical end of the stream has been reached, NO otherwise.
 **/
- (BOOL)isAtEnd;

/**
 * @return The offset into the stream.
 **/
- (size_t)position;

/**
 * Moves the limit to the given byte offset starting at the current location.
 *
 * @exception _GPBCodedInputStreamException If the requested bytes exceeed the
 *            current limit.
 *
 * @param byteLimit The number of bytes to move the limit, offset to the current
 *                  location.
 *
 * @return The limit offset before moving the new limit.
 */
- (size_t)pushLimit:(size_t)byteLimit;

/**
 * Moves the limit back to the offset as it was before calling pushLimit:.
 *
 * @param oldLimit The number of bytes to move the current limit. Usually this
 *                 is the value returned by the pushLimit: method.
 */
- (void)popLimit:(size_t)oldLimit;

/**
 * Verifies that the last call to -readTag returned the given tag value. This
 * is used to verify that a nested group ended with the correct end tag.
 *
 * @exception NSParseErrorException If the value does not match the last tag.
 *
 * @param expected The tag that was expected.
 **/
- (void)checkLastTagWas:(int32_t)expected;

@end

NS_ASSUME_NONNULL_END
