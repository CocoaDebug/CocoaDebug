//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

import UIKit

public class WindowHelper: NSObject {
    public static let shared = WindowHelper()

    var window: CocoaDebugWindow
    var displayedList = false
    lazy var vc = CocoaDebugViewController() //必须使用lazy, 否则崩溃
    
    //FPS
    fileprivate var fpsCounter = FPSCounter()
    var fpsCallback:((Int) -> Void)?

    
    private override init() {
        window = CocoaDebugWindow(frame: UIScreen.main.bounds)
        // This is for making the window not to effect the StatusBarStyle
        window.bounds.size.height = UIScreen.main.bounds.height.nextDown
        super.init()
        
        fpsCounter.delegate = self
    }

    
    public func enable() {
        if window.rootViewController != vc {
            window.rootViewController = vc
            window.delegate = self
            window.isHidden = false
            _DebugMemoryMonitor.sharedInstance()?.startMonitoring()
//            _DebugCpuMonitor.sharedInstance()?.startMonitoring()
            fpsCounter.startMonitoring()
        }
        
        if #available(iOS 13.0, *) {
            var success: Bool = false
            
            for i in 0...10 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + (0.1 * Double(i))) {[weak self] in
                    if success == true {return}
                    
                    for scene in UIApplication.shared.connectedScenes {
                        if let windowScene = scene as? UIWindowScene {
                            self?.window.windowScene = windowScene
                            success = true
                        }
                    }
                }
            }
        }
    }
    

    public func disable() {
        if window.rootViewController != nil {
            window.rootViewController = nil
            window.delegate = nil
            window.isHidden = true
            _DebugMemoryMonitor.sharedInstance()?.stopMonitoring()
//            _DebugCpuMonitor.sharedInstance()?.stopMonitoring()
            fpsCounter.stopMonitoring()
        }
    }
}


// MARK: - FPSCounterDelegate
extension WindowHelper: FPSCounterDelegate {
    @objc public func fpsCounter(_ counter: FPSCounter, didUpdateFramesPerSecond fps: Int) {
        if let fpsCallback = fpsCallback {
            fpsCallback(fps)
        }
    }
}

