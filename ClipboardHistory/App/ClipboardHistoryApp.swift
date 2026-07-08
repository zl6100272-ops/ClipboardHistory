import SwiftUI

@main
struct ClipboardHistoryApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // Hidden window group keeps the app alive (required for menu bar apps)
        WindowGroup(id: "hidden") {
            Color.clear
                .frame(width: 0, height: 0)
                .hidden()
                .onAppear {
                    // Close this window immediately — we only need it to keep the process alive
                    if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == "hidden" }) {
                        window.close()
                    }
                }
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 0, height: 0)

        Settings {
            SettingsView(settings: appDelegate.settings)
        }
    }
}
