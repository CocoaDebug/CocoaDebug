//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "_GPBArray.h"
#import "_GPBMessage.h"
#import "_GPBRuntimeTypes.h"

CF_EXTERN_C_BEGIN

NS_ASSUME_NONNULL_BEGIN

/**
 * Generates a string that should be a valid "TextFormat" for the C++ version
 * of Protocol Buffers.
 *
 * @param message    The message to generate from.
 * @param lineIndent A string to use as the prefix for all lines generated. Can
 *                   be nil if no extra indent is needed.
 *
 * @return An NSString with the TextFormat of the message.
 **/
NSString *_GPBTextFormatForMessage(_GPBMessage *message,
                                  NSString * __nullable lineIndent);

/**
 * Generates a string that should be a valid "TextFormat" for the C++ version
 * of Protocol Buffers.
 *
 * @param unknownSet The unknown field set to generate from.
 * @param lineIndent A string to use as the prefix for all lines generated. Can
 *                   be nil if no extra indent is needed.
 *
 * @return An NSString with the TextFormat of the unknown field set.
 **/
NSString *_GPBTextFormatForUnknownFieldSet(_GPBUnknownFieldSet * __nullable unknownSet,
                                          NSString * __nullable lineIndent);

/**
 * Checks if the given field number is set on a message.
 *
 * @param self        The message to check.
 * @param fieldNumber The field number to check.
 *
 * @return YES if the field number is set on the given message.
 **/
BOOL _GPBMessageHasFieldNumberSet(_GPBMessage *self, uint32_t fieldNumber);

/**
 * Checks if the given field is set on a message.
 *
 * @param self  The message to check.
 * @param field The field to check.
 *
 * @return YES if the field is set on the given message.
 **/
BOOL _GPBMessageHasFieldSet(_GPBMessage *self, _GPBFieldDescriptor *field);

/**
 * Clears the given field for the given message.
 *
 * @param self  The message for which to clear the field.
 * @param field The field to clear.
 **/
void _GPBClearMessageField(_GPBMessage *self, _GPBFieldDescriptor *field);

//%PDDM-EXPAND _GPB_ACCESSORS()
// This block of code is generated, do not edit it directly.


//
// Get/Set a given field from/to a message.
//

// Single Fields

/**
 * Gets the value of a bytes field.
 *
 * @param self  The message from which to get the field.
 * @param field The field to get.
 **/
NSData *_GPBGetMessageBytesField(_GPBMessage *self, _GPBFieldDescriptor *field);

/**
 * Sets the value of a bytes field.
 *
 * @param self  The message into which to set the field.
 * @param field The field to set.
 * @param value The to set in the field.
 **/
void _GPBSetMessageBytesField(_GPBMessage *self, _GPBFieldDescriptor *field, NSData *value);

/**
 * Gets the value of a string field.
 *
 * @param self  The message from which to get the field.
 * @param field The field to get.
 **/
NSString *_GPBGetMessageStringField(_GPBMessage *self, _GPBFieldDescriptor *field);

/**
 * Sets the value of a string field.
 *
 * @param self  The message into which to set the field.
 * @param field The field to set.
 * @param value The to set in the field.
 **/
void _GPBSetMessageStringField(_GPBMessage *self, _GPBFieldDescriptor *field, NSString *value);

/**
 * Gets the value of a message field.
 *
 * @param self  The message from which to get the field.
 * @param field The field to get.
 **/
_GPBMessage *_GPBGetMessageMessageField(_GPBMessage *self, _GPBFieldDescriptor *field);

/**
 * Sets the value of a message field.
 *
 * @param self  The message into which to set the field.
 * @param field The field to set.
 * @param value The to set in the field.
 **/
void _GPBSetMessageMessageField(_GPBMessage *self, _GPBFieldDescriptor *field, _GPBMessage *value);

/**
 * Gets the value of a group field.
 *
 * @param self  The message from which to get the field.
 * @param field The field to get.
 **/
_GPBMessage *_GPBGetMessageGroupField(_GPBMessage *self, _GPBFieldDescriptor *field);

/**
 * Sets the value of a group field.
 *
 * @param self  The message into which to set the field.
 * @param field The field to set.
 * @param value The to set in the field.
 **/
