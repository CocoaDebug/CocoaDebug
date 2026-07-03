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
    NSLog(@"[CocoaDebug] AutoLaunch: didFinishLaunching fired");

    // Swift @objc class runtime name is ModuleName.ClassName
    Class CocoaDebugClass = NSClassFromString(@"CocoaDebug.CocoaDebug");
    if (!CocoaDebugClass) {
        // Fallback: try without module prefix (e.g. static library or different build config)
        CocoaDebugClass = NSClassFromString(@"CocoaDebug");
    }
    if (CocoaDebugClass && [CocoaDebugClass respondsToSelector:@selector(enable)]) {
        NSLog(@"[CocoaDebug] AutoLaunch: calling enable");
        [CocoaDebugClass performSelector:@selector(enable)];
        NSLog(@"[CocoaDebug] AutoLaunch: enable returned");
    } else {
        NSLog(@"[CocoaDebug] AutoLaunch: FAILED — CocoaDebug class=%@ responds=%@",
              CocoaDebugClass,
              CocoaDebugClass ? @"NO" : @"nil");
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidFinishLaunchingNotification
                                                  object:nil];
}

@end
