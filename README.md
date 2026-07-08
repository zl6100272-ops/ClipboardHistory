# ClipboardHistory

macOS native clipboard history tool inspired by Windows `Win+V`.

## What is implemented

- Menu bar app with no Dock icon intent (`LSUIElement=true` in `ClipboardHistory/Info.plist`).
- Polls `NSPasteboard.changeCount` every 0.5 seconds.
- Records text, images, and file references.
- Stores metadata in SQLite via GRDB.
- Stores images under `~/Library/Caches/com.clipboard-history/images/`.
- Keeps the latest 100 records.
- `Command + Shift + V` floating history window.
- Search plus type filter for all/text/image/file.
- Click-to-paste using pasteboard write plus simulated `Command + V`.
- Privacy mode from the menu bar and `Command + Shift + P`.
- Settings view with launch-at-login toggle and simple hotkey customization.

## Open in Xcode

This repository is a Swift Package because the current environment cannot run Xcode to generate a real `.xcodeproj`.

On macOS:

```sh
cd /tmp/ClipboardHistory
open Package.swift
```

In Xcode, set the executable target's custom Info.plist to `ClipboardHistory/Info.plist` so `LSUIElement=true` is used for the built app.

## Permissions

The app prompts for Accessibility permission on first launch. Accessibility is required for simulated paste via `CGEventPost`.

If global hotkeys or paste do not work:

1. Open System Settings.
2. Go to Privacy & Security.
3. Enable Accessibility for ClipboardHistory.

## Notes

- App Sandbox should be disabled unless file access entitlements are added.
- `SMAppService.mainApp` requires a signed app bundle for production-quality launch-at-login behavior.
- The Linux container used to create this project does not include Swift or macOS frameworks, so compile verification must be done in Xcode on macOS.