void _GPBSetMessageGroupField(_GPBMessage *self, _GPBFieldDescriptor *field, _GPBMessage *value);

/**
 * Gets the value of a bool field.
 *
 * @param self  The message from which to get the field.
 * @param field The field to get.
 **/
BOOL _GPBGetMessageBoolField(_GPBMessage *self, _GPBFieldDescriptor *field);

/**
 * Sets the value of a bool field.
 *
 * @param self  The message into which to set the field.
 * @param field The field to set.
 * @param value The to set in the field.
 **/
void _GPBSetMessageBoolField(_GPBMessage *self, _GPBFieldDescriptor *field, BOOL value);

/**
 * Gets the value of an int32 field.
 *
 * @param self  The message from which to get the field.
 * @param field The field to get.
 **/
int32_t _GPBGetMessageInt32Field(_GPBMessage *self, _GPBFieldDescriptor *field);

/**
 * Sets the value of an int32 field.
 *
 * @param self  The message into which to set the field.
 * @param field The field to set.
 * @param value The to set in the field.
 **/
void _GPBSetMessageInt32Field(_GPBMessage *self, _GPBFieldDescriptor *field, int32_t value);

/**
 * Gets the value of an uint32 field.
 *
 * @param self  The message from which to get the field.
 * @param field The field to get.
 **/
uint32_t _GPBGetMessageUInt32Field(_GPBMessage *self, _GPBFieldDescriptor *field);

/**
 * Sets the value of an uint32 field.
 *
 * @param self  The message into which to set the field.
 * @param field The field to set.
 * @param value The to set in the field.
 **/
void _GPBSetMessageUInt32Field(_GPBMessage *self, _GPBFieldDescriptor *field, uint32_t value);

/**
 * Gets the value of an int64 field.
 *
 * @param self  The message from which to get the field.
 * @param field The field to get.
 **/
int64_t _GPBGetMessageInt64Field(_GPBMessage *self, _GPBFieldDescriptor *field);

/**
 * Sets the value of an int64 field.
 *
 * @param self  The message into which to set the field.
 * @param field The field to set.
 * @param value The to set in the field.
 **/
void _GPBSetMessageInt64Field(_GPBMessage *self, _GPBFieldDescriptor *field, int64_t value);

/**
 * Gets the value of an uint64 field.
 *
 * @param self  The message from which to get the field.
 * @param field The field to get.
 **/
uint64_t _GPBGetMessageUInt64Field(_GPBMessage *self, _GPBFieldDescriptor *field);

/**
 * Sets the value of an uint64 field.
 *
 * @param self  The message into which to set the field.
 * @param field The field to set.
 * @param value The to set in the field.
 **/
void _GPBSetMessageUInt64Field(_GPBMessage *self, _GPBFieldDescriptor *field, uint64_t value);

/**
 * Gets the value of a float field.
 *
 * @param self  The message from which to get the field.
 * @param field The field to get.
 **/
float _GPBGetMessageFloatField(_GPBMessage *self, _GPBFieldDescriptor *field);

/**
 * Sets the value of a float field.
 *
 * @param self  The message into which to set the field.
 * @param field The field to set.
 * @param value The to set in the field.
 **/
void _GPBSetMessageFloatField(_GPBMessage *self, _GPBFieldDescriptor *field, float value);

/**
 * Gets the value of a double field.
 *
 * @param self  The message from which to get the field.
 * @param field The field to get.
 **/
double _GPBGetMessageDoubleField(_GPBMessage *self, _GPBFieldDescriptor *field);

/**
 * Sets the value of a double field.
 *
 * @param self  The message into which to set the field.
 * @param field The field to set.
 * @param value The to set in the field.
 **/
void _GPBSetMessageDoubleField(_GPBMessage *self, _GPBFieldDescriptor *field, double value);

/**
 * Gets the given enum field of a message. For proto3, if the value isn't a
 * member of the enum, @c k_GPBUnrecognizedEnumeratorValue will be returned.
 * _GPBGetMessageRawEnumField will bypass the check and return whatever value
 * was set.
 *
 * @param self  The message from which to get the field.
 * @param field The field to get.
 *
 * @return The enum value for the given field.
 **/
