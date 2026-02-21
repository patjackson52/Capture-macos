import AppKit
import Foundation

struct ClipboardIngestionService {
    func draftFromClipboard() -> CaptureDraft {
        let pb = NSPasteboard.general
        var text = ""
        var attachments: [AttachmentDraft] = []

        if let s = pb.string(forType: .string) {
            text = s
        }
        if let tiff = pb.data(forType: .tiff), let bitmap = NSBitmapImageRep(data: tiff), let png = bitmap.representation(using: .png, properties: [:]) {
            attachments.append(AttachmentDraft(sourceURL: nil, imageData: png, fileExtension: "png", mimeType: "image/png"))
        }

        return CaptureDraft(text: text, tags: [], attachments: attachments, source: .shortcutClipboard)
    }
}
