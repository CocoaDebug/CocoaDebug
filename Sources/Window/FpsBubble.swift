//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

import UIKit

class FpsBubble: UIView {
    
    static var size: CGSize {return CGSize(width: 48, height: 16)}
    
    private var fpsLabel: _DebugConsoleLabel? = {
        return _DebugConsoleLabel(frame: CGRect(x:0, y:0, width:size.width, height:size.height))
    }()
    
    fileprivate func initLayer() {
        self.backgroundColor = .black
        self.layer.cornerRadius = 4
        self.sizeToFit()
        
        if let fpsLabel = fpsLabel {
            self.addSubview(fpsLabel)
        }
    }
    
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: UIScreen.main.bounds.width/4.0, y:1, width: frame.width, height: frame.height))
        
        initLayer()
        
        fpsLabel?.attributedText = fpsLabel?.fpsAttributedString(with: 60)
        
        WindowHelper.shared.fpsCallback = { [weak self] value in
            self?.fpsLabel?.update(withValue: Float(value))
        }
    }
    
    func updateFrame() {
        if #available(iOS 11.0, *) {
            let safeAreaInsetsTop = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
            if safeAreaInsetsTop > 24 { //iPhoneX
                center.x = UIScreen.main.bounds.width/2.0
                center.y = 39
                
                let string = CocoaDebugDeviceInfo.sharedInstance().getPlatformString
                if string == "iPhone 12 mini" {
                    center.y = 43
                } else if string == "iPhone 12" {
                    center.y = 41
                } else if string == "iPhone 12 Pro" {
                    center.y = 41
                } else if string == "iPhone 12 Pro Max" {
                    center.y = 41
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
