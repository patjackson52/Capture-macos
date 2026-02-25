# Capture macOS — Live Status

**Last updated (UTC):** 2026-02-25 02:16 UTC

## App Factory Phases
1. ✅ **Research & requirements** — Completed
2. ✅ **Architecture & technical design** — Completed
3. ✅ **MVP implementation** — Completed (coder phase baseline shipped)
4. ✅ **Core integrations** — Completed (menu bar, shortcut, clipboard, services, settings)
5. 🔄 **QA, polish, and release prep** — In progress (requires macOS runtime validation + Android fixture confirmation)

## Current blockers / decisions needed
- Validate and adjust serializer against **actual Android output corpus** (if any field/name/newline drift is found).
- Perform macOS runtime validation on Patrick’s MacBook Pro node (shortcut registration, Services invocation, launch-at-login behavior).

## Resolved decisions
- Format parity target: Android actual output behavior (`DECISIONS.md`).
- Distribution for v0.1.0: personal/developer use only (`DECISIONS.md`).

## Next action
- Execute first end-to-end notarized distribution cycle from tag (`v<VERSION>`) and validate Gatekeeper on a clean host.
- Run runtime validation on macOS node and reconcile any parity deltas from real Android fixtures.

## Changelog
- 2026-02-21 — Coder M1 complete: scaffolded native Swift/SwiftUI package + app shell + README stub.
- 2026-02-21 — Coder M2 complete: models/repository/serializer, file + asset writing, collision handling.
- 2026-02-21 — Coder M3 complete: capture UI (text/tags/attachments, drag/drop, save states/errors).
- 2026-02-21 — Coder M4 complete: menu bar + global shortcut trigger + clipboard text/image ingest.
- 2026-02-21 — Coder M5 complete: Services selected-text handoff integrated into capture draft.
- 2026-02-21 — Coder M6 complete: settings (folder picker + bookmark persistence) + launch-at-login toggle.
- 2026-02-21 — Coder M8 baseline complete: tests/fixtures for text-only, attachment-only, mixed parity contract.
- 2026-02-21 — Milestone: Design completed. Golden-path audit confirmed required UX adjustments.
- 2026-02-21 — Confirmed decisions: format parity with Android output and v0.1.0 distribution target.
- 2026-02-23 — Release prep hardening: distribution workflow now uploads versioned zip artifact, writes clearer summaries, and cleans temporary keychain.
- 2026-02-25 — Added machine-readable lane requirement matrix, handoff skeleton generator script, and asset production workflow/responsibility docs.
- 2026-02-23 — Docs refreshed for first notarized cycle readiness and Sparkle/auto-update preparation checklist.
- 2026-02-21 — Milestone: Research completed; initialized live status tracker.
