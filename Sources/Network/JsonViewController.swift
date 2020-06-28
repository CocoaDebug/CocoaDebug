//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

enum EditType {
    case unknown
    case requestHeader
    case responseHeader
}

import Foundation
import UIKit

class JsonViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    var editType: EditType  = .unknown
    var httpModel: _HttpModel?
    var detailModel: NetworkDetailModel?
    
    //编辑过的url
    var editedURLString: String?
    //编辑过的content
    var editedContent: String?
    
    static func instanceFromStoryBoard() -> JsonViewController {
        let storyboard = UIStoryboard(name: "Network", bundle: Bundle(for: CocoaDebug.self))
        return storyboard.instantiateViewController(withIdentifier: "JsonViewController") as! JsonViewController
    }
    
    //MARK: - tool
    
    //确定格式(JSON/Form)
    func detectSerializer() {
        guard let content = detailModel?.content else {
            detailModel?.requestSerializer = RequestSerializer.JSON//默认JSON格式
            return
        }
        
        if let _ = content.stringToDictionary() {
            //JSON格式
            detailModel?.requestSerializer = RequestSerializer.JSON
        }else{
            //Form格式
            detailModel?.requestSerializer = RequestSerializer.form
            
                if let jsonString = detailModel?.content?.formStringToJsonString() {
                    textView.text = jsonString
                    detailModel?.requestSerializer = RequestSerializer.JSON
                    detailModel?.content = textView.text
                }
        }
    }
    
    
    //MARK: - init
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        navigationController?.hidesBarsOnSwipe = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.textContainer.lineFragmentPadding = 15
//        textView.textContainerInset = .zero
        
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
            textView.text = String(detailModel?.requestHeaderFields?.dictionaryToString()?.dropFirst().dropLast().dropFirst().dropLast().dropFirst().dropFirst() ?? "").replacingOccurrences(of: "\",\n  \"", with: "\",\n\"")
        }
        else if editType == .responseHeader
        {
            imageView.isHidden = true
            textView.isHidden = false
            textView.text = String(detailModel?.responseHeaderFields?.dictionaryToString()?.dropFirst().dropLast().dropFirst().dropLast().dropFirst().dropFirst() ?? "").replacingOccurrences(of: "\",\n  \"", with: "\",\n\"")
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
    
    
    //MARK: - override
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(selectAll(_:)) {
            UIAlertView.init(title: "", message: "", delegate: self, cancelButtonTitle: "Copy All", otherButtonTitles: "Cancel").show()
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func selectAll(_ sender: Any?) {
        textView.selectAll(sender)
    }
}


//MARK: - UIAlertViewDelegate
extension JsonViewController: UIAlertViewDelegate {
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 0 {
            UIPasteboard.general.string = textView.text
        }
    }
}
