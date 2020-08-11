//
//  AppDelegate.m
//  Example_Objc
//
//  Created by man on 8/11/20.
//  Copyright © 2020 man. All rights reserved.
//

#import "AppDelegate.h"
#ifdef DEBUG
    @import CocoaDebug;
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    #ifdef DEBUG
    /*
         //--- If Use Google's Protocol buffers ---
         CocoaDebug.protobufTransferMap = @{
             @"your_api_keywords_1": @[@"your_protobuf_className_1"],
             @"your_api_keywords_2": @[@"your_protobuf_className_2"],
             @"your_api_keywords_3": @[@"your_protobuf_className_3"]
         };

         //--- If Want to Custom CocoaDebug Settings ---
         CocoaDebug.serverURL = @"google.com";
         CocoaDebug.ignoredURLs = @[@"aaa.com", @"bbb.com"];
         CocoaDebug.onlyURLs = @[@"ccc.com", @"ddd.com"];
         CocoaDebug.tabBarControllers = @[[UIViewController new], [UIViewController new]];
         CocoaDebug.logMaxCount = 1000;
         CocoaDebug.emailToRecipients = @[@"aaa@gmail.com", @"bbb@gmail.com"];
         CocoaDebug.emailCcRecipients = @[@"ccc@gmail.com", @"ddd@gmail.com"];
         CocoaDebug.mainColor = @"#fd9727";
     */
         
         [CocoaDebug enable];
    #endif
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)){
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions  API_AVAILABLE(ios(13.0)){
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
