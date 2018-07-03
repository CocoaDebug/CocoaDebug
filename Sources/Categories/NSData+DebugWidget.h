//
//  DebugWidget.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (DebugWidget)

+ (NSData *)debugWidget_dataWithInputStream:(NSInputStream *)stream;

@end
