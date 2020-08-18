//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol _LeakedObjectProxyDelegate <NSObject>

- (void)retainCycle;

@end

@interface _LeakedObjectProxy : NSObject <_LeakedObjectProxyDelegate>

+ (BOOL)isAnyObjectLeakedAtPtrs:(NSSet *)ptrs;
+ (void)addLeakedObject:(id)object;

@end
