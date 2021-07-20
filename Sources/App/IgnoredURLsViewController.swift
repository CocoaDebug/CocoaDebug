//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import Foundation
import UIKit

class IgnoredURLsViewController: UITableViewController {
    
    var ignoredURLs: Array<String>?
    var onlyURLs: Array<String>?
    
    var ignoredPrefixLogs: Array<String>?
    var onlyPrefixLogs: Array<String>?
    
    @IBOutlet weak var naviItem: UINavigationItem!
    
    var naviItemTitleLabel: UILabel?
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviItemTitleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        naviItemTitleLabel?.textAlignment = .center
        naviItemTitleLabel?.textColor = Color.mainGreen
        naviItemTitleLabel?.font = .boldSystemFont(ofSize: 20)
        naviItemTitleLabel?.text = "Settings"
        naviItem.titleView = naviItemTitleLabel
        
        tableView.tableFooterView = UIView()
        
        ignoredURLs = CocoaDebugSettings.shared.ignoredURLs
        onlyURLs = CocoaDebugSettings.shared.onlyURLs
        
        ignoredPrefixLogs = CocoaDebugSettings.shared.ignoredPrefixLogs
        onlyPrefixLogs = CocoaDebugSettings.shared.onlyPrefixLogs
    }
}

//MARK: - UITableViewDataSource
extension IgnoredURLsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return ignoredURLs?.count ?? 0
        case 1:
            return onlyURLs?.count ?? 0
        case 2:
            return ignoredPrefixLogs?.count ?? 0
        case 3:
            return onlyPrefixLogs?.count ?? 0
        default:
            break
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "CocoaDebugSettingsCell")
        cell.textLabel?.textColor = .white
        cell.contentView.backgroundColor = .black
        cell.selectionStyle = .none
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = ignoredURLs?[indexPath.row]
        case 1:
            cell.textLabel?.text = onlyURLs?[indexPath.row]
        case 2:
            cell.textLabel?.text = ignoredPrefixLogs?[indexPath.row]
        case 3:
            cell.textLabel?.text = onlyPrefixLogs?[indexPath.row]
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return "ignored URLs"
        case 1:
            return "only URLs"
        case 2:
            return "ignored Prefix Logs"
        case 3:
            return "only Prefix Logs"
        default:
            break
        }
        
        return ""
    }
}

//MARK: - UITableViewDelegate
extension IgnoredURLsViewController {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 20
    }
}
