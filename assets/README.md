# Assets scaffolding (macOS / App Store)

This directory tracks App Store-ready visual assets and placeholders.

## Layout

- `source/app-store/` — editable source files from design tools
- `exports/app-store/` — final files intended for submission
- `manifest.json` — required/recommended assets, formats, and dimensions

## Validation

Run:

```bash
scripts/check-assets-manifest.py
```

The checker enforces placeholder existence and validates real image dimensions when exports are present.
