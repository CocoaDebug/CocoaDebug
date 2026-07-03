//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_HttpModel.h"

@interface _HttpDatasource : NSObject

/// Read-only for backward compatibility. Prefer snapshotWithCompletion: for thread safety.
@property (nonatomic, strong, readonly) NSMutableArray<_HttpModel *> *httpModels;

+ (instancetype)shared;

- (BOOL)addHttpRequset:(_HttpModel*)model;
- (void)reset;
- (void)remove:(_HttpModel *)model;
- (void)removeAtIndex:(NSUInteger)index;

/// Thread-safe snapshot callback on main queue.
- (void)snapshotWithCompletion:(void (^)(NSArray<_HttpModel *> *models))completion;

@end
