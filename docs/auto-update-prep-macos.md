# macOS auto-update prep checklist (Sparkle-ready)

This project currently ships direct distribution artifacts. This checklist prepares the repo and process for a future Sparkle-based auto-update channel without introducing secrets.

## Scope of this checklist

- No signing/notarization secret values are stored here
- No framework integration is performed yet
- Focus is process/readiness so implementation can happen cleanly

## 1) Release artifact prerequisites

- [ ] Continue producing deterministic versioned artifacts from CI
- [ ] Keep `VERSION` as single source of release version truth
- [ ] Preserve release metadata (`sha`, `run_id`, `run_attempt`) for auditability

## 2) Sparkle integration prerequisites

- [ ] Decide update feed URL host and retention policy
- [ ] Generate dedicated Sparkle EdDSA signing keypair on an operator machine
- [ ] Store Sparkle private key as an environment/repo secret (never in git)
- [ ] Add Sparkle public key (`SUPublicEDKey`) to app bundle configuration
- [ ] Define update channel policy (stable-only for v0.1.x)

## 3) CI/workflow prerequisites

- [ ] Add release workflow step to emit Sparkle appcast item metadata
- [ ] Add workflow guard that appcast version equals `VERSION`
- [ ] Publish signed appcast + release archive to immutable URLs
- [ ] Include checksum/signature verification in release summary

## 4) Governance and rollback

- [ ] Define rollback process for a bad update (appcast rollback + prior build restore)
- [ ] Document how update feed is paused in incident scenarios
- [ ] Ensure branch protection/required checks gate appcast publishing changes

## 5) First implementation readiness gate

Before implementing Sparkle, verify all are true:

- [ ] Direct distribution + notarization run has succeeded at least once
- [ ] Gatekeeper validation has been performed on a clean macOS host
- [ ] Release owner + backup owner for update keys are assigned
- [ ] Incident contact path for revoking/rotating update keys is documented
