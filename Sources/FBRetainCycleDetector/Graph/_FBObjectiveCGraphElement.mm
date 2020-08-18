//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_FBObjectiveCGraphElement+Internal.h"

#import <objc/message.h>
#import <objc/runtime.h>

#import "_FBAssociationManager.h"
#import "_FBClassStrongLayout.h"
#import "_FBObjectGraphConfiguration.h"
#import "_FBRetainCycleUtils.h"
#import "_FBRetainCycleDetector.h"

@implementation _FBObjectiveCGraphElement

- (instancetype)initWithObject:(id)object
{
  return [self initWithObject:object
                configuration:[_FBObjectGraphConfiguration new]];
}

- (instancetype)initWithObject:(id)object
                 configuration:(nonnull _FBObjectGraphConfiguration *)configuration
{
  return [self initWithObject:object
                configuration:configuration
                     namePath:nil];
}

- (instancetype)initWithObject:(id)object
                 configuration:(nonnull _FBObjectGraphConfiguration *)configuration
                      namePath:(NSArray<NSString *> *)namePath
{
  if (self = [super init]) {
#if _INTERNAL_RCD_ENABLED
    // We are trying to mimic how ObjectiveC does storeWeak to not fall into
    // _objc_fatal path
    // https://github.com/bavarious/objc4/blob/3f282b8dbc0d1e501f97e4ed547a4a99cb3ac10b/runtime/objc-weak.mm#L369

    Class aCls = object_getClass(object);

    BOOL (*allowsWeakReference)(id, SEL) =
    (__typeof__(allowsWeakReference))class_getMethodImplementation(aCls, @selector(allowsWeakReference));

    if (allowsWeakReference && (IMP)allowsWeakReference != _objc_msgForward) {
      if (allowsWeakReference(object, @selector(allowsWeakReference))) {
        // This is still racey since allowsWeakReference could change it value by now.
        _object = object;
      }
    } else {
      _object = object;
    }
#endif
    _namePath = namePath;
    _configuration = configuration;
  }

  return self;
}

- (NSSet *)allRetainedObjects
{
  NSArray *retainedObjectsNotWrapped = [_FBAssociationManager associationsForObject:_object];
  NSMutableSet *retainedObjects = [NSMutableSet new];

  for (id obj in retainedObjectsNotWrapped) {
    _FBObjectiveCGraphElement *element = _FBWrapObjectGraphElementWithContext(self,
                                                                            obj,
                                                                            _configuration,
                                                                            @[@"__associated_object"]);
    if (element) {
      [retainedObjects addObject:element];
    }
  }

  return retainedObjects;
}

- (BOOL)isEqual:(id)object
{
  if ([object isKindOfClass:[_FBObjectiveCGraphElement class]]) {
    _FBObjectiveCGraphElement *objcObject = object;
    // Use pointer equality
    return objcObject.object == _object;
  }
  return NO;
}

- (NSUInteger)hash
{
  return (size_t)_object;
}

- (NSString *)description
{
  if (_namePath) {
    NSString *namePathStringified = [_namePath componentsJoinedByString:@" -> "];
    return [NSString stringWithFormat:@"-> %@ -> %@ ", namePathStringified, [self classNameOrNull]];
  }
  return [NSString stringWithFormat:@"-> %@ ", [self classNameOrNull]];
}

- (size_t)objectAddress
{
  return (size_t)_object;
}

- (NSString *)classNameOrNull
{
  NSString *className = NSStringFromClass([self objectClass]);
  if (!className) {
    className = @"(null)";
  }

  return className;
}

- (Class)objectClass
{
  return object_getClass(_object);
}

@end
