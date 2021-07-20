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

@property (nonatomic, strong) NSMutableArray<_OCLogModel *> *normalLogArray;
@property (nonatomic, strong) NSMutableArray<_OCLogModel *> *rnLogArray;
@property (nonatomic, strong) NSMutableArray<_OCLogModel *> *webLogArray;

+ (instancetype)shared;

- (void)addLog:(_OCLogModel *)log;
- (void)removeLog:(_OCLogModel *)log;

- (void)resetNormalLogs;
- (void)resetRNLogs;
- (void)resetWebLogs;

@end

