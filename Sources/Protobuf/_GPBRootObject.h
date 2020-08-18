//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

@class _GPBExtensionRegistry;

NS_ASSUME_NONNULL_BEGIN

/**
 * Every generated proto file defines a local "Root" class that exposes a
 * _GPBExtensionRegistry for all the extensions defined by that file and
 * the files it depends on.
 **/
@interface _GPBRootObject : NSObject

/**
 * @return An extension registry for the given file and all the files it depends
 * on.
 **/
+ (_GPBExtensionRegistry *)extensionRegistry;

@end

NS_ASSUME_NONNULL_END
