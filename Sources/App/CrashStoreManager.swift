//
//  Example
//  man
//
//  Created by man on 11/11/2018.
//  Copyright © 2018 man. All rights reserved.
//

import Foundation

class CrashStoreManager {
    
    lazy var crashArray: [CrashModel] = [CrashModel]()
    
    static let shared = CrashStoreManager()
    private init() {
        crashArray = self.getCrashs()
    }
    
    //MARK: - public
    func addCrash(_ crash: CrashModel) {
        if self.crashArray.count >= CocoaDebugSettings.shared.logMaxCount {
            if self.crashArray.count > 0 {
                self.crashArray.remove(at: 0)
            }
        }
        self.crashArray.append(crash)
        archiveCrashs(self.crashArray)
    }
    
    func removeCrash(_ model: CrashModel) {
        if let index = self.crashArray.index(where: { (crash) -> Bool in
            return crash.id == model.id
        }) {
            self.crashArray.remove(at: index)
        }
        archiveCrashs(self.crashArray)
    }
    
    func resetCrashs() {
        self.crashArray.removeAll()
        UserDefaults.standard.removeObject(forKey: "crashArchive_CocoaDebug")
        UserDefaults.standard.removeObject(forKey: "crashCount_CocoaDebug")
        UserDefaults.standard.synchronize()
    }
    
    //MARK: - private
    private func archiveCrashs(_ crashs: [CrashModel]) {
        let dataArchive = NSKeyedArchiver.archivedData(withRootObject: crashs)
        UserDefaults.standard.set(dataArchive, forKey: "crashArchive_CocoaDebug")
        UserDefaults.standard.set(crashs.count, forKey: "crashCount_CocoaDebug")
        UserDefaults.standard.synchronize()
    }
    
    private func getCrashs() -> [CrashModel] {
        guard let data = UserDefaults.standard.object(forKey: "crashArchive_CocoaDebug") as? Data else {return []}
        do {
            if #available(iOS 9.0, *) {
                let dataArchive = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
                return dataArchive as! [CrashModel]
            } else {
                // Fallback on earlier versions
                return []
            }
        } catch {
            return []
        }
    }
}
