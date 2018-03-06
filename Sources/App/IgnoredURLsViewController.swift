//
//  DotzuX.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import UIKit

class IgnoredURLsViewController: UITableViewController {
    
    var models: Array<String>?
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()

        models = DotzuXSettings.shared.ignoredURLs
    }
    
    //MARK: - UITableViewDataSource
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
