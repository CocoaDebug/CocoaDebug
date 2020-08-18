//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_GPBWireFormat.h"

#import "_GPBUtilities_PackagePrivate.h"

enum {
  _GPBWireFormatTagTypeBits = 3,
  _GPBWireFormatTagTypeMask = 7 /* = (1 << _GPBWireFormatTagTypeBits) - 1 */,
};

uint32_t _GPBWireFormatMakeTag(uint32_t fieldNumber, _GPBWireFormat wireType) {
  return (fieldNumber << _GPBWireFormatTagTypeBits) | wireType;
}

_GPBWireFormat _GPBWireFormatGetTagWireType(uint32_t tag) {
  return (_GPBWireFormat)(tag & _GPBWireFormatTagTypeMask);
}

uint32_t _GPBWireFormatGetTagFieldNumber(uint32_t tag) {
  return _GPBLogicalRightShift32(tag, _GPBWireFormatTagTypeBits);
}

BOOL _GPBWireFormatIsValidTag(uint32_t tag) {
  uint32_t formatBits = (tag & _GPBWireFormatTagTypeMask);
  // The valid _GPBWireFormat* values are 0-5, anything else is not a valid tag.
  BOOL result = (formatBits <= 5);
  return result;
}

_GPBWireFormat _GPBWireFormatForType(_GPBDataType type, BOOL isPacked) {
  if (isPacked) {
    return _GPBWireFormatLengthDelimited;
  }

  static const _GPBWireFormat format[_GPBDataType_Count] = {
      _GPBWireFormatVarint,           // _GPBDataTypeBool
      _GPBWireFormatFixed32,          // _GPBDataTypeFixed32
      _GPBWireFormatFixed32,          // _GPBDataTypeSFixed32
      _GPBWireFormatFixed32,          // _GPBDataTypeFloat
      _GPBWireFormatFixed64,          // _GPBDataTypeFixed64
      _GPBWireFormatFixed64,          // _GPBDataTypeSFixed64
      _GPBWireFormatFixed64,          // _GPBDataTypeDouble
      _GPBWireFormatVarint,           // _GPBDataTypeInt32
      _GPBWireFormatVarint,           // _GPBDataTypeInt64
      _GPBWireFormatVarint,           // _GPBDataTypeSInt32
      _GPBWireFormatVarint,           // _GPBDataTypeSInt64
      _GPBWireFormatVarint,           // _GPBDataTypeUInt32
      _GPBWireFormatVarint,           // _GPBDataTypeUInt64
      _GPBWireFormatLengthDelimited,  // _GPBDataTypeBytes
      _GPBWireFormatLengthDelimited,  // _GPBDataTypeString
      _GPBWireFormatLengthDelimited,  // _GPBDataTypeMessage
      _GPBWireFormatStartGroup,       // _GPBDataTypeGroup
      _GPBWireFormatVarint            // _GPBDataTypeEnum
  };
  return format[type];
}
