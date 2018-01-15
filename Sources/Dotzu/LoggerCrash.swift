//
//  LoggerCrash.swift
//  exampleWindow
//
//  Created by Remi Robert on 31/01/2017.
//  Copyright © 2017 Remi Robert. All rights reserved.
//

import UIKit
import Darwin

func exceptionHandler(exception: NSException) {
    if LoggerCrash.shared.crashed {
        return
    }
    LoggerCrash.shared.crashed = true
    LoggerCrash.addCrash(name: exception.name.rawValue, reason: exception.reason)
}

func handleSignal(signal: Int32) {
    if LoggerCrash.shared.crashed {
        return
    }
    LoggerCrash.shared.crashed = true
    switch signal {
    case SIGILL:
        LoggerCrash.addCrash(name: "SIGILL", reason: nil)
    case SIGABRT:
        LoggerCrash.addCrash(name: "SIGABRT", reason: nil)
    case SIGFPE:
        LoggerCrash.addCrash(name: "SIGFPE", reason: nil)
    case SIGBUS:
        LoggerCrash.addCrash(name: "SIGBUS", reason: nil)
    case SIGSEGV:
        LoggerCrash.addCrash(name: "SIGSEGV", reason: nil)
    case SIGSYS:
        LoggerCrash.addCrash(name: "SIGSYS", reason: nil)
    case SIGPIPE:
        LoggerCrash.addCrash(name: "SIGPIPE", reason: nil)
    case SIGTRAP:
        LoggerCrash.addCrash(name: "SIGTRAP", reason: nil)
    default: break
    }
}

class LoggerCrash: LogGenerator {

    static let shared = LoggerCrash()
    var crashed = false
    var enable: Bool = true {
        didSet {
            if enable {
                LoggerCrash.register()
            }
            else {
                LoggerCrash.unregister()
            }
        }
    }

    static func register() {
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

    static func unregister() {
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

    static func addCrash(name: String, reason: String?) {
        let newCrash = LogCrash(name: name, reason: reason)
        StoreManager.shared.addCrash(newCrash)
    }
}
