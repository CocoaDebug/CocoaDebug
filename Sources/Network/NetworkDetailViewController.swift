//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class NetworkDetailViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var closeItem: UIBarButtonItem!
    @IBOutlet weak var naviItem: UINavigationItem!
    
    var naviItemTitleLabel: UILabel?

    var httpModel: _HttpModel?
    
    var detailModels: [NetworkDetailModel] = [NetworkDetailModel]()
    
    var requestDictionary: [String: Any]? = Dictionary()
    
    var headerCell: NetworkCell?
    
    var messageBody: String = ""

    var justCancelCallback:(() -> Void)?
    
    static func instanceFromStoryBoard() -> NetworkDetailViewController {
        let storyboard = UIStoryboard(name: "Network", bundle: Bundle(for: CocoaDebug.self))
        return storyboard.instantiateViewController(withIdentifier: "NetworkDetailViewController") as! NetworkDetailViewController
    }
    
    
    //MARK: - tool
    func setupModels()
    {
        guard let requestSerializer = httpModel?.requestSerializer else {return}
        var requestContent: String? = nil
        
        //容错判断,否则为nil时会崩溃
        if httpModel?.requestData == nil {
            httpModel?.requestData = Data.init()
        }
        if httpModel?.responseData == nil {
            httpModel?.responseData = Data.init()
        }
        
        //判断请求参数格式JSON/Form
        if requestSerializer == RequestSerializer.JSON {
            //JSON
            requestContent = httpModel?.requestData.dataToPrettyPrintString()
        }
        else if requestSerializer == RequestSerializer.form {
            if let data = httpModel?.requestData {
                //1.protobuf
                if let message = try? _GPBMessage.parse(from: data) {
                    if message.serializedSize() > 0 {
                        requestContent = message.description
                    } else {
                        //2.Form
                        requestContent = data.dataToString()
                    }
                }
                if requestContent == nil || requestContent == "" || requestContent == "\u{8}\u{1e}" {
                    //3.utf-8 string
                    requestContent = String(data: data, encoding: .utf8)
                }
                if requestContent == "" || requestContent == "\u{8}\u{1e}" {
                    requestContent = nil
                }
            }
        }
        
        if httpModel?.isImage == true {
            //图片:
            //1.主要
            let model_1 = NetworkDetailModel.init(title: "URL", content: "https://github.com/CocoaDebug/CocoaDebug", url: httpModel?.url.absoluteString, httpModel: httpModel)
            let model_3 = NetworkDetailModel.init(title: "REQUEST", content: requestContent, url: httpModel?.url.absoluteString, httpModel: httpModel)
            var model_5 = NetworkDetailModel.init(title: "RESPONSE", content: nil, url: httpModel?.url.absoluteString, httpModel: httpModel)
            let model_6 = NetworkDetailModel.init(title: "ERROR", content: httpModel?.errorLocalizedDescription, url: httpModel?.url.absoluteString, httpModel: httpModel)
            let model_7 = NetworkDetailModel.init(title: "ERROR DESCRIPTION", content: httpModel?.errorDescription, url: httpModel?.url.absoluteString, httpModel: httpModel)
            if let responseData = httpModel?.responseData {
                model_5 = NetworkDetailModel.init(title: "RESPONSE", content: nil, url: httpModel?.url.absoluteString, image: UIImage.init(gifData: responseData), httpModel: httpModel)
            }
            //2.次要
            let model_8 = NetworkDetailModel.init(title: "TOTAL TIME", content: httpModel?.totalDuration, url: httpModel?.url.absoluteString, httpModel: httpModel)
            let model_9 = NetworkDetailModel.init(title: "MIME TYPE", content: httpModel?.mineType, url: httpModel?.url.absoluteString, httpModel: httpModel)
            var model_2 = NetworkDetailModel.init(title: "REQUEST HEADER", content: nil, url: httpModel?.url.absoluteString, httpModel: httpModel)
            if let requestHeaderFields = httpModel?.requestHeaderFields {
                if !requestHeaderFields.isEmpty {
                    model_2 = NetworkDetailModel.init(title: "REQUEST HEADER", content: requestHeaderFields.description, url: httpModel?.url.absoluteString, httpModel: httpModel)
                    model_2.requestHeaderFields = requestHeaderFields
                    model_2.content = String(requestHeaderFields.dictionaryToString()?.dropFirst().dropLast().dropFirst().dropLast().dropFirst().dropFirst() ?? "").replacingOccurrences(of: "\",\n  \"", with: "\",\n\"").replacingOccurrences(of: "\\/", with: "/")
                }
            }
            var model_4 = NetworkDetailModel.init(title: "RESPONSE HEADER", content: nil, url: httpModel?.url.absoluteString, httpModel: httpModel)
            if let responseHeaderFields = httpModel?.responseHeaderFields {
                if !responseHeaderFields.isEmpty {
                    model_4 = NetworkDetailModel.init(title: "RESPONSE HEADER", content: responseHeaderFields.description, url: httpModel?.url.absoluteString, httpModel: httpModel)
                    model_4.responseHeaderFields = responseHeaderFields
                    model_4.content = String(responseHeaderFields.dictionaryToString()?.dropFirst().dropLast().dropFirst().dropLast().dropFirst().dropFirst() ?? "").replacingOccurrences(of: "\",\n  \"", with: "\",\n\"").replacingOccurrences(of: "\\/", with: "/")
                }
            }
            let model_0 = NetworkDetailModel.init(title: "RESPONSE SIZE", content: httpModel?.size, url: httpModel?.url.absoluteString, httpModel: httpModel)
            //3.
            detailModels.append(model_1)
            detailModels.append(model_2)
            detailModels.append(model_3)
            detailModels.append(model_4)
            detailModels.append(model_5)
            detailModels.append(model_6)
            detailModels.append(model_7)
            detailModels.append(model_0)
            detailModels.append(model_8)
            detailModels.append(model_9)
        }
        else {
            //非图片:
            //1.主要
            let model_1 = NetworkDetailModel.init(title: "URL", content: "https://github.com/CocoaDebug/CocoaDebug", url: httpModel?.url.absoluteString, httpModel: httpModel)
            let model_3 = NetworkDetailModel.init(title: "REQUEST", content: requestContent, url: httpModel?.url.absoluteString, httpModel: httpModel)
            let model_5 = NetworkDetailModel.init(title: "RESPONSE", content: httpModel?.responseData.dataToPrettyPrintString(), url: httpModel?.url.absoluteString, httpModel: httpModel)
            let model_6 = NetworkDetailModel.init(title: "ERROR", content: httpModel?.errorLocalizedDescription, url: httpModel?.url.absoluteString, httpModel: httpModel)
            let model_7 = NetworkDetailModel.init(title: "ERROR DESCRIPTION", content: httpModel?.errorDescription, url: httpModel?.url.absoluteString, httpModel: httpModel)
            //2.次要
            let model_8 = NetworkDetailModel.init(title: "TOTAL TIME", content: httpModel?.totalDuration, url: httpModel?.url.absoluteString, httpModel: httpModel)
            let model_9 = NetworkDetailModel.init(title: "MIME TYPE", content: httpModel?.mineType, url: httpModel?.url.absoluteString, httpModel: httpModel)
            var model_2 = NetworkDetailModel.init(title: "REQUEST HEADER", content: nil, url: httpModel?.url.absoluteString, httpModel: httpModel)
            if let requestHeaderFields = httpModel?.requestHeaderFields {
                if !requestHeaderFields.isEmpty {
                    model_2 = NetworkDetailModel.init(title: "REQUEST HEADER", content: requestHeaderFields.description, url: httpModel?.url.absoluteString, httpModel: httpModel)
                    model_2.requestHeaderFields = requestHeaderFields
                    model_2.content = String(requestHeaderFields.dictionaryToString()?.dropFirst().dropLast().dropFirst().dropLast().dropFirst().dropFirst() ?? "").replacingOccurrences(of: "\",\n  \"", with: "\",\n\"").replacingOccurrences(of: "\\/", with: "/")
                }
            }
            var model_4 = NetworkDetailModel.init(title: "RESPONSE HEADER", content: nil, url: httpModel?.url.absoluteString, httpModel: httpModel)
            if let responseHeaderFields = httpModel?.responseHeaderFields {
                if !responseHeaderFields.isEmpty {
                    model_4 = NetworkDetailModel.init(title: "RESPONSE HEADER", content: responseHeaderFields.description, url: httpModel?.url.absoluteString, httpModel: httpModel)
                    model_4.responseHeaderFields = responseHeaderFields
                    model_4.content = String(responseHeaderFields.dictionaryToString()?.dropFirst().dropLast().dropFirst().dropLast().dropFirst().dropFirst() ?? "").replacingOccurrences(of: "\",\n  \"", with: "\",\n\"").replacingOccurrences(of: "\\/", with: "/")
                }
            }
            let model_0 = NetworkDetailModel.init(title: "RESPONSE SIZE", content: httpModel?.size, url: httpModel?.url.absoluteString, httpModel: httpModel)
            //3.
            detailModels.append(model_1)
            detailModels.append(model_2)
            detailModels.append(model_3)
            detailModels.append(model_4)
            detailModels.append(model_5)
            detailModels.append(model_6)
            detailModels.append(model_7)
            detailModels.append(model_0)
            detailModels.append(model_8)
            detailModels.append(model_9)
        }
    }
    
    //确定request格式(JSON/Form)
    func detectRequestSerializer() {
        guard let requestData = httpModel?.requestData else {
            httpModel?.requestSerializer = RequestSerializer.JSON//默认JSON格式
            return
        }
        
        if let _ = requestData.dataToDictionary() {
            //JSON格式
            httpModel?.requestSerializer = RequestSerializer.JSON
        } else {
            //Form格式
            httpModel?.requestSerializer = RequestSerializer.form
        }
    }
    
    
    //email configure
    func configureMailComposer(_ copy: Bool = false) -> MFMailComposeViewController? {
        
        //1.image
        var img: UIImage? = nil
        var isImage: Bool = false
        if let httpModel = httpModel {
            isImage = httpModel.isImage
        }
        
        //2.body message ------------------ start ------------------
        var string: String = ""
        messageBody = ""
        
        for model in detailModels {
            if let title = model.title, let content = model.content {
                if content != "" {
                    string = "\n\n" + "------- " + title + " -------" + "\n" + content
                }
            }
            if !messageBody.contains(string) {
                messageBody.append(string)
            }
            //image
            if isImage == true {
                if let image = model.image {
                    img = image
                }
            }
        }
        
        //2.1.url
        var url: String = ""
        if let httpModel = httpModel {
            url = httpModel.url.absoluteString
        }
        
        //2.2.method
        var method: String = ""
        if let httpModel = httpModel {
            method = "[" + httpModel.method + "]"
        }
        
        //2.3.time
        var time: String = ""
        if let httpModel = httpModel {
            if let startTime = httpModel.startTime {
                if (startTime as NSString).doubleValue == 0 {
                    time = _OCLoggerFormat.formatDate(Date())
                } else {
                    time = _OCLoggerFormat.formatDate(NSDate(timeIntervalSince1970: (startTime as NSString).doubleValue) as Date)
                }
            }
        }
        
        //2.4.statusCode
        var statusCode: String = ""
        if let httpModel = httpModel {
            statusCode = httpModel.statusCode
            if statusCode == "0" { //"0" means network unavailable
                statusCode = "❌"
            }
        }
        
        //body message ------------------ end ------------------
        var subString = method + " " + time + " " + "(" + statusCode + ")"
        if subString.contains("❌") {
            subString = subString.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
        }
        
        messageBody = messageBody.replacingOccurrences(of: "https://github.com/CocoaDebug/CocoaDebug", with: url)
        messageBody = subString + messageBody
        
        //////////////////////////////////////////////////////////////////////////////////
        
        if !MFMailComposeViewController.canSendMail() {
            if copy == false {
                //share via email
                let alert = UIAlertController.init(title: "No Mail Accounts", message: "Please set up a Mail account in order to send email.", preferredStyle: .alert)
                let action = UIAlertAction.init(title: "OK", style: .cancel) { _ in
//                    CocoaDebugSettings.shared.responseShakeNetworkDetail = true
                }
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            } else {
                //copy to clipboard
//                CocoaDebugSettings.shared.responseShakeNetworkDetail = true
            }
            
            return nil
        }
        
        if copy == true {
            //copy to clipboard
//            CocoaDebugSettings.shared.responseShakeNetworkDetail = true
            return nil
        }
        
        //3.email recipients
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients(CocoaDebugSettings.shared.emailToRecipients)
        mailComposeVC.setCcRecipients(CocoaDebugSettings.shared.emailCcRecipients)
        
        //4.image
        if let img = img {
            if let imageData = img.pngData() {
                mailComposeVC.addAttachmentData(imageData, mimeType: "image/png", fileName: "image")
            }
        }
        
        //5.body
        mailComposeVC.setMessageBody(messageBody, isHTML: false)
        
        //6.subject
        mailComposeVC.setSubject(url)

        return mailComposeVC
    }
    
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviItemTitleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        naviItemTitleLabel?.textAlignment = .center
        naviItemTitleLabel?.textColor = Color.mainGreen
        naviItemTitleLabel?.font = .boldSystemFont(ofSize: 20)
        naviItemTitleLabel?.text = "Details"
        naviItem.titleView = naviItemTitleLabel
        
        closeItem.tintColor = Color.mainGreen
        
        //确定request格式(JSON/Form)
        detectRequestSerializer()
            
        setupModels()
        
        if var lastModel = detailModels.last {
            lastModel.isLast = true
            detailModels.removeLast()
            detailModels.append(lastModel)
        }
        
        //使用单独的xib-cell文件, 必须注册, 否则崩溃
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "NetworkCell", bundle: bundle)
        tableView.register(nib, forCellReuseIdentifier: "NetworkCell")
        
        //header
        headerCell = bundle.loadNibNamed(String(describing: NetworkCell.self), owner: nil, options: nil)?.first as? NetworkCell
        headerCell?.httpModel = httpModel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //notification
