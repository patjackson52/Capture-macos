import SwiftUI

struct CaptureView: View {
    @ObservedObject var viewModel: CaptureViewModel
    var source: CaptureSource

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Capture")
                .font(.title2).bold()

            TextEditor(text: $viewModel.text)
                .frame(minHeight: 120)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))

            HStack {
                TextField("tags (comma separated)", text: $viewModel.tagsText)
                    .onSubmit { viewModel.appendTagFromInput() }
                Button("Add") { viewModel.appendTagFromInput() }
            }

            ScrollView(.horizontal) {
                HStack {
                    ForEach(viewModel.tags, id: \.self) { tag in
                        HStack(spacing: 6) {
                            Text("#\(tag)")
                            Button("✕") { viewModel.removeTag(tag) }.buttonStyle(.plain)
                        }
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Capsule().fill(Color.blue.opacity(0.15)))
                    }
                }
            }

            Text("Attachments: \(viewModel.attachments.count)")
            List {
                ForEach(viewModel.attachments) { a in
                    HStack {
                        Text(a.sourceURL?.lastPathComponent ?? "clipboard-image.\(a.fileExtension)")
                        Spacer()
                        Button("Remove") { viewModel.removeAttachment(id: a.id) }
                    }
                }
            }
            .frame(height: 120)

            if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(.red)
            }

            HStack {
                Spacer()
                Button("Save") { viewModel.save(source: source) }
                    .keyboardShortcut(.return, modifiers: [.command])
                    .disabled(!viewModel.canSave)
            }
        }
        .padding()
        .frame(minWidth: 500, minHeight: 500)
        .onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
            let group = DispatchGroup()
            var urls: [URL] = []
            for p in providers {
                group.enter()
                _ = p.loadObject(ofClass: URL.self) { url, _ in
                    if let url { urls.append(url) }
                    group.leave()
                }
            }
            group.notify(queue: .main) { viewModel.addAttachments(from: urls) }
            return true
        }
    }
}
