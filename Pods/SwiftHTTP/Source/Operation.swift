//
//  Operation.swift
//  SwiftHTTP
//
//  Created by Dalton Cherry on 8/2/15.
//  Copyright © 2015 vluxe. All rights reserved.
//

import Foundation

enum HTTPOptError: Error {
    case invalidRequest
}

/**
This protocol exist to allow easy and customizable swapping of a serializing format within an class methods of HTTP.
*/
public protocol HTTPSerializeProtocol {
    
    /**
    implement this protocol to support serializing parameters to the proper HTTP body or URL
    -parameter request: The URLRequest object you will modify to add the parameters to
    -parameter parameters: The container (array or dictionary) to convert and append to the URL or Body
    */
    func serialize(_ request: inout URLRequest, parameters: HTTPParameterProtocol) -> Error?
}

/**
Standard HTTP encoding
*/
public struct HTTPParameterSerializer: HTTPSerializeProtocol {
    public init() { }
    public func serialize(_ request: inout URLRequest, parameters: HTTPParameterProtocol) -> Error? {
        return request.appendParameters(parameters)
    }
}

/**
Send the data as a JSON body
*/
public struct JSONParameterSerializer: HTTPSerializeProtocol {
    public init() { }
    public func serialize(_ request: inout URLRequest, parameters: HTTPParameterProtocol) -> Error? {
        return request.appendParametersAsJSON(parameters)
    }
}

/**
All the things of an HTTP response
*/
open class Response {
    /// The header values in HTTP response.
    open var headers: Dictionary<String,String>?
    /// The mime type of the HTTP response.
    open var mimeType: String?
    /// The suggested filename for a downloaded file.
    open var suggestedFilename: String?
    /// The body data of the HTTP response.
    open var data: Data {
        return collectData as Data
    }
    /// The status code of the HTTP response.
    open var statusCode: Int?
    /// The URL of the HTTP response.
    open var URL: Foundation.URL?
    /// The Error of the HTTP response (if there was one).
    open var error: Error?
    ///Returns the response as a string
    open var text: String? {
        return  String(data: data, encoding: .utf8)
    }
    ///get the description of the response
    open var description: String {
        var buffer = ""
        if let u = URL {
            buffer += "URL:\n\(u)\n\n"
        }
        if let code = self.statusCode {
            buffer += "Status Code:\n\(code)\n\n"
        }
        if let heads = headers {
            buffer += "Headers:\n"
            for (key, value) in heads {
                buffer += "\(key): \(value)\n"
            }
            buffer += "\n"
        }
        if let t = text {
            buffer += "Payload:\n\(t)\n"
        }
        return buffer
    }
    ///private things
    
    ///holds the collected data
    var collectData = NSMutableData()
    ///finish closure
    var completionHandler:((Response) -> Void)?
    
    //progress closure. Progress is between 0 and 1.
    var progressHandler:((Float) -> Void)?
    
    //download closure. the URL is the file URL where the temp file has been download. 
    //This closure will be called so you can move the file where you desire.
    var downloadHandler:((Response, URL) -> Void)?
    
    ///This gets called on auth challenges. If nil, default handling is use.
    ///Returning nil from this method will cause the request to be rejected and cancelled
    var auth:((URLAuthenticationChallenge) -> URLCredential?)?
    
    ///This is for doing SSL pinning
    var security: HTTPSecurity?
}

/**
The class that does the magic. Is a subclass of NSOperation so you can use it with operation queues or just a good ole HTTP request.
*/
open class HTTP {
    /**
    Get notified with a request finishes.
    */
    open var onFinish:((Response) -> Void)? {
        didSet {
            if let handler = onFinish {
                DelegateManager.sharedInstance.addTask(task, completionHandler: { (response: Response) in
                    handler(response)
                })
            }
        }
    }
    ///This is for handling authenication
    open var auth:((URLAuthenticationChallenge) -> URLCredential?)? {
        set {
            guard let resp = DelegateManager.sharedInstance.responseForTask(task) else { return }
            resp.auth = newValue
        }
        get {
            guard let resp = DelegateManager.sharedInstance.responseForTask(task) else { return nil }
            return resp.auth
        }
    }
    
    ///This is for doing SSL pinning
    open var security: HTTPSecurity? {
        set {
            guard let resp = DelegateManager.sharedInstance.responseForTask(task) else { return }
            resp.security = newValue
        }
        get {
            guard let resp = DelegateManager.sharedInstance.responseForTask(task) else { return nil }
            return resp.security
        }
    }
    
    ///This is for monitoring progress
    open var progress: ((Float) -> Void)? {
        set {
            guard let resp = DelegateManager.sharedInstance.responseForTask(task) else { return }
            resp.progressHandler = newValue
        }
        get {
            guard let resp = DelegateManager.sharedInstance.responseForTask(task) else { return nil }
            return resp.progressHandler
        }
    }
    
