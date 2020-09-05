//
//  ViewController.swift
//  Example_Swift
//
//  Created by man on 8/11/20.
//  Copyright © 2020 man. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Example"
    }

    @IBAction func loadRequests(_ sender: Any) {
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
        let formData = Data(String(repeating: "Cocoadebug is the greatest tool", count: 100).utf8)

        
        //1.Alamofire
        request("https://httpbin.org/get").responseJSON { response in
            print(response, color: .red)
        }
        request("https://httpbin.org/post", method: .post, parameters: ["data": "Alamofire"], encoding: JSONEncoding.default).responseJSON { response in
            print(response, color: .red)
        }

        upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(formData, withName: "formData")
        }, usingThreshold: 0, to: "https://httpbin.org/post") { (result) in
            switch result {
            case .success(request: let uploadRequest, streamingFromDisk: _, streamFileURL: _):
                uploadRequest.uploadProgress { (progress) in
                    print("Alamofire upload progress: \(progress.fractionCompleted)")
                }.response { (response) in
                    print("Alamofire upload completed")
                }
            case .failure:
                print("Alamofire upload failure")
            }
        }
        download("https://httpbin.org/bytes/\(1024*1024)", method: .get, parameters: nil) { (url, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
            return (destinationURL: URL.init(fileURLWithPath: NSHomeDirectory() + "/Documents/AlamofireDownloadTest.data"), options: .createIntermediateDirectories)
        }.downloadProgress { (progress) in
            print("Alamofire download progress: \(progress.fractionCompleted)")
        }.responseData { (response: DownloadResponse<Data>) in
            print("Alamofire download completed")
        }
        
        //2.SwiftHTTP
        HTTP.GET("https://httpbin.org/get") { response in
            print(response.text, color: .red)
        }
        HTTP.POST("https://httpbin.org/post", parameters: ["data": "SwiftHTTP"]) { response in
            print(response.text, color: .red)
        }
        let uploadData = Upload(); uploadData.data = formData
        HTTP.POST("https://httpbin.org/post", parameters: ["data": uploadData]) { (response) in
            print("SwiftHTTP upload completed")
        }?.progress = { value in
            print("SwiftHTTP upload progress: \(value)")
        }
        HTTP.GET("https://www.baidu.com/img/bd_logo1.png") { response in
            print(response.description, color: .red)
        }
        HTTP.GET("https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png") { response in
            print(response.description, color: .red)
        }
        let downloadTask = HTTP.New("https://httpbin.org/bytes/\(1024*1024)", method: .GET) { (response) in
            print("SwiftHTTP download completed")
        }
        downloadTask?.downloadHandler = { (response, url) in
            // SwiftHTTP has an error that downloadHander cannot be called
            print("SwiftHTTP download location: \(url)")
        }
        downloadTask?.progress = { value in
            print("SwiftHTTP download progress: \(value)")
        }
        downloadTask?.run()
 
        

        //3.Networking
        Networking(baseURL: "https://httpbin.org").get("/get") { (response, error) in
            print(response)
        }
        Networking(baseURL: "https://httpbin.org").post("/post", parameters: ["data": "Networking"]) { (response, error) in
            print(response)
        }
        // Networking not support progress handler
        Networking(baseURL: "https://httpbin.org").post("/post", part: FormDataPart.init(type: .data, data: formData, parameterName: "formData")) { (response, error) in
            print("Networking upload completed")
        }
        // Networking not support progress handler
        Networking.init(baseURL: "https://httpbin.org").downloadData(for: "/bytes/\(1024*1024)") { (data, eror) in
            let url = URL.init(fileURLWithPath: NSHomeDirectory() + "/Documents/NetworkingDownloadTest.data")
            if let data = data {
                try? data.write(to: url)
                print("Networking download completed, location: \(url)")
            }
        }

        //4.ASIHTTPRequest
        // URLProtocol connot support CFNetwork
//        ASIHTTPRequestClient.shared().getJSON("https://httpbin.org/get", params: nil, successBlock: { (request, JSON) in
//            print(JSON)
//        }) { (request, error) in
//            print(error?.localizedDescription)
//        }
//        ASIHTTPRequestClient.shared().postJSON("https://httpbin.org/post", params: ["data": "ASIHTTPRequest"], successBlock: { (request, JSON) in
//            print(JSON)
//        }) { (request, error) in
//            print(error?.localizedDescription)
//        }
//        ASIHTTPRequestClient.shared().postForm("https://httpbin.org/post", params: ["data": "ASIHTTPRequest"], successBlock: { (request, JSON) in
//            print(JSON)
//        }) { (request, error) in
//            print(error?.localizedDescription)
//        }
//        ASIHTTPRequestClient.shared()?.uploadData("https://httpbin.org/post", fileData: formData, forKey: "formData", params: nil, progress: { (value) in
//            print("ASIHTTPRequestClient upload progress: \(value)" )
//        }, successBlock: { (request, resposne) in
//            print("ASIHTTPRequestClient upload completed")
//        }, failedBlock: { (request, error) in
//            print(error?.localizedDescription)
//        })
//        ASIHTTPRequestClient.shared()?.downloadFile("https://httpbin.org/bytes/\(1024*1024)",
//                                                    writeTo: NSHomeDirectory() + "/Documents/",
//                                                    fileName: "ASIHTTPRequestClientDownloadTest.data", progress: { (value) in
//                                                        print("ASIHTTPRequestClient download progress: \(value)" )
//                                                    }, successBlock: { (response) in
//                                                        print("Networking download completed, location: \(response ?? "")")
//                                                    }, failedBlock: { (error) in
//                                                        print(error?.localizedDescription)
//                                                    })

        //5.large response data
        HTTP.POST("http://api.ellabook.cn/rest/api/service", parameters: ["method": "ella.book.listAllPart"]) { response in
            print(response.text, color: .red)
        }
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

