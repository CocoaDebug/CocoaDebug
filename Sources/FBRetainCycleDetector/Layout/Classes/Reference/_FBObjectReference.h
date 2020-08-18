//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Defines an outgoing reference from Objective-C object.
 */

@protocol _FBObjectReference <NSObject>

/**
 What is the index of that reference in ivar layout?
 index * sizeof(void *) gives you offset from the
 beginning of the object.
 */
- (NSUInteger)indexInIvarLayout;

/**
 For given object we need to be able to grab that object reference.
 */
- (nullable id)objectReferenceFromObject:(nullable id)object;


/**
 For given reference in an object, there can be a path of names that leads to it.
 For example it can be an ivar, thus the path will consist of ivar name only:
 @[@"_myIvar"]

 But it also can be a reference in some nested struct like:
 struct Some_Struct {
   NSObject *myObject;
 };

 If that struct will be used in class, then name path would look like this:
 @[@"_myIvar", @"Some_Struct", @"myObject"]
 */
- (nullable NSArray<NSString *> *)namePath;

@end
