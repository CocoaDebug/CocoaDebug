//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import UIKit

protocol WindowDelegate: AnyObject {
    func isPointEvent(point: CGPoint) -> Bool
}

class CocoaDebugWindow: UIWindow {
    
    weak var delegate: WindowDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = .clear
        self.windowLevel = UIWindow.Level(rawValue: UIWindow.Level.alert.rawValue - 1)
        self.accessibilityIdentifier = "com.cocoadebug.window"
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
        if let bubbleVC = CocoaDebugWindowManager.shared.currentBubbleVC() {
            return bubbleVC.shouldReceive(point: point)
        }
        return false
    }
}
