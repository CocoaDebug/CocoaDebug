//
//  CocoaDebug.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class CocoaDebugNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.isTranslucent = false //add by liman
        
        navigationBar.tintColor = Color.mainGreen
        navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20),
                                             NSAttributedStringKey.foregroundColor: Color.mainGreen]

        let selector = #selector(CocoaDebugNavigationController.exit)
        
        let image = UIImage(named: "CocoaDebug_close", in: Bundle(for: CocoaDebugNavigationController.self), compatibleWith: nil)
        let leftItem = UIBarButtonItem(image: image,
                                         style: .done, target: self, action: selector)
        leftItem.tintColor = Color.mainGreen
        topViewController?.navigationItem.leftBarButtonItem = leftItem
    }
    
    
    @objc func exit() {
        dismiss(animated: true, completion: nil)
    }
}
