//
//  _GPBMessage+CocoaDebug.m
//  AirPayCounter
//
//  Created by HuiCao on 2019/7/9.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_GPBMessage+CocoaDebug.h"
#import "NSObject+CocoaDebug.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "_GPBArray.h"

@implementation _GPBMessage (CocoaDebug)

#pragma mark - Public Methods
- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary<NSString *, NSString *> *keyMap = [NSMutableDictionary<NSString *, NSString *> dictionary];
        NSDictionary *nameMap = [self nameMap];
        for (NSString *keyName in nameMap) {
            id keyNameObject = [nameMap objectForKey:keyName];
            if ([keyNameObject isKindOfClass:[NSString class]]) {
                [keyMap setObject:keyName forKey:keyNameObject];
            }
            if ([keyNameObject isKindOfClass:[NSArray class]]) {
                for (id keyPath in (NSArray *)keyNameObject) {
                    [keyMap setObject:keyName forKey:keyPath];
                }
            }
        }
        for (NSString *keyName in dict) {
            NSString *keyPath = [keyMap _stringForKey:keyName default:keyName];
            [self setKeyPath:keyPath value:[dict objectForKey:keyName]];
        }
    }
    return self;
}

- (NSDictionary *)containerType {
    return @{};
}

- (NSDictionary *)nameMap {
    return @{};
}

