//
//  CocoaDebug.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemoryHelper : NSObject

+ (instancetype)shared;

- (NSString *)appUsedMemoryAndPercentage;
- (NSString *)appUsedMemoryAndFreeMemory;

@end
