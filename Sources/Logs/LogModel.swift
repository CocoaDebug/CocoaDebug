//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import UIKit

class LogModel {
    
    let id: String
    let fileInfo: String?
    let content: String
    let date: Date?
    let color: UIColor?
    
    var isTag: Bool = false
    
    var str: String?
    var attr: NSMutableAttributedString?
    
    
    
    init(content: String, color: UIColor?, fileInfo: String? = nil, isTag: Bool = false) {
        self.id = NSUUID().uuidString
        self.fileInfo = fileInfo
        self.content = content
        self.date = Date()
        self.color = color
        self.isTag = isTag
        
        /////////////////////////////////////////////////////////////////////////
        
        var startIndex = 0
        var lenghtDate: Int?
        let stringContent = NSMutableString()
        
        
        if let date = self.date {
            stringContent.append("[\(LoggerFormat.formatDate(date: date))] ")
            lenghtDate = stringContent.length
            startIndex = stringContent.length
        }
        if let fileInfoString = self.fileInfo {
            stringContent.append("\(fileInfoString)\(self.content)")
        } else {
            stringContent.append("\(self.content)")
        }
        
        let attstr = NSMutableAttributedString(string: stringContent as String)
        attstr.addAttribute(NSAttributedStringKey.foregroundColor,
                            value: self.color ?? .white,
                            range: NSMakeRange(0, stringContent.length))
        if let dateLenght = lenghtDate {
            let range = NSMakeRange(0, dateLenght)
            attstr.addAttribute(NSAttributedStringKey.foregroundColor, value: Color.mainGreen, range: range)
            attstr.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 12), range: range)
        }
        if let fileInfoString = self.fileInfo {
            let range = NSMakeRange(startIndex, fileInfoString.count)
            attstr.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.gray, range: range)
            attstr.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 12), range: range)
        }
        
        
        self.str = stringContent as String
        self.attr = attstr
    }
}


