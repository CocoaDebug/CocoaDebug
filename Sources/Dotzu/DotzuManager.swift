//
//  Manager.swift
//  exampleWindow
//
//  Created by Remi Robert on 02/12/2016.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit

public class Dotzu: NSObject {
    public static let sharedManager = Dotzu()
    var window: ManagerWindow
    let controller = ManagerViewController()
    var displayedList = false

    override init() {
        self.window = ManagerWindow(frame: UIScreen.main.bounds)
        super.init()
    }

    public func enable() {
        self.window.rootViewController = self.controller
        self.window.isHidden = false
        self.window.delegate = self
        Logger.shared.enable = true
        LoggerCrash.shared.enable = true
    }

    public func disable() {
        self.window.rootViewController = nil
        self.window.removeFromSuperview()
        self.window.delegate = nil
        Logger.shared.enable = false
        LoggerCrash.shared.enable = false
    }
}

extension Dotzu: ManagerWindowDelegate {
    func isPointEvent(point: CGPoint) -> Bool {
        return self.controller.shouldReceive(point: point)
    }
}