- (NSString *)_JSONStringWithIgnoreFields:(NSArray * _Nullable)ignoreFields {
    NSData *data = [NSJSONSerialization dataWithJSONObject:[self dictionaryWithIgnoreFields:ignoreFields] options:kNilOptions error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - Private Methods
- (NSDictionary *)dictionaryWithIgnoreFields:(NSArray * _Nullable)ignoreFields {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (unsigned int i = 0; i < count; i++) {
        const char *propertyName = property_getName(properties[i]);
        NSString *keyPath = [NSString stringWithUTF8String:propertyName];

        id serializeObject = [self serializeValueForKey:keyPath];
        if (nil == serializeObject) {
            continue;
        }
        id keyNameObject = [[self nameMap] objectForKey:keyPath];

        if (keyNameObject == nil && ![ignoreFields containsObject:keyPath]) {
            [dict setObject:serializeObject forKey:keyPath];
        }
        if ([keyNameObject isKindOfClass:[NSString class]] && ![ignoreFields containsObject:keyNameObject]) {
            [dict setObject:serializeObject forKey:keyNameObject];
        }
        if ([keyNameObject isKindOfClass:[NSArray class]] && ![ignoreFields containsObject:keyNameObject]) {
            NSString *keyName = [keyNameObject objectAtIndex:0]; // 只序列化第一个值
            [dict setObject:serializeObject forKey:keyName];
        }
    }
    free(properties);
    return dict;
}

- (NSDictionary *)dictionary {
    return [self dictionaryWithIgnoreFields:nil];
}

- (id)serializeValueForKey:(NSString *)keyPath {
    id item = [self valueForKey:keyPath];
    if ([item isKindOfClass:[NSNumber class]] || [item isKindOfClass:[NSString class]]) {
        return item;
    }
    if ([item isKindOfClass:[_GPBMessage class]]) {
        return [item dictionary];
    }
    if ([item isKindOfClass:[_GPBInt32Array class]]) {
        NSMutableArray *array = [NSMutableArray array];
        _GPBInt32Array *itemArray = (_GPBInt32Array *)item;
        [itemArray enumerateValuesWithBlock:^(int32_t value, NSUInteger idx, BOOL * _Nonnull stop) {
            [array addObject:@(value)];
        }];
        return array;
    }
    if ([item isKindOfClass:[_GPBUInt32Array class]]) {
        NSMutableArray *array = [NSMutableArray array];
        _GPBUInt32Array *itemArray = (_GPBUInt32Array *)item;
        [itemArray enumerateValuesWithBlock:^(uint32_t value, NSUInteger idx, BOOL * _Nonnull stop) {
            [array addObject:@(value)];
        }];
        return array;
    }
    if ([item isKindOfClass:[_GPBInt64Array class]]) {
        NSMutableArray *array = [NSMutableArray array];
        _GPBInt64Array *itemArray = (_GPBInt64Array *)item;
        [itemArray enumerateValuesWithBlock:^(int64_t value, NSUInteger idx, BOOL * _Nonnull stop) {
            [array addObject:@(value)];
        }];
        return array;
    }
    if ([item isKindOfClass:[_GPBUInt64Array class]]) {
        NSMutableArray *array = [NSMutableArray array];
        _GPBUInt64Array *itemArray = (_GPBUInt64Array *)item;
        [itemArray enumerateValuesWithBlock:^(uint64_t value, NSUInteger idx, BOOL * _Nonnull stop) {
            [array addObject:@(value)];
        }];
        return array;
    }
    if ([item isKindOfClass:[_GPBFloatArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        _GPBFloatArray *itemArray = (_GPBFloatArray *)item;
        [itemArray enumerateValuesWithBlock:^(float value, NSUInteger idx, BOOL * _Nonnull stop) {
            [array addObject:@(value)];
        }];
        return array;
    }
    if ([item isKindOfClass:[_GPBDoubleArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        _GPBDoubleArray *itemArray = (_GPBDoubleArray *)item;
        [itemArray enumerateValuesWithBlock:^(double value, NSUInteger idx, BOOL * _Nonnull stop) {
            [array addObject:@(value)];
        }];
        return array;
    }
    if ([item isKindOfClass:[_GPBBoolArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        _GPBBoolArray *itemArray = (_GPBBoolArray *)item;
        [itemArray enumerateValuesWithBlock:^(BOOL value, NSUInteger idx, BOOL * _Nonnull stop) {
            [array addObject:@(value)];
        }];
        return array;
    }
    if ([item isKindOfClass:[_GPBEnumArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        _GPBEnumArray *itemArray = (_GPBEnumArray *)item;
        [itemArray enumerateValuesWithBlock:^(int32_t value, NSUInteger idx, BOOL * _Nonnull stop) {
            [array addObject:@(value)];
        }];
        return array;
    }
    if ([item isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        for (id arrayItem in item) {
            if ([arrayItem isKindOfClass:[NSNumber class]] || [arrayItem isKindOfClass:[NSString class]]) {
                [array addObject:arrayItem];
                continue;
            }
            if ([arrayItem isKindOfClass:[_GPBMessage class]]) {
                [array addObject:[arrayItem dictionary]];
            }
        }
        return array;
    }
    return nil;
}

- (void)setKeyPath:(NSString *)keyPath value:(id)value {
    NSMutableArray *propertiesNameArray = [NSMutableArray<NSString *> array];
    NSMutableDictionary *propertiesTypeDic = [NSMutableDictionary<NSString *, NSString *> dictionary];
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (NSUInteger i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        [propertiesNameArray addObject:propertyName];

        NSString *attr = [NSString stringWithUTF8String:&(property_getAttributes(property)[1])];
        NSString *type = [[attr componentsSeparatedByString:@","] objectAtIndex:0];
        [propertiesTypeDic setObject:type forKey:propertyName];
    }
    free(properties);

    NSString *type = [propertiesTypeDic _stringForKey:keyPath default:@""];
    SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [keyPath substringToIndex:1].uppercaseString, [keyPath substringFromIndex:1]]);

    if ([value isKindOfClass:[NSString class]] == YES) {
        NSString *str = (NSString *)value;
        if ([type isEqualToString:@"@\"NSString\""]) {
            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)self, setter, str);
        }
        if ([type isEqualToString:[NSString stringWithUTF8String:@encode(bool)]]) {
            NSAssert([value isKindOfClass:[NSString class]], @"%@: property (%@) type mismatch, require bool but string", self, keyPath);
            ((void (*)(id, SEL, bool))(void *) objc_msgSend)(self, setter, str.boolValue);
            return;
        }
        if ([type isEqualToString:[NSString stringWithUTF8String:@encode(BOOL)]]) {
            NSAssert([value isKindOfClass:[NSString class]], @"%@: property (%@) type mismatch, require BOOL but string", self, keyPath);
            ((void (*)(id, SEL, BOOL))(void *) objc_msgSend)(self, setter, str.boolValue);
            return;
        }
        if ([type isEqualToString:[NSString stringWithUTF8String:@encode(int32_t)]]) {
            NSAssert([value isKindOfClass:[NSString class]], @"%@: property (%@) type mismatch, require int32_t but string", self, keyPath);
            ((void (*)(id, SEL, int32_t))(void *) objc_msgSend)(self, setter, (int32_t)str.intValue);
            return;
        }
        if ([type isEqualToString:[NSString stringWithUTF8String:@encode(uint32_t)]]) {
            NSAssert([value isKindOfClass:[NSString class]], @"%@: property (%@) type mismatch, require uint32_t but string", self, keyPath);
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
            NSNumber *num = [numberFormatter numberFromString:str];
            ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)(self, setter, (uint32_t)num.unsignedIntValue);
            return;
        }
        if ([type isEqualToString:[NSString stringWithUTF8String:@encode(int64_t)]]) {
            NSAssert([value isKindOfClass:[NSString class]], @"%@: property (%@) type mismatch, require int64_t but string", self, keyPath);
            ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)(self, setter, (int64_t)str.longLongValue);
            return;
        }
        if ([type isEqualToString:[NSString stringWithUTF8String:@encode(uint64_t)]]) {
            NSAssert([value isKindOfClass:[NSString class]], @"%@: property (%@) type mismatch, require uint64_t but string", self, keyPath);
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
            NSNumber *num = [numberFormatter numberFromString:str];
            ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)(self, setter, (uint64_t)num.unsignedLongLongValue);
            return;
        }
        if ([type isEqualToString:[NSString stringWithUTF8String:@encode(float)]]) {
            NSAssert([value isKindOfClass:[NSString class]], @"%@: property (%@) type mismatch, require float but string", self, keyPath);
            float f = str.floatValue;
            if (isnan(f) == NO && isinf(f) == NO) {
                ((void (*)(id, SEL, float))(void *) objc_msgSend)(self, setter, f);
                return;
            }
        }
        if ([type isEqualToString:[NSString stringWithUTF8String:@encode(double)]]) {
            NSAssert([value isKindOfClass:[NSString class]], @"%@: property (%@) type mismatch, require double but string", self, keyPath);
            double d = str.doubleValue;
            if (isnan(d) == NO && isinf(d) == NO) {
                ((void (*)(id, SEL, double))(void *) objc_msgSend)(self, setter, d);
                return;
            }
        }
    }
    if ([value isKindOfClass:[NSNumber class]] == YES) {
        NSNumber *number = (NSNumber *)value;
        if ([type isEqualToString:[NSString stringWithUTF8String:@encode(bool)]]) {
            ((void (*)(id, SEL, bool))(void *) objc_msgSend)(self, setter, number.boolValue);
            return;
        }
        if ([type isEqualToString:[NSString stringWithUTF8String:@encode(BOOL)]]) {
            ((void (*)(id, SEL, BOOL))(void *) objc_msgSend)(self, setter, number.boolValue);
            return;
        }
        if ([type isEqualToString:[NSString stringWithUTF8String:@encode(int32_t)]]) {
            ((void (*)(id, SEL, int32_t))(void *) objc_msgSend)(self, setter, (int32_t)number.intValue);
            return;
        }
        if ([type isEqualToString:[NSString stringWithUTF8String:@encode(uint32_t)]]) {
            ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)(self, setter, (uint32_t)number.unsignedIntValue);
            return;
        }
        if ([type isEqualToString:[NSString stringWithUTF8String:@encode(int64_t)]]) {
            ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)(self, setter, (int64_t)number.longLongValue);
            return;
        }
        if ([type isEqualToString:[NSString stringWithUTF8String:@encode(uint64_t)]]) {
            ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)(self, setter, (uint64_t)number.longLongValue);
            return;
        }
        if ([type isEqualToString:[NSString stringWithUTF8String:@encode(float)]]) {
            float f = number.floatValue;
            if (isnan(f) == NO && isinf(f) == NO) {
                ((void (*)(id, SEL, float))(void *) objc_msgSend)(self, setter, f);
                return;
            }
        }
        if ([type isEqualToString:[NSString stringWithUTF8String:@encode(double)]]) {
            double d = number.doubleValue;
            if (isnan(d) == NO && isinf(d) == NO) {
                ((void (*)(id, SEL, double))(void *) objc_msgSend)(self, setter, d);
                return;
            }
        }
        if ([type isEqualToString:@"@\"NSString\""]) {
            NSAssert([value isKindOfClass:[NSString class]], @"%@: property (%@) type mismatch, require string but number", self, keyPath);
            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)self, setter, [number stringValue]);
            return;
        }
    }
    if (([type isEqualToString:@"@\"NSMutableArray\""] || [type isEqualToString:@"@\"NSArray\""]) && [value isKindOfClass:[NSArray class]] == YES) {
        NSMutableArray *array = [NSMutableArray array];
        for (id arrayValue in value) {
            if ([arrayValue isKindOfClass:[NSNumber class]] == YES || [arrayValue isKindOfClass:[NSString class]] == YES) {
                [array addObject:arrayValue];
                continue;
            }
            if ([arrayValue isKindOfClass:[NSDictionary class]] == YES) {
                NSString *arrayItemType = [[self containerType] _stringForKey:keyPath default:nil];
                if (arrayItemType == nil) {
                    [array addObject:arrayValue];
                    break;
                }
                Class itemClass = NSClassFromString(arrayItemType);
                if (!itemClass) {
                    //SSPWarning(@"Can't find class of %@", arrayItemType);
                    return;
                }
                Class parentClass = class_getSuperclass(itemClass);
                if ([parentClass isEqual:[_GPBMessage class]] == NO) {
                    //SSPWarning(@"%@ is not _GPBMessage", arrayItemType);
                    return;
                }
                [array addObject:[[itemClass alloc] initWithDictionary:arrayValue]];
            }
            if ([arrayValue isKindOfClass:[NSArray class]] == YES) {
                //SSPError(@"Not support NSArray in NSArray");
                return;
            }
        }
        ((void (*)(id, SEL, id))(void *) objc_msgSend)(self, setter, array);
        return;
    }
    if ([type hasPrefix:@"@\""] && [value isKindOfClass:[NSDictionary class]] == YES) {
        if ([type isEqualToString:@"@\"NSDictionary\""] || [type isEqualToString:@"@\"NSMutableDictionary\""]) {
            NSMutableDictionary *dictValue = [NSMutableDictionary dictionary];
            NSArray *dictTypes = [[self containerType] _arrayForKey:keyPath default:nil];
            if (dictTypes && [dictTypes count] == 2) {
                for (id dictKey in value) {
                    Class itemClass = NSClassFromString(dictTypes[1]);
                    if (!itemClass) {
                        //SSPWarning(@"Can't find class of %@", dictTypes[1]);
                        return;
                    }
                    if ([itemClass isEqual:[NSString class]]||[itemClass isEqual:[NSNumber class]]) {
                        [dictValue setObject:value[dictKey] forKey:dictKey];
                        continue;
                    }
                    Class parentClass = class_getSuperclass(itemClass);
                    if ([parentClass isEqual:[_GPBMessage class]] == NO) {
                        //SSPWarning(@"%@ is not _GPBMessage", dictTypes[1]);
                        return;
                    }
                    [dictValue setObject:[[itemClass alloc] initWithDictionary:value[dictKey]] forKey:dictKey];
                }
            } else if (dictTypes && [dictTypes count] == 3){
                for (id dictKey in value) {
                    Class itemClass = NSClassFromString(dictTypes[1]);
                    if (!itemClass || ![itemClass isEqual:[NSArray class]] || ![value[dictKey] isKindOfClass:[NSArray class]]) {
                        //SSPWarning(@"Map<obj, Array> parse error!");
                        return;
                    }
                    NSMutableArray *array = [NSMutableArray array];
                    for (id arrayValue in value[dictKey]) {
                        if ([arrayValue isKindOfClass:[NSNumber class]] == YES || [arrayValue isKindOfClass:[NSString class]] == YES) {
                            [array addObject:arrayValue];
                            continue;
                        }
                        if ([arrayValue isKindOfClass:[NSDictionary class]] == YES) {
                            Class inItemClass = NSClassFromString(dictTypes[2]);
                            if (!inItemClass) {
                                //SSPWarning(@"Can't find class of %@", dictTypes[2]);
                                return;
                            }
                            Class parentClass = class_getSuperclass(inItemClass);
                            if ([parentClass isEqual:[_GPBMessage class]] == NO) {
                                //SSPWarning(@"%@ is not _GPBMessage", dictTypes[2]);
                                return;
                            }
                            [array addObject:[[inItemClass alloc] initWithDictionary:arrayValue]];
                        }
                        if ([arrayValue isKindOfClass:[NSArray class]] == YES) {
                            //SSPError(@"Not support NSArray in NSArray");
                            return;
                        }
                    }
                    [dictValue setObject:array forKey:dictKey];
                }
            }
            ((void (*)(id, SEL, id))(void *) objc_msgSend)(self, setter, dictValue);
            return;
        }

        NSString *itemType = [type substringWithRange:NSMakeRange(2, [type length]-3)];
        Class itemClass = NSClassFromString(itemType);
        if (!itemClass) {
            //SSPWarning(@"Can't find class of %@", itemType);
            return;
        }
        Class parentClass = class_getSuperclass(itemClass);
        if ([parentClass isEqual:[_GPBMessage class]] == NO) {
            //SSPWarning(@"%@ is not _GPBMessage", itemType);
            return;
        }
        id item = [[itemClass alloc] initWithDictionary:value];
        ((void (*)(id, SEL, id))(void *) objc_msgSend)(self, setter, item);
        return;
    }
}

@end
