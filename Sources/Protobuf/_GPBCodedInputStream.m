//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_GPBCodedInputStream_PackagePrivate.h"

#import "_GPBDictionary_PackagePrivate.h"
#import "_GPBMessage_PackagePrivate.h"
#import "_GPBUnknownFieldSet_PackagePrivate.h"
#import "_GPBUtilities_PackagePrivate.h"
#import "_GPBWireFormat.h"

NSString *const _GPBCodedInputStreamException =
    _GPBNSStringifySymbol(_GPBCodedInputStreamException);

NSString *const _GPBCodedInputStreamUnderlyingErrorKey =
    _GPBNSStringifySymbol(_GPBCodedInputStreamUnderlyingErrorKey);

NSString *const _GPBCodedInputStreamErrorDomain =
    _GPBNSStringifySymbol(_GPBCodedInputStreamErrorDomain);

// Matching:
// https://github.com/protocolbuffers/protobuf/blob/master/java/core/src/main/java/com/google/protobuf/CodedInputStream.java#L62
//  private static final int DEFAULT_RECURSION_LIMIT = 100;
// https://github.com/protocolbuffers/protobuf/blob/master/src/google/protobuf/io/coded_stream.cc#L86
//  int CodedInputStream::default_recursion_limit_ = 100;
static const NSUInteger kDefaultRecursionLimit = 100;

static void RaiseException(NSInteger code, NSString *reason) {
  NSDictionary *errorInfo = nil;
  if ([reason length]) {
    errorInfo = @{ _GPBErrorReasonKey: reason };
  }
  NSError *error = [NSError errorWithDomain:_GPBCodedInputStreamErrorDomain
                                       code:code
                                   userInfo:errorInfo];

  NSDictionary *exceptionInfo =
      @{ _GPBCodedInputStreamUnderlyingErrorKey: error };
  [[NSException exceptionWithName:_GPBCodedInputStreamException
                           reason:reason
                         userInfo:exceptionInfo] raise];
}

static void CheckRecursionLimit(_GPBCodedInputStreamState *state) {
  if (state->recursionDepth >= kDefaultRecursionLimit) {
    RaiseException(_GPBCodedInputStreamErrorRecursionDepthExceeded, nil);
  }
}

static void CheckSize(_GPBCodedInputStreamState *state, size_t size) {
  size_t newSize = state->bufferPos + size;
  if (newSize > state->bufferSize) {
    RaiseException(_GPBCodedInputStreamErrorInvalidSize, nil);
  }
  if (newSize > state->currentLimit) {
    // Fast forward to end of currentLimit;
    state->bufferPos = state->currentLimit;
    RaiseException(_GPBCodedInputStreamErrorSubsectionLimitReached, nil);
  }
}

static int8_t ReadRawByte(_GPBCodedInputStreamState *state) {
  CheckSize(state, sizeof(int8_t));
  return ((int8_t *)state->bytes)[state->bufferPos++];
}

static int32_t ReadRawLittleEndian32(_GPBCodedInputStreamState *state) {
  CheckSize(state, sizeof(int32_t));
  // Not using OSReadLittleInt32 because it has undocumented dependency
  // on reads being aligned.
  int32_t value;
  memcpy(&value, state->bytes + state->bufferPos, sizeof(int32_t));
  value = OSSwapLittleToHostInt32(value);
  state->bufferPos += sizeof(int32_t);
  return value;
}

static int64_t ReadRawLittleEndian64(_GPBCodedInputStreamState *state) {
  CheckSize(state, sizeof(int64_t));
  // Not using OSReadLittleInt64 because it has undocumented dependency
  // on reads being aligned.  
  int64_t value;
  memcpy(&value, state->bytes + state->bufferPos, sizeof(int64_t));
  value = OSSwapLittleToHostInt64(value);
  state->bufferPos += sizeof(int64_t);
  return value;
}

static int64_t ReadRawVarint64(_GPBCodedInputStreamState *state) {
  int32_t shift = 0;
  int64_t result = 0;
  while (shift < 64) {
    int8_t b = ReadRawByte(state);
    result |= (int64_t)((uint64_t)(b & 0x7F) << shift);
    if ((b & 0x80) == 0) {
      return result;
    }
    shift += 7;
  }
  RaiseException(_GPBCodedInputStreamErrorInvalidVarInt, @"Invalid VarInt64");
  return 0;
}

static int32_t ReadRawVarint32(_GPBCodedInputStreamState *state) {
  return (int32_t)ReadRawVarint64(state);
}

