//
//  DotzuX.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (DotzuX)

- (NSString *)requestId;
- (void)setRequestId:(NSString *)requestId;

- (NSNumber*)startTime;
- (void)setStartTime:(NSNumber*)startTime;

@end
