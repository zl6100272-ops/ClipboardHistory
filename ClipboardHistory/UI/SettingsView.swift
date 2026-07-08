import Carbon
import ServiceManagement
import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @State private var launchAtLoginError: String?

    var body: some View {
        Form {
            Toggle("暂停记录", isOn: $settings.isRecordingPaused)

            Toggle("开机自启动", isOn: Binding(
                get: { settings.launchAtLogin },
                set: updateLaunchAtLogin
            ))

            HotKeyPicker(
                title: "历史快捷键",
                keyCode: $settings.historyHotKeyKeyCode,
                modifiers: $settings.historyHotKeyModifiers
            )

            HotKeyPicker(
                title: "隐私模式快捷键",
                keyCode: $settings.privacyHotKeyKeyCode,
                modifiers: $settings.privacyHotKeyModifiers
            )

            if let launchAtLoginError {
                Text(launchAtLoginError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(20)
        .frame(width: 420)
    }

    private func updateLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            settings.launchAtLogin = enabled
            launchAtLoginError = nil
        } catch {
            launchAtLoginError = error.localizedDescription
        }
    }
}

private struct HotKeyPicker: View {
    let title: String
    @Binding var keyCode: UInt32
    @Binding var modifiers: UInt32

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
            HStack {
                Picker("修饰键", selection: $modifiers) {
                    Text("Command + Shift").tag(UInt32(cmdKey | shiftKey))
                    Text("Control + Option").tag(UInt32(controlKey | optionKey))
                    Text("Command + Option").tag(UInt32(cmdKey | optionKey))
                }
                .labelsHidden()

                Picker("按键", selection: $keyCode) {
                    Text("V").tag(UInt32(kVK_ANSI_V))
                    Text("P").tag(UInt32(kVK_ANSI_P))
                    Text("B").tag(UInt32(kVK_ANSI_B))
                    Text("Space").tag(UInt32(kVK_Space))
                }
                .labelsHidden()
            }
        }
    }
}
