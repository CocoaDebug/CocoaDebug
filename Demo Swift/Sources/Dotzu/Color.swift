//
//  Color.swift
//  exampleWindow
//
//  Created by Remi Robert on 20/01/2017.
//  Copyright © 2017 Remi Robert. All rights reserved.
//

import UIKit

struct Color {

    static var colorGradientHead: [CGColor] {
        return [UIColor(red:0.25, green:0.25, blue:0.25, alpha:1.00).cgColor,
                 UIColor(red:0.15, green:0.15, blue:0.15, alpha:1.00).cgColor]
    }

    static var mainGreen: UIColor {
        return UIColor.init(hexString: "#42d459")
    }
}
