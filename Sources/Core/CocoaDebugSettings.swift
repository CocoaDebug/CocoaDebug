//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import Foundation

@objc public class CocoaDebugSettings: NSObject {
    
    @objc public static let shared = CocoaDebugSettings()
    
    @objc public var slowAnimations: Bool = false {
        didSet {            
            if slowAnimations == false {
                UIApplication.shared.windows.first?.layer.speed = 1;
            } else {
                UIApplication.shared.windows.first?.layer.speed = 0.1;
            }
        }
    }
    
    @objc public var responseShake: Bool = false {
        didSet {
            UserDefaults.standard.set(responseShake, forKey: "responseShake_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    
    @objc public var firstIn: String? = nil {
        didSet {
            UserDefaults.standard.set(firstIn, forKey: "firstIn_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var enableCrashRecording: Bool = false {
        didSet {
            UserDefaults.standard.set(enableCrashRecording, forKey: "enableCrashRecording_CocoaDebug")
            UserDefaults.standard.synchronize()
            
            if enableCrashRecording == true {
                CrashLogger.shared.enable = true
            } else {
                CrashLogger.shared.enable = false
                CrashStoreManager.shared.resetCrashs()
            }
        }
    }
    @objc public var enableUIBlockingMonitoring: Bool = false {
        didSet {
            UserDefaults.standard.set(enableUIBlockingMonitoring, forKey: "enableUIBlockingMonitoring_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var enableWKWebViewMonitoring: Bool = false {
        didSet {
            UserDefaults.standard.set(enableWKWebViewMonitoring, forKey: "enableWKWebViewMonitoring_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var enableLogMonitoring: Bool = false {
        didSet {
            UserDefaults.standard.set(enableLogMonitoring, forKey: "enableLogMonitoring_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var disableNetworkMonitoring: Bool = false {
        didSet {
            UserDefaults.standard.set(disableNetworkMonitoring, forKey: "disableNetworkMonitoring_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var enableRNMonitoring: Bool = false {
        didSet {
            UserDefaults.standard.set(enableRNMonitoring, forKey: "enableRNMonitoring_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var enableMemoryLeaksMonitoring_ViewController: Bool = false {
        didSet {
            UserDefaults.standard.set(enableMemoryLeaksMonitoring_ViewController, forKey: "enableMemoryLeaksMonitoring_UIViewController_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var enableMemoryLeaksMonitoring_View: Bool = false {
        didSet {
            UserDefaults.standard.set(enableMemoryLeaksMonitoring_View, forKey: "enableMemoryLeaksMonitoring_UIView_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var enableMemoryLeaksMonitoring_MemberVariables: Bool = false {
        didSet {
            UserDefaults.standard.set(enableMemoryLeaksMonitoring_MemberVariables, forKey: "enableMemoryLeaksMonitoring_MemberVariables_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var visible: Bool = false {
        didSet {
            UserDefaults.standard.set(visible, forKey: "visible_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var showBubbleAndWindow: Bool = false {
        didSet {
            UserDefaults.standard.set(showBubbleAndWindow, forKey: "showBubbleAndWindow_CocoaDebug")
            UserDefaults.standard.synchronize()
            
            let x = WindowHelper.shared.vc.bubble.frame.origin.x
            let width = WindowHelper.shared.vc.bubble.frame.size.width
            
            if showBubbleAndWindow == true
            {
                if x > UIScreen.main.bounds.size.width/2 {
                    WindowHelper.shared.vc.bubble.frame.origin.x = UIScreen.main.bounds.size.width - width/8*8.25
                } else {
                    WindowHelper.shared.vc.bubble.frame.origin.x = -width + width/8*8.25
                }
                WindowHelper.shared.enable()
            }
            else
            {
                if x > UIScreen.main.bounds.size.width/2 {
                    WindowHelper.shared.vc.bubble.frame.origin.x = UIScreen.main.bounds.size.width
                } else {
                    WindowHelper.shared.vc.bubble.frame.origin.x = -width
                }
                WindowHelper.shared.disable()
            }
        }
    }
    @objc public var serverURL: String? = nil {
        didSet {
            UserDefaults.standard.set(serverURL, forKey: "serverURL_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var tabBarSelectItem: Int {
        didSet {
            UserDefaults.standard.set(tabBarSelectItem, forKey: "tabBarSelectItem_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var logSelectIndex: Int {
        didSet {
            UserDefaults.standard.set(logSelectIndex, forKey: "logSelectIndex_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var networkLastIndex: Int {
        didSet {
            UserDefaults.standard.set(networkLastIndex, forKey: "networkLastIndex_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var bubbleFrameX: Float {
        didSet {
            UserDefaults.standard.set(bubbleFrameX, forKey: "bubbleFrameX_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var bubbleFrameY: Float {
        didSet {
            UserDefaults.standard.set(bubbleFrameY, forKey: "bubbleFrameY_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var logSearchWordNormal: String? = nil {
        didSet {
            UserDefaults.standard.set(logSearchWordNormal, forKey: "logSearchWordNormal_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var logSearchWordRN: String? = nil {
        didSet {
            UserDefaults.standard.set(logSearchWordRN, forKey: "logSearchWordRN_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var logSearchWordWeb: String? = nil {
        didSet {
            UserDefaults.standard.set(logSearchWordWeb, forKey: "logSearchWordWeb_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var networkSearchWord: String? = nil {
        didSet {
            UserDefaults.standard.set(networkSearchWord, forKey: "networkSearchWord_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var mainColor: String {
        didSet {
            UserDefaults.standard.set(mainColor, forKey: "mainColor_CocoaDebug")
            UserDefaults.standard.synchronize()
            _NetworkHelper.shared().mainColor = mainColor.hexColor
        }
    }
    @objc public var additionalViewController: UIViewController? = nil
    
    //share via email
    @objc public var emailToRecipients: [String]? = nil
    @objc public var emailCcRecipients: [String]? = nil
    
    //objc
    
    @objc public var ignoredURLs: [String]? = nil {
        didSet {
            _NetworkHelper.shared().ignoredURLs = ignoredURLs
        }
    }
    @objc public var onlyURLs: [String]? = nil {
        didSet {
            _NetworkHelper.shared().onlyURLs = onlyURLs
        }
    }
    
    @objc public var ignoredPrefixLogs: [String]? = nil {
        didSet {
            _NetworkHelper.shared().ignoredPrefixLogs = ignoredPrefixLogs
        }
    }
    @objc public var onlyPrefixLogs: [String]? = nil {
        didSet {
            _NetworkHelper.shared().onlyPrefixLogs = onlyPrefixLogs
        }
    }
    
    //protobuf
    @objc public var protobufTransferMap: [String: [String]]? = nil {
        didSet {
            _NetworkHelper.shared().protobufTransferMap = protobufTransferMap
        }
    }
    
    private override init() {
        responseShake = UserDefaults.standard.bool(forKey: "responseShake_CocoaDebug")
        firstIn = UserDefaults.standard.string(forKey: "firstIn_CocoaDebug")
        serverURL = UserDefaults.standard.string(forKey: "serverURL_CocoaDebug")
        visible = UserDefaults.standard.bool(forKey: "visible_CocoaDebug")
        showBubbleAndWindow = UserDefaults.standard.bool(forKey: "showBubbleAndWindow_CocoaDebug")
        enableCrashRecording = UserDefaults.standard.bool(forKey: "enableCrashRecording_CocoaDebug")
        enableUIBlockingMonitoring = UserDefaults.standard.bool(forKey: "enableUIBlockingMonitoring_CocoaDebug")
        enableWKWebViewMonitoring = UserDefaults.standard.bool(forKey: "enableWKWebViewMonitoring_CocoaDebug")
        enableLogMonitoring = UserDefaults.standard.bool(forKey: "enableLogMonitoring_CocoaDebug")
        disableNetworkMonitoring = UserDefaults.standard.bool(forKey: "disableNetworkMonitoring_CocoaDebug")
        enableRNMonitoring = UserDefaults.standard.bool(forKey: "enableRNMonitoring_CocoaDebug")
        tabBarSelectItem = UserDefaults.standard.integer(forKey: "tabBarSelectItem_CocoaDebug")
        logSelectIndex = UserDefaults.standard.integer(forKey: "logSelectIndex_CocoaDebug")
        networkLastIndex = UserDefaults.standard.integer(forKey: "networkLastIndex_CocoaDebug")
        bubbleFrameX = UserDefaults.standard.float(forKey: "bubbleFrameX_CocoaDebug")
        bubbleFrameY = UserDefaults.standard.float(forKey: "bubbleFrameY_CocoaDebug")
        logSearchWordNormal = UserDefaults.standard.string(forKey: "logSearchWordNormal_CocoaDebug")
        logSearchWordRN = UserDefaults.standard.string(forKey: "logSearchWordRN_CocoaDebug")
        logSearchWordWeb = UserDefaults.standard.string(forKey: "logSearchWordWeb_CocoaDebug")
        networkSearchWord = UserDefaults.standard.string(forKey: "networkSearchWord_CocoaDebug")
        mainColor = UserDefaults.standard.string(forKey: "mainColor_CocoaDebug") ?? "#42d459"
        
        
        //objc

        ignoredURLs = _NetworkHelper.shared().ignoredURLs
        onlyURLs = _NetworkHelper.shared().onlyURLs
        
        ignoredPrefixLogs = _NetworkHelper.shared().ignoredPrefixLogs
        onlyPrefixLogs = _NetworkHelper.shared().onlyPrefixLogs
        
        //protobuf
        protobufTransferMap = _NetworkHelper.shared().protobufTransferMap
        
        //Memory
        enableMemoryLeaksMonitoring_ViewController = UserDefaults.standard.bool(forKey: "enableMemoryLeaksMonitoring_UIViewController_CocoaDebug")
        enableMemoryLeaksMonitoring_View = UserDefaults.standard.bool(forKey: "enableMemoryLeaksMonitoring_UIView_CocoaDebug")
        enableMemoryLeaksMonitoring_MemberVariables = UserDefaults.standard.bool(forKey: "enableMemoryLeaksMonitoring_MemberVariables_CocoaDebug")
    }
}
