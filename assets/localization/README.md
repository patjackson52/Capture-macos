# Localization templates (listing metadata + captions)

Use these templates to prepare release-candidate copy across locales:

- `app-store-metadata.template.json` — App Store Connect listing copy
- `direct-listing-metadata.template.json` — direct distribution listing copy
- `screenshot-captions.template.json` — locale-specific screenshot captions
- `release-cycle-evidence.template.json` — release-cycle evidence tracking scaffold

## Validation

```bash
scripts/check-localization-readiness.py
```

This validates locale completeness and required evidence entries against `assets/required-asset-matrix.json`.
