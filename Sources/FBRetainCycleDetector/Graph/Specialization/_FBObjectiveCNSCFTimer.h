//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "_FBObjectiveCObject.h"

/**
 Specialization of _FBObjectiveCObject for NSTimer.
 Standard methods that _FBObjectiveCObject uses will not fetch us all objects retained by NSTimer.
 One good example is target of NSTimer.
 */
@interface _FBObjectiveCNSCFTimer : _FBObjectiveCObject
@end
