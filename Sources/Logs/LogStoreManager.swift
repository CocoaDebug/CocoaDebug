//
//  DebugTool.swift
//  demo
//
//  Created by liman on 26/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation

class LogStoreManager {
    
    var defaultLogArray: [LogModel] = [LogModel]()
    var colorLogArray: [LogModel] = [LogModel]()
    
    static let shared = LogStoreManager()
    private init() {}
    
    //MARK: - public
    func addLog(_ log: LogModel) {
        if log.color == .white || log.color == nil
        {   //白色
            if self.defaultLogArray.count >= 1000/2 {
                if self.defaultLogArray.count > 0 {
                    self.defaultLogArray.remove(at: 0)
                }
            }
            self.defaultLogArray.append(log)
        }
        else ///////////////////////////////
        {   //彩色
            if self.colorLogArray.count >= 1000/2 {
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
