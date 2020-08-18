//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_GPBCodedOutputStream_PackagePrivate.h"

#import <mach/vm_param.h>

#import "_GPBArray.h"
#import "_GPBUnknownFieldSet_PackagePrivate.h"
#import "_GPBUtilities_PackagePrivate.h"

// These values are the existing values so as not to break any code that might
// have already been inspecting them when they weren't documented/exposed.
NSString *const _GPBCodedOutputStreamException_OutOfSpace = @"OutOfSpace";
NSString *const _GPBCodedOutputStreamException_WriteFailed = @"WriteFailed";

// Structure for containing state of a _GPBCodedInputStream. Brought out into
// a struct so that we can inline several common functions instead of dealing
// with overhead of ObjC dispatch.
typedef struct _GPBOutputBufferState {
  uint8_t *bytes;
  size_t size;
  size_t position;
  NSOutputStream *output;
} _GPBOutputBufferState;

@implementation _GPBCodedOutputStream {
  _GPBOutputBufferState state_;
  NSMutableData *buffer_;
}

static const int32_t LITTLE_ENDIAN_32_SIZE = sizeof(uint32_t);
static const int32_t LITTLE_ENDIAN_64_SIZE = sizeof(uint64_t);

// Internal helper that writes the current buffer to the output. The
// buffer position is reset to its initial value when this returns.
static void _GPBRefreshBuffer(_GPBOutputBufferState *state) {
  if (state->output == nil) {
    // We're writing to a single buffer.
    [NSException raise:_GPBCodedOutputStreamException_OutOfSpace format:@""];
  }
  if (state->position != 0) {
    NSInteger written =
        [state->output write:state->bytes maxLength:state->position];
    if (written != (NSInteger)state->position) {
      [NSException raise:_GPBCodedOutputStreamException_WriteFailed format:@""];
    }
    state->position = 0;
  }
}

static void _GPBWriteRawByte(_GPBOutputBufferState *state, uint8_t value) {
  if (state->position == state->size) {
    _GPBRefreshBuffer(state);
  }
  state->bytes[state->position++] = value;
}

static void _GPBWriteRawVarint32(_GPBOutputBufferState *state, int32_t value) {
  while (YES) {
    if ((value & ~0x7F) == 0) {
      uint8_t val = (uint8_t)value;
      _GPBWriteRawByte(state, val);
      return;
    } else {
      _GPBWriteRawByte(state, (value & 0x7F) | 0x80);
      value = _GPBLogicalRightShift32(value, 7);
    }
  }
}

static void _GPBWriteRawVarint64(_GPBOutputBufferState *state, int64_t value) {
  while (YES) {
    if ((value & ~0x7FL) == 0) {
      uint8_t val = (uint8_t)value;
      _GPBWriteRawByte(state, val);
      return;
    } else {
      _GPBWriteRawByte(state, ((int32_t)value & 0x7F) | 0x80);
      value = _GPBLogicalRightShift64(value, 7);
    }
  }
}

static void _GPBWriteInt32NoTag(_GPBOutputBufferState *state, int32_t value) {
  if (value >= 0) {
    _GPBWriteRawVarint32(state, value);
  } else {
    // Must sign-extend
    _GPBWriteRawVarint64(state, value);
  }
}

static void _GPBWriteUInt32(_GPBOutputBufferState *state, int32_t fieldNumber,
                           uint32_t value) {
  _GPBWriteTagWithFormat(state, fieldNumber, _GPBWireFormatVarint);
  _GPBWriteRawVarint32(state, value);
}

static void _GPBWriteTagWithFormat(_GPBOutputBufferState *state,
                                  uint32_t fieldNumber, _GPBWireFormat format) {
  _GPBWriteRawVarint32(state, _GPBWireFormatMakeTag(fieldNumber, format));
}

static void _GPBWriteRawLittleEndian32(_GPBOutputBufferState *state,
                                      int32_t value) {
  _GPBWriteRawByte(state, (value)&0xFF);
  _GPBWriteRawByte(state, (value >> 8) & 0xFF);
  _GPBWriteRawByte(state, (value >> 16) & 0xFF);
  _GPBWriteRawByte(state, (value >> 24) & 0xFF);
}

static void _GPBWriteRawLittleEndian64(_GPBOutputBufferState *state,
                                      int64_t value) {
  _GPBWriteRawByte(state, (int32_t)(value)&0xFF);
  _GPBWriteRawByte(state, (int32_t)(value >> 8) & 0xFF);
  _GPBWriteRawByte(state, (int32_t)(value >> 16) & 0xFF);
  _GPBWriteRawByte(state, (int32_t)(value >> 24) & 0xFF);
  _GPBWriteRawByte(state, (int32_t)(value >> 32) & 0xFF);
  _GPBWriteRawByte(state, (int32_t)(value >> 40) & 0xFF);
  _GPBWriteRawByte(state, (int32_t)(value >> 48) & 0xFF);
  _GPBWriteRawByte(state, (int32_t)(value >> 56) & 0xFF);
}

- (void)dealloc {
  [self flush];
  [state_.output close];
  [state_.output release];
  [buffer_ release];

  [super dealloc];
}

- (instancetype)initWithOutputStream:(NSOutputStream *)output {
  NSMutableData *data = [NSMutableData dataWithLength:PAGE_SIZE];
  return [self initWithOutputStream:output data:data];
}

- (instancetype)initWithData:(NSMutableData *)data {
  return [self initWithOutputStream:nil data:data];
}

// This initializer isn't exposed, but it is the designated initializer.
// Setting OutputStream and NSData is to control the buffering behavior/size
// of the work, but that is more obvious via the bufferSize: version.
- (instancetype)initWithOutputStream:(NSOutputStream *)output
                                data:(NSMutableData *)data {
  if ((self = [super init])) {
    buffer_ = [data retain];
    state_.bytes = [data mutableBytes];
    state_.size = [data length];
    state_.output = [output retain];
    [state_.output open];
  }
  return self;
}

