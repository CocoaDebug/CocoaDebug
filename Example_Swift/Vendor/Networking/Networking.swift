import Foundation

public extension Int {

    /**
     Categorizes a status code.
     - returns: The NetworkingStatusCodeType of the status code.
     */
    func statusCodeType() -> Networking.StatusCodeType {
        switch self {
        case URLError.cancelled.rawValue:
            return .cancelled
        case 100 ..< 200:
            return .informational
        case 200 ..< 300:
            return .successful
        case 300 ..< 400:
            return .redirection
        case 400 ..< 500:
            return .clientError
        case 500 ..< 600:
            return .serverError
        default:
            return .unknown
        }
    }
}

open class Networking {
    static let domain = "com.3lvis.networking"

    struct FakeRequest {
        let response: Any?
        let responseType: ResponseType
        let statusCode: Int
    }

    /**
     Provides the options for configuring your Networking object with NSURLSessionConfiguration.
     - `Default:` This configuration type manages upload and download tasks using the default options.
     - `Ephemeral:` A configuration type that uses no persistent storage for caches, cookies, or credentials. It's optimized for transferring data to and from your app’s memory.
     - `Background:` A configuration type that allows HTTP and HTTPS uploads or downloads to be performed in the background. It causes upload and download tasks to be performed by the system in a separate process.
     */
    public enum ConfigurationType {
        case `default`, ephemeral, background
    }

    enum RequestType: String {
        case get = "GET", post = "POST", put = "PUT", delete = "DELETE"
    }

    enum SessionTaskType: String {
        case data, upload, download
    }

    /**
     Sets the rules to serialize your parameters, also sets the `Content-Type` header.
     - `JSON:` Serializes your parameters using `NSJSONSerialization` and sets your `Content-Type` to `application/json`.
     - `FormURLEncoded:` Serializes your parameters using `Percent-encoding` and sets your `Content-Type` to `application/x-www-form-urlencoded`.
     - `MultipartFormData:` Serializes your parameters and parts as multipart and sets your `Content-Type` to `multipart/form-data`.
     - `Custom(String):` Sends your parameters as plain data, sets your `Content-Type` to the value inside `Custom`.
     */
    public enum ParameterType {
        /**
         Don't specify any `Content-Type`.
         */
        case none
        /**
         Serializes your parameters using `NSJSONSerialization` and sets your `Content-Type` to `application/json`.
         */
        case json
        /**
         Serializes your parameters using `Percent-encoding` and sets your `Content-Type` to `application/x-www-form-urlencoded`.
         */
        case formURLEncoded
        /**
         Serializes your parameters and parts as multipart and sets your `Content-Type` to `multipart/form-data`.
         */
        case multipartFormData
        /**
         Sends your parameters as plain data, sets your `Content-Type` to the value inside `Custom`.
         */
        case custom(String)

        func contentType(_ boundary: String) -> String? {
            switch self {
            case .none:
                return nil
            case .json:
                return "application/json"
            case .formURLEncoded:
                return "application/x-www-form-urlencoded"
            case .multipartFormData:
                return "multipart/form-data; boundary=\(boundary)"
            case .custom(let value):
                return value
            }
        }
    }

    enum ResponseType {
        case json
        case data
        case image

        var accept: String? {
            switch self {
            case .json:
                return "application/json"
            default:
                return nil
            }
        }
    }

    /**
     Categorizes a status code.
     - `Informational`: This class of status code indicates a provisional response, consisting only of the Status-Line and optional headers, and is terminated by an empty line.
     - `Successful`: This class of status code indicates that the client's request was successfully received, understood, and accepted.
     - `Redirection`: This class of status code indicates that further action needs to be taken by the user agent in order to fulfill the request.
     - `ClientError:` The 4xx class of status code is intended for cases in which the client seems to have erred.
     - `ServerError:` Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has erred or is incapable of performing the request.
     - `Cancelled:` When a request gets cancelled
     - `Unknown:` This response status code could be used by Foundation for other types of states.
     */
    public enum StatusCodeType {
        case informational, successful, redirection, clientError, serverError, cancelled, unknown
    }

    fileprivate let baseURL: String
    fileprivate var fakeRequests = [RequestType: [String: FakeRequest]]()
    var token: String?
    var authorizationHeaderValue: String?
    var authorizationHeaderKey = "Authorization"
    fileprivate var configurationType: ConfigurationType
    var cache: NSCache<AnyObject, AnyObject>

