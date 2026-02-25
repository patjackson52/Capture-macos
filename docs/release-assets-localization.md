# Release asset localization + RC checklist flow

This document defines how to prepare localized listing copy/captions and validate release-cycle evidence before publish.

## 1) Fill localization templates

Start from:

- `assets/localization/app-store-metadata.template.json`
- `assets/localization/direct-listing-metadata.template.json`
- `assets/localization/screenshot-captions.template.json`
- `assets/localization/release-cycle-evidence.template.json`

Keep locale keys aligned across all templates (for example: `en-US`, `es-ES`).

## 2) Validate localization completeness + evidence contract

```bash
scripts/check-localization-readiness.py
```

The check enforces:

- required copy fields per locale (App Store + direct listing)
- screenshot caption coverage for required screenshot assets in `assets/manifest.json`
- required evidence entries for each lane in `assets/required-asset-matrix.json`

## 3) Generate release candidate checklist markdown

```bash
scripts/generate-rc-asset-checklist.py --version 0.1.0 --cycle-id 20260225T021900Z
```

Default output:

- `out/release-candidate-asset-checklist.md`

The generated checklist includes lane-by-lane required assets/evidence plus localization review rows per locale.
