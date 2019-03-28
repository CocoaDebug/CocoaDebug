import Foundation

public extension Networking {

    /**
     Retrieves an image from the cache or from the filesystem.
     - parameter path: The path where the image is located.
     - parameter cacheName: The cache name used to identify the downloaded image, by default the path is used.
     - parameter completion: A closure that returns the image from the cache, if no image is found it will return nil, it contains an image and an error.
     */
    @available(*, deprecated, message: "Use `imageFromCache(path: String, cacheName: String?)` instead. The asynchronous version will be removed since it's synchronous now.")
    func imageFromCache(_ path: String, cacheName: String? = nil, completion: @escaping (_ image: NetworkingImage?) -> Void) {
        let object = imageFromCache(path, cacheName: cacheName)

        TestCheck.testBlock(isSynchronous) {
            completion(object)
        }
    }

    /**
     Authenticates using Basic Authentication, it converts username:password to Base64 then sets the Authorization header to "Basic \(Base64(username:password))".
     - parameter username: The username to be used.
     - parameter password: The password to be used.
     */
    @available(*, deprecated, message: "Use `setAuthorizationHeader(username:password:)` instead.")
    func authenticate(username: String, password: String) {
        setAuthorizationHeader(username: username, password: password)
    }

    /**
     Authenticates using a Bearer token, sets the Authorization header to "Bearer \(token)".
     - parameter token: The token to be used.
     */
    @available(*, deprecated, message: "Use `setAuthorizationHeader(token:)` instead")
    func authenticate(token: String) {
        setAuthorizationHeader(token: token)
    }

    /**
     Authenticates using a custom HTTP Authorization header.
     - parameter authorizationHeaderKey: Sets this value as the key for the HTTP `Authorization` header
     - parameter authorizationHeaderValue: Sets this value to the HTTP `Authorization` header or to the `headerKey` if you provided that.
     */
    @available(*, deprecated, message: "Use `setAuthorizationHeader(headerKey:headerValue:)` instead.")
    func authenticate(headerKey: String = "Authorization", headerValue: String) {
        setAuthorizationHeader(headerKey: headerKey, headerValue: headerValue)
    }

    /**
     Retrieves data from the cache or from the filesystem.
     - parameter path: The path where the image is located.
     - parameter cacheName: The cache name used to identify the downloaded data, by default the path is used.
     - parameter completion: A closure that returns the data from the cache, if no data is found it will return nil.
     */
    @available(*, deprecated, message: "Use `dataFromCache(path: String, cacheName: String?)` instead. The asynchronous version will be removed since it's synchronous now.")
    func dataFromCache(for path: String, cacheName: String? = nil, completion: @escaping (_ data: Data?) -> Void) {
        let object = dataFromCache(for: path, cacheName: cacheName)

        TestCheck.testBlock(isSynchronous) {
            completion(object)
        }
    }

    /**
     Cancels all the current requests.
     - parameter completion: The completion block to be called when all the requests are cancelled.
     */
    @available(*, deprecated, message: "Use `cancelAllRequests()` instead. The asynchronous version will be removed since it's synchronous now.")
    func cancelAllRequests(with completion: @escaping (() -> Void)) {
        cancelAllRequests()
        completion()
    }

    /**
     Cancels the GET request for the specified path. This causes the request to complete with error code URLError.cancelled.
     - parameter path: The path for the cancelled GET request
     - parameter completion: A closure that gets called when the cancellation is completed.
     */
    @available(*, deprecated, message: "Use `cancelGET(path)` instead. The asynchronous version will be removed since it's synchronous now.")
    func cancelGET(_ path: String, completion: (() -> Void)) {
        cancelGET(path)
        completion()
    }

    /**
     Cancels the PUT request for the specified path. This causes the request to complete with error code URLError.cancelled.
     - parameter path: The path for the cancelled PUT request.
     - parameter completion: A closure that gets called when the cancellation is completed.
     */
    @available(*, deprecated, message: "Use `cancelPUT(path)` instead. The asynchronous version will be removed since it's synchronous now.")
    func cancelPUT(_ path: String, completion: (() -> Void)) {
        cancelPUT(path)
        completion()
    }

    /**
     Cancels the POST request for the specified path. This causes the request to complete with error code URLError.cancelled.
     - parameter path: The path for the cancelled POST request.
     - parameter completion: A closure that gets called when the cancellation is completed.
     */
    @available(*, deprecated, message: "Use `cancelPOST(path)` instead. The asynchronous version will be removed since it's synchronous now.")
    func cancelPOST(_ path: String, completion: (() -> Void)) {
        cancelPOST(path)
        completion()
    }

