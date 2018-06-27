//
//  AppDelegate.swift
//  Example_Swift
//
//  Created by liman on 05/03/2018.
//  Copyright © 2018 liman. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
//            DotzuX.serverURL = "google.com" //default value is `nil`
//            DotzuX.ignoredURLs = ["aaa.com", "bbb.com"] //default value is `nil`
//            DotzuX.onlyURLs = ["ccc.com", "ddd.com"] //default value is `nil`
//            DotzuX.tabBarControllers = [UIViewController(), UIViewController()] //default value is `nil`
//            DotzuX.recordCrash = true //default value is `false`
//            DotzuX.logMaxCount = 1000 //default value is `500`
//            DotzuX.emailSubject = "my email subject" //default value is `Network Details`.
//            DotzuX.emailToRecipients = ["aaa@gmail.com", "bbb@gmail.com"] //default value is `nil`
//            DotzuX.emailCcRecipients = ["ccc@gmail.com", "ddd@gmail.com"] //default value is `nil`
            DotzuX.enable()
        #endif
        
        return true
    }
}


//MARK: - over write print()
public func print<T>(file: String = #file, function: String = #function, line: Int = #line, _ message: T, color: UIColor = .white) {
    
    #if DEBUG
        swiftLog(file, function, line, message, color)
    #endif
}


