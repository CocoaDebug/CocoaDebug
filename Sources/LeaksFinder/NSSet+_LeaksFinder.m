//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "NSSet+_LeaksFinder.h"

@implementation NSSet(_LeaksFinder)

//是否开启所有属性的检查
- (void)willReleaseIvarList {
    if (!self.count) {
        return;
    }

    id obj;

    NSEnumerator * enumerator = [self objectEnumerator];
    while (obj = [enumerator nextObject]) {
        [obj willReleaseIvarList];
    }
}

- (BOOL)continueCheckObjecClass:(Class)objectClass {
    return YES;
}

@end
