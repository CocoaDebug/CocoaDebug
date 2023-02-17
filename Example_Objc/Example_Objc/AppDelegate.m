//
//  CocoaDebug
//  liman
//
//  Created by liman 02/02/2023.
//  Copyright © 2023 liman. All rights reserved.
//

#import "AppDelegate.h"
#import "TestViewController.h"

#ifdef DEBUG
    @import CocoaDebug;
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //You can add your custom controller here.👇👇👇
    //#ifdef DEBUG
    //    CocoaDebug.additionalViewController = [TestViewController new];
    //#endif
    
    return YES;
}

@end
