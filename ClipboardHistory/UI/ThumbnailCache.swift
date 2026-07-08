import AppKit
import Foundation

final class ThumbnailCache {
    static let shared = ThumbnailCache()

    private let cache = NSCache<NSString, NSImage>()
    private let queue = DispatchQueue(label: "clipboard-history.thumbnail-cache", qos: .utility)

    func image(path: String, completion: @escaping (NSImage?) -> Void) {
        if let image = cache.object(forKey: path as NSString) {
            completion(image)
            return
        }

        queue.async { [cache] in
            let image = NSImage(contentsOfFile: path)
            if let image {
                cache.setObject(image, forKey: path as NSString)
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
