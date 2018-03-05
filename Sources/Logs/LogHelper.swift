//
//  DebugTool.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation

public class LogHelper: NSObject {
    
    static let shared = LogHelper()
    private override init() {}
    
    fileprivate func parseFileInfo(file: String?, function: String?, line: Int?) -> String? {
        guard let file = file, let function = function, let line = line, let fileName = file.components(separatedBy: "/").last else {return nil}
        return "\(fileName)[\(line)]\(function)\n"
    }

    func handleLog(file: String?, function: String?, line: Int?, message: Any..., color: UIColor?) {
        //1.
        let fileInfo = parseFileInfo(file: file, function: function, line: line)
        let stringContent = message.reduce("") { result, next -> String in
            return "\(result)\(result.count > 0 ? " " : "")\(next)"
        }
        
        //2.
        let newLog = LogModel(content: stringContent, color: color, fileInfo: fileInfo)
        LogStoreManager.shared.addLog(newLog)
        
        dispatch_main_async_safe {
            NotificationCenter.default.post(name: NSNotification.Name("refreshLogs_DebugTool"), object: nil, userInfo: nil)
        }
    }
}
