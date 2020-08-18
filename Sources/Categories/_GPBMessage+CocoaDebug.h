//
//  _GPBMessage+CocoaDebug.h
//  AirPayCounter
//
//  Created by HuiCao on 2019/7/9.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_GPBMessage.h"

@interface _GPBMessage (CocoaDebug)

- (id _Nullable)initWithDictionary:(NSDictionary *_Nullable)dict;

- (NSDictionary *_Nullable)containerType;
- (NSDictionary *_Nullable)nameMap;
- (NSString *_Nullable)_JSONStringWithIgnoreFields:(NSArray * _Nullable)ignoreFields;
- (NSDictionary *_Nullable)dictionaryWithIgnoreFields:(NSArray * _Nullable)ignoreFields;

@end
