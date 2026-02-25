# Assets scaffolding (macOS distribution)

This directory tracks listing and launch assets for both App Store and direct distribution.

## Layout

- `source/app-store/` — editable source files from design tools
- `exports/app-store/` — final files intended for App Store submission
- `exports/direct-distribution/` — website/OG/press-kit assets for direct channel
- `manifest.json` — required/recommended assets, formats, dimensions, and channels
- `manifest.schema.json` — schema contract for manifest structure

## Validation

Run:

```bash
scripts/check-assets-manifest.py
```

The checker validates manifest shape, enforces placeholder existence, and validates image dimensions when exports are present.
