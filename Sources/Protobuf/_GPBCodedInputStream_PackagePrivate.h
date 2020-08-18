//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

// This header is private to the ProtobolBuffers library and must NOT be
// included by any sources outside this library. The contents of this file are
// subject to change at any time without notice.

#import "_GPBCodedInputStream.h"

@class _GPBUnknownFieldSet;
@class _GPBFieldDescriptor;

typedef struct _GPBCodedInputStreamState {
  const uint8_t *bytes;
  size_t bufferSize;
  size_t bufferPos;

  // For parsing subsections of an input stream you can put a hard limit on
  // how much should be read. Normally the limit is the end of the stream,
  // but you can adjust it to anywhere, and if you hit it you will be at the
  // end of the stream, until you adjust the limit.
  size_t currentLimit;
  int32_t lastTag;
  NSUInteger recursionDepth;
} _GPBCodedInputStreamState;

@interface _GPBCodedInputStream () {
 @package
  struct _GPBCodedInputStreamState state_;
  NSData *buffer_;
}

// Group support is deprecated, so we hide this interface from users, but
// support for older data.
- (void)readGroup:(int32_t)fieldNumber
              message:(_GPBMessage *)message
    extensionRegistry:(_GPBExtensionRegistry *)extensionRegistry;

// Reads a group field value from the stream and merges it into the given
// UnknownFieldSet.
- (void)readUnknownGroup:(int32_t)fieldNumber
                 message:(_GPBUnknownFieldSet *)message;

// Reads a map entry.
- (void)readMapEntry:(id)mapDictionary
    extensionRegistry:(_GPBExtensionRegistry *)extensionRegistry
                field:(_GPBFieldDescriptor *)field
        parentMessage:(_GPBMessage *)parentMessage;
@end

CF_EXTERN_C_BEGIN

int32_t _GPBCodedInputStreamReadTag(_GPBCodedInputStreamState *state);

double _GPBCodedInputStreamReadDouble(_GPBCodedInputStreamState *state);
float _GPBCodedInputStreamReadFloat(_GPBCodedInputStreamState *state);
uint64_t _GPBCodedInputStreamReadUInt64(_GPBCodedInputStreamState *state);
uint32_t _GPBCodedInputStreamReadUInt32(_GPBCodedInputStreamState *state);
int64_t _GPBCodedInputStreamReadInt64(_GPBCodedInputStreamState *state);
int32_t _GPBCodedInputStreamReadInt32(_GPBCodedInputStreamState *state);
uint64_t _GPBCodedInputStreamReadFixed64(_GPBCodedInputStreamState *state);
uint32_t _GPBCodedInputStreamReadFixed32(_GPBCodedInputStreamState *state);
int32_t _GPBCodedInputStreamReadEnum(_GPBCodedInputStreamState *state);
int32_t _GPBCodedInputStreamReadSFixed32(_GPBCodedInputStreamState *state);
int64_t _GPBCodedInputStreamReadSFixed64(_GPBCodedInputStreamState *state);
int32_t _GPBCodedInputStreamReadSInt32(_GPBCodedInputStreamState *state);
int64_t _GPBCodedInputStreamReadSInt64(_GPBCodedInputStreamState *state);
BOOL _GPBCodedInputStreamReadBool(_GPBCodedInputStreamState *state);
NSString *_GPBCodedInputStreamReadRetainedString(_GPBCodedInputStreamState *state)
    __attribute((ns_returns_retained));
NSData *_GPBCodedInputStreamReadRetainedBytes(_GPBCodedInputStreamState *state)
    __attribute((ns_returns_retained));
NSData *_GPBCodedInputStreamReadRetainedBytesNoCopy(
    _GPBCodedInputStreamState *state) __attribute((ns_returns_retained));

size_t _GPBCodedInputStreamPushLimit(_GPBCodedInputStreamState *state,
                                    size_t byteLimit);
void _GPBCodedInputStreamPopLimit(_GPBCodedInputStreamState *state,
                                 size_t oldLimit);
size_t _GPBCodedInputStreamBytesUntilLimit(_GPBCodedInputStreamState *state);
BOOL _GPBCodedInputStreamIsAtEnd(_GPBCodedInputStreamState *state);
void _GPBCodedInputStreamCheckLastTagWas(_GPBCodedInputStreamState *state,
                                        int32_t value);

CF_EXTERN_C_END
