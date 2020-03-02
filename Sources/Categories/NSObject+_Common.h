//
//  NSObject+Common.h
//  AirPayCounter
//
//  Created by HuiCao on 2019/4/17.
//  Copyright © 2019 Shopee. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (_Common)

- (NSString *)_stringForKey:(id<NSCopying>)key;
- (NSArray *)_arrayForKey:(id<NSCopying>)key;
- (NSDictionary *)_dictionaryForKey:(id<NSCopying>)key;
- (NSInteger)_integerForKey:(id<NSCopying>)key;
- (int64_t)_int64ForKey:(id<NSCopying>)key;
- (int32_t)_int32ForKey:(id<NSCopying>)key;
- (float)_floatForKey:(id<NSCopying>)key;
- (double)_doubleForKey:(id<NSCopying>)key;
- (BOOL)_boolForKey:(id<NSCopying>)key;

- (NSString *)_stringForKey:(id<NSCopying>)key default:(NSString * _Nullable)defaultValue;
- (bool)_boolForKey:(id<NSCopying>)key default:(bool)defaultValue;
- (NSInteger)_integerForKey:(id<NSCopying>)key default:(NSInteger)defaultValue;
- (float)_floatForKey:(id<NSCopying>)key default:(float)defaultValue;
- (NSArray *)_arrayForKey:(id<NSCopying>)key default:(NSArray * _Nullable)defaultValue;
- (NSDictionary *)_dictionaryForKey:(id<NSCopying>)key default:(NSDictionary * _Nullable)defaultValue;

@end

NS_ASSUME_NONNULL_END
