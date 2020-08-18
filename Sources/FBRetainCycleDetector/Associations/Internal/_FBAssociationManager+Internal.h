//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_FBAssociationManager.h"
#import "_FBRetainCycleDetector.h"

#if _INTERNAL_RCD_ENABLED

namespace _FB { namespace AssociationManager {

  void _threadUnsafeResetAssociationAtKey(id object, void *key);
  void _threadUnsafeSetStrongAssociation(id object, void *key, id value);
  void _threadUnsafeRemoveAssociations(id object);

  NSArray *associations(id object);

} }

#endif
