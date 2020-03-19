//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_NSObject+CocoaDebug.h"
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
    objc_setAssociatedObject(self, @"startTime", startTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

/*************************************************/

@implementation UIColor (CocoaDebug)

+ (UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end

/*************************************************/

@implementation NSDictionary (CocoaDebug)

- (NSString *)_stringForKey:(id<NSCopying>)key {
    id obj = [self objectForKey:key];
    if (![obj isKindOfClass:[NSString class]]) {
        return nil;
    }
    return obj;
}

- (NSArray *)_arrayForKey:(id<NSCopying>)key {
    id obj = [self objectForKey:key];
    if (![obj isKindOfClass:[NSArray class]]) {
        return nil;
    }
    return obj;
}

- (NSDictionary *)_dictionaryForKey:(id<NSCopying>)key {
    id obj = [self objectForKey:key];
    if (![obj isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return obj;
}

- (NSInteger)_integerForKey:(id<NSCopying>)key {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [((NSNumber *)obj) integerValue];
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return [((NSString *)obj) integerValue];
    }
    return 0;
}

- (int64_t)_int64ForKey:(id<NSCopying>)key {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [((NSNumber *)obj) longLongValue];
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return [((NSString *)obj) longLongValue];
    }
    return 0;
}

- (int32_t)_int32ForKey:(id<NSCopying>)key {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [((NSNumber *)obj) intValue];
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return [((NSString *)obj) intValue];
    }
    return 0;
}

- (float)_floatForKey:(id<NSCopying>)key {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [((NSNumber *)obj) floatValue];
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return [((NSString *)obj) floatValue];
    }
    return 0;
}

- (double)_doubleForKey:(id<NSCopying>)key {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [((NSNumber *)obj) doubleValue];
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return [((NSString *)obj) doubleValue];
    }
    return 0;
}

- (BOOL)_boolForKey:(id<NSCopying>)key {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [((NSNumber *)obj) boolValue];
    }
    if ([obj isKindOfClass:[NSString class]]) {
        return [((NSString *)obj) boolValue];
    }
    return NO;
}

- (NSString *)_stringForKey:(id<NSCopying>)key default:(NSString * _Nullable)defaultValue {
    id obj = [self objectForKey:key];
    
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    return defaultValue;
}

- (bool)_boolForKey:(id<NSCopying>)key default:(bool)defaultValue {
    id obj = [self objectForKey:key];
    
    if ([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]]) {
        return [obj boolValue];
    }
    return defaultValue;
}

- (NSInteger)_integerForKey:(id<NSCopying>)key default:(NSInteger)defaultValue {
    id obj = [self objectForKey:key];
    
    if ([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]]) {
        return [obj integerValue];
    }
    return defaultValue;
}

- (float)_floatForKey:(id<NSCopying>)key default:(float)defaultValue {
    id obj = [self objectForKey:key];
    
    if ([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSString class]]) {
        return [obj floatValue];
    }
    return defaultValue;
}

- (NSArray *)_arrayForKey:(id<NSCopying>)key default:(NSArray * _Nullable)defaultValue {
    id obj = [self objectForKey:key];
    
    if ([obj isKindOfClass:[NSArray class]]) {
        return obj;
    }
    return defaultValue;
}

- (NSDictionary *)_dictionaryForKey:(id<NSCopying>)key default:(NSDictionary * _Nullable)defaultValue {
    id obj = [self objectForKey:key];
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return obj;
    }
    return defaultValue;
}

@end
