//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

import UIKit

class _CrashModel: NSObject, NSSecureCoding {
    
    var id: String
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
    
    static var supportsSecureCoding: Bool { return true }

    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(of: NSString.self, forKey: "id") as String? ?? ""
        date = aDecoder.decodeObject(of: NSDate.self, forKey: "date") as Date? ?? Date()
        reason = aDecoder.decodeObject(of: NSString.self, forKey: "reason") as String?
        name = aDecoder.decodeObject(of: NSString.self, forKey: "name") as String?
        callStacks = aDecoder.decodeObject(of: [NSArray.self, NSString.self], forKey: "callstacks") as? [String]
    }
    
    func toString() -> String {
        let stringContent = NSMutableString()
        stringContent.append("Date: \(String(describing: _OCLoggerFormat.formatDate(date)))\n")
        stringContent.append("Name:   \(name ?? "N/A")\n")
        stringContent.append("Reason: \(reason ?? "N/A")\n")
        
        let stacks = (callStacks ?? []).reduce("", {
            return "\($0)\($1)\n"
        })
        stringContent.append(stacks)
        return stringContent as String
    }
}

