//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_OCLogModel.h"

@interface _OCLogStoreManager : NSObject

@property (nonatomic, strong) NSMutableArray<_OCLogModel *> *defaultLogArray;
@property (nonatomic, strong) NSMutableArray<_OCLogModel *> *colorLogArray;
@property (nonatomic, strong) NSMutableArray<_OCLogModel *> *webLogArray;

+ (instancetype)shared;

- (void)addLog:(_OCLogModel *)log;
- (void)removeLog:(_OCLogModel *)log;

- (void)resetDefaultLogs;
- (void)resetColorLogs;
- (void)resetWebLogs;

@end

