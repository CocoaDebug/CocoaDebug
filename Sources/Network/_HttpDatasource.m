//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import "_HttpDatasource.h"
#import "_NetworkHelper.h"

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
        self.httpModels = [NSMutableArray arrayWithCapacity:1000 + 100];
    }
    return self;
}

- (BOOL)addHttpRequset:(_HttpModel*)model
{
    if ([model.url.absoluteString isEqualToString:@""]) {
        return NO;
    }
    
    
    //url Filter, ignore case
    for (NSString *urlString in [[_NetworkHelper shared] ignoredURLs]) {
        if ([[model.url.absoluteString lowercaseString] containsString:[urlString lowercaseString]]) {
            return NO;
        }
    }
    
    //Maximum number limit
    if (self.httpModels.count >= 1000) {
        if ([self.httpModels count] > 0) {
            [self.httpModels removeObjectAtIndex:0];
        }
    }
    
    //detect repeated
    __block BOOL isExist = NO;
    [self.httpModels enumerateObjectsUsingBlock:^(_HttpModel *obj, NSUInteger index, BOOL *stop) {
        if ([obj.requestId isEqualToString:model.requestId]) {
            isExist = YES;
        }
    }];
    if (!isExist) {
        [self.httpModels addObject:model];
    } else {
        return NO;
    }
    
    return YES;
}

- (void)reset
{
    [self.httpModels removeAllObjects];
}

- (void)remove:(_HttpModel *)model
{
    [self.httpModels enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(_HttpModel *obj, NSUInteger index, BOOL *stop) {
        if ([obj.requestId isEqualToString:model.requestId]) {
            [self.httpModels removeObjectAtIndex:index];
        }
    }];
}

@end
