//
//  NSURLRequest+DebugMan.h
//  DebugMan
//
//  Created by liman on 21/01/2018.
//  Copyright © 2018 liman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (DebugMan)

- (NSString *)requestId;
- (void)setRequestId:(NSString *)requestId;

- (NSNumber*)startTime;
- (void)setStartTime:(NSNumber*)startTime;

@end
