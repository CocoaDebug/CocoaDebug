//
//  AppDelegate.swift
//  Example_Swift
//
//  Created by man on 8/11/20.
//  Copyright © 2020 man. All rights reserved.
//

import UIKit
#if DEBUG
    import CocoaDebug
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
        /*
             //--- If Use Google's Protocol buffers ---
             CocoaDebug.protobufTransferMap = [
                 "your_api_keywords_1": ["your_protobuf_className_1"],
                 "your_api_keywords_2": ["your_protobuf_className_2"],
                 "your_api_keywords_3": ["your_protobuf_className_3"]
             ]

             //--- If Want to Custom CocoaDebug Settings ---
             CocoaDebug.serverURL = "google.com"
             CocoaDebug.ignoredURLs = ["aaa.com", "bbb.com"]
             CocoaDebug.onlyURLs = ["ccc.com", "ddd.com"]
             CocoaDebug.tabBarControllers = [UIViewController.init(), UIViewController.init()]
             CocoaDebug.logMaxCount = 1000
             CocoaDebug.emailToRecipients = ["aaa@gmail.com", "bbb@gmail.com"]
             CocoaDebug.emailCcRecipients = ["ccc@gmail.com", "ddd@gmail.com"]
             CocoaDebug.mainColor = "#fd9727"
         */
             
             CocoaDebug.enable()
        #endif
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}



//normal print
public func print<T>(file: String = #file, function: String = #function, line: Int = #line, _ message: T, color: UIColor = .white) {
    #if DEBUG
        swiftLog(file, function, line, message, color, false)
    #endif
}

//unicode print
public func print_UNICODE<T>(file: String = #file, function: String = #function, line: Int = #line, _ message: T, color: UIColor = .white) {
    #if DEBUG
        swiftLog(file, function, line, message, color, true)
    #endif
}
