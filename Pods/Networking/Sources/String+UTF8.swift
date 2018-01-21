import Foundation

extension String {

    func encodeUTF8() -> String? {
        if let _ = URL(string: self) {
            return self
        }

        var components = self.components(separatedBy: "/")
        guard let lastComponent = components.popLast(),
            let endcodedLastComponent = lastComponent.addingPercentEncoding(withAllowedCharacters: .urlQueryParametersAllowed) else {
            return nil
        }

        return (components + [endcodedLastComponent]).joined(separator: "/")
    }
}
