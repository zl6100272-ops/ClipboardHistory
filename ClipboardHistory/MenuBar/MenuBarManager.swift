import AppKit
import Combine
import SwiftUI

final class MenuBarManager {
    var onQuit: (() -> Void)?
    var onOpenSettings: (() -> Void)?

    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let settings: AppSettings
    private var cancellables = Set<AnyCancellable>()

    init(settings: AppSettings) {
        self.settings = settings
        configureMenu()
        updateIcon()

        settings.objectWillChange
            .sink { [weak self] _ in DispatchQueue.main.async { self?.updateIcon() } }
            .store(in: &cancellables)
    }

    private func configureMenu() {
        let menu = NSMenu()

        let pauseItem = NSMenuItem(title: "暂停记录", action: #selector(toggleRecording), keyEquivalent: "")
        pauseItem.target = self
        menu.addItem(pauseItem)

        let settingsItem = NSMenuItem(title: "设置...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        item.menu = menu
    }

    private func updateIcon() {
        guard let button = item.button else { return }
        // Use clipboard icon — more visible than paperclip
        let image = NSImage(systemSymbolName: "clipboard", accessibilityDescription: "Clipboard History")
        if let image {
            // Create a template image that adapts to light/dark mode
            image.isTemplate = true
            button.image = image
        } else {
            // Fallback: use plain text
            button.title = "📋"
        }
        button.contentTintColor = settings.isRecordingPaused ? .disabledControlTextColor : .labelColor

        if let pauseItem = item.menu?.items.first {
            pauseItem.title = settings.isRecordingPaused ? "恢复记录" : "暂停记录"
        }
    }

    @objc private func toggleRecording() {
        settings.isRecordingPaused.toggle()
        updateIcon()
    }

    @objc private func openSettings() {
        onOpenSettings?()
    }

    @objc private func quit() {
        onQuit?()
    }
}
