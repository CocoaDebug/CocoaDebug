//
//  ViewController.swift
//  DebugMan
//
//  Created by liman on 13/12/2017.
//  Copyright © 2017 liman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //log
        print("hello world")
        print("red color", .red)
        
        //network
        test()
    }
    
    //MARK - network
    func test()
    {
        //1.Alamofire
        request("http://httpbin.org/get").responseJSON { response in
            print(response, .green)
        }
        request("http://httpbin.org/post", method: .post, parameters: ["data": "Alamofire"], encoding: JSONEncoding.default).responseJSON { response in
            print(response, .red)
        }
        
        //2.SwiftHTTP
        HTTP.GET("http://httpbin.org/get") { response in
            print(response, .yellow)
        }
        HTTP.POST("http://httpbin.org/post", parameters: ["data": "SwiftHTTP"]) { response in
            print(response, .gray)
        }
        HTTP.GET("https://www.baidu.com/img/bd_logo1.png") { response in
            print(response, .orange)
        }
        
        //3.Networking
        Networking(baseURL: "http://httpbin.org").get("/get") { (response, error) in
            print(response)
        }
        Networking(baseURL: "http://httpbin.org").post("/post", parameters: ["data": "Networking"]) { (response, error) in
            print(response)
        }
        
        //4.ASIHTTPRequest
        ASIHTTPRequestClient.shared().getJSON("http://httpbin.org/get", params: nil, successBlock: { (request, JSON) in
            print(JSON)
        }) { (request, error) in
            print(error?.localizedDescription)
        }
        ASIHTTPRequestClient.shared().postJSON("http://httpbin.org/post", params: ["data": "ASIHTTPRequest"], successBlock: { (request, JSON) in
            print(JSON)
        }) { (request, error) in
            print(error?.localizedDescription)
        }
        ASIHTTPRequestClient.shared().postForm("http://httpbin.org/post", params: ["data": "ASIHTTPRequest"], successBlock: { (request, JSON) in
            print(JSON)
        }) { (request, error) in
            print(error?.localizedDescription)
        }
    }
}

