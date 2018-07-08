//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "HttpDatasource.h"
#import "NetworkHelper.h"

@implementation HttpDatasource

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
        _httpModels = [NSMutableArray array];
        _httpModelRequestIds = [NSMutableArray array];
    }
    return self;
}

- (BOOL)addHttpRequset:(HttpModel*)model
{
    //url过滤, 忽略大小写
    for (NSString *urlString in [NetworkHelper shared].ignoredURLs) {
        if ([[model.url.absoluteString lowercaseString] containsString:[urlString lowercaseString]]) {
            return NO;
        }
    }
    
    if (self.httpModels.count >= [NetworkHelper shared].logMaxCount) {
        if ([self.httpModels count] > 0) {
            [self.httpModels removeObjectAtIndex:0];
        }
    }
    [self.httpModels addObject:model];

    if (self.httpModelRequestIds.count >= [NetworkHelper shared].logMaxCount) {
        if ([self.httpModelRequestIds count] > 0) {
            [self.httpModelRequestIds removeObjectAtIndex:0];
        }
    }
    if (model.requestId && [model.requestId length] > 0) {
        [self.httpModelRequestIds addObject:model.requestId];
    }
    
    return YES;
}

- (void)reset
{
    [self.httpModels removeAllObjects];
    [self.httpModelRequestIds removeAllObjects];
}

- (void)remove:(HttpModel *)model
{
    if ([[self.httpModels copy] containsObject:model]) {
        [self.httpModels removeObject:model];
    }

    if ([[self.httpModelRequestIds copy] containsObject:model.requestId]) {
        [self.httpModelRequestIds removeObject:model.requestId];
    }
}

@end
