//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_LeaksMessenger.h"

@implementation _LeaksMessenger

+ (void)alertWithTitle:(NSString *)title
               message:(NSString *)message {
    [self alertWithTitle:title
                 message:message
                delegate:nil
   additionalButtonTitle:nil];
}

+ (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
              delegate:(id<_LeakedObjectProxyDelegate>)delegate
 additionalButtonTitle:(NSString *)additionalButtonTitle {

    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    if (additionalButtonTitle.length) {
        [alertVC addAction:[UIAlertAction actionWithTitle:additionalButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if ([delegate respondsToSelector:@selector(retainCycle)]) {
                [delegate retainCycle];
            }
        }]];
    }
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alertVC animated:YES completion:nil];
    
    NSLog(@"%@: %@", title, message);
}

@end
