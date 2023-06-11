//
//  _HTTPModel+cURL.swift
//  CocoaDebug
//
//  Created by Nehcgnos on 2023/6/11.
//  Copyright © 2023 man. All rights reserved.
//

import Foundation

extension _HttpModel {
    func cURLDescription() -> String {
        var components = ["curl \"\(url?.absoluteString ?? "<unknown url>")\""]

        if let method, method != "GET" {
            components.append("-X \(method)")
        }

        for (field, value) in requestHeaderFields {
            components.append("-H \"\(field): \(value)\"")
        }

        if let requestBodyString = String(data: requestData, encoding: .utf8), requestBodyString.isEmpty == false {
            var escapedBody = requestBodyString.replacingOccurrences(of: "\\\"", with: "\\\\\"")
            escapedBody = escapedBody.replacingOccurrences(of: "\"", with: "\\\"")

            components.append("-d \"\(escapedBody)\"")
        }

        return components.joined(separator: " \\\n")
    }
}
