//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_GPBUnknownFieldSet_PackagePrivate.h"

#import "_GPBCodedInputStream_PackagePrivate.h"
#import "_GPBCodedOutputStream.h"
#import "_GPBUnknownField_PackagePrivate.h"
#import "_GPBUtilities.h"
#import "_GPBWireFormat.h"

#pragma mark Helpers

static void checkNumber(int32_t number) {
  if (number == 0) {
    [NSException raise:NSInvalidArgumentException
                format:@"Zero is not a valid field number."];
  }
}

@implementation _GPBUnknownFieldSet {
 @package
  CFMutableDictionaryRef fields_;
}

static void CopyWorker(const void *key, const void *value, void *context) {
#pragma unused(key)
  _GPBUnknownField *field = value;
  _GPBUnknownFieldSet *result = context;

  _GPBUnknownField *copied = [field copy];
  [result addField:copied];
  [copied release];
}

// Direct access is use for speed, to avoid even internally declaring things
// read/write, etc. The warning is enabled in the project to ensure code calling
// protos can turn on -Wdirect-ivar-access without issues.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"

- (id)copyWithZone:(NSZone *)zone {
  _GPBUnknownFieldSet *result = [[_GPBUnknownFieldSet allocWithZone:zone] init];
  if (fields_) {
    CFDictionaryApplyFunction(fields_, CopyWorker, result);
  }
  return result;
}

- (void)dealloc {
  if (fields_) {
    CFRelease(fields_);
  }
  [super dealloc];
}

- (BOOL)isEqual:(id)object {
  BOOL equal = NO;
  if ([object isKindOfClass:[_GPBUnknownFieldSet class]]) {
    _GPBUnknownFieldSet *set = (_GPBUnknownFieldSet *)object;
    if ((fields_ == NULL) && (set->fields_ == NULL)) {
      equal = YES;
    } else if ((fields_ != NULL) && (set->fields_ != NULL)) {
      equal = CFEqual(fields_, set->fields_);
    }
  }
  return equal;
}

- (NSUInteger)hash {
  // Return the hash of the fields dictionary (or just some value).
  if (fields_) {
    return CFHash(fields_);
  }
  return (NSUInteger)[_GPBUnknownFieldSet class];
}

#pragma mark - Public Methods

- (BOOL)hasField:(int32_t)number {
  ssize_t key = number;
  return fields_ ? (CFDictionaryGetValue(fields_, (void *)key) != nil) : NO;
}

- (_GPBUnknownField *)getField:(int32_t)number {
  ssize_t key = number;
  _GPBUnknownField *result =
      fields_ ? CFDictionaryGetValue(fields_, (void *)key) : nil;
  return result;
}

- (NSUInteger)countOfFields {
  return fields_ ? CFDictionaryGetCount(fields_) : 0;
}

- (NSArray *)sortedFields {
  if (!fields_) return [NSArray array];
  size_t count = CFDictionaryGetCount(fields_);
  ssize_t keys[count];
  _GPBUnknownField *values[count];
  CFDictionaryGetKeysAndValues(fields_, (const void **)keys,
                               (const void **)values);
  struct _GPBFieldPair {
    ssize_t key;
    _GPBUnknownField *value;
  } pairs[count];
  for (size_t i = 0; i < count; ++i) {
    pairs[i].key = keys[i];
    pairs[i].value = values[i];
  };
  qsort_b(pairs, count, sizeof(struct _GPBFieldPair),
          ^(const void *first, const void *second) {
            const struct _GPBFieldPair *a = first;
            const struct _GPBFieldPair *b = second;
            return (a->key > b->key) ? 1 : ((a->key == b->key) ? 0 : -1);
          });
  for (size_t i = 0; i < count; ++i) {
    values[i] = pairs[i].value;
  };
  return [NSArray arrayWithObjects:values count:count];
}

#pragma mark - Internal Methods

