//
//  DebugMan.swift
//  PhiSpeaker
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Phicomm. All rights reserved.
//

import Foundation
import UIKit

public class DebugMan : NSObject {
    
    //MARK: - ****************** Usage of DebugMan ******************
    
    /// launchShow: Whether to display the debug panel ball when APP launch. the default display (是否APP启动时就显示调试面板球, 默认显示) |
    /// serverURL: if the catched URLs contain server URL ,set these URLs bold font to be marked. not mark when this value is nil by default (加粗标记服务器地址URL, 为nil就不标记, 默认值为nil) |
    /// ignoredURLs: Set the URLs which should not catched, ignoring case, catch all URLs when the value is nil. the default is nil (设置不抓取的域名, 忽略大小写, 为nil时默认抓取所有, 默认值为nil) |
    /// onlyURLs: Set the URLs which are only catched, ignoring case, catch all URLs when the value is nil. the default is nil (设置只抓取的域名, 忽略大小写, 为nil时默认抓取所有, 默认值为nil) |
    /// maxLogsCount: Custom set "Logs/Network/Crash" maximum record amount, the default is 100 (if exceed maximum record amount, DebugMan will automatically clear the earliest record, and update the recent record. so do not worry) (自定义logs/network/crash最大记录, 默认100条 (超过会自动清除最早的记录,并更新最近记录. 所以不必担心)) |
    /// tabBarControllers: custom controllers to be added as child controllers of UITabBarController. the default is none (给UITabBarController增加的自定义子控制器, 默认没有) |
    public func enable(_ launchShow: Bool = true, serverURL: String? = nil, ignoredURLs: [String]? = nil, onlyURLs: [String]? = nil, maxLogsCount: Int = 100, tabBarControllers: [UIViewController]? = nil) {
        
        if serverURL == nil {
            LogsSettings.shared.serverURL = ""
        }else{
            LogsSettings.shared.serverURL = serverURL
        }
        if tabBarControllers == nil {
            LogsSettings.shared.tabBarControllers = []
        }else{
            LogsSettings.shared.tabBarControllers = tabBarControllers
        }
        if onlyURLs == nil {
            LogsSettings.shared.onlyURLs = []
        }else{
            LogsSettings.shared.onlyURLs = onlyURLs
        }
        if ignoredURLs == nil {
            LogsSettings.shared.ignoredURLs = []
        }else{
            LogsSettings.shared.ignoredURLs = ignoredURLs
        }

        Dotzu.sharedManager.enable()
        JxbDebugTool.shareInstance().enable()
        LogsSettings.shared.showBall = true
        LogsSettings.shared.maxLogsCount = maxLogsCount
        
        if launchShow == true {
            LogsSettings.shared.showBall = true
        }else{
            LogsSettings.shared.showBall = false
        }
    }
    
    /*
    //MARK: - private method
    private func disable() {
        Dotzu.sharedManager.disable()
        JxbDebugTool.shareInstance().disable()
        LogsSettings.shared.showBall = false
    }
    */
    
    //MARK: - init method
    public static let shared = DebugMan()
    private override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(methodThatIsCalledAfterShake), name: NSNotification.Name(DHCSHakeNotificationName), object: nil)
        
        LogsSettings.shared.logSearchWord = nil
        LogsSettings.shared.networkSearchWord = nil
        
        let _ = StoreManager.shared
    }
    
    //MARK: - deinit method
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - notification method
    @objc private func methodThatIsCalledAfterShake() {
        LogsSettings.shared.showBall = !LogsSettings.shared.showBall
    }
}
