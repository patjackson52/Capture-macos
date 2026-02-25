#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "[preflight] Running macOS distribution preflight checks"

VERSION_VALUE="$(tr -d '[:space:]' < VERSION)"
if [[ -z "$VERSION_VALUE" ]]; then
  echo "[error] VERSION must not be empty"
  exit 1
fi

echo "[ok] VERSION=$VERSION_VALUE"

required_env=(
  APPLE_TEAM_ID
  APPLE_DEVELOPER_ID_APP_CERT_BASE64
  APPLE_DEVELOPER_ID_APP_CERT_PASSWORD
  APPLE_NOTARY_API_KEY_ID
  APPLE_NOTARY_API_ISSUER_ID
  APPLE_NOTARY_API_PRIVATE_KEY_BASE64
)

missing=0
for key in "${required_env[@]}"; do
  if [[ -z "${!key:-}" ]]; then
    echo "[error] Missing required env var: $key"
    missing=1
  else
    echo "[ok] $key is set"
  fi
done

if [[ "$missing" -ne 0 ]]; then
  echo "[error] One or more required secrets/env vars are missing"
  exit 1
fi

scripts/check-assets-manifest.py

python3 - <<'PY'
import json
from pathlib import Path

matrix_path = Path("assets/required-asset-matrix.json")
if not matrix_path.is_file():
    raise SystemExit("[error] Missing assets/required-asset-matrix.json")

data = json.loads(matrix_path.read_text(encoding="utf-8"))
required_lanes = {"app-store", "direct-notarized"}
lanes = {lane.get("id") for lane in data.get("lanes", []) if isinstance(lane, dict)}
missing = sorted(required_lanes - lanes)
if missing:
    raise SystemExit(f"[error] required-asset-matrix missing lanes: {', '.join(missing)}")
print("[ok] required-asset-matrix includes app-store and direct-notarized lanes")
PY

required_placeholders=(
  assets/exports/direct-distribution/icons/direct-download-icon-512.placeholder.md
  assets/exports/direct-distribution/screenshots/direct-hero-01-1920x1080.placeholder.md
  assets/exports/direct-distribution/og/capture-og-1200x630.placeholder.md
  assets/exports/direct-distribution/press-kit/capture-press-kit.placeholder.md
)

for path in "${required_placeholders[@]}"; do
  if [[ ! -f "$path" ]]; then
    echo "[error] Missing direct distribution placeholder: $path"
    exit 1
  fi
  echo "[ok] Found $path"
done

echo "[preflight] All checks passed"
