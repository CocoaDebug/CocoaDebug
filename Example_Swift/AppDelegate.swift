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
//            DotzuX.serverURL = "google.com" //default nil
//            DotzuX.ignoredURLs = ["aaa.com", "bbb.com"] //default nil
//            DotzuX.onlyURLs = ["ccc.com", "ddd.com"] //default nil
//            DotzuX.tabBarControllers = [controller, controller2] //default nil
//            DotzuX.recordCrash = true //default false
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


