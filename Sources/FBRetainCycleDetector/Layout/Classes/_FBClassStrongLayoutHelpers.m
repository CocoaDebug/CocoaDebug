//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#if __has_feature(objc_arc)
#error This file must be compiled with MRR. Use -fno-objc-arc flag.
#endif

#import "_FBClassStrongLayoutHelpers.h"

id _FBExtractObjectByOffset(id obj, NSUInteger index) {
  id *idx = (id *)((uintptr_t)obj + (index * sizeof(void *)));

  return *idx;
}
