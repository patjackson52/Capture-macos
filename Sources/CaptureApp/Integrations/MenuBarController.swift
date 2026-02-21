import AppKit

@MainActor
final class MenuBarController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var onNewCapture: (() -> Void)?
    var onPickFolder: (() -> Void)?
    var onToggleLaunchAtLogin: (() -> Void)?

    init() {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "tray.and.arrow.down.fill", accessibilityDescription: "Capture")
        }
        let menu = NSMenu()
        menu.addItem(withTitle: "New Capture", action: #selector(newCapture), keyEquivalent: "n").target = self
        menu.addItem(withTitle: "Set Output Folder…", action: #selector(pickFolder), keyEquivalent: "o").target = self
        menu.addItem(withTitle: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "l").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "q").target = self
        statusItem.menu = menu
    }

    @objc private func newCapture() { onNewCapture?() }
    @objc private func pickFolder() { onPickFolder?() }
    @objc private func toggleLaunchAtLogin() { onToggleLaunchAtLogin?() }
    @objc private func quit() { NSApp.terminate(nil) }
}
