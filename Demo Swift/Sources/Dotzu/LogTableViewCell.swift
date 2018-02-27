//
//  LogTableViewCell.swift
//  exampleWindow
//
//  Created by Remi Robert on 06/12/2016.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit

class LogTableViewCell: UITableViewCell {

    @IBOutlet weak var labelContent: UITextView!
    @IBOutlet weak var viewTypeLogColor: UIView!
    
    var model: Log? {
        didSet {
            guard let model = model else { return }
            
            labelContent.text = nil
            let format = LoggerFormat.format(model)
            labelContent.text = format.str
            labelContent.attributedText = format.attr
            
            //tag
            if model.isTag == true {
                self.contentView.backgroundColor = UIColor.init(hexString: "#007aff")
            }else{
                self.contentView.backgroundColor = UIColor.black
            }
        }
    }
}