    /**
     Cancels the DELETE request for the specified path. This causes the request to complete with error code URLError.cancelled.
     - parameter path: The path for the cancelled DELETE request.
     - parameter completion: A closure that gets called when the cancellation is completed.
     */
    @available(*, deprecated, message: "Use `cancelDELETE(path)` instead. The asynchronous version will be removed since it's synchronous now.")
    func cancelDELETE(_ path: String, completion: (() -> Void)) {
        cancelDELETE(path)
        completion()
    }

    /**
     Cancels the image download request for the specified path. This causes the request to complete with error code URLError.cancelled.
     - parameter path: The path for the cancelled image download request.
     - parameter completion: A closure that gets called when the cancellation is completed.
     */
    @available(*, deprecated, message: "Use `cancelImageDownload(path)` instead. The asynchronous version will be removed since it's synchronous now.")
    func cancelImageDownload(_ path: String, completion: (() -> Void)) {
        cancelImageDownload(path)
        completion()
    }

    /**
     Cancels the request that matches the requestID.
     - parameter requestID: The ID of the request to be cancelled.
     - parameter completion: The completion block to be called when the request is cancelled.
     */
    @available(*, deprecated, message: "Use `cancel(with:)` instead. The asynchronous version will be removed since it's synchronous now.")
    func cancel(with requestID: String, completion: (() -> Void)) {
        cancel(with: requestID)
        completion()
    }

    /**
     GET request to the specified path.
     - parameter path: The path for the GET request.
     - parameter completion: A closure that gets called when the GET request is completed, it contains a `JSON` object and an `NSError`.
     - returns: The request identifier.
     */
    @discardableResult
    @available(*, unavailable, renamed: "get")
    func GET(_ path: String, parameters: Any? = nil, completion: @escaping (_ json: Any?, _ error: NSError?) -> Void) -> String {
        let parameterType = parameters != nil ? ParameterType.formURLEncoded : ParameterType.none
        let requestID = request(.get, path: path, cacheName: nil, parameterType: parameterType, parameters: parameters, parts: nil, responseType: .json) { json, _, error in
            completion(json, error)
        }

        return requestID
    }

    /**
     GET request to the specified path.
     - parameter path: The path for the GET request.
     - parameter completion: A closure that gets called when the GET request is completed, it contains a `JSON` object and an `NSError`.
     - returns: The request identifier.
     */
    @discardableResult
    @available(*, unavailable, renamed: "get")
    func GET(_ path: String, parameters: Any? = nil, completion: @escaping (_ json: Any?, _ headers: [AnyHashable: Any], _ error: NSError?) -> Void) -> String {
        let parameterType = parameters != nil ? ParameterType.formURLEncoded : ParameterType.none
        let requestID = request(.get, path: path, cacheName: nil, parameterType: parameterType, parameters: parameters, parts: nil, responseType: .json, completion: completion)

        return requestID
    }

    /**
     PUT request to the specified path, using the provided parameters.
     - parameter path: The path for the PUT request.
     - parameter parameters: The parameters to be used, they will be serialized using the ParameterType, by default this is JSON.
     - parameter completion: A closure that gets called when the PUT request is completed, it contains a `JSON` object and an `NSError`.
     - returns: The request identifier.
     */
    @discardableResult
    @available(*, unavailable, renamed: "put")
    func PUT(_ path: String, parameterType: ParameterType = .json, parameters: Any? = nil, completion: @escaping (_ json: Any?, _ error: NSError?) -> Void) -> String {
        let requestID = request(.put, path: path, cacheName: nil, parameterType: parameterType, parameters: parameters, parts: nil, responseType: .json) { json, _, error in
            completion(json, error)
        }

        return requestID
    }

    /**
     PUT request to the specified path, using the provided parameters.
     - parameter path: The path for the PUT request.
     - parameter parameters: The parameters to be used, they will be serialized using the ParameterType, by default this is JSON.
     - parameter completion: A closure that gets called when the PUT request is completed, it contains a `JSON` object and an `NSError`.
     - returns: The request identifier.
     */
    @discardableResult
    @available(*, unavailable, renamed: "put")
    func PUT(_ path: String, parameterType: ParameterType = .json, parameters: Any? = nil, completion: @escaping (_ json: Any?, _ headers: [AnyHashable: Any], _ error: NSError?) -> Void) -> String {
        let requestID = request(.put, path: path, cacheName: nil, parameterType: parameterType, parameters: parameters, parts: nil, responseType: .json, completion: completion)

        return requestID
    }

