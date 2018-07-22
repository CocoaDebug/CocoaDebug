//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import Foundation
import UIKit

class NetworkCell: UITableViewCell {
    
    lazy var formatter: DateFormatter = DateFormatter()
    
    @IBOutlet weak var leftAlignLine: UIView!
    @IBOutlet weak var statusCodeLabel: UILabel!
    @IBOutlet weak var methodLabel: UILabel!
    @IBOutlet weak var requestTimeTextView: UITextView!
    @IBOutlet weak var requestUrlTextView: UITextView!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var statusCodeView: UIView!

    
    var httpModel: HttpModel? {
        didSet {
            
            guard let serverURL = CocoaDebugSettings.shared.serverURL else {return}
            
            //域名
            requestUrlTextView.text = httpModel?.url.absoluteString
            if requestUrlTextView.text?.contains(serverURL) == true {
                if #available(iOS 8.2, *) {
                    requestUrlTextView.font = UIFont.systemFont(ofSize: 13, weight: .heavy)
                } else {
                    // Fallback on earlier versions
                    requestUrlTextView.font = UIFont.boldSystemFont(ofSize: 13)
                }
            }else{
                if #available(iOS 8.2, *) {
                    requestUrlTextView.font = UIFont.systemFont(ofSize: 13, weight: .regular)
                } else {
                    // Fallback on earlier versions
                    requestUrlTextView.font = UIFont.systemFont(ofSize: 13)
                }
            }
            
            //请求方式
            if let method = httpModel?.method {
                methodLabel.text = "[" + method + "]"
            }
            
            //请求时间
            if let startTime = httpModel?.startTime {
                if (startTime as NSString).doubleValue == 0 {
                    requestTimeTextView.text = formatter.string(from: Date())
                }else{
                    requestTimeTextView.text = formatter.string(from: NSDate(timeIntervalSince1970: (startTime as NSString).doubleValue) as Date)
                }
            }
            
            //https://httpstatuses.com/
            let successStatusCodes = ["200","201","202","203","204","205","206","207","208","226"]
            
            //状态码
            statusCodeLabel.text = httpModel?.statusCode
            if successStatusCodes.contains(statusCodeLabel.text ?? "") {
                statusCodeLabel.textColor = "#42d459".hexColor
            }else{
                statusCodeLabel.textColor = "#ff0000".hexColor
            }
            if statusCodeLabel.text == "0" { //"0" means network unavailable
                statusCodeLabel.text = "❌"
            }
            
            //是否显示图片label
            if httpModel?.isImage == true {
                imageLabel.isHidden = false
            }else{
                imageLabel.isHidden = true
            }
            
            //tag
            if httpModel?.isTag == true {
                self.contentView.backgroundColor = "#007aff".hexColor
            }else{
                self.contentView.backgroundColor = .black
            }
            
            //isSelected
            if httpModel?.isSelected == true {
                statusCodeView.backgroundColor = "#222222".hexColor
            }else{
                statusCodeView.backgroundColor = "#333333".hexColor
            }
        }
    }
    
    //MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageLabel.backgroundColor = Color.mainGreen
        requestTimeTextView.textColor = Color.mainGreen
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        requestTimeTextView.textContainer.lineFragmentPadding = 0
        requestTimeTextView.textContainerInset = .zero
        requestTimeTextView.isSelectable = false
        
        requestUrlTextView.textContainer.lineFragmentPadding = 0
        requestUrlTextView.textContainerInset = .zero
        requestUrlTextView.isSelectable = true
    }
}
