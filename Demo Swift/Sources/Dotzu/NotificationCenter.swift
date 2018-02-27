//
//  NotificationCenter.swift
//  NotificationCenter
//
//  Created by Remi Robert on 19/09/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import Foundation

typealias NotificationObserverBlock =  ((Any?) -> Void)

protocol NotificationProtocol {
    var name: String {get}
}

extension NotificationProtocol {
    func post<A>(_ value: A?) {
        let center = NotificationCenter.default
        let name = NSNotification.Name(self.name)
        guard let value = value else {
            center.post(name: name, object: nil, userInfo: nil)
            return
        }
        let userInfo = ["value": value]
        center.post(name: name, object: nil, userInfo: userInfo)
    }
}

class NotificationObserver<A> {
    let observer: NSObjectProtocol

    required init(notification: NotificationProtocol, block aBlock: @escaping NotificationObserverBlock) {
        let center = NotificationCenter.default
        let name = NSNotification.Name(notification.name)
        observer = center.addObserver(forName: name, object: nil, queue: nil) { note in
            guard let value = note.userInfo?["value"] as? A else {
                aBlock(nil)
                return
            }
            aBlock(value)
        }
    }

    deinit {
        let center = NotificationCenter.default
        center.removeObserver(observer)
    }
}
