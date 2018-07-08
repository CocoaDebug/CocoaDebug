//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*************************************************/

@interface NSData (CocoaDebug)

+ (NSData *)dataWithInputStream:(NSInputStream *)stream;

@end

/*************************************************/

@interface NSString (CocoaDebug)

- (CGFloat)heightWithFont:(UIFont *)font constraintToWidth:(CGFloat)width;

@end

/*************************************************/

@interface NSURLRequest (CocoaDebug)

- (NSString *)requestId;
- (void)setRequestId:(NSString *)requestId;

- (NSNumber*)startTime;
- (void)setStartTime:(NSNumber*)startTime;

@end
