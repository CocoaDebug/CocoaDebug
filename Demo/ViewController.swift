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
        
        //Alamofire
        Alamofire.request("http://httpbin.org/get").responseJSON { _ in
            print("111")
        }
        Alamofire.request("http://httpbin.org/post", method: .post, parameters: ["data": "Alamofire"], encoding: JSONEncoding.default).responseJSON { _ in
            print("111", .blue)
        }
        
        //SwiftHTTP
        HTTP.GET("http://httpbin.org/get") { _ in
            print("222")
        }
        HTTP.POST("http://httpbin.org/post", parameters: ["data": "SwiftHTTP"]) { _ in
            print("222", .yellow)
        }
        HTTP.GET("https://www.baidu.com/img/bd_logo1.png") { _ in
            print("pic", .red)
        }
        
        //Networking
        let networking = Networking(baseURL: "http://httpbin.org")
        networking.get("/get") { (_, _) in
            print("333")
        }
        networking.post("/post", parameters: ["data": "Networking"]) { (_, _) in
            print("333", .orange)
        }
    }
}

