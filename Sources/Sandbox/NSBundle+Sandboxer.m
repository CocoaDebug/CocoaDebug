//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "NSBundle+Sandboxer.h"
#import "Sandboxer.h"
#import "Sandboxer-Header.h"

@implementation NSBundle (Sandboxer)

+ (NSBundle *)sandboxerBundle {
    static NSBundle *bundle = nil;
    if (!bundle) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SandboxerResources" ofType:@"bundle"];
        if (MLBIsStringEmpty(path)) {
            NSBundle *bd = [NSBundle bundleForClass:[Sandboxer class]];
            if (bd) {
                path = [bd pathForResource:@"SandboxerResources" ofType:@"bundle"];
            }
        }
        
        bundle = [NSBundle bundleWithPath:path];
    }
    
    return bundle;
}

+ (NSString *)mlb_localizedStringForKey:(NSString *)key {
    return NSLocalizedStringFromTableInBundle(key, @"Sandboxer", [NSBundle sandboxerBundle], nil);
}

@end