    /**
     Flag used to indicate synchronous request.
     */
    public var isSynchronous = false

    /**
     Flag used to disable error logging. Useful when want to disable log before release build.
     */
    public var disableErrorLogging = false

    /**
     The boundary used for multipart requests.
     */
    let boundary = String(format: "net.3lvis.networking.%08x%08x", arc4random(), arc4random())

    lazy var session: URLSession = {
        var configuration = self.sessionConfiguration()
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil

        return URLSession(configuration: configuration)
    }()

    /**
     Base initializer, it creates an instance of `Networking`.
     - parameter baseURL: The base URL for HTTP requests under `Networking`.
     */
    public init(baseURL: String, configurationType: ConfigurationType = .default, cache: NSCache<AnyObject, AnyObject>? = nil) {
        self.baseURL = baseURL
        self.configurationType = configurationType
        self.cache = cache ?? NSCache()
    }

    /**
     Authenticates using Basic Authentication, it converts username:password to Base64 then sets the Authorization header to "Basic \(Base64(username:password))".
     - parameter username: The username to be used.
     - parameter password: The password to be used.
     */
    public func setAuthorizationHeader(username: String, password: String) {
        let credentialsString = "\(username):\(password)"
        if let credentialsData = credentialsString.data(using: .utf8) {
            let base64Credentials = credentialsData.base64EncodedString(options: [])
            let authString = "Basic \(base64Credentials)"

            authorizationHeaderKey = "Authorization"
            authorizationHeaderValue = authString
        }
    }

    /**
     Authenticates using a Bearer token, sets the Authorization header to "Bearer \(token)".
     - parameter token: The token to be used.
     */
    public func setAuthorizationHeader(token: String) {
        self.token = token
    }

    /**
     Sets the header fields for every HTTP call.
     */
    public var headerFields: [String: String]?

    /**
     Authenticates using a custom HTTP Authorization header.
     - parameter authorizationHeaderKey: Sets this value as the key for the HTTP `Authorization` header
     - parameter authorizationHeaderValue: Sets this value to the HTTP `Authorization` header or to the `headerKey` if you provided that.
     */
    public func setAuthorizationHeader(headerKey: String = "Authorization", headerValue: String) {
        authorizationHeaderKey = headerKey
        authorizationHeaderValue = headerValue
    }

    /// Callback used to intercept requests that return with a 403 or 401 status code.
    public var unauthorizedRequestCallback: (() -> Void)?

