//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

@protocol _FBObjectReference;
/**
 @return An array of id<_FBObjectReference> objects that will have *all* references
 the object has (also not retained ivars, structs etc.)
 */
NSArray<id<_FBObjectReference>> *_Nonnull _FBGetClassReferences(__unsafe_unretained Class _Nullable aCls);

/**
 @return An array of id<_FBObjectReference> objects that will have only those references
 that are retained by the object. It also goes through parent classes.
 */
NSArray<id<_FBObjectReference>> *_Nonnull _FBGetObjectStrongReferences(id _Nullable obj,
                                                                     NSMutableDictionary<Class, NSArray<id<_FBObjectReference>> *> *_Nullable layoutCache);

#ifdef __cplusplus
}
#endif
