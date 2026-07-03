//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import UIKit

/// Thin compatibility adapter that forwards to CocoaDebugWindowManager.
/// Kept for backward compatibility with existing ObjC callers.
public class WindowHelper: NSObject {
    public static let shared = WindowHelper()

    // Deprecated direct access; use CocoaDebugWindowManager instead
    var window: CocoaDebugWindow {
        // Return a placeholder — callers should migrate to WindowManager
        return CocoaDebugWindow(frame: .zero)
    }
    var displayedList = false
    lazy var vc = CocoaDebugViewController() //must lazy init, otherwise crash

    private override init() {
        super.init()
    }

    /// Forward to CocoaDebugWindowManager.start()
    public func enable() {
        CocoaDebugWindowManager.shared.start()
    }

    /// Forward to CocoaDebugWindowManager.stop()
    public func disable() {
        CocoaDebugWindowManager.shared.stop()
        stopUIBlockingMonitoring()
    }
    
    public func startUIBlockingMonitoring() {
//        uiBlockingCounter.startMonitoring()
        _RunloopMonitor.shared().begin()
    }

    public func stopUIBlockingMonitoring() {
//        uiBlockingCounter.stopMonitoring()
        _RunloopMonitor.shared().end()
    }
}


// MARK: - UIBlockingCounterDelegate
//extension WindowHelper: UIBlockingCounterDelegate {
//    @objc public func uiBlockingCounter(_ counter: UIBlockingCounter, didUpdateFramesPerSecond uiBlocking: Int) {
//        if let uiBlockingCallback = uiBlockingCallback {
//            uiBlockingCallback(uiBlocking)
//        }
//    }
//}

