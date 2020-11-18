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

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    if (additionalButtonTitle.length) {
        [alert addAction:[UIAlertAction actionWithTitle:additionalButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if ([delegate respondsToSelector:@selector(retainCycle)]) {
                [delegate retainCycle];
            }
        }]];
    }
    
    alert.popoverPresentationController.permittedArrowDirections = 0;
    alert.popoverPresentationController.sourceView = UIApplication.sharedApplication.keyWindow.rootViewController.view;
    alert.popoverPresentationController.sourceRect = CGRectMake(UIApplication.sharedApplication.keyWindow.rootViewController.view.bounds.size.width / 2.0, UIApplication.sharedApplication.keyWindow.rootViewController.view.bounds.size.height / 2.0, 0, 0);
    
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    
    NSLog(@"%@: %@", title, message);
}

@end
