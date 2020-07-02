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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@implementation NSObject (CocoaDebugAutoLaunch)

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching) name:UIApplicationDidFinishLaunchingNotification object:nil];
}

- (void)applicationDidFinishLaunching {
    Class CocoaDebug = [NSObject swiftClassFromString:(@"CocoaDebug")];
    [[CocoaDebug class] performSelector:@selector(enable)];
}

- (Class)swiftClassFromString:(NSString *)className {
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleExecutable"];
    NSString *classStringName = [NSString stringWithFormat:@"_TtC%lu%@%lu%@", (unsigned long)appName.length, appName, (unsigned long)className.length, className];
    return NSClassFromString(classStringName);
}

@end

#pragma GCC diagnostic pop
