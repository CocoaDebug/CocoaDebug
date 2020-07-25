//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

import UIKit
import Darwin

func exceptionHandler(exception: NSException) {
    if CrashLogger.shared.crashed {
        return
    }
    CrashLogger.shared.crashed = true
    CrashLogger.addCrash(name: exception.name.rawValue, reason: exception.reason)
}

func handleSignal(signal: Int32) {
    if CrashLogger.shared.crashed {
        return
    }
    CrashLogger.shared.crashed = true
    switch signal {
    case SIGILL:
        CrashLogger.addCrash(name: "SIGILL", reason: nil)
    case SIGABRT:
        CrashLogger.addCrash(name: "SIGABRT", reason: nil)
    case SIGFPE:
        CrashLogger.addCrash(name: "SIGFPE", reason: nil)
    case SIGBUS:
        CrashLogger.addCrash(name: "SIGBUS", reason: nil)
    case SIGSEGV:
        CrashLogger.addCrash(name: "SIGSEGV", reason: nil)
    case SIGSYS:
        CrashLogger.addCrash(name: "SIGSYS", reason: nil)
    case SIGPIPE:
        CrashLogger.addCrash(name: "SIGPIPE", reason: nil)
    case SIGTRAP:
        CrashLogger.addCrash(name: "SIGTRAP", reason: nil)
    default: break
    }
}

class CrashLogger {

    static let shared = CrashLogger()
    private init() {}
    
    var hasBeenRegistered = false
    var crashed = false
    var enable: Bool = false {
        didSet {
            if enable {
                CrashLogger.shared.register()
            }
            else {
                CrashLogger.shared.unregister()
            }
        }
    }

    func register() {
        if hasBeenRegistered == false {
            hasBeenRegistered = true
            NSSetUncaughtExceptionHandler(exceptionHandler)
            signal(SIGILL, handleSignal)
            signal(SIGABRT, handleSignal)
            signal(SIGFPE, handleSignal)
            signal(SIGBUS, handleSignal)
            signal(SIGSEGV, handleSignal)
            signal(SIGSYS, handleSignal)
            signal(SIGPIPE, handleSignal)
            signal(SIGTRAP, handleSignal)
        }
    }

    func unregister() {
        if hasBeenRegistered == true {
            hasBeenRegistered = false
            NSSetUncaughtExceptionHandler(nil)
            signal(SIGILL, SIG_DFL)
            signal(SIGABRT, SIG_DFL)
            signal(SIGFPE, SIG_DFL)
            signal(SIGBUS, SIG_DFL)
            signal(SIGSEGV, SIG_DFL)
            signal(SIGSYS, SIG_DFL)
            signal(SIGPIPE, SIG_DFL)
            signal(SIGTRAP, SIG_DFL)
        }
    }

    static func addCrash(name: String, reason: String?) {
        let newCrash = _CrashModel(name: name, reason: reason)
        CrashStoreManager.shared.addCrash(newCrash)
    }
}
