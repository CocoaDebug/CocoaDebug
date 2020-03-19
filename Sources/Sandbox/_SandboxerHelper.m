//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_SandboxerHelper.h"

@implementation _SandboxerHelper

+ (NSDateFormatter *)fileModificationDateFormatter {
    static NSDateFormatter *_fileModificationDateFormatter;
    if (!_fileModificationDateFormatter) {
        _fileModificationDateFormatter = [[NSDateFormatter alloc] init];
        _fileModificationDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    }
    
    return _fileModificationDateFormatter;
}

#pragma mark - Public Methods

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (NSString *)fileModificationDateTextWithDate:(NSDate *)date {
    if (!date) { return @""; }
    return [[_SandboxerHelper fileModificationDateFormatter] stringFromDate:date];
}

//liman

//Get Folder Size
+ (NSString *)sizeOfFolder:(NSString *)folderPath {
    //Calculate Folder Size with only files
    //    NSArray *folderContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    
    //Calculate Folder Size with other sub directories in the folder
    NSArray *folderContents = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:nil];
    
    __block unsigned long long int folderSize = 0;
    
    [folderContents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:obj] error:nil];
        folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
    }];
    NSString *folderSizeStr = [NSByteCountFormatter stringFromByteCount:folderSize countStyle:NSByteCountFormatterCountStyleFile];
    return folderSizeStr;
}

//Get File Size
+ (NSString *)sizeOfFile:(NSString *)filePath {
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    NSInteger fileSize = [[fileAttributes objectForKey:NSFileSize] integerValue];
    NSString *fileSizeString = [NSByteCountFormatter stringFromByteCount:fileSize countStyle:NSByteCountFormatterCountStyleFile];
    return fileSizeString;
}

#pragma mark - tool
+ (NSString *)generateRandomId {
    UInt64 time = [[NSDate date] timeIntervalSince1970] * 1000;
    return [NSString stringWithFormat:@"%llu_%@", time, [self generateRandomString]];
}

+ (NSString *)generateRandomString {
    char data[10];
    for (int x = 0; x < 10; ++x) {
        data[x] = (char)('A' + (arc4random_uniform(26)));
    }
    return [[NSString alloc] initWithBytes:data length:10 encoding:NSUTF8StringEncoding];
}

@end
