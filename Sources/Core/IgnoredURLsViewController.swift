//
//  IgnoredURLsViewController.swift
//  PhiHome
//
//  Created by liman on 28/11/2017.
//  Copyright © 2017 Phicomm. All rights reserved.
//

import Foundation
import UIKit

class IgnoredURLsViewController: UITableViewController {
    
    var models: Array<String>?
    
    static func instanceFromStoryBoard() -> IgnoredURLsViewController {
        let storyboard = UIStoryboard(name: "App", bundle: Bundle(for: DebugMan.self))
        return storyboard.instantiateViewController(withIdentifier: "IgnoredURLsViewController") as! IgnoredURLsViewController
    }
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()

        models = LogsSettings.shared.ignoredURLs
    }
    
    //MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = models?[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        cell.contentView.backgroundColor = UIColor.black
        cell.selectionStyle = .none
        
        return cell
    }
}
