# Rollout evidence template (macOS distribution cycle)

Use this template per release candidate to capture evidence required for staged rollout and rollback readiness.

## Release identity

- Release version:
- Git commit SHA:
- Build timestamp (UTC):
- Operator:
- Distribution channel(s): App Store / Direct / Both

## Notarization + signing evidence (direct distribution)

- Apple Team ID used:
- Developer ID cert fingerprint (last 8):
- notarytool submission RequestUUID:
- Notarization status (Accepted/Invalid):
- Notarization completion timestamp (UTC):
- Staple verification command + output snippet:
- Gatekeeper (`spctl`) assessment output snippet:

## Distribution asset package evidence

- Package directory or artifact URL:
- `CaptureApp.zip` SHA-256:
- `checksums.txt` attached: yes/no
- `release-metadata.json` attached: yes/no
- `notarization-log.txt` attached: yes/no
- `gatekeeper-assessment.txt` attached: yes/no

## Listing/marketing asset evidence

- App icon finalized: yes/no
- App Store screenshots finalized: yes/no
- Direct listing screenshot finalized: yes/no
- Open Graph image finalized: yes/no
- Press kit ZIP finalized: yes/no
- Asset manifest check command + result:

## Staged rollout execution log

- Stage 0 (internal) start/end + outcome:
- Stage 1 (trusted external) start/end + outcome:
- Stage 2 (broad rollout) start/end + outcome:
- Key quality metrics observed (crash-free, launch success, install success):

## Approval and rollback readiness

- Engineering approval reference:
- QA approval reference:
- Product/release approval reference:
- Rollback owner + contact:
- Last known good version + artifact link:
- Any incident notes / follow-up actions:
