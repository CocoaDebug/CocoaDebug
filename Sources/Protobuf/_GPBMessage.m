//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_GPBMessage_PackagePrivate.h"

#import <objc/runtime.h>
#import <objc/message.h>
#import <stdatomic.h>

#import "_GPBArray_PackagePrivate.h"
#import "_GPBCodedInputStream_PackagePrivate.h"
#import "_GPBCodedOutputStream_PackagePrivate.h"
#import "_GPBDescriptor_PackagePrivate.h"
#import "_GPBDictionary_PackagePrivate.h"
#import "_GPBExtensionInternals.h"
#import "_GPBExtensionRegistry.h"
#import "_GPBRootObject_PackagePrivate.h"
#import "_GPBUnknownFieldSet_PackagePrivate.h"
#import "_GPBUtilities_PackagePrivate.h"

// Direct access is use for speed, to avoid even internally declaring things
// read/write, etc. The warning is enabled in the project to ensure code calling
// protos can turn on -Wdirect-ivar-access without issues.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"

NSString *const _GPBMessageErrorDomain =
    _GPBNSStringifySymbol(_GPBMessageErrorDomain);

NSString *const _GPBErrorReasonKey = @"Reason";

static NSString *const k_GPBDataCoderKey = @"_GPBData";

//
// PLEASE REMEMBER:
//
// This is the base class for *all* messages generated, so any selector defined,
// *public* or *private* could end up colliding with a proto message field. So
// avoid using selectors that could match a property, use C functions to hide
// them, etc.
//

@interface _GPBMessage () {
 @package
  _GPBUnknownFieldSet *unknownFields_;
  NSMutableDictionary *extensionMap_;
  NSMutableDictionary *autocreatedExtensionMap_;

  // If the object was autocreated, we remember the creator so that if we get
  // mutated, we can inform the creator to make our field visible.
  _GPBMessage *autocreator_;
  _GPBFieldDescriptor *autocreatorField_;
  _GPBExtensionDescriptor *autocreatorExtension_;

  // A lock to provide mutual exclusion from internal data that can be modified
  // by *read* operations such as getters (autocreation of message fields and
  // message extensions, not setting of values). Used to guarantee thread safety
  // for concurrent reads on the message.
  // NOTE: OSSpinLock may seem like a good fit here but Apple engineers have
  // pointed out that they are vulnerable to live locking on iOS in cases of
  // priority inversion:
  //   http://mjtsai.com/blog/2015/12/16/osspinlock-is-unsafe/
  //   https://lists.swift.org/pipermail/swift-dev/Week-of-Mon-20151214/000372.html
  // Use of readOnlySemaphore_ must be prefaced by a call to
  // _GPBPrepareReadOnlySemaphore to ensure it has been created. This allows
  // readOnlySemaphore_ to be only created when actually needed.
  _Atomic(dispatch_semaphore_t) readOnlySemaphore_;
}
@end

static id CreateArrayForField(_GPBFieldDescriptor *field,
                              _GPBMessage *autocreator)
    __attribute__((ns_returns_retained));
static id GetOrCreateArrayIvarWithField(_GPBMessage *self,
                                        _GPBFieldDescriptor *field,
                                        _GPBFileSyntax syntax);
static id GetArrayIvarWithField(_GPBMessage *self, _GPBFieldDescriptor *field);
static id CreateMapForField(_GPBFieldDescriptor *field,
                            _GPBMessage *autocreator)
    __attribute__((ns_returns_retained));
static id GetOrCreateMapIvarWithField(_GPBMessage *self,
                                      _GPBFieldDescriptor *field,
                                      _GPBFileSyntax syntax);
static id GetMapIvarWithField(_GPBMessage *self, _GPBFieldDescriptor *field);
static NSMutableDictionary *CloneExtensionMap(NSDictionary *extensionMap,
                                              NSZone *zone)
    __attribute__((ns_returns_retained));

#ifdef DEBUG
static NSError *MessageError(NSInteger code, NSDictionary *userInfo) {
  return [NSError errorWithDomain:_GPBMessageErrorDomain
                             code:code
                         userInfo:userInfo];
}
#endif

static NSError *ErrorFromException(NSException *exception) {
  NSError *error = nil;

  if ([exception.name isEqual:_GPBCodedInputStreamException]) {
    NSDictionary *exceptionInfo = exception.userInfo;
    error = exceptionInfo[_GPBCodedInputStreamUnderlyingErrorKey];
  }

  if (!error) {
    NSString *reason = exception.reason;
    NSDictionary *userInfo = nil;
    if ([reason length]) {
      userInfo = @{ _GPBErrorReasonKey : reason };
    }

    error = [NSError errorWithDomain:_GPBMessageErrorDomain
                                code:_GPBMessageErrorCodeOther
                            userInfo:userInfo];
  }
  return error;
}

static void CheckExtension(_GPBMessage *self,
                           _GPBExtensionDescriptor *extension) {
  if (![self isKindOfClass:extension.containingMessageClass]) {
    [NSException
         raise:NSInvalidArgumentException
        format:@"Extension %@ used on wrong class (%@ instead of %@)",
               extension.singletonName,
               [self class], extension.containingMessageClass];
  }
}

static NSMutableDictionary *CloneExtensionMap(NSDictionary *extensionMap,
                                              NSZone *zone) {
  if (extensionMap.count == 0) {
    return nil;
  }
  NSMutableDictionary *result = [[NSMutableDictionary allocWithZone:zone]
      initWithCapacity:extensionMap.count];

  for (_GPBExtensionDescriptor *extension in extensionMap) {
    id value = [extensionMap objectForKey:extension];
    BOOL isMessageExtension = _GPBExtensionIsMessage(extension);

    if (extension.repeated) {
      if (isMessageExtension) {
        NSMutableArray *list =
            [[NSMutableArray alloc] initWithCapacity:[value count]];
        for (_GPBMessage *listValue in value) {
          _GPBMessage *copiedValue = [listValue copyWithZone:zone];
          [list addObject:copiedValue];
          [copiedValue release];
        }
        [result setObject:list forKey:extension];
        [list release];
      } else {
        NSMutableArray *copiedValue = [value mutableCopyWithZone:zone];
        [result setObject:copiedValue forKey:extension];
        [copiedValue release];
      }
    } else {
      if (isMessageExtension) {
        _GPBMessage *copiedValue = [value copyWithZone:zone];
        [result setObject:copiedValue forKey:extension];
        [copiedValue release];
      } else {
        [result setObject:value forKey:extension];
      }
    }
  }

  return result;
}

static id CreateArrayForField(_GPBFieldDescriptor *field,
                              _GPBMessage *autocreator) {
  id result;
  _GPBDataType fieldDataType = _GPBGetFieldDataType(field);
  switch (fieldDataType) {
    case _GPBDataTypeBool:
      result = [[_GPBBoolArray alloc] init];
      break;
    case _GPBDataTypeFixed32:
    case _GPBDataTypeUInt32:
      result = [[_GPBUInt32Array alloc] init];
      break;
    case _GPBDataTypeInt32:
    case _GPBDataTypeSFixed32:
    case _GPBDataTypeSInt32:
      result = [[_GPBInt32Array alloc] init];
      break;
    case _GPBDataTypeFixed64:
    case _GPBDataTypeUInt64:
      result = [[_GPBUInt64Array alloc] init];
      break;
    case _GPBDataTypeInt64:
    case _GPBDataTypeSFixed64:
    case _GPBDataTypeSInt64:
      result = [[_GPBInt64Array alloc] init];
      break;
    case _GPBDataTypeFloat:
      result = [[_GPBFloatArray alloc] init];
      break;
    case _GPBDataTypeDouble:
      result = [[_GPBDoubleArray alloc] init];
      break;

    case _GPBDataTypeEnum:
      result = [[_GPBEnumArray alloc]
                  initWithValidationFunction:field.enumDescriptor.enumVerifier];
      break;

    case _GPBDataTypeBytes:
    case _GPBDataTypeGroup:
    case _GPBDataTypeMessage:
    case _GPBDataTypeString:
      if (autocreator) {
        result = [[_GPBAutocreatedArray alloc] init];
      } else {
        result = [[NSMutableArray alloc] init];
      }
      break;
  }

  if (autocreator) {
    if (_GPBDataTypeIsObject(fieldDataType)) {
      _GPBAutocreatedArray *autoArray = result;
      autoArray->_autocreator =  autocreator;
    } else {
      _GPBInt32Array *gpbArray = result;
      gpbArray->_autocreator = autocreator;
    }
  }

  return result;
}

static id CreateMapForField(_GPBFieldDescriptor *field,
                            _GPBMessage *autocreator) {
  id result;
  _GPBDataType keyDataType = field.mapKeyDataType;
  _GPBDataType valueDataType = _GPBGetFieldDataType(field);
  switch (keyDataType) {
    case _GPBDataTypeBool:
      switch (valueDataType) {
        case _GPBDataTypeBool:
          result = [[_GPBBoolBoolDictionary alloc] init];
          break;
        case _GPBDataTypeFixed32:
        case _GPBDataTypeUInt32:
          result = [[_GPBBoolUInt32Dictionary alloc] init];
          break;
        case _GPBDataTypeInt32:
        case _GPBDataTypeSFixed32:
        case _GPBDataTypeSInt32:
          result = [[_GPBBoolInt32Dictionary alloc] init];
          break;
        case _GPBDataTypeFixed64:
        case _GPBDataTypeUInt64:
          result = [[_GPBBoolUInt64Dictionary alloc] init];
          break;
        case _GPBDataTypeInt64:
        case _GPBDataTypeSFixed64:
        case _GPBDataTypeSInt64:
          result = [[_GPBBoolInt64Dictionary alloc] init];
          break;
        case _GPBDataTypeFloat:
          result = [[_GPBBoolFloatDictionary alloc] init];
          break;
        case _GPBDataTypeDouble:
          result = [[_GPBBoolDoubleDictionary alloc] init];
          break;
        case _GPBDataTypeEnum:
          result = [[_GPBBoolEnumDictionary alloc]
              initWithValidationFunction:field.enumDescriptor.enumVerifier];
          break;
        case _GPBDataTypeBytes:
        case _GPBDataTypeMessage:
        case _GPBDataTypeString:
          result = [[_GPBBoolObjectDictionary alloc] init];
          break;
        case _GPBDataTypeGroup:
          NSCAssert(NO, @"shouldn't happen");
          return nil;
      }
      break;
    case _GPBDataTypeFixed32:
    case _GPBDataTypeUInt32:
      switch (valueDataType) {
        case _GPBDataTypeBool:
          result = [[_GPBUInt32BoolDictionary alloc] init];
          break;
        case _GPBDataTypeFixed32:
        case _GPBDataTypeUInt32:
          result = [[_GPBUInt32UInt32Dictionary alloc] init];
          break;
        case _GPBDataTypeInt32:
        case _GPBDataTypeSFixed32:
        case _GPBDataTypeSInt32:
          result = [[_GPBUInt32Int32Dictionary alloc] init];
          break;
        case _GPBDataTypeFixed64:
        case _GPBDataTypeUInt64:
          result = [[_GPBUInt32UInt64Dictionary alloc] init];
          break;
        case _GPBDataTypeInt64:
        case _GPBDataTypeSFixed64:
        case _GPBDataTypeSInt64:
          result = [[_GPBUInt32Int64Dictionary alloc] init];
          break;
        case _GPBDataTypeFloat:
          result = [[_GPBUInt32FloatDictionary alloc] init];
          break;
        case _GPBDataTypeDouble:
          result = [[_GPBUInt32DoubleDictionary alloc] init];
          break;
        case _GPBDataTypeEnum:
          result = [[_GPBUInt32EnumDictionary alloc]
              initWithValidationFunction:field.enumDescriptor.enumVerifier];
          break;
        case _GPBDataTypeBytes:
        case _GPBDataTypeMessage:
        case _GPBDataTypeString:
          result = [[_GPBUInt32ObjectDictionary alloc] init];
          break;
        case _GPBDataTypeGroup:
          NSCAssert(NO, @"shouldn't happen");
          return nil;
      }
      break;
    case _GPBDataTypeInt32:
    case _GPBDataTypeSFixed32:
    case _GPBDataTypeSInt32:
      switch (valueDataType) {
        case _GPBDataTypeBool:
          result = [[_GPBInt32BoolDictionary alloc] init];
          break;
        case _GPBDataTypeFixed32:
        case _GPBDataTypeUInt32:
          result = [[_GPBInt32UInt32Dictionary alloc] init];
          break;
        case _GPBDataTypeInt32:
        case _GPBDataTypeSFixed32:
        case _GPBDataTypeSInt32:
          result = [[_GPBInt32Int32Dictionary alloc] init];
          break;
        case _GPBDataTypeFixed64:
        case _GPBDataTypeUInt64:
          result = [[_GPBInt32UInt64Dictionary alloc] init];
          break;
        case _GPBDataTypeInt64:
        case _GPBDataTypeSFixed64:
        case _GPBDataTypeSInt64:
          result = [[_GPBInt32Int64Dictionary alloc] init];
          break;
        case _GPBDataTypeFloat:
          result = [[_GPBInt32FloatDictionary alloc] init];
          break;
        case _GPBDataTypeDouble:
          result = [[_GPBInt32DoubleDictionary alloc] init];
          break;
        case _GPBDataTypeEnum:
          result = [[_GPBInt32EnumDictionary alloc]
              initWithValidationFunction:field.enumDescriptor.enumVerifier];
          break;
        case _GPBDataTypeBytes:
        case _GPBDataTypeMessage:
        case _GPBDataTypeString:
          result = [[_GPBInt32ObjectDictionary alloc] init];
          break;
        case _GPBDataTypeGroup:
          NSCAssert(NO, @"shouldn't happen");
          return nil;
      }
      break;
    case _GPBDataTypeFixed64:
    case _GPBDataTypeUInt64:
      switch (valueDataType) {
        case _GPBDataTypeBool:
          result = [[_GPBUInt64BoolDictionary alloc] init];
          break;
        case _GPBDataTypeFixed32:
        case _GPBDataTypeUInt32:
          result = [[_GPBUInt64UInt32Dictionary alloc] init];
          break;
        case _GPBDataTypeInt32:
        case _GPBDataTypeSFixed32:
        case _GPBDataTypeSInt32:
          result = [[_GPBUInt64Int32Dictionary alloc] init];
          break;
        case _GPBDataTypeFixed64:
        case _GPBDataTypeUInt64:
          result = [[_GPBUInt64UInt64Dictionary alloc] init];
          break;
        case _GPBDataTypeInt64:
        case _GPBDataTypeSFixed64:
        case _GPBDataTypeSInt64:
          result = [[_GPBUInt64Int64Dictionary alloc] init];
          break;
        case _GPBDataTypeFloat:
          result = [[_GPBUInt64FloatDictionary alloc] init];
          break;
        case _GPBDataTypeDouble:
          result = [[_GPBUInt64DoubleDictionary alloc] init];
          break;
        case _GPBDataTypeEnum:
          result = [[_GPBUInt64EnumDictionary alloc]
              initWithValidationFunction:field.enumDescriptor.enumVerifier];
          break;
        case _GPBDataTypeBytes:
        case _GPBDataTypeMessage:
        case _GPBDataTypeString:
          result = [[_GPBUInt64ObjectDictionary alloc] init];
          break;
        case _GPBDataTypeGroup:
          NSCAssert(NO, @"shouldn't happen");
          return nil;
      }
      break;
    case _GPBDataTypeInt64:
    case _GPBDataTypeSFixed64:
    case _GPBDataTypeSInt64:
      switch (valueDataType) {
        case _GPBDataTypeBool:
          result = [[_GPBInt64BoolDictionary alloc] init];
          break;
        case _GPBDataTypeFixed32:
        case _GPBDataTypeUInt32:
          result = [[_GPBInt64UInt32Dictionary alloc] init];
          break;
        case _GPBDataTypeInt32:
        case _GPBDataTypeSFixed32:
        case _GPBDataTypeSInt32:
          result = [[_GPBInt64Int32Dictionary alloc] init];
          break;
        case _GPBDataTypeFixed64:
        case _GPBDataTypeUInt64:
          result = [[_GPBInt64UInt64Dictionary alloc] init];
          break;
        case _GPBDataTypeInt64:
        case _GPBDataTypeSFixed64:
        case _GPBDataTypeSInt64:
          result = [[_GPBInt64Int64Dictionary alloc] init];
          break;
        case _GPBDataTypeFloat:
          result = [[_GPBInt64FloatDictionary alloc] init];
          break;
        case _GPBDataTypeDouble:
          result = [[_GPBInt64DoubleDictionary alloc] init];
          break;
        case _GPBDataTypeEnum:
          result = [[_GPBInt64EnumDictionary alloc]
              initWithValidationFunction:field.enumDescriptor.enumVerifier];
          break;
        case _GPBDataTypeBytes:
        case _GPBDataTypeMessage:
        case _GPBDataTypeString:
          result = [[_GPBInt64ObjectDictionary alloc] init];
          break;
        case _GPBDataTypeGroup:
          NSCAssert(NO, @"shouldn't happen");
          return nil;
      }
      break;
    case _GPBDataTypeString:
      switch (valueDataType) {
        case _GPBDataTypeBool:
          result = [[_GPBStringBoolDictionary alloc] init];
          break;
        case _GPBDataTypeFixed32:
        case _GPBDataTypeUInt32:
          result = [[_GPBStringUInt32Dictionary alloc] init];
          break;
        case _GPBDataTypeInt32:
        case _GPBDataTypeSFixed32:
        case _GPBDataTypeSInt32:
          result = [[_GPBStringInt32Dictionary alloc] init];
          break;
        case _GPBDataTypeFixed64:
        case _GPBDataTypeUInt64:
          result = [[_GPBStringUInt64Dictionary alloc] init];
          break;
        case _GPBDataTypeInt64:
        case _GPBDataTypeSFixed64:
        case _GPBDataTypeSInt64:
          result = [[_GPBStringInt64Dictionary alloc] init];
          break;
        case _GPBDataTypeFloat:
          result = [[_GPBStringFloatDictionary alloc] init];
          break;
        case _GPBDataTypeDouble:
          result = [[_GPBStringDoubleDictionary alloc] init];
          break;
        case _GPBDataTypeEnum:
          result = [[_GPBStringEnumDictionary alloc]
              initWithValidationFunction:field.enumDescriptor.enumVerifier];
          break;
        case _GPBDataTypeBytes:
        case _GPBDataTypeMessage:
        case _GPBDataTypeString:
          if (autocreator) {
            result = [[_GPBAutocreatedDictionary alloc] init];
          } else {
            result = [[NSMutableDictionary alloc] init];
          }
          break;
        case _GPBDataTypeGroup:
          NSCAssert(NO, @"shouldn't happen");
          return nil;
      }
      break;

    case _GPBDataTypeFloat:
    case _GPBDataTypeDouble:
    case _GPBDataTypeEnum:
    case _GPBDataTypeBytes:
    case _GPBDataTypeGroup:
    case _GPBDataTypeMessage:
      NSCAssert(NO, @"shouldn't happen");
      return nil;
  }

  if (autocreator) {
    if ((keyDataType == _GPBDataTypeString) &&
        _GPBDataTypeIsObject(valueDataType)) {
      _GPBAutocreatedDictionary *autoDict = result;
      autoDict->_autocreator =  autocreator;
    } else {
      _GPBInt32Int32Dictionary *gpbDict = result;
      gpbDict->_autocreator = autocreator;
    }
  }

  return result;
}

#if !defined(__clang_analyzer__)
// These functions are blocked from the analyzer because the analyzer sees the
// _GPBSetRetainedObjectIvarWithFieldInternal() call as consuming the array/map,
// so use of the array/map after the call returns is flagged as a use after
// free.
// But _GPBSetRetainedObjectIvarWithFieldInternal() is "consuming" the retain
// count be holding onto the object (it is transfering it), the object is
// still valid after returning from the call.  The other way to avoid this
// would be to add a -retain/-autorelease, but that would force every
// repeated/map field parsed into the autorelease pool which is both a memory
// and performance hit.

static id GetOrCreateArrayIvarWithField(_GPBMessage *self,
                                        _GPBFieldDescriptor *field,
                                        _GPBFileSyntax syntax) {
  id array = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
  if (!array) {
    // No lock needed, this is called from places expecting to mutate
    // so no threading protection is needed.
    array = CreateArrayForField(field, nil);
    _GPBSetRetainedObjectIvarWithFieldInternal(self, field, array, syntax);
  }
  return array;
}

// This is like _GPBGetObjectIvarWithField(), but for arrays, it should
// only be used to wire the method into the class.
static id GetArrayIvarWithField(_GPBMessage *self, _GPBFieldDescriptor *field) {
  id array = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
  if (!array) {
    // Check again after getting the lock.
    _GPBPrepareReadOnlySemaphore(self);
    dispatch_semaphore_wait(self->readOnlySemaphore_, DISPATCH_TIME_FOREVER);
    array = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
    if (!array) {
      array = CreateArrayForField(field, self);
      _GPBSetAutocreatedRetainedObjectIvarWithField(self, field, array);
    }
    dispatch_semaphore_signal(self->readOnlySemaphore_);
  }
  return array;
}

static id GetOrCreateMapIvarWithField(_GPBMessage *self,
                                      _GPBFieldDescriptor *field,
                                      _GPBFileSyntax syntax) {
  id dict = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
  if (!dict) {
    // No lock needed, this is called from places expecting to mutate
    // so no threading protection is needed.
    dict = CreateMapForField(field, nil);
    _GPBSetRetainedObjectIvarWithFieldInternal(self, field, dict, syntax);
  }
  return dict;
}

// This is like _GPBGetObjectIvarWithField(), but for maps, it should
// only be used to wire the method into the class.
static id GetMapIvarWithField(_GPBMessage *self, _GPBFieldDescriptor *field) {
  id dict = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
  if (!dict) {
    // Check again after getting the lock.
    _GPBPrepareReadOnlySemaphore(self);
    dispatch_semaphore_wait(self->readOnlySemaphore_, DISPATCH_TIME_FOREVER);
    dict = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
    if (!dict) {
      dict = CreateMapForField(field, self);
      _GPBSetAutocreatedRetainedObjectIvarWithField(self, field, dict);
    }
    dispatch_semaphore_signal(self->readOnlySemaphore_);
  }
  return dict;
}

#endif  // !defined(__clang_analyzer__)

_GPBMessage *_GPBCreateMessageWithAutocreator(Class msgClass,
                                            _GPBMessage *autocreator,
                                            _GPBFieldDescriptor *field) {
  _GPBMessage *message = [[msgClass alloc] init];
  message->autocreator_ = autocreator;
  message->autocreatorField_ = [field retain];
  return message;
}

static _GPBMessage *CreateMessageWithAutocreatorForExtension(
    Class msgClass, _GPBMessage *autocreator, _GPBExtensionDescriptor *extension)
    __attribute__((ns_returns_retained));

static _GPBMessage *CreateMessageWithAutocreatorForExtension(
    Class msgClass, _GPBMessage *autocreator,
    _GPBExtensionDescriptor *extension) {
  _GPBMessage *message = [[msgClass alloc] init];
  message->autocreator_ = autocreator;
  message->autocreatorExtension_ = [extension retain];
  return message;
}

BOOL _GPBWasMessageAutocreatedBy(_GPBMessage *message, _GPBMessage *parent) {
  return (message->autocreator_ == parent);
}

void _GPBBecomeVisibleToAutocreator(_GPBMessage *self) {
  // Message objects that are implicitly created by accessing a message field
  // are initially not visible via the hasX selector. This method makes them
  // visible.
  if (self->autocreator_) {
    // This will recursively make all parent messages visible until it reaches a
    // super-creator that's visible.
    if (self->autocreatorField_) {
      _GPBFileSyntax syntax = [self->autocreator_ descriptor].file.syntax;
      _GPBSetObjectIvarWithFieldInternal(self->autocreator_,
                                        self->autocreatorField_, self, syntax);
    } else {
      [self->autocreator_ setExtension:self->autocreatorExtension_ value:self];
    }
  }
}

void _GPBAutocreatedArrayModified(_GPBMessage *self, id array) {
  // When one of our autocreated arrays adds elements, make it visible.
  _GPBDescriptor *descriptor = [[self class] descriptor];
  for (_GPBFieldDescriptor *field in descriptor->fields_) {
    if (field.fieldType == _GPBFieldTypeRepeated) {
      id curArray = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
      if (curArray == array) {
        if (_GPBFieldDataTypeIsObject(field)) {
          _GPBAutocreatedArray *autoArray = array;
          autoArray->_autocreator = nil;
        } else {
          _GPBInt32Array *gpbArray = array;
          gpbArray->_autocreator = nil;
        }
        _GPBBecomeVisibleToAutocreator(self);
        return;
      }
    }
  }
  NSCAssert(NO, @"Unknown autocreated %@ for %@.", [array class], self);
}

void _GPBAutocreatedDictionaryModified(_GPBMessage *self, id dictionary) {
  // When one of our autocreated dicts adds elements, make it visible.
  _GPBDescriptor *descriptor = [[self class] descriptor];
  for (_GPBFieldDescriptor *field in descriptor->fields_) {
    if (field.fieldType == _GPBFieldTypeMap) {
      id curDict = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
      if (curDict == dictionary) {
        if ((field.mapKeyDataType == _GPBDataTypeString) &&
            _GPBFieldDataTypeIsObject(field)) {
          _GPBAutocreatedDictionary *autoDict = dictionary;
          autoDict->_autocreator = nil;
        } else {
          _GPBInt32Int32Dictionary *gpbDict = dictionary;
          gpbDict->_autocreator = nil;
        }
        _GPBBecomeVisibleToAutocreator(self);
        return;
      }
    }
  }
  NSCAssert(NO, @"Unknown autocreated %@ for %@.", [dictionary class], self);
}

void _GPBClearMessageAutocreator(_GPBMessage *self) {
  if ((self == nil) || !self->autocreator_) {
    return;
  }

#if defined(DEBUG) && DEBUG && !defined(NS_BLOCK_ASSERTIONS)
  // Either the autocreator must have its "has" flag set to YES, or it must be
  // NO and not equal to ourselves.
  BOOL autocreatorHas =
      (self->autocreatorField_
           ? _GPBGetHasIvarField(self->autocreator_, self->autocreatorField_)
           : [self->autocreator_ hasExtension:self->autocreatorExtension_]);
  _GPBMessage *autocreatorFieldValue =
      (self->autocreatorField_
           ? _GPBGetObjectIvarWithFieldNoAutocreate(self->autocreator_,
                                                   self->autocreatorField_)
           : [self->autocreator_->autocreatedExtensionMap_
                 objectForKey:self->autocreatorExtension_]);
  NSCAssert(autocreatorHas || autocreatorFieldValue != self,
            @"Cannot clear autocreator because it still refers to self, self: %@.",
            self);

#endif  // DEBUG && !defined(NS_BLOCK_ASSERTIONS)

  self->autocreator_ = nil;
  [self->autocreatorField_ release];
  self->autocreatorField_ = nil;
  [self->autocreatorExtension_ release];
  self->autocreatorExtension_ = nil;
}

// Call this before using the readOnlySemaphore_. This ensures it is created only once.
void _GPBPrepareReadOnlySemaphore(_GPBMessage *self) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"

  // Create the semaphore on demand (rather than init) as developers might not cause them
  // to be needed, and the heap usage can add up.  The atomic swap is used to avoid needing
  // another lock around creating it.
  if (self->readOnlySemaphore_ == nil) {
    dispatch_semaphore_t worker = dispatch_semaphore_create(1);
    dispatch_semaphore_t expected = nil;
    if (!atomic_compare_exchange_strong(&self->readOnlySemaphore_, &expected, worker)) {
      dispatch_release(worker);
    }
#if defined(__clang_analyzer__)
    // The Xcode 9.2 (and 9.3 beta) static analyzer thinks worker is leaked
    // (doesn't seem to know about atomic_compare_exchange_strong); so just
    // for the analyzer, var it think worker is also released in this case.
    else { dispatch_release(worker); }
#endif
  }

#pragma clang diagnostic pop
}

static _GPBUnknownFieldSet *GetOrMakeUnknownFields(_GPBMessage *self) {
  if (!self->unknownFields_) {
    self->unknownFields_ = [[_GPBUnknownFieldSet alloc] init];
    _GPBBecomeVisibleToAutocreator(self);
  }
  return self->unknownFields_;
}

@implementation _GPBMessage

+ (void)initialize {
  Class pbMessageClass = [_GPBMessage class];
  if ([self class] == pbMessageClass) {
    // This is here to start up the "base" class descriptor.
    [self descriptor];
    // Message shares extension method resolving with _GPBRootObject so insure
    // it is started up at the same time.
    (void)[_GPBRootObject class];
  } else if ([self superclass] == pbMessageClass) {
    // This is here to start up all the "message" subclasses. Just needs to be
    // done for the messages, not any of the subclasses.
    // This must be done in initialize to enforce thread safety of start up of
    // the protocol buffer library.
    // Note: The generated code for -descriptor calls
    // +[_GPBDescriptor allocDescriptorForClass:...], passing the _GPBRootObject
    // subclass for the file.  That call chain is what ensures that *Root class
    // is started up to support extension resolution off the message class
    // (+resolveClassMethod: below) in a thread safe manner.
    [self descriptor];
  }
}

+ (instancetype)allocWithZone:(NSZone *)zone {
  // Override alloc to allocate our classes with the additional storage
  // required for the instance variables.
  _GPBDescriptor *descriptor = [self descriptor];
  return NSAllocateObject(self, descriptor->storageSize_, zone);
}

+ (instancetype)alloc {
  return [self allocWithZone:nil];
}

+ (_GPBDescriptor *)descriptor {
  // This is thread safe because it is called from +initialize.
  static _GPBDescriptor *descriptor = NULL;
  static _GPBFileDescriptor *fileDescriptor = NULL;
  if (!descriptor) {
    // Use a dummy file that marks it as proto2 syntax so when used generically
    // it supports unknowns/etc.
    fileDescriptor =
        [[_GPBFileDescriptor alloc] initWithPackage:@"internal"
                                            syntax:_GPBFileSyntaxProto2];

    descriptor = [_GPBDescriptor allocDescriptorForClass:[_GPBMessage class]
                                              rootClass:Nil
                                                   file:fileDescriptor
                                                 fields:NULL
                                             fieldCount:0
                                            storageSize:0
                                                  flags:0];
  }
  return descriptor;
}

+ (instancetype)message {
  return [[[self alloc] init] autorelease];
}

- (instancetype)init {
  if ((self = [super init])) {
    messageStorage_ = (_GPBMessage_StoragePtr)(
        ((uint8_t *)self) + class_getInstanceSize([self class]));
  }

  return self;
}

- (instancetype)initWithData:(NSData *)data error:(NSError **)errorPtr {
  return [self initWithData:data extensionRegistry:nil error:errorPtr];
}

- (instancetype)initWithData:(NSData *)data
           extensionRegistry:(_GPBExtensionRegistry *)extensionRegistry
                       error:(NSError **)errorPtr {
  if ((self = [self init])) {
    @try {
      [self mergeFromData:data extensionRegistry:extensionRegistry];
      if (errorPtr) {
        *errorPtr = nil;
      }
    }
    @catch (NSException *exception) {
      [self release];
      self = nil;
      if (errorPtr) {
        *errorPtr = ErrorFromException(exception);
      }
    }
#ifdef DEBUG
    if (self && !self.initialized) {
      [self release];
      self = nil;
      if (errorPtr) {
        *errorPtr = MessageError(_GPBMessageErrorCodeMissingRequiredField, nil);
      }
    }
#endif
  }
  return self;
}

- (instancetype)initWithCodedInputStream:(_GPBCodedInputStream *)input
                       extensionRegistry:
                           (_GPBExtensionRegistry *)extensionRegistry
                                   error:(NSError **)errorPtr {
  if ((self = [self init])) {
    @try {
      [self mergeFromCodedInputStream:input extensionRegistry:extensionRegistry];
      if (errorPtr) {
        *errorPtr = nil;
      }
    }
    @catch (NSException *exception) {
      [self release];
      self = nil;
      if (errorPtr) {
        *errorPtr = ErrorFromException(exception);
      }
    }
#ifdef DEBUG
    if (self && !self.initialized) {
      [self release];
      self = nil;
      if (errorPtr) {
        *errorPtr = MessageError(_GPBMessageErrorCodeMissingRequiredField, nil);
      }
    }
#endif
  }
  return self;
}

- (void)dealloc {
  [self internalClear:NO];
  NSCAssert(!autocreator_, @"Autocreator was not cleared before dealloc.");
  if (readOnlySemaphore_) {
    dispatch_release(readOnlySemaphore_);
  }
  [super dealloc];
}

- (void)copyFieldsInto:(_GPBMessage *)message
                  zone:(NSZone *)zone
            descriptor:(_GPBDescriptor *)descriptor {
  // Copy all the storage...
  memcpy(message->messageStorage_, messageStorage_, descriptor->storageSize_);

  _GPBFileSyntax syntax = descriptor.file.syntax;

  // Loop over the fields doing fixup...
  for (_GPBFieldDescriptor *field in descriptor->fields_) {
    if (_GPBFieldIsMapOrArray(field)) {
      id value = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
      if (value) {
        // We need to copy the array/map, but the catch is for message fields,
        // we also need to ensure all the messages as those need copying also.
        id newValue;
        if (_GPBFieldDataTypeIsMessage(field)) {
          if (field.fieldType == _GPBFieldTypeRepeated) {
            NSArray *existingArray = (NSArray *)value;
            NSMutableArray *newArray =
                [[NSMutableArray alloc] initWithCapacity:existingArray.count];
            newValue = newArray;
            for (_GPBMessage *msg in existingArray) {
              _GPBMessage *copiedMsg = [msg copyWithZone:zone];
              [newArray addObject:copiedMsg];
              [copiedMsg release];
            }
          } else {
            if (field.mapKeyDataType == _GPBDataTypeString) {
              // Map is an NSDictionary.
              NSDictionary *existingDict = value;
              NSMutableDictionary *newDict = [[NSMutableDictionary alloc]
                  initWithCapacity:existingDict.count];
              newValue = newDict;
              [existingDict enumerateKeysAndObjectsUsingBlock:^(NSString *key,
                                                                _GPBMessage *msg,
                                                                BOOL *stop) {
#pragma unused(stop)
                _GPBMessage *copiedMsg = [msg copyWithZone:zone];
                [newDict setObject:copiedMsg forKey:key];
                [copiedMsg release];
              }];
            } else {
              // Is one of the _GPB*ObjectDictionary classes.  Type doesn't
              // matter, just need one to invoke the selector.
              _GPBInt32ObjectDictionary *existingDict = value;
              newValue = [existingDict deepCopyWithZone:zone];
            }
          }
        } else {
          // Not messages (but is a map/array)...
          if (field.fieldType == _GPBFieldTypeRepeated) {
            if (_GPBFieldDataTypeIsObject(field)) {
              // NSArray
              newValue = [value mutableCopyWithZone:zone];
            } else {
              // _GPB*Array
              newValue = [value copyWithZone:zone];
            }
          } else {
            if ((field.mapKeyDataType == _GPBDataTypeString) &&
                _GPBFieldDataTypeIsObject(field)) {
              // NSDictionary
              newValue = [value mutableCopyWithZone:zone];
            } else {
              // Is one of the _GPB*Dictionary classes.  Type doesn't matter,
              // just need one to invoke the selector.
              _GPBInt32Int32Dictionary *existingDict = value;
              newValue = [existingDict copyWithZone:zone];
            }
          }
        }
        // We retain here because the memcpy picked up the pointer value and
        // the next call to SetRetainedObject... will release the current value.
        [value retain];
        _GPBSetRetainedObjectIvarWithFieldInternal(message, field, newValue,
                                                  syntax);
      }
    } else if (_GPBFieldDataTypeIsMessage(field)) {
      // For object types, if we have a value, copy it.  If we don't,
      // zero it to remove the pointer to something that was autocreated
      // (and the ptr just got memcpyed).
      if (_GPBGetHasIvarField(self, field)) {
        _GPBMessage *value = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        _GPBMessage *newValue = [value copyWithZone:zone];
        // We retain here because the memcpy picked up the pointer value and
        // the next call to SetRetainedObject... will release the current value.
        [value retain];
        _GPBSetRetainedObjectIvarWithFieldInternal(message, field, newValue,
                                                  syntax);
      } else {
        uint8_t *storage = (uint8_t *)message->messageStorage_;
        id *typePtr = (id *)&storage[field->description_->offset];
        *typePtr = NULL;
      }
    } else if (_GPBFieldDataTypeIsObject(field) &&
               _GPBGetHasIvarField(self, field)) {
      // A set string/data value (message picked off above), copy it.
      id value = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
      id newValue = [value copyWithZone:zone];
      // We retain here because the memcpy picked up the pointer value and
      // the next call to SetRetainedObject... will release the current value.
      [value retain];
      _GPBSetRetainedObjectIvarWithFieldInternal(message, field, newValue,
                                                syntax);
    } else {
      // memcpy took care of the rest of the primitive fields if they were set.
    }
  }  // for (field in descriptor->fields_)
}

- (id)copyWithZone:(NSZone *)zone {
  _GPBDescriptor *descriptor = [self descriptor];
  _GPBMessage *result = [[descriptor.messageClass allocWithZone:zone] init];

  [self copyFieldsInto:result zone:zone descriptor:descriptor];
  // Make immutable copies of the extra bits.
  result->unknownFields_ = [unknownFields_ copyWithZone:zone];
  result->extensionMap_ = CloneExtensionMap(extensionMap_, zone);
  return result;
}

- (void)clear {
  [self internalClear:YES];
}

- (void)internalClear:(BOOL)zeroStorage {
  _GPBDescriptor *descriptor = [self descriptor];
  for (_GPBFieldDescriptor *field in descriptor->fields_) {
    if (_GPBFieldIsMapOrArray(field)) {
      id arrayOrMap = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
      if (arrayOrMap) {
        if (field.fieldType == _GPBFieldTypeRepeated) {
          if (_GPBFieldDataTypeIsObject(field)) {
            if ([arrayOrMap isKindOfClass:[_GPBAutocreatedArray class]]) {
              _GPBAutocreatedArray *autoArray = arrayOrMap;
              if (autoArray->_autocreator == self) {
                autoArray->_autocreator = nil;
              }
            }
          } else {
            // Type doesn't matter, it is a _GPB*Array.
            _GPBInt32Array *gpbArray = arrayOrMap;
            if (gpbArray->_autocreator == self) {
              gpbArray->_autocreator = nil;
            }
          }
        } else {
          if ((field.mapKeyDataType == _GPBDataTypeString) &&
              _GPBFieldDataTypeIsObject(field)) {
            if ([arrayOrMap isKindOfClass:[_GPBAutocreatedDictionary class]]) {
              _GPBAutocreatedDictionary *autoDict = arrayOrMap;
              if (autoDict->_autocreator == self) {
                autoDict->_autocreator = nil;
              }
            }
          } else {
            // Type doesn't matter, it is a _GPB*Dictionary.
            _GPBInt32Int32Dictionary *gpbDict = arrayOrMap;
            if (gpbDict->_autocreator == self) {
              gpbDict->_autocreator = nil;
            }
          }
        }
        [arrayOrMap release];
      }
    } else if (_GPBFieldDataTypeIsMessage(field)) {
      _GPBClearAutocreatedMessageIvarWithField(self, field);
      _GPBMessage *value = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
      [value release];
    } else if (_GPBFieldDataTypeIsObject(field) &&
               _GPBGetHasIvarField(self, field)) {
      id value = _GPBGetObjectIvarWithField(self, field);
      [value release];
    }
  }

  // _GPBClearMessageAutocreator() expects that its caller has already been
  // removed from autocreatedExtensionMap_ so we set to nil first.
  NSArray *autocreatedValues = [autocreatedExtensionMap_ allValues];
  [autocreatedExtensionMap_ release];
  autocreatedExtensionMap_ = nil;

  // Since we're clearing all of our extensions, make sure that we clear the
  // autocreator on any that we've created so they no longer refer to us.
  for (_GPBMessage *value in autocreatedValues) {
    NSCAssert(_GPBWasMessageAutocreatedBy(value, self),
              @"Autocreated extension does not refer back to self.");
    _GPBClearMessageAutocreator(value);
  }

  [extensionMap_ release];
  extensionMap_ = nil;
  [unknownFields_ release];
  unknownFields_ = nil;

  // Note that clearing does not affect autocreator_. If we are being cleared
  // because of a dealloc, then autocreator_ should be nil anyway. If we are
  // being cleared because someone explicitly clears us, we don't want to
  // sever our relationship with our autocreator.

  if (zeroStorage) {
    memset(messageStorage_, 0, descriptor->storageSize_);
  }
}

- (BOOL)isInitialized {
  _GPBDescriptor *descriptor = [self descriptor];
  for (_GPBFieldDescriptor *field in descriptor->fields_) {
    if (field.isRequired) {
      if (!_GPBGetHasIvarField(self, field)) {
        return NO;
      }
    }
    if (_GPBFieldDataTypeIsMessage(field)) {
      _GPBFieldType fieldType = field.fieldType;
      if (fieldType == _GPBFieldTypeSingle) {
        if (field.isRequired) {
          _GPBMessage *message = _GPBGetMessageMessageField(self, field);
          if (!message.initialized) {
            return NO;
          }
        } else {
          NSAssert(field.isOptional,
                   @"%@: Single message field %@ not required or optional?",
                   [self class], field.name);
          if (_GPBGetHasIvarField(self, field)) {
            _GPBMessage *message = _GPBGetMessageMessageField(self, field);
            if (!message.initialized) {
              return NO;
            }
          }
        }
      } else if (fieldType == _GPBFieldTypeRepeated) {
        NSArray *array = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        for (_GPBMessage *message in array) {
          if (!message.initialized) {
            return NO;
          }
        }
      } else {  // fieldType == _GPBFieldTypeMap
        if (field.mapKeyDataType == _GPBDataTypeString) {
          NSDictionary *map =
              _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
          if (map && !_GPBDictionaryIsInitializedInternalHelper(map, field)) {
            return NO;
          }
        } else {
          // Real type is _GPB*ObjectDictionary, exact type doesn't matter.
          _GPBInt32ObjectDictionary *map =
              _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
          if (map && ![map isInitialized]) {
            return NO;
          }
        }
      }
    }
  }

  __block BOOL result = YES;
  [extensionMap_
      enumerateKeysAndObjectsUsingBlock:^(_GPBExtensionDescriptor *extension,
                                          id obj,
                                          BOOL *stop) {
        if (_GPBExtensionIsMessage(extension)) {
          if (extension.isRepeated) {
            for (_GPBMessage *msg in obj) {
              if (!msg.initialized) {
                result = NO;
                *stop = YES;
                break;
              }
            }
          } else {
            _GPBMessage *asMsg = obj;
            if (!asMsg.initialized) {
              result = NO;
              *stop = YES;
            }
          }
        }
      }];
  return result;
}

- (_GPBDescriptor *)descriptor {
  return [[self class] descriptor];
}

- (NSData *)data {
#ifdef DEBUG
  if (!self.initialized) {
    return nil;
  }
#endif
  NSMutableData *data = [NSMutableData dataWithLength:[self serializedSize]];
  _GPBCodedOutputStream *stream =
      [[_GPBCodedOutputStream alloc] initWithData:data];
  @try {
    [self writeToCodedOutputStream:stream];
  }
  @catch (NSException *exception) {
    // This really shouldn't happen. The only way writeToCodedOutputStream:
    // could throw is if something in the library has a bug and the
    // serializedSize was wrong.
#ifdef DEBUG
    NSLog(@"%@: Internal exception while building message data: %@",
          [self class], exception);
#endif
    data = nil;
  }
  [stream release];
  return data;
}

- (NSData *)delimitedData {
  size_t serializedSize = [self serializedSize];
  size_t varintSize = _GPBComputeRawVarint32SizeForInteger(serializedSize);
  NSMutableData *data =
      [NSMutableData dataWithLength:(serializedSize + varintSize)];
  _GPBCodedOutputStream *stream =
      [[_GPBCodedOutputStream alloc] initWithData:data];
  @try {
    [self writeDelimitedToCodedOutputStream:stream];
  }
  @catch (NSException *exception) {
    // This really shouldn't happen.  The only way writeToCodedOutputStream:
    // could throw is if something in the library has a bug and the
    // serializedSize was wrong.
#ifdef DEBUG
    NSLog(@"%@: Internal exception while building message delimitedData: %@",
          [self class], exception);
#endif
    // If it happens, truncate.
    data.length = 0;
  }
  [stream release];
  return data;
}

- (void)writeToOutputStream:(NSOutputStream *)output {
  _GPBCodedOutputStream *stream =
      [[_GPBCodedOutputStream alloc] initWithOutputStream:output];
  [self writeToCodedOutputStream:stream];
  [stream release];
}

- (void)writeToCodedOutputStream:(_GPBCodedOutputStream *)output {
  _GPBDescriptor *descriptor = [self descriptor];
  NSArray *fieldsArray = descriptor->fields_;
  NSUInteger fieldCount = fieldsArray.count;
  const _GPBExtensionRange *extensionRanges = descriptor.extensionRanges;
  NSUInteger extensionRangesCount = descriptor.extensionRangesCount;
  NSArray *sortedExtensions =
      [[extensionMap_ allKeys] sortedArrayUsingSelector:@selector(compareByFieldNumber:)];
  for (NSUInteger i = 0, j = 0; i < fieldCount || j < extensionRangesCount;) {
    if (i == fieldCount) {
      [self writeExtensionsToCodedOutputStream:output
                                         range:extensionRanges[j++]
                              sortedExtensions:sortedExtensions];
    } else if (j == extensionRangesCount ||
               _GPBFieldNumber(fieldsArray[i]) < extensionRanges[j].start) {
      [self writeField:fieldsArray[i++] toCodedOutputStream:output];
    } else {
      [self writeExtensionsToCodedOutputStream:output
                                         range:extensionRanges[j++]
                              sortedExtensions:sortedExtensions];
    }
  }
  if (descriptor.isWireFormat) {
    [unknownFields_ writeAsMessageSetTo:output];
  } else {
    [unknownFields_ writeToCodedOutputStream:output];
  }
}

- (void)writeDelimitedToOutputStream:(NSOutputStream *)output {
  _GPBCodedOutputStream *codedOutput =
      [[_GPBCodedOutputStream alloc] initWithOutputStream:output];
  [self writeDelimitedToCodedOutputStream:codedOutput];
  [codedOutput release];
}

- (void)writeDelimitedToCodedOutputStream:(_GPBCodedOutputStream *)output {
  [output writeRawVarintSizeTAs32:[self serializedSize]];
  [self writeToCodedOutputStream:output];
}

- (void)writeField:(_GPBFieldDescriptor *)field
    toCodedOutputStream:(_GPBCodedOutputStream *)output {
  _GPBFieldType fieldType = field.fieldType;
  if (fieldType == _GPBFieldTypeSingle) {
    BOOL has = _GPBGetHasIvarField(self, field);
    if (!has) {
      return;
    }
  }
  uint32_t fieldNumber = _GPBFieldNumber(field);

//%PDDM-DEFINE FIELD_CASE(TYPE, REAL_TYPE)
//%FIELD_CASE_FULL(TYPE, REAL_TYPE, REAL_TYPE)
//%PDDM-DEFINE FIELD_CASE_FULL(TYPE, REAL_TYPE, ARRAY_TYPE)
//%    case _GPBDataType##TYPE:
//%      if (fieldType == _GPBFieldTypeRepeated) {
//%        uint32_t tag = field.isPackable ? _GPBFieldTag(field) : 0;
//%        _GPB##ARRAY_TYPE##Array *array =
//%            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
//%        [output write##TYPE##Array:fieldNumber values:array tag:tag];
//%      } else if (fieldType == _GPBFieldTypeSingle) {
//%        [output write##TYPE:fieldNumber
//%              TYPE$S  value:_GPBGetMessage##REAL_TYPE##Field(self, field)];
//%      } else {  // fieldType == _GPBFieldTypeMap
//%        // Exact type here doesn't matter.
//%        _GPBInt32##ARRAY_TYPE##Dictionary *dict =
//%            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
//%        [dict writeToCodedOutputStream:output asField:field];
//%      }
//%      break;
//%
//%PDDM-DEFINE FIELD_CASE2(TYPE)
//%    case _GPBDataType##TYPE:
//%      if (fieldType == _GPBFieldTypeRepeated) {
//%        NSArray *array = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
//%        [output write##TYPE##Array:fieldNumber values:array];
//%      } else if (fieldType == _GPBFieldTypeSingle) {
//%        // _GPBGetObjectIvarWithFieldNoAutocreate() avoids doing the has check
//%        // again.
//%        [output write##TYPE:fieldNumber
//%              TYPE$S  value:_GPBGetObjectIvarWithFieldNoAutocreate(self, field)];
//%      } else {  // fieldType == _GPBFieldTypeMap
//%        // Exact type here doesn't matter.
//%        id dict = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
//%        _GPBDataType mapKeyDataType = field.mapKeyDataType;
//%        if (mapKeyDataType == _GPBDataTypeString) {
//%          _GPBDictionaryWriteToStreamInternalHelper(output, dict, field);
//%        } else {
//%          [dict writeToCodedOutputStream:output asField:field];
//%        }
//%      }
//%      break;
//%

  switch (_GPBGetFieldDataType(field)) {

//%PDDM-EXPAND FIELD_CASE(Bool, Bool)
// This block of code is generated, do not edit it directly.

    case _GPBDataTypeBool:
      if (fieldType == _GPBFieldTypeRepeated) {
        uint32_t tag = field.isPackable ? _GPBFieldTag(field) : 0;
        _GPBBoolArray *array =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [output writeBoolArray:fieldNumber values:array tag:tag];
      } else if (fieldType == _GPBFieldTypeSingle) {
        [output writeBool:fieldNumber
                    value:_GPBGetMessageBoolField(self, field)];
      } else {  // fieldType == _GPBFieldTypeMap
        // Exact type here doesn't matter.
        _GPBInt32BoolDictionary *dict =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [dict writeToCodedOutputStream:output asField:field];
      }
      break;

//%PDDM-EXPAND FIELD_CASE(Fixed32, UInt32)
// This block of code is generated, do not edit it directly.

    case _GPBDataTypeFixed32:
      if (fieldType == _GPBFieldTypeRepeated) {
        uint32_t tag = field.isPackable ? _GPBFieldTag(field) : 0;
        _GPBUInt32Array *array =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [output writeFixed32Array:fieldNumber values:array tag:tag];
      } else if (fieldType == _GPBFieldTypeSingle) {
        [output writeFixed32:fieldNumber
                       value:_GPBGetMessageUInt32Field(self, field)];
      } else {  // fieldType == _GPBFieldTypeMap
        // Exact type here doesn't matter.
        _GPBInt32UInt32Dictionary *dict =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [dict writeToCodedOutputStream:output asField:field];
      }
      break;

//%PDDM-EXPAND FIELD_CASE(SFixed32, Int32)
// This block of code is generated, do not edit it directly.

    case _GPBDataTypeSFixed32:
      if (fieldType == _GPBFieldTypeRepeated) {
        uint32_t tag = field.isPackable ? _GPBFieldTag(field) : 0;
        _GPBInt32Array *array =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [output writeSFixed32Array:fieldNumber values:array tag:tag];
      } else if (fieldType == _GPBFieldTypeSingle) {
        [output writeSFixed32:fieldNumber
                        value:_GPBGetMessageInt32Field(self, field)];
      } else {  // fieldType == _GPBFieldTypeMap
        // Exact type here doesn't matter.
        _GPBInt32Int32Dictionary *dict =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [dict writeToCodedOutputStream:output asField:field];
      }
      break;

//%PDDM-EXPAND FIELD_CASE(Float, Float)
// This block of code is generated, do not edit it directly.

    case _GPBDataTypeFloat:
      if (fieldType == _GPBFieldTypeRepeated) {
        uint32_t tag = field.isPackable ? _GPBFieldTag(field) : 0;
        _GPBFloatArray *array =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [output writeFloatArray:fieldNumber values:array tag:tag];
      } else if (fieldType == _GPBFieldTypeSingle) {
        [output writeFloat:fieldNumber
                     value:_GPBGetMessageFloatField(self, field)];
      } else {  // fieldType == _GPBFieldTypeMap
        // Exact type here doesn't matter.
        _GPBInt32FloatDictionary *dict =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [dict writeToCodedOutputStream:output asField:field];
      }
      break;

//%PDDM-EXPAND FIELD_CASE(Fixed64, UInt64)
// This block of code is generated, do not edit it directly.

    case _GPBDataTypeFixed64:
      if (fieldType == _GPBFieldTypeRepeated) {
        uint32_t tag = field.isPackable ? _GPBFieldTag(field) : 0;
        _GPBUInt64Array *array =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [output writeFixed64Array:fieldNumber values:array tag:tag];
      } else if (fieldType == _GPBFieldTypeSingle) {
        [output writeFixed64:fieldNumber
                       value:_GPBGetMessageUInt64Field(self, field)];
      } else {  // fieldType == _GPBFieldTypeMap
        // Exact type here doesn't matter.
        _GPBInt32UInt64Dictionary *dict =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [dict writeToCodedOutputStream:output asField:field];
      }
      break;

//%PDDM-EXPAND FIELD_CASE(SFixed64, Int64)
// This block of code is generated, do not edit it directly.

    case _GPBDataTypeSFixed64:
      if (fieldType == _GPBFieldTypeRepeated) {
        uint32_t tag = field.isPackable ? _GPBFieldTag(field) : 0;
        _GPBInt64Array *array =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [output writeSFixed64Array:fieldNumber values:array tag:tag];
      } else if (fieldType == _GPBFieldTypeSingle) {
        [output writeSFixed64:fieldNumber
                        value:_GPBGetMessageInt64Field(self, field)];
      } else {  // fieldType == _GPBFieldTypeMap
        // Exact type here doesn't matter.
        _GPBInt32Int64Dictionary *dict =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [dict writeToCodedOutputStream:output asField:field];
      }
      break;

//%PDDM-EXPAND FIELD_CASE(Double, Double)
// This block of code is generated, do not edit it directly.

    case _GPBDataTypeDouble:
      if (fieldType == _GPBFieldTypeRepeated) {
        uint32_t tag = field.isPackable ? _GPBFieldTag(field) : 0;
        _GPBDoubleArray *array =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [output writeDoubleArray:fieldNumber values:array tag:tag];
      } else if (fieldType == _GPBFieldTypeSingle) {
        [output writeDouble:fieldNumber
                      value:_GPBGetMessageDoubleField(self, field)];
      } else {  // fieldType == _GPBFieldTypeMap
        // Exact type here doesn't matter.
        _GPBInt32DoubleDictionary *dict =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [dict writeToCodedOutputStream:output asField:field];
      }
      break;

//%PDDM-EXPAND FIELD_CASE(Int32, Int32)
// This block of code is generated, do not edit it directly.

    case _GPBDataTypeInt32:
      if (fieldType == _GPBFieldTypeRepeated) {
        uint32_t tag = field.isPackable ? _GPBFieldTag(field) : 0;
        _GPBInt32Array *array =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [output writeInt32Array:fieldNumber values:array tag:tag];
      } else if (fieldType == _GPBFieldTypeSingle) {
        [output writeInt32:fieldNumber
                     value:_GPBGetMessageInt32Field(self, field)];
      } else {  // fieldType == _GPBFieldTypeMap
        // Exact type here doesn't matter.
        _GPBInt32Int32Dictionary *dict =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [dict writeToCodedOutputStream:output asField:field];
      }
      break;

//%PDDM-EXPAND FIELD_CASE(Int64, Int64)
// This block of code is generated, do not edit it directly.

    case _GPBDataTypeInt64:
      if (fieldType == _GPBFieldTypeRepeated) {
        uint32_t tag = field.isPackable ? _GPBFieldTag(field) : 0;
        _GPBInt64Array *array =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [output writeInt64Array:fieldNumber values:array tag:tag];
      } else if (fieldType == _GPBFieldTypeSingle) {
        [output writeInt64:fieldNumber
                     value:_GPBGetMessageInt64Field(self, field)];
      } else {  // fieldType == _GPBFieldTypeMap
        // Exact type here doesn't matter.
        _GPBInt32Int64Dictionary *dict =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [dict writeToCodedOutputStream:output asField:field];
      }
      break;

//%PDDM-EXPAND FIELD_CASE(SInt32, Int32)
// This block of code is generated, do not edit it directly.

    case _GPBDataTypeSInt32:
      if (fieldType == _GPBFieldTypeRepeated) {
        uint32_t tag = field.isPackable ? _GPBFieldTag(field) : 0;
        _GPBInt32Array *array =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [output writeSInt32Array:fieldNumber values:array tag:tag];
      } else if (fieldType == _GPBFieldTypeSingle) {
        [output writeSInt32:fieldNumber
                      value:_GPBGetMessageInt32Field(self, field)];
      } else {  // fieldType == _GPBFieldTypeMap
        // Exact type here doesn't matter.
        _GPBInt32Int32Dictionary *dict =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [dict writeToCodedOutputStream:output asField:field];
      }
      break;

//%PDDM-EXPAND FIELD_CASE(SInt64, Int64)
// This block of code is generated, do not edit it directly.

    case _GPBDataTypeSInt64:
      if (fieldType == _GPBFieldTypeRepeated) {
        uint32_t tag = field.isPackable ? _GPBFieldTag(field) : 0;
        _GPBInt64Array *array =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [output writeSInt64Array:fieldNumber values:array tag:tag];
      } else if (fieldType == _GPBFieldTypeSingle) {
        [output writeSInt64:fieldNumber
                      value:_GPBGetMessageInt64Field(self, field)];
      } else {  // fieldType == _GPBFieldTypeMap
        // Exact type here doesn't matter.
        _GPBInt32Int64Dictionary *dict =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [dict writeToCodedOutputStream:output asField:field];
      }
      break;

//%PDDM-EXPAND FIELD_CASE(UInt32, UInt32)
// This block of code is generated, do not edit it directly.

    case _GPBDataTypeUInt32:
      if (fieldType == _GPBFieldTypeRepeated) {
        uint32_t tag = field.isPackable ? _GPBFieldTag(field) : 0;
        _GPBUInt32Array *array =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [output writeUInt32Array:fieldNumber values:array tag:tag];
      } else if (fieldType == _GPBFieldTypeSingle) {
        [output writeUInt32:fieldNumber
                      value:_GPBGetMessageUInt32Field(self, field)];
      } else {  // fieldType == _GPBFieldTypeMap
        // Exact type here doesn't matter.
        _GPBInt32UInt32Dictionary *dict =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [dict writeToCodedOutputStream:output asField:field];
      }
      break;

//%PDDM-EXPAND FIELD_CASE(UInt64, UInt64)
// This block of code is generated, do not edit it directly.

    case _GPBDataTypeUInt64:
      if (fieldType == _GPBFieldTypeRepeated) {
        uint32_t tag = field.isPackable ? _GPBFieldTag(field) : 0;
        _GPBUInt64Array *array =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [output writeUInt64Array:fieldNumber values:array tag:tag];
      } else if (fieldType == _GPBFieldTypeSingle) {
        [output writeUInt64:fieldNumber
                      value:_GPBGetMessageUInt64Field(self, field)];
      } else {  // fieldType == _GPBFieldTypeMap
        // Exact type here doesn't matter.
        _GPBInt32UInt64Dictionary *dict =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [dict writeToCodedOutputStream:output asField:field];
      }
      break;

//%PDDM-EXPAND FIELD_CASE_FULL(Enum, Int32, Enum)
// This block of code is generated, do not edit it directly.

    case _GPBDataTypeEnum:
      if (fieldType == _GPBFieldTypeRepeated) {
        uint32_t tag = field.isPackable ? _GPBFieldTag(field) : 0;
        _GPBEnumArray *array =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [output writeEnumArray:fieldNumber values:array tag:tag];
      } else if (fieldType == _GPBFieldTypeSingle) {
        [output writeEnum:fieldNumber
                    value:_GPBGetMessageInt32Field(self, field)];
      } else {  // fieldType == _GPBFieldTypeMap
        // Exact type here doesn't matter.
        _GPBInt32EnumDictionary *dict =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [dict writeToCodedOutputStream:output asField:field];
      }
      break;

//%PDDM-EXPAND FIELD_CASE2(Bytes)
// This block of code is generated, do not edit it directly.

    case _GPBDataTypeBytes:
      if (fieldType == _GPBFieldTypeRepeated) {
        NSArray *array = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [output writeBytesArray:fieldNumber values:array];
      } else if (fieldType == _GPBFieldTypeSingle) {
        // _GPBGetObjectIvarWithFieldNoAutocreate() avoids doing the has check
        // again.
        [output writeBytes:fieldNumber
                     value:_GPBGetObjectIvarWithFieldNoAutocreate(self, field)];
      } else {  // fieldType == _GPBFieldTypeMap
        // Exact type here doesn't matter.
        id dict = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        _GPBDataType mapKeyDataType = field.mapKeyDataType;
        if (mapKeyDataType == _GPBDataTypeString) {
          _GPBDictionaryWriteToStreamInternalHelper(output, dict, field);
        } else {
          [dict writeToCodedOutputStream:output asField:field];
        }
      }
      break;

//%PDDM-EXPAND FIELD_CASE2(String)
// This block of code is generated, do not edit it directly.

    case _GPBDataTypeString:
      if (fieldType == _GPBFieldTypeRepeated) {
        NSArray *array = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [output writeStringArray:fieldNumber values:array];
      } else if (fieldType == _GPBFieldTypeSingle) {
        // _GPBGetObjectIvarWithFieldNoAutocreate() avoids doing the has check
        // again.
        [output writeString:fieldNumber
                      value:_GPBGetObjectIvarWithFieldNoAutocreate(self, field)];
      } else {  // fieldType == _GPBFieldTypeMap
        // Exact type here doesn't matter.
        id dict = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        _GPBDataType mapKeyDataType = field.mapKeyDataType;
        if (mapKeyDataType == _GPBDataTypeString) {
          _GPBDictionaryWriteToStreamInternalHelper(output, dict, field);
        } else {
          [dict writeToCodedOutputStream:output asField:field];
        }
      }
      break;

//%PDDM-EXPAND FIELD_CASE2(Message)
// This block of code is generated, do not edit it directly.

    case _GPBDataTypeMessage:
      if (fieldType == _GPBFieldTypeRepeated) {
        NSArray *array = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [output writeMessageArray:fieldNumber values:array];
      } else if (fieldType == _GPBFieldTypeSingle) {
        // _GPBGetObjectIvarWithFieldNoAutocreate() avoids doing the has check
        // again.
        [output writeMessage:fieldNumber
                       value:_GPBGetObjectIvarWithFieldNoAutocreate(self, field)];
      } else {  // fieldType == _GPBFieldTypeMap
        // Exact type here doesn't matter.
        id dict = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        _GPBDataType mapKeyDataType = field.mapKeyDataType;
        if (mapKeyDataType == _GPBDataTypeString) {
          _GPBDictionaryWriteToStreamInternalHelper(output, dict, field);
        } else {
          [dict writeToCodedOutputStream:output asField:field];
        }
      }
      break;

//%PDDM-EXPAND FIELD_CASE2(Group)
// This block of code is generated, do not edit it directly.

    case _GPBDataTypeGroup:
      if (fieldType == _GPBFieldTypeRepeated) {
        NSArray *array = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [output writeGroupArray:fieldNumber values:array];
      } else if (fieldType == _GPBFieldTypeSingle) {
        // _GPBGetObjectIvarWithFieldNoAutocreate() avoids doing the has check
        // again.
        [output writeGroup:fieldNumber
                     value:_GPBGetObjectIvarWithFieldNoAutocreate(self, field)];
      } else {  // fieldType == _GPBFieldTypeMap
        // Exact type here doesn't matter.
        id dict = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        _GPBDataType mapKeyDataType = field.mapKeyDataType;
        if (mapKeyDataType == _GPBDataTypeString) {
          _GPBDictionaryWriteToStreamInternalHelper(output, dict, field);
        } else {
          [dict writeToCodedOutputStream:output asField:field];
        }
      }
      break;

//%PDDM-EXPAND-END (18 expansions)
  }
}

#pragma mark - Extensions

- (id)getExtension:(_GPBExtensionDescriptor *)extension {
  CheckExtension(self, extension);
  id value = [extensionMap_ objectForKey:extension];
  if (value != nil) {
    return value;
  }

  // No default for repeated.
  if (extension.isRepeated) {
    return nil;
  }
  // Non messages get their default.
  if (!_GPBExtensionIsMessage(extension)) {
    return extension.defaultValue;
  }

  // Check for an autocreated value.
  _GPBPrepareReadOnlySemaphore(self);
  dispatch_semaphore_wait(readOnlySemaphore_, DISPATCH_TIME_FOREVER);
  value = [autocreatedExtensionMap_ objectForKey:extension];
  if (!value) {
    // Auto create the message extensions to match normal fields.
    value = CreateMessageWithAutocreatorForExtension(extension.msgClass, self,
                                                     extension);

    if (autocreatedExtensionMap_ == nil) {
      autocreatedExtensionMap_ = [[NSMutableDictionary alloc] init];
    }

    // We can't simply call setExtension here because that would clear the new
    // value's autocreator.
    [autocreatedExtensionMap_ setObject:value forKey:extension];
    [value release];
  }

  dispatch_semaphore_signal(readOnlySemaphore_);
  return value;
}

- (id)getExistingExtension:(_GPBExtensionDescriptor *)extension {
  // This is an internal method so we don't need to call CheckExtension().
  return [extensionMap_ objectForKey:extension];
}

- (BOOL)hasExtension:(_GPBExtensionDescriptor *)extension {
#if defined(DEBUG) && DEBUG
  CheckExtension(self, extension);
#endif  // DEBUG
  return nil != [extensionMap_ objectForKey:extension];
}

- (NSArray *)extensionsCurrentlySet {
  return [extensionMap_ allKeys];
}

- (void)writeExtensionsToCodedOutputStream:(_GPBCodedOutputStream *)output
                                     range:(_GPBExtensionRange)range
                          sortedExtensions:(NSArray *)sortedExtensions {
  uint32_t start = range.start;
  uint32_t end = range.end;
  for (_GPBExtensionDescriptor *extension in sortedExtensions) {
    uint32_t fieldNumber = extension.fieldNumber;
    if (fieldNumber < start) {
      continue;
    }
    if (fieldNumber >= end) {
      break;
    }
    id value = [extensionMap_ objectForKey:extension];
    _GPBWriteExtensionValueToOutputStream(extension, value, output);
  }
}

- (void)setExtension:(_GPBExtensionDescriptor *)extension value:(id)value {
  if (!value) {
    [self clearExtension:extension];
    return;
  }

  CheckExtension(self, extension);

  if (extension.repeated) {
    [NSException raise:NSInvalidArgumentException
                format:@"Must call addExtension() for repeated types."];
  }

  if (extensionMap_ == nil) {
    extensionMap_ = [[NSMutableDictionary alloc] init];
  }

  // This pointless cast is for CLANG_WARN_NULLABLE_TO_NONNULL_CONVERSION.
  // Without it, the compiler complains we're passing an id nullable when
  // setObject:forKey: requires a id nonnull for the value. The check for
  // !value at the start of the method ensures it isn't nil, but the check
  // isn't smart enough to realize that.
  [extensionMap_ setObject:(id)value forKey:extension];

  _GPBExtensionDescriptor *descriptor = extension;

  if (_GPBExtensionIsMessage(descriptor) && !descriptor.isRepeated) {
    _GPBMessage *autocreatedValue =
        [[autocreatedExtensionMap_ objectForKey:extension] retain];
    // Must remove from the map before calling _GPBClearMessageAutocreator() so
    // that _GPBClearMessageAutocreator() knows its safe to clear.
    [autocreatedExtensionMap_ removeObjectForKey:extension];
    _GPBClearMessageAutocreator(autocreatedValue);
    [autocreatedValue release];
  }

  _GPBBecomeVisibleToAutocreator(self);
}

- (void)addExtension:(_GPBExtensionDescriptor *)extension value:(id)value {
  CheckExtension(self, extension);

  if (!extension.repeated) {
    [NSException raise:NSInvalidArgumentException
                format:@"Must call setExtension() for singular types."];
  }

  if (extensionMap_ == nil) {
    extensionMap_ = [[NSMutableDictionary alloc] init];
  }
  NSMutableArray *list = [extensionMap_ objectForKey:extension];
  if (list == nil) {
    list = [NSMutableArray array];
    [extensionMap_ setObject:list forKey:extension];
  }

  [list addObject:value];
  _GPBBecomeVisibleToAutocreator(self);
}

- (void)setExtension:(_GPBExtensionDescriptor *)extension
               index:(NSUInteger)idx
               value:(id)value {
  CheckExtension(self, extension);

  if (!extension.repeated) {
    [NSException raise:NSInvalidArgumentException
                format:@"Must call setExtension() for singular types."];
  }

  if (extensionMap_ == nil) {
    extensionMap_ = [[NSMutableDictionary alloc] init];
  }

  NSMutableArray *list = [extensionMap_ objectForKey:extension];

  [list replaceObjectAtIndex:idx withObject:value];
  _GPBBecomeVisibleToAutocreator(self);
}

- (void)clearExtension:(_GPBExtensionDescriptor *)extension {
  CheckExtension(self, extension);

  // Only become visible if there was actually a value to clear.
  if ([extensionMap_ objectForKey:extension]) {
    [extensionMap_ removeObjectForKey:extension];
    _GPBBecomeVisibleToAutocreator(self);
  }
}

#pragma mark - mergeFrom

- (void)mergeFromData:(NSData *)data
    extensionRegistry:(_GPBExtensionRegistry *)extensionRegistry {
  _GPBCodedInputStream *input = [[_GPBCodedInputStream alloc] initWithData:data];
  [self mergeFromCodedInputStream:input extensionRegistry:extensionRegistry];
  [input checkLastTagWas:0];
  [input release];
}

#pragma mark - mergeDelimitedFrom

- (void)mergeDelimitedFromCodedInputStream:(_GPBCodedInputStream *)input
                         extensionRegistry:(_GPBExtensionRegistry *)extensionRegistry {
  _GPBCodedInputStreamState *state = &input->state_;
  if (_GPBCodedInputStreamIsAtEnd(state)) {
    return;
  }
  NSData *data = _GPBCodedInputStreamReadRetainedBytesNoCopy(state);
  if (data == nil) {
    return;
  }
  [self mergeFromData:data extensionRegistry:extensionRegistry];
  [data release];
}

#pragma mark - Parse From Data Support

+ (instancetype)parseFromData:(NSData *)data error:(NSError **)errorPtr {
  return [self parseFromData:data extensionRegistry:nil error:errorPtr];
}

+ (instancetype)parseFromData:(NSData *)data
            extensionRegistry:(_GPBExtensionRegistry *)extensionRegistry
                        error:(NSError **)errorPtr {
  return [[[self alloc] initWithData:data
                   extensionRegistry:extensionRegistry
                               error:errorPtr] autorelease];
}

+ (instancetype)parseFromCodedInputStream:(_GPBCodedInputStream *)input
                        extensionRegistry:(_GPBExtensionRegistry *)extensionRegistry
                                    error:(NSError **)errorPtr {
  return
      [[[self alloc] initWithCodedInputStream:input
                            extensionRegistry:extensionRegistry
                                        error:errorPtr] autorelease];
}

#pragma mark - Parse Delimited From Data Support

+ (instancetype)parseDelimitedFromCodedInputStream:(_GPBCodedInputStream *)input
                                 extensionRegistry:
                                     (_GPBExtensionRegistry *)extensionRegistry
                                             error:(NSError **)errorPtr {
  _GPBMessage *message = [[[self alloc] init] autorelease];
  @try {
    [message mergeDelimitedFromCodedInputStream:input
                              extensionRegistry:extensionRegistry];
    if (errorPtr) {
      *errorPtr = nil;
    }
  }
  @catch (NSException *exception) {
    message = nil;
    if (errorPtr) {
      *errorPtr = ErrorFromException(exception);
    }
  }
#ifdef DEBUG
  if (message && !message.initialized) {
    message = nil;
    if (errorPtr) {
      *errorPtr = MessageError(_GPBMessageErrorCodeMissingRequiredField, nil);
    }
  }
#endif
  return message;
}

#pragma mark - Unknown Field Support

- (_GPBUnknownFieldSet *)unknownFields {
  return unknownFields_;
}

- (void)setUnknownFields:(_GPBUnknownFieldSet *)unknownFields {
  if (unknownFields != unknownFields_) {
    [unknownFields_ release];
    unknownFields_ = [unknownFields copy];
    _GPBBecomeVisibleToAutocreator(self);
  }
}

- (void)parseMessageSet:(_GPBCodedInputStream *)input
      extensionRegistry:(_GPBExtensionRegistry *)extensionRegistry {
  uint32_t typeId = 0;
  NSData *rawBytes = nil;
  _GPBExtensionDescriptor *extension = nil;
  _GPBCodedInputStreamState *state = &input->state_;
  while (true) {
    uint32_t tag = _GPBCodedInputStreamReadTag(state);
    if (tag == 0) {
      break;
    }

    if (tag == _GPBWireFormatMessageSetTypeIdTag) {
      typeId = _GPBCodedInputStreamReadUInt32(state);
      if (typeId != 0) {
        extension = [extensionRegistry extensionForDescriptor:[self descriptor]
                                                  fieldNumber:typeId];
      }
    } else if (tag == _GPBWireFormatMessageSetMessageTag) {
      rawBytes =
          [_GPBCodedInputStreamReadRetainedBytesNoCopy(state) autorelease];
    } else {
      if (![input skipField:tag]) {
        break;
      }
    }
  }

  [input checkLastTagWas:_GPBWireFormatMessageSetItemEndTag];

  if (rawBytes != nil && typeId != 0) {
    if (extension != nil) {
      _GPBCodedInputStream *newInput =
          [[_GPBCodedInputStream alloc] initWithData:rawBytes];
      _GPBExtensionMergeFromInputStream(extension,
                                       extension.packable,
                                       newInput,
                                       extensionRegistry,
                                       self);
      [newInput release];
    } else {
      _GPBUnknownFieldSet *unknownFields = GetOrMakeUnknownFields(self);
      // rawBytes was created via a NoCopy, so it can be reusing a
      // subrange of another NSData that might go out of scope as things
      // unwind, so a copy is needed to ensure what is saved in the
      // unknown fields stays valid.
      NSData *cloned = [NSData dataWithData:rawBytes];
      [unknownFields mergeMessageSetMessage:typeId data:cloned];
    }
  }
}

- (BOOL)parseUnknownField:(_GPBCodedInputStream *)input
        extensionRegistry:(_GPBExtensionRegistry *)extensionRegistry
                      tag:(uint32_t)tag {
  _GPBWireFormat wireType = _GPBWireFormatGetTagWireType(tag);
  int32_t fieldNumber = _GPBWireFormatGetTagFieldNumber(tag);

  _GPBDescriptor *descriptor = [self descriptor];
  _GPBExtensionDescriptor *extension =
      [extensionRegistry extensionForDescriptor:descriptor
                                    fieldNumber:fieldNumber];
  if (extension == nil) {
    if (descriptor.wireFormat && _GPBWireFormatMessageSetItemTag == tag) {
      [self parseMessageSet:input extensionRegistry:extensionRegistry];
      return YES;
    }
  } else {
    if (extension.wireType == wireType) {
      _GPBExtensionMergeFromInputStream(extension,
                                       extension.packable,
                                       input,
                                       extensionRegistry,
                                       self);
      return YES;
    }
    // Primitive, repeated types can be packed on unpacked on the wire, and are
    // parsed either way.
    if ([extension isRepeated] &&
        !_GPBDataTypeIsObject(extension->description_->dataType) &&
        (extension.alternateWireType == wireType)) {
      _GPBExtensionMergeFromInputStream(extension,
                                       !extension.packable,
                                       input,
                                       extensionRegistry,
                                       self);
      return YES;
    }
  }
  if ([_GPBUnknownFieldSet isFieldTag:tag]) {
    _GPBUnknownFieldSet *unknownFields = GetOrMakeUnknownFields(self);
    return [unknownFields mergeFieldFrom:tag input:input];
  } else {
    return NO;
  }
}

- (void)addUnknownMapEntry:(int32_t)fieldNum value:(NSData *)data {
  _GPBUnknownFieldSet *unknownFields = GetOrMakeUnknownFields(self);
  [unknownFields addUnknownMapEntry:fieldNum value:data];
}

#pragma mark - MergeFromCodedInputStream Support

static void MergeSingleFieldFromCodedInputStream(
    _GPBMessage *self, _GPBFieldDescriptor *field, _GPBFileSyntax syntax,
    _GPBCodedInputStream *input, _GPBExtensionRegistry *extensionRegistry) {
  _GPBDataType fieldDataType = _GPBGetFieldDataType(field);
  switch (fieldDataType) {
#define CASE_SINGLE_POD(NAME, TYPE, FUNC_TYPE)                             \
    case _GPBDataType##NAME: {                                              \
      TYPE val = _GPBCodedInputStreamRead##NAME(&input->state_);            \
      _GPBSet##FUNC_TYPE##IvarWithFieldInternal(self, field, val, syntax);  \
      break;                                                               \
            }
#define CASE_SINGLE_OBJECT(NAME)                                           \
    case _GPBDataType##NAME: {                                              \
      id val = _GPBCodedInputStreamReadRetained##NAME(&input->state_);      \
      _GPBSetRetainedObjectIvarWithFieldInternal(self, field, val, syntax); \
      break;                                                               \
    }
      CASE_SINGLE_POD(Bool, BOOL, Bool)
      CASE_SINGLE_POD(Fixed32, uint32_t, UInt32)
      CASE_SINGLE_POD(SFixed32, int32_t, Int32)
      CASE_SINGLE_POD(Float, float, Float)
      CASE_SINGLE_POD(Fixed64, uint64_t, UInt64)
      CASE_SINGLE_POD(SFixed64, int64_t, Int64)
      CASE_SINGLE_POD(Double, double, Double)
      CASE_SINGLE_POD(Int32, int32_t, Int32)
      CASE_SINGLE_POD(Int64, int64_t, Int64)
      CASE_SINGLE_POD(SInt32, int32_t, Int32)
      CASE_SINGLE_POD(SInt64, int64_t, Int64)
      CASE_SINGLE_POD(UInt32, uint32_t, UInt32)
      CASE_SINGLE_POD(UInt64, uint64_t, UInt64)
      CASE_SINGLE_OBJECT(Bytes)
      CASE_SINGLE_OBJECT(String)
#undef CASE_SINGLE_POD
#undef CASE_SINGLE_OBJECT

    case _GPBDataTypeMessage: {
      if (_GPBGetHasIvarField(self, field)) {
        // _GPBGetObjectIvarWithFieldNoAutocreate() avoids doing the has
        // check again.
        _GPBMessage *message =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [input readMessage:message extensionRegistry:extensionRegistry];
      } else {
        _GPBMessage *message = [[field.msgClass alloc] init];
        [input readMessage:message extensionRegistry:extensionRegistry];
        _GPBSetRetainedObjectIvarWithFieldInternal(self, field, message, syntax);
      }
      break;
    }

    case _GPBDataTypeGroup: {
      if (_GPBGetHasIvarField(self, field)) {
        // _GPBGetObjectIvarWithFieldNoAutocreate() avoids doing the has
        // check again.
        _GPBMessage *message =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
        [input readGroup:_GPBFieldNumber(field)
                      message:message
            extensionRegistry:extensionRegistry];
      } else {
        _GPBMessage *message = [[field.msgClass alloc] init];
        [input readGroup:_GPBFieldNumber(field)
                      message:message
            extensionRegistry:extensionRegistry];
        _GPBSetRetainedObjectIvarWithFieldInternal(self, field, message, syntax);
      }
      break;
    }

    case _GPBDataTypeEnum: {
      int32_t val = _GPBCodedInputStreamReadEnum(&input->state_);
      if (_GPBHasPreservingUnknownEnumSemantics(syntax) ||
          [field isValidEnumValue:val]) {
        _GPBSetInt32IvarWithFieldInternal(self, field, val, syntax);
      } else {
        _GPBUnknownFieldSet *unknownFields = GetOrMakeUnknownFields(self);
        [unknownFields mergeVarintField:_GPBFieldNumber(field) value:val];
      }
    }
  }  // switch
}

