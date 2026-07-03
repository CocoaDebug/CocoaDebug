//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import "_OCLogStoreManager.h"
#import "_NetworkHelper.h"

static const NSUInteger kMaxLogCount = 2000;

@interface _OCLogStoreManager ()
@property (nonatomic, strong) NSMutableArray<_OCLogModel *> *internalNormalLogArray;
@property (nonatomic, strong) NSMutableArray<_OCLogModel *> *internalRNLogArray;
@property (nonatomic, strong) NSMutableArray<_OCLogModel *> *internalWebLogArray;
@property (nonatomic, strong) dispatch_queue_t storeQueue;
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
        _internalNormalLogArray = [NSMutableArray arrayWithCapacity:kMaxLogCount + 100];
        _internalRNLogArray = [NSMutableArray arrayWithCapacity:kMaxLogCount + 100];
        _internalWebLogArray = [NSMutableArray arrayWithCapacity:kMaxLogCount + 100];
        _storeQueue = dispatch_queue_create("com.cocoadebug.logstore", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

// Provide read-only access to the internal arrays for backward compatibility.
// Callers should prefer snapshotWithCompletion: for thread safety.
- (NSMutableArray *)normalLogArray { return _internalNormalLogArray; }
- (NSMutableArray *)rnLogArray { return _internalRNLogArray; }
- (NSMutableArray *)webLogArray { return _internalWebLogArray; }

- (void)addLog:(_OCLogModel *)log
{
    if (![log.content isKindOfClass:[NSString class]]) { return; }
    if (!log) { return; }

    // Capture filter values outside the queue to avoid potential deadlock.
    NSArray *onlyPrefixLogs = [[_NetworkHelper shared].onlyPrefixLogs copy];
    NSArray *ignoredPrefixLogs = [[_NetworkHelper shared].ignoredPrefixLogs copy];

    // Filter on the calling thread (fast-path rejection before queuing)
    if (onlyPrefixLogs.count > 0) {
        BOOL matchesAny = NO;
        for (NSString *prefixStr in onlyPrefixLogs) {
            if ([log.content hasPrefix:prefixStr]) {
                matchesAny = YES;
                break;
            }
        }
        if (!matchesAny) { return; }
    }
    for (NSString *prefixStr in ignoredPrefixLogs) {
        if ([log.content hasPrefix:prefixStr]) {
            return;
        }
    }

    dispatch_async(self.storeQueue, ^{
        if (log.logType == CocoaDebugLogTypeNormal) {
            if (self.internalNormalLogArray.count >= kMaxLogCount) {
                if (self.internalNormalLogArray.count > 0) {
                    [self.internalNormalLogArray removeObjectAtIndex:0];
                }
            }
            [self.internalNormalLogArray addObject:log];
        }
        else if (log.logType == CocoaDebugLogTypeRN) {
            if (self.internalRNLogArray.count >= kMaxLogCount) {
                if (self.internalRNLogArray.count > 0) {
                    [self.internalRNLogArray removeObjectAtIndex:0];
                }
            }
            [self.internalRNLogArray addObject:log];
        }
        else {
            if (self.internalWebLogArray.count >= kMaxLogCount) {
                if (self.internalWebLogArray.count > 0) {
                    [self.internalWebLogArray removeObjectAtIndex:0];
                }
            }
            [self.internalWebLogArray addObject:log];
        }
    });
}

- (void)removeLog:(_OCLogModel *)log
{
    if (!log) { return; }
    dispatch_async(self.storeQueue, ^{
        // FIXED: was CocoaDebugLogTypeNormal duplicated (copy-paste bug).
        // RN branch was dead code; web branch would incorrectly catch RN logs.
        if (log.logType == CocoaDebugLogTypeNormal) {
            [self.internalNormalLogArray removeObject:log];
        }
        else if (log.logType == CocoaDebugLogTypeRN) {
            [self.internalRNLogArray removeObject:log];
        }
        else {
            [self.internalWebLogArray removeObject:log];
        }
    });
}

- (void)resetNormalLogs
{
    dispatch_async(self.storeQueue, ^{
        [self.internalNormalLogArray removeAllObjects];
    });
}

- (void)resetRNLogs
{
    dispatch_async(self.storeQueue, ^{
        [self.internalRNLogArray removeAllObjects];
    });
}

- (void)resetWebLogs
{
    dispatch_async(self.storeQueue, ^{
        [self.internalWebLogArray removeAllObjects];
    });
}

- (void)snapshotWithCompletion:(void (^)(NSArray<_OCLogModel *> *normalLogs,
                                          NSArray<_OCLogModel *> *rnLogs,
                                          NSArray<_OCLogModel *> *webLogs))completion
{
    if (!completion) { return; }
    dispatch_async(self.storeQueue, ^{
        NSArray *normalCopy = [self.internalNormalLogArray copy];
        NSArray *rnCopy = [self.internalRNLogArray copy];
        NSArray *webCopy = [self.internalWebLogArray copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(normalCopy, rnCopy, webCopy);
        });
    });
}

@end
