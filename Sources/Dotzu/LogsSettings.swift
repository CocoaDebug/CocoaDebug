//
//  LogsSettings.swift
//  exampleWindow
//
//  Created by Remi Robert on 18/01/2017.
//  Copyright © 2017 Remi Robert. All rights reserved.
//

import Foundation

public class LogsSettings {

    public static let shared = LogsSettings()

    public var showBallAndWindow: Bool = false {
        didSet {
            UserDefaults.standard.set(showBallAndWindow, forKey: "showBallAndWindow")
            UserDefaults.standard.synchronize()
            
            let x = DotzuManager.shared.controller.logHeadView.frame.origin.x
            let width = DotzuManager.shared.controller.logHeadView.frame.size.width
            
            if showBallAndWindow == true
            {
                if x > 0 {
                    DotzuManager.shared.controller.logHeadView.frame.origin.x = UIScreen.main.bounds.size.width - width/8*7
                }else{
                    DotzuManager.shared.controller.logHeadView.frame.origin.x = -width + width/8*7
                }
                DotzuManager.shared.enable()
            }
            else
            {
                if x > 0 {
                    DotzuManager.shared.controller.logHeadView.frame.origin.x = UIScreen.main.bounds.size.width
                }else{
                    DotzuManager.shared.controller.logHeadView.frame.origin.x = -width
                }
                DotzuManager.shared.disable()
            }
        }
    }
    public var serverURL: String? = nil {
        didSet {
            UserDefaults.standard.set(serverURL, forKey: "serverURL")
            UserDefaults.standard.synchronize()
        }
    }
    public var tabBarSelectItem: Int {
        didSet {
            UserDefaults.standard.set(tabBarSelectItem, forKey: "tabBarSelectItem")
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
    public var maxLogsCount: Int {
        didSet {
            UserDefaults.standard.set(maxLogsCount, forKey: "maxLogsCount")
            UserDefaults.standard.synchronize()
            JxbDebugTool.shareInstance().maxLogsCount = maxLogsCount
        }
    }
    public var logHeadFrameX: Float {
        didSet {
            UserDefaults.standard.set(logHeadFrameX, forKey: "logHeadFrameX")
            UserDefaults.standard.synchronize()
        }
    }
    public var logHeadFrameY: Float {
        didSet {
            UserDefaults.standard.set(logHeadFrameY, forKey: "logHeadFrameY")
            UserDefaults.standard.synchronize()
        }
    }
    public var logSearchWord: String? = nil {
        didSet {
            UserDefaults.standard.set(logSearchWord, forKey: "logSearchWord")
            UserDefaults.standard.synchronize()
        }
    }
    public var networkSearchWord: String? = nil {
        didSet {
            UserDefaults.standard.set(networkSearchWord, forKey: "networkSearchWord")
            UserDefaults.standard.synchronize()
        }
    }
    public var tabBarControllers: [UIViewController]? = nil
    
    
    
    private init()
    {
        serverURL = UserDefaults.standard.string(forKey: "serverURL") ?? ""
        maxLogsCount = UserDefaults.standard.integer(forKey: "maxLogsCount")
        showBallAndWindow = UserDefaults.standard.bool(forKey: "showBallAndWindow")
        tabBarSelectItem = UserDefaults.standard.integer(forKey: "tabBarSelectItem")
        logHeadFrameX = UserDefaults.standard.float(forKey: "logHeadFrameX")
        logHeadFrameY = UserDefaults.standard.float(forKey: "logHeadFrameY")
        logSearchWord = UserDefaults.standard.string(forKey: "logSearchWord") ?? ""
        networkSearchWord = UserDefaults.standard.string(forKey: "networkSearchWord") ?? ""
    }
}