    ///This is for handling downloads
    open var downloadHandler: ((Response, URL) -> Void)? {
        set {
            guard let resp = DelegateManager.sharedInstance.responseForTask(task) else { return }
            resp.downloadHandler = newValue
        }
        get {
            guard let resp = DelegateManager.sharedInstance.responseForTask(task) else { return nil }
            return resp.downloadHandler
        }
    }
    
    ///the actual task
    var task: URLSessionTask!
	
    /**
    creates a new HTTP request.
    */
    public init(_ req: URLRequest, session: URLSession = SharedSession.defaultSession, isDownload: Bool = false) {
        if isDownload {
            task = session.downloadTask(with: req)
        } else {
            task = session.dataTask(with: req)
        }
        DelegateManager.sharedInstance.addResponseForTask(task)
    }
    
    /**
    start/sends the HTTP task with a completionHandler. Use this when *NOT* using an NSOperationQueue.
    */
    open func run(_ completionHandler: ((Response) -> Void)? = nil) {
        if let handler = completionHandler {
            onFinish = handler
        }
        task.resume()
    }
	
    /**
    Cancel the running task
    */
    open func cancel() {
        task.cancel()
    }

    /**
    Class method to run a GET request that handles the URLRequest and parameter encoding for you.
    */
    @discardableResult open class func GET(_ url: String, parameters: HTTPParameterProtocol? = nil, headers: [String:String]? = nil,
        requestSerializer: HTTPSerializeProtocol = HTTPParameterSerializer(), completionHandler: ((Response) -> Void)? = nil) -> HTTP? {
        return Run(url, method: .GET, parameters: parameters, headers: headers, requestSerializer: requestSerializer, completionHandler: completionHandler)
    }
    
    /**
    Class method to run a HEAD request that handles the URLRequest and parameter encoding for you.
    */
    @discardableResult open class func HEAD(_ url: String, parameters: HTTPParameterProtocol? = nil, headers: [String:String]? = nil, requestSerializer: HTTPSerializeProtocol = HTTPParameterSerializer(), completionHandler: ((Response) -> Void)? = nil) -> HTTP? {
        return Run(url, method: .HEAD, parameters: parameters, headers: headers, requestSerializer: requestSerializer, completionHandler: completionHandler)
    }
    
    /**
    Class method to run a DELETE request that handles the URLRequest and parameter encoding for you.
    */
    @discardableResult open class func DELETE(_ url: String, parameters: HTTPParameterProtocol? = nil, headers: [String:String]? = nil, requestSerializer: HTTPSerializeProtocol = HTTPParameterSerializer(), completionHandler: ((Response) -> Void)? = nil) -> HTTP? {
        return Run(url, method: .DELETE, parameters: parameters, headers: headers, requestSerializer: requestSerializer, completionHandler: completionHandler)
    }
    
    /**
    Class method to run a POST request that handles the URLRequest and parameter encoding for you.
    */
    @discardableResult open class func POST(_ url: String, parameters: HTTPParameterProtocol? = nil, headers: [String:String]? = nil, requestSerializer: HTTPSerializeProtocol = HTTPParameterSerializer(), completionHandler: ((Response) -> Void)? = nil) -> HTTP? {
        return Run(url, method: .POST, parameters: parameters, headers: headers, requestSerializer: requestSerializer, completionHandler: completionHandler)
    }
    
    /**
    Class method to run a PUT request that handles the URLRequest and parameter encoding for you.
    */
    @discardableResult open class func PUT(_ url: String, parameters: HTTPParameterProtocol? = nil, headers: [String:String]? = nil,
        requestSerializer: HTTPSerializeProtocol = HTTPParameterSerializer(), completionHandler: ((Response) -> Void)? = nil) -> HTTP? {
        return Run(url, method: .PUT, parameters: parameters, headers: headers, requestSerializer: requestSerializer, completionHandler: completionHandler)
    }
    
    /**
    Class method to run a PUT request that handles the URLRequest and parameter encoding for you.
    */
    @discardableResult open class func PATCH(_ url: String, parameters: HTTPParameterProtocol? = nil, headers: [String:String]? = nil, requestSerializer: HTTPSerializeProtocol = HTTPParameterSerializer(), completionHandler: ((Response) -> Void)? = nil) -> HTTP? {
        return Run(url, method: .PATCH, parameters: parameters, headers: headers, requestSerializer: requestSerializer, completionHandler: completionHandler)
    }
    
