//
//  AppDelegate.m
//  Objective_C_Demo
//
//  Created by liman on 08/02/2018.
//  Copyright © 2018 liman. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    #ifdef DEBUG
        [[DebugMan shared] enableWithServerURL:nil ignoredURLs:nil onlyURLs:nil tabBarControllers:nil recordCrash:YES];
    #endif
    
    return YES;
}


@end
