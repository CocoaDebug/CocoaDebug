//
//  ViewController.swift
//  Example_Swift
//
//  Created by man 8/11/20.
//  Copyright © 2020 man. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Detect UI Blocking
        Thread.sleep(forTimeInterval: 0.5)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Example"

        print("hello world")
        print("hello world red", color: .red)
        print("hello world blue", color: UIColor.blue)
        print("억 암 온 양 哈哈哈 とうかいとうさん")

        testHTTP()
        testRedirect()
    }

    deinit {

    }


    func testHTTP() {

        //1.Alamofire
        request("https://httpbin.org/get").responseJSON { response in
            print(response, color: .red)
        }
        request("https://httpbin.org/post", method: .post, parameters: ["data": "Alamofire"], encoding: JSONEncoding.default).responseJSON { response in
            print(response, color: .red)
        }

        //2.SwiftHTTP
        HTTP.GET("https://httpbin.org/get") { response in
            print(response.text, color: .red)
        }
        HTTP.POST("https://httpbin.org/post", parameters: ["data": "SwiftHTTP"]) { response in
            print(response.text, color: .red)
        }
        HTTP.GET("https://www.baidu.com/img/bd_logo1.png") { response in
            print(response.description, color: .red)
        }
        HTTP.GET("https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png") { response in
            print(response.description, color: .red)
        }

        //3.Networking
        Networking(baseURL: "https://httpbin.org").get("/get") { (response, error) in
            print(response)
        }
        Networking(baseURL: "https://httpbin.org").post("/post", parameters: ["data": "Networking"]) { (response, error) in
            print(response)
        }

        //4.ASIHTTPRequest
        ASIHTTPRequestClient.shared().getJSON("https://httpbin.org/get", params: nil, successBlock: { (request, JSON) in
            print(JSON)
        }) { (request, error) in
            print(error?.localizedDescription)
        }
        ASIHTTPRequestClient.shared().postJSON("https://httpbin.org/post", params: ["data": "ASIHTTPRequest"], successBlock: { (request, JSON) in
            print(JSON)
        }) { (request, error) in
            print(error?.localizedDescription)
        }
        ASIHTTPRequestClient.shared().postForm("https://httpbin.org/post", params: ["data": "ASIHTTPRequest"], successBlock: { (request, JSON) in
            print(JSON)
        }) { (request, error) in
            print(error?.localizedDescription)
        }

        //5.large response data
//        HTTP.POST("http://api.ellabook.cn/rest/api/service", parameters: ["method": "ella.book.listAllPart"]) { response in
//            print(response.text, color: .red)
//        }
    }


    func testRedirect() {
        RedirectRequester.getRedirectInfo(with: "http://apple.com") { result, response in
            print("Redirect \(result): \(response)")
        }
    }
}


fileprivate class RedirectRequester: NSObject, URLSessionTaskDelegate {

    private static var sharedInstance = RedirectRequester()
    private static var session: URLSession!

    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(nil)
    }

    class func getRedirectInfo(with url: String, completionHandler: @escaping (Bool, String) -> Void) -> Void {
        if self.session == nil {
            let config = URLSessionConfiguration.default
            self.session = URLSession(configuration: config, delegate: RedirectRequester.sharedInstance, delegateQueue: nil)
        }

        let request = URLRequest(url: URL(string: url)!, cachePolicy: .reloadIgnoringLocalCacheData)

        let task = self.session.dataTask(with: request) { data, response, error in
            if let error = error {
                completionHandler(false, error.localizedDescription)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if (300...302).contains(httpResponse.statusCode) {
                    completionHandler(true, httpResponse.allHeaderFields["Location"] as! String)
                    return
                }
            }

            completionHandler(false, "Redirect request failed")
        }
        task.resume()
    }
}

