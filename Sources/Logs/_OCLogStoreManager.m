//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "_OCLogStoreManager.h"
#import "_NetworkHelper.h"

@implementation _OCLogStoreManager

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
        self.defaultLogArray = [NSMutableArray arrayWithCapacity:[[_NetworkHelper shared] logMaxCount]];
        self.colorLogArray = [NSMutableArray arrayWithCapacity:[[_NetworkHelper shared] logMaxCount]];
        self.h5LogArray = [NSMutableArray arrayWithCapacity:[[_NetworkHelper shared] logMaxCount]];
    }
    return self;
}

- (void)addLog:(_OCLogModel *)log
{
    if (log.h5LogType == H5LogTypeNone)
    {
        if (log.color == [UIColor whiteColor] || log.color == nil)
        {
            //白色
            if ([self.defaultLogArray count] >= [[_NetworkHelper shared] logMaxCount]) {
                if (self.defaultLogArray.count > 0) {
                    [self.defaultLogArray removeObjectAtIndex:0];
                }
            }
            [self.defaultLogArray addObject:log];
        }
        else
        {
            //彩色
            if ([self.colorLogArray count] >= [[_NetworkHelper shared] logMaxCount]) {
                if (self.colorLogArray.count > 0) {
                    [self.colorLogArray removeObjectAtIndex:0];
                }
            }
            [self.colorLogArray addObject:log];
        }
    }
    else
    {
        //H5
        if ([self.h5LogArray count] >= [[_NetworkHelper shared] logMaxCount]) {
            if (self.h5LogArray.count > 0) {
                [self.h5LogArray removeObjectAtIndex:0];
            }
        }
        [self.h5LogArray addObject:log];
    }
}

- (void)removeLog:(_OCLogModel *)log
{
    if (log.h5LogType == H5LogTypeNone)
    {
        if (log.color == [UIColor whiteColor] || log.color == nil) {
            //白色
            [self.defaultLogArray removeObject:log];
        }else{
            //彩色
            [self.colorLogArray removeObject:log];
        }
    }
    else
    {
        //H5
        [self.h5LogArray removeObject:log];
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

- (void)resetH5Logs
{
    [self.h5LogArray removeAllObjects];
}

@end
