//
//  CocoaDebug.swift
//  demo
//
//  Created by CocoaDebug on 26/11/2017.
//  Copyright © 2018 CocoaDebug. All rights reserved.
//

import UIKit

public class WindowHelper: NSObject {
    public static let shared = WindowHelper()
    var window: CocoaDebugWindow?
    lazy var vc = CocoaDebugViewController()
    var displayedList = false
 
    private override init() {
        self.window = CocoaDebugWindow(frame: UIScreen.main.bounds)
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
