//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "_LeakedObjectProxy.h"

@interface _LeaksMessenger : NSObject

+ (void)alertWithTitle:(NSString *)title
               message:(NSString *)message;

+ (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
              delegate:(id<_LeakedObjectProxyDelegate>)delegate
 additionalButtonTitle:(NSString *)additionalButtonTitle;

@end
