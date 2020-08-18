//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_GPBCodedOutputStream.h"

NS_ASSUME_NONNULL_BEGIN

CF_EXTERN_C_BEGIN

size_t _GPBComputeDoubleSize(int32_t fieldNumber, double value)
    __attribute__((const));
size_t _GPBComputeFloatSize(int32_t fieldNumber, float value)
    __attribute__((const));
size_t _GPBComputeUInt64Size(int32_t fieldNumber, uint64_t value)
    __attribute__((const));
size_t _GPBComputeInt64Size(int32_t fieldNumber, int64_t value)
    __attribute__((const));
size_t _GPBComputeInt32Size(int32_t fieldNumber, int32_t value)
    __attribute__((const));
size_t _GPBComputeFixed64Size(int32_t fieldNumber, uint64_t value)
    __attribute__((const));
size_t _GPBComputeFixed32Size(int32_t fieldNumber, uint32_t value)
    __attribute__((const));
size_t _GPBComputeBoolSize(int32_t fieldNumber, BOOL value)
    __attribute__((const));
size_t _GPBComputeStringSize(int32_t fieldNumber, NSString *value)
    __attribute__((const));
size_t _GPBComputeGroupSize(int32_t fieldNumber, _GPBMessage *value)
    __attribute__((const));
size_t _GPBComputeUnknownGroupSize(int32_t fieldNumber,
                                  _GPBUnknownFieldSet *value)
    __attribute__((const));
size_t _GPBComputeMessageSize(int32_t fieldNumber, _GPBMessage *value)
    __attribute__((const));
size_t _GPBComputeBytesSize(int32_t fieldNumber, NSData *value)
    __attribute__((const));
size_t _GPBComputeUInt32Size(int32_t fieldNumber, uint32_t value)
    __attribute__((const));
size_t _GPBComputeSFixed32Size(int32_t fieldNumber, int32_t value)
    __attribute__((const));
size_t _GPBComputeSFixed64Size(int32_t fieldNumber, int64_t value)
    __attribute__((const));
size_t _GPBComputeSInt32Size(int32_t fieldNumber, int32_t value)
    __attribute__((const));
size_t _GPBComputeSInt64Size(int32_t fieldNumber, int64_t value)
    __attribute__((const));
size_t _GPBComputeTagSize(int32_t fieldNumber) __attribute__((const));
size_t _GPBComputeWireFormatTagSize(int field_number, _GPBDataType dataType)
    __attribute__((const));

size_t _GPBComputeDoubleSizeNoTag(double value) __attribute__((const));
size_t _GPBComputeFloatSizeNoTag(float value) __attribute__((const));
size_t _GPBComputeUInt64SizeNoTag(uint64_t value) __attribute__((const));
size_t _GPBComputeInt64SizeNoTag(int64_t value) __attribute__((const));
size_t _GPBComputeInt32SizeNoTag(int32_t value) __attribute__((const));
size_t _GPBComputeFixed64SizeNoTag(uint64_t value) __attribute__((const));
size_t _GPBComputeFixed32SizeNoTag(uint32_t value) __attribute__((const));
size_t _GPBComputeBoolSizeNoTag(BOOL value) __attribute__((const));
size_t _GPBComputeStringSizeNoTag(NSString *value) __attribute__((const));
size_t _GPBComputeGroupSizeNoTag(_GPBMessage *value) __attribute__((const));
size_t _GPBComputeUnknownGroupSizeNoTag(_GPBUnknownFieldSet *value)
    __attribute__((const));
size_t _GPBComputeMessageSizeNoTag(_GPBMessage *value) __attribute__((const));
size_t _GPBComputeBytesSizeNoTag(NSData *value) __attribute__((const));
size_t _GPBComputeUInt32SizeNoTag(int32_t value) __attribute__((const));
size_t _GPBComputeEnumSizeNoTag(int32_t value) __attribute__((const));
size_t _GPBComputeSFixed32SizeNoTag(int32_t value) __attribute__((const));
size_t _GPBComputeSFixed64SizeNoTag(int64_t value) __attribute__((const));
size_t _GPBComputeSInt32SizeNoTag(int32_t value) __attribute__((const));
size_t _GPBComputeSInt64SizeNoTag(int64_t value) __attribute__((const));

// Note that this will calculate the size of 64 bit values truncated to 32.
size_t _GPBComputeSizeTSizeAsInt32NoTag(size_t value) __attribute__((const));

size_t _GPBComputeRawVarint32Size(int32_t value) __attribute__((const));
size_t _GPBComputeRawVarint64Size(int64_t value) __attribute__((const));

// Note that this will calculate the size of 64 bit values truncated to 32.
size_t _GPBComputeRawVarint32SizeForInteger(NSInteger value)
    __attribute__((const));

// Compute the number of bytes that would be needed to encode a
// MessageSet extension to the stream.  For historical reasons,
// the wire format differs from normal fields.
size_t _GPBComputeMessageSetExtensionSize(int32_t fieldNumber, _GPBMessage *value)
    __attribute__((const));

// Compute the number of bytes that would be needed to encode an
// unparsed MessageSet extension field to the stream.  For
// historical reasons, the wire format differs from normal fields.
size_t _GPBComputeRawMessageSetExtensionSize(int32_t fieldNumber, NSData *value)
    __attribute__((const));

size_t _GPBComputeEnumSize(int32_t fieldNumber, int32_t value)
    __attribute__((const));

CF_EXTERN_C_END

NS_ASSUME_NONNULL_END
