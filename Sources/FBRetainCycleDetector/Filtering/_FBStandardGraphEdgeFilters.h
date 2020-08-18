//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "_FBObjectGraphConfiguration.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 Standard filters mostly filters excluding some UIKit references we have caught during testing on some apps.
 */
NSArray<_FBGraphEdgeFilterBlock> *_Nonnull _FBGetStandardGraphEdgeFilters();

/**
 Helper functions for some typical patterns.
 */
_FBGraphEdgeFilterBlock _Nonnull _FBFilterBlockWithObjectIvarRelation(Class _Nonnull aCls,
                                                                    NSString *_Nonnull ivarName);
_FBGraphEdgeFilterBlock _Nonnull _FBFilterBlockWithObjectToManyIvarsRelation(Class _Nonnull aCls,
                                                                           NSSet<NSString *> *_Nonnull ivarNames);
_FBGraphEdgeFilterBlock _Nonnull _FBFilterBlockWithObjectIvarObjectRelation(Class _Nonnull fromClass,
                                                                          NSString *_Nonnull ivarName,
                                                                          Class _Nonnull toClass);

#ifdef __cplusplus
}
#endif
