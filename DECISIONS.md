# Capture macOS — Decisions Log

## 2026-02-21 19:22 UTC

### Format parity (confirmed)
**Decision:** Match Android actual output. The canonical source of truth is current Android repo behavior.

**Rationale (short):** Ensures cross-platform consistency and avoids ambiguity from docs drifting from shipped Android behavior.

### Distribution target for v0.1.0 (confirmed)
**Decision:** Personal/developer use only for now (no App Store distribution for v0.1.0).

**Future path:** When sharing beyond personal/developer use, distribute via Developer ID signing + Apple notarization.

**Rationale (short):** Reduces early release overhead while preserving a compliant path for later external sharing.
