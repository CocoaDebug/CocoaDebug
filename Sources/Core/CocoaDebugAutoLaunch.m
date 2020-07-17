/*
 https://developer.apple.com/forums/thread/61432
 
 --- The Issue: ---

 When user touch down on a view contains gestureRecognizers, abort will called:

 Assertion failure in -[UIGestureGraphEdge initWithLabel:sourceNode:targetNode:directed:], /BuildRoot/Library/Caches/com.apple.xbs/Sources/UIKit/UIKit-3599.6/Source/GestureGraph/UIGestureGraphEdge.m:25

 --- Reason: ---

 If I create view and setup gestures in some class's +(void)load method, the issue will occur.

 Since +(void)load method is called way before application finish launching,

 I suspect this is due to the UIGestureRecognizer's global enviroment is not set up yet.

 --- Solve: ---

 Delay the creation of the view, such as put it in the applicationDidFinishLaunching callback.
 */

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

static const char *kPropertyKey = "kApplicationDidFinishLaunching_CocoaDebug_Key";

#define GCD_DELAY_AFTER(time, block) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC), dispatch_get_main_queue(), block)

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "_NetworkHelper.h"

@interface NSObject (CocoaDebugAutoLaunch)

@property (nonatomic, assign) BOOL applicationDidFinishLaunching;

@end

@implementation NSObject (CocoaDebugAutoLaunch)

#pragma mark - load
+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunchingNotification:) name:UIApplicationDidFinishLaunchingNotification object:nil];
}

#pragma mark - notification
- (void)applicationDidFinishLaunchingNotification:(NSNotification *)notification {
    //
    if (self.applicationDidFinishLaunching) {return;}
    self.applicationDidFinishLaunching = YES;
    
    //
    Class CocoaDebug = [NSObject swiftClassFromString:(@"CocoaDebug")];
    
    if (CocoaDebug) {
        [[CocoaDebug class] performSelector:@selector(enable)];
    } else {
        GCD_DELAY_AFTER(1, ^{
            if (![_NetworkHelper shared].isRunningAutoLaunch) {
                [[[UIAlertView alloc] initWithTitle:@"WARNING" message:@"CocoaDebug auto launch failed,\nPlease enable CocoaDebug manually." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        });
    }
    
    //
    GCD_DELAY_AFTER(2, ^{
        [_NetworkHelper shared].isRunningAutoLaunch = NO;
    });
}

#pragma mark - private
- (Class)swiftClassFromString:(NSString *)className {
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleExecutable"];
    NSString *classStringName = [NSString stringWithFormat:@"_TtC%lu%@%lu%@", (unsigned long)appName.length, appName, (unsigned long)className.length, className];
    return NSClassFromString(classStringName);
}

#pragma mark - getter setter
- (BOOL)applicationDidFinishLaunching {
    NSNumber *number = objc_getAssociatedObject(self, kPropertyKey);
    return [number boolValue];
}

- (void)setApplicationDidFinishLaunching:(BOOL)applicationDidFinishLaunching {
    NSNumber *number = [NSNumber numberWithBool:applicationDidFinishLaunching];
    objc_setAssociatedObject(self, kPropertyKey, number, OBJC_ASSOCIATION_RETAIN);
}

@end

#pragma GCC diagnostic pop
