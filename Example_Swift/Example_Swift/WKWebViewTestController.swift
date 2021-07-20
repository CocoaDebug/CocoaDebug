//
//  WKWebViewTestController.swift
//  Example_Swift
//
//  Created by man 5/18/19.
//  Copyright © 2019 man. All rights reserved.
//

import UIKit
import WebKit

class WKWebViewTestController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView(frame: self.view.bounds)
        webView?.navigationDelegate = self;
        self.view.addSubview(webView!)
        webView?.load(URLRequest(urlString: "https://m.baidu.com/")!)
        
        
        //log
//        do{
//            let str = try String.init(contentsOfFile: Bundle.main.path(forResource: "index", ofType: "html") ?? "")
//            webView?.loadHTMLString(str, baseURL: Bundle.main.bundleURL)
//        }catch{}
    }
    
    
    
    //MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, cred)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
}
