import AppKit
import Foundation

final class ClipboardMonitor {
    private let pasteboard = NSPasteboard.general
    private let database: DatabaseManager
    private let fileStore: ClipboardFileManager
    private let settings: AppSettings
    private let queue = DispatchQueue(label: "clipboard-history.monitor", qos: .utility)

    private var timer: Timer?
    private var lastChangeCount: Int
    private var lastFingerprint = ""

    init(database: DatabaseManager, fileStore: ClipboardFileManager, settings: AppSettings) {
        self.database = database
        self.fileStore = fileStore
        self.settings = settings
        self.lastChangeCount = pasteboard.changeCount
    }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.poll()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func poll() {
        guard !settings.isRecordingPaused else {
            lastChangeCount = pasteboard.changeCount
            return
        }

        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        let snapshot = ClipboardSnapshot(pasteboard: pasteboard)
        queue.async { [weak self] in
            self?.persist(snapshot)
        }
    }

    private func persist(_ snapshot: ClipboardSnapshot) {
        do {
            guard let item = try snapshot.makeItem(fileStore: fileStore) else { return }
            let fingerprint = "\(item.type.rawValue):\(item.content)"
            guard fingerprint != lastFingerprint else { return }

            if let recent = try database.mostRecent(), recent.type == item.type, recent.content == item.content {
                lastFingerprint = fingerprint
                return
            }

            try database.insert(item)
            lastFingerprint = fingerprint
        } catch {
            NSLog("Clipboard history persist failed: \(error.localizedDescription)")
        }
    }
}

private struct ClipboardSnapshot {
    let string: String?
    let fileURLs: [URL]
    let image: NSImage?

    init(pasteboard: NSPasteboard) {
        string = pasteboard.string(forType: .string)
        fileURLs = pasteboard.readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) as? [URL] ?? []

        if let data = pasteboard.data(forType: .png) ?? pasteboard.data(forType: .tiff) {
            image = NSImage(data: data)
        } else {
            image = nil
        }
    }

    func makeItem(fileStore: ClipboardFileManager) throws -> ClipboardItem? {
        if let image {
            let paths = try fileStore.saveImage(image)
            return ClipboardItem(id: nil, type: .image, content: paths.imagePath, thumbnailPath: paths.thumbnailPath, createdAt: Date())
        }

        if !fileURLs.isEmpty {
            return ClipboardItem(id: nil, type: .file, content: fileURLs.map(\.path).joined(separator: "\n"), thumbnailPath: nil, createdAt: Date())
        }

        if let string, !string.isEmpty {
            return ClipboardItem(id: nil, type: .text, content: string, thumbnailPath: nil, createdAt: Date())
        }

        return nil
    }
}