//        NotificationCenter.default.addObserver(self, selector: #selector(motionShake_notification), name: NSNotification.Name(rawValue: "motionShake_CocoaDebug"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //notification
//        NotificationCenter.default.removeObserver(self)

        if let justCancelCallback = justCancelCallback {
            justCancelCallback()
        }
    }
    
    //MARK: - target action
    @IBAction func close(_ sender: UIBarButtonItem) {
        (self.navigationController as! CocoaDebugNavigationController).exit()
    }
    
    @IBAction func didTapMail(_ sender: UIBarButtonItem) {
        
//        CocoaDebugSettings.shared.responseShakeNetworkDetail = false
        
        // create an actionSheet
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // create an action
        let firstAction: UIAlertAction = UIAlertAction(title: "share via email", style: .default) { [weak self] action -> Void in
            if let mailComposeViewController = self?.configureMailComposer() {
                self?.present(mailComposeViewController, animated: true, completion: nil)
            }
        }
        
        let secondAction: UIAlertAction = UIAlertAction(title: "copy to clipboard", style: .default) { [weak self] action -> Void in
            _ = self?.configureMailComposer(true)
            UIPasteboard.general.string = self?.messageBody
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
//            CocoaDebugSettings.shared.responseShakeNetworkDetail = true
        }
        
        // add actions
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(cancelAction)
        
        // present an actionSheet...
        present(actionSheetController, animated: true, completion: nil)
    }
    
    
    //MARK: - notification
