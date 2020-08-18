//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <objc/runtime.h>

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 Returns object on given index for obj in its ivar layout.
 It will try to map the object to an Objective-C object, so if the index
 is invalid it will crash with BAD_ACCESS.

 It cannot be called under ARC.
 */
id _FBExtractObjectByOffset(id obj, NSUInteger index);

#ifdef __cplusplus
}
#endif
