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
    var window: ManagerWindow
    let controller = ManagerViewController()
    var displayedList = false

    override init() {
        self.window = ManagerWindow(frame: UIScreen.main.bounds)
        super.init()
        
        Logger.shared.enable = true
        LoggerCrash.shared.enable = true
    }

    public func enable() {
        if self.window.rootViewController != self.controller {
            self.window.rootViewController = self.controller
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

extension DotzuManager: ManagerWindowDelegate {
    func isPointEvent(point: CGPoint) -> Bool {
        return self.controller.shouldReceive(point: point)
    }
}
