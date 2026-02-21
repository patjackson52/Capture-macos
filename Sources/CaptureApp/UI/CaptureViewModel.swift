import AppKit
import Combine
import Foundation

@MainActor
final class CaptureViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var tagsText: String = ""
    @Published var tags: [String] = []
    @Published var attachments: [AttachmentDraft] = []
    @Published var isSaving = false
    @Published var errorMessage: String?

    var onSaveSuccess: (() -> Void)?

    private let repository: CaptureRepository
    private let settings: SettingsStore

    init(repository: CaptureRepository, settings: SettingsStore) {
        self.repository = repository
        self.settings = settings
    }

    var canSave: Bool {
        !isSaving && (!text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !tags.isEmpty || !attachments.isEmpty)
    }

    func setDraft(_ draft: CaptureDraft) {
        text = draft.text
        tags = draft.tags.normalizedTags()
        tagsText = ""
        attachments = draft.attachments
        errorMessage = nil
    }

    func appendTagFromInput() {
        let additions = tagsText.split(separator: ",").map(String.init)
        tags = (tags + additions).normalizedTags()
        tagsText = ""
    }

    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }

    func addAttachments(from urls: [URL]) {
        for url in urls {
            attachments.append(AttachmentDraft(sourceURL: url, fileExtension: url.pathExtension.isEmpty ? "png" : url.pathExtension.lowercased()))
        }
    }

    func removeAttachment(id: UUID) {
        attachments.removeAll { $0.id == id }
    }

    func save(source: CaptureSource) {
        guard let folder = settings.outputFolderURL else {
            errorMessage = "Choose an output folder first from menu bar settings."
            return
        }
        isSaving = true
        errorMessage = nil
        do {
            _ = try repository.save(draft: CaptureDraft(text: text, tags: tags, attachments: attachments, source: source), outputFolder: folder)
            isSaving = false
            onSaveSuccess?()
        } catch {
            isSaving = false
            errorMessage = error.localizedDescription
        }
    }
}
