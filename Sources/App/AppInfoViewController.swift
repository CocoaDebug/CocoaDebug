//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import UIKit

class AppInfoViewController: UITableViewController {
    
    @IBOutlet weak var labelVersionNumber: UILabel!
    @IBOutlet weak var labelBuildNumber: UILabel!
    @IBOutlet weak var labelBundleName: UILabel!
    @IBOutlet weak var labelScreenResolution: UILabel!
    @IBOutlet weak var labelScreenSize: UILabel!
    @IBOutlet weak var labelDeviceModel: UILabel!
    @IBOutlet weak var labelCrashCount: UILabel!
    @IBOutlet weak var labelBundleID: UILabel!
    @IBOutlet weak var labelignoredURLs: UILabel!
    @IBOutlet weak var labelserverURL: UILabel!
    @IBOutlet weak var labelIOSVersion: UILabel!
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add FPSLabel behind status bar
//        addStatusBarBackgroundView(viewController: self)
        
        labelCrashCount.frame.size = CGSize(width: 30, height: 20)

        labelVersionNumber.text = AppInfo.versionNumber
        labelBuildNumber.text = AppInfo.buildNumber
        labelBundleName.text = AppInfo.bundleName

        labelScreenResolution.text = Device.screenResolution
        labelScreenSize.text = "\(Device.screenSize)"
        labelDeviceModel.text = "\(Device.deviceModel)"
        
        labelBundleID.text = Bundle.main.bundleIdentifier
        labelignoredURLs.text = String(CocoaDebugSettings.shared.ignoredURLs?.count ?? 0)
        
        labelserverURL.text = CocoaDebugSettings.shared.serverURL
        labelIOSVersion.text = UIDevice.current.systemVersion
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let count = UserDefaults.standard.integer(forKey: "crashCount_CocoaDebug")
        labelCrashCount.text = "\(count)"
        labelCrashCount.textColor = count > 0 ? .red : .white
    }
}

//MARK: - UITableViewDelegate
extension AppInfoViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if CocoaDebugSettings.shared.recordCrash == true {
            if section == 0 {
                return 56
            }
        }else{
            if section == 0 {
                return 0
            }
            if section == 1 {
                return 3
            }
        }
        return 38
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if CocoaDebugSettings.shared.recordCrash == false {
            if indexPath.section == 0 && indexPath.row == 0 {
                return 0
            }
        }
        
        if indexPath.section == 1 && indexPath.row == 4 {
            if labelserverURL.text == nil || labelserverURL.text == "" {
                return 0
            }
        }
        if indexPath.section == 2 && indexPath.row == 1 {
            if labelScreenSize.text == "0.0" {
                return 0
            }
        }
        if indexPath.section == 3 && indexPath.row == 0 {
            if labelignoredURLs.text == "0" {
                if UIScreen.main.scale == 3 {
                    return 1.5//plus,iPhone X
                }
                return 0.5//iphone 5,6,6s,7,8
            }
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 3 {
            UIPasteboard.general.string = Bundle.main.bundleIdentifier
            
            let alert = UIAlertController.init(title: "copied to clipboard", message: nil, preferredStyle: .alert)
            let action = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
        if indexPath.section == 1 && indexPath.row == 4 {
            if labelserverURL.text == nil || labelserverURL.text == "" {
                return
            }
            
            UIPasteboard.general.string = CocoaDebugSettings.shared.serverURL
            
            let alert = UIAlertController.init(title: "copied to clipboard", message: nil, preferredStyle: .alert)
            let action = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
