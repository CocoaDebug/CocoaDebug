//
//  NSURLRequest+Identify.h
//  Pods
//
//  Created by Peter on 16/1/23.
//
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (Identify)

- (NSString *)requestId;
- (void)setRequestId:(NSString *)requestId;


- (NSNumber*)startTime;
- (void)setStartTime:(NSNumber*)startTime;
@end
