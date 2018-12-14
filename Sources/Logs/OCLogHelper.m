//
//  OCLogHelper.m
//  Example_Objc
//
//  Created by man on 2018/12/14.
//  Copyright © 2018年 liman. All rights reserved.
//

#import "OCLogHelper.h"

@implementation OCLogHelper

+ (instancetype)shared
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (NSString *)parseFileInfo:(NSString *)file function:(NSString *)function line:(NSInteger)line
{
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

}

@end