+ (instancetype)streamWithOutputStream:(NSOutputStream *)output {
  NSMutableData *data = [NSMutableData dataWithLength:PAGE_SIZE];
  return [[[self alloc] initWithOutputStream:output
                                        data:data] autorelease];
}

+ (instancetype)streamWithData:(NSMutableData *)data {
  return [[[self alloc] initWithData:data] autorelease];
}

// Direct access is use for speed, to avoid even internally declaring things
// read/write, etc. The warning is enabled in the project to ensure code calling
// protos can turn on -Wdirect-ivar-access without issues.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"

- (void)writeDoubleNoTag:(double)value {
  _GPBWriteRawLittleEndian64(&state_, _GPBConvertDoubleToInt64(value));
}

- (void)writeDouble:(int32_t)fieldNumber value:(double)value {
  _GPBWriteTagWithFormat(&state_, fieldNumber, _GPBWireFormatFixed64);
  _GPBWriteRawLittleEndian64(&state_, _GPBConvertDoubleToInt64(value));
}

- (void)writeFloatNoTag:(float)value {
  _GPBWriteRawLittleEndian32(&state_, _GPBConvertFloatToInt32(value));
}

- (void)writeFloat:(int32_t)fieldNumber value:(float)value {
  _GPBWriteTagWithFormat(&state_, fieldNumber, _GPBWireFormatFixed32);
  _GPBWriteRawLittleEndian32(&state_, _GPBConvertFloatToInt32(value));
}

- (void)writeUInt64NoTag:(uint64_t)value {
  _GPBWriteRawVarint64(&state_, value);
}

- (void)writeUInt64:(int32_t)fieldNumber value:(uint64_t)value {
  _GPBWriteTagWithFormat(&state_, fieldNumber, _GPBWireFormatVarint);
  _GPBWriteRawVarint64(&state_, value);
}

- (void)writeInt64NoTag:(int64_t)value {
  _GPBWriteRawVarint64(&state_, value);
}

- (void)writeInt64:(int32_t)fieldNumber value:(int64_t)value {
  _GPBWriteTagWithFormat(&state_, fieldNumber, _GPBWireFormatVarint);
  _GPBWriteRawVarint64(&state_, value);
}

- (void)writeInt32NoTag:(int32_t)value {
  _GPBWriteInt32NoTag(&state_, value);
}

- (void)writeInt32:(int32_t)fieldNumber value:(int32_t)value {
  _GPBWriteTagWithFormat(&state_, fieldNumber, _GPBWireFormatVarint);
  _GPBWriteInt32NoTag(&state_, value);
}

- (void)writeFixed64NoTag:(uint64_t)value {
  _GPBWriteRawLittleEndian64(&state_, value);
}

- (void)writeFixed64:(int32_t)fieldNumber value:(uint64_t)value {
  _GPBWriteTagWithFormat(&state_, fieldNumber, _GPBWireFormatFixed64);
  _GPBWriteRawLittleEndian64(&state_, value);
}

- (void)writeFixed32NoTag:(uint32_t)value {
  _GPBWriteRawLittleEndian32(&state_, value);
}

- (void)writeFixed32:(int32_t)fieldNumber value:(uint32_t)value {
  _GPBWriteTagWithFormat(&state_, fieldNumber, _GPBWireFormatFixed32);
  _GPBWriteRawLittleEndian32(&state_, value);
}

- (void)writeBoolNoTag:(BOOL)value {
  _GPBWriteRawByte(&state_, (value ? 1 : 0));
}

- (void)writeBool:(int32_t)fieldNumber value:(BOOL)value {
  _GPBWriteTagWithFormat(&state_, fieldNumber, _GPBWireFormatVarint);
  _GPBWriteRawByte(&state_, (value ? 1 : 0));
}

