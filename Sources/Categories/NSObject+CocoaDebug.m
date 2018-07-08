//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "NSObject+CocoaDebug.h"
#import <objc/runtime.h>

/*************************************************/

@implementation NSData (CocoaDebug)

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

@implementation NSString (CocoaDebug)

- (CGFloat)heightWithFont:(UIFont *)font constraintToWidth:(CGFloat)width
{
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil];
    
    return rect.size.height;
}

@end

/*************************************************/

@implementation NSURLRequest (CocoaDebug)

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
    objc_setAssociatedObject(self, @"startTime", startTime, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

