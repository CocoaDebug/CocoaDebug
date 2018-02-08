//
//  DebugManSettings.swift
//  example
//
//  Created by liman on 18/01/2017.
//  Copyright © 2017 liman. All rights reserved.
//

import Foundation

public class DebugManSettings {

    public static let shared = DebugManSettings()

    
    public var firstIn: String? = nil {
        didSet {
            UserDefaults.standard.set(firstIn, forKey: "firstIn_DebugMan")
            UserDefaults.standard.synchronize()
        }
    }
    public var recordCrash: Bool {
        didSet {
            UserDefaults.standard.set(recordCrash, forKey: "recordCrash_DebugMan")
            UserDefaults.standard.synchronize()
            
            if recordCrash == true {
                LoggerCrash.shared.enable = true
            }else{
                StoreManager.shared.resetCrashs()
            }
        }
    }
    public var visible: Bool {
        didSet {
            UserDefaults.standard.set(visible, forKey: "visible_DebugMan")
            UserDefaults.standard.synchronize()
        }
    }
    public var showBallAndWindow: Bool {
        didSet {
            UserDefaults.standard.set(showBallAndWindow, forKey: "showBallAndWindow_DebugMan")
            UserDefaults.standard.synchronize()
            
            let x = DotzuManager.shared.vc.logHeadView.frame.origin.x
            let width = DotzuManager.shared.vc.logHeadView.frame.size.width
            
            if showBallAndWindow == true
            {
                if x > 0 {
                    DotzuManager.shared.vc.logHeadView.frame.origin.x = UIScreen.main.bounds.size.width - width/8*7
                }else{
                    DotzuManager.shared.vc.logHeadView.frame.origin.x = -width + width/8*7
                }
                DotzuManager.shared.enable()
            }
            else
            {
                if x > 0 {
                    DotzuManager.shared.vc.logHeadView.frame.origin.x = UIScreen.main.bounds.size.width
                }else{
                    DotzuManager.shared.vc.logHeadView.frame.origin.x = -width
                }
                DotzuManager.shared.disable()
            }
        }
    }
    public var serverURL: String? = nil {
        didSet {
            UserDefaults.standard.set(serverURL, forKey: "serverURL_DebugMan")
            UserDefaults.standard.synchronize()
        }
    }
    public var tabBarSelectItem: Int {
        didSet {
            UserDefaults.standard.set(tabBarSelectItem, forKey: "tabBarSelectItem_DebugMan")
            UserDefaults.standard.synchronize()
        }
    }
    public var logSelectIndex: Int {
        didSet {
            UserDefaults.standard.set(logSelectIndex, forKey: "logSelectIndex_DebugMan")
            UserDefaults.standard.synchronize()
        }
    }
    public var onlyURLs: [String]? = nil {
        didSet {
            JxbDebugTool.shareInstance().onlyURLs = onlyURLs
        }
    }
    public var ignoredURLs: [String]? = nil {
        didSet {
            JxbDebugTool.shareInstance().ignoredURLs = ignoredURLs
        }
    }
    public var logHeadFrameX: Float {
        didSet {
            UserDefaults.standard.set(logHeadFrameX, forKey: "logHeadFrameX_DebugMan")
            UserDefaults.standard.synchronize()
        }
    }
    public var logHeadFrameY: Float {
        didSet {
            UserDefaults.standard.set(logHeadFrameY, forKey: "logHeadFrameY_DebugMan")
            UserDefaults.standard.synchronize()
        }
    }
    public var logSearchWord: String? = nil {
        didSet {
            UserDefaults.standard.set(logSearchWord, forKey: "logSearchWord_DebugMan")
            UserDefaults.standard.synchronize()
        }
    }
    public var networkSearchWord: String? = nil {
        didSet {
            UserDefaults.standard.set(networkSearchWord, forKey: "networkSearchWord_DebugMan")
            UserDefaults.standard.synchronize()
        }
    }
    public var tabBarControllers: [UIViewController]? = nil
    
    
    
    private init()
    {
        firstIn = UserDefaults.standard.string(forKey: "firstIn_DebugMan")
        serverURL = UserDefaults.standard.string(forKey: "serverURL_DebugMan")
        visible = UserDefaults.standard.bool(forKey: "visible_DebugMan")
        showBallAndWindow = UserDefaults.standard.bool(forKey: "showBallAndWindow_DebugMan")
        recordCrash = UserDefaults.standard.bool(forKey: "recordCrash_DebugMan")
        tabBarSelectItem = UserDefaults.standard.integer(forKey: "tabBarSelectItem_DebugMan")
        logSelectIndex = UserDefaults.standard.integer(forKey: "logSelectIndex_DebugMan")
        logHeadFrameX = UserDefaults.standard.float(forKey: "logHeadFrameX_DebugMan")
        logHeadFrameY = UserDefaults.standard.float(forKey: "logHeadFrameY_DebugMan")
        logSearchWord = UserDefaults.standard.string(forKey: "logSearchWord_DebugMan")
        networkSearchWord = UserDefaults.standard.string(forKey: "networkSearchWord_DebugMan")
    }
}
