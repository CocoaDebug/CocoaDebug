//
//  DebugTool.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation

@objc public class DebugTool : NSObject {
    
    ///if the catched URLs contain server URL ,set these URLs bold font to be marked. not mark when this value is nil. default value is `nil`.
    @objc public static var serverURL: String? = nil
    ///set the URLs which should not catched, ignoring case, catch all URLs when the value is nil. default value is `nil`.
    @objc public static var ignoredURLs: [String]? = nil
    ///set the URLs which are only catched, ignoring case, catch all URLs when the value is nil. default value is `nil`.
    @objc public static var onlyURLs: [String]? = nil
    ///custom controllers to be added as child controllers of UITabBarController. default value is `nil`.
    @objc public static var tabBarControllers: [UIViewController]? = nil
    ///whether to allow the recording of crash logs in app. default value is `false`.
    @objc public static var recordCrash: Bool = false
    
    //MARK: - DebugTool start
    @objc public static func start() {
        initializationMethod(serverURL: serverURL, ignoredURLs: ignoredURLs, onlyURLs: onlyURLs, tabBarControllers: tabBarControllers, recordCrash: recordCrash)
    }
    
    //MARK: - objcLog() usage only for Objective-C
    @objc public static func objcLog(_ file: String = #file,
                                     _ function: String = #function,
                                     _ line: Int = #line,
                                     _ message: Any,
                                     _ color: UIColor? = nil) {
        Swift.print(message)
        LogHelper.shared.handleLog(file: file, function: function, line: line, message: message, color: color)
    }
}


//MARK: - swiftLog() usage only for Swift
public func swiftLog<T>(_ file: String = #file,
                        _ function: String = #function,
                        _ line: Int = #line,
                        _ message: T,
                        _ color: UIColor? = nil) {
    Swift.print(message)
    LogHelper.shared.handleLog(file: file, function: function, line: line, message: message, color: color)
}


