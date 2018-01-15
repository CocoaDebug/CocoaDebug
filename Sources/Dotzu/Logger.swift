//
//  LogPrint.swift
//  exampleWindow
//
//  Created by Remi Robert on 17/01/2017.
//  Copyright © 2017 Remi Robert. All rights reserved.
//

import Foundation

//MARK: - ****************** Usage of DebugManLog ******************

/// file: logs file (打印日志所在的文件名) |
/// function: logs function (打印日志所在的函数名) |
/// line: logs line (打印日志所在的行数) |
/// message: logs content (打印日志的内容) |
/// color: logs color, default is white (打印日志的颜色, 默认白色) |
public func DebugManLog<T>(_ file: String = #file,
                           _ function: String = #function,
                           _ line: Int = #line,
                           _ message: T,
                           _ color: UIColor? = nil)
{
    if Logger.shared.enable {
        Logger.shared.handleLog(file: file, function: function, line: line, message: message, color: color)
    } else {
        Swift.print(message)
    }
}

//MARK: -
public class Logger: LogGenerator {
    
    static let shared = Logger()
    private let queue = DispatchQueue(label: "logprint.log.queue")

    var enable: Bool = true

    fileprivate func parseFileInfo(file: String?, function: String?, line: Int?) -> String? {
        guard let file = file, let function = function, let line = line else {return nil}
        guard let fileName = file.components(separatedBy: "/").last else { return nil }
        
        
        return "\(fileName)[\(line)]\(function):\n"
    }

    fileprivate func handleLog(file: String?, function: String?, line: Int?, message: Any..., color: UIColor?) {
        if !Logger.shared.enable {
            return
        }
        let fileInfo = parseFileInfo(file: file, function: function, line: line)
        let stringContent = message.reduce("") { result, next -> String in
            return "\(result)\(result.count > 0 ? " " : "")\(next)"
        }

        Logger.shared.queue.async {
            let newLog = Log(content: stringContent, color: color, fileInfo: fileInfo)
            let format = LoggerFormat.format(newLog)
            Swift.print(format.str)
            StoreManager.shared.addLog(newLog)
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            NotificationCenter.default.post(name: NSNotification.Name("refreshLogs"), object: nil, userInfo: nil)
        }
    }
}
