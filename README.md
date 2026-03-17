# Capture (macOS)

Native macOS 14+ menu bar capture app built in Swift/SwiftUI.

## Implemented in this coder phase

- Swift Package scaffold for macOS app target (`CaptureApp`)
- Domain/data layer:
  - capture draft + attachment models
  - repository save pipeline
  - Android-parity serializer contract format (YAML front matter + markdown body)
  - timestamped filename generation and collision handling
  - attachment writing into `assets/`
- Capture UI:
  - text editor
  - tags input/chips with normalization + dedupe
  - attachment list add/remove
  - drag-and-drop file URL support
  - save state + inline errors
- Menu bar integration:
  - `NSStatusItem` menu with New Capture, Set Output Folder, Launch at Login, Quit
- Global shortcut + clipboard ingest:
  - default shortcut `⌘⌥C`
  - clipboard text + image ingestion when opening capture
- Services integration:
  - selected text handler routed into capture draft
- Settings:
  - output folder picker
  - security-scoped bookmark persistence
  - launch at login toggle via `SMAppService`
- Basic tests:
  - parity fixture tests (`text-only`, `attachment-only`, `mixed`)
  - repository save collision behavior

## Build

```bash
cd Capture-macos
swift build
```

## Test

```bash
cd Capture-macos
swift test
```

## Run

```bash
cd Capture-macos
swift run CaptureApp
```

## Output contract used currently

- Entry files: `<root>/yyyyMMdd-HHmmss(.n).md`
- Assets: `<root>/assets/yyyyMMdd-HHmmss-<index>(.n).<ext>`
- Markdown file format:
  - YAML front matter fields in fixed order: `id`, `createdAt`, `updatedAt`, `source`, `tags`, `attachments`
  - blank line
  - markdown body text

## Release/distribution docs

- Baseline runbook: `docs/release-runbook-basics.md`
- Direct distribution + notarization scaffold: `docs/distribution-prep-macos-direct-notarization.md`
- Signing prerequisites checklist: `docs/signing-prerequisites-macos.md`
- Auto-update prep checklist (Sparkle-ready): `docs/auto-update-prep-macos.md`
- Governance and rollback controls: `docs/release-governance-checklist.md`

## Notes

- This is aimed at personal/developer use for v0.1.0.
- Exact Android parity still depends on validating these fixtures against real Android output corpus.
