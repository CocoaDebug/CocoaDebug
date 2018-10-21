#if os(OSX)
    import AppKit.NSImage
    public typealias NetworkingImage = NSImage
#else
    import UIKit.UIImage
    public typealias NetworkingImage = UIImage
#endif

/**
 Helper methods to handle UIImage and NSImage related tasks.
 */
extension NetworkingImage {

    static func find(named name: String, inBundle bundle: Bundle) -> NetworkingImage {
        #if os(OSX)
            return bundle.image(forResource: name)!
        #elseif os(watchOS)
            return UIImage(named: name)!
        #else
            return UIImage(named: name, in: bundle, compatibleWith: nil)!
        #endif
    }

    #if os(OSX)

        func data(_ type: NSBitmapImageFileType) -> Data? {
            let imageData = tiffRepresentation!
            let bitmapImageRep = NSBitmapImageRep(data: imageData)!
            let data = bitmapImageRep.representation(using: type, properties: [String: Any]())
            return data
        }
    #endif

    func png_Data() -> Data? {
        #if os(OSX)
            return data(.PNG)
        #else
        return self.pngData()
        #endif
    }

    func jpgData() -> Data? {
        #if os(OSX)
            return data(.JPEG)
        #else
            return  self.jpegData(compressionQuality: 1)
        #endif
    }
}
