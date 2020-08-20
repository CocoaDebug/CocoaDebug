//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_LeakedObjectProxy.h"
#import "_LeaksMessenger.h"
#import "NSObject+_LeaksFinder.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "FBRetainCycleDetector.h"

static NSMutableSet *leakedObjectPtrs;

@interface _LeakedObjectProxy ()
@property (nonatomic, weak) id object;
@property (nonatomic, strong) NSNumber *objectPtr;
@property (nonatomic, strong) NSArray *viewStack;
@end

@implementation _LeakedObjectProxy

+ (BOOL)isAnyObjectLeakedAtPtrs:(NSSet *)ptrs {
    NSAssert([NSThread isMainThread], @"Must be in main thread.");
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        leakedObjectPtrs = [[NSMutableSet alloc] init];
    });
    
    if (!ptrs.count) {
        return NO;
    }
    if ([leakedObjectPtrs intersectsSet:ptrs]) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)addLeakedObject:(id)object {
    NSAssert([NSThread isMainThread], @"Must be in main thread.");
    
    _LeakedObjectProxy *proxy = [[_LeakedObjectProxy alloc] init];
    proxy.object = object;
    proxy.objectPtr = @((uintptr_t)object);
    proxy.viewStack = [object viewStack];
    static const void *const kLeakedObjectProxyKey = &kLeakedObjectProxyKey;
    objc_setAssociatedObject(object, kLeakedObjectProxyKey, proxy, OBJC_ASSOCIATION_RETAIN);
    
    [leakedObjectPtrs addObject:proxy.objectPtr];
    
    [_LeaksMessenger alertWithTitle:@"Memory Leak"
                            message:[NSString stringWithFormat:@"%@", proxy.viewStack]
                           delegate:proxy
              additionalButtonTitle:@"Retain Cycle"];
}

- (void)dealloc {
    NSNumber *objectPtr = _objectPtr;
    NSArray *viewStack = _viewStack;
    dispatch_async(dispatch_get_main_queue(), ^{
        [leakedObjectPtrs removeObject:objectPtr];
        [_LeaksMessenger alertWithTitle:@"Object Deallocated"
                                message:[NSString stringWithFormat:@"%@", viewStack]];
    });
}

#pragma mark - _LeakedObjectProxyDelegate

- (void)retainCycle {
    id object = self.object;
    if (!object) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        FBRetainCycleDetector *detector = [FBRetainCycleDetector new];
        [detector addCandidate:self.object];
        NSSet *retainCycles = [detector findRetainCyclesWithMaxCycleLength:20];
        
        BOOL hasFound = NO;
        for (NSArray *retainCycle in retainCycles) {
            NSInteger index = 0;
            for (FBObjectiveCGraphElement *element in retainCycle) {
                if (element.object == object) {
                    NSArray *shiftedRetainCycle = [self shiftArray:retainCycle toIndex:index];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_LeaksMessenger alertWithTitle:@"Retain Cycle"
                                                message:[NSString stringWithFormat:@"%@", shiftedRetainCycle]];
                    });
                    hasFound = YES;
                    break;
                }
                
                ++index;
            }
            if (hasFound) {
                break;
            }
        }
        if (!hasFound) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_LeaksMessenger alertWithTitle:@"Retain Cycle"
                                        message:@"Fail to find a retain cycle"];
            });
        }
    });
}

- (NSArray *)shiftArray:(NSArray *)array toIndex:(NSInteger)index {
    if (index == 0) {
        return array;
    }
    
    NSRange range = NSMakeRange(index, array.count - index);
    NSMutableArray *result = [[array subarrayWithRange:range] mutableCopy];
    [result addObjectsFromArray:[array subarrayWithRange:NSMakeRange(0, index)]];
    return result;
}

@end
