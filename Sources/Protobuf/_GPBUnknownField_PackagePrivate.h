//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "_GPBUnknownField.h"

@class _GPBCodedOutputStream;

@interface _GPBUnknownField ()

- (void)writeToOutput:(_GPBCodedOutputStream *)output;
- (size_t)serializedSize;

- (void)writeAsMessageSetExtensionToOutput:(_GPBCodedOutputStream *)output;
- (size_t)serializedSizeAsMessageSetExtension;

- (void)mergeFromField:(_GPBUnknownField *)other;

@end
