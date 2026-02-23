# macOS Signing & Notarization Prerequisites Checklist

Use this checklist before enabling full release signing/notarization in CI.

## 1) Apple Developer setup

- [ ] Active Apple Developer Program membership
- [ ] Apple Team ID identified and documented
- [ ] Access to Certificates, Identifiers & Profiles for the release owner

## 2) Developer ID certificate(s)

- [ ] Create/download **Developer ID Application** certificate
- [ ] Export certificate as `.p12` with strong password
- [ ] (Optional) Developer ID Installer certificate if distributing signed `.pkg`
- [ ] Store certificate export securely (password manager or secrets vault)

## 3) Notarization credentials

Choose one method (API key recommended for automation):

### Option A: App Store Connect API key (recommended)

- [ ] Create ASC API key with minimum required access
- [ ] Record Key ID, Issuer ID
- [ ] Export `.p8` key securely
- [ ] Confirm notarization tooling supports API key auth in pipeline

### Option B: Apple ID + app-specific password

- [ ] Dedicated Apple ID for automation (preferred)
- [ ] App-specific password created and stored securely
- [ ] Team ID available for notarization submission

## 4) CI secret mapping placeholders (GitHub Actions)

Current workflow (`.github/workflows/macos-distribution-notarize.yml`) is wired for **API key flow**.

Required repository/org secrets:

- `APPLE_TEAM_ID`
- `APPLE_DEVELOPER_ID_APP_CERT_BASE64` (base64-encoded `.p12`)
- `APPLE_DEVELOPER_ID_APP_CERT_PASSWORD`
- `APPLE_NOTARY_API_KEY_ID`
- `APPLE_NOTARY_API_ISSUER_ID`
- `APPLE_NOTARY_API_PRIVATE_KEY_BASE64` (base64-encoded `.p8`)

If you later switch to Apple ID flow, update both workflow and this checklist together to avoid drift.

## 5) Local validation before CI rollout

- [ ] Verify local code signing works with exported cert
- [ ] Verify local notarization submit/wait/staple flow works
- [ ] Confirm Gatekeeper validation passes on a clean macOS machine

## 6) Operational/security checks

- [ ] Restrict CI secrets to required repos/environments only
- [ ] Enable protected release branch/tag policies
- [ ] Document certificate rotation and incident response process
- [ ] Assign owner for release credential maintenance
