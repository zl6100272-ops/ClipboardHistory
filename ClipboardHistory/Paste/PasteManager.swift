import AppKit
import Carbon
import Foundation

final class PasteManager {
    private let fileStore: ClipboardFileManager

    init(fileStore: ClipboardFileManager) {
        self.fileStore = fileStore
    }

    func paste(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        switch item.type {
        case .text:
            pasteboard.setString(item.content, forType: .string)
        case .file:
            let urls = item.content
                .split(separator: "\n")
                .map { URL(fileURLWithPath: String($0)) as NSURL }
            pasteboard.writeObjects(urls)
        case .image:
            if let image = fileStore.image(at: item.content) {
                pasteboard.writeObjects([image])
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.sendCommandV()
        }
    }

    private func sendCommandV() {
        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_ANSI_V), keyDown: false)
        keyDown?.flags = .maskCommand
        keyUp?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
}
