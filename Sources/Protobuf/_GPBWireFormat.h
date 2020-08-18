//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_GPBRuntimeTypes.h"

CF_EXTERN_C_BEGIN

NS_ASSUME_NONNULL_BEGIN

typedef enum {
  _GPBWireFormatVarint = 0,
  _GPBWireFormatFixed64 = 1,
  _GPBWireFormatLengthDelimited = 2,
  _GPBWireFormatStartGroup = 3,
  _GPBWireFormatEndGroup = 4,
  _GPBWireFormatFixed32 = 5,
} _GPBWireFormat;

enum {
  _GPBWireFormatMessageSetItem = 1,
  _GPBWireFormatMessageSetTypeId = 2,
  _GPBWireFormatMessageSetMessage = 3
};

uint32_t _GPBWireFormatMakeTag(uint32_t fieldNumber, _GPBWireFormat wireType)
    __attribute__((const));
_GPBWireFormat _GPBWireFormatGetTagWireType(uint32_t tag) __attribute__((const));
uint32_t _GPBWireFormatGetTagFieldNumber(uint32_t tag) __attribute__((const));
BOOL _GPBWireFormatIsValidTag(uint32_t tag) __attribute__((const));

_GPBWireFormat _GPBWireFormatForType(_GPBDataType dataType, BOOL isPacked)
    __attribute__((const));

#define _GPBWireFormatMessageSetItemTag \
  (_GPBWireFormatMakeTag(_GPBWireFormatMessageSetItem, _GPBWireFormatStartGroup))
#define _GPBWireFormatMessageSetItemEndTag \
  (_GPBWireFormatMakeTag(_GPBWireFormatMessageSetItem, _GPBWireFormatEndGroup))
#define _GPBWireFormatMessageSetTypeIdTag \
  (_GPBWireFormatMakeTag(_GPBWireFormatMessageSetTypeId, _GPBWireFormatVarint))
#define _GPBWireFormatMessageSetMessageTag               \
  (_GPBWireFormatMakeTag(_GPBWireFormatMessageSetMessage, \
                        _GPBWireFormatLengthDelimited))

NS_ASSUME_NONNULL_END

CF_EXTERN_C_END
