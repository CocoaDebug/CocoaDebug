//
//  AppDelegate.swift
//  Example_Swift
//
//  Created by man 8/11/20.
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
//            customCocoaDebug()
        #endif
        
        return true
    }
    
    func customCocoaDebug() {
        //--- If want to custom CocoaDebug settings ---
        CocoaDebug.serverURL = "google.com"
        CocoaDebug.ignoredURLs = ["aaa.com", "bbb.com"]
        CocoaDebug.onlyURLs = ["ccc.com", "ddd.com"]
        CocoaDebug.ignoredPrefixLogs = ["aaa", "bbb"]
        CocoaDebug.onlyPrefixLogs = ["ccc", "ddd"]
        CocoaDebug.emailToRecipients = ["aaa@gmail.com", "bbb@gmail.com"]
        CocoaDebug.emailCcRecipients = ["ccc@gmail.com", "ddd@gmail.com"]
        CocoaDebug.mainColor = "#fd9727"
        CocoaDebug.additionalViewController = TestController.init()
        
        //Deprecated! If want to support protobuf, check branch: origin/protobuf_support
        //--- If use Google's Protocol buffers ---
//        CocoaDebug.protobufTransferMap = [
//            "your_api_keywords_1": ["your_protobuf_className_1"],
//            "your_api_keywords_2": ["your_protobuf_className_2"],
//            "your_api_keywords_3": ["your_protobuf_className_3"]
//        ]
        
        //--- If want to manual enable App logs (Take effect the next time when app starts) ---
        CocoaDebugSettings.shared.enableLogMonitoring = true
    }
}

extension AppDelegate {
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}



//MARK: - override Swift `print` method
public func print<T>(file: String = #file, function: String = #function, line: Int = #line, _ message: T, color: UIColor = .white) {
#if DEBUG
    Swift.print(message)
    _SwiftLogHelper.shared.handleLog(file: file, function: function, line: line, message: message, color: color)
#endif
}
