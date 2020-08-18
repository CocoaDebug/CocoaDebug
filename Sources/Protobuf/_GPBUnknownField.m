//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_GPBUnknownField_PackagePrivate.h"

#import "_GPBArray.h"
#import "_GPBCodedOutputStream_PackagePrivate.h"
#import "_GPBUnknownFieldSet.h"

@implementation _GPBUnknownField {
 @protected
  int32_t number_;
  _GPBUInt64Array *mutableVarintList_;
  _GPBUInt32Array *mutableFixed32List_;
  _GPBUInt64Array *mutableFixed64List_;
  NSMutableArray<NSData*> *mutableLengthDelimitedList_;
  NSMutableArray<_GPBUnknownFieldSet*> *mutableGroupList_;
}

@synthesize number = number_;
@synthesize varintList = mutableVarintList_;
@synthesize fixed32List = mutableFixed32List_;
@synthesize fixed64List = mutableFixed64List_;
@synthesize lengthDelimitedList = mutableLengthDelimitedList_;
@synthesize groupList = mutableGroupList_;

- (instancetype)initWithNumber:(int32_t)number {
  if ((self = [super init])) {
    number_ = number;
  }
  return self;
}

- (void)dealloc {
  [mutableVarintList_ release];
  [mutableFixed32List_ release];
  [mutableFixed64List_ release];
  [mutableLengthDelimitedList_ release];
  [mutableGroupList_ release];

  [super dealloc];
}

// Direct access is use for speed, to avoid even internally declaring things
// read/write, etc. The warning is enabled in the project to ensure code calling
// protos can turn on -Wdirect-ivar-access without issues.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"

- (id)copyWithZone:(NSZone *)zone {
  _GPBUnknownField *result =
      [[_GPBUnknownField allocWithZone:zone] initWithNumber:number_];
  result->mutableFixed32List_ = [mutableFixed32List_ copyWithZone:zone];
  result->mutableFixed64List_ = [mutableFixed64List_ copyWithZone:zone];
  result->mutableLengthDelimitedList_ =
      [mutableLengthDelimitedList_ mutableCopyWithZone:zone];
  result->mutableVarintList_ = [mutableVarintList_ copyWithZone:zone];
  if (mutableGroupList_.count) {
    result->mutableGroupList_ = [[NSMutableArray allocWithZone:zone]
        initWithCapacity:mutableGroupList_.count];
    for (_GPBUnknownFieldSet *group in mutableGroupList_) {
      _GPBUnknownFieldSet *copied = [group copyWithZone:zone];
      [result->mutableGroupList_ addObject:copied];
      [copied release];
    }
  }
  return result;
}

- (BOOL)isEqual:(id)object {
  if (self == object) return YES;
  if (![object isKindOfClass:[_GPBUnknownField class]]) return NO;
  _GPBUnknownField *field = (_GPBUnknownField *)object;
  if (number_ != field->number_) return NO;
  BOOL equalVarint =
      (mutableVarintList_.count == 0 && field->mutableVarintList_.count == 0) ||
      [mutableVarintList_ isEqual:field->mutableVarintList_];
  if (!equalVarint) return NO;
  BOOL equalFixed32 = (mutableFixed32List_.count == 0 &&
                       field->mutableFixed32List_.count == 0) ||
                      [mutableFixed32List_ isEqual:field->mutableFixed32List_];
  if (!equalFixed32) return NO;
  BOOL equalFixed64 = (mutableFixed64List_.count == 0 &&
                       field->mutableFixed64List_.count == 0) ||
                      [mutableFixed64List_ isEqual:field->mutableFixed64List_];
  if (!equalFixed64) return NO;
  BOOL equalLDList =
      (mutableLengthDelimitedList_.count == 0 &&
       field->mutableLengthDelimitedList_.count == 0) ||
      [mutableLengthDelimitedList_ isEqual:field->mutableLengthDelimitedList_];
  if (!equalLDList) return NO;
  BOOL equalGroupList =
      (mutableGroupList_.count == 0 && field->mutableGroupList_.count == 0) ||
      [mutableGroupList_ isEqual:field->mutableGroupList_];
  if (!equalGroupList) return NO;
  return YES;
}

- (NSUInteger)hash {
  // Just mix the hashes of the possible sub arrays.
  const int prime = 31;
  NSUInteger result = prime + [mutableVarintList_ hash];
  result = prime * result + [mutableFixed32List_ hash];
  result = prime * result + [mutableFixed64List_ hash];
  result = prime * result + [mutableLengthDelimitedList_ hash];
  result = prime * result + [mutableGroupList_ hash];
  return result;
}

- (void)writeToOutput:(_GPBCodedOutputStream *)output {
  NSUInteger count = mutableVarintList_.count;
  if (count > 0) {
    [output writeUInt64Array:number_ values:mutableVarintList_ tag:0];
  }
  count = mutableFixed32List_.count;
  if (count > 0) {
    [output writeFixed32Array:number_ values:mutableFixed32List_ tag:0];
  }
  count = mutableFixed64List_.count;
  if (count > 0) {
    [output writeFixed64Array:number_ values:mutableFixed64List_ tag:0];
  }
  count = mutableLengthDelimitedList_.count;
  if (count > 0) {
    [output writeBytesArray:number_ values:mutableLengthDelimitedList_];
  }
  count = mutableGroupList_.count;
  if (count > 0) {
    [output writeUnknownGroupArray:number_ values:mutableGroupList_];
  }
}

