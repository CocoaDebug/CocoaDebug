//
//  CocoaDebug
//  liman
//
//  Created by liman 02/02/2023.
//  Copyright © 2023 liman. All rights reserved.
//

import Foundation
import UIKit

@objc public class CocoaDebug : NSObject {
    
    ///if the captured URLs contain server URL, CocoaDebug set server URL bold font to be marked. Not mark when this value is nil. Default value is `nil`.
//    @objc public static var serverURL: String? = nil
    ///set the URLs which should not been captured, CocoaDebug capture all URLs when the value is nil. Default value is `nil`.
//    @objc public static var ignoredURLs: [String]? = nil
    ///set the URLs which are only been captured, CocoaDebug capture all URLs when the value is nil. Default value is `nil`.
//    @objc public static var onlyURLs: [String]? = nil
    ///set the prefix Logs which should not been captured, CocoaDebug capture all Logs when the value is nil. Default value is `nil`.
//    @objc public static var ignoredPrefixLogs: [String]? = nil
    ///set the prefix Logs which are only been captured, CocoaDebug capture all Logs when the value is nil. Default value is `nil`.
//    @objc public static var onlyPrefixLogs: [String]? = nil
    ///add an additional UIViewController as child controller of CocoaDebug's main UITabBarController. Default value is `nil`.
    @objc public static var additionalViewController: UIViewController? = nil
    ///set the initial recipients to include in the email’s “To” field when share via email. Default value is `nil`.
//    @objc public static var emailToRecipients: [String]? = nil
    ///set the initial recipients to include in the email’s “Cc” field when share via email. Default value is `nil`.
//    @objc public static var emailCcRecipients: [String]? = nil
    ///set CocoaDebug's main color with hexadecimal format. Default value is `#42d459`.
    static var mainColor: String = "#42d459"
    ///protobuf url and response class transfer map. Default value is `nil`.
//    @objc public static var protobufTransferMap: [String: [String]]? = nil

    //MARK: - CocoaDebug enable
    @objc public static func enable() {
        initializationMethod(serverURL: nil, ignoredURLs: nil, onlyURLs: nil, ignoredPrefixLogs: nil, onlyPrefixLogs: nil, additionalViewController: additionalViewController, emailToRecipients: nil, emailCcRecipients: nil, mainColor: nil, protobufTransferMap: nil)
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



//MARK: - override Swift `print` method
public func print<T>(file: String = #file, function: String = #function, line: Int = #line, _ message: T, color: UIColor = .white) {
    Swift.print(message)
    _SwiftLogHelper.shared.handleLog(file: file, function: function, line: line, message: message, color: color)
}



