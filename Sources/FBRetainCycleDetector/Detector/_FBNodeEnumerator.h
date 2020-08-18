//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

@class _FBObjectiveCGraphElement;

/**
 _FBNodeEnumerator wraps any object graph element (_FBObjectiveCGraphElement) and lets you enumerate over its
 retained references
 */
@interface _FBNodeEnumerator : NSEnumerator

/**
 Designated initializer
 */
- (nonnull instancetype)initWithObject:(nonnull _FBObjectiveCGraphElement *)object;

- (nullable _FBNodeEnumerator *)nextObject;

@property (nonatomic, strong, readonly, nonnull) _FBObjectiveCGraphElement *object;

@end
