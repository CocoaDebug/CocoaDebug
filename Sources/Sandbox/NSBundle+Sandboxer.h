//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (Sandboxer)

@property (class, nonatomic, readonly, strong) NSBundle *sandboxerBundle;

+ (NSString *)mlb_localizedStringForKey:(NSString *)key;

@end
