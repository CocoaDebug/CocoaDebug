//
//  UIWindow+CJShakeRecognizer.m
//  FeedbackrPre
//
//  Created by confidence on 04/01/2013.
//  Copyright (c) 2013 confidence. All rights reserved.
//

#import "UIWindow+DHCShakeRecognizer.h"

@implementation UIWindow (DHCShakeRecognizer)

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"CONJUShakeNotification" object:nil]];
    }
}

@end

NSString * const DHCSHakeNotificationName = @"CONJUShakeNotification";
