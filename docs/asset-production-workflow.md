# Asset production workflow and release handoff responsibilities (macOS)

This workflow defines how Capture macOS listing assets and release evidence are produced and handed off for each distribution lane.

Machine-readable source of truth:
- `assets/required-asset-matrix.json`
- `assets/manifest.json`

## 1) Plan the release lane

Choose one lane:
- `app-store`
- `direct-notarized`

Then confirm required entries in `assets/required-asset-matrix.json`.

## 2) Produce lane assets

Design/marketing owners create source files under `assets/source/` and final exports under `assets/exports/`.

Validation gate:

```bash
scripts/check-assets-manifest.py
```

This verifies required placeholders and export dimensions (when export files are present).

## 3) Build handoff package skeleton (direct-notarized lane)

Generate a per-cycle package scaffold:

```bash
scripts/generate-notarization-handoff.sh
```

Optional overrides:

```bash
scripts/generate-notarization-handoff.sh --version 0.1.0 --cycle-id 20260225T020000Z
```

The script creates:
- `out/handoffs/notarization-<version>-<cycle-id>/artifacts/`
- `out/handoffs/notarization-<version>-<cycle-id>/evidence/`
- `out/handoffs/notarization-<version>-<cycle-id>/CHECKLIST.md`

`CHECKLIST.md` is generated from the direct-notarized lane in `assets/required-asset-matrix.json`.

## 4) Prepare localization metadata + captions

Fill locale templates:
- `assets/localization/app-store-metadata.template.json`
- `assets/localization/direct-listing-metadata.template.json`
- `assets/localization/screenshot-captions.template.json`
- `assets/localization/release-cycle-evidence.template.json`

Validate locale completeness and evidence requirements:

```bash
scripts/check-localization-readiness.py
```

Generate RC checklist markdown from the matrix/manifest:

```bash
scripts/generate-rc-asset-checklist.py --version 0.1.0 --cycle-id 20260225T020000Z
```

## 5) Fill and verify release evidence

Release owner populates package contents after signing/notarization:
- `artifacts/CaptureApp.zip`
- `artifacts/checksums.txt`
- `artifacts/release-metadata.json`
- `evidence/notarization-log.txt`
- `evidence/gatekeeper-assessment.txt`

Then run final validation using:

```bash
scripts/check-notarized-asset-package.sh <handoff-package-dir>
```

## Responsibility matrix (roles)

- **Design**
  - Produces App Store icon/screenshots and direct hero/OG exports
  - Confirms dimensions and visual QA
- **Marketing**
  - Produces direct-distribution press kit and one-sheet collateral
  - Confirms messaging consistency and publication readiness
- **Release**
  - Runs preflight and notarization cycle
  - Assembles package artifacts and checksums
  - Verifies checklist completion and signs off distribution handoff
- **QA**
  - Produces Gatekeeper assessment evidence on clean host
  - Verifies user-install path before publication

## Definition of done

A lane handoff is complete when:
1. All `requiredAssets` for that lane are available or explicitly waived.
2. All `requiredEvidence` entries are attached in the package.
3. Lane checklist (`CHECKLIST.md` or equivalent release ticket checklist) is fully checked.
4. Release owner records approval in release notes/change record.
