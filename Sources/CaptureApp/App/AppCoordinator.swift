import Foundation

@MainActor
final class AppCoordinator {
    private let settings = SettingsStore()
    private let repository = CaptureRepository()
    private let clipboard = ClipboardIngestionService()
    private let launchAtLogin = LaunchAtLoginManager()

    private lazy var viewModel: CaptureViewModel = {
        let vm = CaptureViewModel(repository: repository, settings: settings)
        vm.onSaveSuccess = { [weak self] in self?.windowController.close() }
        return vm
    }()

    private lazy var windowController = CaptureWindowController(viewModel: viewModel)
    private lazy var menu = MenuBarController()
    private lazy var shortcut = GlobalShortcutService()
    private lazy var services = ServicesIngestionHandler()

    func start() {
        menu.onNewCapture = { [weak self] in self?.openCaptureFromClipboard() }
        menu.onPickFolder = { [weak self] in self?.settings.pickOutputFolder() }
        menu.onToggleLaunchAtLogin = { [weak self] in self?.launchAtLogin.toggle() }

        shortcut.onTrigger = { [weak self] in self?.openCaptureFromClipboard() }
        shortcut.registerDefaultShortcut()

        services.onSelectedText = { [weak self] text in
            self?.viewModel.setDraft(CaptureDraft(text: text, tags: [], attachments: [], source: .servicesSelection))
            self?.windowController.show(source: .servicesSelection)
        }
    }

    private func openCaptureFromClipboard() {
        let draft = clipboard.draftFromClipboard()
        viewModel.setDraft(draft)
        windowController.show(source: .shortcutClipboard)
    }
}
