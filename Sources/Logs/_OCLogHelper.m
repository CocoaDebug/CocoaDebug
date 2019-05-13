//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "_OCLogHelper.h"
#import "_OCLogModel.h"
#import "_OCLogStoreManager.h"

@implementation _OCLogHelper

+ (instancetype)shared
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

//default value for @property
- (id)init {
    if (self = [super init])  {
        self.enable = YES;
    }
    return self;
}

- (NSString *)parseFileInfo:(NSString *)file function:(NSString *)function line:(NSInteger)line
{
    if ([file isEqualToString:@"TCP"] && [function isEqualToString:@"TCP"] && line == 1) {
        return @"TCP|TCP|1";
    }
    
    if (line == 0) {
        NSString *fileName = [[file componentsSeparatedByString:@"/"] lastObject];
        return [NSString stringWithFormat:@"%@ %@\n", fileName, function];
    }
    
    NSString *fileName = [[file componentsSeparatedByString:@"/"] lastObject];
    return [NSString stringWithFormat:@"%@[%ld]%@\n", fileName, (long)line, function];
}

- (void)handleLogWithFile:(NSString *)file function:(NSString *)function line:(NSInteger)line message:(NSString *)message color:(UIColor *)color
{
    if (!self.enable) {
        return;
    }
    
    //1.
    NSString *fileInfo = [self parseFileInfo:file function:function line:line];
    
    //2.
    _OCLogModel *newLog = [[_OCLogModel alloc] initWithContent:message color:color fileInfo:fileInfo isTag:NO];
    if (line == 0 && ![fileInfo isEqualToString:@"TCP|TCP|1"]) {
        newLog.h5LogType = H5LogTypeNotNone;
    }
    [[_OCLogStoreManager shared] addLog:newLog];
    
    //3.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshLogs_CocoaDebug" object:nil userInfo:nil];
}

@end
