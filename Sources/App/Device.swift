//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import UIKit

struct Device {

    var osVersion: String?
    static var screenResolution: String? {
        let scale = UIScreen.main.scale
        let dimension = UIScreen.main.bounds
        return "\(dimension.size.width*scale)*\(dimension.size.height*scale)"
    }
    static var deviceModel: DeviceModel = DeviceModel.current

    var getScreenSize: String?
    var aspectRatio: String?

    static var screenSize: Float {
        switch self.deviceModel {
        case .iPhone4, .iPhone4S:                                               return 3.5
        case .iPodTouch1Gen, .iPodTouch2Gen, .iPodTouch3Gen, .iPodTouch4Gen:    return 3.5
        case .iPodTouch5Gen, .iPodTouch6Gen:                                    return 4
        case .iPhone5, .iPhone5C, .iPhone5S, .iPhoneSE:                         return 4
        case .iPhone6, .iPhone6S, .iPhone7, .iPhone8:                           return 4.7
        case .iPhone6Plus, .iPhone6SPlus, .iPhone7Plus, .iPhone8Plus:           return 5.5
        case .iPad1, .iPad2, .iPad3, .iPad4, .iPadAir, .iPadAir2:               return 9.7
        case .iPadMini, .iPadMini2, .iPadMini3, .iPadMini4:                     return 7.9
        case .iPadPro:                                                          return 12.9
        case .iPhoneX:                                                          return 5.8
        case .unknown, .simulator:                                              return 0
        }
    }

}
