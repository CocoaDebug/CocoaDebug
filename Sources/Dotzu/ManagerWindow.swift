//
//  ManagerWindow.swift
//  exampleWindow
//
//  Created by Remi Robert on 02/12/2016.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit

protocol ManagerWindowDelegate: class {
    func isPointEvent(point: CGPoint) -> Bool
}

class ManagerWindow: UIWindow {

    weak var delegate: ManagerWindowDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.clear
        self.windowLevel = UIWindowLevelStatusBar - 1
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return self.delegate?.isPointEvent(point: point) ?? false
    }
}