- (void)writeStringNoTag:(const NSString *)value {
  size_t length = [value lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
  _GPBWriteRawVarint32(&state_, (int32_t)length);
  if (length == 0) {
    return;
  }

  const char *quickString =
      CFStringGetCStringPtr((CFStringRef)value, kCFStringEncodingUTF8);

  // Fast path: Most strings are short, if the buffer already has space,
  // add to it directly.
  NSUInteger bufferBytesLeft = state_.size - state_.position;
  if (bufferBytesLeft >= length) {
    NSUInteger usedBufferLength = 0;
    BOOL result;
    if (quickString != NULL) {
      memcpy(state_.bytes + state_.position, quickString, length);
      usedBufferLength = length;
      result = YES;
    } else {
      result = [value getBytes:state_.bytes + state_.position
                     maxLength:bufferBytesLeft
                    usedLength:&usedBufferLength
                      encoding:NSUTF8StringEncoding
                       options:(NSStringEncodingConversionOptions)0
                         range:NSMakeRange(0, [value length])
                remainingRange:NULL];
    }
    if (result) {
      NSAssert2((usedBufferLength == length),
                @"Our UTF8 calc was wrong? %tu vs %zd", usedBufferLength,
                length);
      state_.position += usedBufferLength;
      return;
    }
  } else if (quickString != NULL) {
    [self writeRawPtr:quickString offset:0 length:length];
  } else {
    // Slow path: just get it as data and write it out.
    NSData *utf8Data = [value dataUsingEncoding:NSUTF8StringEncoding];
    NSAssert2(([utf8Data length] == length),
              @"Strings UTF8 length was wrong? %tu vs %zd", [utf8Data length],
              length);
    [self writeRawData:utf8Data];
  }
}

- (void)writeString:(int32_t)fieldNumber value:(NSString *)value {
  _GPBWriteTagWithFormat(&state_, fieldNumber, _GPBWireFormatLengthDelimited);
  [self writeStringNoTag:value];
}

- (void)writeGroupNoTag:(int32_t)fieldNumber value:(_GPBMessage *)value {
  [value writeToCodedOutputStream:self];
  _GPBWriteTagWithFormat(&state_, fieldNumber, _GPBWireFormatEndGroup);
}

- (void)writeGroup:(int32_t)fieldNumber value:(_GPBMessage *)value {
  _GPBWriteTagWithFormat(&state_, fieldNumber, _GPBWireFormatStartGroup);
  [self writeGroupNoTag:fieldNumber value:value];
}

- (void)writeUnknownGroupNoTag:(int32_t)fieldNumber
                         value:(const _GPBUnknownFieldSet *)value {
  [value writeToCodedOutputStream:self];
  _GPBWriteTagWithFormat(&state_, fieldNumber, _GPBWireFormatEndGroup);
}

- (void)writeUnknownGroup:(int32_t)fieldNumber
                    value:(_GPBUnknownFieldSet *)value {
  _GPBWriteTagWithFormat(&state_, fieldNumber, _GPBWireFormatStartGroup);
  [self writeUnknownGroupNoTag:fieldNumber value:value];
}

- (void)writeMessageNoTag:(_GPBMessage *)value {
  _GPBWriteRawVarint32(&state_, (int32_t)[value serializedSize]);
  [value writeToCodedOutputStream:self];
}

- (void)writeMessage:(int32_t)fieldNumber value:(_GPBMessage *)value {
  _GPBWriteTagWithFormat(&state_, fieldNumber, _GPBWireFormatLengthDelimited);
  [self writeMessageNoTag:value];
}

- (void)writeBytesNoTag:(NSData *)value {
  _GPBWriteRawVarint32(&state_, (int32_t)[value length]);
  [self writeRawData:value];
}

- (void)writeBytes:(int32_t)fieldNumber value:(NSData *)value {
  _GPBWriteTagWithFormat(&state_, fieldNumber, _GPBWireFormatLengthDelimited);
  [self writeBytesNoTag:value];
}

- (void)writeUInt32NoTag:(uint32_t)value {
  _GPBWriteRawVarint32(&state_, value);
}

- (void)writeUInt32:(int32_t)fieldNumber value:(uint32_t)value {
  _GPBWriteUInt32(&state_, fieldNumber, value);
}

- (void)writeEnumNoTag:(int32_t)value {
  _GPBWriteInt32NoTag(&state_, value);
}

- (void)writeEnum:(int32_t)fieldNumber value:(int32_t)value {
  _GPBWriteTagWithFormat(&state_, fieldNumber, _GPBWireFormatVarint);
  _GPBWriteInt32NoTag(&state_, value);
}

- (void)writeSFixed32NoTag:(int32_t)value {
  _GPBWriteRawLittleEndian32(&state_, value);
}

- (void)writeSFixed32:(int32_t)fieldNumber value:(int32_t)value {
  _GPBWriteTagWithFormat(&state_, fieldNumber, _GPBWireFormatFixed32);
  _GPBWriteRawLittleEndian32(&state_, value);
}

- (void)writeSFixed64NoTag:(int64_t)value {
  _GPBWriteRawLittleEndian64(&state_, value);
}

- (void)writeSFixed64:(int32_t)fieldNumber value:(int64_t)value {
  _GPBWriteTagWithFormat(&state_, fieldNumber, _GPBWireFormatFixed64);
  _GPBWriteRawLittleEndian64(&state_, value);
}

- (void)writeSInt32NoTag:(int32_t)value {
  _GPBWriteRawVarint32(&state_, _GPBEncodeZigZag32(value));
}

- (void)writeSInt32:(int32_t)fieldNumber value:(int32_t)value {
  _GPBWriteTagWithFormat(&state_, fieldNumber, _GPBWireFormatVarint);
  _GPBWriteRawVarint32(&state_, _GPBEncodeZigZag32(value));
}

- (void)writeSInt64NoTag:(int64_t)value {
  _GPBWriteRawVarint64(&state_, _GPBEncodeZigZag64(value));
}

- (void)writeSInt64:(int32_t)fieldNumber value:(int64_t)value {
  _GPBWriteTagWithFormat(&state_, fieldNumber, _GPBWireFormatVarint);
  _GPBWriteRawVarint64(&state_, _GPBEncodeZigZag64(value));
}

//%PDDM-DEFINE WRITE_PACKABLE_DEFNS(NAME, ARRAY_TYPE, TYPE, ACCESSOR_NAME)
//%- (void)write##NAME##Array:(int32_t)fieldNumber
//%       NAME$S     values:(_GPB##ARRAY_TYPE##Array *)values
//%       NAME$S        tag:(uint32_t)tag {
//%  if (tag != 0) {
//%    if (values.count == 0) return;
//%    __block size_t dataSize = 0;
//%    [values enumerate##ACCESSOR_NAME##ValuesWithBlock:^(TYPE value, NSUInteger idx, BOOL *stop) {
//%#pragma unused(idx, stop)
//%      dataSize += _GPBCompute##NAME##SizeNoTag(value);
//%    }];
//%    _GPBWriteRawVarint32(&state_, tag);
//%    _GPBWriteRawVarint32(&state_, (int32_t)dataSize);
//%    [values enumerate##ACCESSOR_NAME##ValuesWithBlock:^(TYPE value, NSUInteger idx, BOOL *stop) {
//%#pragma unused(idx, stop)
//%      [self write##NAME##NoTag:value];
//%    }];
//%  } else {
//%    [values enumerate##ACCESSOR_NAME##ValuesWithBlock:^(TYPE value, NSUInteger idx, BOOL *stop) {
//%#pragma unused(idx, stop)
//%      [self write##NAME:fieldNumber value:value];
//%    }];
//%  }
//%}
//%
//%PDDM-DEFINE WRITE_UNPACKABLE_DEFNS(NAME, TYPE)
//%- (void)write##NAME##Array:(int32_t)fieldNumber values:(NSArray *)values {
//%  for (TYPE *value in values) {
//%    [self write##NAME:fieldNumber value:value];
//%  }
//%}
//%
//%PDDM-EXPAND WRITE_PACKABLE_DEFNS(Double, Double, double, )
// This block of code is generated, do not edit it directly.

- (void)writeDoubleArray:(int32_t)fieldNumber
                  values:(_GPBDoubleArray *)values
                     tag:(uint32_t)tag {
  if (tag != 0) {
    if (values.count == 0) return;
    __block size_t dataSize = 0;
    [values enumerateValuesWithBlock:^(double value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      dataSize += _GPBComputeDoubleSizeNoTag(value);
    }];
    _GPBWriteRawVarint32(&state_, tag);
    _GPBWriteRawVarint32(&state_, (int32_t)dataSize);
    [values enumerateValuesWithBlock:^(double value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeDoubleNoTag:value];
    }];
  } else {
    [values enumerateValuesWithBlock:^(double value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeDouble:fieldNumber value:value];
    }];
  }
}

