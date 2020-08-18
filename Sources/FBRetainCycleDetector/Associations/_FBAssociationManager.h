//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 _FBAssociationManager is a tracker of object associations. For given object it can return all objects that
 are being retained by this object with objc_setAssociatedObject & retain policy.
 */
@interface _FBAssociationManager : NSObject

/**
 Start tracking associations. It will use fishhook to swizzle C methods:
 objc_(set/remove)AssociatedObject and inject some tracker code.
 */
+ (void)hook;

/**
 Stop tracking associations, fishhooks.
 */
+ (void)unhook;

/**
 For given object return all objects that are retained by it using associated objects.

 @return NSArray of objects associated with given object
 */
+ (nullable NSArray *)associationsForObject:(nullable id)object;

@end
