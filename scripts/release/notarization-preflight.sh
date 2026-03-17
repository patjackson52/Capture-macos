#!/usr/bin/env bash
set -euo pipefail

required_vars=(
  APPLE_TEAM_ID
  APPLE_DEVELOPER_ID_APP_CERT_BASE64
  APPLE_DEVELOPER_ID_APP_CERT_PASSWORD
  APPLE_NOTARY_API_KEY_ID
  APPLE_NOTARY_API_ISSUER_ID
  APPLE_NOTARY_API_PRIVATE_KEY_BASE64
)

missing=0
for key in "${required_vars[@]}"; do
  if [[ -z "${!key:-}" ]]; then
    echo "[missing] $key"
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  echo
  echo "One or more required env vars are missing."
  echo "Populate the values locally (or GitHub secrets) and retry."
  exit 1
fi

if [[ ! -f VERSION ]]; then
  echo "VERSION file is missing"
  exit 1
fi

VERSION_VALUE="$(tr -d '[:space:]' < VERSION)"
if [[ -z "$VERSION_VALUE" ]]; then
  echo "VERSION file is empty"
  exit 1
fi

echo "Preflight OK"
echo "- VERSION=$VERSION_VALUE"
echo "- Required notarization/signing variables are present"