//%PDDM-EXPAND WRITE_PACKABLE_DEFNS(Float, Float, float, )
// This block of code is generated, do not edit it directly.

- (void)writeFloatArray:(int32_t)fieldNumber
                 values:(_GPBFloatArray *)values
                    tag:(uint32_t)tag {
  if (tag != 0) {
    if (values.count == 0) return;
    __block size_t dataSize = 0;
    [values enumerateValuesWithBlock:^(float value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      dataSize += _GPBComputeFloatSizeNoTag(value);
    }];
    _GPBWriteRawVarint32(&state_, tag);
    _GPBWriteRawVarint32(&state_, (int32_t)dataSize);
    [values enumerateValuesWithBlock:^(float value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeFloatNoTag:value];
    }];
  } else {
    [values enumerateValuesWithBlock:^(float value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeFloat:fieldNumber value:value];
    }];
  }
}

//%PDDM-EXPAND WRITE_PACKABLE_DEFNS(UInt64, UInt64, uint64_t, )
// This block of code is generated, do not edit it directly.

- (void)writeUInt64Array:(int32_t)fieldNumber
                  values:(_GPBUInt64Array *)values
                     tag:(uint32_t)tag {
  if (tag != 0) {
    if (values.count == 0) return;
    __block size_t dataSize = 0;
    [values enumerateValuesWithBlock:^(uint64_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      dataSize += _GPBComputeUInt64SizeNoTag(value);
    }];
    _GPBWriteRawVarint32(&state_, tag);
    _GPBWriteRawVarint32(&state_, (int32_t)dataSize);
    [values enumerateValuesWithBlock:^(uint64_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeUInt64NoTag:value];
    }];
  } else {
    [values enumerateValuesWithBlock:^(uint64_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeUInt64:fieldNumber value:value];
    }];
  }
}

//%PDDM-EXPAND WRITE_PACKABLE_DEFNS(Int64, Int64, int64_t, )
// This block of code is generated, do not edit it directly.

- (void)writeInt64Array:(int32_t)fieldNumber
                 values:(_GPBInt64Array *)values
                    tag:(uint32_t)tag {
  if (tag != 0) {
    if (values.count == 0) return;
    __block size_t dataSize = 0;
    [values enumerateValuesWithBlock:^(int64_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      dataSize += _GPBComputeInt64SizeNoTag(value);
    }];
    _GPBWriteRawVarint32(&state_, tag);
    _GPBWriteRawVarint32(&state_, (int32_t)dataSize);
    [values enumerateValuesWithBlock:^(int64_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeInt64NoTag:value];
    }];
  } else {
    [values enumerateValuesWithBlock:^(int64_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeInt64:fieldNumber value:value];
    }];
  }
}

//%PDDM-EXPAND WRITE_PACKABLE_DEFNS(Int32, Int32, int32_t, )
// This block of code is generated, do not edit it directly.

- (void)writeInt32Array:(int32_t)fieldNumber
                 values:(_GPBInt32Array *)values
                    tag:(uint32_t)tag {
  if (tag != 0) {
    if (values.count == 0) return;
    __block size_t dataSize = 0;
    [values enumerateValuesWithBlock:^(int32_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      dataSize += _GPBComputeInt32SizeNoTag(value);
    }];
    _GPBWriteRawVarint32(&state_, tag);
    _GPBWriteRawVarint32(&state_, (int32_t)dataSize);
    [values enumerateValuesWithBlock:^(int32_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeInt32NoTag:value];
    }];
  } else {
    [values enumerateValuesWithBlock:^(int32_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeInt32:fieldNumber value:value];
    }];
  }
}

//%PDDM-EXPAND WRITE_PACKABLE_DEFNS(UInt32, UInt32, uint32_t, )
// This block of code is generated, do not edit it directly.

- (void)writeUInt32Array:(int32_t)fieldNumber
                  values:(_GPBUInt32Array *)values
                     tag:(uint32_t)tag {
  if (tag != 0) {
    if (values.count == 0) return;
    __block size_t dataSize = 0;
    [values enumerateValuesWithBlock:^(uint32_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      dataSize += _GPBComputeUInt32SizeNoTag(value);
    }];
    _GPBWriteRawVarint32(&state_, tag);
    _GPBWriteRawVarint32(&state_, (int32_t)dataSize);
    [values enumerateValuesWithBlock:^(uint32_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeUInt32NoTag:value];
    }];
  } else {
    [values enumerateValuesWithBlock:^(uint32_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeUInt32:fieldNumber value:value];
    }];
  }
}

