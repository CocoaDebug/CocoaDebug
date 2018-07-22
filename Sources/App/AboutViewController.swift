//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import Foundation
import UIKit

class AboutViewController: UITableViewController {
    
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    //MARK: - target action
    @IBAction func tapUrl(_ sender: UITapGestureRecognizer) {
        guard let url = URL.init(string: "https://github.com/CocoaDebug/CocoaDebug") else {return}
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
