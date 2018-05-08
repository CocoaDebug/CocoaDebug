//
//  DotzuX.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation

@objc public class DotzuX : NSObject {
    
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
    ///the maximum count of logs which DotzuX display. default value is `500`.
    @objc public static var logMaxCount: Int = 500
    
    
    //MARK: - DotzuX enable
    @objc public static func enable() {
        initializationMethod(serverURL: serverURL, ignoredURLs: ignoredURLs, onlyURLs: onlyURLs, tabBarControllers: tabBarControllers, recordCrash: recordCrash)
    }
    
    //MARK: - DotzuX disable
    @objc public static func disable() {
        WindowHelper.shared.disable()
        NetworkHelper.shared().disable()
        LogHelper.shared.enable = false
        CrashLogger.shared.enable = false
        DotzuXSettings.shared.responseShake = false
    }
    
    //MARK: - objcLog() usage only for Objective-C
    @objc public static func objcHandleLog(_ file: String = #file,
                                           _ function: String = #function,
                                           _ line: Int = #line,
                                           _ message: Any,
                                           _ color: UIColor) {
        LogHelper.shared.handleLog(file: file, function: function, line: line, message: message, color: color)
    }
    
    @objc public static func objcLog(_ file: String = #file,
                                     _ function: String = #function,
                                     _ line: Int = #line,
                                     _ message: Any,
                                     _ color: UIColor) {
        Swift.print(message)
        LogHelper.shared.handleLog(file: file, function: function, line: line, message: message, color: color)
    }
}


//MARK: - swiftLog() usage only for Swift
public func swiftHandleLog<T>(_ file: String = #file,
                              _ function: String = #function,
                              _ line: Int = #line,
                              _ message: T,
                              _ color: UIColor) {
    LogHelper.shared.handleLog(file: file, function: function, line: line, message: message, color: color)
}

public func swiftLog<T>(_ file: String = #file,
                        _ function: String = #function,
                        _ line: Int = #line,
                        _ message: T,
                        _ color: UIColor) {
    Swift.print(message)
    LogHelper.shared.handleLog(file: file, function: function, line: line, message: message, color: color)
}


