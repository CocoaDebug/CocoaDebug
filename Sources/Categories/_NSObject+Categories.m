//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "_NSObject+Categories.h"
#import <objc/runtime.h>

/*************************************************/

@implementation NSData (_Categories)

+ (NSData *)dataWithInputStream:(NSInputStream *)stream
{
    NSMutableData * data = [NSMutableData data];
    [stream open];
    NSInteger result;
    uint8_t buffer[1024]; // BUFFER_LEN can be any positive integer
    
    while((result = [stream read:buffer maxLength:1024]) != 0) {
        if(result > 0) {
            // buffer contains result bytes of data to be handled
            [data appendBytes:buffer length:result];
        } else {
            // The stream had an error. You can get an NSError object using [iStream streamError]
            if (result<0) {
//                [NSException raise:@"STREAM_ERROR" format:@"%@", [stream streamError]];
                return nil;//liman
            }
        }
    }
    return data;
}

@end

/*************************************************/

@implementation NSString (_Categories)

- (CGFloat)heightWithFont:(UIFont *)font constraintToWidth:(CGFloat)width
{
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil];
    
    return rect.size.height;
}

+ (NSString *)unicodeToChinese:(NSString *)unicodeStr
{
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2]stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *returnStr = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}

@end

/*************************************************/

@implementation NSURLRequest (_Categories)

- (NSString *)requestId {
    return objc_getAssociatedObject(self, @"requestId");
}

- (void)setRequestId:(NSString *)requestId {
    objc_setAssociatedObject(self, @"requestId", requestId, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSNumber*)startTime {
    return objc_getAssociatedObject(self, @"startTime");
}

- (void)setStartTime:(NSNumber*)startTime {
    objc_setAssociatedObject(self, @"startTime", startTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

/*************************************************/

@implementation UIColor (_Categories)

+ (UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end

