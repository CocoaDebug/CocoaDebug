//
//  OCLoggerFormat.m
//  Example_Swift
//
//  Created by man on 2018/12/14.
//  Copyright © 2018年 liman. All rights reserved.
//

#import "OCLoggerFormat.h"

@implementation OCLoggerFormat

+ (NSString *)formatDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone systemTimeZone];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    return [formatter stringFromDate:date];
}

@end
