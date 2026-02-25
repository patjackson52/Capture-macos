#!/usr/bin/env python3
import argparse
import json
import os
from datetime import datetime, timezone
from typing import Dict, List

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
DEFAULT_MATRIX = os.path.join(ROOT, "assets", "required-asset-matrix.json")
DEFAULT_MANIFEST = os.path.join(ROOT, "assets", "manifest.json")
DEFAULT_LOCALIZATION = os.path.join(ROOT, "assets", "localization", "app-store-metadata.template.json")
DEFAULT_OUT = os.path.join(ROOT, "out", "release-candidate-asset-checklist.md")


def load_json(path: str, label: str):
    if not os.path.isfile(path):
        raise SystemExit(f"[error] missing {label}: {os.path.relpath(path, ROOT)}")
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def build_asset_index(manifest: dict) -> Dict[str, dict]:
    by_id: Dict[str, dict] = {}
    for channel in manifest.get("channels", []):
        channel_name = channel.get("name")
        for asset in channel.get("assets", []):
            enriched = dict(asset)
            enriched["manifestChannel"] = channel_name
            by_id[asset.get("id")] = enriched
    return by_id


def checkbox_asset(asset_ref: dict, indexed_asset: dict) -> str:
    asset_id = asset_ref.get("assetId", "<unknown-asset>")
    owner = asset_ref.get("ownerRole", "unassigned")
    channel = asset_ref.get("manifestChannel", indexed_asset.get("manifestChannel", "unknown-channel"))
    export = indexed_asset.get("export", "<missing-export>")
    category = indexed_asset.get("category", "unknown")
    return (
        f"- [ ] `{asset_id}` ({category}, owner: {owner})  "
        f"channel: `{channel}` · export: `{export}`"
    )


def checkbox_evidence(item: dict) -> str:
    item_id = item.get("id", "<unknown-evidence>")
    path = item.get("path", "<missing-path>")
    owner = item.get("ownerRole", "unassigned")
    return f"- [ ] `{item_id}` (owner: {owner}) · `{path}`"


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate release candidate asset checklist markdown.")
    parser.add_argument("--matrix", default=DEFAULT_MATRIX, help="Path to required-asset-matrix.json")
    parser.add_argument("--manifest", default=DEFAULT_MANIFEST, help="Path to assets manifest.json")
    parser.add_argument("--localization", default=DEFAULT_LOCALIZATION, help="Path to app-store localization template")
    parser.add_argument("--version", default="", help="Release version (optional)")
    parser.add_argument("--cycle-id", default="", help="Release cycle ID (optional)")
    parser.add_argument("--out", default=DEFAULT_OUT, help="Output markdown path")
    args = parser.parse_args()

    matrix = load_json(args.matrix, "required asset matrix")
    manifest = load_json(args.manifest, "asset manifest")
    localization = load_json(args.localization, "localization template")

    assets_by_id = build_asset_index(manifest)
    locales: List[str] = sorted(localization.get("locales", {}).keys())

    generated_at = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    version_line = args.version.strip() or "<set-version>"
    cycle_line = args.cycle_id.strip() or "<set-cycle-id>"

    lines: List[str] = []
    lines.append("# Release candidate asset checklist")
    lines.append("")
    lines.append(f"- Generated (UTC): {generated_at}")
    lines.append(f"- Version: {version_line}")
    lines.append(f"- Cycle ID: {cycle_line}")
    lines.append("")

    if locales:
        lines.append("## Localization readiness")
        for locale in locales:
            lines.append(f"- [ ] `{locale}` copy reviewed for App Store + direct listing + captions")
        lines.append("")

    for lane in matrix.get("lanes", []):
        lane_id = lane.get("id", "<unknown-lane>")
        lane_name = lane.get("name", lane_id)

        lines.append(f"## Lane: {lane_name} (`{lane_id}`)")
        lines.append("")
        lines.append("### Required assets")

        for asset_ref in lane.get("requiredAssets", []):
            asset_id = asset_ref.get("assetId")
            indexed_asset = assets_by_id.get(asset_id, {})
            lines.append(checkbox_asset(asset_ref, indexed_asset))

        lines.append("")
        lines.append("### Required evidence")
        for evidence in lane.get("requiredEvidence", []):
            lines.append(checkbox_evidence(evidence))
        lines.append("")

    out_path = args.out
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")

    print(f"[ok] Wrote RC checklist: {os.path.relpath(out_path, ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
