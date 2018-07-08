//
//  CocoaDebug.swift
//  demo
//
//  Created by CocoaDebug on 26/11/2017.
//  Copyright © 2018 CocoaDebug. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (CocoaDebug)

- (NSString *)requestId;
- (void)setRequestId:(NSString *)requestId;

- (NSNumber*)startTime;
- (void)setStartTime:(NSNumber*)startTime;

@end
