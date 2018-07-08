//
//  CocoaDebug.swift
//  demo
//
//  Created by CocoaDebug on 26/11/2017.
//  Copyright © 2018 CocoaDebug. All rights reserved.
//

import UIKit

class CocoaDebugNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.isTranslucent = false //add by CocoaDebug
        
        navigationBar.tintColor = Color.mainGreen
        navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20),
                                             NSAttributedStringKey.foregroundColor: Color.mainGreen]

        let selector = #selector(CocoaDebugNavigationController.exit)
        
        let image = UIImage(named: "_icon_file_type_close", in: Bundle(for: CocoaDebugNavigationController.self), compatibleWith: nil)
        let leftItem = UIBarButtonItem(image: image,
                                         style: .done, target: self, action: selector)
        leftItem.tintColor = Color.mainGreen
        topViewController?.navigationItem.leftBarButtonItem = leftItem
    }
    
    
    @objc func exit() {
        dismiss(animated: true, completion: nil)
    }
}
