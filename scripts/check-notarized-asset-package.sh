#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <package-dir>" >&2
  exit 1
fi

PACKAGE_DIR="$1"

if [[ ! -d "$PACKAGE_DIR" ]]; then
  echo "[error] Package directory not found: $PACKAGE_DIR"
  exit 1
fi

echo "[check] Verifying notarized distribution asset package: $PACKAGE_DIR"

required_files=(
  "artifacts/CaptureApp.zip"
  "artifacts/checksums.txt"
  "artifacts/release-metadata.json"
  "evidence/notarization-log.txt"
  "evidence/gatekeeper-assessment.txt"
  "assets/press-kit/capture-press-kit.zip"
  "assets/og/capture-og-1200x630.png"
  "assets/screenshots/direct-hero-01-1920x1080.png"
)

for rel in "${required_files[@]}"; do
  path="$PACKAGE_DIR/$rel"
  if [[ ! -f "$path" ]]; then
    echo "[error] Missing required package file: $rel"
    exit 1
  fi
  echo "[ok] $rel"
done

if ! grep -q "CaptureApp.zip" "$PACKAGE_DIR/artifacts/checksums.txt"; then
  echo "[error] artifacts/checksums.txt is missing CaptureApp.zip entry"
  exit 1
fi

echo "[ok] artifacts/checksums.txt contains CaptureApp.zip"

echo "[check] Package verification passed"
