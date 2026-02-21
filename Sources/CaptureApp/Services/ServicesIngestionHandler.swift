import AppKit

@MainActor
final class ServicesIngestionHandler: NSObject {
    var onSelectedText: ((String) -> Void)?

    override init() {
        super.init()
        NSApp.servicesProvider = self
    }

    @objc func captureSelectedText(_ pboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString>) {
        if let text = pboard.string(forType: .string) {
            onSelectedText?(text)
        }
    }
}
