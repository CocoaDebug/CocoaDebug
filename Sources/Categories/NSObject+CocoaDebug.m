//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "NSObject+CocoaDebug.h"
#import <objc/runtime.h>
#import <ImageIO/ImageIO.h>

/*************************************************/

@implementation NSData (CocoaDebug)

+ (NSData *)dataWithInputStream:(NSInputStream *)stream
{
    NSMutableData * data = [NSMutableData data];
    [stream open];
    NSInteger result;
    uint8_t buffer[1024]; // BUFFER_LEN can be any positive integer
    
    while((result = [stream read:buffer maxLength:1024]) != 0) {
        if (result > 0) {
            // buffer contains result bytes of data to be handled
            [data appendBytes:buffer length:result];
        } else {
            // The stream had an error. You can get an NSError object using [iStream streamError]
            if (result < 0) {
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

/*************************************************/

@implementation UIImage (CocoaDebug)

/** 根据一个GIF图片的data数据 获得GIF image对象 */
+ (UIImage *_Nullable)imageWithGIFData:(NSData *_Nullable)data {
    if (!data) return nil;
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    size_t count = CGImageSourceGetCount(source);
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
        
    } else {
        
        NSMutableArray *images = [NSMutableArray array];
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < count; i++) {
            
            // 拿出了Gif的每一帧图片
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            
            //Learning... 设置动画时长 算出每一帧显示的时长(帧时长)
            NSTimeInterval frameDuration = [UIImage ssz_frameDurationAtIndex:i source:source];
            
            duration += frameDuration;
            
            // 将每帧图片添加到数组中
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            // 释放真图片对象
            CFRelease(image);
        }
        
        // 设置动画时长
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    // 释放源Gif图片
    CFRelease(source);
    
    return animatedImage;
}

/** 根据本地GIF图片名 获得GIF image对象 */
+ (UIImage *_Nullable)imageWithGIFNamed:(NSString *_Nullable)name {
    NSUInteger scale = (NSUInteger)[UIScreen mainScreen].scale;
    return [self GIFName:name scale:scale];
}

+ (UIImage *)GIFName:(NSString *)name scale:(NSUInteger)scale {
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@@%zdx", name, scale] ofType:@"gif"];
    
    if (!imagePath) {
        (scale + 1 > 3) ? (scale -= 1) : (scale += 1);
        imagePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@@%zdx", name, scale] ofType:@"gif"];
    }
    
    if (imagePath) {
        // 传入图片名(不包含@Nx)
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        return [UIImage imageWithGIFData:imageData];
        
    } else {
        
        imagePath = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
        
        if (imagePath) {
            // 传入的图片名已包含@Nx or 传入图片只有一张 不分@Nx
            NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
            return [UIImage imageWithGIFData:imageData];
            
        } else {
            // 不是一张GIF图片(后缀不是gif)
            return [UIImage imageNamed:name];
        }
    }
}

/** 根据一个GIF图片的URL 获得GIF image对象 */
+ (void)imageWithGIFUrl:(NSString *_Nullable)url gifImageBlock:(void(^_Nullable)(UIImage *_Nullable gifImage))gifImageBlock {
    NSURL *GIFUrl = [NSURL URLWithString:url];
    
    if (!GIFUrl) return;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *CIFData = [NSData dataWithContentsOfURL:GIFUrl];
        
        // 刷新UI在主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            gifImageBlock([UIImage imageWithGIFData:CIFData]);
        });
    });
}

//关于GIF图片帧时长
+ (float)ssz_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
        
    } else {
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See and
    // for more information.
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    
    return frameDuration;
}

@end
