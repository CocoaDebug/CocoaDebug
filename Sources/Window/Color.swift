//
//  CocoaDebug.swift
//  demo
//
//  Created by CocoaDebug on 26/11/2017.
//  Copyright © 2018 CocoaDebug. All rights reserved.
//

import UIKit

struct Color {

    static var colorGradientHead: [CGColor] {
        return [UIColor(red:0.25, green:0.25, blue:0.25, alpha:1.00).cgColor,
                 UIColor(red:0.15, green:0.15, blue:0.15, alpha:1.00).cgColor]
    }

    static var mainGreen: UIColor {
        return "#42d459".hexColor
    }
}
