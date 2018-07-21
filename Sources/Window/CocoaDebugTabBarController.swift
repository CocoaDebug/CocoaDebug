//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import UIKit

class CocoaDebugTabBarController: UITabBarController {

    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let window = UIApplication.shared.delegate?.window {
            window?.endEditing(true)
        }
        
        setChildControllers()
        
        self.selectedIndex = CocoaDebugSettings.shared.tabBarSelectItem 
        self.tabBar.tintColor = Color.mainGreen
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CocoaDebugSettings.shared.visible = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CocoaDebugSettings.shared.visible = false
    }
    
    //MARK: - private
    func setChildControllers() {

        //1.
        let logs = UIStoryboard(name: "Logs", bundle: Bundle(for: CocoaDebug.self)).instantiateViewController(withIdentifier: "Logs")
        let network = UIStoryboard(name: "Network", bundle: Bundle(for: CocoaDebug.self)).instantiateViewController(withIdentifier: "Network")
        let app = UIStoryboard(name: "App", bundle: Bundle(for: CocoaDebug.self)).instantiateViewController(withIdentifier: "App")
        
        //2.
        Sandbox.shared.isSystemFilesHidden = false
        Sandbox.shared.isExtensionHidden = false
        Sandbox.shared.isShareable = true
        Sandbox.shared.isFileDeletable = true
        Sandbox.shared.isDirectoryDeletable = true
        guard let sandbox = Sandbox.shared.homeDirectoryNavigationController() else {return}
        sandbox.tabBarItem.title = "Sandbox"
        sandbox.tabBarItem.image = UIImage.init(named: "_icon_file_type_sandbox", in: Bundle.init(for: CocoaDebug.self), compatibleWith: nil)
        
        //3.
        guard let tabBarControllers = CocoaDebugSettings.shared.tabBarControllers else {
            self.viewControllers = [logs, network, app, sandbox]
            return
        }
        
        //4.添加额外的控制器
        var temp = [logs, network, app, sandbox]
        
        for vc in tabBarControllers {
            
            let nav = UINavigationController.init(rootViewController: vc)
            nav.navigationBar.barTintColor = "#1f2124".hexColor
            
            //****** 以下代码从NavigationController.swift复制 ******
            nav.navigationBar.isTranslucent = false
            
            nav.navigationBar.tintColor = Color.mainGreen
            nav.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20),
                                                     NSAttributedStringKey.foregroundColor: Color.mainGreen]
            
            let selector = #selector(CocoaDebugNavigationController.exit)
            
            
            let image = UIImage(named: "_icon_file_type_close", in: Bundle(for: CocoaDebugNavigationController.self), compatibleWith: nil)
            let leftItem = UIBarButtonItem(image: image,
                                             style: .done, target: self, action: selector)
            leftItem.tintColor = Color.mainGreen
            nav.topViewController?.navigationItem.leftBarButtonItem = leftItem
            //****** 以上代码从NavigationController.swift复制 ******
            
            temp.append(nav)
        }
        
        self.viewControllers = temp
    }
    
    //MARK: - target action
    @objc func exit() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - show more than 5 tabs by CocoaDebug
    override var traitCollection: UITraitCollection {
        let realTraits = super.traitCollection
        let lieTrait = UITraitCollection.init(horizontalSizeClass: .regular)
        return UITraitCollection(traitsFrom: [realTraits, lieTrait])
    }
}

//MARK: - UITabBarDelegate
extension CocoaDebugTabBarController {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem)
    {
        guard let items = self.tabBar.items else {return}
        
        for index in 0...items.count-1 {
            if item == items[index] {
                CocoaDebugSettings.shared.tabBarSelectItem = index
            }
        }
    }
}
