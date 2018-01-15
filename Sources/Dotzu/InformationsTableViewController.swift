//
//  InformationsTableViewController.swift
//  exampleWindow
//
//  Created by Remi Robert on 18/01/2017.
//  Copyright © 2017 Remi Robert. All rights reserved.
//

import UIKit

class InformationsTableViewController: UITableViewController {

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
        
        labelCrashCount.frame.size = CGSize(width: 30, height: 20)

        labelVersionNumber.text = ApplicationInformation.versionNumber
        labelBuildNumber.text = ApplicationInformation.buildNumber
        labelBundleName.text = ApplicationInformation.bundleName

        labelScreenResolution.text = Device.screenResolution
        labelScreenSize.text = "\(Device.screenSize)"
        labelDeviceModel.text = "\(Device.deviceModel)"
        
        labelBundleID.text = Bundle.main.bundleIdentifier
        labelignoredURLs.text = String(LogsSettings.shared.ignoredURLs?.count ?? 0)
        
        labelserverURL.text = LogsSettings.shared.serverURL
        labelIOSVersion.text = UIDevice.current.systemVersion
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let count = UserDefaults.standard.integer(forKey: "crashCount")
        labelCrashCount.text = "\(count)"
        labelCrashCount.textColor = count > 0 ? UIColor.red : UIColor.white
    }
    
    //MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == 1 && indexPath.row == 4 {
            if labelserverURL.text == nil || labelserverURL.text == "" {
                return 0
            }
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 3 {
            UIPasteboard.general.string = Bundle.main.bundleIdentifier
            
            let alert = UIAlertController.init(title: "copy bundle id to clipboard success", message: nil, preferredStyle: .alert)
            let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
        if indexPath.section == 1 && indexPath.row == 4 {
            if labelserverURL.text == nil || labelserverURL.text == "" {
                return
            }
            
            UIPasteboard.general.string = LogsSettings.shared.serverURL
            
            let alert = UIAlertController.init(title: "copy server URL to clipboard success", message: nil, preferredStyle: .alert)
            let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
        if indexPath.section == 3 && indexPath.row == 0 {
            let vc = IgnoredURLsViewController.instanceFromStoryBoard()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
