//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_FBClassStrongLayout.h"

#import <math.h>
#import <memory>
#import <objc/runtime.h>
#import <vector>

#import <UIKit/UIKit.h>

#import "_FBIvarReference.h"
#import "_FBObjectInStructReference.h"
#import "_FBStructEncodingParser.h"
#import "_Struct.h"
#import "_Type.h"

/**
 If we stumble upon a struct, we need to go through it and check if it doesn't retain some objects.
 */
static NSArray *_FBGetReferencesForObjectsInStructEncoding(_FBIvarReference *ivar, std::string encoding) {
  NSMutableArray<_FBObjectInStructReference *> *references = [NSMutableArray new];

  std::string ivarName = std::string([ivar.name cStringUsingEncoding:NSUTF8StringEncoding]);
  _FB::RetainCycleDetector::Parser::_Struct parsed_Struct =
  _FB::RetainCycleDetector::Parser::parse_StructEncodingWithName(encoding, ivarName);
  
  std::vector<std::shared_ptr<_FB::RetainCycleDetector::Parser::_Type>> types = parsed_Struct.flatten_Types();
  
  ptrdiff_t offset = ivar.offset;
  
  for (auto &type: types) {
    NSUInteger size, align;

    std::string typeEncoding = type->typeEncoding;
    if (typeEncoding[0] == '^') {
      // It's a pointer, let's skip
      size = sizeof(void *);
      align = _Alignof(void *);
    } else {
      @try {
        NSGetSizeAndAlignment(typeEncoding.c_str(),
                              &size,
                              &align);
      } @catch (NSException *e) {
        /**
         If we failed, we probably have C++ and ObjC cannot get it's size and alignment. We are skipping.
         If we would like to support it, we would need to derive size and alignment of type from the string.
         C++ does not have reflection so we can't really do that unless we create the mapping ourselves.
         */
        break;
      }
    }


    // The object must be aligned
    NSUInteger overAlignment = offset % align;
    NSUInteger whatsMissing = (overAlignment == 0) ? 0 : align - overAlignment;
    offset += whatsMissing;

    if (typeEncoding[0] == '@') {
    
      // The index that ivar layout will ask for is going to be aligned with pointer size

      // Prepare additional context
      NSString *typeEncodingName = [NSString stringWithCString:type->name.c_str() encoding:NSUTF8StringEncoding];
      
      NSMutableArray *namePath = [NSMutableArray new];
      
      for (auto &name: type->typePath) {
        NSString *nameString = [NSString stringWithCString:name.c_str() encoding:NSUTF8StringEncoding];
        if (nameString) {
          [namePath addObject:nameString];
        }
      }
      
      if (typeEncodingName) {
        [namePath addObject:typeEncodingName];
      }
      [references addObject:[[_FBObjectInStructReference alloc] initWithIndex:(offset / sizeof(void *))
                                                                    namePath:namePath]];
    }

    offset += size;
  }

  return references;
}

NSArray<id<_FBObjectReference>> *_FBGetClassReferences(Class aCls) {
  NSMutableArray<id<_FBObjectReference>> *result = [NSMutableArray new];

  unsigned int count;
  Ivar *ivars = class_copyIvarList(aCls, &count);

  for (unsigned int i = 0; i < count; ++i) {
    Ivar ivar = ivars[i];
    _FBIvarReference *wrapper = [[_FBIvarReference alloc] initWithIvar:ivar];

    if (wrapper.type == _FBStruct_Type) {
      std::string encoding = std::string(ivar_getTypeEncoding(wrapper.ivar));
      NSArray<_FBObjectInStructReference *> *references = _FBGetReferencesForObjectsInStructEncoding(wrapper, encoding);

      [result addObjectsFromArray:references];
    } else {
      [result addObject:wrapper];
    }
  }
  free(ivars);

  return [result copy];
}

static NSIndexSet *_FBGetLayoutAsIndexesForDescription(NSUInteger minimumIndex, const uint8_t *layoutDescription) {
  NSMutableIndexSet *interestingIndexes = [NSMutableIndexSet new];
  NSUInteger currentIndex = minimumIndex;

  while (*layoutDescription != '\x00') {
    int upperNibble = (*layoutDescription & 0xf0) >> 4;
    int lowerNibble = *layoutDescription & 0xf;

    // Upper nimble is for skipping
    currentIndex += upperNibble;

    // Lower nimble describes count
    [interestingIndexes addIndexesInRange:NSMakeRange(currentIndex, lowerNibble)];
    currentIndex += lowerNibble;

    ++layoutDescription;
  }

  return interestingIndexes;
}

static NSUInteger _FBGetMinimumIvarIndex(__unsafe_unretained Class aCls) {
  NSUInteger minimumIndex = 1;
  unsigned int count;
  Ivar *ivars = class_copyIvarList(aCls, &count);

  if (count > 0) {
    Ivar ivar = ivars[0];
    ptrdiff_t offset = ivar_getOffset(ivar);
    minimumIndex = offset / (sizeof(void *));
  }

  free(ivars);

  return minimumIndex;
}

static NSArray<id<_FBObjectReference>> *_FBGetStrongReferencesForClass(Class aCls) {
  NSArray<id<_FBObjectReference>> *ivars = [_FBGetClassReferences(aCls) filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
    if ([evaluatedObject isKindOfClass:[_FBIvarReference class]]) {
      _FBIvarReference *wrapper = evaluatedObject;
      return wrapper.type != _FBUnknown_Type;
    }
    return YES;
  }]];

  const uint8_t *fullLayout = class_getIvarLayout(aCls);

  if (!fullLayout) {
    return nil;
  }

  NSUInteger minimumIndex = _FBGetMinimumIvarIndex(aCls);
  NSIndexSet *parsedLayout = _FBGetLayoutAsIndexesForDescription(minimumIndex, fullLayout);

  NSArray<id<_FBObjectReference>> *filteredIvars =
  [ivars filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<_FBObjectReference> evaluatedObject,
                                                                           NSDictionary *bindings) {
    return [parsedLayout containsIndex:[evaluatedObject indexInIvarLayout]];
  }]];

  return filteredIvars;
}

NSArray<id<_FBObjectReference>> *_FBGetObjectStrongReferences(id obj,
                                                            NSMutableDictionary<Class, NSArray<id<_FBObjectReference>> *> *layoutCache) {
  NSMutableArray<id<_FBObjectReference>> *array = [NSMutableArray new];

  __unsafe_unretained Class previousClass = nil;
  __unsafe_unretained Class currentClass = object_getClass(obj);

  while (previousClass != currentClass) {
    NSArray<id<_FBObjectReference>> *ivars;
    
    ivars = layoutCache[currentClass];
    
    if (!ivars) {
      ivars = _FBGetStrongReferencesForClass(currentClass);
      if (layoutCache && currentClass) {
        layoutCache[currentClass] = ivars;
      }
    }
    [array addObjectsFromArray:ivars];

    previousClass = currentClass;
    currentClass = class_getSuperclass(currentClass);
  }

  return [array copy];
}