    /**
     Returns a NSURL by appending the provided path to the Networking's base URL.
     - parameter path: The path to be appended to the base URL.
     - returns: A NSURL generated after appending the path to the base URL.
     */
    public func url(for path: String) throws -> URL {
        let encodedPath = path.encodeUTF8() ?? path
        guard let url = URL(string: baseURL + encodedPath) else {
            throw NSError(domain: Networking.domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Couldn't create a url using baseURL: \(baseURL) and encodedPath: \(encodedPath)"])
        }
        return url
    }

    /**
     Returns the NSURL used to store a resource for a certain path. Useful to find where a download image is located.
     - parameter path: The path used to download the resource.
     - returns: A NSURL where a resource has been stored.
     */
    public func destinationURL(for path: String, cacheName: String? = nil) throws -> URL {
        let normalizedCacheName = cacheName?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        var resourcesPath: String
        if let normalizedCacheName = normalizedCacheName {
            resourcesPath = normalizedCacheName
        } else {
            let url = try self.url(for: path)
            resourcesPath = url.absoluteString
        }

        let normalizedResourcesPath = resourcesPath.replacingOccurrences(of: "/", with: "-")
        let folderPath = Networking.domain
        let finalPath = "\(folderPath)/\(normalizedResourcesPath)"

        if let url = URL(string: finalPath) {
            #if os(tvOS)
                let directory = FileManager.SearchPathDirectory.cachesDirectory
            #else
                let directory = TestCheck.isTesting ? FileManager.SearchPathDirectory.cachesDirectory : FileManager.SearchPathDirectory.documentDirectory
            #endif
            if let cachesURL = FileManager.default.urls(for: directory, in: .userDomainMask).first {
                try (cachesURL as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
                let folderURL = cachesURL.appendingPathComponent(URL(string: folderPath)!.absoluteString)

                if FileManager.default.exists(at: folderURL) == false {
                    try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: false, attributes: nil)
                }

                let destinationURL = cachesURL.appendingPathComponent(url.absoluteString)

                return destinationURL
            } else {
                throw NSError(domain: Networking.domain, code: 9999, userInfo: [NSLocalizedDescriptionKey: "Couldn't normalize url"])
            }
        } else {
            throw NSError(domain: Networking.domain, code: 9999, userInfo: [NSLocalizedDescriptionKey: "Couldn't create a url using replacedPath: \(finalPath)"])
        }
    }

    /**
     Splits a url in base url and relative path.
     - parameter path: The full url to be splitted.
     - returns: A base url and a relative path.
     */
    public static func splitBaseURLAndRelativePath(for path: String) -> (baseURL: String, relativePath: String) {
        guard let encodedPath = path.encodeUTF8() else { fatalError("Couldn't encode path to UTF8: \(path)") }
        guard let url = URL(string: encodedPath) else { fatalError("Path \(encodedPath) can't be converted to url") }
        guard let baseURLWithDash = URL(string: "/", relativeTo: url)?.absoluteURL.absoluteString else { fatalError("Can't find absolute url of url: \(url)") }
        let index = baseURLWithDash.index(before: baseURLWithDash.endIndex)
//        let baseURL = baseURLWithDash.substring(to: index) //swift3
        let baseURL = String(baseURLWithDash[..<index]) //swift4
        
        let relativePath = path.replacingOccurrences(of: baseURL, with: "")

        return (baseURL, relativePath)
    }

    /**
     Cancels the request that matches the requestID.
     - parameter requestID: The ID of the request to be cancelled.
     */
    public func cancel(with requestID: String) {
        let semaphore = DispatchSemaphore(value: 0)
        session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            var tasks = [URLSessionTask]()
            tasks.append(contentsOf: dataTasks as [URLSessionTask])
            tasks.append(contentsOf: uploadTasks as [URLSessionTask])
            tasks.append(contentsOf: downloadTasks as [URLSessionTask])

            for task in tasks {
                if task.taskDescription == requestID {
                    task.cancel()
                    break
                }
            }

            semaphore.signal()
        }

        _ = semaphore.wait(timeout: DispatchTime.now() + 60.0)
    }

    /**
     Cancels all the current requests.
     */
    public func cancelAllRequests() {
        let semaphore = DispatchSemaphore(value: 0)
        session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            for sessionTask in dataTasks {
                sessionTask.cancel()
            }
            for sessionTask in downloadTasks {
                sessionTask.cancel()
            }
            for sessionTask in uploadTasks {
                sessionTask.cancel()
            }

            semaphore.signal()
        }

        _ = semaphore.wait(timeout: DispatchTime.now() + 60.0)
    }

    /// Deletes the downloaded/cached files.
    public static func deleteCachedFiles() {
        #if os(tvOS)
            let directory = FileManager.SearchPathDirectory.cachesDirectory
        #else
            let directory = TestCheck.isTesting ? FileManager.SearchPathDirectory.cachesDirectory : FileManager.SearchPathDirectory.documentDirectory
        #endif
        if let cachesURL = FileManager.default.urls(for: directory, in: .userDomainMask).first {
            let folderURL = cachesURL.appendingPathComponent(URL(string: Networking.domain)!.absoluteString)

            if FileManager.default.exists(at: folderURL) {
                _ = try? FileManager.default.remove(at: folderURL)
            }
        }
    }

    /// Removes the stored credentials and cached data.
    public func reset() {
        cache.removeAllObjects()
        fakeRequests.removeAll()
        token = nil
        headerFields = nil
        authorizationHeaderKey = "Authorization"
        authorizationHeaderValue = nil

        Networking.deleteCachedFiles()
    }
}

extension Networking {

    func objectFromCache(for path: String, cacheName: String? = nil, responseType: ResponseType) -> Any? {
        /*
         Workaround: Remove URL parameters from path. That can lead to writing cached files with names longer than
         255 characters, resulting in error. Another option to explore is to use a hash version of the url if it's
         longer than 255 characters.
         */
        guard let destinationURL = try? destinationURL(for: path, cacheName: cacheName) else { fatalError("Couldn't get destination URL for path: \(path) and cacheName: \(String(describing: cacheName))") }

        if let object = cache.object(forKey: destinationURL.absoluteString as AnyObject) {
            return object
        } else if FileManager.default.exists(at: destinationURL) {
            var returnedObject: Any?

            let object = data(for: destinationURL)
            if responseType == .image {
                returnedObject = NetworkingImage(data: object)
            } else {
                returnedObject = object
            }
            if let returnedObject = returnedObject {
                cache.setObject(returnedObject as AnyObject, forKey: destinationURL.absoluteString as AnyObject)
            }

            return returnedObject
        } else {
            return nil
        }
    }

