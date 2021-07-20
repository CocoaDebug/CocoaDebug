//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

static const char *kPropertyKey = "kApplicationDidFinishLaunching_CocoaDebug_Key";

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "_NetworkHelper.h"

@interface NSObject (CocoaDebugAutoLaunch)

@property (nonatomic, assign) BOOL cocoadebug_applicationDidFinishLaunching;

@end

@implementation NSObject (CocoaDebugAutoLaunch)

#pragma mark - load
+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cocoadebug_applicationDidFinishLaunchingNotification:) name:UIApplicationDidFinishLaunchingNotification object:nil];
}

#pragma mark - notification
- (void)cocoadebug_applicationDidFinishLaunchingNotification:(NSNotification *)notification {
    if (self.cocoadebug_applicationDidFinishLaunching) {return;}
    self.cocoadebug_applicationDidFinishLaunching = YES;
    
    Class CocoaDebug = NSClassFromString(@"_TtC10CocoaDebug10CocoaDebug");
    if (CocoaDebug) {
        [[CocoaDebug class] performSelector:@selector(enable)];
    }
}

#pragma mark - getter setter
- (BOOL)cocoadebug_applicationDidFinishLaunching {
    NSNumber *number = objc_getAssociatedObject(self, kPropertyKey);
    return [number boolValue];
}

- (void)setCocoadebug_applicationDidFinishLaunching:(BOOL)applicationDidFinishLaunching {
    NSNumber *number = [NSNumber numberWithBool:applicationDidFinishLaunching];
    objc_setAssociatedObject(self, kPropertyKey, number, OBJC_ASSOCIATION_RETAIN);
}

@end
