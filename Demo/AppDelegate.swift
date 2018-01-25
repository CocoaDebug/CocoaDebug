//
//  AppDelegate.swift
//  DebugMan
//
//  Created by liman on 13/12/2017.
//  Copyright © 2017 liman. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    //MARK: - step 1: initialize `DebugMan`
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
            DebugMan.shared.enable()
        #endif
        
        return true
    }
}

//MARK: - step 2: override `print` && `NSLog`
public func print<T>(file: String = #file, function: String = #function, line: Int = #line, _ message: T, _ color: UIColor? = nil) {
    
    #if DEBUG
        DebugManLog(file, function, line, message, color)
    #endif
}

public func NSLog<T>(file: String = #file, function: String = #function, line: Int = #line, _ message: T, _ color: UIColor? = nil) {
    
    #if DEBUG
        DebugManLog(file, function, line, message, color)
    #endif
}
