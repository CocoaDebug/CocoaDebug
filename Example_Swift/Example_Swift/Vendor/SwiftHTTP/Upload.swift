//
//  Upload.swift
//  SwiftHTTP
//
//  Created by Dalton Cherry on 6/5/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//

import Foundation

#if os(iOS)
    import MobileCoreServices
#endif

/**
 Upload errors
 */
enum HTTPUploadError: Error {
    case noFileUrl
    case noData
}

/**
This is how to upload files in SwiftHTTP. The upload object represents a file to upload by either a data blob or a url (which it reads off disk).
*/
open class Upload: NSObject, NSCoding {
    var fileUrl: URL? {
        didSet {
            getMimeType()
        }
    }
    var mimeType: String?
    var data: Data?
    var fileName: String?
    
    /**
    Tries to determine the mime type from the fileUrl extension.
    */
    func getMimeType() {
        mimeType = "application/octet-stream"
        guard let url = fileUrl else { return }
        #if os(iOS) || os(OSX) //for watchOS support
            guard let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, url.pathExtension as CFString, nil) else { return }
            guard let str = UTTypeCopyPreferredTagWithClass(UTI.takeRetainedValue(), kUTTagClassMIMEType) else { return }
            mimeType = str.takeRetainedValue() as String
        #endif
    }
    
    /**
    Reads the data from disk or from memory. Throws an error if no data or file is found.
    */
    open func getData() -> (data: Data?, error: Error?) {
        if let d = data {
            return (d, nil)
        }
        guard let url = fileUrl else { return (nil, HTTPUploadError.noFileUrl) }
        fileName = url.lastPathComponent
        do {
            let d = try Data(contentsOf: url, options: .mappedIfSafe)
            data = d
            getMimeType()
            return (d, nil)
        } catch let error {
            return (nil, error)
        }
    }
    
    /**
    Standard NSCoder support
    */
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.fileUrl, forKey: "fileUrl")
        aCoder.encode(self.mimeType, forKey: "mimeType")
        aCoder.encode(self.fileName, forKey: "fileName")
        aCoder.encode(self.data, forKey: "data")
    }
    
    /**
    Required for NSObject support (because of NSCoder, it would be a struct otherwise!)
    */
    public override init() {
        super.init()
    }
    
    required public convenience init(coder aDecoder: NSCoder) {
        self.init()
        fileUrl = aDecoder.decodeObject(forKey: "fileUrl") as? URL
        mimeType = aDecoder.decodeObject(forKey: "mimeType") as? String
        fileName = aDecoder.decodeObject(forKey: "fileName") as? String
        data = aDecoder.decodeObject(forKey: "data") as? Data
    }
    
    /**
    Initializes a new Upload object with a fileUrl. The fileName and mimeType will be infered.
    
    -parameter fileUrl: The fileUrl is a standard url path to a file.
    */
    public convenience init(fileUrl: URL) {
        self.init()
        self.fileUrl = fileUrl
    }
    
    /**
    Initializes a new Upload object with a data blob.
    
    -parameter data: The data is a NSData representation of a file's data.
    -parameter fileName: The fileName is just that. The file's name.
    -parameter mimeType: The mimeType is just that. The mime type you would like the file to uploaded as.
    */
    ///upload a file from a a data blob. Must add a filename and mimeType as that can't be infered from the data
    public convenience init(data: Data, fileName: String, mimeType: String) {
        self.init()
        self.data = data
        self.fileName = fileName
        self.mimeType = mimeType
    }
}
