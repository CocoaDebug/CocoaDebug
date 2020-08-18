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

#import "_GPBDescriptor.h"
#import "_GPBWireFormat.h"

// Describes attributes of the field.
typedef NS_OPTIONS(uint16_t, _GPBFieldFlags) {
  _GPBFieldNone            = 0,
  // These map to standard protobuf concepts.
  _GPBFieldRequired        = 1 << 0,
  _GPBFieldRepeated        = 1 << 1,
  _GPBFieldPacked          = 1 << 2,
  _GPBFieldOptional        = 1 << 3,
  _GPBFieldHasDefaultValue = 1 << 4,

  // Indicates the field needs custom handling for the TextFormat name, if not
  // set, the name can be derived from the ObjC name.
  _GPBFieldTextFormatNameCustom = 1 << 6,
  // Indicates the field has an enum descriptor.
  _GPBFieldHasEnumDescriptor = 1 << 7,

  // These are not standard protobuf concepts, they are specific to the
  // Objective C runtime.

  // These bits are used to mark the field as a map and what the key
  // type is.
  _GPBFieldMapKeyMask     = 0xF << 8,
  _GPBFieldMapKeyInt32    =  1 << 8,
  _GPBFieldMapKeyInt64    =  2 << 8,
  _GPBFieldMapKeyUInt32   =  3 << 8,
  _GPBFieldMapKeyUInt64   =  4 << 8,
  _GPBFieldMapKeySInt32   =  5 << 8,
  _GPBFieldMapKeySInt64   =  6 << 8,
  _GPBFieldMapKeyFixed32  =  7 << 8,
  _GPBFieldMapKeyFixed64  =  8 << 8,
  _GPBFieldMapKeySFixed32 =  9 << 8,
  _GPBFieldMapKeySFixed64 = 10 << 8,
  _GPBFieldMapKeyBool     = 11 << 8,
  _GPBFieldMapKeyString   = 12 << 8,
};

// NOTE: The structures defined here have their members ordered to minimize
// their size. This directly impacts the size of apps since these exist per
// field/extension.

// Describes a single field in a protobuf as it is represented as an ivar.
typedef struct _GPBMessageFieldDescription {
  // Name of ivar.
  const char *name;
  union {
    const char *className;  // Name for message class.
    // For enums only: If EnumDescriptors are compiled in, it will be that,
    // otherwise it will be the verifier.
    _GPBEnumDescriptorFunc enumDescFunc;
    _GPBEnumValidationFunc enumVerifier;
  } dataTypeSpecific;
  // The field number for the ivar.
  uint32_t number;
  // The index (in bits) into _has_storage_.
  //   >= 0: the bit to use for a value being set.
  //   = _GPBNoHasBit(INT32_MAX): no storage used.
  //   < 0: in a oneOf, use a full int32 to record the field active.
  int32_t hasIndex;
  // Offset of the variable into it's structure struct.
  uint32_t offset;
  // Field flags. Use accessor functions below.
  _GPBFieldFlags flags;
  // Data type of the ivar.
  _GPBDataType dataType;
} _GPBMessageFieldDescription;

// Fields in messages defined in a 'proto2' syntax file can provide a default
// value. This struct provides the default along with the field info.
typedef struct _GPBMessageFieldDescriptionWithDefault {
  // Default value for the ivar.
  _GPBGenericValue defaultValue;

  _GPBMessageFieldDescription core;
} _GPBMessageFieldDescriptionWithDefault;

// Describes attributes of the extension.
typedef NS_OPTIONS(uint8_t, _GPBExtensionOptions) {
  _GPBExtensionNone          = 0,
  // These map to standard protobuf concepts.
  _GPBExtensionRepeated      = 1 << 0,
  _GPBExtensionPacked        = 1 << 1,
  _GPBExtensionSetWireFormat = 1 << 2,
};

// An extension
typedef struct _GPBExtensionDescription {
  _GPBGenericValue defaultValue;
  const char *singletonName;
  const char *extendedClass;
  const char *messageOrGroupClassName;
  _GPBEnumDescriptorFunc enumDescriptorFunc;
  int32_t fieldNumber;
  _GPBDataType dataType;
  _GPBExtensionOptions options;
} _GPBExtensionDescription;

