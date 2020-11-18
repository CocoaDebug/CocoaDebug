//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
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
            } else {
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
    func jsonStringToPrettyJsonString() -> String? {
        return self.stringToDictionary()?.dictionaryToString()
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
        //1.pretty json
        if let str = self.dataToDictionary()?.dictionaryToString() {
            return str
        } else {
            //2.protobuf
            if let message = try? _GPBMessage.parse(from: self) {
                if message.serializedSize() > 0 {
                    return message.description
                } else {
                    //3.utf-8 string
                    return String(data: self, encoding: .utf8)
                }
            } else {
                //3.utf-8 string
                return String(data: self, encoding: .utf8)
            }
        }
    }
}

//MARK: - *********************************************************************

//https://gist.github.com/arshad/de147c42d7b3063ef7bc
///Color
extension String {
    var hexColor: UIColor {
        let hex = trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        var a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return .clear
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

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
        } else {
            DispatchQueue.main.async( execute: {
                callback()
            })
        }
    }
}

//https://stackoverflow.com/questions/26244293/scrolltorowatindexpath-with-uitableview-does-not-work
///tableView
extension UITableView {
    func tableViewScrollToBottom(animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
            let numberOfSections = self.numberOfSections
            let numberOfRows = self.numberOfRows(inSection: numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = IndexPath(row: numberOfRows-1, section: (numberOfSections-1))
                self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }
    
    func tableViewScrollToIndex(index: Int, animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1)) {
            self.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: animated)
        }
    }
    
    func tableViewScrollToHeader(animated: Bool) {
        self.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: animated)
    }
    
    func reloadData(completion: @escaping () -> ()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData()})
        {_ in completion() }
    }
}

///shake
extension UIWindow {
    
    private static var _myComputedProperty = [String:Bool]()
    
    var myComputedProperty:Bool {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            return UIWindow._myComputedProperty[tmpAddress] ?? false
        }
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            UIWindow._myComputedProperty[tmpAddress] = newValue
        }
    }
    
    
    open override var canBecomeFirstResponder: Bool {
        return true
    }
    
    open override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
        
        self.myComputedProperty = true

        if CocoaDebugSettings.shared.responseShake == false {return}
        if motion == .motionShake {
            if CocoaDebugSettings.shared.visible == true { return }
            CocoaDebugSettings.shared.showBubbleAndWindow = !CocoaDebugSettings.shared.showBubbleAndWindow
        }
    }
    
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        
        if self.myComputedProperty == true {
            self.myComputedProperty = false
            return
        }
        
        if CocoaDebugSettings.shared.responseShake == false {return}
        if motion == .motionShake {
            if CocoaDebugSettings.shared.visible == true { return }
            CocoaDebugSettings.shared.showBubbleAndWindow = !CocoaDebugSettings.shared.showBubbleAndWindow
        }
    }
}


///CocoaDebug
extension CocoaDebug {
    
    ///init
    static func initializationMethod(serverURL: String? = nil, ignoredURLs: [String]? = nil, onlyURLs: [String]? = nil, additionalViewController: UIViewController? = nil, emailToRecipients: [String]? = nil, emailCcRecipients: [String]? = nil, mainColor: String? = nil, protobufTransferMap: [String: [String]]? = nil)
    {
        if CocoaDebugSettings.shared.isRunning == true {return}
        
        CocoaDebugSettings.shared.isRunning = true

        
        let enableCrashRecording = UserDefaults.standard.bool(forKey: "enableCrashRecording_CocoaDebug")
        let disableLogMonitoring = UserDefaults.standard.bool(forKey: "disableLogMonitoring_CocoaDebug")
        let disableNetworkMonitoring = UserDefaults.standard.bool(forKey: "disableNetworkMonitoring_CocoaDebug")
        let enableWKWebViewMonitoring = UserDefaults.standard.bool(forKey: "enableWKWebViewMonitoring_CocoaDebug")

        if serverURL == nil {
            CocoaDebugSettings.shared.serverURL = ""
        } else {
            CocoaDebugSettings.shared.serverURL = serverURL
        }
        if onlyURLs == nil {
            CocoaDebugSettings.shared.onlyURLs = []
        } else {
            CocoaDebugSettings.shared.onlyURLs = onlyURLs
        }
        if ignoredURLs == nil {
            CocoaDebugSettings.shared.ignoredURLs = []
        } else {
            CocoaDebugSettings.shared.ignoredURLs = ignoredURLs
        }
        if CocoaDebugSettings.shared.firstIn == nil {//first launch
            CocoaDebugSettings.shared.firstIn = ""
            CocoaDebugSettings.shared.showBubbleAndWindow = true
        } else {//not first launch
            CocoaDebugSettings.shared.showBubbleAndWindow = CocoaDebugSettings.shared.showBubbleAndWindow
        }
        
        CocoaDebugSettings.shared.visible = false
        CocoaDebugSettings.shared.logSearchWordDefault = nil
        CocoaDebugSettings.shared.logSearchWordColor = nil
        CocoaDebugSettings.shared.networkSearchWord = nil
        CocoaDebugSettings.shared.enableCrashRecording = enableCrashRecording
        CocoaDebugSettings.shared.enableWKWebViewMonitoring = enableWKWebViewMonitoring
        CocoaDebugSettings.shared.logMaxCount = CocoaDebug.logMaxCount
        CocoaDebugSettings.shared.protobufTransferMap = protobufTransferMap
        CocoaDebugSettings.shared.additionalViewController = additionalViewController
        
        var _ = _OCLogStoreManager.shared()
        CocoaDebugSettings.shared.responseShake = true
//        CocoaDebugSettings.shared.responseShakeNetworkDetail = true
        
        //share via email
        CocoaDebugSettings.shared.emailToRecipients = emailToRecipients
        CocoaDebugSettings.shared.emailCcRecipients = emailCcRecipients
        
        //color
        CocoaDebugSettings.shared.mainColor = mainColor ?? "#42d459"
        
        //slow animations
        CocoaDebugSettings.shared.slowAnimations = false
        
        //log
        if disableLogMonitoring == true {
            _LogHelper.shared.enable = false
            _OCLogHelper.shared()?.enable = false
        } else {
            _LogHelper.shared.enable = true
            _OCLogHelper.shared()?.enable = true
        }
        
        //network
        if disableNetworkMonitoring == true {
            _NetworkHelper.shared().disable()
        } else {
            _NetworkHelper.shared().enable()
        }
    }
    
    ///deinit
    static func deinitializationMethod() {
        CocoaDebugSettings.shared.isRunning = false
        WindowHelper.shared.disable()
        _NetworkHelper.shared().disable()
        _LogHelper.shared.enable = false
        _OCLogHelper.shared()?.enable = false
        CrashLogger.shared.enable = false
        CocoaDebugSettings.shared.responseShake = false
//        CocoaDebugSettings.shared.responseShakeNetworkDetail = false
    }
}


