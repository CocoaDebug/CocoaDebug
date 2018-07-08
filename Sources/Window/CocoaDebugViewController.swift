//
//  CocoaDebug.swift
//  demo
//
//  Created by CocoaDebug on 26/11/2017.
//  Copyright © 2018 CocoaDebug. All rights reserved.
//

import UIKit

class CocoaDebugViewController: UIViewController {

    var bubble = CocoaDebugBubble(frame: CGRect(origin: CocoaDebugBubble.originalPosition, size: CocoaDebugBubble.size))

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.addSubview(self.bubble)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.bubble.updateOrientation(newSize: size)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bubble.delegate = self
        self.view.backgroundColor = .clear
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        WindowHelper.shared.displayedList = false
    }

    func shouldReceive(point: CGPoint) -> Bool {
        if WindowHelper.shared.displayedList {
            return true
        }
        return self.bubble.frame.contains(point)
    }
}

//MARK: - CocoaDebugBubbleDelegate
extension CocoaDebugViewController: CocoaDebugBubbleDelegate {
    
    func didTapCocoaDebugBubble() {
        WindowHelper.shared.displayedList = true
        let storyboard = UIStoryboard(name: "Manager", bundle: Bundle(for: CocoaDebugViewController.self))
        guard let vc = storyboard.instantiateInitialViewController() else {return}
        self.present(vc, animated: true, completion: nil)
    }
}
