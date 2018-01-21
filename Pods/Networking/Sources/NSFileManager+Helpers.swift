import Foundation

extension FileManager {

    public func exists(at url: URL) -> Bool {
        let path = url.path

        return fileExists(atPath: path)
    }

    public func remove(at url: URL) throws {
        let path = url.path
        guard FileManager.default.isDeletableFile(atPath: url.path) else { return }

        try FileManager.default.removeItem(atPath: path)
    }
}
