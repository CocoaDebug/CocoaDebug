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
        DotzuManager.shared.displayedList = true
        let storyboard = UIStoryboard(name: "Manager", bundle: Bundle(for: ManagerViewController.self))
        guard let vc = storyboard.instantiateInitialViewController() else {return}
        self.present(vc, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        DotzuManager.shared.displayedList = false
    }

    func shouldReceive(point: CGPoint) -> Bool {
        //修复keyWindow上新增view的点击事件不执行
        if (UIApplication.shared.keyWindow?.subviews.count ?? 0) > 1 {
            return true
        }
        if DotzuManager.shared.displayedList {
            return true
        }
        return self.logHeadView.frame.contains(point)
    }
}
