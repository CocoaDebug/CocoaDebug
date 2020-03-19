//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
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
    ///the maximum count of logs which CocoaDebug display. default value is `1000`.
    @objc public static var logMaxCount: Int = 1000
    ///set the initial recipients to include in the email’s “To” field when share via email. default value is `nil`.
    @objc public static var emailToRecipients: [String]? = nil
    ///set the initial recipients to include in the email’s “Cc” field when share via email. default value is `nil`.
    @objc public static var emailCcRecipients: [String]? = nil
    ///set the main color with hexadecimal format. default value is `#42d459`.
    @objc public static var mainColor: String = "#42d459"
    ///protobuf url and response class transfer map. default value is `nil`.
    @objc public static var protobufTransferMap: [String: [String]]? = nil
    
    //MARK: - CocoaDebug enable
    @objc public static func enable() {
        initializationMethod(serverURL: serverURL, ignoredURLs: ignoredURLs, onlyURLs: onlyURLs, tabBarControllers: tabBarControllers, emailToRecipients: emailToRecipients, emailCcRecipients: emailCcRecipients, mainColor: mainColor, protobufTransferMap: protobufTransferMap)
    }
    
    //MARK: - CocoaDebug disable
    @objc public static func disable() {
        deinitializationMethod()
    }

    //MARK: - hide Bubble
    @objc public static func hideBubble() {
        CocoaDebugSettings.shared.showBubbleAndWindow = false
    }
    
    //MARK: - show Bubble
    @objc public static func showBubble() {
        CocoaDebugSettings.shared.showBubbleAndWindow = true
    }
}

//MARK: - swiftLog() usage only for Swift
public func swiftLog<T>(_ file: String = #file,
                        _ function: String = #function,
                        _ line: Int = #line,
                        _ message: T,
                        _ color: UIColor,
                        _ unicodeToChinese: Bool = false) {
    
    //unicode转换为中文
    if message is NSString && unicodeToChinese == true {
        if let _message = NSString.unicode(toChinese: message as? String) {
            Swift.print(_message)
            _LogHelper.shared.handleLog(file: file, function: function, line: line, message: _message, color: color)
            return
        }
    }
    
    
    
    Swift.print(message)
    _LogHelper.shared.handleLog(file: file, function: function, line: line, message: message, color: color)
}


