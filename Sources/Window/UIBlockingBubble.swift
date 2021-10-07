//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import UIKit

class UIBlockingBubble: UIView {
    
    static var size: CGSize {return CGSize(width: 70, height: 20)}
    
    private var uiBlockingLabel: UILabel? = {
        return UILabel(frame: CGRect(x:0, y:0, width:size.width, height:size.height))
    }()
    
    fileprivate func initLayer() {
        self.backgroundColor = .black
        self.layer.cornerRadius = 4
        self.sizeToFit()
        
        if let uiBlockingLabel = uiBlockingLabel {
            self.addSubview(uiBlockingLabel)
        }
    }
    
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: UIScreen.main.bounds.width/4.0, y:1, width: frame.width, height: frame.height))
        
        initLayer()
        
//        uiBlockingLabel?.attributedText = uiBlockingLabel?.uiBlockingAttributedString(with: 60)
        
//        WindowHelper.shared.uiBlockingCallback = { [weak self] value in
//            self?.uiBlockingLabel?.update(withValue: Float(value))
//        }
        
        uiBlockingLabel?.textAlignment = .center
        uiBlockingLabel?.adjustsFontSizeToFitWidth = true
        uiBlockingLabel?.text = "Normal"
        uiBlockingLabel?.textColor = .white
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "CocoaDebug_Detected_UI_Blocking"), object: nil, queue: OperationQueue.main) { [weak self] _ in
            self?.uiBlockingLabel?.text = "Blocking"
            self?.uiBlockingLabel?.textColor = .red
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {[weak self] in
                self?.uiBlockingLabel?.text = "Normal"
                self?.uiBlockingLabel?.textColor = .white
            }
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
    
    deinit {
        //notification
        NotificationCenter.default.removeObserver(self)
    }
}
