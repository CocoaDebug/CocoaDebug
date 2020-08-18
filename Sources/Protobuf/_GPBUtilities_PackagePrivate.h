//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "_GPBUtilities.h"

#import "_GPBDescriptor_PackagePrivate.h"

// Macros for stringifying library symbols. These are used in the generated
// PB descriptor classes wherever a library symbol name is represented as a
// string. See README.google for more information.
#define _GPBStringify(S) #S
#define _GPBStringifySymbol(S) _GPBStringify(S)

#define _GPBNSStringify(S) @#S
#define _GPBNSStringifySymbol(S) _GPBNSStringify(S)

// Constant to internally mark when there is no has bit.
#define _GPBNoHasBit INT32_MAX

CF_EXTERN_C_BEGIN

// These two are used to inject a runtime check for version mismatch into the
// generated sources to make sure they are linked with a supporting runtime.
void _GPBCheckRuntimeVersionSupport(int32_t objcRuntimeVersion);
_GPB_INLINE void _GPB_DEBUG_CHECK_RUNTIME_VERSIONS() {
  // NOTE: By being inline here, this captures the value from the library's
  // headers at the time the generated code was compiled.
#if defined(DEBUG) && DEBUG
  _GPBCheckRuntimeVersionSupport(GOOGLE_PROTOBUF_OBJC_VERSION);
#endif
}

// Legacy version of the checks, remove when GOOGLE_PROTOBUF_OBJC_GEN_VERSION
// goes away (see more info in _GPBBootstrap.h).
void _GPBCheckRuntimeVersionInternal(int32_t version);
_GPB_INLINE void _GPBDebugCheckRuntimeVersion() {
#if defined(DEBUG) && DEBUG
  _GPBCheckRuntimeVersionInternal(GOOGLE_PROTOBUF_OBJC_GEN_VERSION);
#endif
}

// Conversion functions for de/serializing floating point types.

_GPB_INLINE int64_t _GPBConvertDoubleToInt64(double v) {
  _GPBInternalCompileAssert(sizeof(double) == sizeof(int64_t), double_not_64_bits);
  int64_t result;
  memcpy(&result, &v, sizeof(result));
  return result;
}

_GPB_INLINE int32_t _GPBConvertFloatToInt32(float v) {
  _GPBInternalCompileAssert(sizeof(float) == sizeof(int32_t), float_not_32_bits);
  int32_t result;
  memcpy(&result, &v, sizeof(result));
  return result;
}

_GPB_INLINE double _GPBConvertInt64ToDouble(int64_t v) {
  _GPBInternalCompileAssert(sizeof(double) == sizeof(int64_t), double_not_64_bits);
  double result;
  memcpy(&result, &v, sizeof(result));
  return result;
}

_GPB_INLINE float _GPBConvertInt32ToFloat(int32_t v) {
  _GPBInternalCompileAssert(sizeof(float) == sizeof(int32_t), float_not_32_bits);
  float result;
  memcpy(&result, &v, sizeof(result));
  return result;
}

_GPB_INLINE int32_t _GPBLogicalRightShift32(int32_t value, int32_t spaces) {
  return (int32_t)((uint32_t)(value) >> spaces);
}

_GPB_INLINE int64_t _GPBLogicalRightShift64(int64_t value, int32_t spaces) {
  return (int64_t)((uint64_t)(value) >> spaces);
}

// Decode a ZigZag-encoded 32-bit value.  ZigZag encodes signed integers
// into values that can be efficiently encoded with varint.  (Otherwise,
// negative values must be sign-extended to 64 bits to be varint encoded,
// thus always taking 10 bytes on the wire.)
_GPB_INLINE int32_t _GPBDecodeZigZag32(uint32_t n) {
  return (int32_t)(_GPBLogicalRightShift32((int32_t)n, 1) ^ -((int32_t)(n) & 1));
}

