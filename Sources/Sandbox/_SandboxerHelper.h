//
//  CocoaDebug
//  liman
//
//  Created by liman 02/02/2023.
//  Copyright © 2023 liman. All rights reserved.
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