    /**
     POST request to the specified path, using the provided parameters.
     - parameter path: The path for the POST request.
     - parameter parameters: The parameters to be used, they will be serialized using the ParameterType, by default this is JSON.
     - parameter completion: A closure that gets called when the POST request is completed, it contains a `JSON` object and an `NSError`.
     - returns: The request identifier.
     */
    @discardableResult
    @available(*, unavailable, renamed: "post")
    func POST(_ path: String, parameterType: ParameterType = .json, parameters: Any? = nil, completion: @escaping (_ json: Any?, _ error: NSError?) -> Void) -> String {
        let requestID = request(.post, path: path, cacheName: nil, parameterType: parameterType, parameters: parameters, parts: nil, responseType: .json) { json, _, error in
            completion(json, error)
        }

        return requestID
    }

    /**
     POST request to the specified path, using the provided parameters.
     - parameter path: The path for the POST request.
     - parameter parameters: The parameters to be used, they will be serialized using the ParameterType, by default this is JSON.
     - parameter completion: A closure that gets called when the POST request is completed, it contains a `JSON` object and an `NSError`.
     - returns: The request identifier.
     */
    @discardableResult
    @available(*, unavailable, renamed: "post")
    func POST(_ path: String, parameterType: ParameterType = .json, parameters: Any? = nil, completion: @escaping (_ json: Any?, _ headers: [AnyHashable: Any], _ error: NSError?) -> Void) -> String {
        let requestID = request(.post, path: path, cacheName: nil, parameterType: parameterType, parameters: parameters, parts: nil, responseType: .json, completion: completion)

        return requestID
    }

    /**
     POST request to the specified path, using the provided parameters.
     - parameter path: The path for the POST request.
     - parameter parameters: The parameters to be used, they will be serialized using the ParameterType, by default this is JSON.
     - parameter part: The form data that will be sent in the request.
     - parameter completion: A closure that gets called when the POST request is completed, it contains a `JSON` object and an `NSError`.
     - returns: The request identifier.
     */
    @discardableResult
    @available(*, unavailable, renamed: "post")
    func POST(_ path: String, parameters: Any? = nil, part: FormDataPart, completion: @escaping (_ json: Any?, _ error: NSError?) -> Void) -> String {
        let requestID = post(path, parameters: parameters, parts: [part], completion: completion)

        return requestID
    }

    /**
     POST request to the specified path, using the provided parameters.
     - parameter path: The path for the POST request.
     - parameter parameters: The parameters to be used, they will be serialized using the ParameterType, by default this is JSON.
     - parameter parts: The list of form data parts that will be sent in the request.
     - parameter completion: A closure that gets called when the POST request is completed, it contains a `JSON` object and an `NSError`.
     - returns: The request identifier.
     */
    @discardableResult
    @available(*, unavailable, renamed: "post")
    func POST(_ path: String, parameters: Any? = nil, parts: [FormDataPart], completion: @escaping (_ json: Any?, _ error: NSError?) -> Void) -> String {
        let requestID = request(.post, path: path, cacheName: nil, parameterType: .multipartFormData, parameters: parameters, parts: parts, responseType: .json) { json, _, error in
            completion(json, error)
        }
        
        return requestID
    }

    /**
     DELETE request to the specified path, using the provided parameters.
     - parameter path: The path for the DELETE request.
     - parameter completion: A closure that gets called when the DELETE request is completed, it contains a `JSON` object and an `NSError`.
     - returns: The request identifier.
     */
    @discardableResult
    @available(*, unavailable, renamed: "delete")
    func DELETE(_ path: String, parameters: Any? = nil, completion: @escaping (_ json: Any?, _ error: NSError?) -> Void) -> String {
        let parameterType = parameters != nil ? ParameterType.formURLEncoded : ParameterType.none
        let requestID = request(.delete, path: path, cacheName: nil, parameterType: parameterType, parameters: parameters, parts: nil, responseType: .json) { json, _, error in
            completion(json, error)
        }

        return requestID
    }

    /**
     DELETE request to the specified path, using the provided parameters.
     - parameter path: The path for the DELETE request.
     - parameter completion: A closure that gets called when the DELETE request is completed, it contains a `JSON` object and an `NSError`.
     - returns: The request identifier.
     */
    @discardableResult
    @available(*, unavailable, renamed: "delete")
    func DELETE(_ path: String, parameters: Any? = nil, completion: @escaping (_ json: Any?, _ headers: [AnyHashable: Any], _ error: NSError?) -> Void) -> String {
        let parameterType = parameters != nil ? ParameterType.formURLEncoded : ParameterType.none
        let requestID = request(.delete, path: path, cacheName: nil, parameterType: parameterType, parameters: parameters, parts: nil, responseType: .json, completion: completion)

        return requestID
    }
}
