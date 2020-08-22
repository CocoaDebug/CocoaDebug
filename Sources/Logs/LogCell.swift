//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

import UIKit

class LogCell: UITableViewCell {

    @IBOutlet weak var labelContent: CustomTextView!
    @IBOutlet weak var viewTypeLogColor: UIView!
    
    var model: _OCLogModel? {
        didSet {
            guard let model = model else { return }
            
            labelContent.text = nil
            labelContent.text = model.str
            labelContent.attributedText = model.attr
            labelContent.textContainer.lineBreakMode = NSLineBreakMode.byCharWrapping
            
            //tag
            if model.isTag == true {
                self.contentView.backgroundColor = "#007aff".hexColor
            } else {
                self.contentView.backgroundColor = .black
            }
        }
    }
}


class CustomTextView : UITextView {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.inputView = UIView.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(selectAll) {
            if let range = selectedTextRange, range.start == beginningOfDocument, range.end == endOfDocument {
                return false
            }
            return !text.isEmpty
        }
        else if action == #selector(paste(_:)) {
            return false
        }
        else if action == #selector(cut(_:)) {
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
}
