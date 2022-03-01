//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import UIKit

class AppInfoViewController: UITableViewController {
    
    @IBOutlet weak var labelVersionNumber: UILabel!
    @IBOutlet weak var labelBuildNumber: UILabel!
    @IBOutlet weak var labelBundleName: UILabel!
    @IBOutlet weak var labelScreenResolution: UILabel!
    @IBOutlet weak var labelDeviceModel: UILabel!
    @IBOutlet weak var labelBundleID: UILabel!
    @IBOutlet weak var labelIOSVersion: UILabel!

    @IBOutlet weak var slowAnimationsSwitch: UISwitch!
    @IBOutlet weak var naviItem: UINavigationItem!
    
    var naviItemTitleLabel: UILabel?
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviItemTitleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        naviItemTitleLabel?.textAlignment = .center
        naviItemTitleLabel?.font = .boldSystemFont(ofSize: 17)
        naviItemTitleLabel?.text = "App"
        naviItem.titleView = naviItemTitleLabel
        
        
        labelVersionNumber.text = CocoaDebugDeviceInfo.sharedInstance().appVersion
        labelBuildNumber.text = CocoaDebugDeviceInfo.sharedInstance().appBuiltVersion
        labelBundleName.text = CocoaDebugDeviceInfo.sharedInstance().appBundleName
        
        labelScreenResolution.text = "\(Int(CocoaDebugDeviceInfo.sharedInstance().resolution.width))" + "*" + "\(Int(CocoaDebugDeviceInfo.sharedInstance().resolution.height))"
        labelDeviceModel.text = "\(UIDevice().cocoadebugDeviceType.rawValue)"
        
        labelBundleID.text = CocoaDebugDeviceInfo.sharedInstance().appBundleID
        
        labelIOSVersion.text = UIDevice.current.systemVersion
        slowAnimationsSwitch.isOn = CocoaDebugSettings.shared.slowAnimations
        slowAnimationsSwitch.addTarget(self, action: #selector(slowAnimationsSwitchChanged), for: UIControl.Event.valueChanged)
    }
    
    
    //MARK: - alert
    func showAlert() {
        let alert = UIAlertController.init(title: nil, message: "You must restart APP to ensure the changes take effect", preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: "Restart later", style: .cancel, handler: nil)
        let okAction = UIAlertAction.init(title: "Restart now", style: .destructive) { _ in
            exit(0)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        alert.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - target action
    @objc func slowAnimationsSwitchChanged(sender: UISwitch) {
        CocoaDebugSettings.shared.slowAnimations = slowAnimationsSwitch.isOn
    }
}


//MARK: - UITableViewDelegate
extension AppInfoViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if section == 0 {
            return 56
        }
        return 38
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44
    }
}
