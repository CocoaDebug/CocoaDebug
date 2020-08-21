//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

import Foundation

class CrashStoreManager {
    
    var crashArray: [_CrashModel] = [_CrashModel]()
    
    static let shared = CrashStoreManager()
    private init() {
        crashArray = self.getCrashs()
    }
    
    //MARK: - public
    func addCrash(_ crash: _CrashModel) {
        if self.crashArray.count >= CocoaDebugSettings.shared.logMaxCount {
            if self.crashArray.count > 0 {
                self.crashArray.remove(at: 0)
            }
        }
        self.crashArray.append(crash)
        archiveCrashs(self.crashArray)
    }
    
    func removeCrash(_ model: _CrashModel) {
        if let index = self.crashArray.firstIndex(where: { (crash) -> Bool in
            return crash.id == model.id
        }) {
            self.crashArray.remove(at: index)
        }
        archiveCrashs(self.crashArray)
    }
    
    func resetCrashs() {
        if self.crashArray.count > 0 {
            self.crashArray.removeAll()
            UserDefaults.standard.removeObject(forKey: "crashArchive_CocoaDebug")
            UserDefaults.standard.removeObject(forKey: "crashCount_CocoaDebug")
            UserDefaults.standard.synchronize()
        }
    }
    
    //MARK: - private
    private func archiveCrashs(_ crashs: [_CrashModel]) {
        do {
            var dataArchive: Data
            if #available(iOS 11.0, *) {
                dataArchive = try NSKeyedArchiver.archivedData(withRootObject: crashs, requiringSecureCoding: false)
            } else {
                // Fallback on earlier versions
                dataArchive = NSKeyedArchiver.archivedData(withRootObject: crashs)
            }
            UserDefaults.standard.set(dataArchive, forKey: "crashArchive_CocoaDebug")
            UserDefaults.standard.set(crashs.count, forKey: "crashCount_CocoaDebug")
            UserDefaults.standard.synchronize()
        } catch {}
    }
    
    private func getCrashs() -> [_CrashModel] {
        guard let data = UserDefaults.standard.object(forKey: "crashArchive_CocoaDebug") as? Data else {return []}
        do {
            if #available(iOS 9.0, *) {
                let dataArchive = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
                return dataArchive as! [_CrashModel]
            } else {
                // Fallback on earlier versions
                return []
            }
        } catch {
            return []
        }
    }
}
