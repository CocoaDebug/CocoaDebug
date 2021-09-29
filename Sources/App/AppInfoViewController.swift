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
    @IBOutlet weak var labelCrashCount: UILabel!
    @IBOutlet weak var labelBundleID: UILabel!
    @IBOutlet weak var labelserverURL: UILabel!
    @IBOutlet weak var labelIOSVersion: UILabel!
    @IBOutlet weak var labelHtml: UILabel!
    @IBOutlet weak var crashSwitch: UISwitch!
    @IBOutlet weak var logSwitch: UISwitch!
    @IBOutlet weak var networkSwitch: UISwitch!
    @IBOutlet weak var webViewSwitch: UISwitch!
    @IBOutlet weak var slowAnimationsSwitch: UISwitch!
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var rnSwitch: UISwitch!
    @IBOutlet weak var uiBlockingSwitch: UISwitch!
    
    var naviItemTitleLabel: UILabel?
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviItemTitleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        naviItemTitleLabel?.textAlignment = .center
        naviItemTitleLabel?.textColor = Color.mainGreen
        naviItemTitleLabel?.font = .boldSystemFont(ofSize: 20)
        naviItemTitleLabel?.text = "App"
        naviItem.titleView = naviItemTitleLabel
        
        labelCrashCount.frame.size = CGSize(width: 30, height: 20)
        
        labelVersionNumber.text = CocoaDebugDeviceInfo.sharedInstance().appVersion
        labelBuildNumber.text = CocoaDebugDeviceInfo.sharedInstance().appBuiltVersion
        labelBundleName.text = CocoaDebugDeviceInfo.sharedInstance().appBundleName
        
        labelScreenResolution.text = "\(Int(CocoaDebugDeviceInfo.sharedInstance().resolution.width))" + "*" + "\(Int(CocoaDebugDeviceInfo.sharedInstance().resolution.height))"
        labelDeviceModel.text = "\(CocoaDebugDeviceInfo.sharedInstance().getPlatformString)"
        
        labelBundleID.text = CocoaDebugDeviceInfo.sharedInstance().appBundleID
        
        labelserverURL.text = CocoaDebugSettings.shared.serverURL
        labelIOSVersion.text = UIDevice.current.systemVersion
        
        if UIScreen.main.bounds.size.width == 320 {
            labelHtml.font = UIFont.systemFont(ofSize: 15)
        }
        
        logSwitch.isOn = CocoaDebugSettings.shared.enableLogMonitoring
        networkSwitch.isOn = !CocoaDebugSettings.shared.disableNetworkMonitoring
        rnSwitch.isOn = CocoaDebugSettings.shared.enableRNMonitoring
        webViewSwitch.isOn = CocoaDebugSettings.shared.enableWKWebViewMonitoring
        slowAnimationsSwitch.isOn = CocoaDebugSettings.shared.slowAnimations
        crashSwitch.isOn = CocoaDebugSettings.shared.enableCrashRecording
        uiBlockingSwitch.isOn = CocoaDebugSettings.shared.enableUIBlockingMonitoring

        logSwitch.addTarget(self, action: #selector(logSwitchChanged), for: UIControl.Event.valueChanged)
        networkSwitch.addTarget(self, action: #selector(networkSwitchChanged), for: UIControl.Event.valueChanged)
        rnSwitch.addTarget(self, action: #selector(rnSwitchChanged), for: UIControl.Event.valueChanged)
        webViewSwitch.addTarget(self, action: #selector(webViewSwitchChanged), for: UIControl.Event.valueChanged)
        slowAnimationsSwitch.addTarget(self, action: #selector(slowAnimationsSwitchChanged), for: UIControl.Event.valueChanged)
        crashSwitch.addTarget(self, action: #selector(crashSwitchChanged), for: UIControl.Event.valueChanged)
        uiBlockingSwitch.addTarget(self, action: #selector(uiBlockingSwitchChanged), for: UIControl.Event.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let count = UserDefaults.standard.integer(forKey: "crashCount_CocoaDebug")
        labelCrashCount.text = "\(count)"
        labelCrashCount.textColor = count > 0 ? .red : .white
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
        //        self.showAlert()
    }
    
    @objc func uiBlockingSwitchChanged(sender: UISwitch) {
        CocoaDebugSettings.shared.enableUIBlockingMonitoring = uiBlockingSwitch.isOn
        if uiBlockingSwitch.isOn == true {
            WindowHelper.shared.startUIBlockingMonitoring()
        } else {
            WindowHelper.shared.stopUIBlockingMonitoring()
        }
    }
    
    @objc func crashSwitchChanged(sender: UISwitch) {
        CocoaDebugSettings.shared.enableCrashRecording = crashSwitch.isOn
        self.showAlert()
    }
    
    @objc func networkSwitchChanged(sender: UISwitch) {
        CocoaDebugSettings.shared.disableNetworkMonitoring = !networkSwitch.isOn
        self.showAlert()
    }
    
    @objc func logSwitchChanged(sender: UISwitch) {
        CocoaDebugSettings.shared.enableLogMonitoring = logSwitch.isOn
        self.showAlert()
    }
    
    @objc func rnSwitchChanged(sender: UISwitch) {
        CocoaDebugSettings.shared.enableRNMonitoring = rnSwitch.isOn
        self.showAlert()
    }
    
    @objc func webViewSwitchChanged(sender: UISwitch) {
        CocoaDebugSettings.shared.enableWKWebViewMonitoring = webViewSwitch.isOn
        self.showAlert()
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
        
        if indexPath.section == 1 && indexPath.row == 2 {
            UIPasteboard.general.string = CocoaDebugDeviceInfo.sharedInstance().appBundleName
            
            let alert = UIAlertController.init(title: "copied bundle name to clipboard", message: nil, preferredStyle: .alert)
            let action = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            
            alert.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        if indexPath.section == 1 && indexPath.row == 3 {
            UIPasteboard.general.string = CocoaDebugDeviceInfo.sharedInstance().appBundleID
            
            let alert = UIAlertController.init(title: "copied bundle id to clipboard", message: nil, preferredStyle: .alert)
            let action = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            
            alert.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        if indexPath.section == 1 && indexPath.row == 4 {
            if labelserverURL.text == nil || labelserverURL.text == "" {return}
            
            UIPasteboard.general.string = CocoaDebugSettings.shared.serverURL
            
            let alert = UIAlertController.init(title: "copied server to clipboard", message: nil, preferredStyle: .alert)
            let action = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            
            alert.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}
