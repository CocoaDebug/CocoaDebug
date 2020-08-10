//
//  ViewController.swift
//  Example_Test
//
//  Created by man on 8/10/20.
//  Copyright © 2020 man. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBAction func click(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        UIView.animate(withDuration: 0.3) {
            if sender.isSelected == true {
                sender.center = CGPoint(x: 200, y: 400)
            } else {
                sender.center = CGPoint(x: 100, y: 100)
            }
        }
    }
}

