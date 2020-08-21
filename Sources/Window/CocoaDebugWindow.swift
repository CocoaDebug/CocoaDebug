//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

import UIKit

protocol WindowDelegate: class {
    func isPointEvent(point: CGPoint) -> Bool
}

class CocoaDebugWindow: UIWindow {
    
    weak var delegate: WindowDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .clear
        self.windowLevel = UIWindow.Level(rawValue: UIWindow.Level.alert.rawValue - 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
