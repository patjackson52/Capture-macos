import XCTest
@testable import CaptureApp

final class RepositoryTests: XCTestCase {
    func testSavesEntryAndAssetAndHandlesCollision() throws {
        let repo = CaptureRepository()
        let base = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)

        let now = ISO8601DateFormatter().date(from: "2026-02-21T20:00:00Z")!
        let draft = CaptureDraft(
            text: "hello",
            tags: ["Tag", "tag"],
            attachments: [AttachmentDraft(sourceURL: nil, imageData: Data([1,2,3]), fileExtension: "png", mimeType: "image/png")],
            source: .shortcutClipboard
        )

        let first = try repo.save(draft: draft, outputFolder: base, now: now)
        let second = try repo.save(draft: draft, outputFolder: base, now: now)

        XCTAssertTrue(FileManager.default.fileExists(atPath: first.entryURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: first.assetURLs[0].path))
        XCTAssertNotEqual(first.entryURL.lastPathComponent, second.entryURL.lastPathComponent)
    }
}
