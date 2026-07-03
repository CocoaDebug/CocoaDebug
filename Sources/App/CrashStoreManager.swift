//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
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
        if self.crashArray.count >= 1000 {
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
        }
    }
    
    //MARK: - private
    private func archiveCrashs(_ crashs: [_CrashModel]) {
        do {
            let dataArchive = try NSKeyedArchiver.archivedData(withRootObject: crashs, requiringSecureCoding: true)
            UserDefaults.standard.set(dataArchive, forKey: "crashArchive_CocoaDebug")
            UserDefaults.standard.set(crashs.count, forKey: "crashCount_CocoaDebug")
        } catch {}
    }
    
    private func getCrashs() -> [_CrashModel] {
        guard let data = UserDefaults.standard.object(forKey: "crashArchive_CocoaDebug") as? Data else {return []}
        do {
            let dataArchive = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, _CrashModel.self], from: data)
            return (dataArchive as? [_CrashModel]) ?? []
        } catch {
            return []
        }
    }
}
