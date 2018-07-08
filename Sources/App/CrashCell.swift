//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import UIKit

class CrashCell: UITableViewCell {

    @IBOutlet weak var textview: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        textview.isUserInteractionEnabled = false
    }

    var crash: CrashModel? {
        didSet {
            guard let crash = crash else {return}
            let formatDate = LoggerFormat.formatDate(date: crash.date)
            let content = "\("\(formatDate)\n")\(crash.name ?? "unknown crash")"
            
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
