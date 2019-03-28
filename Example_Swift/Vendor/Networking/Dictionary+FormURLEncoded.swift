import Foundation

public extension Dictionary where Key: ExpressibleByStringLiteral {

    /**
     Returns the parameters in using URL-enconding, for example ["username": "Michael", "age": 20] will become "username=Michael&age=20".
     */
    func urlEncodedString() throws -> String {

        let pairs = try reduce([]) { current, keyValuePair -> [String] in
            if let encodedValue = "\(keyValuePair.value)".addingPercentEncoding(withAllowedCharacters: .urlQueryParametersAllowed) {
                return current + ["\(keyValuePair.key)=\(encodedValue)"]
            } else {
                throw NSError(domain: Networking.domain, code: 0, userInfo: [NSLocalizedDescriptionKey: "Couldn't encode \(keyValuePair.value)"])
            }
        }

        let converted = pairs.joined(separator: "&")

        return converted
    }
}
