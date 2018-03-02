//
//  DotzuManager.swift
//  exampleWindow
//
//  Created by Remi Robert on 02/12/2016.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit

public class DotzuManager: NSObject {
    public static let shared = DotzuManager()
    var window: InvisibleWindow
    let vc = ManagerViewController()
    var displayedList = false

    override init() {
        self.window = InvisibleWindow(frame: UIScreen.main.bounds)
        super.init()
    }

    public func enable() {
        if self.window.rootViewController != self.vc {
            self.window.rootViewController = self.vc
            self.window.delegate = self
            self.window.isHidden = false
        }
    }

    public func disable() {
        if self.window.rootViewController != nil {
            self.window.rootViewController = nil
            self.window.delegate = nil
            self.window.isHidden = true
        }
    }
}

extension DotzuManager: DebugManWindowDelegate {
    func isPointEvent(point: CGPoint) -> Bool {
        return self.vc.shouldReceive(point: point)
    }
}
