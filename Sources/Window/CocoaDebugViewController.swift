//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

import UIKit

class CocoaDebugViewController: UIViewController {

    var bubble = Bubble(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: Bubble.size))

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.addSubview(self.bubble)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.bubble.updateOrientation(newSize: size)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bubble.center = Bubble.originalPosition
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

//MARK: - BubbleDelegate
extension CocoaDebugViewController: BubbleDelegate {
    
    func didTapBubble() {
        WindowHelper.shared.displayedList = true
        let storyboard = UIStoryboard(name: "Manager", bundle: Bundle(for: CocoaDebug.self))
        guard let vc = storyboard.instantiateInitialViewController() else {return}
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}
