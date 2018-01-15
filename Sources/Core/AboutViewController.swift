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
    
    static func instanceFromStoryBoard() -> AboutViewController {
        let storyboard = UIStoryboard(name: "App", bundle: Bundle(for: DebugMan.self))
        return storyboard.instantiateViewController(withIdentifier: "AboutViewController") as! AboutViewController
    }
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    //MARK: - target action
    @IBAction func tapURL(_ sender: UITapGestureRecognizer) {
        guard let url = URL.init(string: "https://github.com/liman123/DebugMan") else {return}
        UIApplication.shared.openURL(url)
    }
}
