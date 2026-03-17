# macOS direct distribution + notarization prep (Phase 2 scaffold)

This document captures the non-secret workflow scaffolding and validation path for direct macOS distribution with notarization.

## Required secrets (fail-fast enforced in workflow)

- `APPLE_TEAM_ID`
- `APPLE_DEVELOPER_ID_APP_CERT_BASE64` (base64 `.p12`)
- `APPLE_DEVELOPER_ID_APP_CERT_PASSWORD`
- `APPLE_NOTARY_API_KEY_ID`
- `APPLE_NOTARY_API_ISSUER_ID`
- `APPLE_NOTARY_API_PRIVATE_KEY_BASE64` (base64 `.p8`)

> Workflow: `.github/workflows/macos-distribution-notarize.yml`

## Trigger paths

- Manual: **macOS Direct Distribution + Notarization (scaffold)** via `workflow_dispatch`
- Tag push: `v*` (notarization submission executes on tag runs)

## Validation behavior

The workflow fails immediately when:

- `VERSION` is empty
- tag version and `VERSION` do not match
- any required distribution secret is missing
- build/package output is missing

## Safe scaffold mode (default)

`notarize_enabled` defaults to `false` for manual runs.

In scaffold mode, the workflow:

1. validates configuration/secrets
2. builds release binary
3. materializes keychain/certificate and notary key placeholders
4. packages `build/CaptureApp.zip`
5. uploads artifact `capture-macos-direct-distribution-<VERSION>`
6. skips notarization submission

## Enabling notarization

For manual run, set `notarize_enabled=true`.

For tag push (`v*`), notarization submission executes automatically after validation/build.

## Local preflight helper

Use `scripts/release/notarization-preflight.sh` to validate required environment variables and `VERSION` before triggering CI:

```bash
export APPLE_TEAM_ID=... # and other required values
scripts/release/notarization-preflight.sh
```

This check is non-destructive and mirrors the workflow fail-fast expectations.

## Operator validation checklist

- [ ] Required secrets are configured with least privilege access
- [ ] Local preflight helper passes (`scripts/release/notarization-preflight.sh`)
- [ ] Manual scaffold run succeeds from `workflow_dispatch`
- [ ] First notarization run succeeds with `notarize_enabled=true`
- [ ] Notarization ticket status is accepted and logged
- [ ] Signed/notarized binary passes Gatekeeper validation on clean macOS host
