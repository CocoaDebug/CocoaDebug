//
//  DotzuX.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import UIKit

class NetworkDetailViewController: UITableViewController {
    
    var httpModel: HttpModel?
    
    lazy var detailModels: [NetworkDetailModel] = [NetworkDetailModel]()
    
    lazy var requestDictionary: [String: Any]? = Dictionary()
    
    var headerCell: NetworkCell?

    var justCancelCallback:(() -> Void)?
    
    static func instanceFromStoryBoard() -> NetworkDetailViewController {
        let storyboard = UIStoryboard(name: "Network", bundle: Bundle(for: DotzuX.self))
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
        if requestSerializer == JSONRequestSerializer {
            //JSON
            requestContent = httpModel?.requestData.dataToPrettyPrintString()
        }
        if requestSerializer == FormRequestSerializer {
            //Form
            requestContent = httpModel?.requestData.dataToString()
        }
        
        if httpModel?.isImage == true {
            //图片:
            //1.主要
            let m1 = NetworkDetailModel.init(title: "URL", content: "http://www.phicomm.com/cn/")
            let m2 = NetworkDetailModel.init(title: "REQUEST", content: requestContent)
            var m3 = NetworkDetailModel.init(title: "RESPONSE", content: nil)
            let m8 = NetworkDetailModel.init(title: "ERROR", content: httpModel?.errorLocalizedDescription)
            let m4 = NetworkDetailModel.init(title: "ERROR DESCRIPTION", content: httpModel?.errorDescription)
            if let responseData = httpModel?.responseData {
                m3 = NetworkDetailModel.init(title: "RESPONSE", content: nil, UIImage.init(data: responseData))
            }
            //2.次要
            let m5 = NetworkDetailModel.init(title: "TOTAL TIME", content: httpModel?.totalDuration)
            let m6 = NetworkDetailModel.init(title: "MIME TYPE", content: httpModel?.mineType)
            var m7 = NetworkDetailModel.init(title: "REQUEST HEADER", content: nil)
            if let requestHeaderFields = httpModel?.requestHeaderFields {
                if !requestHeaderFields.isEmpty {
                    m7 = NetworkDetailModel.init(title: "REQUEST HEADER", content: requestHeaderFields.description)
                    m7.requestHeaderFields = requestHeaderFields
                    m7.content = requestHeaderFields.dictionaryToString()?.replacingOccurrences(of: "{", with: "[").replacingOccurrences(of: "}", with: "]")
                }
            }
            var m7_ = NetworkDetailModel.init(title: "RESPONSE HEADER", content: nil)
            if let responseHeaderFields = httpModel?.responseHeaderFields {
                if !responseHeaderFields.isEmpty {
                    m7_ = NetworkDetailModel.init(title: "RESPONSE HEADER", content: responseHeaderFields.description)
                    m7_.responseHeaderFields = responseHeaderFields
                    m7_.content = responseHeaderFields.dictionaryToString()?.replacingOccurrences(of: "{", with: "[").replacingOccurrences(of: "}", with: "]")
                }
            }
            //3.
            detailModels.append(m1)
            detailModels.append(m7)
            detailModels.append(m2)
            detailModels.append(m7_)
            detailModels.append(m3)
            detailModels.append(m8)
            detailModels.append(m4)
            detailModels.append(m5)
            detailModels.append(m6)
        }
        else{
            //非图片:
            //1.主要
            let m1 = NetworkDetailModel.init(title: "URL", content: "http://www.phicomm.com/cn/")
            let m2 = NetworkDetailModel.init(title: "REQUEST", content: requestContent)
            let m3 = NetworkDetailModel.init(title: "RESPONSE", content: httpModel?.responseData.dataToPrettyPrintString())
            let m8 = NetworkDetailModel.init(title: "ERROR", content: httpModel?.errorLocalizedDescription)
            let m4 = NetworkDetailModel.init(title: "ERROR DESCRIPTION", content: httpModel?.errorDescription)
            //2.次要
            let m5 = NetworkDetailModel.init(title: "TOTAL TIME", content: httpModel?.totalDuration)
            let m6 = NetworkDetailModel.init(title: "MIME TYPE", content: httpModel?.mineType)
            var m7 = NetworkDetailModel.init(title: "REQUEST HEADER", content: nil)
            if let requestHeaderFields = httpModel?.requestHeaderFields {
                if !requestHeaderFields.isEmpty {
                    m7 = NetworkDetailModel.init(title: "REQUEST HEADER", content: requestHeaderFields.description)
                    m7.requestHeaderFields = requestHeaderFields
                    m7.content = requestHeaderFields.dictionaryToString()?.replacingOccurrences(of: "{", with: "[").replacingOccurrences(of: "}", with: "]")
                }
            }
            var m7_ = NetworkDetailModel.init(title: "RESPONSE HEADER", content: nil)
            if let responseHeaderFields = httpModel?.responseHeaderFields {
                if !responseHeaderFields.isEmpty {
                    m7_ = NetworkDetailModel.init(title: "RESPONSE HEADER", content: responseHeaderFields.description)
                    m7_.responseHeaderFields = responseHeaderFields
                    m7_.content = responseHeaderFields.dictionaryToString()?.replacingOccurrences(of: "{", with: "[").replacingOccurrences(of: "}", with: "]")
                }
            }
            //3.
            detailModels.append(m1)
            detailModels.append(m7)
            detailModels.append(m2)
            detailModels.append(m7_)
            detailModels.append(m3)
            detailModels.append(m8)
            detailModels.append(m4)
            detailModels.append(m5)
            detailModels.append(m6)
        }
    }
    