    func data(for destinationURL: URL) -> Data {
        let path = destinationURL.path
        guard let data = FileManager.default.contents(atPath: path) else { fatalError("Couldn't get image in destination url: \(String(describing: url))") }

        return data
    }

    func sessionConfiguration() -> URLSessionConfiguration {
        switch configurationType {
        case .default:
            return URLSessionConfiguration.default
        case .ephemeral:
            return URLSessionConfiguration.ephemeral
        case .background:
            return URLSessionConfiguration.background(withIdentifier: "NetworkingBackgroundConfiguration")
        }
    }

    func fake(_ requestType: RequestType, path: String, fileName: String, bundle: Bundle = Bundle.main) {
        do {
            if let result = try JSON.from(fileName, bundle: bundle) {
                fake(requestType, path: path, response: result, responseType: .json, statusCode: 200)
            }
        } catch ParsingError.notFound {
            fatalError("We couldn't find \(fileName), are you sure is there?")
        } catch {
            fatalError("Converting data to JSON failed")
        }
    }

    func fake(_ requestType: RequestType, path: String, response: Any?, responseType: ResponseType, statusCode: Int) {
        var fakeRequests = self.fakeRequests[requestType] ?? [String: FakeRequest]()
        fakeRequests[path] = FakeRequest(response: response, responseType: responseType, statusCode: statusCode)
        self.fakeRequests[requestType] = fakeRequests
    }

    @discardableResult
    func request(_ requestType: RequestType, path: String, cacheName: String?, parameterType: ParameterType?, parameters: Any?, parts: [FormDataPart]?, responseType: ResponseType, completion: @escaping (_ response: Any?, _ headers: [AnyHashable: Any], _ error: NSError?) -> Void) -> String {
        var requestID = UUID().uuidString

        if let fakeRequests = fakeRequests[requestType], let fakeRequest = fakeRequests[path] {
            if fakeRequest.statusCode.statusCodeType() == .successful {
                completion(fakeRequest.response, [String: Any](), nil)
            } else {
                if let unauthorizedRequestCallback = unauthorizedRequestCallback, fakeRequest.statusCode == 403 || fakeRequest.statusCode == 401 {
                    unauthorizedRequestCallback()
                } else {
                    let error = NSError(domain: Networking.domain, code: fakeRequest.statusCode, userInfo: [NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: fakeRequest.statusCode)])
                    completion(fakeRequest.response, [String: Any](), error)
                }
            }
        } else {
            switch responseType {
            case .json:
                requestID = dataRequest(requestType, path: path, cacheName: cacheName, parameterType: parameterType, parameters: parameters, parts: parts, responseType: responseType) { data, headers, error in
                    var returnedError = error
                    var returnedResponse: Any?
                    if let data = data, data.count > 0 {
                        do {
                            returnedResponse = try JSONSerialization.jsonObject(with: data, options: [])
                        } catch let JSONParsingError as NSError {
                            if returnedError == nil {
                                returnedError = JSONParsingError
                            }
                        }
                    }
                    TestCheck.testBlock(self.isSynchronous) {
                        completion(returnedResponse, headers, returnedError)
                    }
                }
            case .data, .image:
                let object = objectFromCache(for: path, cacheName: cacheName, responseType: responseType)
                if let object = object {
                    TestCheck.testBlock(isSynchronous) {
                        completion(object, [String: Any](), nil)
                    }
                } else {
                    requestID = dataRequest(requestType, path: path, cacheName: cacheName, parameterType: parameterType, parameters: parameters, parts: parts, responseType: responseType) { data, headers, error in

                        var returnedResponse: Any?
                        if let data = data, data.count > 0 {
                            guard let destinationURL = try? self.destinationURL(for: path, cacheName: cacheName) else { fatalError("Couldn't get destination URL for path: \(path) and cacheName: \(String(describing: cacheName))") }
                            _ = try? data.write(to: destinationURL, options: [.atomic])
                            switch responseType {
                            case .data:
                                self.cache.setObject(data as AnyObject, forKey: destinationURL.absoluteString as AnyObject)
                                returnedResponse = data
                            case .image:
                                if let image = NetworkingImage(data: data) {
                                    self.cache.setObject(image, forKey: destinationURL.absoluteString as AnyObject)
                                    returnedResponse = image
                                }
                            default:
                                fatalError("Response Type is different than Data and Image")
                            }
                        }
                        TestCheck.testBlock(self.isSynchronous) {
                            completion(returnedResponse, headers, error)
                        }
                    }
                }
            }
        }

