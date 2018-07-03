//
//  DebugWidget.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class CrashDetailViewController: UITableViewController {

    @IBOutlet weak var textviewName: UITextView!
    @IBOutlet weak var textviewReason: UITextView!
    @IBOutlet weak var textviewStackTraces: UITextView!
    var crash: CrashModel?

    static func instanceFromStoryBoard() -> CrashDetailViewController {
        let storyboard = UIStoryboard(name: "App", bundle: Bundle(for: DebugWidget.self))
        return storyboard.instantiateViewController(withIdentifier: "CrashDetailViewController") as! CrashDetailViewController
    }
    
    //MARK - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        tableView.delegate = self

        textviewName.text = "\(crash?.name ?? "N/A")"
        textviewReason.text = "\(crash?.reason ?? "N/A")"

        let contentStack = crash?.callStacks?.reduce("", {
            $0 == "" ? $1 : $0 + "\n" + $1
        })
        textviewStackTraces.text = contentStack
    }
}

//MARK: - UITableViewDelegate
extension CrashDetailViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
