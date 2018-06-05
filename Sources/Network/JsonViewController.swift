//
//  DotzuX.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

enum EditType {
    case unknown
    case requestHeader
    case responseHeader
}

import Foundation
import UIKit

class JsonViewController: UITableViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    var editType: EditType  = .unknown
    var httpModel: HttpModel?
    var detailModel: NetworkDetailModel?
    
    //编辑过的url
    var editedURLString: String?
    //编辑过的content (request/header)
    var editedContent: String?
    
    static func instanceFromStoryBoard() -> JsonViewController {
        let storyboard = UIStoryboard(name: "Network", bundle: Bundle(for: DotzuX.self))
        return storyboard.instantiateViewController(withIdentifier: "JsonViewController") as! JsonViewController
    }
    
    //MARK: - tool
    
    //确定格式(JSON/Form)
    func detectSerializer() {
        guard let content = detailModel?.content else {
            detailModel?.requestSerializer = JSONRequestSerializer//默认JSON格式
            return
        }
        
        if let _ = content.stringToDictionary() {
            //JSON格式
            detailModel?.requestSerializer = JSONRequestSerializer
        }else{
            //Form格式
            detailModel?.requestSerializer = FormRequestSerializer
            
                if let jsonString = detailModel?.content?.formStringToJsonString() {
                    textView.text = jsonString
                    detailModel?.requestSerializer = JSONRequestSerializer
                    detailModel?.content = textView.text
                }
        }
    }
    
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        
        self.title = detailModel?.title
        
        //判断类型 (默认类型URL)
        if detailModel?.title == "REQUEST HEADER" {
            editType = .requestHeader
        }
        if detailModel?.title == "RESPONSE HEADER" {
            editType = .responseHeader
        }
        
        //设置UI
        if editType == .requestHeader
        {
            imageView.isHidden = true
            textView.isHidden = false
            textView.text = detailModel?.requestHeaderFields?.dictionaryToString()
        }
        else if editType == .responseHeader
        {
            imageView.isHidden = true
            textView.isHidden = false
            textView.text = detailModel?.responseHeaderFields?.dictionaryToString()
        }
        else
        {
            if let content = detailModel?.content {
                imageView.isHidden = true
                textView.isHidden = false
                textView.text = content
                detectSerializer()//确定格式(JSON/Form)
            }
            if let image = detailModel?.image {
                textView.isHidden = true
                imageView.isHidden = false
                imageView.image = image
            }
        }
    }
}