- (void)writeToCodedOutputStream:(_GPBCodedOutputStream *)output {
  if (!fields_) return;
  size_t count = CFDictionaryGetCount(fields_);
  ssize_t keys[count];
  _GPBUnknownField *values[count];
  CFDictionaryGetKeysAndValues(fields_, (const void **)keys,
                               (const void **)values);
  if (count > 1) {
    struct _GPBFieldPair {
      ssize_t key;
      _GPBUnknownField *value;
    } pairs[count];

    for (size_t i = 0; i < count; ++i) {
      pairs[i].key = keys[i];
      pairs[i].value = values[i];
    };
    qsort_b(pairs, count, sizeof(struct _GPBFieldPair),
            ^(const void *first, const void *second) {
              const struct _GPBFieldPair *a = first;
              const struct _GPBFieldPair *b = second;
              return (a->key > b->key) ? 1 : ((a->key == b->key) ? 0 : -1);
            });
    for (size_t i = 0; i < count; ++i) {
      _GPBUnknownField *value = pairs[i].value;
      [value writeToOutput:output];
    }
  } else {
    [values[0] writeToOutput:output];
  }
}

- (NSString *)description {
  NSMutableString *description = [NSMutableString
      stringWithFormat:@"<%@ %p>: TextFormat: {\n", [self class], self];
  NSString *textFormat = _GPBTextFormatForUnknownFieldSet(self, @"  ");
  [description appendString:textFormat];
  [description appendString:@"}"];
  return description;
}

static void _GPBUnknownFieldSetSerializedSize(const void *key, const void *value,
                                             void *context) {
#pragma unused(key)
  _GPBUnknownField *field = value;
  size_t *result = context;
  *result += [field serializedSize];
}

- (size_t)serializedSize {
  size_t result = 0;
  if (fields_) {
    CFDictionaryApplyFunction(fields_, _GPBUnknownFieldSetSerializedSize,
                              &result);
  }
  return result;
}

static void _GPBUnknownFieldSetWriteAsMessageSetTo(const void *key,
                                                  const void *value,
                                                  void *context) {
#pragma unused(key)
  _GPBUnknownField *field = value;
  _GPBCodedOutputStream *output = context;
  [field writeAsMessageSetExtensionToOutput:output];
}

- (void)writeAsMessageSetTo:(_GPBCodedOutputStream *)output {
  if (fields_) {
    CFDictionaryApplyFunction(fields_, _GPBUnknownFieldSetWriteAsMessageSetTo,
                              output);
  }
}

static void _GPBUnknownFieldSetSerializedSizeAsMessageSet(const void *key,
                                                         const void *value,
                                                         void *context) {
#pragma unused(key)
  _GPBUnknownField *field = value;
  size_t *result = context;
  *result += [field serializedSizeAsMessageSetExtension];
}

- (size_t)serializedSizeAsMessageSet {
  size_t result = 0;
  if (fields_) {
    CFDictionaryApplyFunction(
        fields_, _GPBUnknownFieldSetSerializedSizeAsMessageSet, &result);
  }
  return result;
}

- (NSData *)data {
  NSMutableData *data = [NSMutableData dataWithLength:self.serializedSize];
  _GPBCodedOutputStream *output =
      [[_GPBCodedOutputStream alloc] initWithData:data];
  [self writeToCodedOutputStream:output];
  [output release];
  return data;
}

+ (BOOL)isFieldTag:(int32_t)tag {
  return _GPBWireFormatGetTagWireType(tag) != _GPBWireFormatEndGroup;
}

- (void)addField:(_GPBUnknownField *)field {
  int32_t number = [field number];
  checkNumber(number);
  if (!fields_) {
    // Use a custom dictionary here because the keys are numbers and conversion
    // back and forth from NSNumber isn't worth the cost.
    fields_ = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, NULL,
                                        &kCFTypeDictionaryValueCallBacks);
  }
  ssize_t key = number;
  CFDictionarySetValue(fields_, (const void *)key, field);
}

- (_GPBUnknownField *)mutableFieldForNumber:(int32_t)number create:(BOOL)create {
  ssize_t key = number;
  _GPBUnknownField *existing =
      fields_ ? CFDictionaryGetValue(fields_, (const void *)key) : nil;
  if (!existing && create) {
    existing = [[_GPBUnknownField alloc] initWithNumber:number];
    // This retains existing.
    [self addField:existing];
    [existing release];
  }
  return existing;
}