//    @objc func motionShake_notification() {
//        dispatch_main_async_safe { [weak self] in
//
//        }
//    }
}

//MARK: - UITableViewDataSource
extension NetworkDetailViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkDetailCell", for: indexPath)
            as! NetworkDetailCell
        cell.detailModel = detailModels[indexPath.row]
        
        //2.点击了编辑view
        cell.tapEditViewCallback = { [weak self] detailModel in
            let vc = JsonViewController.instanceFromStoryBoard()
            vc.detailModel = detailModel
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension NetworkDetailViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let detailModel = detailModels[indexPath.row]
        
        if detailModel.blankContent == "..." {
            if detailModel.isLast == true {
                return 50.5
            }
            return 50
        }
        
        if indexPath.row == 0 {
            return 0
        }
        
        if detailModel.image == nil {
            if let content = detailModel.content {
                if content == "" {
                    return 0
                }
                //计算NSString高度
                let height = content.height(with: UIFont.systemFont(ofSize: 13), constraintToWidth: (UIScreen.main.bounds.size.width - 30))
                return (height + 70) > 5000 ? 5000 : (height + 70)
            }
            return 0
        }
        
        return UIScreen.main.bounds.size.width + 50
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerCell?.contentView
    }


    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let serverURL = CocoaDebugSettings.shared.serverURL else {return 0}
        
        var height: CGFloat = 0.0
            
        if let cString = httpModel?.url.absoluteString.cString(using: String.Encoding.utf8) {
            if let content_ = NSString(cString: cString, encoding: String.Encoding.utf8.rawValue) {
                
                if httpModel?.url.absoluteString.contains(serverURL) == true {
                    //计算NSString高度
                    if #available(iOS 8.2, *) {
                        height = content_.height(with: UIFont.systemFont(ofSize: 13, weight: .heavy), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    } else {
                        // Fallback on earlier versions
                        height = content_.height(with: UIFont.boldSystemFont(ofSize: 13), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    }
                } else {
                    //计算NSString高度
                    if #available(iOS 8.2, *) {
                        height = content_.height(with: UIFont.systemFont(ofSize: 13, weight: .regular), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    } else {
                        // Fallback on earlier versions
                        height = content_.height(with: UIFont.systemFont(ofSize: 13), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    }
                }
                return height + 57
            }
        }
        
        return 0
    }
}

//MARK: - MFMailComposeViewControllerDelegate
extension NetworkDetailViewController {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true) {
            if error != nil {
                let alert = UIAlertController.init(title: error?.localizedDescription, message: nil, preferredStyle: .alert)
                let action = UIAlertAction.init(title: "OK", style: .cancel, handler: { _ in
//                    CocoaDebugSettings.shared.responseShakeNetworkDetail = true
                })
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            } else {
//                CocoaDebugSettings.shared.responseShakeNetworkDetail = true
            }
        }
    }
}
