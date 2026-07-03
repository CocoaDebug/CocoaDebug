//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import "_HttpDatasource.h"
#import "_NetworkHelper.h"

static const NSUInteger kMaxHttpModelCount = 2000;

@interface _HttpDatasource ()
@property (nonatomic, strong) NSMutableArray<_HttpModel *> *internalHttpModels;
@property (nonatomic, strong) dispatch_queue_t storeQueue;
@end

@implementation _HttpDatasource

+ (instancetype)shared
{
    static id sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.internalHttpModels = [NSMutableArray arrayWithCapacity:kMaxHttpModelCount + 100];
        self.storeQueue = dispatch_queue_create("com.cocoadebug.httpdatasource", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (NSMutableArray *)httpModels { return _internalHttpModels; }

- (BOOL)addHttpRequset:(_HttpModel*)model
{
    if (!model) { return NO; }
    if (!model.url || [model.url.absoluteString isEqualToString:@""]) {
        return NO;
    }

    // Filter on calling thread before queuing
    NSArray *ignoredURLs = [[_NetworkHelper shared].ignoredURLs copy];
    for (NSString *urlString in ignoredURLs) {
        if (urlString.length == 0) { continue; }
        if ([[model.url.absoluteString lowercaseString] containsString:[urlString lowercaseString]]) {
            return NO;
        }
    }

    dispatch_async(self.storeQueue, ^{
        // Maximum number limit
        if (self.internalHttpModels.count >= kMaxHttpModelCount) {
            if (self.internalHttpModels.count > 0) {
                [self.internalHttpModels removeObjectAtIndex:0];
            }
        }

        // Dedup by requestId
        __block BOOL isExist = NO;
        NSString *requestId = model.requestId ?: @"";
        if (requestId.length > 0) {
            [self.internalHttpModels enumerateObjectsUsingBlock:^(_HttpModel *obj, NSUInteger index, BOOL *stop) {
                if ([obj.requestId isEqualToString:requestId]) {
                    isExist = YES;
                    *stop = YES;
                }
            }];
        }
        if (!isExist) {
            [self.internalHttpModels addObject:model];
        }
    });

    return YES;
}

- (void)reset
{
    dispatch_async(self.storeQueue, ^{
        [self.internalHttpModels removeAllObjects];
    });
}

- (void)remove:(_HttpModel *)model
{
    if (!model) { return; }
    dispatch_async(self.storeQueue, ^{
        NSString *requestId = model.requestId ?: @"";
        if (requestId.length == 0) { return; }
        [self.internalHttpModels enumerateObjectsWithOptions:NSEnumerationReverse
                                                  usingBlock:^(_HttpModel *obj, NSUInteger index, BOOL *stop) {
            if ([obj.requestId isEqualToString:requestId]) {
                [self.internalHttpModels removeObjectAtIndex:index];
                *stop = YES;
            }
        }];
    });
}

- (void)removeAtIndex:(NSUInteger)index
{
    dispatch_async(self.storeQueue, ^{
        if (index < self.internalHttpModels.count) {
            [self.internalHttpModels removeObjectAtIndex:index];
        }
    });
}

- (void)snapshotWithCompletion:(void (^)(NSArray<_HttpModel *> *models))completion
{
    if (!completion) { return; }
    dispatch_async(self.storeQueue, ^{
        NSArray *copy = [self.internalHttpModels copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(copy);
        });
    });
}

@end
