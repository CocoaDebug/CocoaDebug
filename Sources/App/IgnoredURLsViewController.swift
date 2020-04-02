//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

import Foundation
import UIKit

class IgnoredURLsViewController: UITableViewController {
    
    var models: Array<String>?
    
    @IBOutlet weak var naviItem: UINavigationItem!
    
    var naviItemTitleLabel: UILabel?

    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviItemTitleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        naviItemTitleLabel?.textAlignment = .center
        naviItemTitleLabel?.textColor = Color.mainGreen
        naviItemTitleLabel?.font = .boldSystemFont(ofSize: 20)
        naviItemTitleLabel?.text = "Ignored URLs"
        naviItem.titleView = naviItemTitleLabel
        
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
