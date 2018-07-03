//
//  DebugWidget.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation

@objc public class DebugWidgetSettings: NSObject {

    @objc public static let shared = DebugWidgetSettings()

    @objc public var responseShake: Bool = false {
        didSet {
            UserDefaults.standard.set(responseShake, forKey: "responseShake_DebugWidget")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var responseShakeNetworkDetail: Bool = false {
        didSet {
            UserDefaults.standard.set(responseShakeNetworkDetail, forKey: "responseShakeNetworkDetail_DebugWidget")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var firstIn: String? = nil {
        didSet {
            UserDefaults.standard.set(firstIn, forKey: "firstIn_DebugWidget")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var recordCrash: Bool = false {
        didSet {
            UserDefaults.standard.set(recordCrash, forKey: "recordCrash_DebugWidget")
            UserDefaults.standard.synchronize()
            
            if recordCrash == true {
                CrashLogger.shared.enable = true
            }else{
                CrashStoreManager.shared.resetCrashs()
            }
        }
    }
    @objc public var visible: Bool = false {
        didSet {
            UserDefaults.standard.set(visible, forKey: "visible_DebugWidget")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var showDebugWidgetBubbleAndWindow: Bool = false {
        didSet {
            UserDefaults.standard.set(showDebugWidgetBubbleAndWindow, forKey: "showDebugWidgetBubbleAndWindow_DebugWidget")
            UserDefaults.standard.synchronize()
            
            let x = WindowHelper.shared.vc.bubble.frame.origin.x
            let width = WindowHelper.shared.vc.bubble.frame.size.width
            
            if showDebugWidgetBubbleAndWindow == true
            {
                if x > 0 {
                    WindowHelper.shared.vc.bubble.frame.origin.x = UIScreen.main.bounds.size.width - width/8*7
                }else{
                    WindowHelper.shared.vc.bubble.frame.origin.x = -width + width/8*7
                }
                WindowHelper.shared.enable()
            }
            else
            {
                if x > 0 {
                    WindowHelper.shared.vc.bubble.frame.origin.x = UIScreen.main.bounds.size.width
                }else{
                    WindowHelper.shared.vc.bubble.frame.origin.x = -width
                }
                WindowHelper.shared.disable()
            }
        }
    }
    @objc public var serverURL: String? = nil {
        didSet {
            UserDefaults.standard.set(serverURL, forKey: "serverURL_DebugWidget")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var tabBarSelectItem: Int {
        didSet {
            UserDefaults.standard.set(tabBarSelectItem, forKey: "tabBarSelectItem_DebugWidget")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var logSelectIndex: Int {
        didSet {
            UserDefaults.standard.set(logSelectIndex, forKey: "logSelectIndex_DebugWidget")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var bubbleFrameX: Float {
        didSet {
            UserDefaults.standard.set(bubbleFrameX, forKey: "bubbleFrameX_DebugWidget")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var bubbleFrameY: Float {
        didSet {
            UserDefaults.standard.set(bubbleFrameY, forKey: "bubbleFrameY_DebugWidget")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var logSearchWordDefault: String? = nil {
        didSet {
            UserDefaults.standard.set(logSearchWordDefault, forKey: "logSearchWordDefault_DebugWidget")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var logSearchWordColor: String? = nil {
        didSet {
            UserDefaults.standard.set(logSearchWordColor, forKey: "logSearchWordColor_DebugWidget")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var networkSearchWord: String? = nil {
        didSet {
            UserDefaults.standard.set(networkSearchWord, forKey: "networkSearchWord_DebugWidget")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var tabBarControllers: [UIViewController]? = nil
    
    //share via email
    @objc public var emailToRecipients: [String]? = nil
    @objc public var emailCcRecipients: [String]? = nil
    
    //objc
    @objc public var logMaxCount: Int {
        didSet {
            NetworkHelper.shared().logMaxCount = logMaxCount
        }
    }
    @objc public var onlyURLs: [String]? = nil {
        didSet {
            NetworkHelper.shared().onlyURLs = onlyURLs
        }
    }
    @objc public var ignoredURLs: [String]? = nil {
        didSet {
            NetworkHelper.shared().ignoredURLs = ignoredURLs
        }
    }
    
    
    
    private override init() {
        responseShake = UserDefaults.standard.bool(forKey: "responseShake_DebugWidget")
        responseShakeNetworkDetail = UserDefaults.standard.bool(forKey: "responseShakeNetworkDetail_DebugWidget")
        firstIn = UserDefaults.standard.string(forKey: "firstIn_DebugWidget")
        serverURL = UserDefaults.standard.string(forKey: "serverURL_DebugWidget")
        visible = UserDefaults.standard.bool(forKey: "visible_DebugWidget")
        showDebugWidgetBubbleAndWindow = UserDefaults.standard.bool(forKey: "showDebugWidgetBubbleAndWindow_DebugWidget")
        recordCrash = UserDefaults.standard.bool(forKey: "recordCrash_DebugWidget")
        tabBarSelectItem = UserDefaults.standard.integer(forKey: "tabBarSelectItem_DebugWidget")
        logSelectIndex = UserDefaults.standard.integer(forKey: "logSelectIndex_DebugWidget")
        bubbleFrameX = UserDefaults.standard.float(forKey: "bubbleFrameX_DebugWidget")
        bubbleFrameY = UserDefaults.standard.float(forKey: "bubbleFrameY_DebugWidget")
        logSearchWordDefault = UserDefaults.standard.string(forKey: "logSearchWordDefault_DebugWidget")
        logSearchWordColor = UserDefaults.standard.string(forKey: "logSearchWordColor_DebugWidget")
        networkSearchWord = UserDefaults.standard.string(forKey: "networkSearchWord_DebugWidget")
        
        //objc
        logMaxCount = NetworkHelper.shared().logMaxCount
        onlyURLs = NetworkHelper.shared().onlyURLs
        ignoredURLs = NetworkHelper.shared().ignoredURLs
    }
}
