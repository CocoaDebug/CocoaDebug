//
//  ManagerViewController.swift
//  exampleWindow
//
//  Created by Remi Robert on 02/12/2016.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit

class ManagerViewController: UIViewController, LogHeadViewDelegate {

    var logHeadView = LogHeadView(frame: CGRect(origin: LogHeadView.originalPosition, size: LogHeadView.size))

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.addSubview(self.logHeadView)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.logHeadView.updateOrientation(newSize: size)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logHeadView.delegate = self
        self.view.backgroundColor = UIColor.clear
    }

    func didTapLogHeadView() {
        Dotzu.sharedManager.displayedList = true
        let storyboard = UIStoryboard(name: "Manager", bundle: Bundle(for: ManagerViewController.self))
        guard let controller = storyboard.instantiateInitialViewController() else {return}
        self.present(controller, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        Dotzu.sharedManager.displayedList = false
    }

    func shouldReceive(point: CGPoint) -> Bool {
        if Dotzu.sharedManager.displayedList {
            return true
        }
        return self.logHeadView.frame.contains(point)
    }
}
