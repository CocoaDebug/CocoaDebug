//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_GPBExtensionInternals.h"

#import <objc/runtime.h>

#import "_GPBCodedInputStream_PackagePrivate.h"
#import "_GPBCodedOutputStream_PackagePrivate.h"
#import "_GPBDescriptor_PackagePrivate.h"
#import "_GPBMessage_PackagePrivate.h"
#import "_GPBUtilities_PackagePrivate.h"

static id NewSingleValueFromInputStream(_GPBExtensionDescriptor *extension,
                                        _GPBCodedInputStream *input,
                                        _GPBExtensionRegistry *extensionRegistry,
                                        _GPBMessage *existingValue)
    __attribute__((ns_returns_retained));

_GPB_INLINE size_t DataTypeSize(_GPBDataType dataType) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wswitch-enum"
  switch (dataType) {
    case _GPBDataTypeBool:
      return 1;
    case _GPBDataTypeFixed32:
    case _GPBDataTypeSFixed32:
    case _GPBDataTypeFloat:
      return 4;
    case _GPBDataTypeFixed64:
    case _GPBDataTypeSFixed64:
    case _GPBDataTypeDouble:
      return 8;
    default:
      return 0;
  }
#pragma clang diagnostic pop
}

static size_t ComputePBSerializedSizeNoTagOfObject(_GPBDataType dataType, id object) {
#define FIELD_CASE(TYPE, ACCESSOR)                                     \
  case _GPBDataType##TYPE:                                              \
    return _GPBCompute##TYPE##SizeNoTag([(NSNumber *)object ACCESSOR]);
#define FIELD_CASE2(TYPE)                                              \
  case _GPBDataType##TYPE:                                              \
    return _GPBCompute##TYPE##SizeNoTag(object);
  switch (dataType) {
    FIELD_CASE(Bool, boolValue)
    FIELD_CASE(Float, floatValue)
    FIELD_CASE(Double, doubleValue)
    FIELD_CASE(Int32, intValue)
    FIELD_CASE(SFixed32, intValue)
    FIELD_CASE(SInt32, intValue)
    FIELD_CASE(Enum, intValue)
    FIELD_CASE(Int64, longLongValue)
    FIELD_CASE(SInt64, longLongValue)
    FIELD_CASE(SFixed64, longLongValue)
    FIELD_CASE(UInt32, unsignedIntValue)
    FIELD_CASE(Fixed32, unsignedIntValue)
    FIELD_CASE(UInt64, unsignedLongLongValue)
    FIELD_CASE(Fixed64, unsignedLongLongValue)
    FIELD_CASE2(Bytes)
    FIELD_CASE2(String)
    FIELD_CASE2(Message)
    FIELD_CASE2(Group)
  }
#undef FIELD_CASE
#undef FIELD_CASE2
}

static size_t ComputeSerializedSizeIncludingTagOfObject(
    _GPBExtensionDescription *description, id object) {
#define FIELD_CASE(TYPE, ACCESSOR)                                   \
  case _GPBDataType##TYPE:                                            \
    return _GPBCompute##TYPE##Size(description->fieldNumber,          \
                                  [(NSNumber *)object ACCESSOR]);
#define FIELD_CASE2(TYPE)                                            \
  case _GPBDataType##TYPE:                                            \
    return _GPBCompute##TYPE##Size(description->fieldNumber, object);
  switch (description->dataType) {
    FIELD_CASE(Bool, boolValue)
    FIELD_CASE(Float, floatValue)
    FIELD_CASE(Double, doubleValue)
    FIELD_CASE(Int32, intValue)
    FIELD_CASE(SFixed32, intValue)
    FIELD_CASE(SInt32, intValue)
    FIELD_CASE(Enum, intValue)
    FIELD_CASE(Int64, longLongValue)
    FIELD_CASE(SInt64, longLongValue)
    FIELD_CASE(SFixed64, longLongValue)
    FIELD_CASE(UInt32, unsignedIntValue)
    FIELD_CASE(Fixed32, unsignedIntValue)
    FIELD_CASE(UInt64, unsignedLongLongValue)
    FIELD_CASE(Fixed64, unsignedLongLongValue)
    FIELD_CASE2(Bytes)
    FIELD_CASE2(String)
    FIELD_CASE2(Group)
    case _GPBDataTypeMessage:
      if (_GPBExtensionIsWireFormat(description)) {
        return _GPBComputeMessageSetExtensionSize(description->fieldNumber,
                                                 object);
      } else {
        return _GPBComputeMessageSize(description->fieldNumber, object);
      }
  }
