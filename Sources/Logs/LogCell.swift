//
//  DebugTool.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class LogCell: UITableViewCell {

    @IBOutlet weak var labelContent: UITextView!
    @IBOutlet weak var viewTypeLogColor: UIView!
    
    var model: LogModel? {
        didSet {
            guard let model = model else { return }
            
            labelContent.text = nil
            let format = LoggerFormat.format(model)
            labelContent.text = format.str
            labelContent.attributedText = format.attr
            
            //tag
            if model.isTag == true {
                self.contentView.backgroundColor = .init(hexString: "#007aff")
            }else{
                self.contentView.backgroundColor = .black
            }
        }
    }
}
