import Foundation

public extension Networking {
    /// Retrieves an image from the cache or from the filesystem.
    ///
    /// - Parameters:
    ///   - path: The path where the image is located.
    ///   - cacheName: The cache name used to identify the downloaded image, by default the path is used.
    /// - Returns: The cached image.
    func imageFromCache(_ path: String, cacheName: String? = nil) -> NetworkingImage? {
        let object = objectFromCache(for: path, cacheName: cacheName, responseType: .image)

        return object as? NetworkingImage
    }

    /// Downloads an image using the specified path.
    ///
    /// - Parameters:
    ///   - path: The path where the image is located.
    ///   - cacheName: The cache name used to identify the downloaded image, by default the path is used.
    ///   - completion: A closure that gets called when the image download request is completed, it contains an image and an error.
    /// - Returns: The request identifier.
    @discardableResult
    func downloadImage(_ path: String, cacheName: String? = nil, completion: @escaping (_ image: NetworkingImage?, _ error: NSError?) -> Void) -> String {
        let requestIdentifier = request(.get, path: path, cacheName: cacheName, parameterType: nil, parameters: nil, parts: nil, responseType: .image) { response, _, error in
            TestCheck.testBlock(self.isSynchronous) {
                completion(response as? NetworkingImage, error)
            }
        }

        return requestIdentifier
    }

    /// Cancels the image download request for the specified path. This causes the request to complete with error code URLError.cancelled.
    ///
    /// - Parameter path: The path for the cancelled image download request.
    func cancelImageDownload(_ path: String) {
        let url = try! self.url(for: path)
        cancelRequest(.data, requestType: .get, url: url)
    }

    /// Registers a fake download image request with an image. After registering this, every download request to the path, will return the registered image.
    ///
    /// - Parameters:
    ///   - path: The path for the faked image download request.
    ///   - image: An image that will be returned when there's a request to the registered path.
    ///   - statusCode: The status code to be used when faking the request.
    func fakeImageDownload(_ path: String, image: NetworkingImage?, statusCode: Int = 200) {
        fake(.get, path: path, response: image, responseType: .image, statusCode: statusCode)
    }

    /// Downloads data from a URL, caching the result.
    ///
    /// - Parameters:
    ///   - path: The path used to download the resource.
    ///   - cacheName: The cache name used to identify the downloaded data, by default the path is used.
    ///   - completion: A closure that gets called when the download request is completed, it contains  a `data` object and an `NSError`.
    @discardableResult
    func downloadData(for path: String, cacheName: String? = nil, completion: @escaping (_ data: Data?, _ error: NSError?) -> Void) -> String {
        let requestIdentifier = request(.get, path: path, cacheName: cacheName, parameterType: nil, parameters: nil, parts: nil, responseType: .data) { response, _, error in
            completion(response as? Data, error)
        }

        return requestIdentifier
    }

    /// Retrieves data from the cache or from the filesystem.
    ///
    /// - Parameters:
    ///   - path: The path where the image is located.
    ///   - cacheName: The cache name used to identify the downloaded data, by default the path is used.
    /// - Returns: The cached data.
    func dataFromCache(for path: String, cacheName: String? = nil) -> Data? {
        let object = objectFromCache(for: path, cacheName: cacheName, responseType: .data)

        return object as? Data
    }
}
