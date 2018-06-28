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
//        DotzuX.serverURL = @"google.com"; //default value is `nil`
//        DotzuX.ignoredURLs = @[@"aaa.com", @"bbb.com"]; //default value is `nil`
//        DotzuX.onlyURLs = @[@"ccc.com", @"ddd.com"]; //default value is `nil`
//        DotzuX.tabBarControllers = @[[UIViewController new], [UIViewController new]]; //default value is `nil`
//        DotzuX.recordCrash = YES; //default value is `NO`
//        DotzuX.logMaxCount = 1000; //default value is `500`
//        DotzuX.emailToRecipients = @[@"aaa@gmail.com", @"bbb@gmail.com"]; //default value is `nil`
//        DotzuX.emailCcRecipients = @[@"ccc@gmail.com", @"ddd@gmail.com"]; //default value is `nil`
        [DotzuX enable];
    #endif
    
    return YES;
}




@end
