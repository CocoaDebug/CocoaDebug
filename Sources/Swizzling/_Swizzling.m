//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_Swizzling.h"

IMP replaceMethod(SEL selector, IMP newImpl, Class affectedClass, BOOL isClassMethod) {
    Method origMethod = isClassMethod ? class_getClassMethod(affectedClass, selector) : class_getInstanceMethod(affectedClass, selector);
    IMP origImpl = method_getImplementation(origMethod);

    if (!class_addMethod(isClassMethod ? object_getClass(affectedClass) : affectedClass, selector, newImpl, method_getTypeEncoding(origMethod))) {
        method_setImplementation(origMethod, newImpl);
    }

    return origImpl;
}