int32_t _GPBGetMessageEnumField(_GPBMessage *self, _GPBFieldDescriptor *field);

/**
 * Set the given enum field of a message. You can only set values that are
 * members of the enum.
 *
 * @param self  The message into which to set the field.
 * @param field The field to set.
 * @param value The enum value to set in the field.
 **/
void _GPBSetMessageEnumField(_GPBMessage *self,
                            _GPBFieldDescriptor *field,
                            int32_t value);

/**
 * Get the given enum field of a message. No check is done to ensure the value
 * was defined in the enum.
 *
 * @param self  The message from which to get the field.
 * @param field The field to get.
 *
 * @return The raw enum value for the given field.
 **/
int32_t _GPBGetMessageRawEnumField(_GPBMessage *self, _GPBFieldDescriptor *field);

/**
 * Set the given enum field of a message. You can set the value to anything,
 * even a value that is not a member of the enum.
 *
 * @param self  The message into which to set the field.
 * @param field The field to set.
 * @param value The raw enum value to set in the field.
 **/
void _GPBSetMessageRawEnumField(_GPBMessage *self,
                               _GPBFieldDescriptor *field,
                               int32_t value);

// Repeated Fields

/**
 * Gets the value of a repeated field.
 *
 * @param self  The message from which to get the field.
 * @param field The repeated field to get.
 *
 * @return A _GPB*Array or an NSMutableArray based on the field's type.
 **/
id _GPBGetMessageRepeatedField(_GPBMessage *self, _GPBFieldDescriptor *field);

/**
 * Sets the value of a repeated field.
 *
 * @param self  The message into which to set the field.
 * @param field The field to set.
 * @param array A _GPB*Array or NSMutableArray based on the field's type.
 **/
void _GPBSetMessageRepeatedField(_GPBMessage *self,
                                _GPBFieldDescriptor *field,
                                id array);

// Map Fields

/**
 * Gets the value of a map<> field.
 *
 * @param self  The message from which to get the field.
 * @param field The repeated field to get.
 *
 * @return A _GPB*Dictionary or NSMutableDictionary based on the field's type.
 **/
id _GPBGetMessageMapField(_GPBMessage *self, _GPBFieldDescriptor *field);

/**
 * Sets the value of a map<> field.
 *
 * @param self       The message into which to set the field.
 * @param field      The field to set.
 * @param dictionary A _GPB*Dictionary or NSMutableDictionary based on the
 *                   field's type.
 **/
void _GPBSetMessageMapField(_GPBMessage *self,
                           _GPBFieldDescriptor *field,
                           id dictionary);

//%PDDM-EXPAND-END _GPB_ACCESSORS()

/**
 * Returns an empty NSData to assign to byte fields when you wish to assign them
 * to empty. Prevents allocating a lot of little [NSData data] objects.
 **/
NSData *_GPBEmptyNSData(void) __attribute__((pure));

/**
 * Drops the `unknownFields` from the given message and from all sub message.
 **/
void _GPBMessageDropUnknownFieldsRecursively(_GPBMessage *message);

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END


