//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import Foundation

@objc public class CocoaDebug : NSObject {
    
    ///if the crawled URLs contain server URL ,set these URLs bold font to be marked. not mark when this value is nil. default value is `nil`.
    @objc public static var serverURL: String? = nil
    ///set the URLs which should not crawled, ignoring case, crawl all URLs when the value is nil. default value is `nil`.
    @objc public static var ignoredURLs: [String]? = nil
    ///set the URLs which are only crawled, ignoring case, crawl all URLs when the value is nil. default value is `nil`.
    @objc public static var onlyURLs: [String]? = nil
    ///set controllers to be added as child controllers of UITabBarController. default value is `nil`.
    @objc public static var tabBarControllers: [UIViewController]? = nil
    ///whether to allow the recording of crash logs in app. default value is `false`.
    @objc public static var recordCrash: Bool = false
    ///the maximum count of logs which CocoaDebug display. default value is `500`.
    @objc public static var logMaxCount: Int = 500
    ///set the initial recipients to include in the email’s “To” field when share via email. default value is `nil`.
    @objc public static var emailToRecipients: [String]? = nil
    ///set the initial recipients to include in the email’s “Cc” field when share via email. default value is `nil`.
    @objc public static var emailCcRecipients: [String]? = nil
    ///set the main color with hexadecimal format. default value is `#42d459`.
    @objc public static var mainColor: String = "#42d459"
    
    //MARK: - CocoaDebug enable
    @objc public static func enable() {
        initializationMethod(serverURL: serverURL, ignoredURLs: ignoredURLs, onlyURLs: onlyURLs, tabBarControllers: tabBarControllers, recordCrash: recordCrash, emailToRecipients: emailToRecipients, emailCcRecipients: emailCcRecipients, mainColor: mainColor)
    }
    
    //MARK: - CocoaDebug disable
    @objc public static func disable() {
        deinitializationMethod()
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


