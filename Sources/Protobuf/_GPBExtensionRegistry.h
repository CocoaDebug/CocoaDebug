//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

@class _GPBDescriptor;
@class _GPBExtensionDescriptor;

NS_ASSUME_NONNULL_BEGIN

/**
 * A table of known extensions, searchable by name or field number.  When
 * parsing a protocol message that might have extensions, you must provide a
 * _GPBExtensionRegistry in which you have registered any extensions that you
 * want to be able to parse. Otherwise, those extensions will just be treated
 * like unknown fields.
 *
 * The *Root classes provide `+extensionRegistry` for the extensions defined
 * in a given file *and* all files it imports. You can also create a
 * _GPBExtensionRegistry, and merge those registries to handle parsing
 * extensions defined from non overlapping files.
 *
 * ```
 * _GPBExtensionRegistry *registry = [[MyProtoFileRoot extensionRegistry] copy];
 * [registry addExtension:[OtherMessage neededExtension]]; // Not in MyProtoFile
 * NSError *parseError;
 * MyMessage *msg = [MyMessage parseData:data extensionRegistry:registry error:&parseError];
 * ```
 **/
@interface _GPBExtensionRegistry : NSObject<NSCopying>

/**
 * Adds the given _GPBExtensionDescriptor to this registry.
 *
 * @param extension The extension description to add.
 **/
- (void)addExtension:(_GPBExtensionDescriptor *)extension;

/**
 * Adds all the extensions from another registry to this registry.
 *
 * @param registry The registry to merge into this registry.
 **/
- (void)addExtensions:(_GPBExtensionRegistry *)registry;

/**
 * Looks for the extension registered for the given field number on a given
 * _GPBDescriptor.
 *
 * @param descriptor  The descriptor to look for a registered extension on.
 * @param fieldNumber The field number of the extension to look for.
 *
 * @return The registered _GPBExtensionDescriptor or nil if none was found.
 **/
- (nullable _GPBExtensionDescriptor *)extensionForDescriptor:(_GPBDescriptor *)descriptor
                                                fieldNumber:(NSInteger)fieldNumber;

@end

NS_ASSUME_NONNULL_END
