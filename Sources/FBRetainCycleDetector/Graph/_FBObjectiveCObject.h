//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "_FBObjectiveCGraphElement.h"

@class _FBGraphEdgeFilterProvider;

/**
 _FBObjectiveCGraphElement specialization that can gather all references kept in ivars, as part of collection
 etc.
 */
@interface _FBObjectiveCObject : _FBObjectiveCGraphElement
@end
