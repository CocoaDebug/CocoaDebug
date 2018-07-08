//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import Foundation

class LogStoreManager {
    
    lazy var defaultLogArray: [LogModel] = [LogModel]()
    lazy var colorLogArray: [LogModel] = [LogModel]()
    
    static let shared = LogStoreManager()
    private init() {}
    
    //MARK: - public
    func addLog(_ log: LogModel) {
        
        if log.color == .white || log.color == nil
        {   //白色
            if self.defaultLogArray.count >= CocoaDebugSettings.shared.logMaxCount {
                if self.defaultLogArray.count > 0 {
                    self.defaultLogArray.remove(at: 0)
                }
            }
            self.defaultLogArray.append(log)
        }
        else ///////////////////////////////
        {   //彩色
            if self.colorLogArray.count >= CocoaDebugSettings.shared.logMaxCount {
                if self.colorLogArray.count > 0 {
                    self.colorLogArray.remove(at: 0)
                }
            }
            self.colorLogArray.append(log)
        }
    }
    
    func removeLog(_ model: LogModel) {
        if model.color == .white || model.color == nil
        {   //白色
            if let index = self.defaultLogArray.index(where: { (log) -> Bool in
                return log.id == model.id
            }) {
                self.defaultLogArray.remove(at: index)
            }
        }
        else ///////////////////////////////
        {   //彩色
            if let index = self.colorLogArray.index(where: { (log) -> Bool in
                return log.id == model.id
            }) {
                self.colorLogArray.remove(at: index)
            }
        }
    }
    
    func resetDefaultLogs() {
        self.defaultLogArray.removeAll()
    }
    
    func resetColorLogs() {
        self.colorLogArray.removeAll()
    }
}
