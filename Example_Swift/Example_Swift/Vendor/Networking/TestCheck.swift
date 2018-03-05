import Foundation

struct TestCheck {
    /**
     Method to check whether you are on testing mode or not.
     - returns: A Bool, `true` if you're on testing mode, `false` if you're not.
     */
    static let isTesting: Bool = {
        let enviroment = ProcessInfo.processInfo.environment
        let serviceName = enviroment["XPC_SERVICE_NAME"]
        let injectBundle = enviroment["XCInjectBundle"]
        var isRunning = (enviroment["TRAVIS"] != nil || enviroment["XCTestConfigurationFilePath"] != nil)

        if !isRunning {
            if let serviceName = serviceName {
                isRunning = (serviceName as NSString).pathExtension == "xctest"
            }
        }

        if !isRunning {
            if let injectBundle = injectBundle {
                isRunning = (injectBundle as NSString).pathExtension == "xctest"
            }
        }

        return isRunning
    }()

    /**
     If it's in a unit testing target then it will return in the current thread, otherwise it will return in the main thread.
     */
    static func testBlock(_ disabled: Bool, block: @escaping () -> Void) {
        if TestCheck.isTesting && disabled == false {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
}
