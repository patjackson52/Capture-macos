# First notarized distribution asset package (macOS)

Use this guide to produce and validate the first direct-distribution package after notarization is enabled.

## Package target layout

```text
out/notarized-package/
  CaptureApp.zip
  checksums.txt
  release-metadata.json
  notarization-log.txt
  gatekeeper-assessment.txt
  assets/
    og/capture-og-1200x630.png
    screenshots/direct-hero-01-1920x1080.png
    press-kit/capture-press-kit.zip
```

## 1) Preflight

Run before starting a release lane:

```bash
scripts/preflight-macos-distribution.sh
```

Checks include:
- `VERSION` presence
- signing/notary env var presence
- asset manifest integrity + placeholder scaffolding
- direct-distribution listing placeholder coverage

## 2) Materialize package payload

Expected data sources:
- `CaptureApp.zip`: signed + notarized app archive
- `notarization-log.txt`: notarytool submit/wait output including RequestUUID
- `gatekeeper-assessment.txt`: clean-host `spctl`/launch verification output
- direct distribution assets from `assets/exports/direct-distribution/`

Generate checksums:

```bash
cd out/notarized-package
shasum -a 256 CaptureApp.zip > checksums.txt
```

## 3) Validate package shape

```bash
scripts/check-notarized-asset-package.sh out/notarized-package
```

This verifies required files and checksum coverage for `CaptureApp.zip`.

## 4) Capture rollout evidence

Record release evidence using:

- `docs/rollout-evidence-template.md`

Store the completed template in your release ticket/change record.
