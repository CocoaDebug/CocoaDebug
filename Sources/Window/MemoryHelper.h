//
//  CocoaDebug.swift
//  demo
//
//  Created by CocoaDebug on 26/11/2017.
//  Copyright © 2018 CocoaDebug. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemoryHelper : NSObject

+ (instancetype)shared;

- (NSString *)appUsedMemoryAndPercentage;
- (NSString *)appUsedMemoryAndFreeMemory;

@end
