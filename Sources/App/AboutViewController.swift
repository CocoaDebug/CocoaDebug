//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

import Foundation
import UIKit

class AboutViewController: UITableViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var naviItem: UINavigationItem!
    
    var naviItemTitleLabel: UILabel?

    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviItemTitleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        naviItemTitleLabel?.textAlignment = .center
        naviItemTitleLabel?.textColor = Color.mainGreen
        naviItemTitleLabel?.font = .boldSystemFont(ofSize: 20)
        naviItemTitleLabel?.text = "About"
        naviItem.titleView = naviItemTitleLabel
        
        
        let version = "1.4.8"
        
        self.versionLabel.text = "CocoaDebug Version ".appending(version)
        
        tableView.tableFooterView = UIView()
    }
}
