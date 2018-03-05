//
//  DebugTool.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation

extension Dictionary {
    ///JSON/Form格式互转
    func dictionaryToFormString() -> String? {
        var array = [String]()
        
        for (key, value) in self {
            array.append(String(describing: key) + "=" + String(describing: value))
        }
        if array.count > 0 {
            return array.joined(separator: "&")
        }
        return nil
    }
}

extension String {
    ///JSON/Form格式互转
    func formStringToDictionary() -> [String: Any]? {
        var dictionary = [String: Any]()
        let array = self.components(separatedBy: "&")
        
        for str in array {
            let arr = str.components(separatedBy: "=")
            if arr.count == 2 {
                dictionary.updateValue(arr[1], forKey: arr[0])
            }else{
                return nil
            }
        }
        if dictionary.count > 0 {
            return dictionary
        }
        return nil
    }
}

//MARK: - *********************************************************************

extension Data {
    func dataToDictionary() -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: []) as? [String : Any]
        } catch {
        }
        return nil
    }
}

extension Dictionary {
    func dictionaryToData() -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        } catch {
        }
        return nil
    }
}

extension Data {
    func dataToString() -> String? {
        return String(bytes: self, encoding: .utf8)
    }
}

extension String {
    func stringToData() -> Data? {
        return self.data(using: .utf8)
    }
}

//MARK: - *********************************************************************

extension String {
    func stringToDictionary() -> [String: Any]? {
        return self.stringToData()?.dataToDictionary()
    }
}

extension Dictionary {
    func dictionaryToString() -> String? {
        return self.dictionaryToData()?.dataToString()
    }
}

extension String {
    func isValidURL() -> Bool {
        if let url = URL(string: self) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
}

extension String {
    func isValidJsonString() -> Bool {
        if let _ = self.stringToDictionary() {
            return true
        }
        return false
    }
}

extension String {
    func isValidFormString() -> Bool {
        if let _ = self.formStringToDictionary() {
            return true
        }
        return false
    }
}

extension String {
    func jsonStringToFormString() -> String? {
        return self.stringToDictionary()?.dictionaryToFormString()
    }
}

extension String {
    func formStringToJsonString() -> String? {
        return self.formStringToDictionary()?.dictionaryToString()
    }
}

extension String {
    func formStringToData() -> Data? {
        return self.formStringToDictionary()?.dictionaryToData()
    }
}

extension Data {
    func formDataToDictionary() -> [String: Any]? {
        return self.dataToString()?.formStringToDictionary()
    }
}

extension Data {
    func dataToPrettyPrintString() -> String? {
        return self.dataToDictionary()?.dictionaryToString()
    }
}

//MARK: - *********************************************************************

///添加圆角
extension UIView {
    func addCorner(roundingCorners: UIRectCorner, cornerSize: CGSize) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: roundingCorners, cornerRadii: cornerSize)
        let cornerLayer = CAShapeLayer()
        cornerLayer.frame = bounds
        cornerLayer.path = path.cgPath
        self.layer.mask = cornerLayer
    }
}

///主线程
extension NSObject {
    func dispatch_main_async_safe(callback: @escaping ()->Void ) {
        if Thread.isMainThread {
            callback()
        }else{
            DispatchQueue.main.async( execute: {
                callback()
            })
        }
    }
}

///alert
extension UIAlertController {
    static func showError(title: String?, controller: UIViewController?) {
        weak var weakVC = controller
        
        let alert = self.init(title: title, message: nil, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        weakVC?.present(alert, animated: true, completion: nil)
    }
}

///shake
extension UIWindow {
    open override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
//        if event?.type == .motion && event?.subtype == .motionShake {/*shake*/}
        if motion == .motionShake {
            if DebugToolSettings.shared.visible == true {return}
            DebugToolSettings.shared.showDebugToolBubbleAndWindow = !DebugToolSettings.shared.showDebugToolBubbleAndWindow
        }
    }
}

///DebugTool initialization
extension DebugTool {
    static func initializationMethod(serverURL: String? = nil, ignoredURLs: [String]? = nil, onlyURLs: [String]? = nil, tabBarControllers: [UIViewController]? = nil, recordCrash: Bool = false)
    {
        if serverURL == nil {
            DebugToolSettings.shared.serverURL = ""
        }else{
            DebugToolSettings.shared.serverURL = serverURL
        }
        if tabBarControllers == nil {
            DebugToolSettings.shared.tabBarControllers = []
        }else{
            DebugToolSettings.shared.tabBarControllers = tabBarControllers
        }
        if onlyURLs == nil {
            DebugToolSettings.shared.onlyURLs = []
        }else{
            DebugToolSettings.shared.onlyURLs = onlyURLs
        }
        if ignoredURLs == nil {
            DebugToolSettings.shared.ignoredURLs = []
        }else{
            DebugToolSettings.shared.ignoredURLs = ignoredURLs
        }
        if DebugToolSettings.shared.firstIn == nil {//first launch
            DebugToolSettings.shared.firstIn = ""
            DebugToolSettings.shared.showDebugToolBubbleAndWindow = true
        }else{//not first launch
            DebugToolSettings.shared.showDebugToolBubbleAndWindow = DebugToolSettings.shared.showDebugToolBubbleAndWindow
        }
        if DebugToolSettings.shared.showDebugToolBubbleAndWindow == true {
            WindowHelper.shared.enable()
        }
        
        DebugToolSettings.shared.visible = false
        DebugToolSettings.shared.logSearchWord = nil
        DebugToolSettings.shared.networkSearchWord = nil
        DebugToolSettings.shared.recordCrash = recordCrash
        
        let _ = LogStoreManager.shared
        NetworkHelper.shared().enable()
    }
}


