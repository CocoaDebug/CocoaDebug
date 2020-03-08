// Protocol Buffers - Google's data interchange format
// Copyright 2008 Google Inc.  All rights reserved.
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
