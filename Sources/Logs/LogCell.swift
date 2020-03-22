//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

import UIKit

class LogCell: UITableViewCell {

    @IBOutlet weak var labelContent: UITextView!
    @IBOutlet weak var viewTypeLogColor: UIView!
    
    var showCellAlert:(() -> Void)?

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
            }else{
                self.contentView.backgroundColor = .black
            }
        }
    }
    
    
    //MARK: - override
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(selectAll(_:)) {
            if let showCellAlert = showCellAlert {
                showCellAlert()
            }
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func selectAll(_ sender: Any?) {
        labelContent.selectAll(sender)
    }
}
