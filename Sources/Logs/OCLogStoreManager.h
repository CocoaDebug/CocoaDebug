//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCLogModel.h"

@interface OCLogStoreManager : NSObject

@property (nonatomic, strong) NSMutableArray<OCLogModel *> *defaultLogArray;
@property (nonatomic, strong) NSMutableArray<OCLogModel *> *colorLogArray;
@property (nonatomic, strong) NSMutableArray<OCLogModel *> *h5LogArray;

+ (instancetype)shared;

- (void)addLog:(OCLogModel *)log;
- (void)removeLog:(OCLogModel *)log;

- (void)resetDefaultLogs;
- (void)resetColorLogs;
- (void)resetH5Logs;

@end

