//
//  OCLogStoreManager.h
//  Example_Swift
//
//  Created by man on 2018/12/14.
//  Copyright © 2018年 liman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCLogModel.h"

@interface OCLogStoreManager : NSObject

@property (nonatomic, strong) NSMutableArray<OCLogModel *> *defaultLogArray;
@property (nonatomic, strong) NSMutableArray<OCLogModel *> *colorLogArray;

+ (instancetype)shared;

- (void)addLog:(OCLogModel *)log;
- (void)removeLog:(OCLogModel *)log;
- (void)resetDefaultLogs;
- (void)resetColorLogs;

@end