static void SkipRawData(_GPBCodedInputStreamState *state, size_t size) {
  CheckSize(state, size);
  state->bufferPos += size;
}

double _GPBCodedInputStreamReadDouble(_GPBCodedInputStreamState *state) {
  int64_t value = ReadRawLittleEndian64(state);
  return _GPBConvertInt64ToDouble(value);
}

float _GPBCodedInputStreamReadFloat(_GPBCodedInputStreamState *state) {
  int32_t value = ReadRawLittleEndian32(state);
  return _GPBConvertInt32ToFloat(value);
}

uint64_t _GPBCodedInputStreamReadUInt64(_GPBCodedInputStreamState *state) {
  uint64_t value = ReadRawVarint64(state);
  return value;
}

uint32_t _GPBCodedInputStreamReadUInt32(_GPBCodedInputStreamState *state) {
  uint32_t value = ReadRawVarint32(state);
  return value;
}

int64_t _GPBCodedInputStreamReadInt64(_GPBCodedInputStreamState *state) {
  int64_t value = ReadRawVarint64(state);
  return value;
}

int32_t _GPBCodedInputStreamReadInt32(_GPBCodedInputStreamState *state) {
  int32_t value = ReadRawVarint32(state);
  return value;
}

uint64_t _GPBCodedInputStreamReadFixed64(_GPBCodedInputStreamState *state) {
  uint64_t value = ReadRawLittleEndian64(state);
  return value;
}

uint32_t _GPBCodedInputStreamReadFixed32(_GPBCodedInputStreamState *state) {
  uint32_t value = ReadRawLittleEndian32(state);
  return value;
}

int32_t _GPBCodedInputStreamReadEnum(_GPBCodedInputStreamState *state) {
  int32_t value = ReadRawVarint32(state);
  return value;
}

int32_t _GPBCodedInputStreamReadSFixed32(_GPBCodedInputStreamState *state) {
  int32_t value = ReadRawLittleEndian32(state);
  return value;
}

int64_t _GPBCodedInputStreamReadSFixed64(_GPBCodedInputStreamState *state) {
  int64_t value = ReadRawLittleEndian64(state);
  return value;
}

int32_t _GPBCodedInputStreamReadSInt32(_GPBCodedInputStreamState *state) {
  int32_t value = _GPBDecodeZigZag32(ReadRawVarint32(state));
  return value;
}

int64_t _GPBCodedInputStreamReadSInt64(_GPBCodedInputStreamState *state) {
  int64_t value = _GPBDecodeZigZag64(ReadRawVarint64(state));
  return value;
}

BOOL _GPBCodedInputStreamReadBool(_GPBCodedInputStreamState *state) {
  return ReadRawVarint64(state) != 0;
}

int32_t _GPBCodedInputStreamReadTag(_GPBCodedInputStreamState *state) {
  if (_GPBCodedInputStreamIsAtEnd(state)) {
    state->lastTag = 0;
    return 0;
  }

  state->lastTag = ReadRawVarint32(state);
  // Tags have to include a valid wireformat.
  if (!_GPBWireFormatIsValidTag(state->lastTag)) {
    RaiseException(_GPBCodedInputStreamErrorInvalidTag,
                   @"Invalid wireformat in tag.");
  }
  // Zero is not a valid field number.
  if (_GPBWireFormatGetTagFieldNumber(state->lastTag) == 0) {
    RaiseException(_GPBCodedInputStreamErrorInvalidTag,
                   @"A zero field number on the wire is invalid.");
  }
  return state->lastTag;
}

NSString *_GPBCodedInputStreamReadRetainedString(
    _GPBCodedInputStreamState *state) {
  int32_t size = ReadRawVarint32(state);
  NSString *result;
  if (size == 0) {
    result = @"";
  } else {
    CheckSize(state, size);
    result = [[NSString alloc] initWithBytes:&state->bytes[state->bufferPos]
                                      length:size
                                    encoding:NSUTF8StringEncoding];
    state->bufferPos += size;
    if (!result) {
#ifdef DEBUG
      // https://developers.google.com/protocol-buffers/docs/proto#scalar
      NSLog(@"UTF-8 failure, is some field type 'string' when it should be "
            @"'bytes'?");
#endif
      RaiseException(_GPBCodedInputStreamErrorInvalidUTF8, nil);
    }
  }
  return result;
}

