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
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let version = "1.2.3"
        
        self.versionLabel.text = "CocoaDebug Version ".appending(version)
        
        tableView.tableFooterView = UIView()
    }
}
