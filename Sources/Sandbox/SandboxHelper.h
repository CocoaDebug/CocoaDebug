//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SandboxHelper : NSObject

+ (NSString *)fileModificationDateTextWithDate:(NSDate *)date;

//liman

//Get Folder Size
+ (NSString *)sizeOfFolder:(NSString *)folderPath;
//Get File Size
+ (NSString *)sizeOfFile:(NSString *)filePath;

@end
