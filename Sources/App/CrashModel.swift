//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import UIKit

class CrashModel: NSObject, NSCoding {
    
    let id: String
    var date: Date
    var reason: String?
    var name: String?
    var callStacks: [String]?
    
    
    init(name: String, reason: String?) {
        id = UUID().uuidString
        date = Date()
        self.reason = reason
        self.name = name
        callStacks = Thread.callStackSymbols
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(reason, forKey: "reason")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(callStacks, forKey: "callstacks")
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as? String ?? ""
        date = aDecoder.decodeObject(forKey: "date") as? Date ?? Date()
        reason = aDecoder.decodeObject(forKey: "reason") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        callStacks = aDecoder.decodeObject(forKey: "callstacks") as? [String]
    }
    
    func toString() -> String {
        let stringContent = NSMutableString()
        stringContent.append("Date: \(LoggerFormat.formatDate(date: date))\n")
        stringContent.append("Name:   \(name ?? "N/A")\n")
        stringContent.append("Reason: \(reason ?? "N/A")\n")
        
        let stacks = (callStacks ?? []).reduce("", {
            return "\($0)\($1)\n"
        })
        stringContent.append(stacks)
        return stringContent as String
    }
}

