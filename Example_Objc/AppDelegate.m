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
//        Debugger.serverURL = @"google.com"; //default nil
//        Debugger.ignoredURLs = @[@"aaa.com", @"bbb.com"]; //default nil
//        Debugger.onlyURLs = @[@"ccc.com", @"ddd.com"]; //default nil
//        Debugger.tabBarControllers = @[controller, controller2]; //default nil
//        Debugger.recordCrash = YES; //default NO
        [DotzuX start];
    #endif
    
    return YES;
}




@end