#undef FIELD_CASE
#undef FIELD_CASE2
}

static size_t ComputeSerializedSizeIncludingTagOfArray(
    _GPBExtensionDescription *description, NSArray *values) {
  if (_GPBExtensionIsPacked(description)) {
    size_t size = 0;
    size_t typeSize = DataTypeSize(description->dataType);
    if (typeSize != 0) {
      size = values.count * typeSize;
    } else {
      for (id value in values) {
        size +=
            ComputePBSerializedSizeNoTagOfObject(description->dataType, value);
      }
    }
    return size + _GPBComputeTagSize(description->fieldNumber) +
           _GPBComputeRawVarint32SizeForInteger(size);
  } else {
    size_t size = 0;
    for (id value in values) {
      size += ComputeSerializedSizeIncludingTagOfObject(description, value);
    }
    return size;
  }
}

static void WriteObjectIncludingTagToCodedOutputStream(
    id object, _GPBExtensionDescription *description,
    _GPBCodedOutputStream *output) {
#define FIELD_CASE(TYPE, ACCESSOR)                      \
  case _GPBDataType##TYPE:                               \
    [output write##TYPE:description->fieldNumber        \
                  value:[(NSNumber *)object ACCESSOR]]; \
    return;
#define FIELD_CASE2(TYPE)                                       \
  case _GPBDataType##TYPE:                                       \
    [output write##TYPE:description->fieldNumber value:object]; \
    return;
  switch (description->dataType) {
    FIELD_CASE(Bool, boolValue)
    FIELD_CASE(Float, floatValue)
    FIELD_CASE(Double, doubleValue)
    FIELD_CASE(Int32, intValue)
    FIELD_CASE(SFixed32, intValue)
    FIELD_CASE(SInt32, intValue)
    FIELD_CASE(Enum, intValue)
    FIELD_CASE(Int64, longLongValue)
    FIELD_CASE(SInt64, longLongValue)
    FIELD_CASE(SFixed64, longLongValue)
    FIELD_CASE(UInt32, unsignedIntValue)
    FIELD_CASE(Fixed32, unsignedIntValue)
    FIELD_CASE(UInt64, unsignedLongLongValue)
    FIELD_CASE(Fixed64, unsignedLongLongValue)
    FIELD_CASE2(Bytes)
    FIELD_CASE2(String)
    FIELD_CASE2(Group)
    case _GPBDataTypeMessage:
      if (_GPBExtensionIsWireFormat(description)) {
        [output writeMessageSetExtension:description->fieldNumber value:object];
      } else {
        [output writeMessage:description->fieldNumber value:object];
      }
      return;
  }
#undef FIELD_CASE
#undef FIELD_CASE2
}

static void WriteObjectNoTagToCodedOutputStream(
    id object, _GPBExtensionDescription *description,
    _GPBCodedOutputStream *output) {
#define FIELD_CASE(TYPE, ACCESSOR)                             \
  case _GPBDataType##TYPE:                                      \
    [output write##TYPE##NoTag:[(NSNumber *)object ACCESSOR]]; \
    return;
#define FIELD_CASE2(TYPE)               \
  case _GPBDataType##TYPE:               \
    [output write##TYPE##NoTag:object]; \
    return;
  switch (description->dataType) {
    FIELD_CASE(Bool, boolValue)
    FIELD_CASE(Float, floatValue)
    FIELD_CASE(Double, doubleValue)
    FIELD_CASE(Int32, intValue)
    FIELD_CASE(SFixed32, intValue)
    FIELD_CASE(SInt32, intValue)
    FIELD_CASE(Enum, intValue)
    FIELD_CASE(Int64, longLongValue)
    FIELD_CASE(SInt64, longLongValue)
    FIELD_CASE(SFixed64, longLongValue)
    FIELD_CASE(UInt32, unsignedIntValue)
    FIELD_CASE(Fixed32, unsignedIntValue)
    FIELD_CASE(UInt64, unsignedLongLongValue)
    FIELD_CASE(Fixed64, unsignedLongLongValue)
    FIELD_CASE2(Bytes)
    FIELD_CASE2(String)
    FIELD_CASE2(Message)
    case _GPBDataTypeGroup:
      [output writeGroupNoTag:description->fieldNumber value:object];
      return;
  }
#undef FIELD_CASE
#undef FIELD_CASE2
}

static void WriteArrayIncludingTagsToCodedOutputStream(
    NSArray *values, _GPBExtensionDescription *description,
    _GPBCodedOutputStream *output) {
  if (_GPBExtensionIsPacked(description)) {
    [output writeTag:description->fieldNumber
              format:_GPBWireFormatLengthDelimited];
    size_t dataSize = 0;
    size_t typeSize = DataTypeSize(description->dataType);
    if (typeSize != 0) {
      dataSize = values.count * typeSize;
    } else {
      for (id value in values) {
        dataSize +=
            ComputePBSerializedSizeNoTagOfObject(description->dataType, value);
      }
    }
    [output writeRawVarintSizeTAs32:dataSize];
    for (id value in values) {
      WriteObjectNoTagToCodedOutputStream(value, description, output);
    }
  } else {
    for (id value in values) {
      WriteObjectIncludingTagToCodedOutputStream(value, description, output);
    }
  }
}

// Direct access is use for speed, to avoid even internally declaring things
// read/write, etc. The warning is enabled in the project to ensure code calling
// protos can turn on -Wdirect-ivar-access without issues.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"

void _GPBExtensionMergeFromInputStream(_GPBExtensionDescriptor *extension,
                                      BOOL isPackedOnStream,
                                      _GPBCodedInputStream *input,
                                      _GPBExtensionRegistry *extensionRegistry,
                                      _GPBMessage *message) {
  _GPBExtensionDescription *description = extension->description_;
  _GPBCodedInputStreamState *state = &input->state_;
  if (isPackedOnStream) {
    NSCAssert(_GPBExtensionIsRepeated(description),
              @"How was it packed if it isn't repeated?");
    int32_t length = _GPBCodedInputStreamReadInt32(state);
    size_t limit = _GPBCodedInputStreamPushLimit(state, length);
    while (_GPBCodedInputStreamBytesUntilLimit(state) > 0) {
      id value = NewSingleValueFromInputStream(extension,
                                               input,
                                               extensionRegistry,
                                               nil);
      [message addExtension:extension value:value];
      [value release];
    }
    _GPBCodedInputStreamPopLimit(state, limit);
  } else {
    id existingValue = nil;
    BOOL isRepeated = _GPBExtensionIsRepeated(description);
    if (!isRepeated && _GPBDataTypeIsMessage(description->dataType)) {
      existingValue = [message getExistingExtension:extension];
    }
    id value = NewSingleValueFromInputStream(extension,
                                             input,
                                             extensionRegistry,
                                             existingValue);
    if (isRepeated) {
      [message addExtension:extension value:value];
    } else {
      [message setExtension:extension value:value];
    }
    [value release];
  }
}

void _GPBWriteExtensionValueToOutputStream(_GPBExtensionDescriptor *extension,
                                          id value,
                                          _GPBCodedOutputStream *output) {
  _GPBExtensionDescription *description = extension->description_;
  if (_GPBExtensionIsRepeated(description)) {
    WriteArrayIncludingTagsToCodedOutputStream(value, description, output);
  } else {
    WriteObjectIncludingTagToCodedOutputStream(value, description, output);
  }
}

size_t _GPBComputeExtensionSerializedSizeIncludingTag(
    _GPBExtensionDescriptor *extension, id value) {
  _GPBExtensionDescription *description = extension->description_;
  if (_GPBExtensionIsRepeated(description)) {
    return ComputeSerializedSizeIncludingTagOfArray(description, value);
  } else {
    return ComputeSerializedSizeIncludingTagOfObject(description, value);
  }
}

// Note that this returns a retained value intentionally.
static id NewSingleValueFromInputStream(_GPBExtensionDescriptor *extension,
                                        _GPBCodedInputStream *input,
                                        _GPBExtensionRegistry *extensionRegistry,
                                        _GPBMessage *existingValue) {
  _GPBExtensionDescription *description = extension->description_;
  _GPBCodedInputStreamState *state = &input->state_;
  switch (description->dataType) {
    case _GPBDataTypeBool:     return [[NSNumber alloc] initWithBool:_GPBCodedInputStreamReadBool(state)];
    case _GPBDataTypeFixed32:  return [[NSNumber alloc] initWithUnsignedInt:_GPBCodedInputStreamReadFixed32(state)];
    case _GPBDataTypeSFixed32: return [[NSNumber alloc] initWithInt:_GPBCodedInputStreamReadSFixed32(state)];
    case _GPBDataTypeFloat:    return [[NSNumber alloc] initWithFloat:_GPBCodedInputStreamReadFloat(state)];
    case _GPBDataTypeFixed64:  return [[NSNumber alloc] initWithUnsignedLongLong:_GPBCodedInputStreamReadFixed64(state)];
    case _GPBDataTypeSFixed64: return [[NSNumber alloc] initWithLongLong:_GPBCodedInputStreamReadSFixed64(state)];
    case _GPBDataTypeDouble:   return [[NSNumber alloc] initWithDouble:_GPBCodedInputStreamReadDouble(state)];
    case _GPBDataTypeInt32:    return [[NSNumber alloc] initWithInt:_GPBCodedInputStreamReadInt32(state)];
    case _GPBDataTypeInt64:    return [[NSNumber alloc] initWithLongLong:_GPBCodedInputStreamReadInt64(state)];
    case _GPBDataTypeSInt32:   return [[NSNumber alloc] initWithInt:_GPBCodedInputStreamReadSInt32(state)];
    case _GPBDataTypeSInt64:   return [[NSNumber alloc] initWithLongLong:_GPBCodedInputStreamReadSInt64(state)];
    case _GPBDataTypeUInt32:   return [[NSNumber alloc] initWithUnsignedInt:_GPBCodedInputStreamReadUInt32(state)];
    case _GPBDataTypeUInt64:   return [[NSNumber alloc] initWithUnsignedLongLong:_GPBCodedInputStreamReadUInt64(state)];
    case _GPBDataTypeBytes:    return _GPBCodedInputStreamReadRetainedBytes(state);
    case _GPBDataTypeString:   return _GPBCodedInputStreamReadRetainedString(state);
    case _GPBDataTypeEnum:     return [[NSNumber alloc] initWithInt:_GPBCodedInputStreamReadEnum(state)];
    case _GPBDataTypeGroup:
    case _GPBDataTypeMessage: {
      _GPBMessage *message;
      if (existingValue) {
        message = [existingValue retain];
      } else {
        _GPBDescriptor *decriptor = [extension.msgClass descriptor];
        message = [[decriptor.messageClass alloc] init];
      }

      if (description->dataType == _GPBDataTypeGroup) {
        [input readGroup:description->fieldNumber
                 message:message
            extensionRegistry:extensionRegistry];
      } else {
        // description->dataType == _GPBDataTypeMessage
        if (_GPBExtensionIsWireFormat(description)) {
          // For MessageSet fields the message length will have already been
          // read.
          [message mergeFromCodedInputStream:input
                           extensionRegistry:extensionRegistry];
        } else {
          [input readMessage:message extensionRegistry:extensionRegistry];
        }
      }

      return message;
    }
  }

  return nil;
}

#pragma clang diagnostic pop
