//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_OCLogModel.h"

@interface _OCLogStoreManager : NSObject

// Read-only snapshot accessors. The internal mutable arrays are private.
@property (nonatomic, strong, readonly) NSMutableArray<_OCLogModel *> *normalLogArray;
@property (nonatomic, strong, readonly) NSMutableArray<_OCLogModel *> *rnLogArray;
@property (nonatomic, strong, readonly) NSMutableArray<_OCLogModel *> *webLogArray;

+ (instancetype)shared;

- (void)addLog:(_OCLogModel *)log;
- (void)removeLog:(_OCLogModel *)log;

- (void)resetNormalLogs;
- (void)resetRNLogs;
- (void)resetWebLogs;

/// Thread-safe snapshot: returns a copy of the current log arrays via callback on main queue.
- (void)snapshotWithCompletion:(void (^)(NSArray<_OCLogModel *> *normalLogs,
                                          NSArray<_OCLogModel *> *rnLogs,
                                          NSArray<_OCLogModel *> *webLogs))completion;

@end
