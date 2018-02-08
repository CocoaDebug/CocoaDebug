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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //log
        print("hello world")
        print("red color", .red)
        
        //network monitor
        test()
    }
    
    //MARK - network monitor
    func test()
    {
        Alamofire.request("http://httpbin.org/get").responseJSON { response in
            print(response, .green)
        }
        Alamofire.request("http://httpbin.org/post", method: .post, parameters: ["data": "Alamofire"], encoding: JSONEncoding.default).responseJSON { response in
            print(response, .red)
        }
        HTTP.GET("http://httpbin.org/get") { response in
            print(response, .yellow)
        }
        HTTP.POST("http://httpbin.org/post", parameters: ["data": "SwiftHTTP"]) { response in
            print(response, .gray)
        }
        HTTP.GET("https://www.baidu.com/img/bd_logo1.png") { response in
            print(response, .orange)
        }
        Networking(baseURL: "http://httpbin.org").get("/get") { (response, error) in
            print(response)
        }
        Networking(baseURL: "http://httpbin.org").post("/post", parameters: ["data": "Networking"]) { (response, error) in
            print(response)
        }
    }
}

