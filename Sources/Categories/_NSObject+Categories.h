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

@interface NSData (_Categories)

+ (NSData *)dataWithInputStream:(NSInputStream *)stream;

@end

/*************************************************/

@interface NSString (_Categories)

- (CGFloat)heightWithFont:(UIFont *)font constraintToWidth:(CGFloat)width;

+ (NSString *)unicodeToChinese:(NSString *)unicodeStr;

@end

/*************************************************/

@interface NSURLRequest (_Categories)

- (NSString *)requestId;
- (void)setRequestId:(NSString *)requestId;

- (NSNumber*)startTime;
- (void)setStartTime:(NSNumber*)startTime;

@end

/*************************************************/

@interface UIColor (_Categories)

+ (UIColor *)colorFromHexString:(NSString *)hexString;

@end
