//
//  LogManager.swift
//  exampleWindow
//
//  Created by Remi Robert on 17/01/2017.
//  Copyright © 2017 Remi Robert. All rights reserved.
//

import Foundation

class StoreManager {
    
    var defaultLogArray: [Log] = [Log]()
    var colorLogArray: [Log] = [Log]()
    var crashArray: [LogCrash] = [LogCrash]()

    static let shared = StoreManager()
    private init() {
        crashArray = self.getCrashs()
    }
    
    //MARK: - tool
    private func archiveCrashs(_ crashs: [LogCrash]) {
        let dataArchive = NSKeyedArchiver.archivedData(withRootObject: crashs)
        UserDefaults.standard.set(dataArchive, forKey: "crashArchive_debugman")
        UserDefaults.standard.set(crashs.count, forKey: "crashCount_debugman")
        UserDefaults.standard.synchronize()
    }
    
    private func getCrashs() -> [LogCrash] {
        guard let data = UserDefaults.standard.object(forKey: "crashArchive_debugman") as? Data else {return []}
        do {
            if #available(iOS 9.0, *) {
                let dataArchive = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
                return dataArchive as! [LogCrash]
            } else {
                // Fallback on earlier versions
                return []
            }
        } catch {
            return []
        }
    }
    
    //MARK: - log相关
    func addLog(_ log: Log) {
        if log.color == .white || log.color == nil
        {   //白色
            if self.defaultLogArray.count >= 10000 {
                if self.defaultLogArray.count > 0 {
                    self.defaultLogArray.remove(at: 0)
                }
            }
            self.defaultLogArray.append(log)
        }
        else ///////////////////////////////
        {   //彩色
            if self.colorLogArray.count >= 10000 {
                if self.colorLogArray.count > 0 {
                    self.colorLogArray.remove(at: 0)
                }
            }
            self.colorLogArray.append(log)
        }
    }
    
    func removeLog(_ model: Log) {
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
    
    //MARK: - crash相关
    func addCrash(_ crash: LogCrash) {
        if self.crashArray.count >= 10000 {
            if self.crashArray.count > 0 {
                self.crashArray.remove(at: 0)
            }
        }
        self.crashArray.append(crash)
        archiveCrashs(self.crashArray)
    }
    
    func removeCrash(_ model: LogCrash) {
        if let index = self.crashArray.index(where: { (crash) -> Bool in
            return crash.id == model.id
        }) {
            self.crashArray.remove(at: index)
        }
        archiveCrashs(self.crashArray)
    }
    
    func resetCrashs() {
        self.crashArray.removeAll()
        UserDefaults.standard.removeObject(forKey: "crashArchive_debugman")
        UserDefaults.standard.removeObject(forKey: "crashCount_debugman")
        UserDefaults.standard.synchronize()
    }
}
