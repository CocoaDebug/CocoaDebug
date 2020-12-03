//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_OCLogStoreManager.h"
#import "_NetworkHelper.h"

@interface _OCLogStoreManager ()
{
    dispatch_semaphore_t semaphore;
}
@end

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
        semaphore = dispatch_semaphore_create(1);
        
        self.normalLogArray = [NSMutableArray arrayWithCapacity:[[_NetworkHelper shared] logMaxCount]];
        self.rnLogArray = [NSMutableArray arrayWithCapacity:[[_NetworkHelper shared] logMaxCount]];
        self.webLogArray = [NSMutableArray arrayWithCapacity:[[_NetworkHelper shared] logMaxCount]];
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
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (log.logType == CocoaDebugLogTypeNormal)
    {
        //normal
        if ([self.normalLogArray count] >= [[_NetworkHelper shared] logMaxCount]) {
            if (self.normalLogArray.count > 0) {
                [self.normalLogArray removeObjectAtIndex:0];
            }
        }
        
        [self.normalLogArray addObject:log];
    }
    else if (log.logType == CocoaDebugLogTypeRN)
    {
        //rn
        if ([self.rnLogArray count] >= [[_NetworkHelper shared] logMaxCount]) {
            if (self.rnLogArray.count > 0) {
                [self.rnLogArray removeObjectAtIndex:0];
            }
        }
        
        [self.rnLogArray addObject:log];
    }
    else
    {
        //web
        if ([self.webLogArray count] >= [[_NetworkHelper shared] logMaxCount]) {
            if (self.webLogArray.count > 0) {
                [self.webLogArray removeObjectAtIndex:0];
            }
        }
        
        [self.webLogArray addObject:log];
    }
    
    dispatch_semaphore_signal(semaphore);
}

- (void)removeLog:(_OCLogModel *)log
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
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
    
    dispatch_semaphore_signal(semaphore);
}

- (void)resetNormalLogs
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self.normalLogArray removeAllObjects];
    dispatch_semaphore_signal(semaphore);
}

- (void)resetRNLogs
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self.rnLogArray removeAllObjects];
    dispatch_semaphore_signal(semaphore);
}

- (void)resetWebLogs
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self.webLogArray removeAllObjects];
    dispatch_semaphore_signal(semaphore);
}

@end
