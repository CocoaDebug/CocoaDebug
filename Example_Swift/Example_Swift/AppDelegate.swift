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
//            DebugTool.serverURL = "google.com" //default nil
//            DebugTool.ignoredURLs = ["aaa.com", "bbb.com"] //default nil
//            DebugTool.onlyURLs = ["ccc.com", "ddd.com"] //default nil
//            DebugTool.tabBarControllers = [controller, controller2] //default nil
//            DebugTool.recordCrash = true //default false
            DebugTool.start()
        #endif
        
        return true
    }
}


//MARK: - over write print()
public func print<T>(file: String = #file, function: String = #function, line: Int = #line, _ message: T, _ color: UIColor? = nil) {
    
    #if DEBUG
        swiftLog(file, function, line, message, color)
    #endif
}


