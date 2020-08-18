//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_GPBExtensionRegistry.h"

#import "_GPBBootstrap.h"
#import "_GPBDescriptor.h"

@implementation _GPBExtensionRegistry {
  NSMutableDictionary *mutableClassMap_;
}

- (instancetype)init {
  if ((self = [super init])) {
    mutableClassMap_ = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)dealloc {
  [mutableClassMap_ release];
  [super dealloc];
}

// Direct access is use for speed, to avoid even internally declaring things
// read/write, etc. The warning is enabled in the project to ensure code calling
// protos can turn on -Wdirect-ivar-access without issues.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"

- (instancetype)copyWithZone:(NSZone *)zone {
  _GPBExtensionRegistry *result = [[[self class] allocWithZone:zone] init];
  [result addExtensions:self];
  return result;
}

- (void)addExtension:(_GPBExtensionDescriptor *)extension {
  if (extension == nil) {
    return;
  }

  Class containingMessageClass = extension.containingMessageClass;
  CFMutableDictionaryRef extensionMap = (CFMutableDictionaryRef)
      [mutableClassMap_ objectForKey:containingMessageClass];
  if (extensionMap == nil) {
    // Use a custom dictionary here because the keys are numbers and conversion
    // back and forth from NSNumber isn't worth the cost.
    extensionMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, NULL,
                                             &kCFTypeDictionaryValueCallBacks);
    [mutableClassMap_ setObject:(id)extensionMap
                         forKey:(id<NSCopying>)containingMessageClass];
    CFRelease(extensionMap);
  }

  ssize_t key = extension.fieldNumber;
  CFDictionarySetValue(extensionMap, (const void *)key, extension);
}

- (_GPBExtensionDescriptor *)extensionForDescriptor:(_GPBDescriptor *)descriptor
                                       fieldNumber:(NSInteger)fieldNumber {
  Class messageClass = descriptor.messageClass;
  CFMutableDictionaryRef extensionMap = (CFMutableDictionaryRef)
      [mutableClassMap_ objectForKey:messageClass];
  ssize_t key = fieldNumber;
  _GPBExtensionDescriptor *result =
      (extensionMap
       ? CFDictionaryGetValue(extensionMap, (const void *)key)
       : nil);
  return result;
}

static void CopyKeyValue(const void *key, const void *value, void *context) {
  CFMutableDictionaryRef extensionMap = (CFMutableDictionaryRef)context;
  CFDictionarySetValue(extensionMap, key, value);
}

- (void)addExtensions:(_GPBExtensionRegistry *)registry {
  if (registry == nil) {
    // In the case where there are no extensions just ignore.
    return;
  }
  NSMutableDictionary *otherClassMap = registry->mutableClassMap_;
  [otherClassMap enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL * stop) {
#pragma unused(stop)
    Class containingMessageClass = key;
    CFMutableDictionaryRef otherExtensionMap = (CFMutableDictionaryRef)value;

    CFMutableDictionaryRef extensionMap = (CFMutableDictionaryRef)
        [mutableClassMap_ objectForKey:containingMessageClass];
    if (extensionMap == nil) {
      extensionMap = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, otherExtensionMap);
      [mutableClassMap_ setObject:(id)extensionMap
                           forKey:(id<NSCopying>)containingMessageClass];
      CFRelease(extensionMap);
    } else {
      CFDictionaryApplyFunction(otherExtensionMap, CopyKeyValue, extensionMap);
    }
  }];
}

#pragma clang diagnostic pop

@end
