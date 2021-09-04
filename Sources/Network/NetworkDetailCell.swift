//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import Foundation
import UIKit

class NetworkDetailCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextView: CustomTextView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var middleLine: UIView!
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var editView: UIView!
    
    @IBOutlet weak var titleViewBottomSpaceToMiddleLine: NSLayoutConstraint!
    //-12.5
    
    
    var tapEditViewCallback:((NetworkDetailModel?) -> Void)?
    
    var detailModel: NetworkDetailModel? {
        didSet {
            
            titleLabel.text = detailModel?.title
            contentTextView.text = detailModel?.content
            
            //image
            if detailModel?.image == nil {
                imgView.isHidden = true
            } else {
                imgView.isHidden = false
                imgView.image = detailModel?.image
            }
            
            //Hide content automatically
            if detailModel?.blankContent == "..." {
                middleLine.isHidden = true
                imgView.isHidden = true
                titleViewBottomSpaceToMiddleLine.constant = -12.5 + 2
            } else {
                middleLine.isHidden = false
                if detailModel?.image != nil {
                    imgView.isHidden = false
                }
                titleViewBottomSpaceToMiddleLine.constant = 0
            }
            
            //Bottom dividing line
            if detailModel?.isLast == true {
                bottomLine.isHidden = false
            } else {
                bottomLine.isHidden = true
            }
        }
    }
    
    //MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
        
        editView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapEditView)))
        
        contentTextView.textContainer.lineFragmentPadding = 0
        contentTextView.textContainerInset = .zero
    }
    
    
    //MARK: - target action
    //edit
    @objc func tapEditView() {
        if let tapEditViewCallback = tapEditViewCallback {
            tapEditViewCallback(detailModel)
        }
    }
}
