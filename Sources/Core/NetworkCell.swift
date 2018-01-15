//
//  NetworkCell.swift
//  PhiSpeaker
//
//  Created by liman on 25/11/2017.
//  Copyright © 2017 Phicomm. All rights reserved.
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
    
    /*
     @interface JxbHttpModel : NSObject
     @property (nonatomic,copy)NSString  *requestId;
     @property (nonatomic,copy)NSURL     *url;
     @property (nonatomic,copy)NSString  *method;
     @property (nonatomic,copy)NSString  *requestBody;
     @property (nonatomic,copy)NSString  *statusCode;
     @property (nonatomic,copy)NSData    *responseData;
     @property (nonatomic,assign)BOOL    isImage;
     @property (nonatomic,copy)NSString  *mineType;
     @property (nonatomic,copy)NSString  *startTime;
     @property (nonatomic,copy)NSString  *totalDuration;
     
     @property (nonatomic,copy)NSString  *localizedErrorMsg;
     @property (nonatomic,copy)NSDictionary *headerFields;
     */
    var httpModel: JxbHttpModel? {
        didSet {
            
            guard let serverURL = LogsSettings.shared.serverURL else {return}
            
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
                self.contentView.backgroundColor = UIColor.init(hexString: "#007aff")
            }else{
                self.contentView.backgroundColor = UIColor.black
            }
            
            //isSelected
            if httpModel?.isSelected == true {
                statusCodeView.backgroundColor = UIColor.init(hexString: "#222222")
            }else{
                statusCodeView.backgroundColor = UIColor.init(hexString: "#333333")
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
