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

#import <Foundation/Foundation.h>

#import "_GPBDictionary.h"

@class _GPBCodedInputStream;
@class _GPBCodedOutputStream;
@class _GPBExtensionRegistry;
@class _GPBFieldDescriptor;

@protocol _GPBDictionaryInternalsProtocol
- (size_t)computeSerializedSizeAsField:(_GPBFieldDescriptor *)field;
- (void)writeToCodedOutputStream:(_GPBCodedOutputStream *)outputStream
                         asField:(_GPBFieldDescriptor *)field;
- (void)set_GPBGenericValue:(_GPBGenericValue *)value
     for_GPBGenericValueKey:(_GPBGenericValue *)key;
- (void)enumerateForTextFormat:(void (^)(id keyObj, id valueObj))block;
@end

//%PDDM-DEFINE DICTIONARY_PRIV_INTERFACES_FOR_POD_KEY(KEY_NAME)
//%DICTIONARY_POD_PRIV_INTERFACES_FOR_KEY(KEY_NAME)
//%DICTIONARY_PRIVATE_INTERFACES(KEY_NAME, Object, Object)
//%PDDM-DEFINE DICTIONARY_POD_PRIV_INTERFACES_FOR_KEY(KEY_NAME)
//%DICTIONARY_PRIVATE_INTERFACES(KEY_NAME, UInt32, Basic)
//%DICTIONARY_PRIVATE_INTERFACES(KEY_NAME, Int32, Basic)
//%DICTIONARY_PRIVATE_INTERFACES(KEY_NAME, UInt64, Basic)
//%DICTIONARY_PRIVATE_INTERFACES(KEY_NAME, Int64, Basic)
//%DICTIONARY_PRIVATE_INTERFACES(KEY_NAME, Bool, Basic)
//%DICTIONARY_PRIVATE_INTERFACES(KEY_NAME, Float, Basic)
//%DICTIONARY_PRIVATE_INTERFACES(KEY_NAME, Double, Basic)
//%DICTIONARY_PRIVATE_INTERFACES(KEY_NAME, Enum, Enum)

//%PDDM-DEFINE DICTIONARY_PRIVATE_INTERFACES(KEY_NAME, VALUE_NAME, HELPER)
//%@interface _GPB##KEY_NAME##VALUE_NAME##Dictionary () <_GPBDictionaryInternalsProtocol> {
//% @package
//%  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
//%}
//%EXTRA_DICTIONARY_PRIVATE_INTERFACES_##HELPER()@end
//%

//%PDDM-DEFINE EXTRA_DICTIONARY_PRIVATE_INTERFACES_Basic()
// Empty
//%PDDM-DEFINE EXTRA_DICTIONARY_PRIVATE_INTERFACES_Object()
//%- (BOOL)isInitialized;
//%- (instancetype)deepCopyWithZone:(NSZone *)zone
//%    __attribute__((ns_returns_retained));
//%
//%PDDM-DEFINE EXTRA_DICTIONARY_PRIVATE_INTERFACES_Enum()
//%- (NSData *)serializedDataForUnknownValue:(int32_t)value
//%                                   forKey:(_GPBGenericValue *)key
//%                              keyDataType:(_GPBDataType)keyDataType;
//%

//%PDDM-EXPAND DICTIONARY_PRIV_INTERFACES_FOR_POD_KEY(UInt32)
// This block of code is generated, do not edit it directly.

@interface _GPBUInt32UInt32Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBUInt32Int32Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBUInt32UInt64Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBUInt32Int64Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBUInt32BoolDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBUInt32FloatDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBUInt32DoubleDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBUInt32EnumDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
- (NSData *)serializedDataForUnknownValue:(int32_t)value
                                   forKey:(_GPBGenericValue *)key
                              keyDataType:(_GPBDataType)keyDataType;
@end

@interface _GPBUInt32ObjectDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
- (BOOL)isInitialized;
- (instancetype)deepCopyWithZone:(NSZone *)zone
    __attribute__((ns_returns_retained));
@end

//%PDDM-EXPAND DICTIONARY_PRIV_INTERFACES_FOR_POD_KEY(Int32)
// This block of code is generated, do not edit it directly.

@interface _GPBInt32UInt32Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBInt32Int32Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBInt32UInt64Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBInt32Int64Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBInt32BoolDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBInt32FloatDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBInt32DoubleDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBInt32EnumDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
- (NSData *)serializedDataForUnknownValue:(int32_t)value
                                   forKey:(_GPBGenericValue *)key
                              keyDataType:(_GPBDataType)keyDataType;
