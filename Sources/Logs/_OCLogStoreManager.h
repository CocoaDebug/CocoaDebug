//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_OCLogModel.h"

@interface _OCLogStoreManager : NSObject

@property (nonatomic, strong) NSMutableArray<_OCLogModel *> *defaultLogArray;
@property (nonatomic, strong) NSMutableArray<_OCLogModel *> *colorLogArray;
@property (nonatomic, strong) NSMutableArray<_OCLogModel *> *h5LogArray;

+ (instancetype)shared;

- (void)addLog:(_OCLogModel *)log;
- (void)removeLog:(_OCLogModel *)log;

- (void)resetDefaultLogs;
- (void)resetColorLogs;
- (void)resetH5Logs;

@end