typedef NS_OPTIONS(uint32_t, _GPBDescriptorInitializationFlags) {
  _GPBDescriptorInitializationFlag_None              = 0,
  _GPBDescriptorInitializationFlag_FieldsWithDefault = 1 << 0,
  _GPBDescriptorInitializationFlag_WireFormat        = 1 << 1,
};

@interface _GPBDescriptor () {
 @package
  NSArray *fields_;
  NSArray *oneofs_;
  uint32_t storageSize_;
}

// fieldDescriptions have to be long lived, they are held as raw pointers.
+ (instancetype)
    allocDescriptorForClass:(Class)messageClass
                  rootClass:(Class)rootClass
                       file:(_GPBFileDescriptor *)file
                     fields:(void *)fieldDescriptions
                 fieldCount:(uint32_t)fieldCount
                storageSize:(uint32_t)storageSize
                      flags:(_GPBDescriptorInitializationFlags)flags;

- (instancetype)initWithClass:(Class)messageClass
                         file:(_GPBFileDescriptor *)file
                       fields:(NSArray *)fields
                  storageSize:(uint32_t)storage
                   wireFormat:(BOOL)wireFormat;

// Called right after init to provide extra information to avoid init having
// an explosion of args. These pointers are recorded, so they are expected
// to live for the lifetime of the app.
- (void)setupOneofs:(const char **)oneofNames
              count:(uint32_t)count
      firstHasIndex:(int32_t)firstHasIndex;
- (void)setupExtraTextInfo:(const char *)extraTextFormatInfo;
- (void)setupExtensionRanges:(const _GPBExtensionRange *)ranges count:(int32_t)count;
- (void)setupContainingMessageClassName:(const char *)msgClassName;
- (void)setupMessageClassNameSuffix:(NSString *)suffix;

@end

@interface _GPBFileDescriptor ()
- (instancetype)initWithPackage:(NSString *)package
                     objcPrefix:(NSString *)objcPrefix
                         syntax:(_GPBFileSyntax)syntax;
- (instancetype)initWithPackage:(NSString *)package
                         syntax:(_GPBFileSyntax)syntax;
@end

@interface _GPBOneofDescriptor () {
 @package
  const char *name_;
  NSArray *fields_;
  SEL caseSel_;
}
// name must be long lived.
- (instancetype)initWithName:(const char *)name fields:(NSArray *)fields;
@end

@interface _GPBFieldDescriptor () {
 @package
  _GPBMessageFieldDescription *description_;
  _GPB_UNSAFE_UNRETAINED _GPBOneofDescriptor *containingOneof_;

  SEL getSel_;
  SEL setSel_;
  SEL hasOrCountSel_;  // *Count for map<>/repeated fields, has* otherwise.
  SEL setHasSel_;
}

// Single initializer
// description has to be long lived, it is held as a raw pointer.
- (instancetype)initWithFieldDescription:(void *)description
                         includesDefault:(BOOL)includesDefault
                                  syntax:(_GPBFileSyntax)syntax;
@end

@interface _GPBEnumDescriptor ()
// valueNames, values and extraTextFormatInfo have to be long lived, they are
// held as raw pointers.
+ (instancetype)
    allocDescriptorForName:(NSString *)name
                valueNames:(const char *)valueNames
                    values:(const int32_t *)values
                     count:(uint32_t)valueCount
              enumVerifier:(_GPBEnumValidationFunc)enumVerifier;
+ (instancetype)
    allocDescriptorForName:(NSString *)name
                valueNames:(const char *)valueNames
                    values:(const int32_t *)values
                     count:(uint32_t)valueCount
              enumVerifier:(_GPBEnumValidationFunc)enumVerifier
       extraTextFormatInfo:(const char *)extraTextFormatInfo;

- (instancetype)initWithName:(NSString *)name
                  valueNames:(const char *)valueNames
                      values:(const int32_t *)values
                       count:(uint32_t)valueCount
                enumVerifier:(_GPBEnumValidationFunc)enumVerifier;
