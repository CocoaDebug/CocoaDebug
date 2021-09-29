//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import "_OCLogHelper.h"
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
//- (id)init {
//    if (self = [super init])  {
//        self.enable = YES;
//    }
//    return self;
//}

- (NSString *)parseFileInfo:(NSString *)file function:(NSString *)function line:(NSInteger)line
{
    if (![file isKindOfClass:[NSString class]] || ![function isKindOfClass:[NSString class]]) {
        return @"\n";
    }
    
    if ([file isEqualToString:@"XXX"] && [function isEqualToString:@"XXX"] && line == 1) {
        return @"XXX|XXX|1";
    }
    
    if (line == 0) { //web
        NSString *fileName = [[file componentsSeparatedByString:@"/"] lastObject] ?: @"";
        return [NSString stringWithFormat:@"%@ %@\n", fileName, function];
    }
    
    if (line == 999999999) { //nslog
        NSString *fileName = [[file componentsSeparatedByString:@"/"] lastObject] ?: @"";
        return [NSString stringWithFormat:@"%@ %@\n", fileName, function];
    }
    
    if (line == -1) { //RN
        return file;
    }
    
    NSString *fileName = [[file componentsSeparatedByString:@"/"] lastObject] ?: @"";
    return [NSString stringWithFormat:@"%@[%ld]%@\n", fileName, (long)line, function];
}

- (void)handleLogWithFile:(NSString *)file function:(NSString *)function line:(NSInteger)line message:(NSString *)message color:(UIColor *)color type:(CocoaDebugToolType)type
{
//    if (!self.enable && type != CocoaDebugToolTypeRN) {return;}
    if (!file || !function || !message || !color) {return;}
    
    //1.
    NSString *fileInfo = [self parseFileInfo:file function:function line:line];
    
    //2.
    _OCLogModel *newLog = [[_OCLogModel alloc] initWithContent:message color:color fileInfo:fileInfo isTag:NO type:type];
    
    //    if (line == 0 && ![fileInfo isEqualToString:@"XXX|XXX|1"]) {
    //        newLog.logType = CocoaDebugLogType...
    //    }
    
    if (type == CocoaDebugToolTypeRN) {
        newLog.logType = CocoaDebugLogTypeRN;
    }
    
    if ([file isEqualToString:@"[WKWebView]"]) {
        newLog.logType = CocoaDebugLogTypeWeb;
    }
    
    [[_OCLogStoreManager shared] addLog:newLog];
    
    //3.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshLogs_CocoaDebug" object:nil userInfo:nil];
}

@end
