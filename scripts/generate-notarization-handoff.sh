#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MATRIX="$ROOT/assets/required-asset-matrix.json"

usage() {
  cat <<'EOF'
Usage: scripts/generate-notarization-handoff.sh [--version <version>] [--cycle-id <id>] [--out <dir>]

Creates a notarization-cycle handoff skeleton with:
- artifacts/ and evidence/ directories
- assets mirror directories for direct distribution lane
- CHECKLIST.md stub generated from assets/required-asset-matrix.json

Defaults:
- version: contents of VERSION file
- cycle-id: UTC timestamp (YYYYMMDDTHHMMSSZ)
- out: out/handoffs/notarization-<version>-<cycle-id>
EOF
}

VERSION_VALUE="$(tr -d '[:space:]' < "$ROOT/VERSION")"
CYCLE_ID="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      VERSION_VALUE="$2"
      shift 2
      ;;
    --cycle-id)
      CYCLE_ID="$2"
      shift 2
      ;;
    --out)
      OUT_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$VERSION_VALUE" ]]; then
  echo "[error] version must not be empty" >&2
  exit 1
fi

if [[ ! -f "$MATRIX" ]]; then
  echo "[error] required matrix not found: $MATRIX" >&2
  exit 1
fi

if [[ -z "$OUT_DIR" ]]; then
  OUT_DIR="$ROOT/out/handoffs/notarization-${VERSION_VALUE}-${CYCLE_ID}"
fi

mkdir -p "$OUT_DIR"/{artifacts,evidence,assets/icons,assets/og,assets/screenshots,assets/press-kit}

cat > "$OUT_DIR/README.md" <<EOF
# Notarization handoff package

- Version: $VERSION_VALUE
- Cycle ID: $CYCLE_ID
- Generated (UTC): $(date -u +%Y-%m-%dT%H:%M:%SZ)

This skeleton is intended for direct distribution handoff completion.
Fill in artifacts/evidence and complete CHECKLIST.md before release sign-off.
EOF

cat > "$OUT_DIR/artifacts/release-metadata.json" <<EOF
{
  "version": "$VERSION_VALUE",
  "cycleId": "$CYCLE_ID",
  "generatedAtUtc": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "channel": "direct-notarized",
  "notes": "Replace placeholders and append release metadata."
}
EOF

touch "$OUT_DIR/artifacts/CaptureApp.zip"
touch "$OUT_DIR/artifacts/checksums.txt"
touch "$OUT_DIR/evidence/notarization-log.txt"
touch "$OUT_DIR/evidence/gatekeeper-assessment.txt"

python3 - "$MATRIX" "$OUT_DIR/CHECKLIST.md" <<'PY'
import json
import pathlib
import sys

matrix_path = pathlib.Path(sys.argv[1])
out_path = pathlib.Path(sys.argv[2])

data = json.loads(matrix_path.read_text(encoding="utf-8"))
lanes = data.get("lanes", [])
direct = next((lane for lane in lanes if lane.get("id") == "direct-notarized"), None)
if direct is None:
    raise SystemExit("Missing lane 'direct-notarized' in required-asset-matrix.json")

lines = []
lines.append("# Direct notarization handoff checklist")
lines.append("")
lines.append("Use this checklist to complete the notarized distribution handoff package.")
lines.append("")
lines.append("## Required assets")
for asset in direct.get("requiredAssets", []):
    asset_id = asset.get("assetId", "<unknown-asset>")
    owner = asset.get("ownerRole", "unassigned")
    lines.append(f"- [ ] `{asset_id}` (owner: {owner})")

lines.append("")
lines.append("## Required evidence")
for item in direct.get("requiredEvidence", []):
    item_id = item.get("id", "<unknown-evidence>")
    rel = item.get("path", "")
    owner = item.get("ownerRole", "unassigned")
    lines.append(f"- [ ] `{item_id}` → `{rel}` (owner: {owner})")

lines.append("")
lines.append("## Sign-off")
lines.append("- [ ] Design/Marketing assets finalized")
lines.append("- [ ] Notarization and Gatekeeper evidence attached")
lines.append("- [ ] Release owner approved package for publication")

out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
PY

echo "[ok] Handoff skeleton generated at: $OUT_DIR"
