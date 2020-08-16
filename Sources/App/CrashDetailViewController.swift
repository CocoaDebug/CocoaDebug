//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

import UIKit

class CrashDetailViewController: UITableViewController {
    
    @IBOutlet weak var textviewName: CustomTextView!
    @IBOutlet weak var textviewReason: CustomTextView!
    @IBOutlet weak var textviewStackTraces: CustomTextView!
    @IBOutlet weak var naviItem: UINavigationItem!
    
    var naviItemTitleLabel: UILabel?

    var crash: _CrashModel?

    static func instanceFromStoryBoard() -> CrashDetailViewController {
        let storyboard = UIStoryboard(name: "App", bundle: Bundle(for: CocoaDebug.self))
        return storyboard.instantiateViewController(withIdentifier: "CrashDetailViewController") as! CrashDetailViewController
    }
    
    //MARK - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviItemTitleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        naviItemTitleLabel?.textAlignment = .center
        naviItemTitleLabel?.textColor = Color.mainGreen
        naviItemTitleLabel?.font = .boldSystemFont(ofSize: 20)
        naviItemTitleLabel?.text = "Details"
        naviItem.titleView = naviItemTitleLabel
        
        tableView.rowHeight = UITableView.automaticDimension
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
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
