//
//  LogTabBarViewController.swift
//  exampleWindow
//
//  Created by Remi Robert on 20/01/2017.
//  Copyright © 2017 Remi Robert. All rights reserved.
//

import UIKit

class LogTabBarViewController: UITabBarController {

    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = Color.mainGreen
        
        setChildControllers()
        
        self.selectedIndex = LogsSettings.shared.tabBarSelectItem
        
        if let window = UIApplication.shared.delegate?.window {
            window?.endEditing(true)
        }
    }
    
    //MARK: - private
    func setChildControllers() {
        let Logs = UIStoryboard(name: "Logs", bundle: Bundle(for: DebugMan.self))
        let Network = UIStoryboard(name: "Network", bundle: Bundle(for: DebugMan.self))
        let App = UIStoryboard(name: "App", bundle: Bundle(for: DebugMan.self))
        
        let Logs_ = Logs.instantiateViewController(withIdentifier: "Logs")
        let Network_ = Network.instantiateViewController(withIdentifier: "Network")
        let App_ = App.instantiateViewController(withIdentifier: "App")
        
        self.viewControllers = [Logs_, Network_, App_]
        
        
        //添加额外的控制器
        guard let tabBarControllers = LogsSettings.shared.tabBarControllers else {return}
        
        for vc in tabBarControllers {
            
            let nav = UINavigationController.init(rootViewController: vc)
            
            //************ 以下代码从LogNavigationViewController.swift复制 ************
            nav.navigationBar.tintColor = Color.mainGreen
            nav.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 20),
                                                     NSAttributedStringKey.foregroundColor: Color.mainGreen]
            
            let selector = #selector(LogNavigationViewController.exit)
            
            
            let image = UIImage(named: "debugman_close", in: Bundle(for: LogNavigationViewController.self), compatibleWith: nil)
            let leftButton = UIBarButtonItem(image: image,
                                             style: .done, target: self, action: selector)
            nav.topViewController?.navigationItem.leftBarButtonItem = leftButton
            //************ 以上代码从LogNavigationViewController.swift复制 ************
            
            nav.navigationBar.barTintColor = UIColor.init(hexString: "#1f2124")
            self.viewControllers?.append(nav)
        }
    }
    
    
    //************ 以下代码从LogNavigationViewController.swift复制 ************
    //MARK: - target action
    @objc func exit() {
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - UITabBarDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem)
    {
        guard let items = self.tabBar.items else {return}
        
        for index in 0...items.count-1 {
            if item == items[index] {
                LogsSettings.shared.tabBarSelectItem = index
            }
        }
    }
}
