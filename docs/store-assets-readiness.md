# macOS App Store assets readiness

This checklist tracks icon/screenshot readiness for App Store submission.

## Required baseline assets

- App icon: `1024x1024 PNG`
- 13-inch class screenshots: at least 2 (`1280x800` scaffolded)

## Scaffold paths

- Manifest: `assets/manifest.json`
- Source design files: `assets/source/app-store/`
- Export files: `assets/exports/app-store/`
- Validation script: `scripts/check-assets-manifest.py`

## Validation

```bash
scripts/check-assets-manifest.py
```

Behavior:
- Fails when placeholder scaffolding is missing
- Warns when final exports are not yet produced
- Validates dimensions for PNG/JPEG assets when present

## Human/design-owned work remaining

- Final icon and screenshot artwork
- Capture session execution + screenshot selection
- Store listing copy/localization polish
