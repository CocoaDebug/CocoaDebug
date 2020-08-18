//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "_FBObjectReference.h"

/**
 _Struct object is an Objective-C object that is created inside
 a struct. In Objective-C++ that object will be retained
 by an object owning the struct, therefore will be listed in
 ivar layout for the class.
 */

@interface _FBObjectInStructReference : NSObject <_FBObjectReference>

- (nonnull instancetype)initWithIndex:(NSUInteger)index
                             namePath:(nullable NSArray<NSString *> *)namePath;

@end
