//
//  _AutoLaunch.m
//  CocoaDebug
//
//  Auto-launch helper.
//  Uses a dedicated class to avoid +load on NSObject (which would run for every class in the process).
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// Dedicated class for auto-launch. +load only runs once for this specific class.
@interface CocoaDebugAutoLaunchHelper : NSObject
@end

@implementation CocoaDebugAutoLaunchHelper

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cocoadebug_applicationDidFinishLaunching:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
}

+ (void)cocoadebug_applicationDidFinishLaunching:(NSNotification *)notification {
    // Use the stable @objc class name instead of Swift mangled name.
    Class CocoaDebugClass = NSClassFromString(@"CocoaDebug");
    if (CocoaDebugClass && [CocoaDebugClass respondsToSelector:@selector(enable)]) {
        [CocoaDebugClass performSelector:@selector(enable)];
    }

    // Only fire once; remove observer after first launch.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidFinishLaunchingNotification
                                                  object:nil];
}

@end
