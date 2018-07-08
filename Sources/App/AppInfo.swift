//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
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
