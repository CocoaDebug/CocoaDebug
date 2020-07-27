//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
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

@end
