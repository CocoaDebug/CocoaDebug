//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

import UIKit

class CocoaDebugViewController: UIViewController {
    
    var bubble = Bubble(frame: CGRect(origin: .zero, size: Bubble.size))
    var fpsBubble = FpsBubble(frame: CGRect(origin: .zero, size: FpsBubble.size))
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        bubble.updateOrientation(newSize: size)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear

        bubble.center = Bubble.originalPosition
        bubble.delegate = self
        view.addSubview(bubble)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        WindowHelper.shared.displayedList = false
        if CocoaDebugSettings.shared.enableFpsMonitoring {
            view.addSubview(fpsBubble)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if CocoaDebugSettings.shared.enableFpsMonitoring {
            fpsBubble.updateFrame()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if CocoaDebugSettings.shared.enableFpsMonitoring {
            fpsBubble.removeFromSuperview()
        }
    }
    
    func shouldReceive(point: CGPoint) -> Bool {
        if WindowHelper.shared.displayedList {
            return true
        }
        return bubble.frame.contains(point)
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
