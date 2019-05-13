//
//  NSBundle+Sandboxer.h
//  Example
//
//  Created by meilbn on 24/08/2017.
//  Copyright © 2017 meilbn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (Sandboxer)

@property (class, nonatomic, readonly, strong) NSBundle *sandboxerBundle;

+ (NSString *)mlb_localizedStringForKey:(NSString *)key;

@end
