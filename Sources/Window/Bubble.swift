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

//https://httpcodes.co/status/
private let _successStatusCodes = ["200","201","202","203","204","205","206","207","208","226"]
private let _informationalStatusCodes = ["100","101","102","103","122"]
private let _redirectionStatusCodes = ["300","301","302","303","304","305","306","307","308"]

private let _width: CGFloat = 60
private let _height: CGFloat = 60

class Bubble: UIView {
    
    var hasPerformedSetup: Bool = false//liman
    
    weak var delegate: BubbleDelegate?
    
    public let width: CGFloat = _width
    public let height: CGFloat = _height
    
    private lazy var memoryLabel: _WHDebugConsoleLabel? = {
        return _WHDebugConsoleLabel(frame: CGRect(x:0, y:2, width:_width, height:16))
    }()
    
    private lazy var fpsLabel: _WHDebugConsoleLabel? = {
        return _WHDebugConsoleLabel(frame: CGRect(x:0, y:22, width:_width, height:16))
    }()
    
    private lazy var cpuLabel: _WHDebugConsoleLabel? = {
        return _WHDebugConsoleLabel(frame: CGRect(x:0, y:42, width:_width, height:16))
    }()
    
    
    static var originalPosition: CGPoint {
        
        if CocoaDebugSettings.shared.bubbleFrameX != 0 && CocoaDebugSettings.shared.bubbleFrameY != 0 {
            return CGPoint(x: CGFloat(CocoaDebugSettings.shared.bubbleFrameX), y: CGFloat(CocoaDebugSettings.shared.bubbleFrameY))
        }
        return CGPoint(x: 1.875 + _width/2, y: 200)
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
            label.adjustsFontSizeToFitWidth = true
            
            if _informationalStatusCodes.contains(content) {
                label.textColor = "#4b8af7".hexColor
            }
            else if _redirectionStatusCodes.contains(content) {
                label.textColor = "#ff9800".hexColor
            }
            else {
                label.textColor = .red
            }
            
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
        self.layer.cornerRadius = 10
        self.layer.shadowOffset = CGSize.zero
        self.layer.masksToBounds = true
        self.sizeToFit()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = 10
        gradientLayer.colors = Color.colorGradientHead
        self.layer.addSublayer(gradientLayer)
        
        
        if let memoryLabel = memoryLabel, let fpsLabel = fpsLabel, let cpuLabel = cpuLabel {
            self.addSubview(memoryLabel)
            self.addSubview(fpsLabel)
            self.addSubview(cpuLabel)
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
        let originX = frame.origin.x < newSize.height / 2 ? _width/8*4.25 : newSize.width - _width/8*4.25
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
        NotificationCenter.default.addObserver(forName: NSNotification.Name("reloadHttp_CocoaDebug"), object: nil, queue: OperationQueue.main) { [weak self] (notification) in
            self?.reloadHttp_notification(notification)
        }
        
        //
        _WHDebugFPSMonitor.sharedInstance()?.valueBlock = { [weak self] value in
            self?.fpsLabel?.update(with: .FPS, value: value)
        }
        _WHDebugMemoryMonitor.sharedInstance()?.valueBlock = { [weak self] value in
            self?.memoryLabel?.update(with: .memory, value: value)
        }
        _WHDebugCpuMonitor.sharedInstance()?.valueBlock = { [weak self] value in
            self?.cpuLabel?.update(with: .CPU, value: value)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - notification
    //网络通知
    @objc func reloadHttp_notification(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo else {return}
        let statusCode = userInfo["statusCode"] as? String
        
        if _successStatusCodes.contains(statusCode ?? "") {
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
            
            var frameInset: UIEdgeInsets

            if #available(iOS 11.0, *) {
                frameInset = UIApplication.shared.keyWindow?.safeAreaInsets ?? UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0, right: 0)
            } else {
                frameInset = UIDevice.current.orientation.isPortrait ? UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0) : .zero
            }
            
            let location = panner.location(in: self.superview)
            let velocity = panner.velocity(in: self.superview)
            
            var finalX: Double = Double(self.width/8*4.25)
            var finalY: Double = Double(location.y)
            
            if location.x > UIScreen.main.bounds.size.width / 2 {
                finalX = Double(UIScreen.main.bounds.size.width) - Double(self.width/8*4.25)
            }
            
            self.changeSideDisplay()
            
            let horizentalVelocity = abs(velocity.x)
            let positionX = abs(finalX - Double(location.x))
            
            let velocityForce = sqrt(pow(velocity.x, 2) * pow(velocity.y, 2))
            
            let durationAnimation = (velocityForce > 1000.0) ? min(0.3, positionX / Double(horizentalVelocity)) : 0.3
            
            if velocityForce > 1000.0 {
                finalY += Double(velocity.y) * durationAnimation
            }
            
            if finalY > Double(UIScreen.main.bounds.size.height) - Double(self.height/8*4.25) {
                finalY = Double(UIScreen.main.bounds.size.height) - Double(frameInset.bottom) - Double(self.height/8*4.25)
            } else if finalY < Double(self.height/8*4.25) + Double(frameInset.top)  {
                finalY = Double(self.height/8*4.25) + Double(frameInset.top)
            }
            
            UIView.animate(withDuration: durationAnimation * 5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: .allowUserInteraction, animations: { [weak self] in
                self?.center = CGPoint(x: finalX, y: finalY)
                self?.transform = CGAffineTransform.identity
                }, completion: { _ in
                    CocoaDebugSettings.shared.bubbleFrameX = Float(finalX)
                    CocoaDebugSettings.shared.bubbleFrameY = Float(finalY)
            })
        }
    }
}

