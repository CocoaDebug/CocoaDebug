//
//  CocoaDebug.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

struct AppInfo {

    static var versionNumber: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    static var buildNumber: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }

    static var bundleName: String? {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String
    }
}
