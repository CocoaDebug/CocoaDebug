//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "SandboxHelper.h"

@implementation SandboxHelper

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
    return [[SandboxHelper fileModificationDateFormatter] stringFromDate:date];
}

#pragma mark - liman

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

@end
