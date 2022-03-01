//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import Foundation

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


///CocoaDebug
extension CocoaDebug {
    
    ///init
    static func initializationMethod(serverURL: String? = nil, ignoredURLs: [String]? = nil, onlyURLs: [String]? = nil, ignoredPrefixLogs: [String]? = nil, onlyPrefixLogs: [String]? = nil, additionalViewController: UIViewController? = nil, emailToRecipients: [String]? = nil, emailCcRecipients: [String]? = nil, mainColor: String? = nil, protobufTransferMap: [String: [String]]? = nil)
    {
        if CocoaDebugSettings.shared.firstIn == nil {//first launch
            CocoaDebugSettings.shared.firstIn = ""
            CocoaDebugSettings.shared.showBubbleAndWindow = true
        } else {//not first launch
            CocoaDebugSettings.shared.showBubbleAndWindow = CocoaDebugSettings.shared.showBubbleAndWindow
        }
        
        CocoaDebugSettings.shared.visible = false

        CocoaDebugSettings.shared.additionalViewController = additionalViewController
        
        
        //share via email
        CocoaDebugSettings.shared.emailToRecipients = emailToRecipients
        CocoaDebugSettings.shared.emailCcRecipients = emailCcRecipients
        
        //color
        CocoaDebugSettings.shared.mainColor = mainColor ?? "#42d459"
        
        //slow animations
        CocoaDebugSettings.shared.slowAnimations = false
        
    }
    
    ///deinit
    static func deinitializationMethod() {
        WindowHelper.shared.disable()
    }
}


