//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import UIKit

//#if DEBUG
//    import CocoaDebug
//#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
//            CocoaDebug.serverURL = "google.com" //default value is `nil`
//            CocoaDebug.ignoredURLs = ["aaa.com", "bbb.com"] //default value is `nil`
//            CocoaDebug.onlyURLs = ["ccc.com", "ddd.com"] //default value is `nil`
//            CocoaDebug.tabBarControllers = [UIViewController(), UIViewController()] //default value is `nil`
//            CocoaDebug.recordCrash = true //default value is `false`
//            CocoaDebug.logMaxCount = 1000 //default value is `500`
//            CocoaDebug.emailToRecipients = ["aaa@gmail.com", "bbb@gmail.com"] //default value is `nil`
//            CocoaDebug.emailCcRecipients = ["ccc@gmail.com", "ddd@gmail.com"] //default value is `nil`
//            CocoaDebug.mainColor = "#fd9727" //default value is `#42d459`
            CocoaDebug.enable()
        #endif
        
        return true
    }
}


public func print<T>(file: String = #file, function: String = #function, line: Int = #line, _ message: T, color: UIColor = .white) {
    #if DEBUG
        swiftLog(file, function, line, message, color)
    #endif
}


