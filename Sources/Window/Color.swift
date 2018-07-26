//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import UIKit

struct Color {

    static var colorGradientHead: [CGColor] {
        return [UIColor(red:0.25, green:0.25, blue:0.25, alpha:1.00).cgColor,
                 UIColor(red:0.15, green:0.15, blue:0.15, alpha:1.00).cgColor]
    }

    static var mainGreen: UIColor {
        return CocoaDebug.mainColor.hexColor
    }
}
