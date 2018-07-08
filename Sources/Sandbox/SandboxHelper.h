//
//  CocoaDebug.swift
//  demo
//
//  Created by CocoaDebug on 26/11/2017.
//  Copyright © 2018 CocoaDebug. All rights reserved.
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
