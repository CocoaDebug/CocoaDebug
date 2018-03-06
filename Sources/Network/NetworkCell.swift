//
//  DotzuX.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import UIKit

class NetworkCell: UITableViewCell {
    
    var formatter: DateFormatter = DateFormatter()
    
    @IBOutlet weak var leftAlignLine: UIView!
    @IBOutlet weak var statusCodeLabel: UILabel!
    @IBOutlet weak var methodLabel: UILabel!
    @IBOutlet weak var requestTimeTextView: UITextView!
    @IBOutlet weak var requestUrlTextView: UITextView!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var statusCodeView: UIView!
    @IBOutlet weak var refreshImageView: UIImageView!
    
    
    var httpModel: HttpModel? {
        didSet {
            
            guard let serverURL = DotzuXSettings.shared.serverURL else {return}
            
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
            
            //状态码
            statusCodeLabel.text = httpModel?.statusCode
            if statusCodeLabel.text == "200" {
                statusCodeLabel.textColor = Color.mainGreen
            }else{
                statusCodeLabel.textColor = UIColor.init(hexString: "#ff0000")
            }
            if statusCodeLabel.text == "0" {
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
                self.contentView.backgroundColor = .init(hexString: "#007aff")
            }else{
                self.contentView.backgroundColor = .black
            }
            
            //isSelected
            if httpModel?.isSelected == true {
                statusCodeView.backgroundColor = .init(hexString: "#222222")
            }else{
                statusCodeView.backgroundColor = .init(hexString: "#333333")
            }
        }
    }
    
    //MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        requestUrlTextView.textContainer.lineFragmentPadding = 0
        requestUrlTextView.textContainerInset = .zero
        
        requestTimeTextView.textContainer.lineFragmentPadding = 0
        requestTimeTextView.textContainerInset = .zero
    }
}