    @discardableResult class func Run(_ url: String, method: HTTPVerb, parameters: HTTPParameterProtocol? = nil, headers: [String:String]? = nil, requestSerializer: HTTPSerializeProtocol = HTTPParameterSerializer(), completionHandler: ((Response) -> Void)? = nil) -> HTTP?  {
        guard let task = HTTP.New(url, method: method, parameters: parameters, headers: headers, requestSerializer: requestSerializer, completionHandler: completionHandler) else {return nil}
        task.run()
        return task
    }
    
    /**
     Class method to create a Download request that handles the URLRequest and parameter encoding for you.
     */
    open class func Download(_ url: String, parameters: HTTPParameterProtocol? = nil, headers: [String:String]? = nil,
                             requestSerializer: HTTPSerializeProtocol = HTTPParameterSerializer(), completion:@escaping ((Response, URL) -> Void)) {
        guard let task = HTTP.New(url, method: .GET, parameters: parameters, headers: headers, requestSerializer: requestSerializer) else {return}
        task.downloadHandler = completion
        task.run()
    }
    
    /**
    Class method to create a HTTP request that handles the URLRequest and parameter encoding for you.
    */
    open class func New(_ url: String, method: HTTPVerb, parameters: HTTPParameterProtocol? = nil, headers: [String:String]? = nil, requestSerializer: HTTPSerializeProtocol = HTTPParameterSerializer(), completionHandler: ((Response) -> Void)? = nil) -> HTTP? {
        guard var req = URLRequest(urlString: url, headers: headers) else {
            guard let handler = completionHandler else { return nil }
            let resp = Response()
            resp.error = HTTPOptError.invalidRequest
            handler(resp)
            return nil
        }
        if let handler = DelegateManager.sharedInstance.requestHandler {
            handler(&req)
        }
        req.verb = method
        if let params = parameters {
            if let error = requestSerializer.serialize(&req, parameters: params) {
                guard let handler = completionHandler else { return nil }
                let resp = Response()
                resp.error = error
                handler(resp)
                return nil
            }
        }
        let httpReq = HTTP(req)
        httpReq.onFinish = completionHandler
        return httpReq
    }
    
    /**
    Set the global auth handler
    */
    open class func globalAuth(_ handler: ((URLAuthenticationChallenge) -> URLCredential?)?) {
        DelegateManager.sharedInstance.auth = handler
    }
    
    /**
    Set the global security handler
    */
    open class func globalSecurity(_ security: HTTPSecurity?) {
        DelegateManager.sharedInstance.security = security
    }
    
    /**
    Set the global request handler
    */
    open class func globalRequest(_ handler: ((inout URLRequest) -> Void)?) {
        DelegateManager.sharedInstance.requestHandler = handler
    }
}

extension HTTP {
    static func == (left: HTTP, right: HTTP) -> Bool {
        return left.task.taskIdentifier == right.task.taskIdentifier
    }
    
    static func != (left: HTTP, right: HTTP) -> Bool {
        return !(left == right)
    }
}

/**
Absorb all the delegates methods of NSURLSession and forwards them to pretty closures.
This is basically the sin eater for NSURLSession.
*/
public class DelegateManager: NSObject, URLSessionDataDelegate, URLSessionDownloadDelegate {
    //the singleton to handle delegate needs of NSURLSession
    static let sharedInstance = DelegateManager()
    
    /// this is for global authenication handling
    var auth:((URLAuthenticationChallenge) -> URLCredential?)?
    
    ///This is for global SSL pinning
    var security: HTTPSecurity?
    
    /// this is for global request handling
    var requestHandler:((inout URLRequest) -> Void)?
    
    var taskMap = Dictionary<Int,Response>()
    //"install" a task by adding the task to the map and setting the completion handler
    func addTask(_ task: URLSessionTask, completionHandler:@escaping ((Response) -> Void)) {
        addResponseForTask(task)
        if let resp = responseForTask(task) {
            resp.completionHandler = completionHandler
        }
    }
    
    //"remove" a task by removing the task from the map
    func removeTask(_ task: URLSessionTask) {
        taskMap.removeValue(forKey: task.taskIdentifier)
    }
    
    //add the response task
    func addResponseForTask(_ task: URLSessionTask) {
        if taskMap[task.taskIdentifier] == nil {
            taskMap[task.taskIdentifier] = Response()
        }
    }
    //get the response object for the task
    func responseForTask(_ task: URLSessionTask) -> Response? {
        return taskMap[task.taskIdentifier]
    }
    
