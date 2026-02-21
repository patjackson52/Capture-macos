import AppKit
import SwiftUI

@MainActor
final class CaptureWindowController {
    private var window: NSWindow?
    let viewModel: CaptureViewModel

    init(viewModel: CaptureViewModel) {
        self.viewModel = viewModel
    }

    func show(source: CaptureSource) {
        if window == nil {
            let view = CaptureView(viewModel: viewModel, source: source)
            let host = NSHostingController(rootView: view)
            let win = NSPanel(contentViewController: host)
            win.title = "Capture"
            win.setContentSize(NSSize(width: 560, height: 560))
            win.styleMask = [.titled, .closable, .miniaturizable, .resizable, .nonactivatingPanel]
            win.isFloatingPanel = false
            win.becomesKeyOnlyIfNeeded = false
            window = win
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    func close() {
        window?.close()
    }
}
