//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "_GPBDescriptor.h"

@class _GPBCodedInputStream;
@class _GPBCodedOutputStream;
@class _GPBExtensionRegistry;

void _GPBExtensionMergeFromInputStream(_GPBExtensionDescriptor *extension,
                                      BOOL isPackedOnStream,
                                      _GPBCodedInputStream *input,
                                      _GPBExtensionRegistry *extensionRegistry,
                                      _GPBMessage *message);

size_t _GPBComputeExtensionSerializedSizeIncludingTag(
    _GPBExtensionDescriptor *extension, id value);

void _GPBWriteExtensionValueToOutputStream(_GPBExtensionDescriptor *extension,
                                          id value,
                                          _GPBCodedOutputStream *output);
