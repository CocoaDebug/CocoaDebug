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

#import "_GPBMessage.h"

// TODO: Remove this import. Older generated code use the OSAtomic* apis,
// so anyone that hasn't regenerated says building by having this. After
// enough time has passed, this likely can be removed as folks should have
// regenerated.
#import <libkern/OSAtomic.h>

#import "_GPBBootstrap.h"

typedef struct _GPBMessage_Storage {
  uint32_t _has_storage_[0];
} _GPBMessage_Storage;

typedef struct _GPBMessage_Storage *_GPBMessage_StoragePtr;

@interface _GPBMessage () {
 @package
  // NOTE: Because of the +allocWithZone code using NSAllocateObject(),
  // this structure should ideally always be kept pointer aligned where the
  // real storage starts is also pointer aligned. The compiler/runtime already
  // do this, but it may not be documented.

  // A pointer to the actual fields of the subclasses. The actual structure
  // pointed to by this pointer will depend on the subclass.
  // All of the actual structures will start the same as
  // _GPBMessage_Storage with _has_storage__ as the first field.
  // Kept public because static functions need to access it.
  _GPBMessage_StoragePtr messageStorage_;
}

// Gets an extension value without autocreating the result if not found. (i.e.
// returns nil if the extension is not set)
- (id)getExistingExtension:(_GPBExtensionDescriptor *)extension;

// Parses a message of this type from the input and merges it with this
// message.
//
// Warning:  This does not verify that all required fields are present in
// the input message.
// Note:  The caller should call
// -[CodedInputStream checkLastTagWas:] after calling this to
// verify that the last tag seen was the appropriate end-group tag,
// or zero for EOF.
// NOTE: This will throw if there is an error while parsing.
- (void)mergeFromCodedInputStream:(_GPBCodedInputStream *)input
                extensionRegistry:(_GPBExtensionRegistry *)extensionRegistry;

// Parses the next delimited message of this type from the input and merges it
// with this message.
- (void)mergeDelimitedFromCodedInputStream:(_GPBCodedInputStream *)input
                         extensionRegistry:
                             (_GPBExtensionRegistry *)extensionRegistry;

- (void)addUnknownMapEntry:(int32_t)fieldNum value:(NSData *)data;

@end

CF_EXTERN_C_BEGIN


// Call this before using the readOnlySemaphore_. This ensures it is created only once.
void _GPBPrepareReadOnlySemaphore(_GPBMessage *self);

// Returns a new instance that was automatically created by |autocreator| for
// its field |field|.
_GPBMessage *_GPBCreateMessageWithAutocreator(Class msgClass,
                                            _GPBMessage *autocreator,
                                            _GPBFieldDescriptor *field)
    __attribute__((ns_returns_retained));

// Returns whether |message| autocreated this message. This is NO if the message
// was not autocreated by |message| or if it has been mutated since
// autocreation.
BOOL _GPBWasMessageAutocreatedBy(_GPBMessage *message, _GPBMessage *parent);

// Call this when you mutate a message. It will cause the message to become
// visible to its autocreator.
void _GPBBecomeVisibleToAutocreator(_GPBMessage *self);

// Call this when an array/dictionary is mutated so the parent message that
// autocreated it can react.
void _GPBAutocreatedArrayModified(_GPBMessage *self, id array);
void _GPBAutocreatedDictionaryModified(_GPBMessage *self, id dictionary);

// Clear the autocreator, if any. Asserts if the autocreator still has an
// autocreated reference to this message.
void _GPBClearMessageAutocreator(_GPBMessage *self);

CF_EXTERN_C_END
