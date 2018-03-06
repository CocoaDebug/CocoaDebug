//
//  AboutViewController.swift
//  PhiHome
//
//  Created by liman on 13/12/2017.
//  Copyright © 2017 Phicomm. All rights reserved.
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
        guard let url = URL.init(string: "https://github.com/DotzuX/DotzuX") else {return}
        UIApplication.shared.openURL(url)
    }
}
