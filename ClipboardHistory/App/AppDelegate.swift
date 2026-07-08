import AppKit
import Carbon
import Combine
import SwiftUI
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate {
    let settings = AppSettings()

    private var database: DatabaseManager!
    private var fileStore: ClipboardFileManager!
    private var monitor: ClipboardMonitor!
    private var menuBar: MenuBarManager!
    private var shortcutManager: ShortcutManager!
    private var floatingWindow: FloatingWindowController!
    private var pasteManager: PasteManager!
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        do {
            database = try DatabaseManager()
            fileStore = try ClipboardFileManager()
            pasteManager = PasteManager(fileStore: fileStore)
            floatingWindow = FloatingWindowController(database: database, pasteManager: pasteManager)
            monitor = ClipboardMonitor(database: database, fileStore: fileStore, settings: settings)
            shortcutManager = ShortcutManager(settings: settings)
            menuBar = MenuBarManager(settings: settings)

            menuBar.onQuit = { NSApp.terminate(nil) }
            menuBar.onOpenSettings = {
                NSApp.activate(ignoringOtherApps: true)
                if #available(macOS 14, *) {
                    NSApp.sendAction(Selector(("showSettings:")), to: nil, from: nil)
                } else {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }
            }
            shortcutManager.onShowHistory = { [weak self] in self?.floatingWindow.toggleNearMouse() }
            shortcutManager.onToggleRecording = { [weak self] in self?.settings.isRecordingPaused.toggle() }
            observeHotKeyChanges()

            monitor.start()
            shortcutManager.start()
            requestAccessibilityPermissionIfNeeded()
            showWelcomeNotification()
        } catch {
            NSAlert(error: error).runModal()
            NSApp.terminate(nil)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        monitor?.stop()
        shortcutManager?.stop()
    }

    private func requestAccessibilityPermissionIfNeeded() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    private func showWelcomeNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "Clipboard History 已启动"
            content.body = "按 ⌘⇧V 查看剪贴板历史\n菜单栏图标 📋 可打开设置"
            content.sound = .default
            let request = UNNotificationRequest(
                identifier: "clipboard-welcome",
                content: content,
                trigger: nil
            )
            center.add(request)
        }
    }

    private func observeHotKeyChanges() {
        Publishers.MergeMany([
            settings.$historyHotKeyKeyCode.map { _ in () }.eraseToAnyPublisher(),
            settings.$historyHotKeyModifiers.map { _ in () }.eraseToAnyPublisher(),
            settings.$privacyHotKeyKeyCode.map { _ in () }.eraseToAnyPublisher(),
            settings.$privacyHotKeyModifiers.map { _ in () }.eraseToAnyPublisher()
        ])
        .dropFirst(4)
        .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
        .sink { [weak self] in self?.shortcutManager.reload() }
        .store(in: &cancellables)
    }
}

final class AppSettings: ObservableObject {
    @Published var isRecordingPaused: Bool {
        didSet { defaults.set(isRecordingPaused, forKey: Keys.isRecordingPaused) }
    }

    @Published var launchAtLogin: Bool {
        didSet { defaults.set(launchAtLogin, forKey: Keys.launchAtLogin) }
    }

    @Published var historyHotKeyKeyCode: UInt32 {
        didSet { defaults.set(Int(historyHotKeyKeyCode), forKey: Keys.historyHotKeyKeyCode) }
    }

    @Published var historyHotKeyModifiers: UInt32 {
        didSet { defaults.set(Int(historyHotKeyModifiers), forKey: Keys.historyHotKeyModifiers) }
    }

    @Published var privacyHotKeyKeyCode: UInt32 {
        didSet { defaults.set(Int(privacyHotKeyKeyCode), forKey: Keys.privacyHotKeyKeyCode) }
    }

    @Published var privacyHotKeyModifiers: UInt32 {
        didSet { defaults.set(Int(privacyHotKeyModifiers), forKey: Keys.privacyHotKeyModifiers) }
    }

    private let defaults = UserDefaults.standard

    init() {
        isRecordingPaused = defaults.bool(forKey: Keys.isRecordingPaused)
        launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
        historyHotKeyKeyCode = UInt32(defaults.object(forKey: Keys.historyHotKeyKeyCode) as? Int ?? kVK_ANSI_V)
        historyHotKeyModifiers = UInt32(defaults.object(forKey: Keys.historyHotKeyModifiers) as? Int ?? (cmdKey | shiftKey))
        privacyHotKeyKeyCode = UInt32(defaults.object(forKey: Keys.privacyHotKeyKeyCode) as? Int ?? kVK_ANSI_P)
        privacyHotKeyModifiers = UInt32(defaults.object(forKey: Keys.privacyHotKeyModifiers) as? Int ?? (cmdKey | shiftKey))
    }

    private enum Keys {
        static let isRecordingPaused = "isRecordingPaused"
        static let launchAtLogin = "launchAtLogin"
        static let historyHotKeyKeyCode = "historyHotKeyKeyCode"
        static let historyHotKeyModifiers = "historyHotKeyModifiers"
        static let privacyHotKeyKeyCode = "privacyHotKeyKeyCode"
        static let privacyHotKeyModifiers = "privacyHotKeyModifiers"
    }
}
