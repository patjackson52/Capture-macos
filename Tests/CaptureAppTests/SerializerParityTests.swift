import XCTest
@testable import CaptureApp

final class SerializerParityTests: XCTestCase {
    let fixtureDate = ISO8601DateFormatter().date(from: "2026-02-21T20:00:00Z")!

    func testTextOnlyFixtureParity() throws {
        let record = CaptureRecord(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            createdAt: fixtureDate,
            updatedAt: fixtureDate,
            text: "hello world",
            tags: ["alpha", "beta"],
            attachments: [],
            source: .shortcutClipboard
        )

        try assertParity(record: record, fixture: "text-only.expected")
    }

    func testAttachmentOnlyFixtureParity() throws {
        let record = CaptureRecord(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            createdAt: fixtureDate,
            updatedAt: fixtureDate,
            text: "",
            tags: [],
            attachments: [.init(mimeType: "image/png", relativePath: "assets/20260221-200000-1.png")],
            source: .shortcutClipboard
        )

        try assertParity(record: record, fixture: "attachment-only.expected")
    }

    func testMixedFixtureParity() throws {
        let record = CaptureRecord(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
            createdAt: fixtureDate,
            updatedAt: fixtureDate,
            text: "mixed note",
            tags: ["inbox"],
            attachments: [.init(mimeType: "image/png", relativePath: "assets/20260221-200000-1.png")],
            source: .servicesSelection
        )

        try assertParity(record: record, fixture: "mixed.expected")
    }

    private func assertParity(record: CaptureRecord, fixture: String, file: StaticString = #filePath, line: UInt = #line) throws {
        let serializer = AndroidParitySerializer()
        let data = serializer.serialize(record: record)
        let produced = String(decoding: data, as: UTF8.self)
        let expectedURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures")
            .appendingPathComponent("\(fixture).md")
        let expected = try String(contentsOf: expectedURL)
        XCTAssertEqual(produced, expected, file: file, line: line)
    }
}
