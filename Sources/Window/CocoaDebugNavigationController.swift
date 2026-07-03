//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import UIKit

class CocoaDebugNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.isTranslucent = false //liman
        
        navigationBar.tintColor = Color.mainGreen
        navigationBar.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 20),
                                             .foregroundColor: Color.mainGreen]
        
        let selector = #selector(CocoaDebugNavigationController.exit)
        
        let image = UIImage(named: "_icon_file_type_close", in: Bundle(for: CocoaDebugNavigationController.self), compatibleWith: nil)
        let leftItem = UIBarButtonItem(image: image,
                                       style: .done, target: self, action: selector)
        leftItem.tintColor = Color.mainGreen
        topViewController?.navigationItem.leftBarButtonItem = leftItem
        
        // Set navigation bar appearance in code (do NOT use global UINavigationBar.appearance()).
        // This avoids conflicts with QMUIKit, host app global appearance, and iOS 15+ behavior changes.
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(red: 31/255.0, green: 33/255.0, blue: 36/255.0, alpha: 1.0)
            appearance.shadowColor = .clear
            appearance.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 20),
                                              .foregroundColor: Color.mainGreen]
            self.navigationBar.standardAppearance = appearance
            self.navigationBar.scrollEdgeAppearance = appearance
            self.navigationBar.compactAppearance = appearance
            if #available(iOS 15.0, *) {
                self.navigationBar.compactScrollEdgeAppearance = appearance
            }
        } else if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.shadowColor = .clear
            self.navigationBar.standardAppearance = appearance
            self.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    
    @objc func exit() {
        dismiss(animated: true, completion: nil)
    }
}
