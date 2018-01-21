#if os(iOS)
    import UIKit
#endif

import Foundation

class NetworkActivityIndicator: NSObject {

    /**
     The shared instance.
     */
    static let sharedIndicator = NetworkActivityIndicator()

    /**
     The number of activities in progress.
     */
    var activitiesCount = 0

    /**
     A Boolean value that turns an indicator of network activity on or off.

     Specify true if the app should show network activity and false if it should not. The default value is false. A spinning indicator in the status bar shows network activity. Multiple calls to visible cause an internal counter to take care of persisting the number of times this method has been called.
     */
    var visible: Bool = false {
        didSet {
            if visible {
                activitiesCount += 1
            } else {
                activitiesCount -= 1
            }

            if activitiesCount < 0 {
                activitiesCount = 0
            }

            #if os(iOS)
                let deadline = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: deadline) {
                    // This is needed in order to let this library be used in app extensions.
                    if UIApplication.responds(to: NSSelectorFromString("shared")) {
                        (UIApplication.value(forKeyPath: "shared") as? UIApplication)?.isNetworkActivityIndicatorVisible = (self.activitiesCount > 0)
                    }
                }
            #endif
        }
    }
}