static void MergeRepeatedPackedFieldFromCodedInputStream(
    _GPBMessage *self, _GPBFieldDescriptor *field, _GPBFileSyntax syntax,
    _GPBCodedInputStream *input) {
  _GPBDataType fieldDataType = _GPBGetFieldDataType(field);
  _GPBCodedInputStreamState *state = &input->state_;
  id genericArray = GetOrCreateArrayIvarWithField(self, field, syntax);
  int32_t length = _GPBCodedInputStreamReadInt32(state);
  size_t limit = _GPBCodedInputStreamPushLimit(state, length);
  while (_GPBCodedInputStreamBytesUntilLimit(state) > 0) {
    switch (fieldDataType) {
#define CASE_REPEATED_PACKED_POD(NAME, TYPE, ARRAY_TYPE)      \
     case _GPBDataType##NAME: {                                \
       TYPE val = _GPBCodedInputStreamRead##NAME(state);       \
       [(_GPB##ARRAY_TYPE##Array *)genericArray addValue:val]; \
       break;                                                 \
     }
        CASE_REPEATED_PACKED_POD(Bool, BOOL, Bool)
        CASE_REPEATED_PACKED_POD(Fixed32, uint32_t, UInt32)
        CASE_REPEATED_PACKED_POD(SFixed32, int32_t, Int32)
        CASE_REPEATED_PACKED_POD(Float, float, Float)
        CASE_REPEATED_PACKED_POD(Fixed64, uint64_t, UInt64)
        CASE_REPEATED_PACKED_POD(SFixed64, int64_t, Int64)
        CASE_REPEATED_PACKED_POD(Double, double, Double)
        CASE_REPEATED_PACKED_POD(Int32, int32_t, Int32)
        CASE_REPEATED_PACKED_POD(Int64, int64_t, Int64)
        CASE_REPEATED_PACKED_POD(SInt32, int32_t, Int32)
        CASE_REPEATED_PACKED_POD(SInt64, int64_t, Int64)
        CASE_REPEATED_PACKED_POD(UInt32, uint32_t, UInt32)
        CASE_REPEATED_PACKED_POD(UInt64, uint64_t, UInt64)
#undef CASE_REPEATED_PACKED_POD

      case _GPBDataTypeBytes:
      case _GPBDataTypeString:
      case _GPBDataTypeMessage:
      case _GPBDataTypeGroup:
        NSCAssert(NO, @"Non primitive types can't be packed");
        break;

      case _GPBDataTypeEnum: {
        int32_t val = _GPBCodedInputStreamReadEnum(state);
        if (_GPBHasPreservingUnknownEnumSemantics(syntax) ||
            [field isValidEnumValue:val]) {
          [(_GPBEnumArray*)genericArray addRawValue:val];
        } else {
          _GPBUnknownFieldSet *unknownFields = GetOrMakeUnknownFields(self);
          [unknownFields mergeVarintField:_GPBFieldNumber(field) value:val];
        }
        break;
      }
    }  // switch
  }  // while(BytesUntilLimit() > 0)
  _GPBCodedInputStreamPopLimit(state, limit);
}

static void MergeRepeatedNotPackedFieldFromCodedInputStream(
    _GPBMessage *self, _GPBFieldDescriptor *field, _GPBFileSyntax syntax,
    _GPBCodedInputStream *input, _GPBExtensionRegistry *extensionRegistry) {
  _GPBCodedInputStreamState *state = &input->state_;
  id genericArray = GetOrCreateArrayIvarWithField(self, field, syntax);
  switch (_GPBGetFieldDataType(field)) {
#define CASE_REPEATED_NOT_PACKED_POD(NAME, TYPE, ARRAY_TYPE) \
   case _GPBDataType##NAME: {                                 \
     TYPE val = _GPBCodedInputStreamRead##NAME(state);        \
     [(_GPB##ARRAY_TYPE##Array *)genericArray addValue:val];  \
     break;                                                  \
   }
#define CASE_REPEATED_NOT_PACKED_OBJECT(NAME)                \
   case _GPBDataType##NAME: {                                 \
     id val = _GPBCodedInputStreamReadRetained##NAME(state);  \
     [(NSMutableArray*)genericArray addObject:val];          \
     [val release];                                          \
     break;                                                  \
   }
      CASE_REPEATED_NOT_PACKED_POD(Bool, BOOL, Bool)
      CASE_REPEATED_NOT_PACKED_POD(Fixed32, uint32_t, UInt32)
      CASE_REPEATED_NOT_PACKED_POD(SFixed32, int32_t, Int32)
      CASE_REPEATED_NOT_PACKED_POD(Float, float, Float)
      CASE_REPEATED_NOT_PACKED_POD(Fixed64, uint64_t, UInt64)
      CASE_REPEATED_NOT_PACKED_POD(SFixed64, int64_t, Int64)
      CASE_REPEATED_NOT_PACKED_POD(Double, double, Double)
      CASE_REPEATED_NOT_PACKED_POD(Int32, int32_t, Int32)
      CASE_REPEATED_NOT_PACKED_POD(Int64, int64_t, Int64)
      CASE_REPEATED_NOT_PACKED_POD(SInt32, int32_t, Int32)
      CASE_REPEATED_NOT_PACKED_POD(SInt64, int64_t, Int64)
      CASE_REPEATED_NOT_PACKED_POD(UInt32, uint32_t, UInt32)
      CASE_REPEATED_NOT_PACKED_POD(UInt64, uint64_t, UInt64)
      CASE_REPEATED_NOT_PACKED_OBJECT(Bytes)
      CASE_REPEATED_NOT_PACKED_OBJECT(String)
#undef CASE_REPEATED_NOT_PACKED_POD
#undef CASE_NOT_PACKED_OBJECT
    case _GPBDataTypeMessage: {
      _GPBMessage *message = [[field.msgClass alloc] init];
      [input readMessage:message extensionRegistry:extensionRegistry];
      [(NSMutableArray*)genericArray addObject:message];
      [message release];
      break;
    }
    case _GPBDataTypeGroup: {
      _GPBMessage *message = [[field.msgClass alloc] init];
      [input readGroup:_GPBFieldNumber(field)
                    message:message
          extensionRegistry:extensionRegistry];
      [(NSMutableArray*)genericArray addObject:message];
      [message release];
      break;
    }
    case _GPBDataTypeEnum: {
      int32_t val = _GPBCodedInputStreamReadEnum(state);
      if (_GPBHasPreservingUnknownEnumSemantics(syntax) ||
          [field isValidEnumValue:val]) {
        [(_GPBEnumArray*)genericArray addRawValue:val];
      } else {
        _GPBUnknownFieldSet *unknownFields = GetOrMakeUnknownFields(self);
        [unknownFields mergeVarintField:_GPBFieldNumber(field) value:val];
      }
      break;
    }
  }  // switch
}

- (void)mergeFromCodedInputStream:(_GPBCodedInputStream *)input
                extensionRegistry:(_GPBExtensionRegistry *)extensionRegistry {
  _GPBDescriptor *descriptor = [self descriptor];
  _GPBFileSyntax syntax = descriptor.file.syntax;
  _GPBCodedInputStreamState *state = &input->state_;
  uint32_t tag = 0;
  NSUInteger startingIndex = 0;
  NSArray *fields = descriptor->fields_;
  NSUInteger numFields = fields.count;
  while (YES) {
    BOOL merged = NO;
    tag = _GPBCodedInputStreamReadTag(state);
    if (tag == 0) {
      break;  // Reached end.
    }
    for (NSUInteger i = 0; i < numFields; ++i) {
      if (startingIndex >= numFields) startingIndex = 0;
      _GPBFieldDescriptor *fieldDescriptor = fields[startingIndex];
      if (_GPBFieldTag(fieldDescriptor) == tag) {
        _GPBFieldType fieldType = fieldDescriptor.fieldType;
        if (fieldType == _GPBFieldTypeSingle) {
          MergeSingleFieldFromCodedInputStream(self, fieldDescriptor, syntax,
                                               input, extensionRegistry);
          // Well formed protos will only have a single field once, advance
          // the starting index to the next field.
          startingIndex += 1;
        } else if (fieldType == _GPBFieldTypeRepeated) {
          if (fieldDescriptor.isPackable) {
            MergeRepeatedPackedFieldFromCodedInputStream(
                self, fieldDescriptor, syntax, input);
            // Well formed protos will only have a repeated field that is
            // packed once, advance the starting index to the next field.
            startingIndex += 1;
          } else {
            MergeRepeatedNotPackedFieldFromCodedInputStream(
                self, fieldDescriptor, syntax, input, extensionRegistry);
          }
        } else {  // fieldType == _GPBFieldTypeMap
          // _GPB*Dictionary or NSDictionary, exact type doesn't matter at this
          // point.
          id map = GetOrCreateMapIvarWithField(self, fieldDescriptor, syntax);
          [input readMapEntry:map
            extensionRegistry:extensionRegistry
                        field:fieldDescriptor
                parentMessage:self];
        }
        merged = YES;
        break;
      } else {
        startingIndex += 1;
      }
    }  // for(i < numFields)

    if (!merged && (tag != 0)) {
      // Primitive, repeated types can be packed on unpacked on the wire, and
      // are parsed either way.  The above loop covered tag in the preferred
      // for, so this need to check the alternate form.
      for (NSUInteger i = 0; i < numFields; ++i) {
        if (startingIndex >= numFields) startingIndex = 0;
        _GPBFieldDescriptor *fieldDescriptor = fields[startingIndex];
        if ((fieldDescriptor.fieldType == _GPBFieldTypeRepeated) &&
            !_GPBFieldDataTypeIsObject(fieldDescriptor) &&
            (_GPBFieldAlternateTag(fieldDescriptor) == tag)) {
          BOOL alternateIsPacked = !fieldDescriptor.isPackable;
          if (alternateIsPacked) {
            MergeRepeatedPackedFieldFromCodedInputStream(
                self, fieldDescriptor, syntax, input);
            // Well formed protos will only have a repeated field that is
            // packed once, advance the starting index to the next field.
            startingIndex += 1;
          } else {
            MergeRepeatedNotPackedFieldFromCodedInputStream(
                self, fieldDescriptor, syntax, input, extensionRegistry);
          }
          merged = YES;
          break;
        } else {
          startingIndex += 1;
        }
      }
    }

    if (!merged) {
      if (tag == 0) {
        // zero signals EOF / limit reached
        return;
      } else {
        if (![self parseUnknownField:input
                   extensionRegistry:extensionRegistry
                                 tag:tag]) {
          // it's an endgroup tag
          return;
        }
      }
    }  // if (!merged)

  }  // while(YES)
}

#pragma mark - MergeFrom Support

- (void)mergeFrom:(_GPBMessage *)other {
  Class selfClass = [self class];
  Class otherClass = [other class];
  if (!([selfClass isSubclassOfClass:otherClass] ||
        [otherClass isSubclassOfClass:selfClass])) {
    [NSException raise:NSInvalidArgumentException
                format:@"Classes must match %@ != %@", selfClass, otherClass];
  }

  // We assume something will be done and become visible.
  _GPBBecomeVisibleToAutocreator(self);

  _GPBDescriptor *descriptor = [[self class] descriptor];
  _GPBFileSyntax syntax = descriptor.file.syntax;

  for (_GPBFieldDescriptor *field in descriptor->fields_) {
    _GPBFieldType fieldType = field.fieldType;
    if (fieldType == _GPBFieldTypeSingle) {
      int32_t hasIndex = _GPBFieldHasIndex(field);
      uint32_t fieldNumber = _GPBFieldNumber(field);
      if (!_GPBGetHasIvar(other, hasIndex, fieldNumber)) {
        // Other doesn't have the field set, on to the next.
        continue;
      }
      _GPBDataType fieldDataType = _GPBGetFieldDataType(field);
      switch (fieldDataType) {
        case _GPBDataTypeBool:
          _GPBSetBoolIvarWithFieldInternal(
              self, field, _GPBGetMessageBoolField(other, field), syntax);
          break;
        case _GPBDataTypeSFixed32:
        case _GPBDataTypeEnum:
        case _GPBDataTypeInt32:
        case _GPBDataTypeSInt32:
          _GPBSetInt32IvarWithFieldInternal(
              self, field, _GPBGetMessageInt32Field(other, field), syntax);
          break;
        case _GPBDataTypeFixed32:
        case _GPBDataTypeUInt32:
          _GPBSetUInt32IvarWithFieldInternal(
              self, field, _GPBGetMessageUInt32Field(other, field), syntax);
          break;
        case _GPBDataTypeSFixed64:
        case _GPBDataTypeInt64:
        case _GPBDataTypeSInt64:
          _GPBSetInt64IvarWithFieldInternal(
              self, field, _GPBGetMessageInt64Field(other, field), syntax);
          break;
        case _GPBDataTypeFixed64:
        case _GPBDataTypeUInt64:
          _GPBSetUInt64IvarWithFieldInternal(
              self, field, _GPBGetMessageUInt64Field(other, field), syntax);
          break;
        case _GPBDataTypeFloat:
          _GPBSetFloatIvarWithFieldInternal(
              self, field, _GPBGetMessageFloatField(other, field), syntax);
          break;
        case _GPBDataTypeDouble:
          _GPBSetDoubleIvarWithFieldInternal(
              self, field, _GPBGetMessageDoubleField(other, field), syntax);
          break;
        case _GPBDataTypeBytes:
        case _GPBDataTypeString: {
          id otherVal = _GPBGetObjectIvarWithFieldNoAutocreate(other, field);
          _GPBSetObjectIvarWithFieldInternal(self, field, otherVal, syntax);
          break;
        }
        case _GPBDataTypeMessage:
        case _GPBDataTypeGroup: {
          id otherVal = _GPBGetObjectIvarWithFieldNoAutocreate(other, field);
          if (_GPBGetHasIvar(self, hasIndex, fieldNumber)) {
            _GPBMessage *message =
                _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
            [message mergeFrom:otherVal];
          } else {
            _GPBMessage *message = [otherVal copy];
            _GPBSetRetainedObjectIvarWithFieldInternal(self, field, message,
                                                      syntax);
          }
          break;
        }
      } // switch()
    } else if (fieldType == _GPBFieldTypeRepeated) {
      // In the case of a list, they need to be appended, and there is no
      // _hasIvar to worry about setting.
      id otherArray =
          _GPBGetObjectIvarWithFieldNoAutocreate(other, field);
      if (otherArray) {
        _GPBDataType fieldDataType = field->description_->dataType;
        if (_GPBDataTypeIsObject(fieldDataType)) {
          NSMutableArray *resultArray =
              GetOrCreateArrayIvarWithField(self, field, syntax);
          [resultArray addObjectsFromArray:otherArray];
        } else if (fieldDataType == _GPBDataTypeEnum) {
          _GPBEnumArray *resultArray =
              GetOrCreateArrayIvarWithField(self, field, syntax);
          [resultArray addRawValuesFromArray:otherArray];
        } else {
          // The array type doesn't matter, that all implment
          // -addValuesFromArray:.
          _GPBInt32Array *resultArray =
              GetOrCreateArrayIvarWithField(self, field, syntax);
          [resultArray addValuesFromArray:otherArray];
        }
      }
    } else {  // fieldType = _GPBFieldTypeMap
      // In the case of a map, they need to be merged, and there is no
      // _hasIvar to worry about setting.
      id otherDict = _GPBGetObjectIvarWithFieldNoAutocreate(other, field);
      if (otherDict) {
        _GPBDataType keyDataType = field.mapKeyDataType;
        _GPBDataType valueDataType = field->description_->dataType;
        if (_GPBDataTypeIsObject(keyDataType) &&
            _GPBDataTypeIsObject(valueDataType)) {
          NSMutableDictionary *resultDict =
              GetOrCreateMapIvarWithField(self, field, syntax);
          [resultDict addEntriesFromDictionary:otherDict];
        } else if (valueDataType == _GPBDataTypeEnum) {
          // The exact type doesn't matter, just need to know it is a
          // _GPB*EnumDictionary.
          _GPBInt32EnumDictionary *resultDict =
              GetOrCreateMapIvarWithField(self, field, syntax);
          [resultDict addRawEntriesFromDictionary:otherDict];
        } else {
          // The exact type doesn't matter, they all implement
          // -addEntriesFromDictionary:.
          _GPBInt32Int32Dictionary *resultDict =
              GetOrCreateMapIvarWithField(self, field, syntax);
          [resultDict addEntriesFromDictionary:otherDict];
        }
      }
    }  // if (fieldType)..else if...else
  }  // for(fields)

  // Unknown fields.
  if (!unknownFields_) {
    [self setUnknownFields:other.unknownFields];
  } else {
    [unknownFields_ mergeUnknownFields:other.unknownFields];
  }

  // Extensions

  if (other->extensionMap_.count == 0) {
    return;
  }

  if (extensionMap_ == nil) {
    extensionMap_ =
        CloneExtensionMap(other->extensionMap_, NSZoneFromPointer(self));
  } else {
    for (_GPBExtensionDescriptor *extension in other->extensionMap_) {
      id otherValue = [other->extensionMap_ objectForKey:extension];
      id value = [extensionMap_ objectForKey:extension];
      BOOL isMessageExtension = _GPBExtensionIsMessage(extension);

      if (extension.repeated) {
        NSMutableArray *list = value;
        if (list == nil) {
          list = [[NSMutableArray alloc] init];
          [extensionMap_ setObject:list forKey:extension];
          [list release];
        }
        if (isMessageExtension) {
          for (_GPBMessage *otherListValue in otherValue) {
            _GPBMessage *copiedValue = [otherListValue copy];
            [list addObject:copiedValue];
            [copiedValue release];
          }
        } else {
          [list addObjectsFromArray:otherValue];
        }
      } else {
        if (isMessageExtension) {
          if (value) {
            [(_GPBMessage *)value mergeFrom:(_GPBMessage *)otherValue];
          } else {
            _GPBMessage *copiedValue = [otherValue copy];
            [extensionMap_ setObject:copiedValue forKey:extension];
            [copiedValue release];
          }
        } else {
          [extensionMap_ setObject:otherValue forKey:extension];
        }
      }

      if (isMessageExtension && !extension.isRepeated) {
        _GPBMessage *autocreatedValue =
            [[autocreatedExtensionMap_ objectForKey:extension] retain];
        // Must remove from the map before calling _GPBClearMessageAutocreator()
        // so that _GPBClearMessageAutocreator() knows its safe to clear.
        [autocreatedExtensionMap_ removeObjectForKey:extension];
        _GPBClearMessageAutocreator(autocreatedValue);
        [autocreatedValue release];
      }
    }
  }
}

#pragma mark - isEqual: & hash Support

- (BOOL)isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[_GPBMessage class]]) {
    return NO;
  }
  _GPBMessage *otherMsg = other;
  _GPBDescriptor *descriptor = [[self class] descriptor];
  if ([[otherMsg class] descriptor] != descriptor) {
    return NO;
  }
  uint8_t *selfStorage = (uint8_t *)messageStorage_;
  uint8_t *otherStorage = (uint8_t *)otherMsg->messageStorage_;

  for (_GPBFieldDescriptor *field in descriptor->fields_) {
    if (_GPBFieldIsMapOrArray(field)) {
      // In the case of a list or map, there is no _hasIvar to worry about.
      // NOTE: These are NSArray/_GPB*Array or NSDictionary/_GPB*Dictionary, but
      // the type doesn't really matter as the objects all support -count and
      // -isEqual:.
      NSArray *resultMapOrArray =
          _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
      NSArray *otherMapOrArray =
          _GPBGetObjectIvarWithFieldNoAutocreate(other, field);
      // nil and empty are equal
      if (resultMapOrArray.count != 0 || otherMapOrArray.count != 0) {
        if (![resultMapOrArray isEqual:otherMapOrArray]) {
          return NO;
        }
      }
    } else {  // Single field
      int32_t hasIndex = _GPBFieldHasIndex(field);
      uint32_t fieldNum = _GPBFieldNumber(field);
      BOOL selfHas = _GPBGetHasIvar(self, hasIndex, fieldNum);
      BOOL otherHas = _GPBGetHasIvar(other, hasIndex, fieldNum);
      if (selfHas != otherHas) {
        return NO;  // Differing has values, not equal.
      }
      if (!selfHas) {
        // Same has values, was no, nothing else to check for this field.
        continue;
      }
      // Now compare the values.
      _GPBDataType fieldDataType = _GPBGetFieldDataType(field);
      size_t fieldOffset = field->description_->offset;
      switch (fieldDataType) {
        case _GPBDataTypeBool: {
          // Bools are stored in has_bits to avoid needing explicit space in
          // the storage structure.
          // (the field number passed to the HasIvar helper doesn't really
          // matter since the offset is never negative)
          BOOL selfValue = _GPBGetHasIvar(self, (int32_t)(fieldOffset), 0);
          BOOL otherValue = _GPBGetHasIvar(other, (int32_t)(fieldOffset), 0);
          if (selfValue != otherValue) {
            return NO;
          }
          break;
        }
        case _GPBDataTypeSFixed32:
        case _GPBDataTypeInt32:
        case _GPBDataTypeSInt32:
        case _GPBDataTypeEnum:
        case _GPBDataTypeFixed32:
        case _GPBDataTypeUInt32:
        case _GPBDataTypeFloat: {
          _GPBInternalCompileAssert(sizeof(float) == sizeof(uint32_t), float_not_32_bits);
          // These are all 32bit, signed/unsigned doesn't matter for equality.
          uint32_t *selfValPtr = (uint32_t *)&selfStorage[fieldOffset];
          uint32_t *otherValPtr = (uint32_t *)&otherStorage[fieldOffset];
          if (*selfValPtr != *otherValPtr) {
            return NO;
          }
          break;
        }
        case _GPBDataTypeSFixed64:
        case _GPBDataTypeInt64:
        case _GPBDataTypeSInt64:
        case _GPBDataTypeFixed64:
        case _GPBDataTypeUInt64:
        case _GPBDataTypeDouble: {
          _GPBInternalCompileAssert(sizeof(double) == sizeof(uint64_t), double_not_64_bits);
          // These are all 64bit, signed/unsigned doesn't matter for equality.
          uint64_t *selfValPtr = (uint64_t *)&selfStorage[fieldOffset];
          uint64_t *otherValPtr = (uint64_t *)&otherStorage[fieldOffset];
          if (*selfValPtr != *otherValPtr) {
            return NO;
          }
          break;
        }
        case _GPBDataTypeBytes:
        case _GPBDataTypeString:
        case _GPBDataTypeMessage:
        case _GPBDataTypeGroup: {
          // Type doesn't matter here, they all implement -isEqual:.
          id *selfValPtr = (id *)&selfStorage[fieldOffset];
          id *otherValPtr = (id *)&otherStorage[fieldOffset];
          if (![*selfValPtr isEqual:*otherValPtr]) {
            return NO;
          }
          break;
        }
      } // switch()
    }   // if (mapOrArray)...else
  }  // for(fields)

  // nil and empty are equal
  if (extensionMap_.count != 0 || otherMsg->extensionMap_.count != 0) {
    if (![extensionMap_ isEqual:otherMsg->extensionMap_]) {
      return NO;
    }
  }

  // nil and empty are equal
  _GPBUnknownFieldSet *otherUnknowns = otherMsg->unknownFields_;
  if ([unknownFields_ countOfFields] != 0 ||
      [otherUnknowns countOfFields] != 0) {
    if (![unknownFields_ isEqual:otherUnknowns]) {
      return NO;
    }
  }

  return YES;
}

