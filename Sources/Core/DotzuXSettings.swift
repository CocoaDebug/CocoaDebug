//
//  DotzuX.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation

@objc public class DotzuXSettings: NSObject {

    @objc public static let shared = DotzuXSettings()

    @objc public var firstIn: String? = nil {
        didSet {
            UserDefaults.standard.set(firstIn, forKey: "firstIn_DotzuX")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var recordCrash: Bool = false {
        didSet {
            UserDefaults.standard.set(recordCrash, forKey: "recordCrash_DotzuX")
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
            UserDefaults.standard.set(visible, forKey: "visible_DotzuX")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var showDotzuXBubbleAndWindow: Bool = false {
        didSet {
            UserDefaults.standard.set(showDotzuXBubbleAndWindow, forKey: "showDotzuXBubbleAndWindow_DotzuX")
            UserDefaults.standard.synchronize()
            
            let x = WindowHelper.shared.vc.bubble.frame.origin.x
            let width = WindowHelper.shared.vc.bubble.frame.size.width
            
            if showDotzuXBubbleAndWindow == true
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
            UserDefaults.standard.set(serverURL, forKey: "serverURL_DotzuX")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var tabBarSelectItem: Int {
        didSet {
            UserDefaults.standard.set(tabBarSelectItem, forKey: "tabBarSelectItem_DotzuX")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var logSelectIndex: Int {
        didSet {
            UserDefaults.standard.set(logSelectIndex, forKey: "logSelectIndex_DotzuX")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var bubbleFrameX: Float {
        didSet {
            UserDefaults.standard.set(bubbleFrameX, forKey: "bubbleFrameX_DotzuX")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var bubbleFrameY: Float {
        didSet {
            UserDefaults.standard.set(bubbleFrameY, forKey: "bubbleFrameY_DotzuX")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var logSearchWordDefault: String? = nil {
        didSet {
            UserDefaults.standard.set(logSearchWordDefault, forKey: "logSearchWordDefault_DotzuX")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var logSearchWordColor: String? = nil {
        didSet {
            UserDefaults.standard.set(logSearchWordColor, forKey: "logSearchWordColor_DotzuX")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var networkSearchWord: String? = nil {
        didSet {
            UserDefaults.standard.set(networkSearchWord, forKey: "networkSearchWord_DotzuX")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var tabBarControllers: [UIViewController]? = nil
    
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
        firstIn = UserDefaults.standard.string(forKey: "firstIn_DotzuX")
        serverURL = UserDefaults.standard.string(forKey: "serverURL_DotzuX")
        visible = UserDefaults.standard.bool(forKey: "visible_DotzuX")
        showDotzuXBubbleAndWindow = UserDefaults.standard.bool(forKey: "showDotzuXBubbleAndWindow_DotzuX")
        recordCrash = UserDefaults.standard.bool(forKey: "recordCrash_DotzuX")
        tabBarSelectItem = UserDefaults.standard.integer(forKey: "tabBarSelectItem_DotzuX")
        logSelectIndex = UserDefaults.standard.integer(forKey: "logSelectIndex_DotzuX")
        bubbleFrameX = UserDefaults.standard.float(forKey: "bubbleFrameX_DotzuX")
        bubbleFrameY = UserDefaults.standard.float(forKey: "bubbleFrameY_DotzuX")
        logSearchWordDefault = UserDefaults.standard.string(forKey: "logSearchWordDefault_DotzuX")
        logSearchWordColor = UserDefaults.standard.string(forKey: "logSearchWordColor_DotzuX")
        networkSearchWord = UserDefaults.standard.string(forKey: "networkSearchWord_DotzuX")
        
        //objc
        logMaxCount = NetworkHelper.shared().logMaxCount
        onlyURLs = NetworkHelper.shared().onlyURLs
        ignoredURLs = NetworkHelper.shared().ignoredURLs
    }
}
