//
//  DotzuX.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

protocol WindowDelegate: class {
    func isPointEvent(point: CGPoint) -> Bool
}

class DotzuXWindow: UIWindow {
    
    weak var delegate: WindowDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .clear
        self.windowLevel = UIWindowLevelStatusBar - 1
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return self.delegate?.isPointEvent(point: point) ?? false
    }
}

extension WindowHelper: WindowDelegate {
    func isPointEvent(point: CGPoint) -> Bool {
        return self.vc.shouldReceive(point: point)
    }
}
