//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "_GPBUnknownFieldSet.h"

@class _GPBCodedOutputStream;
@class _GPBCodedInputStream;

@interface _GPBUnknownFieldSet ()

+ (BOOL)isFieldTag:(int32_t)tag;

- (NSData *)data;

- (size_t)serializedSize;
- (size_t)serializedSizeAsMessageSet;

- (void)writeToCodedOutputStream:(_GPBCodedOutputStream *)output;
- (void)writeAsMessageSetTo:(_GPBCodedOutputStream *)output;

- (void)mergeUnknownFields:(_GPBUnknownFieldSet *)other;

- (void)mergeFromCodedInputStream:(_GPBCodedInputStream *)input;
- (void)mergeFromData:(NSData *)data;

- (void)mergeVarintField:(int32_t)number value:(int32_t)value;
- (BOOL)mergeFieldFrom:(int32_t)tag input:(_GPBCodedInputStream *)input;
- (void)mergeMessageSetMessage:(int32_t)number data:(NSData *)messageData;

- (void)addUnknownMapEntry:(int32_t)fieldNum value:(NSData *)data;

@end
