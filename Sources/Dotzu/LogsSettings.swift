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

    public var showBall: Bool {
        didSet {
            UserDefaults.standard.set(showBall, forKey: "showBall")
            UserDefaults.standard.synchronize()
            
            let x = Dotzu.sharedManager.controller.logHeadView.frame.origin.x
            let width = Dotzu.sharedManager.controller.logHeadView.frame.size.width
            
            if showBall == true
            {
                if x > 0 {
                    Dotzu.sharedManager.controller.logHeadView.frame.origin.x = UIScreen.main.bounds.size.width - width/8*7
                }else{
                    Dotzu.sharedManager.controller.logHeadView.frame.origin.x = -width + width/8*7
                }
            }
            else
            {
                if x > 0 {
                    Dotzu.sharedManager.controller.logHeadView.frame.origin.x = UIScreen.main.bounds.size.width
                }else{
                    Dotzu.sharedManager.controller.logHeadView.frame.origin.x = -width
                }
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
        showBall = UserDefaults.standard.bool(forKey: "showBall")
        tabBarSelectItem = UserDefaults.standard.integer(forKey: "tabBarSelectItem")
        logHeadFrameX = UserDefaults.standard.float(forKey: "logHeadFrameX")
        logHeadFrameY = UserDefaults.standard.float(forKey: "logHeadFrameY")
        logSearchWord = UserDefaults.standard.string(forKey: "logSearchWord") ?? ""
        networkSearchWord = UserDefaults.standard.string(forKey: "networkSearchWord") ?? ""
    }
}
