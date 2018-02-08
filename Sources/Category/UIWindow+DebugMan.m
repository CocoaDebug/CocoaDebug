
#import "UIWindow+DebugMan.h"

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

@implementation UIWindow (DebugMan)

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
        
        dispatch_main_async_safe(^{
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ShakeNotification_DebugMan" object:nil]];
        })
    }
}

@end
