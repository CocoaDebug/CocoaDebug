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
//        DebugTool.serverURL = @"google.com"; //default nil
//        DebugTool.ignoredURLs = @[@"aaa.com", @"bbb.com"]; //default nil
//        DebugTool.onlyURLs = @[@"ccc.com", @"ddd.com"]; //default nil
//        DebugTool.tabBarControllers = @[controller, controller2]; //default nil
//        DebugTool.recordCrash = YES; //default NO
        [DebugTool start];
    #endif
    
    return YES;
}




@end
