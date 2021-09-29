//
//  AppDelegate.m
//  Example_Objc
//
//  Created by man on 8/11/20.
//  Copyright © 2020 man. All rights reserved.
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
    
#ifdef DEBUG
//    [self customCocoaDebug];
#endif
    
    return YES;
}

- (void)customCocoaDebug {
    //--- If want to custom CocoaDebug settings ---
    CocoaDebug.serverURL = @"google.com";
    CocoaDebug.ignoredURLs = @[@"aaa.com", @"bbb.com"];
    CocoaDebug.onlyURLs = @[@"ccc.com", @"ddd.com"];
    CocoaDebug.ignoredPrefixLogs = @[@"aaa", @"bbb"];
    CocoaDebug.onlyPrefixLogs = @[@"ccc", @"ddd"];
    CocoaDebug.emailToRecipients = @[@"aaa@gmail.com", @"bbb@gmail.com"];
    CocoaDebug.emailCcRecipients = @[@"ccc@gmail.com", @"ddd@gmail.com"];
    CocoaDebug.mainColor = @"#fd9727";
    CocoaDebug.additionalViewController = [TestViewController new];
    
    //Deprecated! If want to support protobuf, check branch: origin/protobuf_support
    //--- If use Google's Protocol buffers ---
//    CocoaDebug.protobufTransferMap = @{
//        @"your_api_keywords_1": @[@"your_protobuf_className_1"],
//        @"your_api_keywords_2": @[@"your_protobuf_className_2"],
//        @"your_api_keywords_3": @[@"your_protobuf_className_3"]
//    };
    
    //--- If want to manual enable App logs (Take effect the next time when app starts) ---
    CocoaDebugSettings.shared.enableLogMonitoring = YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)){
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions  API_AVAILABLE(ios(13.0)){
}

@end
