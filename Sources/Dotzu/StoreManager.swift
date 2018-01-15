//
//  LogManager.swift
//  exampleWindow
//
//  Created by Remi Robert on 17/01/2017.
//  Copyright © 2017 Remi Robert. All rights reserved.
//

import Foundation

class StoreManager {
    
    var logArray: [Log] = [Log]()
    var crashArray: [LogCrash] = [LogCrash]()

    static let shared = StoreManager()
    private init() {
        crashArray = self.getCrashs()
    }
    
    //MARK: - tool
    private func archiveCrashs(_ crashs: [LogCrash]) {
        let dataArchive = NSKeyedArchiver.archivedData(withRootObject: crashs)
        UserDefaults.standard.set(dataArchive, forKey: "crashArchive")
        UserDefaults.standard.set(crashs.count, forKey: "crashCount")
        UserDefaults.standard.synchronize()
    }
    
    private func getCrashs() -> [LogCrash] {
        guard let data = UserDefaults.standard.object(forKey: "crashArchive") as? Data else {return []}
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
        if self.logArray.count >= LogsSettings.shared.maxLogsCount {
            if self.logArray.count > 0 {
                self.logArray.remove(at: 0)
            }
        }
        self.logArray.append(log)
    }
    
    func resetLogs() {
        self.logArray.removeAll()
    }
    
    func removeLog(_ model: Log) {
        if let index = self.logArray.index(where: { (log) -> Bool in
            return log.id == model.id
        }) {
            self.logArray.remove(at: index)
        }
    }
    
    //MARK: - crash相关
    func addCrash(_ crash: LogCrash) {
        if self.crashArray.count >= LogsSettings.shared.maxLogsCount {
            if self.crashArray.count > 0 {
                self.crashArray.remove(at: 0)
            }
        }
        self.crashArray.append(crash)
        archiveCrashs(self.crashArray)
    }

    func resetCrashs() {
        self.crashArray.removeAll()
        UserDefaults.standard.removeObject(forKey: "crashArchive")
        UserDefaults.standard.removeObject(forKey: "crashCount")
        UserDefaults.standard.synchronize()
    }
    
    func removeCrash(_ model: LogCrash) {
        if let index = self.crashArray.index(where: { (crash) -> Bool in
            return crash.id == model.id
        }) {
            self.crashArray.remove(at: index)
        }
        archiveCrashs(self.crashArray)
    }
}
