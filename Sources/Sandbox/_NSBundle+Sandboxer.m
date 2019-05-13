//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "_NSBundle+Sandboxer.h"
#import "_Sandboxer.h"
#import "_Sandboxer-Header.h"

@implementation NSBundle (_Sandboxer)

+ (NSBundle *)sandboxerBundle {
    static NSBundle *bundle = nil;
    if (!bundle) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"_SandboxerResources" ofType:@"bundle"];
        if (_MLBIsStringEmpty(path)) {
            NSBundle *bd = [NSBundle bundleForClass:[_Sandboxer class]];
            if (bd) {
                path = [bd pathForResource:@"_SandboxerResources" ofType:@"bundle"];
            }
        }
        
        bundle = [NSBundle bundleWithPath:path];
    }
    
    return bundle;
}

+ (NSString *)mlb_localizedStringForKey:(NSString *)key {
    return NSLocalizedStringFromTableInBundle(key, @"_Sandboxer", [NSBundle sandboxerBundle], nil);
}

@end
