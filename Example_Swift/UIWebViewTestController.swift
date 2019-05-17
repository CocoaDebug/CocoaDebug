//
//  UIWebViewTestController.swift
//  Example_Swift
//
//  Created by man on 5/18/19.
//  Copyright © 2019 liman. All rights reserved.
//

import UIKit

class UIWebViewTestController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let webView = UIWebView.init(frame: self.view.bounds)
        self.view.addSubview(webView)
        webView.loadRequest(URLRequest(urlString: "https://m.baidu.com/")!)
        
        
//        do{
//            let str = try String.init(contentsOfFile: Bundle.main.path(forResource: "index2", ofType: "html") ?? "")
//            webView.loadHTMLString(str, baseURL: Bundle.main.bundleURL)
//        }catch{}
    }
}