static void _GPBUnknownFieldSetMergeUnknownFields(const void *key,
                                                 const void *value,
                                                 void *context) {
#pragma unused(key)
  _GPBUnknownField *field = value;
  _GPBUnknownFieldSet *self = context;

  int32_t number = [field number];
  checkNumber(number);
  _GPBUnknownField *oldField = [self mutableFieldForNumber:number create:NO];
  if (oldField) {
    [oldField mergeFromField:field];
  } else {
    // Merge only comes from _GPBMessage's mergeFrom:, so it means we are on
    // mutable message and are an mutable instance, so make sure we need
    // mutable fields.
    _GPBUnknownField *fieldCopy = [field copy];
    [self addField:fieldCopy];
    [fieldCopy release];
  }
}

- (void)mergeUnknownFields:(_GPBUnknownFieldSet *)other {
  if (other && other->fields_) {
    CFDictionaryApplyFunction(other->fields_,
                              _GPBUnknownFieldSetMergeUnknownFields, self);
  }
}

- (void)mergeFromData:(NSData *)data {
  _GPBCodedInputStream *input = [[_GPBCodedInputStream alloc] initWithData:data];
  [self mergeFromCodedInputStream:input];
  [input checkLastTagWas:0];
  [input release];
}

- (void)mergeVarintField:(int32_t)number value:(int32_t)value {
  checkNumber(number);
  [[self mutableFieldForNumber:number create:YES] addVarint:value];
}

- (BOOL)mergeFieldFrom:(int32_t)tag input:(_GPBCodedInputStream *)input {
  NSAssert(_GPBWireFormatIsValidTag(tag), @"Got passed an invalid tag");
  int32_t number = _GPBWireFormatGetTagFieldNumber(tag);
  _GPBCodedInputStreamState *state = &input->state_;
  switch (_GPBWireFormatGetTagWireType(tag)) {
    case _GPBWireFormatVarint: {
      _GPBUnknownField *field = [self mutableFieldForNumber:number create:YES];
      [field addVarint:_GPBCodedInputStreamReadInt64(state)];
      return YES;
    }
    case _GPBWireFormatFixed64: {
      _GPBUnknownField *field = [self mutableFieldForNumber:number create:YES];
      [field addFixed64:_GPBCodedInputStreamReadFixed64(state)];
      return YES;
    }
    case _GPBWireFormatLengthDelimited: {
      NSData *data = _GPBCodedInputStreamReadRetainedBytes(state);
      _GPBUnknownField *field = [self mutableFieldForNumber:number create:YES];
      [field addLengthDelimited:data];
      [data release];
      return YES;
    }
    case _GPBWireFormatStartGroup: {
      _GPBUnknownFieldSet *unknownFieldSet = [[_GPBUnknownFieldSet alloc] init];
      [input readUnknownGroup:number message:unknownFieldSet];
      _GPBUnknownField *field = [self mutableFieldForNumber:number create:YES];
      [field addGroup:unknownFieldSet];
      [unknownFieldSet release];
      return YES;
    }
    case _GPBWireFormatEndGroup:
      return NO;
    case _GPBWireFormatFixed32: {
      _GPBUnknownField *field = [self mutableFieldForNumber:number create:YES];
      [field addFixed32:_GPBCodedInputStreamReadFixed32(state)];
      return YES;
    }
  }
}

- (void)mergeMessageSetMessage:(int32_t)number data:(NSData *)messageData {
  [[self mutableFieldForNumber:number create:YES]
      addLengthDelimited:messageData];
}

- (void)addUnknownMapEntry:(int32_t)fieldNum value:(NSData *)data {
  _GPBUnknownField *field = [self mutableFieldForNumber:fieldNum create:YES];
  [field addLengthDelimited:data];
}

- (void)mergeFromCodedInputStream:(_GPBCodedInputStream *)input {
  while (YES) {
    int32_t tag = _GPBCodedInputStreamReadTag(&input->state_);
    if (tag == 0 || ![self mergeFieldFrom:tag input:input]) {
      break;
    }
  }
}

- (void)getTags:(int32_t *)tags {
  if (!fields_) return;
  size_t count = CFDictionaryGetCount(fields_);
  ssize_t keys[count];
  CFDictionaryGetKeysAndValues(fields_, (const void **)keys, NULL);
  for (size_t i = 0; i < count; ++i) {
    tags[i] = (int32_t)keys[i];
  }
}

#pragma clang diagnostic pop

@end
