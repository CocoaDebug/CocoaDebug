//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#if __has_feature(objc_arc)
#error This file must be compiled with MRR. Use -fno-objc-arc flag.
#endif

#import <algorithm>
#import <map>
#import <mutex>
#import <objc/runtime.h>
#import <unordered_map>
#import <unordered_set>
#import <vector>

#import "_FBAssociationManager+Internal.h"
#import "_FBRetainCycleDetector.h"

#import "_fishhook.h"

#if _INTERNAL_RCD_ENABLED

namespace _FB { namespace AssociationManager {
  using ObjectAssociationSet = std::unordered_set<void *>;
  using AssociationMap = std::unordered_map<id, ObjectAssociationSet *>;

  static auto _associationMap = new AssociationMap();
  static auto _associationMutex = new std::mutex;

  static std::mutex *hookMutex(new std::mutex);
  static bool hookTaken = false;

  void _threadUnsafeResetAssociationAtKey(id object, void *key) {
    auto i = _associationMap->find(object);

    if (i == _associationMap->end()) {
      return;
    }

    auto *refs = i->second;
    auto j = refs->find(key);
    if (j != refs->end()) {
      refs->erase(j);
    }
  }

  void _threadUnsafeSetStrongAssociation(id object, void *key, id value) {
    if (value) {
      auto i = _associationMap->find(object);
      ObjectAssociationSet *refs;
      if (i != _associationMap->end()) {
        refs = i->second;
      } else {
        refs = new ObjectAssociationSet;
        (*_associationMap)[object] = refs;
      }
      refs->insert(key);
    } else {
      _threadUnsafeResetAssociationAtKey(object, key);
    }
  }

  void _threadUnsafeRemoveAssociations(id object) {
    if (_associationMap->size() == 0 ){
      return;
    }

    auto i = _associationMap->find(object);
    if (i == _associationMap->end()) {
      return;
    }

    auto *refs = i->second;
    delete refs;
    _associationMap->erase(i);
  }

  NSArray *associations(id object) {
    std::lock_guard<std::mutex> l(*_associationMutex);
    if (_associationMap->size() == 0 ){
      return nil;
    }

    auto i = _associationMap->find(object);
    if (i == _associationMap->end()) {
      return nil;
    }

    auto *refs = i->second;

    NSMutableArray *array = [NSMutableArray array];
    for (auto &key: *refs) {
      id value = objc_getAssociatedObject(object, key);
      if (value) {
        [array addObject:value];
      }
    }

    return array;
  }

  static void (*fb_orig_objc_setAssociatedObject)(id object, void *key, id value, objc_AssociationPolicy policy);
  static void (*fb_orig_objc_removeAssociatedObjects)(id object);

  static void fb_objc_setAssociatedObject(id object, void *key, id value, objc_AssociationPolicy policy) {
    {
      std::lock_guard<std::mutex> l(*_associationMutex);
      // Track strong references only
      if (policy == OBJC_ASSOCIATION_RETAIN ||
          policy == OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        _threadUnsafeSetStrongAssociation(object, key, value);
      } else {
        // We can change the policy, we need to clear out the key
        _threadUnsafeResetAssociationAtKey(object, key);
      }
    }

    /**
     We are doing that behind the lock. Otherwise it could deadlock.
     The reason for that is when objc calls up _object_set_associative_reference, when we nil out
     a reference for some object, it will also release this value, which could cause it to dealloc.
     This is done inside _object_set_associative_reference without lock. Otherwise it would deadlock,
     since the object that is released, could also clean up some associated objects.
     
     If we would keep a lock during that, we would fall for that deadlock.
     
     Unfortunately this also means the association manager can be not a 100% accurate, since there
     can technically be a race condition between setting values on the same object and same key from
     different threads. (One thread sets value, other nil, we are missing this value)
     */
    fb_orig_objc_setAssociatedObject(object, key, value, policy);
  }

  static void fb_objc_removeAssociatedObjects(id object) {
    {
      std::lock_guard<std::mutex> l(*_associationMutex);
      _threadUnsafeRemoveAssociations(object);
    }
    
    fb_orig_objc_removeAssociatedObjects(object);
  }

  static void cleanUp() {
    std::lock_guard<std::mutex> l(*_associationMutex);
    _associationMap->clear();
  }

} }

#endif

@implementation _FBAssociationManager

+ (void)hook
{
#if _INTERNAL_RCD_ENABLED
  std::lock_guard<std::mutex> l(*_FB::AssociationManager::hookMutex);
  rebind_symbols((struct rebinding[2]){
    {
      "objc_setAssociatedObject",
      (void *)_FB::AssociationManager::fb_objc_setAssociatedObject,
      (void **)&_FB::AssociationManager::fb_orig_objc_setAssociatedObject
    },
    {
      "objc_removeAssociatedObjects",
      (void *)_FB::AssociationManager::fb_objc_removeAssociatedObjects,
      (void **)&_FB::AssociationManager::fb_orig_objc_removeAssociatedObjects
    }}, 2);
  _FB::AssociationManager::hookTaken = true;
#endif //_INTERNAL_RCD_ENABLED
}

+ (void)unhook
{
#if _INTERNAL_RCD_ENABLED
  std::lock_guard<std::mutex> l(*_FB::AssociationManager::hookMutex);
  if (_FB::AssociationManager::hookTaken) {
    rebind_symbols((struct rebinding[2]){
      {
        "objc_setAssociatedObject",
        (void *)_FB::AssociationManager::fb_orig_objc_setAssociatedObject,
      },
      {
        "objc_removeAssociatedObjects",
        (void *)_FB::AssociationManager::fb_orig_objc_removeAssociatedObjects,
      }}, 2);
    _FB::AssociationManager::cleanUp();
  }
#endif //_INTERNAL_RCD_ENABLED
}

+ (NSArray *)associationsForObject:(id)object
{
#if _INTERNAL_RCD_ENABLED
  return _FB::AssociationManager::associations(object);
#else
  return nil;
#endif //_INTERNAL_RCD_ENABLED
}

@end