//%PDDM-EXPAND WRITE_PACKABLE_DEFNS(Fixed64, UInt64, uint64_t, )
// This block of code is generated, do not edit it directly.

- (void)writeFixed64Array:(int32_t)fieldNumber
                   values:(_GPBUInt64Array *)values
                      tag:(uint32_t)tag {
  if (tag != 0) {
    if (values.count == 0) return;
    __block size_t dataSize = 0;
    [values enumerateValuesWithBlock:^(uint64_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      dataSize += _GPBComputeFixed64SizeNoTag(value);
    }];
    _GPBWriteRawVarint32(&state_, tag);
    _GPBWriteRawVarint32(&state_, (int32_t)dataSize);
    [values enumerateValuesWithBlock:^(uint64_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeFixed64NoTag:value];
    }];
  } else {
    [values enumerateValuesWithBlock:^(uint64_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeFixed64:fieldNumber value:value];
    }];
  }
}

//%PDDM-EXPAND WRITE_PACKABLE_DEFNS(Fixed32, UInt32, uint32_t, )
// This block of code is generated, do not edit it directly.

- (void)writeFixed32Array:(int32_t)fieldNumber
                   values:(_GPBUInt32Array *)values
                      tag:(uint32_t)tag {
  if (tag != 0) {
    if (values.count == 0) return;
    __block size_t dataSize = 0;
    [values enumerateValuesWithBlock:^(uint32_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      dataSize += _GPBComputeFixed32SizeNoTag(value);
    }];
    _GPBWriteRawVarint32(&state_, tag);
    _GPBWriteRawVarint32(&state_, (int32_t)dataSize);
    [values enumerateValuesWithBlock:^(uint32_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeFixed32NoTag:value];
    }];
  } else {
    [values enumerateValuesWithBlock:^(uint32_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeFixed32:fieldNumber value:value];
    }];
  }
}

//%PDDM-EXPAND WRITE_PACKABLE_DEFNS(SInt32, Int32, int32_t, )
// This block of code is generated, do not edit it directly.

- (void)writeSInt32Array:(int32_t)fieldNumber
                  values:(_GPBInt32Array *)values
                     tag:(uint32_t)tag {
  if (tag != 0) {
    if (values.count == 0) return;
    __block size_t dataSize = 0;
    [values enumerateValuesWithBlock:^(int32_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      dataSize += _GPBComputeSInt32SizeNoTag(value);
    }];
    _GPBWriteRawVarint32(&state_, tag);
    _GPBWriteRawVarint32(&state_, (int32_t)dataSize);
    [values enumerateValuesWithBlock:^(int32_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeSInt32NoTag:value];
    }];
  } else {
    [values enumerateValuesWithBlock:^(int32_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeSInt32:fieldNumber value:value];
    }];
  }
}

//%PDDM-EXPAND WRITE_PACKABLE_DEFNS(SInt64, Int64, int64_t, )
// This block of code is generated, do not edit it directly.

- (void)writeSInt64Array:(int32_t)fieldNumber
                  values:(_GPBInt64Array *)values
                     tag:(uint32_t)tag {
  if (tag != 0) {
    if (values.count == 0) return;
    __block size_t dataSize = 0;
    [values enumerateValuesWithBlock:^(int64_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      dataSize += _GPBComputeSInt64SizeNoTag(value);
    }];
    _GPBWriteRawVarint32(&state_, tag);
    _GPBWriteRawVarint32(&state_, (int32_t)dataSize);
    [values enumerateValuesWithBlock:^(int64_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeSInt64NoTag:value];
    }];
  } else {
    [values enumerateValuesWithBlock:^(int64_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeSInt64:fieldNumber value:value];
    }];
  }
}

//%PDDM-EXPAND WRITE_PACKABLE_DEFNS(SFixed64, Int64, int64_t, )
// This block of code is generated, do not edit it directly.

- (void)writeSFixed64Array:(int32_t)fieldNumber
                    values:(_GPBInt64Array *)values
                       tag:(uint32_t)tag {
  if (tag != 0) {
    if (values.count == 0) return;
    __block size_t dataSize = 0;
    [values enumerateValuesWithBlock:^(int64_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      dataSize += _GPBComputeSFixed64SizeNoTag(value);
    }];
    _GPBWriteRawVarint32(&state_, tag);
    _GPBWriteRawVarint32(&state_, (int32_t)dataSize);
    [values enumerateValuesWithBlock:^(int64_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeSFixed64NoTag:value];
    }];
  } else {
    [values enumerateValuesWithBlock:^(int64_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeSFixed64:fieldNumber value:value];
    }];
  }
}

//%PDDM-EXPAND WRITE_PACKABLE_DEFNS(SFixed32, Int32, int32_t, )
// This block of code is generated, do not edit it directly.

- (void)writeSFixed32Array:(int32_t)fieldNumber
                    values:(_GPBInt32Array *)values
                       tag:(uint32_t)tag {
  if (tag != 0) {
    if (values.count == 0) return;
    __block size_t dataSize = 0;
    [values enumerateValuesWithBlock:^(int32_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      dataSize += _GPBComputeSFixed32SizeNoTag(value);
    }];
    _GPBWriteRawVarint32(&state_, tag);
    _GPBWriteRawVarint32(&state_, (int32_t)dataSize);
    [values enumerateValuesWithBlock:^(int32_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeSFixed32NoTag:value];
    }];
  } else {
    [values enumerateValuesWithBlock:^(int32_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeSFixed32:fieldNumber value:value];
    }];
  }
}

//%PDDM-EXPAND WRITE_PACKABLE_DEFNS(Bool, Bool, BOOL, )
// This block of code is generated, do not edit it directly.

