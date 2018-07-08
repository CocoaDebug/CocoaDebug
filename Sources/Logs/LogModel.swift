//
//  CocoaDebug.swift
//  demo
//
//  Created by CocoaDebug on 26/11/2017.
//  Copyright © 2018 CocoaDebug. All rights reserved.
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