// It is very difficult to implement a generic hash for ProtoBuf messages that
// will perform well. If you need hashing on your ProtoBufs (eg you are using
// them as dictionary keys) you will probably want to implement a ProtoBuf
// message specific hash as a category on your protobuf class. Do not make it a
// category on _GPBMessage as you will conflict with this hash, and will possibly
// override hash for all generated protobufs. A good implementation of hash will
// be really fast, so we would recommend only hashing protobufs that have an
// identifier field of some kind that you can easily hash. If you implement
// hash, we would strongly recommend overriding isEqual: in your category as
// well, as the default implementation of isEqual: is extremely slow, and may
// drastically affect performance in large sets.
- (NSUInteger)hash {
  _GPBDescriptor *descriptor = [[self class] descriptor];
  const NSUInteger prime = 19;
  uint8_t *storage = (uint8_t *)messageStorage_;

  // Start with the descriptor and then mix it with some instance info.
  // Hopefully that will give a spread based on classes and what fields are set.
  NSUInteger result = (NSUInteger)descriptor;

  for (_GPBFieldDescriptor *field in descriptor->fields_) {
    if (_GPBFieldIsMapOrArray(field)) {
      // Exact type doesn't matter, just check if there are any elements.
      NSArray *mapOrArray = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
      NSUInteger count = mapOrArray.count;
      if (count) {
        // NSArray/NSDictionary use count, use the field number and the count.
        result = prime * result + _GPBFieldNumber(field);
        result = prime * result + count;
      }
    } else if (_GPBGetHasIvarField(self, field)) {
      // Just using the field number seemed simple/fast, but then a small
      // message class where all the same fields are always set (to different
      // things would end up all with the same hash, so pull in some data).
      _GPBDataType fieldDataType = _GPBGetFieldDataType(field);
      size_t fieldOffset = field->description_->offset;
      switch (fieldDataType) {
        case _GPBDataTypeBool: {
          // Bools are stored in has_bits to avoid needing explicit space in
          // the storage structure.
          // (the field number passed to the HasIvar helper doesn't really
          // matter since the offset is never negative)
          BOOL value = _GPBGetHasIvar(self, (int32_t)(fieldOffset), 0);
          result = prime * result + value;
          break;
        }
        case _GPBDataTypeSFixed32:
        case _GPBDataTypeInt32:
        case _GPBDataTypeSInt32:
        case _GPBDataTypeEnum:
        case _GPBDataTypeFixed32:
        case _GPBDataTypeUInt32:
        case _GPBDataTypeFloat: {
          _GPBInternalCompileAssert(sizeof(float) == sizeof(uint32_t), float_not_32_bits);
          // These are all 32bit, just mix it in.
          uint32_t *valPtr = (uint32_t *)&storage[fieldOffset];
          result = prime * result + *valPtr;
          break;
        }
        case _GPBDataTypeSFixed64:
        case _GPBDataTypeInt64:
        case _GPBDataTypeSInt64:
        case _GPBDataTypeFixed64:
        case _GPBDataTypeUInt64:
        case _GPBDataTypeDouble: {
          _GPBInternalCompileAssert(sizeof(double) == sizeof(uint64_t), double_not_64_bits);
          // These are all 64bit, just mix what fits into an NSUInteger in.
          uint64_t *valPtr = (uint64_t *)&storage[fieldOffset];
          result = prime * result + (NSUInteger)(*valPtr);
          break;
        }
        case _GPBDataTypeBytes:
        case _GPBDataTypeString: {
          // Type doesn't matter here, they both implement -hash:.
          id *valPtr = (id *)&storage[fieldOffset];
          result = prime * result + [*valPtr hash];
          break;
        }

        case _GPBDataTypeMessage:
        case _GPBDataTypeGroup: {
          _GPBMessage **valPtr = (_GPBMessage **)&storage[fieldOffset];
          // Could call -hash on the sub message, but that could recurse pretty
          // deep; follow the lead of NSArray/NSDictionary and don't really
          // recurse for hash, instead use the field number and the descriptor
          // of the sub message.  Yes, this could suck for a bunch of messages
          // where they all only differ in the sub messages, but if you are
          // using a message with sub messages for something that needs -hash,
          // odds are you are also copying them as keys, and that deep copy
          // will also suck.
          result = prime * result + _GPBFieldNumber(field);
          result = prime * result + (NSUInteger)[[*valPtr class] descriptor];
          break;
        }
      } // switch()
    }
  }

  // Unknowns and extensions are not included.

  return result;
}

#pragma mark - Description Support

- (NSString *)description {
  NSString *textFormat = _GPBTextFormatForMessage(self, @"    ");
  NSString *description = [NSString
      stringWithFormat:@"<%@ %p>: {\n%@}", [self class], self, textFormat];
  return description;
}

#if defined(DEBUG) && DEBUG

// Xcode 5.1 added support for custom quick look info.
// https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/CustomClassDisplay_in_QuickLook/CH01-quick_look_for_custom_objects/CH01-quick_look_for_custom_objects.html#//apple_ref/doc/uid/TP40014001-CH2-SW1
- (id)debugQuickLookObject {
  return _GPBTextFormatForMessage(self, nil);
}

#endif  // DEBUG

#pragma mark - SerializedSize

- (size_t)serializedSize {
  _GPBDescriptor *descriptor = [[self class] descriptor];
  size_t result = 0;

  // Has check is done explicitly, so _GPBGetObjectIvarWithFieldNoAutocreate()
  // avoids doing the has check again.

  // Fields.
  for (_GPBFieldDescriptor *fieldDescriptor in descriptor->fields_) {
    _GPBFieldType fieldType = fieldDescriptor.fieldType;
    _GPBDataType fieldDataType = _GPBGetFieldDataType(fieldDescriptor);

    // Single Fields
    if (fieldType == _GPBFieldTypeSingle) {
      BOOL selfHas = _GPBGetHasIvarField(self, fieldDescriptor);
      if (!selfHas) {
        continue;  // Nothing to do.
      }

      uint32_t fieldNumber = _GPBFieldNumber(fieldDescriptor);

      switch (fieldDataType) {
#define CASE_SINGLE_POD(NAME, TYPE, FUNC_TYPE)                                \
        case _GPBDataType##NAME: {                                             \
          TYPE fieldVal = _GPBGetMessage##FUNC_TYPE##Field(self, fieldDescriptor); \
          result += _GPBCompute##NAME##Size(fieldNumber, fieldVal);            \
          break;                                                              \
        }
#define CASE_SINGLE_OBJECT(NAME)                                              \
        case _GPBDataType##NAME: {                                             \
          id fieldVal = _GPBGetObjectIvarWithFieldNoAutocreate(self, fieldDescriptor); \
          result += _GPBCompute##NAME##Size(fieldNumber, fieldVal);            \
          break;                                                              \
        }
          CASE_SINGLE_POD(Bool, BOOL, Bool)
          CASE_SINGLE_POD(Fixed32, uint32_t, UInt32)
          CASE_SINGLE_POD(SFixed32, int32_t, Int32)
          CASE_SINGLE_POD(Float, float, Float)
          CASE_SINGLE_POD(Fixed64, uint64_t, UInt64)
          CASE_SINGLE_POD(SFixed64, int64_t, Int64)
          CASE_SINGLE_POD(Double, double, Double)
          CASE_SINGLE_POD(Int32, int32_t, Int32)
          CASE_SINGLE_POD(Int64, int64_t, Int64)
          CASE_SINGLE_POD(SInt32, int32_t, Int32)
          CASE_SINGLE_POD(SInt64, int64_t, Int64)
          CASE_SINGLE_POD(UInt32, uint32_t, UInt32)
          CASE_SINGLE_POD(UInt64, uint64_t, UInt64)
          CASE_SINGLE_OBJECT(Bytes)
          CASE_SINGLE_OBJECT(String)
          CASE_SINGLE_OBJECT(Message)
          CASE_SINGLE_OBJECT(Group)
          CASE_SINGLE_POD(Enum, int32_t, Int32)
#undef CASE_SINGLE_POD
#undef CASE_SINGLE_OBJECT
      }

    // Repeated Fields
    } else if (fieldType == _GPBFieldTypeRepeated) {
      id genericArray =
          _GPBGetObjectIvarWithFieldNoAutocreate(self, fieldDescriptor);
      NSUInteger count = [genericArray count];
      if (count == 0) {
        continue;  // Nothing to add.
      }
      __block size_t dataSize = 0;

      switch (fieldDataType) {
#define CASE_REPEATED_POD(NAME, TYPE, ARRAY_TYPE)                             \
    CASE_REPEATED_POD_EXTRA(NAME, TYPE, ARRAY_TYPE, )
#define CASE_REPEATED_POD_EXTRA(NAME, TYPE, ARRAY_TYPE, ARRAY_ACCESSOR_NAME)  \
        case _GPBDataType##NAME: {                                             \
          _GPB##ARRAY_TYPE##Array *array = genericArray;                       \
          [array enumerate##ARRAY_ACCESSOR_NAME##ValuesWithBlock:^(TYPE value, NSUInteger idx, BOOL *stop) { \
            _Pragma("unused(idx, stop)");                                     \
            dataSize += _GPBCompute##NAME##SizeNoTag(value);                   \
          }];                                                                 \
          break;                                                              \
        }
