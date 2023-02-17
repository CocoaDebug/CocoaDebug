//
//  CocoaDebug
//  liman
//
//  Created by liman 02/02/2023.
//  Copyright © 2023 liman. All rights reserved.
//

import UIKit

#if DEBUG
    import CocoaDebug
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //You can add your custom controller here.👇👇👇
//        #if DEBUG
//            CocoaDebug.additionalViewController = TestController.init()
//        #endif
        
        return true
    }
}

//MARK: - override Swift `print` method
public func print<T>(file: String = #file, function: String = #function, line: Int = #line, _ message: T, color: UIColor = .white) {
#if DEBUG
    Swift.print(message)
    _SwiftLogHelper.shared.handleLog(file: file, function: function, line: line, message: message, color: color)
#endif
}
