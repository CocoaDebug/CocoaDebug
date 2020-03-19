//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _SandboxerHelper : NSObject

+ (NSString *)fileModificationDateTextWithDate:(NSDate *)date;

//liman

//Get Folder Size
+ (NSString *)sizeOfFolder:(NSString *)folderPath;
//Get File Size
+ (NSString *)sizeOfFile:(NSString *)filePath;

+ (instancetype)sharedInstance;

+ (NSString *)generateRandomId;

@property (nonatomic, strong) NSMutableDictionary<NSString*, NSString*> *searchTextDictionary;

@end
