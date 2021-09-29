//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
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
        self.normalLogArray = [NSMutableArray arrayWithCapacity:1000 + 100];
        self.rnLogArray = [NSMutableArray arrayWithCapacity:1000 + 100];
        self.webLogArray = [NSMutableArray arrayWithCapacity:1000 + 100];
    }
    return self;
}

- (void)addLog:(_OCLogModel *)log
{
    if (![log.content isKindOfClass:[NSString class]]) {return;}
    
    //log过滤, 忽略大小写
    for (NSString *prefixStr in [_NetworkHelper shared].onlyPrefixLogs) {
        if (![log.content hasPrefix:prefixStr]) {
            return;
        }
    }
    //log过滤, 忽略大小写
    for (NSString *prefixStr in [_NetworkHelper shared].ignoredPrefixLogs) {
        if ([log.content hasPrefix:prefixStr]) {
            return;
        }
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    if (log.logType == CocoaDebugLogTypeNormal)
    {
        //normal
        if ([self.normalLogArray count] >= 1000) {
            if (self.normalLogArray.count > 0) {
                [self.normalLogArray removeObjectAtIndex:0];
            }
        }
        
        [self.normalLogArray addObject:log];
    }
    else if (log.logType == CocoaDebugLogTypeRN)
    {
        //rn
        if ([self.rnLogArray count] >= 1000) {
            if (self.rnLogArray.count > 0) {
                [self.rnLogArray removeObjectAtIndex:0];
            }
        }
        
        [self.rnLogArray addObject:log];
    }
    else
    {
        //web
        if ([self.webLogArray count] >= 1000) {
            if (self.webLogArray.count > 0) {
                [self.webLogArray removeObjectAtIndex:0];
            }
        }
        
        [self.webLogArray addObject:log];
    }
}

- (void)removeLog:(_OCLogModel *)log
{
    if (log.logType == CocoaDebugLogTypeNormal)
    {
        //normal
        [self.normalLogArray removeObject:log];
    }
    else if (log.logType == CocoaDebugLogTypeNormal)
    {
        //rn
        [self.rnLogArray removeObject:log];
    }
    else
    {
        //web
        [self.webLogArray removeObject:log];
    }
}

- (void)resetNormalLogs
{
    [self.normalLogArray removeAllObjects];
}

- (void)resetRNLogs
{
    [self.rnLogArray removeAllObjects];
}

- (void)resetWebLogs
{
    [self.webLogArray removeAllObjects];
}

@end
