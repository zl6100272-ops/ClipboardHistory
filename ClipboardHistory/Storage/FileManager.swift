import AppKit
import Foundation

final class ClipboardFileManager {
    let imageCacheDirectory: URL

    init() throws {
        imageCacheDirectory = try FileManager.default.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("com.clipboard-history/images", isDirectory: true)

        try FileManager.default.createDirectory(at: imageCacheDirectory, withIntermediateDirectories: true, attributes: nil)
    }

    func saveImage(_ image: NSImage) throws -> (imagePath: String, thumbnailPath: String?) {
        let id = UUID().uuidString
        let imageURL = imageCacheDirectory.appendingPathComponent("\(id).png")
        let thumbnailURL = imageCacheDirectory.appendingPathComponent("\(id)-thumb.png")

        guard let pngData = image.pngData() else {
            throw CocoaError(.fileWriteUnknown)
        }

        try pngData.write(to: imageURL, options: .atomic)

        if let thumbnailData = image.resized(maxPixelSize: 200).pngData() {
            try thumbnailData.write(to: thumbnailURL, options: .atomic)
            return (imageURL.path, thumbnailURL.path)
        }

        return (imageURL.path, nil)
    }

    func image(at path: String) -> NSImage? {
        NSImage(contentsOfFile: path)
    }
}

private extension NSImage {
    func pngData() -> Data? {
        guard
            let tiff = tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiff)
        else { return nil }

        return bitmap.representation(using: .png, properties: [:])
    }

    func resized(maxPixelSize: CGFloat) -> NSImage {
        let ratio = min(maxPixelSize / size.width, maxPixelSize / size.height, 1)
        let targetSize = NSSize(width: size.width * ratio, height: size.height * ratio)
        let image = NSImage(size: targetSize)
        image.lockFocus()
        draw(in: NSRect(origin: .zero, size: targetSize), from: .zero, operation: .copy, fraction: 1)
        image.unlockFocus()
        return image
    }
}
