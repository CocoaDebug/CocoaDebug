//
//  DebugMan.swift
//  PhiSpeaker
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Phicomm. All rights reserved.
//

import Foundation
import UIKit

@objc public class DebugMan : NSObject {
    
    //MARK: - ****************** Usage of DebugMan ******************
    
    /// serverURL: if the catched URLs contain server URL ,set these URLs bold font to be marked. not mark when this value is nil by default (加粗标记服务器地址URL, 为nil就不标记, 默认值为nil) |
    /// ignoredURLs: Set the URLs which should not catched, ignoring case, catch all URLs when the value is nil. the default is nil (设置不抓取的域名, 忽略大小写, 为nil时默认抓取所有, 默认值为nil) |
    /// onlyURLs: Set the URLs which are only catched, ignoring case, catch all URLs when the value is nil. the default is nil (设置只抓取的域名, 忽略大小写, 为nil时默认抓取所有, 默认值为nil) |
    /// tabBarControllers: custom controllers to be added as child controllers of UITabBarController. the default is none (给UITabBarController增加的自定义子控制器, 默认没有) |
    @objc public func enable(serverURL: String? = nil, ignoredURLs: [String]? = nil, onlyURLs: [String]? = nil, tabBarControllers: [UIViewController]? = nil) {
        
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
        
        
        if LogsSettings.shared.firstIn == nil { //first launch
            LogsSettings.shared.firstIn = ""
            LogsSettings.shared.showBallAndWindow = true
        }else{                                  //second launch
            LogsSettings.shared.showBallAndWindow = LogsSettings.shared.showBallAndWindow
        }
        
        if LogsSettings.shared.showBallAndWindow == true {
            DotzuManager.shared.enable()
        }
        
        JxbDebugTool.shareInstance().enable()
    }
    
    
    //MARK: - 暂时没用用到
//    @objc public func disable() {
//        DotzuManager.shared.disable()
//        JxbDebugTool.shareInstance().disable()
//    }
 
    
    //MARK: - init method
    @objc public static let shared = DebugMan()
    private override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(shake), name: NSNotification.Name("ShakeNotification_debugman"), object: nil)
        
        LogsSettings.shared.logSearchWord = nil
        LogsSettings.shared.networkSearchWord = nil
        
        let _ = StoreManager.shared
    }
    
    //MARK: - deinit method
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - notification method
    @objc private func shake() {
        LogsSettings.shared.showBallAndWindow = !LogsSettings.shared.showBallAndWindow
    }
}
