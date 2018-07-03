//
//  AppDelegate.m
//  Example_Objc
//
//  Created by liman on 05/03/2018.
//  Copyright © 2018 liman. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    #ifdef DEBUG
//        DebugWidget.serverURL = @"google.com"; //default value is `nil`
//        DebugWidget.ignoredURLs = @[@"aaa.com", @"bbb.com"]; //default value is `nil`
//        DebugWidget.onlyURLs = @[@"ccc.com", @"ddd.com"]; //default value is `nil`
//        DebugWidget.tabBarControllers = @[[UIViewController new], [UIViewController new]]; //default value is `nil`
//        DebugWidget.recordCrash = YES; //default value is `NO`
//        DebugWidget.logMaxCount = 1000; //default value is `500`
//        DebugWidget.emailToRecipients = @[@"aaa@gmail.com", @"bbb@gmail.com"]; //default value is `nil`
//        DebugWidget.emailCcRecipients = @[@"ccc@gmail.com", @"ddd@gmail.com"]; //default value is `nil`
        [DebugWidget enable];
    #endif
    
    return YES;
}




@end
