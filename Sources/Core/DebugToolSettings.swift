//
//  DebugTool.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation

@objc public class DebugToolSettings: NSObject {

    @objc public static let shared = DebugToolSettings()

    @objc public var firstIn: String? = nil {
        didSet {
            UserDefaults.standard.set(firstIn, forKey: "firstIn_DebugTool")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var recordCrash: Bool = false {
        didSet {
            UserDefaults.standard.set(recordCrash, forKey: "recordCrash_DebugTool")
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
            UserDefaults.standard.set(visible, forKey: "visible_DebugTool")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var showDebugToolBubbleAndWindow: Bool = false {
        didSet {
            UserDefaults.standard.set(showDebugToolBubbleAndWindow, forKey: "showDebugToolBubbleAndWindow_DebugTool")
            UserDefaults.standard.synchronize()
            
            let x = WindowHelper.shared.vc.bubble.frame.origin.x
            let width = WindowHelper.shared.vc.bubble.frame.size.width
            
            if showDebugToolBubbleAndWindow == true
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
            UserDefaults.standard.set(serverURL, forKey: "serverURL_DebugTool")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var tabBarSelectItem: Int {
        didSet {
            UserDefaults.standard.set(tabBarSelectItem, forKey: "tabBarSelectItem_DebugTool")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var logSelectIndex: Int {
        didSet {
            UserDefaults.standard.set(logSelectIndex, forKey: "logSelectIndex_DebugTool")
            UserDefaults.standard.synchronize()
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
    @objc public var bubbleFrameX: Float {
        didSet {
            UserDefaults.standard.set(bubbleFrameX, forKey: "bubbleFrameX_DebugTool")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var bubbleFrameY: Float {
        didSet {
            UserDefaults.standard.set(bubbleFrameY, forKey: "bubbleFrameY_DebugTool")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var logSearchWord: String? = nil {
        didSet {
            UserDefaults.standard.set(logSearchWord, forKey: "logSearchWord_DebugTool")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var networkSearchWord: String? = nil {
        didSet {
            UserDefaults.standard.set(networkSearchWord, forKey: "networkSearchWord_DebugTool")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var tabBarControllers: [UIViewController]? = nil
    
    
    
    private override init() {
        firstIn = UserDefaults.standard.string(forKey: "firstIn_DebugTool")
        serverURL = UserDefaults.standard.string(forKey: "serverURL_DebugTool")
        visible = UserDefaults.standard.bool(forKey: "visible_DebugTool")
        showDebugToolBubbleAndWindow = UserDefaults.standard.bool(forKey: "showDebugToolBubbleAndWindow_DebugTool")
        recordCrash = UserDefaults.standard.bool(forKey: "recordCrash_DebugTool")
        tabBarSelectItem = UserDefaults.standard.integer(forKey: "tabBarSelectItem_DebugTool")
        logSelectIndex = UserDefaults.standard.integer(forKey: "logSelectIndex_DebugTool")
        bubbleFrameX = UserDefaults.standard.float(forKey: "bubbleFrameX_DebugTool")
        bubbleFrameY = UserDefaults.standard.float(forKey: "bubbleFrameY_DebugTool")
        logSearchWord = UserDefaults.standard.string(forKey: "logSearchWord_DebugTool")
        networkSearchWord = UserDefaults.standard.string(forKey: "networkSearchWord_DebugTool")
    }
}