- (void)writeBoolArray:(int32_t)fieldNumber
                values:(_GPBBoolArray *)values
                   tag:(uint32_t)tag {
  if (tag != 0) {
    if (values.count == 0) return;
    __block size_t dataSize = 0;
    [values enumerateValuesWithBlock:^(BOOL value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      dataSize += _GPBComputeBoolSizeNoTag(value);
    }];
    _GPBWriteRawVarint32(&state_, tag);
    _GPBWriteRawVarint32(&state_, (int32_t)dataSize);
    [values enumerateValuesWithBlock:^(BOOL value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeBoolNoTag:value];
    }];
  } else {
    [values enumerateValuesWithBlock:^(BOOL value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeBool:fieldNumber value:value];
    }];
  }
}

//%PDDM-EXPAND WRITE_PACKABLE_DEFNS(Enum, Enum, int32_t, Raw)
// This block of code is generated, do not edit it directly.

- (void)writeEnumArray:(int32_t)fieldNumber
                values:(_GPBEnumArray *)values
                   tag:(uint32_t)tag {
  if (tag != 0) {
    if (values.count == 0) return;
    __block size_t dataSize = 0;
    [values enumerateRawValuesWithBlock:^(int32_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      dataSize += _GPBComputeEnumSizeNoTag(value);
    }];
    _GPBWriteRawVarint32(&state_, tag);
    _GPBWriteRawVarint32(&state_, (int32_t)dataSize);
    [values enumerateRawValuesWithBlock:^(int32_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeEnumNoTag:value];
    }];
  } else {
    [values enumerateRawValuesWithBlock:^(int32_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
      [self writeEnum:fieldNumber value:value];
    }];
  }
}

//%PDDM-EXPAND WRITE_UNPACKABLE_DEFNS(String, NSString)
// This block of code is generated, do not edit it directly.

- (void)writeStringArray:(int32_t)fieldNumber values:(NSArray *)values {
  for (NSString *value in values) {
    [self writeString:fieldNumber value:value];
  }
}

//%PDDM-EXPAND WRITE_UNPACKABLE_DEFNS(Message, _GPBMessage)
// This block of code is generated, do not edit it directly.

- (void)writeMessageArray:(int32_t)fieldNumber values:(NSArray *)values {
  for (_GPBMessage *value in values) {
    [self writeMessage:fieldNumber value:value];
  }
}

//%PDDM-EXPAND WRITE_UNPACKABLE_DEFNS(Bytes, NSData)
// This block of code is generated, do not edit it directly.

- (void)writeBytesArray:(int32_t)fieldNumber values:(NSArray *)values {
  for (NSData *value in values) {
    [self writeBytes:fieldNumber value:value];
  }
}

//%PDDM-EXPAND WRITE_UNPACKABLE_DEFNS(Group, _GPBMessage)
// This block of code is generated, do not edit it directly.

- (void)writeGroupArray:(int32_t)fieldNumber values:(NSArray *)values {
  for (_GPBMessage *value in values) {
    [self writeGroup:fieldNumber value:value];
  }
}

//%PDDM-EXPAND WRITE_UNPACKABLE_DEFNS(UnknownGroup, _GPBUnknownFieldSet)
// This block of code is generated, do not edit it directly.

- (void)writeUnknownGroupArray:(int32_t)fieldNumber values:(NSArray *)values {
  for (_GPBUnknownFieldSet *value in values) {
    [self writeUnknownGroup:fieldNumber value:value];
  }
}

//%PDDM-EXPAND-END (19 expansions)

- (void)writeMessageSetExtension:(int32_t)fieldNumber
                           value:(_GPBMessage *)value {
  _GPBWriteTagWithFormat(&state_, _GPBWireFormatMessageSetItem,
                        _GPBWireFormatStartGroup);
  _GPBWriteUInt32(&state_, _GPBWireFormatMessageSetTypeId, fieldNumber);
  [self writeMessage:_GPBWireFormatMessageSetMessage value:value];
  _GPBWriteTagWithFormat(&state_, _GPBWireFormatMessageSetItem,
                        _GPBWireFormatEndGroup);
}

- (void)writeRawMessageSetExtension:(int32_t)fieldNumber value:(NSData *)value {
  _GPBWriteTagWithFormat(&state_, _GPBWireFormatMessageSetItem,
                        _GPBWireFormatStartGroup);
  _GPBWriteUInt32(&state_, _GPBWireFormatMessageSetTypeId, fieldNumber);
  [self writeBytes:_GPBWireFormatMessageSetMessage value:value];
  _GPBWriteTagWithFormat(&state_, _GPBWireFormatMessageSetItem,
                        _GPBWireFormatEndGroup);
}

- (void)flush {
  if (state_.output != nil) {
    _GPBRefreshBuffer(&state_);
  }
}

- (void)writeRawByte:(uint8_t)value {
  _GPBWriteRawByte(&state_, value);
}

- (void)writeRawData:(const NSData *)data {
  [self writeRawPtr:[data bytes] offset:0 length:[data length]];
}

- (void)writeRawPtr:(const void *)value
             offset:(size_t)offset
             length:(size_t)length {
  if (value == nil || length == 0) {
    return;
  }

  NSUInteger bufferLength = state_.size;
  NSUInteger bufferBytesLeft = bufferLength - state_.position;
  if (bufferBytesLeft >= length) {
    // We have room in the current buffer.
    memcpy(state_.bytes + state_.position, ((uint8_t *)value) + offset, length);
    state_.position += length;
  } else {
    // Write extends past current buffer.  Fill the rest of this buffer and
    // flush.
    size_t bytesWritten = bufferBytesLeft;
    memcpy(state_.bytes + state_.position, ((uint8_t *)value) + offset,
           bytesWritten);
    offset += bytesWritten;
    length -= bytesWritten;
    state_.position = bufferLength;
    _GPBRefreshBuffer(&state_);
    bufferLength = state_.size;

    // Now deal with the rest.
    // Since we have an output stream, this is our buffer
    // and buffer offset == 0
    if (length <= bufferLength) {
      // Fits in new buffer.
      memcpy(state_.bytes, ((uint8_t *)value) + offset, length);
      state_.position = length;
    } else {
      // Write is very big.  Let's do it all at once.
      NSInteger written = [state_.output write:((uint8_t *)value) + offset maxLength:length];
      if (written != (NSInteger)length) {
        [NSException raise:_GPBCodedOutputStreamException_WriteFailed format:@""];
      }
    }
  }
}

