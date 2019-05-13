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
