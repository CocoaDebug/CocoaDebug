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
    
    
    
    init(content: String, color: UIColor?, fileInfo: String? = nil, isTag: Bool = false) {
        self.id = NSUUID().uuidString
        self.fileInfo = fileInfo
        self.content = content
        self.date = Date()
        self.color = color
        self.isTag = isTag
    }
}

