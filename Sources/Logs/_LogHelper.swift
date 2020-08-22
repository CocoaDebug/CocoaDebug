//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

import Foundation

public class _LogHelper: NSObject {
    
    var enable: Bool = true
    
    @objc public static let shared = _LogHelper()
    private override init() {}
    
    
    fileprivate func parseFileInfo(file: String?, function: String?, line: Int?) -> String? {
        guard let file = file, let function = function, let line = line, let fileName = file.components(separatedBy: "/").last else {return nil}
        return "\(fileName)[\(line)]\(function)\n"
    }

    
    public func handleLog(file: String?, function: String?, line: Int?, message: Any..., color: UIColor?) {
        let stringContent = message.reduce("") { result, next -> String in
            return "\(result)\(result.count > 0 ? " " : "")\(next)"
        }
        commonHandleLog(file: file, function: function, line: (line ?? 0), message: stringContent, color: color)
    }
    
    
    private func commonHandleLog(file: String?, function: String?, line: Int, message: String, color: UIColor?) {
        guard enable else {
            return
        }
        
        //1.
        let fileInfo = parseFileInfo(file: file, function: function, line: line)
        
        //2.
        if let newLog = _OCLogModel.init(content: message, color: color, fileInfo: fileInfo, isTag: false, type: .none) {
            _OCLogStoreManager.shared().addLog(newLog)
        }
        
        //3.
        NotificationCenter.default.post(name: NSNotification.Name("refreshLogs_CocoaDebug"), object: nil, userInfo: nil)
    }
}
