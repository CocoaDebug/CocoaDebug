//
//  CocoaDebug
//  liman
//
//  Created by liman 02/02/2023.
//  Copyright © 2023 liman. All rights reserved.
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

