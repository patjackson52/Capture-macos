# macOS listing assets readiness

This checklist tracks visual asset readiness for App Store and direct distribution channels.

## Required baseline assets

### App Store listing

- App icon: `1024x1024 PNG`
- 13-inch class screenshots: at least 2 (`1280x800` scaffolded)

### Direct distribution listing

- Download/listing icon: `512x512 PNG`
- Hero screenshot: `1920x1080 PNG`
- Open Graph image: `1200x630 PNG`
- Press kit ZIP: `capture-press-kit.zip`

## Scaffold paths

- Manifest: `assets/manifest.json`
- Manifest schema: `assets/manifest.schema.json`
- Lane requirement matrix: `assets/required-asset-matrix.json`
- Source design files: `assets/source/app-store/`
- Export files: `assets/exports/app-store/`, `assets/exports/direct-distribution/`
- Validation script: `scripts/check-assets-manifest.py`

## Validation

```bash
scripts/check-assets-manifest.py
```

Behavior:
- Fails when manifest contract or placeholder scaffolding is missing
- Warns when final exports are not yet produced
- Validates dimensions for PNG/JPEG assets when present

## Human/design-owned work remaining

- Final icon/screenshot/OG artwork
- Capture session execution + screenshot selection
- Press kit ZIP composition and review
- Listing copy/localization polish
