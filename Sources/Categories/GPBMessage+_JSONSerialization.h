//
//  GPBMessage+JSONSerialization.h
//  AirPayCounter
//
//  Created by HuiCao on 2019/7/9.
//  Copyright © 2019 Shopee. All rights reserved.
//

#import <Protobuf/GPBMessage.h>

NS_ASSUME_NONNULL_BEGIN

@interface GPBMessage (_JSONSerialization)

/*
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)containerType;
- (NSDictionary *)nameMap;
 */

- (NSString *)_JSONStringWithIgnoreFields:(NSArray * _Nullable)ignoreFields;

@end

NS_ASSUME_NONNULL_END
