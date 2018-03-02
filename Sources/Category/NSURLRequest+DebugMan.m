//
//  NSURLRequest+DebugMan.m
//  DebugMan
//
//  Created by liman on 21/01/2018.
//  Copyright © 2018 liman. All rights reserved.
//

#import "NSURLRequest+DebugMan.h"
#import <objc/runtime.h>

@implementation NSURLRequest (DebugMan)

- (NSString *)requestId {
    return objc_getAssociatedObject(self, @"requestId");
}

- (void)setRequestId:(NSString *)requestId {
    objc_setAssociatedObject(self, @"requestId", requestId, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSNumber*)startTime {
    return objc_getAssociatedObject(self, @"startTime");
}

- (void)setStartTime:(NSNumber*)startTime {
    objc_setAssociatedObject(self, @"startTime", startTime, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
