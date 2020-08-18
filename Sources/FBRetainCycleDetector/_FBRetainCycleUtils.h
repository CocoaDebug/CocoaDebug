//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

@class _FBObjectGraphConfiguration;
@class _FBObjectiveCGraphElement;

#ifdef __cplusplus
extern "C" {
#endif

/**
 Wrapper functions, for given object they will categorize it and create proper Graph Element subclass instance
 for it.
 */
_FBObjectiveCGraphElement *_Nullable _FBWrapObjectGraphElementWithContext(_FBObjectiveCGraphElement *_Nullable sourceElement,
                                                                        id _Nullable object,
                                                                        _FBObjectGraphConfiguration *_Nullable configuration,
                                                                        NSArray<NSString *> *_Nullable namePath);
_FBObjectiveCGraphElement *_Nullable _FBWrapObjectGraphElement(_FBObjectiveCGraphElement *_Nullable sourceElement,
                                                             id _Nullable object,
                                                             _FBObjectGraphConfiguration *_Nullable configuration);

#ifdef __cplusplus
}
#endif