- (size_t)serializedSize {
  __block size_t result = 0;
  int32_t number = number_;
  [mutableVarintList_
      enumerateValuesWithBlock:^(uint64_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
        result += _GPBComputeUInt64Size(number, value);
      }];

  [mutableFixed32List_
      enumerateValuesWithBlock:^(uint32_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
        result += _GPBComputeFixed32Size(number, value);
      }];

  [mutableFixed64List_
      enumerateValuesWithBlock:^(uint64_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
        result += _GPBComputeFixed64Size(number, value);
      }];

  for (NSData *data in mutableLengthDelimitedList_) {
    result += _GPBComputeBytesSize(number, data);
  }

  for (_GPBUnknownFieldSet *set in mutableGroupList_) {
    result += _GPBComputeUnknownGroupSize(number, set);
  }

  return result;
}

- (void)writeAsMessageSetExtensionToOutput:(_GPBCodedOutputStream *)output {
  for (NSData *data in mutableLengthDelimitedList_) {
    [output writeRawMessageSetExtension:number_ value:data];
  }
}

- (size_t)serializedSizeAsMessageSetExtension {
  size_t result = 0;
  for (NSData *data in mutableLengthDelimitedList_) {
    result += _GPBComputeRawMessageSetExtensionSize(number_, data);
  }
  return result;
}

- (NSString *)description {
  NSMutableString *description =
      [NSMutableString stringWithFormat:@"<%@ %p>: Field: %d {\n",
       [self class], self, number_];
  [mutableVarintList_
      enumerateValuesWithBlock:^(uint64_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
        [description appendFormat:@"\t%llu\n", value];
      }];

  [mutableFixed32List_
      enumerateValuesWithBlock:^(uint32_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
        [description appendFormat:@"\t%u\n", value];
      }];

  [mutableFixed64List_
      enumerateValuesWithBlock:^(uint64_t value, NSUInteger idx, BOOL *stop) {
#pragma unused(idx, stop)
        [description appendFormat:@"\t%llu\n", value];
      }];

  for (NSData *data in mutableLengthDelimitedList_) {
    [description appendFormat:@"\t%@\n", data];
  }

  for (_GPBUnknownFieldSet *set in mutableGroupList_) {
    [description appendFormat:@"\t%@\n", set];
  }
  [description appendString:@"}"];
  return description;
}

- (void)mergeFromField:(_GPBUnknownField *)other {
  _GPBUInt64Array *otherVarintList = other.varintList;
  if (otherVarintList.count > 0) {
    if (mutableVarintList_ == nil) {
      mutableVarintList_ = [otherVarintList copy];
    } else {
      [mutableVarintList_ addValuesFromArray:otherVarintList];
    }
  }

  _GPBUInt32Array *otherFixed32List = other.fixed32List;
  if (otherFixed32List.count > 0) {
    if (mutableFixed32List_ == nil) {
      mutableFixed32List_ = [otherFixed32List copy];
    } else {
      [mutableFixed32List_ addValuesFromArray:otherFixed32List];
    }
  }

  _GPBUInt64Array *otherFixed64List = other.fixed64List;
  if (otherFixed64List.count > 0) {
    if (mutableFixed64List_ == nil) {
      mutableFixed64List_ = [otherFixed64List copy];
    } else {
      [mutableFixed64List_ addValuesFromArray:otherFixed64List];
    }
  }

  NSArray *otherLengthDelimitedList = other.lengthDelimitedList;
  if (otherLengthDelimitedList.count > 0) {
    if (mutableLengthDelimitedList_ == nil) {
      mutableLengthDelimitedList_ = [otherLengthDelimitedList mutableCopy];
    } else {
      [mutableLengthDelimitedList_
          addObjectsFromArray:otherLengthDelimitedList];
    }
  }

  NSArray *otherGroupList = other.groupList;
  if (otherGroupList.count > 0) {
    if (mutableGroupList_ == nil) {
      mutableGroupList_ =
          [[NSMutableArray alloc] initWithCapacity:otherGroupList.count];
    }
    // Make our own mutable copies.
    for (_GPBUnknownFieldSet *group in otherGroupList) {
      _GPBUnknownFieldSet *copied = [group copy];
      [mutableGroupList_ addObject:copied];
      [copied release];
    }
  }
}

- (void)addVarint:(uint64_t)value {
  if (mutableVarintList_ == nil) {
    mutableVarintList_ = [[_GPBUInt64Array alloc] initWithValues:&value count:1];
  } else {
    [mutableVarintList_ addValue:value];
  }
}

- (void)addFixed32:(uint32_t)value {
  if (mutableFixed32List_ == nil) {
    mutableFixed32List_ =
        [[_GPBUInt32Array alloc] initWithValues:&value count:1];
  } else {
    [mutableFixed32List_ addValue:value];
  }
}

- (void)addFixed64:(uint64_t)value {
  if (mutableFixed64List_ == nil) {
    mutableFixed64List_ =
        [[_GPBUInt64Array alloc] initWithValues:&value count:1];
  } else {
    [mutableFixed64List_ addValue:value];
  }
}

- (void)addLengthDelimited:(NSData *)value {
  if (mutableLengthDelimitedList_ == nil) {
    mutableLengthDelimitedList_ =
        [[NSMutableArray alloc] initWithObjects:&value count:1];
  } else {
    [mutableLengthDelimitedList_ addObject:value];
  }
}

- (void)addGroup:(_GPBUnknownFieldSet *)value {
  if (mutableGroupList_ == nil) {
    mutableGroupList_ = [[NSMutableArray alloc] initWithObjects:&value count:1];
  } else {
    [mutableGroupList_ addObject:value];
  }
}

#pragma clang diagnostic pop

@end
