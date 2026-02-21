import Foundation

struct AttachmentDraft: Identifiable, Equatable {
    let id: UUID
    var sourceURL: URL?
    var imageData: Data?
    var fileExtension: String
    var mimeType: String

    init(id: UUID = UUID(), sourceURL: URL? = nil, imageData: Data? = nil, fileExtension: String = "png", mimeType: String = "image/png") {
        self.id = id
        self.sourceURL = sourceURL
        self.imageData = imageData
        self.fileExtension = fileExtension
        self.mimeType = mimeType
    }
}

struct CaptureDraft: Equatable {
    var text: String
    var tags: [String]
    var attachments: [AttachmentDraft]
    var source: CaptureSource

    static let empty = CaptureDraft(text: "", tags: [], attachments: [], source: .manual)
}

enum CaptureSource: String {
    case shortcutClipboard
    case servicesSelection
    case manual
}

struct CaptureRecord: Equatable {
    struct Attachment: Equatable {
        var mimeType: String
        var relativePath: String
    }

    var id: UUID
    var createdAt: Date
    var updatedAt: Date
    var text: String
    var tags: [String]
    var attachments: [Attachment]
    var source: CaptureSource
}

extension Array where Element == String {
    func normalizedTags() -> [String] {
        var seen = Set<String>()
        var ordered: [String] = []
        for raw in self {
            let tag = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !tag.isEmpty, !seen.contains(tag) else { continue }
            seen.insert(tag)
            ordered.append(tag)
        }
        return ordered
    }
}
