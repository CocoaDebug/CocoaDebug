//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
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

//https://gist.github.com/arshad/de147c42d7b3063ef7bc
///Color
extension String {
    var hexColor: UIColor {
        let hex = trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
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
        }else{
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
}

///shake
extension UIWindow {
    open override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        
        if CocoaDebugSettings.shared.responseShakeNetworkDetail == false {return}
        
        if CocoaDebugSettings.shared.responseShake == false {return}
        
//        if event?.type == .motion && event?.subtype == .motionShake {/*shake*/}
        if motion == .motionShake {
            if CocoaDebugSettings.shared.visible == true {
                dispatch_main_async_safe {
                    NotificationCenter.default.post(name: NSNotification.Name("motionShake_CocoaDebug"), object: nil, userInfo: nil)
                }
                return
            }
            CocoaDebugSettings.shared.showBubbleAndWindow = !CocoaDebugSettings.shared.showBubbleAndWindow
        }
    }
}

///add FPSLabel behind status bar
extension UIViewController {
    func addStatusBarBackgroundView(viewController: UIViewController) -> Void {
//        var rect = CGRect(origin: CGPoint(x: UIScreen.main.bounds.size.width/2.0, y: 0), size:CGSize(width: UIScreen.main.bounds.size.width/2.0, height:20))
//
//        if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436 {
//            //iPhone X
//            rect.origin.y = 30
//        }
//
//        let label : FPSLabel = FPSLabel.init(frame: rect)
//        label.adjustsFontSizeToFitWidth = true //sublabel.sizeToFit()
////        viewController.view?.addSubview(label)
//        viewController.navigationController?.view.addSubview(label)
    }
}


///CocoaDebug
extension CocoaDebug {
    
    ///init
    static func initializationMethod(serverURL: String? = nil, ignoredURLs: [String]? = nil, onlyURLs: [String]? = nil, tabBarControllers: [UIViewController]? = nil, recordCrash: Bool = false, emailToRecipients: [String]? = nil, emailCcRecipients: [String]? = nil, mainColor: String? = nil)
    {
        if serverURL == nil {
            CocoaDebugSettings.shared.serverURL = ""
        }else{
            CocoaDebugSettings.shared.serverURL = serverURL
        }
        if tabBarControllers == nil {
            CocoaDebugSettings.shared.tabBarControllers = []
        }else{
            CocoaDebugSettings.shared.tabBarControllers = tabBarControllers
        }
        if onlyURLs == nil {
            CocoaDebugSettings.shared.onlyURLs = []
        }else{
            CocoaDebugSettings.shared.onlyURLs = onlyURLs
        }
        if ignoredURLs == nil {
            CocoaDebugSettings.shared.ignoredURLs = []
        }else{
            CocoaDebugSettings.shared.ignoredURLs = ignoredURLs
        }
        if CocoaDebugSettings.shared.firstIn == nil {//first launch
            CocoaDebugSettings.shared.firstIn = ""
            CocoaDebugSettings.shared.showBubbleAndWindow = true
        }else{//not first launch
            CocoaDebugSettings.shared.showBubbleAndWindow = CocoaDebugSettings.shared.showBubbleAndWindow
        }
        if CocoaDebugSettings.shared.showBubbleAndWindow == true {
            WindowHelper.shared.enable()
        }
        
        CocoaDebugSettings.shared.visible = false
        CocoaDebugSettings.shared.logSearchWordDefault = nil
        CocoaDebugSettings.shared.logSearchWordColor = nil
        CocoaDebugSettings.shared.networkSearchWord = nil
        CocoaDebugSettings.shared.recordCrash = recordCrash
        CocoaDebugSettings.shared.logMaxCount = CocoaDebug.logMaxCount
        
        LogHelper.shared.enable = true
        let _ = LogStoreManager.shared
        NetworkHelper.shared().enable()
        CocoaDebugSettings.shared.responseShake = true
        CocoaDebugSettings.shared.responseShakeNetworkDetail = true
        
        //share via email
        CocoaDebugSettings.shared.emailToRecipients = emailToRecipients
        CocoaDebugSettings.shared.emailCcRecipients = emailCcRecipients
        
        //color
        CocoaDebugSettings.shared.mainColor = mainColor ?? "#42d459"
    }
    
    ///deinit
    static func deinitializationMethod() {
        WindowHelper.shared.disable()
        NetworkHelper.shared().disable()
        LogHelper.shared.enable = false
        CrashLogger.shared.enable = false
        CocoaDebugSettings.shared.responseShake = false
        CocoaDebugSettings.shared.responseShakeNetworkDetail = false
    }
}


