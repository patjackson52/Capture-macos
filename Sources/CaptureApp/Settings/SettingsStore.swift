import AppKit
import Foundation

final class SettingsStore {
    private enum Keys {
        static let outputFolderBookmark = "outputFolderBookmark"
    }

    private let defaults = UserDefaults.standard

    var outputFolderURL: URL? {
        guard let data = defaults.data(forKey: Keys.outputFolderBookmark) else { return nil }
        var stale = false
        do {
            let url = try URL(resolvingBookmarkData: data, options: [.withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &stale)
            if stale { setOutputFolder(url) }
            _ = url.startAccessingSecurityScopedResource()
            return url
        } catch {
            return nil
        }
    }

    func pickOutputFolder() {
        NSApp.activate(ignoringOtherApps: true)
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select"
        if panel.runModal() == .OK, let url = panel.url {
            setOutputFolder(url)
        }
    }

    private func setOutputFolder(_ url: URL) {
        if let data = try? url.bookmarkData(options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil) {
            defaults.set(data, forKey: Keys.outputFolderBookmark)
        }
    }
}
