//
//  NSURLResponse+Data.m
//  Pods
//
//  Created by Peter on 16/1/23.
//
//

#import "NSURLResponse+Data.h"
#import <objc/runtime.h>

@implementation NSURLResponse (Data)

- (NSData *)responseData {
    return objc_getAssociatedObject(self, @"responseData");
}

- (void)setResponseData:(NSData *)responseData {
    objc_setAssociatedObject(self, @"responseData", responseData, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
