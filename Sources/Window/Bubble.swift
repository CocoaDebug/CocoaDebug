//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

protocol BubbleDelegate: class {
    func didTapBubble()
}

private let _width: CGFloat = 130/2
private let _height: CGFloat = 130/2

class Bubble: UIView {
    
    var hasPerformedSetup: Bool = false//liman
    
    weak var delegate: BubbleDelegate?
    
    public let width: CGFloat = _width
    public let height: CGFloat = _height
    private var timer: Timer? 
    
    
    private lazy var _label: UILabel? = {
        let xxx: CGFloat = 16/2
        let label = UILabel(frame: CGRect(x:_width/8, y:_height/2 - 16/2 - xxx, width:_width/8*6, height:16))
        label.textColor = Color.mainGreen
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = MemoryHelper.shared().appUsedMemoryAndFreeMemory().components(separatedBy: "  ").first
        return label
    }()
    
    private lazy var _sublabel: FPSLabel? = {
        let xxx: CGFloat = -16/2 - 4
        let sublabel = FPSLabel(frame: CGRect(x:_width/8, y:_height/2 - 16/2 - xxx, width:_width/8*6, height:16))
        
        sublabel.adjustsFontSizeToFitWidth = true //sublabel.sizeToFit()
        return sublabel
    }()
    
    
    static var originalPosition: CGPoint {
        
        if CocoaDebugSettings.shared.bubbleFrameX != 0 && CocoaDebugSettings.shared.bubbleFrameY != 0 {
            return CGPoint(x: CGFloat(CocoaDebugSettings.shared.bubbleFrameX), y: CGFloat(CocoaDebugSettings.shared.bubbleFrameY))
        }
        return CGPoint(x: UIScreen.main.bounds.size.width - _width/8*7, y: UIScreen.main.bounds.size.height/2 - _height/2)
    }
    
