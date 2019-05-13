//
//  SandboxerHelper.m
//  Example
//
//  Created by meilbn on 18/07/2017.
//  Copyright © 2017 meilbn. All rights reserved.
//

#import "SandboxerHelper.h"

@implementation SandboxerHelper

+ (NSDateFormatter *)fileModificationDateFormatter {
    static NSDateFormatter *_fileModificationDateFormatter;
    if (!_fileModificationDateFormatter) {
        _fileModificationDateFormatter = [[NSDateFormatter alloc] init];
        _fileModificationDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    
    return _fileModificationDateFormatter;
}

#pragma mark - Public Methods

+ (NSString *)fileModificationDateTextWithDate:(NSDate *)date {
    if (!date) { return @""; }
    return [[SandboxerHelper fileModificationDateFormatter] stringFromDate:date];
}

@end
