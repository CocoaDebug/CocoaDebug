//
//  OCLogStoreManager.m
//  Example_Swift
//
//  Created by man on 2018/12/14.
//  Copyright © 2018年 liman. All rights reserved.
//

#import "OCLogStoreManager.h"
#import "NetworkHelper.h"

@implementation OCLogStoreManager

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
        self.defaultLogArray = [NSMutableArray arrayWithCapacity:[[NetworkHelper shared] logMaxCount]];
        self.colorLogArray = [NSMutableArray arrayWithCapacity:[[NetworkHelper shared] logMaxCount]];
    }
    return self;
}

- (void)addLog:(OCLogModel *)log
{
    if (log.color == [UIColor whiteColor] || log.color == nil)
    {
        //白色
        if ([self.defaultLogArray count] >= [[NetworkHelper shared] logMaxCount]) {
            if (self.defaultLogArray.count > 0) {
                [self.defaultLogArray removeObjectAtIndex:0];
            }
        }
        [self.defaultLogArray addObject:log];
    }
    else //////////////////////////////////////////////////////
    {
        //彩色
        if ([self.colorLogArray count] >= [[NetworkHelper shared] logMaxCount]) {
            if (self.colorLogArray.count > 0) {
                [self.colorLogArray removeObjectAtIndex:0];
            }
        }
        [self.colorLogArray addObject:log];
    }
}

- (void)removeLog:(OCLogModel *)log
{
    if (log.color == [UIColor whiteColor] || log.color == nil)
    {
        //白色
        [self.defaultLogArray removeObject:log];
    }
    else
    {
        //彩色
        [self.colorLogArray removeObject:log];
    }
}

- (void)resetDefaultLogs
{
    [self.defaultLogArray removeAllObjects];
}

- (void)resetColorLogs
{
    [self.colorLogArray removeAllObjects];
}

@end
