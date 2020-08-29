//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSet(_LeaksFinder)

//是否开启所有属性的检查
- (BOOL)continueCheckObjecClass:(Class)objectClass;

@end