#define CASE_REPEATED_OBJECT(NAME)                                            \
        case _GPBDataType##NAME: {                                             \
          for (id value in genericArray) {                                    \
            dataSize += _GPBCompute##NAME##SizeNoTag(value);                   \
          }                                                                   \
          break;                                                              \
        }
          CASE_REPEATED_POD(Bool, BOOL, Bool)
          CASE_REPEATED_POD(Fixed32, uint32_t, UInt32)
          CASE_REPEATED_POD(SFixed32, int32_t, Int32)
          CASE_REPEATED_POD(Float, float, Float)
          CASE_REPEATED_POD(Fixed64, uint64_t, UInt64)
          CASE_REPEATED_POD(SFixed64, int64_t, Int64)
          CASE_REPEATED_POD(Double, double, Double)
          CASE_REPEATED_POD(Int32, int32_t, Int32)
          CASE_REPEATED_POD(Int64, int64_t, Int64)
          CASE_REPEATED_POD(SInt32, int32_t, Int32)
          CASE_REPEATED_POD(SInt64, int64_t, Int64)
          CASE_REPEATED_POD(UInt32, uint32_t, UInt32)
          CASE_REPEATED_POD(UInt64, uint64_t, UInt64)
          CASE_REPEATED_OBJECT(Bytes)
          CASE_REPEATED_OBJECT(String)
          CASE_REPEATED_OBJECT(Message)
          CASE_REPEATED_OBJECT(Group)
          CASE_REPEATED_POD_EXTRA(Enum, int32_t, Enum, Raw)
#undef CASE_REPEATED_POD
#undef CASE_REPEATED_POD_EXTRA
#undef CASE_REPEATED_OBJECT
      }  // switch
      result += dataSize;
      size_t tagSize = _GPBComputeTagSize(_GPBFieldNumber(fieldDescriptor));
      if (fieldDataType == _GPBDataTypeGroup) {
        // Groups have both a start and an end tag.
        tagSize *= 2;
      }
      if (fieldDescriptor.isPackable) {
        result += tagSize;
        result += _GPBComputeSizeTSizeAsInt32NoTag(dataSize);
      } else {
        result += count * tagSize;
      }

    // Map<> Fields
    } else {  // fieldType == _GPBFieldTypeMap
      if (_GPBDataTypeIsObject(fieldDataType) &&
          (fieldDescriptor.mapKeyDataType == _GPBDataTypeString)) {
        // If key type was string, then the map is an NSDictionary.
        NSDictionary *map =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, fieldDescriptor);
        if (map) {
          result += _GPBDictionaryComputeSizeInternalHelper(map, fieldDescriptor);
        }
      } else {
        // Type will be _GPB*GroupDictionary, exact type doesn't matter.
        _GPBInt32Int32Dictionary *map =
            _GPBGetObjectIvarWithFieldNoAutocreate(self, fieldDescriptor);
        result += [map computeSerializedSizeAsField:fieldDescriptor];
      }
    }
  }  // for(fields)

  // Add any unknown fields.
  if (descriptor.wireFormat) {
    result += [unknownFields_ serializedSizeAsMessageSet];
  } else {
    result += [unknownFields_ serializedSize];
  }

  // Add any extensions.
  for (_GPBExtensionDescriptor *extension in extensionMap_) {
    id value = [extensionMap_ objectForKey:extension];
    result += _GPBComputeExtensionSerializedSizeIncludingTag(extension, value);
  }

  return result;
}

#pragma mark - Resolve Methods Support

typedef struct ResolveIvarAccessorMethodResult {
  IMP impToAdd;
  SEL encodingSelector;
} ResolveIvarAccessorMethodResult;

// |field| can be __unsafe_unretained because they are created at startup
// and are essentially global. No need to pay for retain/release when
// they are captured in blocks.
static void ResolveIvarGet(__unsafe_unretained _GPBFieldDescriptor *field,
                           ResolveIvarAccessorMethodResult *result) {
  _GPBDataType fieldDataType = _GPBGetFieldDataType(field);
  switch (fieldDataType) {
#define CASE_GET(NAME, TYPE, TRUE_NAME)                          \
    case _GPBDataType##NAME: {                                    \
      result->impToAdd = imp_implementationWithBlock(^(id obj) { \
        return _GPBGetMessage##TRUE_NAME##Field(obj, field);      \
       });                                                       \
      result->encodingSelector = @selector(get##NAME);           \
      break;                                                     \
    }
#define CASE_GET_OBJECT(NAME, TYPE, TRUE_NAME)                   \
    case _GPBDataType##NAME: {                                    \
      result->impToAdd = imp_implementationWithBlock(^(id obj) { \
        return _GPBGetObjectIvarWithField(obj, field);            \
       });                                                       \
      result->encodingSelector = @selector(get##NAME);           \
      break;                                                     \
    }
      CASE_GET(Bool, BOOL, Bool)
      CASE_GET(Fixed32, uint32_t, UInt32)
      CASE_GET(SFixed32, int32_t, Int32)
      CASE_GET(Float, float, Float)
      CASE_GET(Fixed64, uint64_t, UInt64)
      CASE_GET(SFixed64, int64_t, Int64)
      CASE_GET(Double, double, Double)
      CASE_GET(Int32, int32_t, Int32)
      CASE_GET(Int64, int64_t, Int64)
      CASE_GET(SInt32, int32_t, Int32)
      CASE_GET(SInt64, int64_t, Int64)
      CASE_GET(UInt32, uint32_t, UInt32)
      CASE_GET(UInt64, uint64_t, UInt64)
      CASE_GET_OBJECT(Bytes, id, Object)
      CASE_GET_OBJECT(String, id, Object)
      CASE_GET_OBJECT(Message, id, Object)
      CASE_GET_OBJECT(Group, id, Object)
      CASE_GET(Enum, int32_t, Enum)
#undef CASE_GET
  }
}

// See comment about __unsafe_unretained on ResolveIvarGet.
static void ResolveIvarSet(__unsafe_unretained _GPBFieldDescriptor *field,
                           _GPBFileSyntax syntax,
                           ResolveIvarAccessorMethodResult *result) {
  _GPBDataType fieldDataType = _GPBGetFieldDataType(field);
  switch (fieldDataType) {
#define CASE_SET(NAME, TYPE, TRUE_NAME)                                       \
    case _GPBDataType##NAME: {                                                 \
      result->impToAdd = imp_implementationWithBlock(^(id obj, TYPE value) {  \
        return _GPBSet##TRUE_NAME##IvarWithFieldInternal(obj, field, value, syntax); \
      });                                                                     \
      result->encodingSelector = @selector(set##NAME:);                       \
      break;                                                                  \
    }
#define CASE_SET_COPY(NAME)                                                   \
    case _GPBDataType##NAME: {                                                 \
      result->impToAdd = imp_implementationWithBlock(^(id obj, id value) {    \
        return _GPBSetRetainedObjectIvarWithFieldInternal(obj, field, [value copy], syntax); \
      });                                                                     \
      result->encodingSelector = @selector(set##NAME:);                       \
      break;                                                                  \
    }
      CASE_SET(Bool, BOOL, Bool)
      CASE_SET(Fixed32, uint32_t, UInt32)
      CASE_SET(SFixed32, int32_t, Int32)
      CASE_SET(Float, float, Float)
      CASE_SET(Fixed64, uint64_t, UInt64)
      CASE_SET(SFixed64, int64_t, Int64)
      CASE_SET(Double, double, Double)
      CASE_SET(Int32, int32_t, Int32)
      CASE_SET(Int64, int64_t, Int64)
      CASE_SET(SInt32, int32_t, Int32)
      CASE_SET(SInt64, int64_t, Int64)
      CASE_SET(UInt32, uint32_t, UInt32)
      CASE_SET(UInt64, uint64_t, UInt64)
      CASE_SET_COPY(Bytes)
      CASE_SET_COPY(String)
      CASE_SET(Message, id, Object)
      CASE_SET(Group, id, Object)
      CASE_SET(Enum, int32_t, Enum)
#undef CASE_SET
  }
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
  const _GPBDescriptor *descriptor = [self descriptor];
  if (!descriptor) {
    return [super resolveInstanceMethod:sel];
  }

  // NOTE: hasOrCountSel_/setHasSel_ will be NULL if the field for the given
  // message should not have has support (done in _GPBDescriptor.m), so there is
  // no need for checks here to see if has*/setHas* are allowed.
  ResolveIvarAccessorMethodResult result = {NULL, NULL};

  // See comment about __unsafe_unretained on ResolveIvarGet.
  for (__unsafe_unretained _GPBFieldDescriptor *field in descriptor->fields_) {
    BOOL isMapOrArray = _GPBFieldIsMapOrArray(field);
    if (!isMapOrArray) {
      // Single fields.
      if (sel == field->getSel_) {
        ResolveIvarGet(field, &result);
        break;
      } else if (sel == field->setSel_) {
        ResolveIvarSet(field, descriptor.file.syntax, &result);
        break;
      } else if (sel == field->hasOrCountSel_) {
        int32_t index = _GPBFieldHasIndex(field);
        uint32_t fieldNum = _GPBFieldNumber(field);
        result.impToAdd = imp_implementationWithBlock(^(id obj) {
          return _GPBGetHasIvar(obj, index, fieldNum);
        });
        result.encodingSelector = @selector(getBool);
        break;
      } else if (sel == field->setHasSel_) {
        result.impToAdd = imp_implementationWithBlock(^(id obj, BOOL value) {
          if (value) {
            [NSException raise:NSInvalidArgumentException
                        format:@"%@: %@ can only be set to NO (to clear field).",
                               [obj class],
                               NSStringFromSelector(field->setHasSel_)];
          }
          _GPBClearMessageField(obj, field);
        });
        result.encodingSelector = @selector(setBool:);
        break;
      } else {
        _GPBOneofDescriptor *oneof = field->containingOneof_;
        if (oneof && (sel == oneof->caseSel_)) {
          int32_t index = _GPBFieldHasIndex(field);
          result.impToAdd = imp_implementationWithBlock(^(id obj) {
            return _GPBGetHasOneof(obj, index);
          });
          result.encodingSelector = @selector(getEnum);
          break;
        }
      }
    } else {
      // map<>/repeated fields.
      if (sel == field->getSel_) {
        if (field.fieldType == _GPBFieldTypeRepeated) {
          result.impToAdd = imp_implementationWithBlock(^(id obj) {
            return GetArrayIvarWithField(obj, field);
          });
        } else {
          result.impToAdd = imp_implementationWithBlock(^(id obj) {
            return GetMapIvarWithField(obj, field);
          });
        }
        result.encodingSelector = @selector(getArray);
        break;
      } else if (sel == field->setSel_) {
        // Local for syntax so the block can directly capture it and not the
        // full lookup.
        const _GPBFileSyntax syntax = descriptor.file.syntax;
        result.impToAdd = imp_implementationWithBlock(^(id obj, id value) {
          _GPBSetObjectIvarWithFieldInternal(obj, field, value, syntax);
        });
        result.encodingSelector = @selector(setArray:);
        break;
      } else if (sel == field->hasOrCountSel_) {
        result.impToAdd = imp_implementationWithBlock(^(id obj) {
          // Type doesn't matter, all *Array and *Dictionary types support
          // -count.
          NSArray *arrayOrMap =
              _GPBGetObjectIvarWithFieldNoAutocreate(obj, field);
          return [arrayOrMap count];
        });
        result.encodingSelector = @selector(getArrayCount);
        break;
      }
    }
  }
  if (result.impToAdd) {
    const char *encoding =
        _GPBMessageEncodingForSelector(result.encodingSelector, YES);
    Class msgClass = descriptor.messageClass;
    BOOL methodAdded = class_addMethod(msgClass, sel, result.impToAdd, encoding);
    // class_addMethod() is documented as also failing if the method was already
    // added; so we check if the method is already there and return success so
    // the method dispatch will still happen.  Why would it already be added?
    // Two threads could cause the same method to be bound at the same time,
    // but only one will actually bind it; the other still needs to return true
    // so things will dispatch.
    if (!methodAdded) {
      methodAdded = _GPBClassHasSel(msgClass, sel);
    }
    return methodAdded;
  }
  return [super resolveInstanceMethod:sel];
}

+ (BOOL)resolveClassMethod:(SEL)sel {
  // Extensions scoped to a Message and looked up via class methods.
  if (_GPBResolveExtensionClassMethod([self descriptor].messageClass, sel)) {
    return YES;
  }
  return [super resolveClassMethod:sel];
}

#pragma mark - NSCoding Support

+ (BOOL)supportsSecureCoding {
  return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [self init];
  if (self) {
    NSData *data =
        [aDecoder decodeObjectOfClass:[NSData class] forKey:k_GPBDataCoderKey];
    if (data.length) {
      [self mergeFromData:data extensionRegistry:nil];
    }
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
#if defined(DEBUG) && DEBUG
  if (extensionMap_.count) {
    // Hint to go along with the docs on _GPBMessage about this.
    //
    // Note: This is incomplete, in that it only checked the "root" message,
    // if a sub message in a field has extensions, the issue still exists. A
    // recursive check could be done here (like the work in
    // _GPBMessageDropUnknownFieldsRecursively()), but that has the potential to
    // be expensive and could slow down serialization in DEBUG enought to cause
    // developers other problems.
    NSLog(@"Warning: writing out a _GPBMessage (%@) via NSCoding and it"
          @" has %ld extensions; when read back in, those fields will be"
          @" in the unknownFields property instead.",
          [self class], (long)extensionMap_.count);
  }
#endif
  NSData *data = [self data];
  if (data.length) {
    [aCoder encodeObject:data forKey:k_GPBDataCoderKey];
  }
}

#pragma mark - KVC Support

+ (BOOL)accessInstanceVariablesDirectly {
  // Make sure KVC doesn't use instance variables.
  return NO;
}

@end

#pragma mark - Messages from _GPBUtilities.h but defined here for access to helpers.

// Only exists for public api, no core code should use this.
id _GPBGetMessageRepeatedField(_GPBMessage *self, _GPBFieldDescriptor *field) {
#if defined(DEBUG) && DEBUG
  if (field.fieldType != _GPBFieldTypeRepeated) {
    [NSException raise:NSInvalidArgumentException
                format:@"%@.%@ is not a repeated field.",
     [self class], field.name];
  }
#endif
  _GPBDescriptor *descriptor = [[self class] descriptor];
  _GPBFileSyntax syntax = descriptor.file.syntax;
  return GetOrCreateArrayIvarWithField(self, field, syntax);
}

// Only exists for public api, no core code should use this.
id _GPBGetMessageMapField(_GPBMessage *self, _GPBFieldDescriptor *field) {
#if defined(DEBUG) && DEBUG
  if (field.fieldType != _GPBFieldTypeMap) {
    [NSException raise:NSInvalidArgumentException
                format:@"%@.%@ is not a map<> field.",
     [self class], field.name];
  }
#endif
  _GPBDescriptor *descriptor = [[self class] descriptor];
  _GPBFileSyntax syntax = descriptor.file.syntax;
  return GetOrCreateMapIvarWithField(self, field, syntax);
}

id _GPBGetObjectIvarWithField(_GPBMessage *self, _GPBFieldDescriptor *field) {
  NSCAssert(!_GPBFieldIsMapOrArray(field), @"Shouldn't get here");
  if (_GPBGetHasIvarField(self, field)) {
    uint8_t *storage = (uint8_t *)self->messageStorage_;
    id *typePtr = (id *)&storage[field->description_->offset];
    return *typePtr;
  }
  // Not set...

  // Non messages (string/data), get their default.
  if (!_GPBFieldDataTypeIsMessage(field)) {
    return field.defaultValue.valueMessage;
  }

  _GPBPrepareReadOnlySemaphore(self);
  dispatch_semaphore_wait(self->readOnlySemaphore_, DISPATCH_TIME_FOREVER);
  _GPBMessage *result = _GPBGetObjectIvarWithFieldNoAutocreate(self, field);
  if (!result) {
    // For non repeated messages, create the object, set it and return it.
    // This object will not initially be visible via _GPBGetHasIvar, so
    // we save its creator so it can become visible if it's mutated later.
    result = _GPBCreateMessageWithAutocreator(field.msgClass, self, field);
    _GPBSetAutocreatedRetainedObjectIvarWithField(self, field, result);
  }
  dispatch_semaphore_signal(self->readOnlySemaphore_);
  return result;
}

#pragma clang diagnostic pop