NSData *_GPBCodedInputStreamReadRetainedBytes(_GPBCodedInputStreamState *state) {
  int32_t size = ReadRawVarint32(state);
  if (size < 0) return nil;
  CheckSize(state, size);
  NSData *result = [[NSData alloc] initWithBytes:state->bytes + state->bufferPos
                                          length:size];
  state->bufferPos += size;
  return result;
}

NSData *_GPBCodedInputStreamReadRetainedBytesNoCopy(
    _GPBCodedInputStreamState *state) {
  int32_t size = ReadRawVarint32(state);
  if (size < 0) return nil;
  CheckSize(state, size);
  // Cast is safe because freeWhenDone is NO.
  NSData *result = [[NSData alloc]
      initWithBytesNoCopy:(void *)(state->bytes + state->bufferPos)
                   length:size
             freeWhenDone:NO];
  state->bufferPos += size;
  return result;
}

size_t _GPBCodedInputStreamPushLimit(_GPBCodedInputStreamState *state,
                                    size_t byteLimit) {
  byteLimit += state->bufferPos;
  size_t oldLimit = state->currentLimit;
  if (byteLimit > oldLimit) {
    RaiseException(_GPBCodedInputStreamErrorInvalidSubsectionLimit, nil);
  }
  state->currentLimit = byteLimit;
  return oldLimit;
}

void _GPBCodedInputStreamPopLimit(_GPBCodedInputStreamState *state,
                                 size_t oldLimit) {
  state->currentLimit = oldLimit;
}

size_t _GPBCodedInputStreamBytesUntilLimit(_GPBCodedInputStreamState *state) {
  return state->currentLimit - state->bufferPos;
}

BOOL _GPBCodedInputStreamIsAtEnd(_GPBCodedInputStreamState *state) {
  return (state->bufferPos == state->bufferSize) ||
         (state->bufferPos == state->currentLimit);
}

void _GPBCodedInputStreamCheckLastTagWas(_GPBCodedInputStreamState *state,
                                        int32_t value) {
  if (state->lastTag != value) {
    RaiseException(_GPBCodedInputStreamErrorInvalidTag, @"Unexpected tag read");
  }
}

@implementation _GPBCodedInputStream

+ (instancetype)streamWithData:(NSData *)data {
  return [[[self alloc] initWithData:data] autorelease];
}

- (instancetype)initWithData:(NSData *)data {
  if ((self = [super init])) {
#ifdef DEBUG
    NSCAssert([self class] == [_GPBCodedInputStream class],
              @"Subclassing of _GPBCodedInputStream is not allowed.");
#endif
    buffer_ = [data retain];
    state_.bytes = (const uint8_t *)[data bytes];
    state_.bufferSize = [data length];
    state_.currentLimit = state_.bufferSize;
  }
  return self;
}

- (void)dealloc {
  [buffer_ release];
  [super dealloc];
}

// Direct access is use for speed, to avoid even internally declaring things
// read/write, etc. The warning is enabled in the project to ensure code calling
// protos can turn on -Wdirect-ivar-access without issues.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"

- (int32_t)readTag {
  return _GPBCodedInputStreamReadTag(&state_);
}

- (void)checkLastTagWas:(int32_t)value {
  _GPBCodedInputStreamCheckLastTagWas(&state_, value);
}

- (BOOL)skipField:(int32_t)tag {
  NSAssert(_GPBWireFormatIsValidTag(tag), @"Invalid tag");
  switch (_GPBWireFormatGetTagWireType(tag)) {
    case _GPBWireFormatVarint:
      _GPBCodedInputStreamReadInt32(&state_);
      return YES;
    case _GPBWireFormatFixed64:
      SkipRawData(&state_, sizeof(int64_t));
      return YES;
    case _GPBWireFormatLengthDelimited:
      SkipRawData(&state_, ReadRawVarint32(&state_));
      return YES;
    case _GPBWireFormatStartGroup:
      [self skipMessage];
      _GPBCodedInputStreamCheckLastTagWas(
          &state_, _GPBWireFormatMakeTag(_GPBWireFormatGetTagFieldNumber(tag),
                                        _GPBWireFormatEndGroup));
      return YES;
    case _GPBWireFormatEndGroup:
      return NO;
    case _GPBWireFormatFixed32:
      SkipRawData(&state_, sizeof(int32_t));
      return YES;
  }
}

- (void)skipMessage {
  while (YES) {
    int32_t tag = _GPBCodedInputStreamReadTag(&state_);
    if (tag == 0 || ![self skipField:tag]) {
      return;
    }
  }
}

- (BOOL)isAtEnd {
  return _GPBCodedInputStreamIsAtEnd(&state_);
}

