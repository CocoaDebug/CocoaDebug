//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import Foundation

@objc public class CocoaDebugSettings: NSObject {

    @objc public static let shared = CocoaDebugSettings()

    @objc public var responseShake: Bool = false {
        didSet {
            UserDefaults.standard.set(responseShake, forKey: "responseShake_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var responseShakeNetworkDetail: Bool = false {
        didSet {
            UserDefaults.standard.set(responseShakeNetworkDetail, forKey: "responseShakeNetworkDetail_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var firstIn: String? = nil {
        didSet {
            UserDefaults.standard.set(firstIn, forKey: "firstIn_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var recordCrash: Bool = false {
        didSet {
            UserDefaults.standard.set(recordCrash, forKey: "recordCrash_CocoaDebug")
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
    @objc public var logSearchWordDefault: String? = nil {
        didSet {
            UserDefaults.standard.set(logSearchWordDefault, forKey: "logSearchWordDefault_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var logSearchWordColor: String? = nil {
        didSet {
            UserDefaults.standard.set(logSearchWordColor, forKey: "logSearchWordColor_CocoaDebug")
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
            NetworkHelper.shared().mainColor = mainColor.hexColor
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
        responseShake = UserDefaults.standard.bool(forKey: "responseShake_CocoaDebug")
        responseShakeNetworkDetail = UserDefaults.standard.bool(forKey: "responseShakeNetworkDetail_CocoaDebug")
        firstIn = UserDefaults.standard.string(forKey: "firstIn_CocoaDebug")
        serverURL = UserDefaults.standard.string(forKey: "serverURL_CocoaDebug")
        visible = UserDefaults.standard.bool(forKey: "visible_CocoaDebug")
        showBubbleAndWindow = UserDefaults.standard.bool(forKey: "showBubbleAndWindow_CocoaDebug")
        recordCrash = UserDefaults.standard.bool(forKey: "recordCrash_CocoaDebug")
        tabBarSelectItem = UserDefaults.standard.integer(forKey: "tabBarSelectItem_CocoaDebug")
        logSelectIndex = UserDefaults.standard.integer(forKey: "logSelectIndex_CocoaDebug")
        bubbleFrameX = UserDefaults.standard.float(forKey: "bubbleFrameX_CocoaDebug")
        bubbleFrameY = UserDefaults.standard.float(forKey: "bubbleFrameY_CocoaDebug")
        logSearchWordDefault = UserDefaults.standard.string(forKey: "logSearchWordDefault_CocoaDebug")
        logSearchWordColor = UserDefaults.standard.string(forKey: "logSearchWordColor_CocoaDebug")
        networkSearchWord = UserDefaults.standard.string(forKey: "networkSearchWord_CocoaDebug")
        mainColor = UserDefaults.standard.string(forKey: "mainColor_CocoaDebug") ?? "#42d459"

        //objc
        logMaxCount = NetworkHelper.shared().logMaxCount
        onlyURLs = NetworkHelper.shared().onlyURLs
        ignoredURLs = NetworkHelper.shared().ignoredURLs
    }
}
