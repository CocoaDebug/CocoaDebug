//
//  CrashListTableViewCell.swift
//  exampleWindow
//
//  Created by Remi Robert on 31/01/2017.
//  Copyright © 2017 Remi Robert. All rights reserved.
//

import UIKit

class CrashListTableViewCell: UITableViewCell {

    @IBOutlet weak var textview: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        textview.isUserInteractionEnabled = false
    }

    var crash: LogCrash? {
        didSet {
            guard let crash = crash else {return}
            let formatDate = LoggerFormat.formatDate(date: crash.date)
            let content = "\("\(formatDate)\n")\(crash.name ?? "Unknow crash")"
            
            textview.text = content
            let attstr = NSMutableAttributedString(string: content)
            
            attstr.addAttribute(NSAttributedStringKey.foregroundColor,
                                value: UIColor.white, range: NSMakeRange(0, content.count))
            
            let range = NSMakeRange(0, formatDate.count)
            attstr.addAttribute(NSAttributedStringKey.foregroundColor, value: Color.mainGreen, range: range)
            attstr.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 12), range: range)
            
            textview.attributedText = attstr
        }
    }
}