- (void)writeTag:(uint32_t)fieldNumber format:(_GPBWireFormat)format {
  _GPBWriteTagWithFormat(&state_, fieldNumber, format);
}

- (void)writeRawVarint32:(int32_t)value {
  _GPBWriteRawVarint32(&state_, value);
}

- (void)writeRawVarintSizeTAs32:(size_t)value {
  // Note the truncation.
  _GPBWriteRawVarint32(&state_, (int32_t)value);
}

- (void)writeRawVarint64:(int64_t)value {
  _GPBWriteRawVarint64(&state_, value);
}

- (void)writeRawLittleEndian32:(int32_t)value {
  _GPBWriteRawLittleEndian32(&state_, value);
}

- (void)writeRawLittleEndian64:(int64_t)value {
  _GPBWriteRawLittleEndian64(&state_, value);
}

#pragma clang diagnostic pop

@end

size_t _GPBComputeDoubleSizeNoTag(Float64 value) {
#pragma unused(value)
  return LITTLE_ENDIAN_64_SIZE;
}

size_t _GPBComputeFloatSizeNoTag(Float32 value) {
#pragma unused(value)
  return LITTLE_ENDIAN_32_SIZE;
}

size_t _GPBComputeUInt64SizeNoTag(uint64_t value) {
  return _GPBComputeRawVarint64Size(value);
}

size_t _GPBComputeInt64SizeNoTag(int64_t value) {
  return _GPBComputeRawVarint64Size(value);
}

size_t _GPBComputeInt32SizeNoTag(int32_t value) {
  if (value >= 0) {
    return _GPBComputeRawVarint32Size(value);
  } else {
    // Must sign-extend.
    return 10;
  }
}

size_t _GPBComputeSizeTSizeAsInt32NoTag(size_t value) {
  return _GPBComputeInt32SizeNoTag((int32_t)value);
}

size_t _GPBComputeFixed64SizeNoTag(uint64_t value) {
#pragma unused(value)
  return LITTLE_ENDIAN_64_SIZE;
}

size_t _GPBComputeFixed32SizeNoTag(uint32_t value) {
#pragma unused(value)
  return LITTLE_ENDIAN_32_SIZE;
}

size_t _GPBComputeBoolSizeNoTag(BOOL value) {
#pragma unused(value)
  return 1;
}

