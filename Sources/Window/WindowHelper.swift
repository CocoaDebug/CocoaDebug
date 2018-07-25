//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import UIKit

public class WindowHelper: NSObject {
    public static let shared = WindowHelper()
    
    var window: CocoaDebugWindow?
    var displayedList = false
    lazy var vc = CocoaDebugViewController()
    
    private override init() {
        self.window = CocoaDebugWindow(frame: CGRect(x: 0, y: CocoaDebugWindow.y, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - CocoaDebugWindow.y))
        super.init()
    }

    public func enable() {
        if self.window?.rootViewController != self.vc {
            self.window?.rootViewController = self.vc
            self.window?.delegate = self
            self.window?.isHidden = false
        }
    }

    public func disable() {
        if self.window?.rootViewController != nil {
            self.window?.rootViewController = nil
            self.window?.delegate = nil
            self.window?.isHidden = true
        }
    }
}