//%PDDM-DEFINE _GPB_ACCESSORS()
//%
//%//
//%// Get/Set a given field from/to a message.
//%//
//%
//%// Single Fields
//%
//%_GPB_ACCESSOR_SINGLE_FULL(Bytes, NSData, , *)
//%_GPB_ACCESSOR_SINGLE_FULL(String, NSString, , *)
//%_GPB_ACCESSOR_SINGLE_FULL(Message, _GPBMessage, , *)
//%_GPB_ACCESSOR_SINGLE_FULL(Group, _GPBMessage, , *)
//%_GPB_ACCESSOR_SINGLE(Bool, BOOL, )
//%_GPB_ACCESSOR_SINGLE(Int32, int32_t, n)
//%_GPB_ACCESSOR_SINGLE(UInt32, uint32_t, n)
//%_GPB_ACCESSOR_SINGLE(Int64, int64_t, n)
//%_GPB_ACCESSOR_SINGLE(UInt64, uint64_t, n)
//%_GPB_ACCESSOR_SINGLE(Float, float, )
//%_GPB_ACCESSOR_SINGLE(Double, double, )
//%/**
//% * Gets the given enum field of a message. For proto3, if the value isn't a
//% * member of the enum, @c k_GPBUnrecognizedEnumeratorValue will be returned.
//% * _GPBGetMessageRawEnumField will bypass the check and return whatever value
//% * was set.
//% *
//% * @param self  The message from which to get the field.
//% * @param field The field to get.
//% *
//% * @return The enum value for the given field.
//% **/
//%int32_t _GPBGetMessageEnumField(_GPBMessage *self, _GPBFieldDescriptor *field);
//%
//%/**
//% * Set the given enum field of a message. You can only set values that are
//% * members of the enum.
//% *
//% * @param self  The message into which to set the field.
//% * @param field The field to set.
//% * @param value The enum value to set in the field.
//% **/
//%void _GPBSetMessageEnumField(_GPBMessage *self,
//%                            _GPBFieldDescriptor *field,
//%                            int32_t value);
//%
//%/**
//% * Get the given enum field of a message. No check is done to ensure the value
//% * was defined in the enum.
//% *
//% * @param self  The message from which to get the field.
//% * @param field The field to get.
//% *
//% * @return The raw enum value for the given field.
//% **/
//%int32_t _GPBGetMessageRawEnumField(_GPBMessage *self, _GPBFieldDescriptor *field);
//%
//%/**
//% * Set the given enum field of a message. You can set the value to anything,
//% * even a value that is not a member of the enum.
//% *
//% * @param self  The message into which to set the field.
//% * @param field The field to set.
//% * @param value The raw enum value to set in the field.
//% **/
//%void _GPBSetMessageRawEnumField(_GPBMessage *self,
//%                               _GPBFieldDescriptor *field,
//%                               int32_t value);
//%
//%// Repeated Fields
//%
//%/**
//% * Gets the value of a repeated field.
//% *
//% * @param self  The message from which to get the field.
//% * @param field The repeated field to get.
//% *
//% * @return A _GPB*Array or an NSMutableArray based on the field's type.
//% **/
//%id _GPBGetMessageRepeatedField(_GPBMessage *self, _GPBFieldDescriptor *field);
//%
//%/**
//% * Sets the value of a repeated field.
//% *
//% * @param self  The message into which to set the field.
//% * @param field The field to set.
//% * @param array A _GPB*Array or NSMutableArray based on the field's type.
//% **/
//%void _GPBSetMessageRepeatedField(_GPBMessage *self,
//%                                _GPBFieldDescriptor *field,
//%                                id array);
//%
//%// Map Fields
//%
//%/**
//% * Gets the value of a map<> field.
//% *
//% * @param self  The message from which to get the field.
//% * @param field The repeated field to get.
//% *
//% * @return A _GPB*Dictionary or NSMutableDictionary based on the field's type.
//% **/
//%id _GPBGetMessageMapField(_GPBMessage *self, _GPBFieldDescriptor *field);
//%
//%/**
//% * Sets the value of a map<> field.
//% *
//% * @param self       The message into which to set the field.
//% * @param field      The field to set.
//% * @param dictionary A _GPB*Dictionary or NSMutableDictionary based on the
//% *                   field's type.
//% **/
//%void _GPBSetMessageMapField(_GPBMessage *self,
//%                           _GPBFieldDescriptor *field,
//%                           id dictionary);
//%

//%PDDM-DEFINE _GPB_ACCESSOR_SINGLE(NAME, TYPE, AN)
//%_GPB_ACCESSOR_SINGLE_FULL(NAME, TYPE, AN, )
//%PDDM-DEFINE _GPB_ACCESSOR_SINGLE_FULL(NAME, TYPE, AN, TisP)
//%/**
//% * Gets the value of a##AN NAME$L field.
//% *
//% * @param self  The message from which to get the field.
//% * @param field The field to get.
//% **/
//%TYPE TisP##_GPBGetMessage##NAME##Field(_GPBMessage *self, _GPBFieldDescriptor *field);
//%
//%/**
//% * Sets the value of a##AN NAME$L field.
//% *
//% * @param self  The message into which to set the field.
//% * @param field The field to set.
//% * @param value The to set in the field.
//% **/
//%void _GPBSetMessage##NAME##Field(_GPBMessage *self, _GPBFieldDescriptor *field, TYPE TisP##value);
//%
