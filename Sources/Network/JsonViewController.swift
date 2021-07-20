//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

enum EditType {
    case unknown
    case requestHeader
    case responseHeader
    case log
}

import Foundation
import UIKit

class JsonViewController: UIViewController {
    
    @IBOutlet weak var textView: CustomTextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var naviItem: UINavigationItem!
    
    var naviItemTitleLabel: UILabel?
    
    var editType: EditType  = .unknown
    var httpModel: _HttpModel?
    var detailModel: NetworkDetailModel?
    
    //Edited url
    var editedURLString: String?
    //Edited content
    var editedContent: String?
    
    //log
    var logTitleString: String?
    var logModels: [_OCLogModel]?
    var logModel: _OCLogModel?
    var justCancelCallback:(() -> Void)?
    
    static func instanceFromStoryBoard() -> JsonViewController {
        let storyboard = UIStoryboard(name: "Network", bundle: Bundle(for: CocoaDebug.self))
        return storyboard.instantiateViewController(withIdentifier: "JsonViewController") as! JsonViewController
    }
    
    //MARK: - tool
    
    //detect format (JSON/Form)
    func detectSerializer() {
        guard let content = detailModel?.content else {
            detailModel?.requestSerializer = RequestSerializer.JSON//default JSON format
            return
        }
        
        if let _ = content.stringToDictionary() {
            //JSON format
            detailModel?.requestSerializer = RequestSerializer.JSON
        } else {
            //Form format
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
        
        if let index = logModels?.firstIndex(where: { (model) -> Bool in
            return model.isSelected == true
        }) {
            logModels?[index].isSelected = false
        }
        
        logModel?.isSelected = true
        
        if let justCancelCallback = justCancelCallback {
            justCancelCallback()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviItemTitleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        naviItemTitleLabel?.textAlignment = .center
        naviItemTitleLabel?.textColor = Color.mainGreen
        naviItemTitleLabel?.font = .boldSystemFont(ofSize: 20)
        naviItemTitleLabel?.text = detailModel?.title
        naviItem.titleView = naviItemTitleLabel
        
        textView.textContainer.lineFragmentPadding = 15
        //        textView.textContainerInset = .zero
        
        //detect type (default type URL)
        if detailModel?.title == "REQUEST HEADER" {
            editType = .requestHeader
        }
        if detailModel?.title == "RESPONSE HEADER" {
            editType = .responseHeader
        }
        
        //setup UI
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
        else if editType == .log
        {
            imageView.isHidden = true
            textView.isHidden = false
            naviItemTitleLabel?.text = logTitleString
            
            if let data = logModel?.contentData {
                textView.text = data.dataToString()
            }
        }
        else
        {
            if let content = detailModel?.content {
                imageView.isHidden = true
                textView.isHidden = false
                textView.text = content
                detectSerializer()//detect format (JSON/Form)
            }
            if let image = detailModel?.image {
                textView.isHidden = true
                imageView.isHidden = false
                imageView.image = image
            }
        }
    }
}
