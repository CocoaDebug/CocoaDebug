//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

#import "AppDelegate.h"
#import "Example_Objc-Swift.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    #ifdef DEBUG
//        CocoaDebug.serverURL = @"google.com"; //default value is `nil`
//        CocoaDebug.ignoredURLs = @[@"aaa.com", @"bbb.com"]; //default value is `nil`
//        CocoaDebug.onlyURLs = @[@"ccc.com", @"ddd.com"]; //default value is `nil`
//        CocoaDebug.tabBarControllers = @[[UIViewController new], [UIViewController new]]; //default value is `nil`
//        CocoaDebug.recordCrash = YES; //default value is `NO`
//        CocoaDebug.logMaxCount = 1000; //default value is `500`
//        CocoaDebug.emailToRecipients = @[@"aaa@gmail.com", @"bbb@gmail.com"]; //default value is `nil`
//        CocoaDebug.emailCcRecipients = @[@"ccc@gmail.com", @"ddd@gmail.com"]; //default value is `nil`
//        CocoaDebug.mainColor = @"#fd9727"; //default value is `#42d459`
//        CocoaDebug.disableLogMonitoring = YES; //default value is `NO`
//        CocoaDebug.disableNetworkMonitoring = YES; //default value is `NO`
        [CocoaDebug enable];
    #endif
    
    return YES;
}

@end