size_t _GPBComputeStringSizeNoTag(NSString *value) {
  NSUInteger length = [value lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
  return _GPBComputeRawVarint32SizeForInteger(length) + length;
}

size_t _GPBComputeGroupSizeNoTag(_GPBMessage *value) {
  return [value serializedSize];
}

size_t _GPBComputeUnknownGroupSizeNoTag(_GPBUnknownFieldSet *value) {
  return value.serializedSize;
}

size_t _GPBComputeMessageSizeNoTag(_GPBMessage *value) {
  size_t size = [value serializedSize];
  return _GPBComputeRawVarint32SizeForInteger(size) + size;
}

size_t _GPBComputeBytesSizeNoTag(NSData *value) {
  NSUInteger valueLength = [value length];
  return _GPBComputeRawVarint32SizeForInteger(valueLength) + valueLength;
}

size_t _GPBComputeUInt32SizeNoTag(int32_t value) {
  return _GPBComputeRawVarint32Size(value);
}

size_t _GPBComputeEnumSizeNoTag(int32_t value) {
  return _GPBComputeInt32SizeNoTag(value);
}

size_t _GPBComputeSFixed32SizeNoTag(int32_t value) {
#pragma unused(value)
  return LITTLE_ENDIAN_32_SIZE;
}

size_t _GPBComputeSFixed64SizeNoTag(int64_t value) {
#pragma unused(value)
  return LITTLE_ENDIAN_64_SIZE;
}

size_t _GPBComputeSInt32SizeNoTag(int32_t value) {
  return _GPBComputeRawVarint32Size(_GPBEncodeZigZag32(value));
}

size_t _GPBComputeSInt64SizeNoTag(int64_t value) {
  return _GPBComputeRawVarint64Size(_GPBEncodeZigZag64(value));
}

size_t _GPBComputeDoubleSize(int32_t fieldNumber, double value) {
  return _GPBComputeTagSize(fieldNumber) + _GPBComputeDoubleSizeNoTag(value);
}

size_t _GPBComputeFloatSize(int32_t fieldNumber, float value) {
  return _GPBComputeTagSize(fieldNumber) + _GPBComputeFloatSizeNoTag(value);
}

size_t _GPBComputeUInt64Size(int32_t fieldNumber, uint64_t value) {
  return _GPBComputeTagSize(fieldNumber) + _GPBComputeUInt64SizeNoTag(value);
}

size_t _GPBComputeInt64Size(int32_t fieldNumber, int64_t value) {
  return _GPBComputeTagSize(fieldNumber) + _GPBComputeInt64SizeNoTag(value);
}

size_t _GPBComputeInt32Size(int32_t fieldNumber, int32_t value) {
  return _GPBComputeTagSize(fieldNumber) + _GPBComputeInt32SizeNoTag(value);
}

size_t _GPBComputeFixed64Size(int32_t fieldNumber, uint64_t value) {
  return _GPBComputeTagSize(fieldNumber) + _GPBComputeFixed64SizeNoTag(value);
}

size_t _GPBComputeFixed32Size(int32_t fieldNumber, uint32_t value) {
  return _GPBComputeTagSize(fieldNumber) + _GPBComputeFixed32SizeNoTag(value);
}

size_t _GPBComputeBoolSize(int32_t fieldNumber, BOOL value) {
  return _GPBComputeTagSize(fieldNumber) + _GPBComputeBoolSizeNoTag(value);
}

size_t _GPBComputeStringSize(int32_t fieldNumber, NSString *value) {
  return _GPBComputeTagSize(fieldNumber) + _GPBComputeStringSizeNoTag(value);
}

size_t _GPBComputeGroupSize(int32_t fieldNumber, _GPBMessage *value) {
  return _GPBComputeTagSize(fieldNumber) * 2 + _GPBComputeGroupSizeNoTag(value);
}

size_t _GPBComputeUnknownGroupSize(int32_t fieldNumber,
                                  _GPBUnknownFieldSet *value) {
  return _GPBComputeTagSize(fieldNumber) * 2 +
         _GPBComputeUnknownGroupSizeNoTag(value);
}

size_t _GPBComputeMessageSize(int32_t fieldNumber, _GPBMessage *value) {
  return _GPBComputeTagSize(fieldNumber) + _GPBComputeMessageSizeNoTag(value);
}

size_t _GPBComputeBytesSize(int32_t fieldNumber, NSData *value) {
  return _GPBComputeTagSize(fieldNumber) + _GPBComputeBytesSizeNoTag(value);
}

size_t _GPBComputeUInt32Size(int32_t fieldNumber, uint32_t value) {
  return _GPBComputeTagSize(fieldNumber) + _GPBComputeUInt32SizeNoTag(value);
}

size_t _GPBComputeEnumSize(int32_t fieldNumber, int32_t value) {
  return _GPBComputeTagSize(fieldNumber) + _GPBComputeEnumSizeNoTag(value);
}

size_t _GPBComputeSFixed32Size(int32_t fieldNumber, int32_t value) {
  return _GPBComputeTagSize(fieldNumber) + _GPBComputeSFixed32SizeNoTag(value);
}

size_t _GPBComputeSFixed64Size(int32_t fieldNumber, int64_t value) {
  return _GPBComputeTagSize(fieldNumber) + _GPBComputeSFixed64SizeNoTag(value);
}

size_t _GPBComputeSInt32Size(int32_t fieldNumber, int32_t value) {
  return _GPBComputeTagSize(fieldNumber) + _GPBComputeSInt32SizeNoTag(value);
}

size_t _GPBComputeSInt64Size(int32_t fieldNumber, int64_t value) {
  return _GPBComputeTagSize(fieldNumber) +
         _GPBComputeRawVarint64Size(_GPBEncodeZigZag64(value));
}

size_t _GPBComputeMessageSetExtensionSize(int32_t fieldNumber,
                                         _GPBMessage *value) {
  return _GPBComputeTagSize(_GPBWireFormatMessageSetItem) * 2 +
         _GPBComputeUInt32Size(_GPBWireFormatMessageSetTypeId, fieldNumber) +
         _GPBComputeMessageSize(_GPBWireFormatMessageSetMessage, value);
}

size_t _GPBComputeRawMessageSetExtensionSize(int32_t fieldNumber,
                                            NSData *value) {
  return _GPBComputeTagSize(_GPBWireFormatMessageSetItem) * 2 +
         _GPBComputeUInt32Size(_GPBWireFormatMessageSetTypeId, fieldNumber) +
         _GPBComputeBytesSize(_GPBWireFormatMessageSetMessage, value);
}

size_t _GPBComputeTagSize(int32_t fieldNumber) {
  return _GPBComputeRawVarint32Size(
      _GPBWireFormatMakeTag(fieldNumber, _GPBWireFormatVarint));
}

size_t _GPBComputeWireFormatTagSize(int field_number, _GPBDataType dataType) {
  size_t result = _GPBComputeTagSize(field_number);
  if (dataType == _GPBDataTypeGroup) {
    // Groups have both a start and an end tag.
    return result * 2;
  } else {
    return result;
  }
}

size_t _GPBComputeRawVarint32Size(int32_t value) {
  // value is treated as unsigned, so it won't be sign-extended if negative.
  if ((value & (0xffffffff << 7)) == 0) return 1;
  if ((value & (0xffffffff << 14)) == 0) return 2;
  if ((value & (0xffffffff << 21)) == 0) return 3;
  if ((value & (0xffffffff << 28)) == 0) return 4;
  return 5;
}

size_t _GPBComputeRawVarint32SizeForInteger(NSInteger value) {
  // Note the truncation.
  return _GPBComputeRawVarint32Size((int32_t)value);
}

size_t _GPBComputeRawVarint64Size(int64_t value) {
  if ((value & (0xffffffffffffffffL << 7)) == 0) return 1;
  if ((value & (0xffffffffffffffffL << 14)) == 0) return 2;
  if ((value & (0xffffffffffffffffL << 21)) == 0) return 3;
  if ((value & (0xffffffffffffffffL << 28)) == 0) return 4;
  if ((value & (0xffffffffffffffffL << 35)) == 0) return 5;
  if ((value & (0xffffffffffffffffL << 42)) == 0) return 6;
  if ((value & (0xffffffffffffffffL << 49)) == 0) return 7;
  if ((value & (0xffffffffffffffffL << 56)) == 0) return 8;
  if ((value & (0xffffffffffffffffL << 63)) == 0) return 9;
  return 10;
}
