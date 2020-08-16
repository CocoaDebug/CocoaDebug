//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

import UIKit

class CrashCell: UITableViewCell {

    @IBOutlet weak var textview: CustomTextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        textview.isUserInteractionEnabled = false
    }

    var crash: _CrashModel? {
        didSet {
            guard let crash = crash else {return}
            
            if let formatDate = _OCLoggerFormat.formatDate(crash.date) {
                let content = "\("\(String(describing: formatDate))\n")\(crash.name ?? "unknown crash")"
                
                textview.text = content
                let attstr = NSMutableAttributedString(string: content)
                
                attstr.addAttribute(.foregroundColor,
                                    value: UIColor.white, range: NSMakeRange(0, content.count))
                
                let range = NSMakeRange(0, formatDate.count)
                attstr.addAttribute(.foregroundColor, value: Color.mainGreen, range: range)
                attstr.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 12), range: range)
                
                textview.attributedText = attstr
            }
        }
    }
}
