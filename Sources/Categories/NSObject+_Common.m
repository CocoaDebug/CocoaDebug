//
//  NSObject+Common.m
//  AirPayCounter
//
//  Created by HuiCao on 2019/4/17.
//  Copyright © 2019 Shopee. All rights reserved.
//

#import "NSObject+_Common.h"

@implementation NSDictionary (_Common)

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
