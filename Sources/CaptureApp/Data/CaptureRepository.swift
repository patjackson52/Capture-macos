import Foundation

enum CaptureRepositoryError: Error, LocalizedError {
    case outputFolderUnavailable
    case emptyCapture

    var errorDescription: String? {
        switch self {
        case .outputFolderUnavailable: return "Output folder is not configured or unavailable."
        case .emptyCapture: return "Add text, tags, or attachments before saving."
        }
    }
}

struct SaveResult {
    let entryURL: URL
    let assetURLs: [URL]
}

final class CaptureRepository {
    private let serializer = AndroidParitySerializer()
    private let fileManager = FileManager.default

    func save(draft: CaptureDraft, outputFolder: URL, now: Date = Date()) throws -> SaveResult {
        let normalizedTags = draft.tags.normalizedTags()
        let text = draft.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty || !normalizedTags.isEmpty || !draft.attachments.isEmpty else {
            throw CaptureRepositoryError.emptyCapture
        }

        try fileManager.createDirectory(at: outputFolder, withIntermediateDirectories: true)
        let assetsDir = outputFolder.appendingPathComponent("assets", isDirectory: true)
        try fileManager.createDirectory(at: assetsDir, withIntermediateDirectories: true)

        var recordAttachments: [CaptureRecord.Attachment] = []
        var writtenAssets: [URL] = []
        for (idx, attachment) in draft.attachments.enumerated() {
            let filename = serializer.assetFilename(baseDate: now, index: idx + 1, fileExtension: attachment.fileExtension)
            let destination = uniqueAssetURL(base: assetsDir.appendingPathComponent(filename))
            if let data = attachment.imageData {
                try data.write(to: destination, options: .atomic)
            } else if let sourceURL = attachment.sourceURL {
                try fileManager.copyItem(at: sourceURL, to: destination)
            }
            let relativePath = "assets/\(destination.lastPathComponent)"
            recordAttachments.append(.init(mimeType: attachment.mimeType, relativePath: relativePath))
            writtenAssets.append(destination)
        }

        let record = CaptureRecord(
            id: UUID(),
            createdAt: now,
            updatedAt: now,
            text: text,
            tags: normalizedTags,
            attachments: recordAttachments,
            source: draft.source
        )

        let entryURL = uniqueEntryURL(base: outputFolder.appendingPathComponent(serializer.entryFilename(for: now)))
        try serializer.serialize(record: record).write(to: entryURL, options: .atomic)
        return SaveResult(entryURL: entryURL, assetURLs: writtenAssets)
    }

    private func uniqueEntryURL(base: URL) -> URL {
        uniqueURL(base: base)
    }

    private func uniqueAssetURL(base: URL) -> URL {
        uniqueURL(base: base)
    }

    private func uniqueURL(base: URL) -> URL {
        var candidate = base
        var attempt = 1
        while fileManager.fileExists(atPath: candidate.path) {
            let ext = base.pathExtension
            let stem = base.deletingPathExtension().lastPathComponent
            let parent = base.deletingLastPathComponent()
            candidate = parent.appendingPathComponent("\(stem)-\(attempt)").appendingPathExtension(ext)
            attempt += 1
        }
        return candidate
    }
}