// Decode a ZigZag-encoded 64-bit value.  ZigZag encodes signed integers
// into values that can be efficiently encoded with varint.  (Otherwise,
// negative values must be sign-extended to 64 bits to be varint encoded,
// thus always taking 10 bytes on the wire.)
_GPB_INLINE int64_t _GPBDecodeZigZag64(uint64_t n) {
  return (int64_t)(_GPBLogicalRightShift64((int64_t)n, 1) ^ -((int64_t)(n) & 1));
}

// Encode a ZigZag-encoded 32-bit value.  ZigZag encodes signed integers
// into values that can be efficiently encoded with varint.  (Otherwise,
// negative values must be sign-extended to 64 bits to be varint encoded,
// thus always taking 10 bytes on the wire.)
_GPB_INLINE uint32_t _GPBEncodeZigZag32(int32_t n) {
  // Note:  the right-shift must be arithmetic
  return ((uint32_t)n << 1) ^ (uint32_t)(n >> 31);
}

// Encode a ZigZag-encoded 64-bit value.  ZigZag encodes signed integers
// into values that can be efficiently encoded with varint.  (Otherwise,
// negative values must be sign-extended to 64 bits to be varint encoded,
// thus always taking 10 bytes on the wire.)
_GPB_INLINE uint64_t _GPBEncodeZigZag64(int64_t n) {
  // Note:  the right-shift must be arithmetic
  return ((uint64_t)n << 1) ^ (uint64_t)(n >> 63);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wswitch-enum"
#pragma clang diagnostic ignored "-Wdirect-ivar-access"

_GPB_INLINE BOOL _GPBDataTypeIsObject(_GPBDataType type) {
  switch (type) {
    case _GPBDataTypeBytes:
    case _GPBDataTypeString:
    case _GPBDataTypeMessage:
    case _GPBDataTypeGroup:
      return YES;
    default:
      return NO;
  }
}

_GPB_INLINE BOOL _GPBDataTypeIsMessage(_GPBDataType type) {
  switch (type) {
    case _GPBDataTypeMessage:
    case _GPBDataTypeGroup:
      return YES;
    default:
      return NO;
  }
}

_GPB_INLINE BOOL _GPBFieldDataTypeIsMessage(_GPBFieldDescriptor *field) {
  return _GPBDataTypeIsMessage(field->description_->dataType);
}

_GPB_INLINE BOOL _GPBFieldDataTypeIsObject(_GPBFieldDescriptor *field) {
  return _GPBDataTypeIsObject(field->description_->dataType);
}

_GPB_INLINE BOOL _GPBExtensionIsMessage(_GPBExtensionDescriptor *ext) {
  return _GPBDataTypeIsMessage(ext->description_->dataType);
}

// The field is an array/map or it has an object value.
_GPB_INLINE BOOL _GPBFieldStoresObject(_GPBFieldDescriptor *field) {
  _GPBMessageFieldDescription *desc = field->description_;
  if ((desc->flags & (_GPBFieldRepeated | _GPBFieldMapKeyMask)) != 0) {
    return YES;
  }
  return _GPBDataTypeIsObject(desc->dataType);
}

BOOL _GPBGetHasIvar(_GPBMessage *self, int32_t index, uint32_t fieldNumber);
void _GPBSetHasIvar(_GPBMessage *self, int32_t idx, uint32_t fieldNumber,
                   BOOL value);
uint32_t _GPBGetHasOneof(_GPBMessage *self, int32_t index);

_GPB_INLINE BOOL
_GPBGetHasIvarField(_GPBMessage *self, _GPBFieldDescriptor *field) {
  _GPBMessageFieldDescription *fieldDesc = field->description_;
  return _GPBGetHasIvar(self, fieldDesc->hasIndex, fieldDesc->number);
}
_GPB_INLINE void _GPBSetHasIvarField(_GPBMessage *self, _GPBFieldDescriptor *field,
                                   BOOL value) {
  _GPBMessageFieldDescription *fieldDesc = field->description_;
  _GPBSetHasIvar(self, fieldDesc->hasIndex, fieldDesc->number, value);
}

void _GPBMaybeClearOneof(_GPBMessage *self, _GPBOneofDescriptor *oneof,
                        int32_t oneofHasIndex, uint32_t fieldNumberNotToClear);

#pragma clang diagnostic pop

//%PDDM-DEFINE _GPB_IVAR_SET_DECL(NAME, TYPE)
//%void _GPBSet##NAME##IvarWithFieldInternal(_GPBMessage *self,
//%            NAME$S                     _GPBFieldDescriptor *field,
//%            NAME$S                     TYPE value,
//%            NAME$S                     _GPBFileSyntax syntax);
//%PDDM-EXPAND _GPB_IVAR_SET_DECL(Bool, BOOL)
// This block of code is generated, do not edit it directly.

void _GPBSetBoolIvarWithFieldInternal(_GPBMessage *self,
                                     _GPBFieldDescriptor *field,
                                     BOOL value,
                                     _GPBFileSyntax syntax);
//%PDDM-EXPAND _GPB_IVAR_SET_DECL(Int32, int32_t)
// This block of code is generated, do not edit it directly.

void _GPBSetInt32IvarWithFieldInternal(_GPBMessage *self,
                                      _GPBFieldDescriptor *field,
                                      int32_t value,
                                      _GPBFileSyntax syntax);
//%PDDM-EXPAND _GPB_IVAR_SET_DECL(UInt32, uint32_t)
// This block of code is generated, do not edit it directly.

void _GPBSetUInt32IvarWithFieldInternal(_GPBMessage *self,
                                       _GPBFieldDescriptor *field,
                                       uint32_t value,
                                       _GPBFileSyntax syntax);
//%PDDM-EXPAND _GPB_IVAR_SET_DECL(Int64, int64_t)
// This block of code is generated, do not edit it directly.

void _GPBSetInt64IvarWithFieldInternal(_GPBMessage *self,
                                      _GPBFieldDescriptor *field,
                                      int64_t value,
                                      _GPBFileSyntax syntax);
//%PDDM-EXPAND _GPB_IVAR_SET_DECL(UInt64, uint64_t)
// This block of code is generated, do not edit it directly.

void _GPBSetUInt64IvarWithFieldInternal(_GPBMessage *self,
                                       _GPBFieldDescriptor *field,
                                       uint64_t value,
                                       _GPBFileSyntax syntax);
//%PDDM-EXPAND _GPB_IVAR_SET_DECL(Float, float)
// This block of code is generated, do not edit it directly.

void _GPBSetFloatIvarWithFieldInternal(_GPBMessage *self,
                                      _GPBFieldDescriptor *field,
                                      float value,
                                      _GPBFileSyntax syntax);
//%PDDM-EXPAND _GPB_IVAR_SET_DECL(Double, double)
// This block of code is generated, do not edit it directly.

void _GPBSetDoubleIvarWithFieldInternal(_GPBMessage *self,
                                       _GPBFieldDescriptor *field,
                                       double value,
                                       _GPBFileSyntax syntax);
//%PDDM-EXPAND _GPB_IVAR_SET_DECL(Enum, int32_t)
// This block of code is generated, do not edit it directly.

void _GPBSetEnumIvarWithFieldInternal(_GPBMessage *self,
                                     _GPBFieldDescriptor *field,
                                     int32_t value,
                                     _GPBFileSyntax syntax);
//%PDDM-EXPAND-END (8 expansions)

int32_t _GPBGetEnumIvarWithFieldInternal(_GPBMessage *self,
                                        _GPBFieldDescriptor *field,
                                        _GPBFileSyntax syntax);

id _GPBGetObjectIvarWithField(_GPBMessage *self, _GPBFieldDescriptor *field);

void _GPBSetObjectIvarWithFieldInternal(_GPBMessage *self,
                                       _GPBFieldDescriptor *field, id value,
                                       _GPBFileSyntax syntax);
void _GPBSetRetainedObjectIvarWithFieldInternal(_GPBMessage *self,
                                               _GPBFieldDescriptor *field,
                                               id __attribute__((ns_consumed))
                                               value,
                                               _GPBFileSyntax syntax);

// _GPBGetObjectIvarWithField will automatically create the field (message) if
// it doesn't exist. _GPBGetObjectIvarWithFieldNoAutocreate will return nil.
id _GPBGetObjectIvarWithFieldNoAutocreate(_GPBMessage *self,
                                         _GPBFieldDescriptor *field);

void _GPBSetAutocreatedRetainedObjectIvarWithField(
    _GPBMessage *self, _GPBFieldDescriptor *field,
    id __attribute__((ns_consumed)) value);

// Clears and releases the autocreated message ivar, if it's autocreated. If
// it's not set as autocreated, this method does nothing.
void _GPBClearAutocreatedMessageIvarWithField(_GPBMessage *self,
                                             _GPBFieldDescriptor *field);

// Returns an Objective C encoding for |selector|. |instanceSel| should be
// YES if it's an instance selector (as opposed to a class selector).
// |selector| must be a selector from MessageSignatureProtocol.
const char *_GPBMessageEncodingForSelector(SEL selector, BOOL instanceSel);

// Helper for text format name encoding.
// decodeData is the data describing the sepecial decodes.
// key and inputString are the input that needs decoding.
NSString *_GPBDecodeTextFormatName(const uint8_t *decodeData, int32_t key,
                                  NSString *inputString);

// A series of selectors that are used solely to get @encoding values
// for them by the dynamic protobuf runtime code. See
// _GPBMessageEncodingForSelector for details. _GPBRootObject conforms to
// the protocol so that it is encoded in the Objective C runtime.
@protocol _GPBMessageSignatureProtocol
@optional

#define _GPB_MESSAGE_SIGNATURE_ENTRY(TYPE, NAME) \
  -(TYPE)get##NAME;                             \
  -(void)set##NAME : (TYPE)value;               \
  -(TYPE)get##NAME##AtIndex : (NSUInteger)index;

_GPB_MESSAGE_SIGNATURE_ENTRY(BOOL, Bool)
_GPB_MESSAGE_SIGNATURE_ENTRY(uint32_t, Fixed32)
_GPB_MESSAGE_SIGNATURE_ENTRY(int32_t, SFixed32)
_GPB_MESSAGE_SIGNATURE_ENTRY(float, Float)
_GPB_MESSAGE_SIGNATURE_ENTRY(uint64_t, Fixed64)
_GPB_MESSAGE_SIGNATURE_ENTRY(int64_t, SFixed64)
_GPB_MESSAGE_SIGNATURE_ENTRY(double, Double)
_GPB_MESSAGE_SIGNATURE_ENTRY(int32_t, Int32)
_GPB_MESSAGE_SIGNATURE_ENTRY(int64_t, Int64)
_GPB_MESSAGE_SIGNATURE_ENTRY(int32_t, SInt32)
_GPB_MESSAGE_SIGNATURE_ENTRY(int64_t, SInt64)
_GPB_MESSAGE_SIGNATURE_ENTRY(uint32_t, UInt32)
_GPB_MESSAGE_SIGNATURE_ENTRY(uint64_t, UInt64)
_GPB_MESSAGE_SIGNATURE_ENTRY(NSData *, Bytes)
_GPB_MESSAGE_SIGNATURE_ENTRY(NSString *, String)
_GPB_MESSAGE_SIGNATURE_ENTRY(_GPBMessage *, Message)
_GPB_MESSAGE_SIGNATURE_ENTRY(_GPBMessage *, Group)
_GPB_MESSAGE_SIGNATURE_ENTRY(int32_t, Enum)

#undef _GPB_MESSAGE_SIGNATURE_ENTRY

- (id)getArray;
- (NSUInteger)getArrayCount;
- (void)setArray:(NSArray *)array;
+ (id)getClassValue;
@end

BOOL _GPBClassHasSel(Class aClass, SEL sel);

CF_EXTERN_C_END
