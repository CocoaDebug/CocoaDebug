//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "_GPBRootObject.h"

@class _GPBExtensionDescriptor;

@interface _GPBRootObject ()

// Globally register.
+ (void)globallyRegisterExtension:(_GPBExtensionDescriptor *)field;

@end

// Returns YES if the selector was resolved and added to the class,
// NO otherwise.
BOOL _GPBResolveExtensionClassMethod(Class self, SEL sel);