    //handle getting data
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        addResponseForTask(dataTask)
        guard let resp = responseForTask(dataTask) else { return }
        resp.collectData.append(data)
        if resp.progressHandler != nil { //don't want the extra cycles for no reason
            guard let taskResp = dataTask.response else { return }
            progressHandler(resp, expectedLength: taskResp.expectedContentLength, currentLength: Int64(resp.collectData.length))
        }
    }
    
    //handle task finishing
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let resp = responseForTask(task) else { return }
        resp.error = error as NSError?
        if let hresponse = task.response as? HTTPURLResponse {
            resp.headers = hresponse.allHeaderFields as? Dictionary<String,String>
            resp.mimeType = hresponse.mimeType
            resp.suggestedFilename = hresponse.suggestedFilename
            resp.statusCode = hresponse.statusCode
            resp.URL = hresponse.url
        }
        if let code = resp.statusCode, code > 299 {
            resp.error = createError(code)
        }
        if let handler = resp.completionHandler {
            handler(resp)
        }
        removeTask(task)
    }
    
    //handle authenication
    public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        var sec = security
        var au = auth
        if let resp = responseForTask(task) {
            if let s = resp.security {
                sec = s
            }
            if let a = resp.auth {
                au = a
            }
        }
        if let sec = sec , challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let space = challenge.protectionSpace
            if let trust = space.serverTrust {
                if sec.isValid(trust, domain: space.host) {
                    completionHandler(.useCredential, URLCredential(trust: trust))
                    return
                }
            }
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
            
        } else if let a = au {
            let cred = a(challenge)
            if let c = cred {
                completionHandler(.useCredential, c)
                return
            }
            completionHandler(.rejectProtectionSpace, nil)
            return
        }
        completionHandler(.performDefaultHandling, nil)
    }
    
    //upload progress
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let resp = responseForTask(task) else { return }
        progressHandler(resp, expectedLength: totalBytesExpectedToSend, currentLength: totalBytesSent)
    }
    
    //download progress
    public func urlSession(_ session: Foundation.URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let resp = responseForTask(downloadTask) else { return }
        progressHandler(resp, expectedLength: totalBytesExpectedToWrite, currentLength: totalBytesWritten)
    }
    
    //handle download task
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let resp = responseForTask(downloadTask) else { return }
        guard let handler = resp.downloadHandler else { return }
        handler(resp, location)
    }
    
    //handle progress
    public func progressHandler(_ response: Response, expectedLength: Int64, currentLength: Int64) {
        guard let handler = response.progressHandler else { return }
        let slice = Float(1.0)/Float(expectedLength)
        handler(slice*Float(currentLength))
    }
    
    /**
    Create an error for response you probably don't want (400-500 HTTP responses for example).
    
    -parameter code: Code for error.
    
    -returns An NSError.
    */
    fileprivate func createError(_ code: Int) -> NSError {
        let text = HTTPStatusCode(statusCode: code).statusDescription
        return NSError(domain: "HTTP", code: code, userInfo: [NSLocalizedDescriptionKey: text])
    }
}

/**
Handles providing singletons of NSURLSession.
*/
public class SharedSession {
    public static let defaultSession = URLSession(configuration: URLSessionConfiguration.default,
        delegate: DelegateManager.sharedInstance, delegateQueue: nil)
    static let ephemeralSession = URLSession(configuration: URLSessionConfiguration.ephemeral,
        delegate: DelegateManager.sharedInstance, delegateQueue: nil)
}


/**
 Bare bones queue to manage HTTP Requests
 */
open class HTTPQueue {
    public var maxSimultaneousRequest = 5
    var queue = [HTTP]()
    let mutex = NSLock()
    var activeReq = [Int: HTTP]()
    var finishedHandler: (() -> Void)?
    
    public init(maxSimultaneousRequest: Int) {
        self.maxSimultaneousRequest = maxSimultaneousRequest
    }
    
    open func add(request: URLRequest) {
        add(http: HTTP(request))
    }
    
    open func add(http: HTTP) {
        var doWork = false
        mutex.lock()
        queue.append(http)
        if activeReq.count < maxSimultaneousRequest {
            doWork = true
        }
        mutex.unlock()
        if doWork {
            run()
        }
    }
    
    open func finished(queue: DispatchQueue = DispatchQueue.main, completionHandler: @escaping (() -> Void)) {
        finishedHandler = completionHandler
    }
    
    func run() {
        guard let http = nextItem() else {
            mutex.lock()
            let count = activeReq.count
            mutex.unlock()
            if count == 0 {
                finishedHandler?()
            }
            return
        }
        let handler = http.onFinish
        http.run {[weak self] (response) in
            handler?(response)
            self?.mutex.lock()
            self?.activeReq.removeValue(forKey: http.task.taskIdentifier)
            self?.mutex.unlock()
            self?.run()
        }
    }
    
    func nextItem() -> HTTP? {
        mutex.lock()
        if queue.count == 0 {
            mutex.unlock()
            return nil
        }
        let next = queue.removeFirst()
        activeReq[next.task.taskIdentifier] = next
        mutex.unlock()
        return next
    }
}
