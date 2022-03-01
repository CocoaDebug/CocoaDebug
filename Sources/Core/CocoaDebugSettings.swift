//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import Foundation

@objc public class CocoaDebugSettings: NSObject {
    
    @objc public static let shared = CocoaDebugSettings()
    
    @objc public var slowAnimations: Bool = false {
        didSet {            
            if slowAnimations == false {
                UIApplication.shared.windows.first?.layer.speed = 1;
            } else {
                UIApplication.shared.windows.first?.layer.speed = 0.1;
            }
        }
    }
    

    @objc public var firstIn: String? = nil {
        didSet {
            UserDefaults.standard.set(firstIn, forKey: "firstIn_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }

    @objc public var visible: Bool = false {
        didSet {
            UserDefaults.standard.set(visible, forKey: "visible_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var showBubbleAndWindow: Bool = false {
        didSet {
            UserDefaults.standard.set(showBubbleAndWindow, forKey: "showBubbleAndWindow_CocoaDebug")
            UserDefaults.standard.synchronize()
            
            let x = WindowHelper.shared.vc.bubble.frame.origin.x
            let width = WindowHelper.shared.vc.bubble.frame.size.width
            
            if showBubbleAndWindow == true
            {
                if x > UIScreen.main.bounds.size.width/2 {
                    WindowHelper.shared.vc.bubble.frame.origin.x = UIScreen.main.bounds.size.width - width/8*8.25
                } else {
                    WindowHelper.shared.vc.bubble.frame.origin.x = -width + width/8*8.25
                }
                WindowHelper.shared.enable()
            }
            else
            {
                if x > UIScreen.main.bounds.size.width/2 {
                    WindowHelper.shared.vc.bubble.frame.origin.x = UIScreen.main.bounds.size.width
                } else {
                    WindowHelper.shared.vc.bubble.frame.origin.x = -width
                }
                WindowHelper.shared.disable()
            }
        }
    }

    @objc public var bubbleFrameX: Float {
        didSet {
            UserDefaults.standard.set(bubbleFrameX, forKey: "bubbleFrameX_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var bubbleFrameY: Float {
        didSet {
            UserDefaults.standard.set(bubbleFrameY, forKey: "bubbleFrameY_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }

    @objc public var mainColor: String {
        didSet {
            UserDefaults.standard.set(mainColor, forKey: "mainColor_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    @objc public var additionalViewController: UIViewController? = nil
    
    //share via email
    @objc public var emailToRecipients: [String]? = nil
    @objc public var emailCcRecipients: [String]? = nil
    

    
    private override init() {
        firstIn = UserDefaults.standard.string(forKey: "firstIn_CocoaDebug")
        visible = UserDefaults.standard.bool(forKey: "visible_CocoaDebug")
        showBubbleAndWindow = UserDefaults.standard.bool(forKey: "showBubbleAndWindow_CocoaDebug")

        bubbleFrameX = UserDefaults.standard.float(forKey: "bubbleFrameX_CocoaDebug")
        bubbleFrameY = UserDefaults.standard.float(forKey: "bubbleFrameY_CocoaDebug")

        mainColor = UserDefaults.standard.string(forKey: "mainColor_CocoaDebug") ?? "#42d459"
    
    }
}