@end

@interface _GPBInt32ObjectDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
- (BOOL)isInitialized;
- (instancetype)deepCopyWithZone:(NSZone *)zone
    __attribute__((ns_returns_retained));
@end

//%PDDM-EXPAND DICTIONARY_PRIV_INTERFACES_FOR_POD_KEY(UInt64)
// This block of code is generated, do not edit it directly.

@interface _GPBUInt64UInt32Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBUInt64Int32Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBUInt64UInt64Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBUInt64Int64Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBUInt64BoolDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBUInt64FloatDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBUInt64DoubleDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBUInt64EnumDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
- (NSData *)serializedDataForUnknownValue:(int32_t)value
                                   forKey:(_GPBGenericValue *)key
                              keyDataType:(_GPBDataType)keyDataType;
@end

@interface _GPBUInt64ObjectDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
- (BOOL)isInitialized;
- (instancetype)deepCopyWithZone:(NSZone *)zone
    __attribute__((ns_returns_retained));
@end

//%PDDM-EXPAND DICTIONARY_PRIV_INTERFACES_FOR_POD_KEY(Int64)
// This block of code is generated, do not edit it directly.

@interface _GPBInt64UInt32Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBInt64Int32Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBInt64UInt64Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBInt64Int64Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBInt64BoolDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBInt64FloatDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBInt64DoubleDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBInt64EnumDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
- (NSData *)serializedDataForUnknownValue:(int32_t)value
                                   forKey:(_GPBGenericValue *)key
                              keyDataType:(_GPBDataType)keyDataType;
@end

@interface _GPBInt64ObjectDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
- (BOOL)isInitialized;
- (instancetype)deepCopyWithZone:(NSZone *)zone
    __attribute__((ns_returns_retained));
@end

//%PDDM-EXPAND DICTIONARY_PRIV_INTERFACES_FOR_POD_KEY(Bool)
// This block of code is generated, do not edit it directly.

@interface _GPBBoolUInt32Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBBoolInt32Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBBoolUInt64Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBBoolInt64Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBBoolBoolDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBBoolFloatDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBBoolDoubleDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBBoolEnumDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
- (NSData *)serializedDataForUnknownValue:(int32_t)value
                                   forKey:(_GPBGenericValue *)key
                              keyDataType:(_GPBDataType)keyDataType;
@end

@interface _GPBBoolObjectDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
- (BOOL)isInitialized;
- (instancetype)deepCopyWithZone:(NSZone *)zone
    __attribute__((ns_returns_retained));
@end

//%PDDM-EXPAND DICTIONARY_POD_PRIV_INTERFACES_FOR_KEY(String)
// This block of code is generated, do not edit it directly.

@interface _GPBStringUInt32Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBStringInt32Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBStringUInt64Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBStringInt64Dictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBStringBoolDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBStringFloatDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBStringDoubleDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

@interface _GPBStringEnumDictionary () <_GPBDictionaryInternalsProtocol> {
 @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
- (NSData *)serializedDataForUnknownValue:(int32_t)value
                                   forKey:(_GPBGenericValue *)key
                              keyDataType:(_GPBDataType)keyDataType;
@end

//%PDDM-EXPAND-END (6 expansions)

#pragma mark - NSDictionary Subclass

@interface _GPBAutocreatedDictionary : NSMutableDictionary {
  @package
  _GPB_UNSAFE_UNRETAINED _GPBMessage *_autocreator;
}
@end

#pragma mark - Helpers

CF_EXTERN_C_BEGIN

// Helper to compute size when an NSDictionary is used for the map instead
// of a custom type.
size_t _GPBDictionaryComputeSizeInternalHelper(NSDictionary *dict,
                                              _GPBFieldDescriptor *field);

// Helper to write out when an NSDictionary is used for the map instead
// of a custom type.
void _GPBDictionaryWriteToStreamInternalHelper(
    _GPBCodedOutputStream *outputStream, NSDictionary *dict,
    _GPBFieldDescriptor *field);

// Helper to check message initialization when an NSDictionary is used for
// the map instead of a custom type.
BOOL _GPBDictionaryIsInitializedInternalHelper(NSDictionary *dict,
                                              _GPBFieldDescriptor *field);

// Helper to read a map instead.
void _GPBDictionaryReadEntry(id mapDictionary, _GPBCodedInputStream *stream,
                            _GPBExtensionRegistry *registry,
                            _GPBFieldDescriptor *field,
                            _GPBMessage *parentMessage);

CF_EXTERN_C_END