- (size_t)position {
  return state_.bufferPos;
}

- (size_t)pushLimit:(size_t)byteLimit {
  return _GPBCodedInputStreamPushLimit(&state_, byteLimit);
}

- (void)popLimit:(size_t)oldLimit {
  _GPBCodedInputStreamPopLimit(&state_, oldLimit);
}

- (double)readDouble {
  return _GPBCodedInputStreamReadDouble(&state_);
}

- (float)readFloat {
  return _GPBCodedInputStreamReadFloat(&state_);
}

- (uint64_t)readUInt64 {
  return _GPBCodedInputStreamReadUInt64(&state_);
}

- (int64_t)readInt64 {
  return _GPBCodedInputStreamReadInt64(&state_);
}

- (int32_t)readInt32 {
  return _GPBCodedInputStreamReadInt32(&state_);
}

- (uint64_t)readFixed64 {
  return _GPBCodedInputStreamReadFixed64(&state_);
}

- (uint32_t)readFixed32 {
  return _GPBCodedInputStreamReadFixed32(&state_);
}

- (BOOL)readBool {
  return _GPBCodedInputStreamReadBool(&state_);
}

- (NSString *)readString {
  return [_GPBCodedInputStreamReadRetainedString(&state_) autorelease];
}

- (void)readGroup:(int32_t)fieldNumber
              message:(_GPBMessage *)message
    extensionRegistry:(_GPBExtensionRegistry *)extensionRegistry {
  CheckRecursionLimit(&state_);
  ++state_.recursionDepth;
  [message mergeFromCodedInputStream:self extensionRegistry:extensionRegistry];
  _GPBCodedInputStreamCheckLastTagWas(
      &state_, _GPBWireFormatMakeTag(fieldNumber, _GPBWireFormatEndGroup));
  --state_.recursionDepth;
}

- (void)readUnknownGroup:(int32_t)fieldNumber
                 message:(_GPBUnknownFieldSet *)message {
  CheckRecursionLimit(&state_);
  ++state_.recursionDepth;
  [message mergeFromCodedInputStream:self];
  _GPBCodedInputStreamCheckLastTagWas(
      &state_, _GPBWireFormatMakeTag(fieldNumber, _GPBWireFormatEndGroup));
  --state_.recursionDepth;
}

- (void)readMessage:(_GPBMessage *)message
    extensionRegistry:(_GPBExtensionRegistry *)extensionRegistry {
  CheckRecursionLimit(&state_);
  int32_t length = ReadRawVarint32(&state_);
  size_t oldLimit = _GPBCodedInputStreamPushLimit(&state_, length);
  ++state_.recursionDepth;
  [message mergeFromCodedInputStream:self extensionRegistry:extensionRegistry];
  _GPBCodedInputStreamCheckLastTagWas(&state_, 0);
  --state_.recursionDepth;
  _GPBCodedInputStreamPopLimit(&state_, oldLimit);
}

- (void)readMapEntry:(id)mapDictionary
    extensionRegistry:(_GPBExtensionRegistry *)extensionRegistry
                field:(_GPBFieldDescriptor *)field
        parentMessage:(_GPBMessage *)parentMessage {
  CheckRecursionLimit(&state_);
  int32_t length = ReadRawVarint32(&state_);
  size_t oldLimit = _GPBCodedInputStreamPushLimit(&state_, length);
  ++state_.recursionDepth;
  _GPBDictionaryReadEntry(mapDictionary, self, extensionRegistry, field,
                         parentMessage);
  _GPBCodedInputStreamCheckLastTagWas(&state_, 0);
  --state_.recursionDepth;
  _GPBCodedInputStreamPopLimit(&state_, oldLimit);
}

- (NSData *)readBytes {
  return [_GPBCodedInputStreamReadRetainedBytes(&state_) autorelease];
}

- (uint32_t)readUInt32 {
  return _GPBCodedInputStreamReadUInt32(&state_);
}

- (int32_t)readEnum {
  return _GPBCodedInputStreamReadEnum(&state_);
}

- (int32_t)readSFixed32 {
  return _GPBCodedInputStreamReadSFixed32(&state_);
}

- (int64_t)readSFixed64 {
  return _GPBCodedInputStreamReadSFixed64(&state_);
}

- (int32_t)readSInt32 {
  return _GPBCodedInputStreamReadSInt32(&state_);
}

- (int64_t)readSInt64 {
  return _GPBCodedInputStreamReadSInt64(&state_);
}

#pragma clang diagnostic pop

@end
