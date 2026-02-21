import Foundation

struct AndroidParitySerializer {
    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    func serialize(record: CaptureRecord) -> Data {
        let tags = record.tags.map { "  - \($0)" }.joined(separator: "\n")
        let attachments = record.attachments.map { attachment in
            "  - mimeType: \(attachment.mimeType)\n    path: \(attachment.relativePath)"
        }.joined(separator: "\n")

        let yaml = """
        ---
        id: \(record.id.uuidString)
        createdAt: \(Self.isoFormatter.string(from: record.createdAt))
        updatedAt: \(Self.isoFormatter.string(from: record.updatedAt))
        source: \(record.source.rawValue)
        tags:
        \(tags.isEmpty ? "  []" : tags)
        attachments:
        \(attachments.isEmpty ? "  []" : attachments)
        ---

        \(record.text)
        """
        return Data(yaml.utf8)
    }

    func entryFilename(for date: Date) -> String {
        Self.fileTimestamp(from: date) + ".md"
    }

    func assetFilename(baseDate: Date, index: Int, fileExtension: String) -> String {
        "\(Self.fileTimestamp(from: baseDate))-\(index).\(fileExtension)"
    }

    static func fileTimestamp(from date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyyMMdd-HHmmss"
        return f.string(from: date)
    }
}