    static var size: CGSize {return CGSize(width: _width, height: _height)}
    
    
    //MARK: - tool
    fileprivate func initLabelEvent(_ content: String, _ foo: Bool) {
        
        if content == "🚀" || content == "❌"
        {
            //step 0
            let WH: CGFloat = 25
            //step 1
            let label = UILabel()
            label.text = content
            //step 2
            if foo == true {
                label.frame = CGRect(x: self.frame.size.width/2 - WH/2, y: self.frame.size.height/2 - WH/2, width: WH, height: WH)
                self.addSubview(label)
            }else{
                label.frame = CGRect(x: self.center.x - WH/2, y: self.center.y - WH/2, width: WH, height: WH)
                self.superview?.addSubview(label)
            }
            //step 3
            UIView.animate(withDuration: 0.8, animations: {
                label.frame.origin.y = foo ? -100 : (self.center.y - 100)
                label.alpha = 0
            }, completion: { _ in
                label.removeFromSuperview()
            })
        }
        else
        {
            //step 0
            let WH: CGFloat = 35
            //step 1
            let label = UILabel()
            label.text = content
            label.textAlignment = .center
            label.textColor = .red
            label.adjustsFontSizeToFitWidth = true
            //step 2
            if #available(iOS 8.2, *) {
                label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
            } else {
                // Fallback on earlier versions
                label.font = UIFont.boldSystemFont(ofSize: 17)
            }
            //step 3
            if foo == true {
                label.frame = CGRect(x: self.frame.size.width/2 - WH/2, y: self.frame.size.height/2 - WH/2, width: WH, height: WH)
                self.addSubview(label)
            }else{
                label.frame = CGRect(x: self.center.x - WH/2, y: self.center.y - WH/2, width: WH, height: WH)
                self.superview?.addSubview(label)
            }
            //step 4
            UIView.animate(withDuration: 0.8, animations: {
                label.frame.origin.y = foo ? -100 : (self.center.y - 100)
                label.alpha = 0
            }, completion: { _ in
                label.removeFromSuperview()
            })
        }
    }
    
    
    fileprivate func initLayer() {
        self.backgroundColor = .black
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.8
        self.layer.cornerRadius = _height/2
        self.layer.shadowOffset = CGSize.zero
        self.sizeToFit()
        self.layer.masksToBounds = true
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = _height/2
        gradientLayer.colors = Color.colorGradientHead
        self.layer.addSublayer(gradientLayer)
        
        if let _label = _label, let _sublabel = _sublabel {
            self.addSubview(_label)
            self.addSubview(_sublabel)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(Bubble.tap))
        self.addGestureRecognizer(tapGesture)
        
        // ***************** Private API *****************
        if #available(iOS 11.0, *) {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(Bubble.longPress(sender:)))
            self.addGestureRecognizer(longPress)
            tapGesture.require(toFail: longPress)
        } else {
            // Fallback on earlier versions
            if #available(iOS 10.0, *) {
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(Bubble.longPress2(sender:)))
                self.addGestureRecognizer(longPress)
                tapGesture.require(toFail: longPress)
            } else {
                // Fallback on earlier versions
            }
        }
        // ***************** Private API *****************
    }
    
    func changeSideDisplay() {
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
        }, completion: nil)
    }
    
    func updateOrientation(newSize: CGSize) {
        let oldSize = CGSize(width: newSize.height, height: newSize.width)
        let percent = center.y / oldSize.height * 100
        let newOrigin = newSize.height * percent / 100
        let originX = frame.origin.x < newSize.height / 2 ? _width/8*3 : newSize.width - _width/8*3
        self.center = CGPoint(x: originX, y: newOrigin)
    }
    
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLayer()
        
        //添加手势
        let selector = #selector(Bubble.panDidFire(panner:))
        let panGesture = UIPanGestureRecognizer(target: self, action: selector)
        self.addGestureRecognizer(panGesture)
        
        //网络通知
        NotificationCenter.default.addObserver(self, selector: #selector(reloadHttp_notification(_ :)), name: NSNotification.Name("reloadHttp_CocoaDebug"), object: nil)
        
        //内存监控
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerMonitor), userInfo: nil, repeats: true)
        guard let timer = timer else {return}
        RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        timer?.invalidate()
    }
    
    //MARK: - notification
    //网络通知
    @objc func reloadHttp_notification(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo else {return}
        let statusCode = userInfo["statusCode"] as? String
        
        //https://httpstatuses.com/
        let successStatusCodes = ["200","201","202","203","204","205","206","207","208","226"]
        
        if successStatusCodes.contains(statusCode ?? "") {
            initLabelEvent("🚀", true)
            initLabelEvent("🚀", false)
        }
        else if statusCode == "0" { //"0" means network unavailable
            initLabelEvent("❌", true)
            initLabelEvent("❌", false)
        }
        else{
            guard let statusCode = statusCode else {return}
            initLabelEvent(statusCode, true)
            initLabelEvent(statusCode, false)
        }
    }
    
    //MARK: - target action
    @objc func timerMonitor() {
        _label?.text = MemoryHelper.shared().appUsedMemoryAndFreeMemory().components(separatedBy: "  ").first
    }
    
    @objc func tap() {
        delegate?.didTapBubble()
    }

    //***************** Private API *****************
    @available(iOS 11.0, *)
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            guard let cls = NSClassFromString("UIDebuggingInformationOverlay") as? UIWindow.Type else {return}
            
            if !self.hasPerformedSetup {
                cls.perform(NSSelectorFromString("prepareDebuggingOverlay"))
                self.hasPerformedSetup = true
            }
            
            let tapGesture = UITapGestureRecognizer()
            tapGesture.state = .ended
            
            let handlerCls = NSClassFromString("UIDebuggingInformationOverlayInvokeGestureHandler") as! NSObject.Type
            let handler = handlerCls.perform(NSSelectorFromString("mainHandler")).takeUnretainedValue()
            let _ = handler.perform(NSSelectorFromString("_handleActivationGesture:"), with: tapGesture)
        }
    }
    
    @available(iOS 10.0, *)
    @objc func longPress2(sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            let overlayClass = NSClassFromString("UIDebuggingInformationOverlay") as? UIWindow.Type
            _ = overlayClass?.perform(NSSelectorFromString("prepareDebuggingOverlay"))
            let overlay = overlayClass?.perform(NSSelectorFromString("overlay")).takeUnretainedValue() as? UIWindow
            _ = overlay?.perform(NSSelectorFromString("toggleVisibility"))
        }
    }
    //***************** Private API *****************
    
    @objc func panDidFire(panner: UIPanGestureRecognizer) {
        if panner.state == .began {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: { [weak self] in
                self?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }, completion: nil)
        }
        
        let offset = panner.translation(in: self.superview)
        panner.setTranslation(CGPoint.zero, in: self.superview)
        var center = self.center
        center.x += offset.x
        center.y += offset.y
        self.center = center
        
        if panner.state == .ended || panner.state == .cancelled {
            
            let location = panner.location(in: self.superview)
            let velocity = panner.velocity(in: self.superview)
            
            var finalX: Double = Double(self.width/8*3)
            var finalY: Double = Double(location.y)
            
            if location.x > UIScreen.main.bounds.size.width / 2 {
                finalX = Double(UIScreen.main.bounds.size.width) - Double(self.width/8*3)
            }
            
            self.changeSideDisplay()
            
            let horizentalVelocity = abs(velocity.x)
            let positionX = abs(finalX - Double(location.x))
            
            let velocityForce = sqrt(pow(velocity.x, 2) * pow(velocity.y, 2))
            
            let durationAnimation = (velocityForce > 1000.0) ? min(0.3, positionX / Double(horizentalVelocity)) : 0.3
            
            if velocityForce > 1000.0 {
                finalY += Double(velocity.y) * durationAnimation
            }
            
            if finalY > Double(UIScreen.main.bounds.size.height) - Double(self.height/8*5) {
                finalY = Double(UIScreen.main.bounds.size.height) - Double(self.height/8*5)
            } else if finalY < Double(self.height/8*5) + 20 {
                finalY = Double(self.height/8*5) + 20 //status bar height
            }
            
            UIView.animate(withDuration: durationAnimation * 5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: UIViewAnimationOptions.allowUserInteraction, animations: { [weak self] in
                self?.center = CGPoint(x: finalX, y: finalY)
                self?.transform = CGAffineTransform.identity
                }, completion: { [weak self] _ in
                    guard let x = self?.frame.origin.x, let y = self?.frame.origin.y else {return}
                    CocoaDebugSettings.shared.bubbleFrameX = Float(x)
                    CocoaDebugSettings.shared.bubbleFrameY = Float(y)
            })
        }
    }
}

