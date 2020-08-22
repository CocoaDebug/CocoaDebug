//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*************************************************/

@interface NSData (CocoaDebug)

+ (NSData *_Nullable)dataWithInputStream:(NSInputStream *_Nullable)stream;

@end

/*************************************************/

@interface NSString (CocoaDebug)

- (CGFloat)heightWithFont:(UIFont *_Nullable)font constraintToWidth:(CGFloat)width;

@end

/*************************************************/

@interface NSURLRequest (CocoaDebug)

- (NSString *_Nullable)requestId;
- (void)setRequestId:(NSString *_Nullable)requestId;

- (NSNumber*_Nullable)startTime;
- (void)setStartTime:(NSNumber*_Nullable)startTime;

@end

/*************************************************/

@interface UIColor (CocoaDebug)

+ (UIColor *_Nullable)colorFromHexString:(NSString *_Nullable)hexString;

@end

/*************************************************/

@interface NSDictionary (CocoaDebug)

- (NSString *_Nullable)_stringForKey:(id<NSCopying>_Nullable)key;
- (NSArray *_Nullable)_arrayForKey:(id<NSCopying>_Nullable)key;
- (NSDictionary *_Nullable)_dictionaryForKey:(id<NSCopying>_Nullable)key;
- (NSInteger)_integerForKey:(id<NSCopying>_Nullable)key;
- (int64_t)_int64ForKey:(id<NSCopying>_Nullable)key;
- (int32_t)_int32ForKey:(id<NSCopying>_Nullable)key;
- (float)_floatForKey:(id<NSCopying>_Nullable)key;
- (double)_doubleForKey:(id<NSCopying>_Nullable)key;
- (BOOL)_boolForKey:(id<NSCopying>_Nullable)key;

- (NSString *_Nullable)_stringForKey:(id<NSCopying>_Nullable)key default:(NSString * _Nullable)defaultValue;
- (bool)_boolForKey:(id<NSCopying>_Nullable)key default:(bool)defaultValue;
- (NSInteger)_integerForKey:(id<NSCopying>_Nullable)key default:(NSInteger)defaultValue;
- (float)_floatForKey:(id<NSCopying>_Nullable)key default:(float)defaultValue;
- (NSArray *_Nullable)_arrayForKey:(id<NSCopying>_Nullable)key default:(NSArray * _Nullable)defaultValue;
- (NSDictionary *_Nullable)_dictionaryForKey:(id<NSCopying>_Nullable)key default:(NSDictionary * _Nullable)defaultValue;

@end

/*************************************************/

@interface UIImage (CocoaDebug)

/** 根据一个GIF图片的data数据 获得GIF image对象 */
+ (UIImage *_Nullable)imageWithGIFData:(NSData *_Nullable)data;

/** 根据本地GIF图片名 获得GIF image对象 */
+ (UIImage *_Nullable)imageWithGIFNamed:(NSString *_Nullable)name;

/** 根据一个GIF图片的URL 获得GIF image对象 */
+ (void)imageWithGIFUrl:(NSString *_Nullable)url gifImageBlock:(void(^_Nullable)(UIImage *_Nullable gifImage))gifImageBlock;

@end
