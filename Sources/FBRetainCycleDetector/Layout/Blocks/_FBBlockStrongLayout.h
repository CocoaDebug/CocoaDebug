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

/**
 Returns an array of id<_FBObjectReference> objects that will have only those references
 that are retained by block.
 */
NSArray *_Nullable _FBGetBlockStrongReferences(void *_Nonnull block);

BOOL _FBObjectIsBlock(void *_Nullable object);
  
#ifdef __cplusplus
}
#endif