@end

@interface _GPBExtensionDescriptor () {
 @package
  _GPBExtensionDescription *description_;
}
@property(nonatomic, readonly) _GPBWireFormat wireType;

// For repeated extensions, alternateWireType is the wireType with the opposite
// value for the packable property.  i.e. - if the extension was marked packed
// it would be the wire type for unpacked; if the extension was marked unpacked,
// it would be the wire type for packed.
@property(nonatomic, readonly) _GPBWireFormat alternateWireType;

// description has to be long lived, it is held as a raw pointer.
- (instancetype)initWithExtensionDescription:
    (_GPBExtensionDescription *)description;
- (NSComparisonResult)compareByFieldNumber:(_GPBExtensionDescriptor *)other;
@end

CF_EXTERN_C_BEGIN

// Direct access is use for speed, to avoid even internally declaring things
// read/write, etc. The warning is enabled in the project to ensure code calling
// protos can turn on -Wdirect-ivar-access without issues.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"

_GPB_INLINE BOOL _GPBFieldIsMapOrArray(_GPBFieldDescriptor *field) {
  return (field->description_->flags &
          (_GPBFieldRepeated | _GPBFieldMapKeyMask)) != 0;
}

_GPB_INLINE _GPBDataType _GPBGetFieldDataType(_GPBFieldDescriptor *field) {
  return field->description_->dataType;
}

_GPB_INLINE int32_t _GPBFieldHasIndex(_GPBFieldDescriptor *field) {
  return field->description_->hasIndex;
}

_GPB_INLINE uint32_t _GPBFieldNumber(_GPBFieldDescriptor *field) {
  return field->description_->number;
}

#pragma clang diagnostic pop

uint32_t _GPBFieldTag(_GPBFieldDescriptor *self);

// For repeated fields, alternateWireType is the wireType with the opposite
// value for the packable property.  i.e. - if the field was marked packed it
// would be the wire type for unpacked; if the field was marked unpacked, it
// would be the wire type for packed.
uint32_t _GPBFieldAlternateTag(_GPBFieldDescriptor *self);

_GPB_INLINE BOOL _GPBHasPreservingUnknownEnumSemantics(_GPBFileSyntax syntax) {
  return syntax == _GPBFileSyntaxProto3;
}

_GPB_INLINE BOOL _GPBExtensionIsRepeated(_GPBExtensionDescription *description) {
  return (description->options & _GPBExtensionRepeated) != 0;
}

_GPB_INLINE BOOL _GPBExtensionIsPacked(_GPBExtensionDescription *description) {
  return (description->options & _GPBExtensionPacked) != 0;
}

_GPB_INLINE BOOL _GPBExtensionIsWireFormat(_GPBExtensionDescription *description) {
  return (description->options & _GPBExtensionSetWireFormat) != 0;
}

// Helper for compile time assets.
#ifndef _GPBInternalCompileAssert
  #if __has_feature(c_static_assert) || __has_extension(c_static_assert)
    #define _GPBInternalCompileAssert(test, msg) _Static_assert((test), #msg)
  #else
    // Pre-Xcode 7 support.
    #define _GPBInternalCompileAssertSymbolInner(line, msg) _GPBInternalCompileAssert ## line ## __ ## msg
    #define _GPBInternalCompileAssertSymbol(line, msg) _GPBInternalCompileAssertSymbolInner(line, msg)
    #define _GPBInternalCompileAssert(test, msg) \
        typedef char _GPBInternalCompileAssertSymbol(__LINE__, msg) [ ((test) ? 1 : -1) ]
  #endif  // __has_feature(c_static_assert) || __has_extension(c_static_assert)
#endif // _GPBInternalCompileAssert

// Sanity check that there isn't padding between the field description
// structures with and without a default.
_GPBInternalCompileAssert(sizeof(_GPBMessageFieldDescriptionWithDefault) ==
                         (sizeof(_GPBGenericValue) +
                          sizeof(_GPBMessageFieldDescription)),
                         DescriptionsWithDefault_different_size_than_expected);

CF_EXTERN_C_END
