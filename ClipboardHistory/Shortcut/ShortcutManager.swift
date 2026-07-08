import Carbon
import Foundation

final class ShortcutManager {
    var onShowHistory: (() -> Void)?
    var onToggleRecording: (() -> Void)?

    private let settings: AppSettings
    private var historyHotKey: EventHotKeyRef?
    private var privacyHotKey: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?

    init(settings: AppSettings) {
        self.settings = settings
    }

    func start() {
        installHandler()
        registerHotKeys()
    }

    func stop() {
        if let historyHotKey { UnregisterEventHotKey(historyHotKey) }
        if let privacyHotKey { UnregisterEventHotKey(privacyHotKey) }
        if let eventHandler { RemoveEventHandler(eventHandler) }
    }

    func reload() {
        stop()
        start()
    }

    private func installHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let callback: EventHandlerUPP = { _, event, userData in
            guard
                let userData,
                let event
            else { return noErr }

            var hotKeyID = EventHotKeyID()
            GetEventParameter(
                event,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotKeyID
            )

            let manager = Unmanaged<ShortcutManager>.fromOpaque(userData).takeUnretainedValue()
            DispatchQueue.main.async {
                switch hotKeyID.id {
                case 1: manager.onShowHistory?()
                case 2: manager.onToggleRecording?()
                default: break
                }
            }
            return noErr
        }

        InstallEventHandler(
            GetApplicationEventTarget(),
            callback,
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )
    }

    private func registerHotKeys() {
        var historyID = EventHotKeyID(signature: OSType("CHST".fourCharCode), id: 1)
        RegisterEventHotKey(
            settings.historyHotKeyKeyCode,
            settings.historyHotKeyModifiers,
            historyID,
            GetApplicationEventTarget(),
            0,
            &historyHotKey
        )

        var privacyID = EventHotKeyID(signature: OSType("CHST".fourCharCode), id: 2)
        RegisterEventHotKey(
            settings.privacyHotKeyKeyCode,
            settings.privacyHotKeyModifiers,
            privacyID,
            GetApplicationEventTarget(),
            0,
            &privacyHotKey
        )
    }
}

private extension String {
    var fourCharCode: FourCharCode {
        utf8.reduce(0) { ($0 << 8) + FourCharCode($1) }
    }
}
