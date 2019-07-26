//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import Foundation
import UIKit

class IgnoredURLsViewController: UITableViewController {
    
    var models: Array<String>?
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()

        models = CocoaDebugSettings.shared.ignoredURLs
    }
}

//MARK: - UITableViewDataSource
extension IgnoredURLsViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = models?[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.contentView.backgroundColor = .black
        cell.selectionStyle = .none
        
        return cell
    }
}
