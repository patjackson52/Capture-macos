# macOS release runbook (baseline)

This is the minimum operator runbook for baseline macOS release packaging.

## Preconditions

- `VERSION` file contains intended release version (for example `0.1.0`)
- For tag-triggered release, git tag must be `v<VERSION>` (for example `v0.1.0`)
- Signing/notarization credentials are managed separately
- Direct distribution + notarization scaffold/runbook is in `docs/distribution-prep-macos-direct-notarization.md`
- Release approval/rollout/rollback controls are in `docs/release-governance-checklist.md`

## Triggering releases

Two supported paths:

- Manual: GitHub Actions → **macOS Release** → **Run workflow**
- Tag push: push a tag matching `v*` (example: `v0.1.0`)

## What the workflow validates

- Fails fast if `VERSION` is empty
- Fails fast if tag/version mismatch is detected
- Builds release binary (`swift build -c release --product CaptureApp`)
- Packages release archive with metadata

## Artifacts and metadata

Expected uploaded artifact name:

- `capture-macos-release-<VERSION>`

Archive path generated during run:

- `build/capture-macos-release-<VERSION>.tar.gz`

Archive includes:

- `CaptureApp`
- `release-metadata.txt`
- `release-metadata.json`

Metadata captures version, ref, commit SHA, and workflow run identifiers.

## Retention

Release artifacts are retained for 30 days by default.