    //确定request格式(JSON/Form)
    func detectRequestSerializer() {
        guard let requestData = httpModel?.requestData else {
            httpModel?.requestSerializer = JSONRequestSerializer//默认JSON格式
            return
        }
        
        if let _ = requestData.dataToDictionary() {
            //JSON格式
            httpModel?.requestSerializer = JSONRequestSerializer
        }else{
            //Form格式
            httpModel?.requestSerializer = FormRequestSerializer
        }
    }
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let justCancelCallback = justCancelCallback {
            justCancelCallback()
        }
    }
    
    //MARK: - target action
    @IBAction func close(_ sender: UIBarButtonItem) {
        (self.navigationController as! DotzuXNavigationController).exit()
    }
    
    
    //MARK: - override
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(selectAll(_:)) {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func selectAll(_ sender: Any?) {
        headerCell?.requestUrlTextView.selectAll(sender)
    }
}

//MARK: - UITableViewDataSource
extension NetworkDetailViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.row == 0 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkCell", for: indexPath)
//                as! NetworkCell
//            cell.httpModel = httpModel
//            return cell
//        }
        
        //------------------------------------------------------------------------------
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkDetailCell", for: indexPath)
            as! NetworkDetailCell
        cell.detailModel = detailModels[indexPath.row]
        
        //1.点击了标题view
//        cell.tapTitleViewCallback = { [weak self] detailModel in
//            if let index = self?.detailModels.index(where: { (model_) -> Bool in
//                return model_.title == detailModel?.title
//            }) {
//                if var model = self?.detailModels[index] {
//                    if model.blankContent == "..." {
//                        model.blankContent = nil
//                    }else{
//                        model.blankContent = "..."
//                    }
//                    self?.detailModels.remove(at: index)
//                    self?.detailModels.insert(model, at: index)
//                }
//            }
//            self?.tableView.reloadData()
//        }
        
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
                let height = content.dotzuX_height(with: UIFont.systemFont(ofSize: 13), constraintToWidth: (UIScreen.main.bounds.size.width - 30))
                return height + 70
            }
            return 0
        }
        
        return UIScreen.main.bounds.size.width + 50
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerCell?.contentView
    }


    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let serverURL = DotzuXSettings.shared.serverURL else {return 0}
        
        var height: CGFloat = 0.0
        if let cString = self.httpModel?.url.absoluteString.cString(using: String.Encoding.utf8) {
            if let content_ = NSString(cString: cString, encoding: String.Encoding.utf8.rawValue) {
                
                if self.httpModel?.url.absoluteString.contains(serverURL) == true {
                    //计算NSString高度
                    if #available(iOS 8.2, *) {
                        height = content_.dotzuX_height(with: UIFont.systemFont(ofSize: 13, weight: .heavy), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    } else {
                        // Fallback on earlier versions
                        height = content_.dotzuX_height(with: UIFont.boldSystemFont(ofSize: 13), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    }
                }else{
                    //计算NSString高度
                    if #available(iOS 8.2, *) {
                        height = content_.dotzuX_height(with: UIFont.systemFont(ofSize: 13, weight: .regular), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    } else {
                        // Fallback on earlier versions
                        height = content_.dotzuX_height(with: UIFont.systemFont(ofSize: 13), constraintToWidth: (UIScreen.main.bounds.size.width - 92))
                    }
                }
                return height + 57
            }
        }
        return 0
    }
}