        return requestID
    }

    @discardableResult
    func dataRequest(_ requestType: RequestType, path: String, cacheName: String?, parameterType: ParameterType?, parameters: Any?, parts: [FormDataPart]?, responseType: ResponseType, completion: @escaping (_ response: Data?, _ headers: [AnyHashable: Any], _ error: NSError?) -> Void) -> String {
        let requestID = UUID().uuidString
        var request = URLRequest(url: try! url(for: path))
        request.httpMethod = requestType.rawValue

        if let parameterType = parameterType, let contentType = parameterType.contentType(boundary) {
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        }

        if let accept = responseType.accept {
            request.addValue(accept, forHTTPHeaderField: "Accept")
        }

        if let authorizationHeader = authorizationHeaderValue {
            request.setValue(authorizationHeader, forHTTPHeaderField: authorizationHeaderKey)
        } else if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: authorizationHeaderKey)
        }

        if let headerFields = headerFields {
            for (key, value) in headerFields {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        DispatchQueue.main.async {
            NetworkActivityIndicator.sharedIndicator.visible = true
        }

        var serializingError: NSError?
        if let parameterType = parameterType {
            switch parameterType {
            case .none: break
            case .json:
                if let parameters = parameters {
                    do {
                        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                    } catch let error as NSError {
                        serializingError = error
                    }
                }
            case .formURLEncoded:
                guard let parametersDictionary = parameters as? [String: Any] else { fatalError("Couldn't convert parameters to a dictionary: \(String(describing: parameters))") }
                do {
                    let formattedParameters = try parametersDictionary.urlEncodedString()
                    switch requestType {
                    case .get, .delete:
                        let urlEncodedPath: String
                        if path.contains("?") {
                            if let lastCharacter = path.last, lastCharacter == "?" {
                                urlEncodedPath = path + formattedParameters
                            } else {
                                urlEncodedPath = path + "&" + formattedParameters
                            }
                        } else {
                            urlEncodedPath = path + "?" + formattedParameters
                        }
                        request.url = try! url(for: urlEncodedPath)
                    case .post, .put:
                        request.httpBody = formattedParameters.data(using: .utf8)
                    }
                } catch let error as NSError {
                    serializingError = error
                }
            case .multipartFormData:
                var bodyData = Data()

                if let parameters = parameters as? [String: Any] {
                    for (key, value) in parameters {
                        let usedValue: Any = value is NSNull ? "null" : value
                        var body = ""
                        body += "--\(boundary)\r\n"
                        body += "Content-Disposition: form-data; name=\"\(key)\""
                        body += "\r\n\r\n\(usedValue)\r\n"
                        bodyData.append(body.data(using: .utf8)!)
                    }
                }

                if let parts = parts {
                    for var part in parts {
                        part.boundary = boundary
                        bodyData.append(part.formData as Data)
                    }
                }

                bodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
                request.httpBody = bodyData as Data
            case .custom:
                request.httpBody = parameters as? Data
            }
        }

        if let serializingError = serializingError {
            completion(nil, [String: Any](), serializingError)
        } else {
            var connectionError: Error?
            let semaphore = DispatchSemaphore(value: 0)
            var returnedResponse: URLResponse?
            var returnedData: Data?
            var returnedHeaders = [AnyHashable: Any]()

            let session = self.session.dataTask(with: request) { data, response, error in
                returnedResponse = response
                connectionError = error
                returnedData = data

                if let httpResponse = response as? HTTPURLResponse {
                    returnedHeaders = httpResponse.allHeaderFields

                    if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
                        if let data = data, data.count > 0 {
                            returnedData = data
                        }
                    } else {
                        var errorCode = httpResponse.statusCode
                        if let error = error as NSError? {
                            if error.code == URLError.cancelled.rawValue {
                                errorCode = error.code
                            }
                        }

                        connectionError = NSError(domain: Networking.domain, code: errorCode, userInfo: [NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)])
                    }
                }

                if TestCheck.isTesting && self.isSynchronous == false {
                    semaphore.signal()
                } else {
                    DispatchQueue.main.async {
                        NetworkActivityIndicator.sharedIndicator.visible = false
                    }

                    self.logError(parameterType: parameterType, parameters: parameters, data: returnedData, request: request, response: returnedResponse, error: connectionError as NSError?)
                    if let unauthorizedRequestCallback = self.unauthorizedRequestCallback, let error = connectionError as NSError?, error.code == 403 || error.code == 401 {
                        unauthorizedRequestCallback()
                    } else {
                        completion(returnedData, returnedHeaders, connectionError as NSError?)
                    }
                }
            }

            session.taskDescription = requestID
            session.resume()

            if TestCheck.isTesting && isSynchronous == false {
                _ = semaphore.wait(timeout: DispatchTime.now() + 60.0)
                logError(parameterType: parameterType, parameters: parameters, data: returnedData, request: request as URLRequest, response: returnedResponse, error: connectionError as NSError?)
                if let unauthorizedRequestCallback = unauthorizedRequestCallback, let error = connectionError as NSError?, error.code == 403 || error.code == 401 {
                    unauthorizedRequestCallback()
                } else {
                    completion(returnedData, returnedHeaders, connectionError as NSError?)
                }
            }
        }

        return requestID
    }

    func cancelRequest(_ sessionTaskType: SessionTaskType, requestType: RequestType, url: URL) {
        let semaphore = DispatchSemaphore(value: 0)
        session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            var sessionTasks = [URLSessionTask]()
            switch sessionTaskType {
            case .data:
                sessionTasks = dataTasks
            case .download:
                sessionTasks = downloadTasks
            case .upload:
                sessionTasks = uploadTasks
            }

            for sessionTask in sessionTasks {
                if sessionTask.originalRequest?.httpMethod == requestType.rawValue && sessionTask.originalRequest?.url?.absoluteString == url.absoluteString {
                    sessionTask.cancel()
                    break
                }
            }

            semaphore.signal()
        }

        _ = semaphore.wait(timeout: DispatchTime.now() + 60.0)
    }

    func logError(parameterType: ParameterType?, parameters: Any? = nil, data: Data?, request: URLRequest?, response: URLResponse?, error: NSError?) {
        if disableErrorLogging { return }
        guard let error = error else { return }

//        print(" ")
//        print("========== Networking Error ==========")
//        print(" ")

        let isCancelled = error.code == NSURLErrorCancelled
        if isCancelled {
            if let request = request, let _ = request.url {
//                print("Cancelled request: \(url.absoluteString)")
//                print(" ")
            }
        } else {
//            print("*** Request ***")
//            print(" ")

//            print("Error \(error.code): \(error.description)")
//            print(" ")

            if let request = request, let _ = request.url {
//                print("URL: \(url.absoluteString)")
//                print(" ")
            }

            if (request?.allHTTPHeaderFields) != nil {
//                print("Headers: \(headers)")
//                print(" ")
            }

            if let parameterType = parameterType, let parameters = parameters {
                switch parameterType {
                case .json:
                    do {
                        let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                        let string = String(data: data, encoding: .utf8)
                        if string != nil {
//                            print("Parameters: \(string)")
//                            print(" ")
                        }
                    } catch _ as NSError {
//                        print("Failed pretty printing parameters: \(parameters), error: \(error)")
//                        print(" ")
                    }
                case .formURLEncoded:
                    guard let parametersDictionary = parameters as? [String: Any] else { fatalError("Couldn't cast parameters as dictionary: \(parameters)") }
                    do {
                        _ = try parametersDictionary.urlEncodedString()
//                        print("Parameters: \(formattedParameters)")
                    } catch _ as NSError {
//                        print("Failed parsing Parameters: \(parametersDictionary) — \(error)")
                    }
//                    print(" ")
                default: break
                }
            }

            if let data = data, let _ = String(data: data, encoding: .utf8) {
//                print("Data: \(stringData)")
//                print(" ")
            }

            if (response as? HTTPURLResponse) != nil {
//                print("*** Response ***")
//                print(" ")

//                print("Headers: \(response.allHeaderFields)")
//                print(" ")

//                print("Status code: \(response.statusCode) — \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))")
//                print(" ")
            }
        }
//        print("================= ~ ==================")
//        print(" ")
    }
}
