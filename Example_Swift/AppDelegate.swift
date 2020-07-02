//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import UIKit

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
        #endif
        
        return true
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

