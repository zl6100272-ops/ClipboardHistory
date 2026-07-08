import AppKit
import SwiftUI

final class FloatingWindowController {
    private let database: DatabaseManager
    private let pasteManager: PasteManager
    private var window: NSWindow?

    init(database: DatabaseManager, pasteManager: PasteManager) {
        self.database = database
        self.pasteManager = pasteManager
    }

    func toggleNearMouse() {
        if let window, window.isVisible {
            window.orderOut(nil)
            return
        }
        showNearMouse()
    }

    private func showNearMouse() {
        let content = ContentView(database: database) { [weak self] item in
            self?.window?.orderOut(nil)
            self?.pasteManager.paste(item)
        }

        let hosting = NSHostingController(rootView: content)
        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.level = .floating
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.contentViewController = hosting
        window.setFrameOrigin(originNearMouse(for: window.frame.size))
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        self.window = window
    }

    private func originNearMouse(for size: NSSize) -> NSPoint {
        let mouse = NSEvent.mouseLocation
        guard let screen = NSScreen.screens.first(where: { $0.frame.contains(mouse) }) ?? NSScreen.main else {
            return NSPoint(x: mouse.x, y: mouse.y - size.height)
        }

        let visible = screen.visibleFrame
        let x = min(max(mouse.x - size.width / 2, visible.minX + 12), visible.maxX - size.width - 12)
        let y = min(max(mouse.y - size.height - 12, visible.minY + 12), visible.maxY - size.height - 12)
        return NSPoint(x: x, y: y)
    }
}
