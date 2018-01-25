//
//  ViewController.swift
//  DebugMan
//
//  Created by liman on 13/12/2017.
//  Copyright © 2017 liman. All rights reserved.
//

import UIKit
import Alamofire
import SwiftHTTP
import Networking

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - test log:
        print("print white")
        print("print red", .red)
        
        NSLog("NSLog white")
        NSLog("NSLog red", .red)
        
        
        //MARK: - test network:
        //Alamofire
        Alamofire.request("http://httpbin.org/get").responseJSON { _ in
        }
        Alamofire.request("http://httpbin.org/post", method: .post, parameters: ["data": "Alamofire"], encoding: JSONEncoding.default).responseJSON { _ in
        }
        
        //SwiftHTTP
        HTTP.GET("http://httpbin.org/get") { _ in
        }
        HTTP.POST("http://httpbin.org/post", parameters: ["data": "SwiftHTTP"]) { _ in
        }
        HTTP.GET("https://www.baidu.com/img/bd_logo1.png") { _ in
        }
        
        //Networking
        let networking = Networking(baseURL: "http://httpbin.org")
        networking.get("/get") { (_, _) in
        }
        networking.post("/post", parameters: ["data": "Networking"]) { (_, _) in
        }
    }
}

