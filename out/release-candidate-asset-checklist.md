# Release candidate asset checklist

- Generated (UTC): 2026-02-25T02:22:27Z
- Version: 0.1.0-alpha.1
- Cycle ID: 20260225T021900Z

## Localization readiness
- [ ] `en-US` copy reviewed for App Store + direct listing + captions
- [ ] `es-ES` copy reviewed for App Store + direct listing + captions

## Lane: App Store distribution (`app-store`)

### Required assets
- [ ] `app-store-icon-1024` (icon, owner: design)  channel: `app-store-listing` · export: `assets/exports/app-store/icons/app-store-icon-1024.png`
- [ ] `screenshot-13in-01` (screenshot, owner: design)  channel: `app-store-listing` · export: `assets/exports/app-store/screenshots/mac-13/mac-13-01-1280x800.png`
- [ ] `screenshot-13in-02` (screenshot, owner: design)  channel: `app-store-listing` · export: `assets/exports/app-store/screenshots/mac-13/mac-13-02-1280x800.png`

### Required evidence
- [ ] `appstore-metadata-export` (owner: release) · `handoff/evidence/app-store-connect-metadata.md`
- [ ] `appstore-review-notes` (owner: release) · `handoff/evidence/review-notes.md`

## Lane: Direct distribution + notarization (`direct-notarized`)

### Required assets
- [ ] `direct-download-icon-512` (icon, owner: design)  channel: `direct-distribution-listing` · export: `assets/exports/direct-distribution/icons/direct-download-icon-512.png`
- [ ] `direct-hero-screenshot-01` (screenshot, owner: design)  channel: `direct-distribution-listing` · export: `assets/exports/direct-distribution/screenshots/direct-hero-01-1920x1080.png`
- [ ] `direct-og-image-1200x630` (open-graph, owner: design)  channel: `direct-distribution-listing` · export: `assets/exports/direct-distribution/og/capture-og-1200x630.png`
- [ ] `direct-press-kit-zip` (press-kit, owner: marketing)  channel: `direct-distribution-listing` · export: `assets/exports/direct-distribution/press-kit/capture-press-kit.zip`

### Required evidence
- [ ] `signed-notarized-zip` (owner: release) · `handoff/artifacts/CaptureApp.zip`
- [ ] `checksums` (owner: release) · `handoff/artifacts/checksums.txt`
- [ ] `release-metadata` (owner: release) · `handoff/artifacts/release-metadata.json`
- [ ] `notarization-log` (owner: release) · `handoff/evidence/notarization-log.txt`
- [ ] `gatekeeper-assessment` (owner: qa) · `handoff/evidence/gatekeeper-assessment.txt`

