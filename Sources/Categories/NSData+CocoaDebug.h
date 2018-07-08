//
//  CocoaDebug.swift
//  demo
//
//  Created by CocoaDebug on 26/11/2017.
//  Copyright © 2018 CocoaDebug. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (CocoaDebug)

+ (NSData *)cocoaDebug_dataWithInputStream:(NSInputStream *)stream;

@end
