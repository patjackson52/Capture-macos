#!/usr/bin/env python3
import json
import os
import sys
from typing import Dict, List, Set

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
MATRIX_PATH = os.path.join(ROOT, "assets", "required-asset-matrix.json")
APP_STORE_PATH = os.path.join(ROOT, "assets", "localization", "app-store-metadata.template.json")
DIRECT_PATH = os.path.join(ROOT, "assets", "localization", "direct-listing-metadata.template.json")
CAPTIONS_PATH = os.path.join(ROOT, "assets", "localization", "screenshot-captions.template.json")
EVIDENCE_PATH = os.path.join(ROOT, "assets", "localization", "release-cycle-evidence.template.json")

APP_STORE_REQUIRED_FIELDS = [
    "appName",
    "subtitle",
    "promoText",
    "description",
    "keywords",
    "releaseNotes",
]

DIRECT_REQUIRED_FIELDS = [
    "headline",
    "subheadline",
    "shortDescription",
    "longDescription",
    "ctaPrimary",
    "ctaSecondary",
]


def fail(msg: str):
    print(f"::error::{msg}")


def warn(msg: str):
    print(f"::warning::{msg}")


def load_json(path: str, label: str):
    if not os.path.isfile(path):
        fail(f"Missing {label}: {os.path.relpath(path, ROOT)}")
        return None

    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as exc:
        fail(f"Unable to parse {label}: {exc}")
        return None


def validate_metadata_template(data: dict, label: str, required_fields: List[str]) -> int:
    failures = 0
    locales = data.get("locales")
    if not isinstance(locales, dict) or not locales:
        fail(f"{label}: locales must be a non-empty object")
        return 1

    for locale, copy_data in locales.items():
        if not isinstance(copy_data, dict):
            fail(f"{label}/{locale}: locale entry must be an object")
            failures += 1
            continue
        for field in required_fields:
            value = copy_data.get(field)
            if value is None:
                fail(f"{label}/{locale}: missing required field '{field}'")
                failures += 1
                continue
            if isinstance(value, str) and not value.strip():
                fail(f"{label}/{locale}: field '{field}' must not be empty")
                failures += 1
            if field == "keywords":
                if not isinstance(value, list) or not value:
                    fail(f"{label}/{locale}: keywords must be a non-empty list")
                    failures += 1
                elif any(not isinstance(x, str) or not x.strip() for x in value):
                    fail(f"{label}/{locale}: keywords entries must be non-empty strings")
                    failures += 1

    return failures


def validate_locale_alignment(app_store: dict, direct: dict, captions: dict) -> int:
    failures = 0
    app_locales: Set[str] = set(app_store.get("locales", {}).keys())
    direct_locales: Set[str] = set(direct.get("locales", {}).keys())
    caption_locales: Set[str] = set(captions.get("locales", {}).keys())

    if not app_locales:
        return 0

    if direct_locales != app_locales:
        missing = sorted(app_locales - direct_locales)
        extra = sorted(direct_locales - app_locales)
        if missing:
            fail(f"direct-listing locales missing from app-store baseline: {', '.join(missing)}")
            failures += 1
        if extra:
            warn(f"direct-listing has additional locales: {', '.join(extra)}")

    if caption_locales != app_locales:
        missing = sorted(app_locales - caption_locales)
        extra = sorted(caption_locales - app_locales)
        if missing:
            fail(f"screenshot-captions locales missing from app-store baseline: {', '.join(missing)}")
            failures += 1
        if extra:
            warn(f"screenshot-captions has additional locales: {', '.join(extra)}")

    return failures


def build_manifest_asset_map(manifest: dict) -> Dict[str, dict]:
    result: Dict[str, dict] = {}
    for channel in manifest.get("channels", []):
        channel_name = channel.get("name")
        for item in channel.get("assets", []):
            item = dict(item)
            item["channel"] = channel_name
            result[item.get("id")] = item
    return result


def validate_screenshot_captions(captions: dict, manifest: dict) -> int:
    failures = 0
    manifest_assets = build_manifest_asset_map(manifest)

    required_caption_ids: Dict[str, List[str]] = {
        "app-store-listing": [],
        "direct-distribution-listing": [],
    }

    for asset in manifest_assets.values():
        if asset.get("category") != "screenshot":
            continue
        channel = asset.get("channel")
        if channel in required_caption_ids and asset.get("required", False):
            required_caption_ids[channel].append(asset.get("id"))

    locales = captions.get("locales", {})
    for locale, channels in locales.items():
        if not isinstance(channels, dict):
            fail(f"screenshot-captions/{locale}: value must be an object")
            failures += 1
            continue

        for channel, required_ids in required_caption_ids.items():
            channel_caps = channels.get(channel)
            if not isinstance(channel_caps, dict):
                fail(f"screenshot-captions/{locale}: missing channel '{channel}' captions")
                failures += 1
                continue

            for asset_id in required_ids:
                caption = channel_caps.get(asset_id)
                if not isinstance(caption, str) or not caption.strip():
                    fail(f"screenshot-captions/{locale}/{channel}: missing caption for {asset_id}")
                    failures += 1

    return failures


def validate_release_cycle_evidence(evidence: dict, matrix: dict) -> int:
    failures = 0
    lanes_obj = evidence.get("lanes")
    if not isinstance(lanes_obj, dict) or not lanes_obj:
        fail("release-cycle-evidence: lanes must be a non-empty object")
        return 1

    matrix_lanes = matrix.get("lanes", [])
    for lane in matrix_lanes:
        lane_id = lane.get("id")
        lane_data = lanes_obj.get(lane_id)
        if not isinstance(lane_data, dict):
            fail(f"release-cycle-evidence: missing lane '{lane_id}'")
            failures += 1
            continue

        required_evidence = lane_data.get("requiredEvidence")
        if not isinstance(required_evidence, dict):
            fail(f"release-cycle-evidence/{lane_id}: requiredEvidence must be an object")
            failures += 1
            continue

        for item in lane.get("requiredEvidence", []):
            evidence_id = item.get("id")
            entry = required_evidence.get(evidence_id)
            if not isinstance(entry, dict):
                fail(f"release-cycle-evidence/{lane_id}: missing required evidence '{evidence_id}'")
                failures += 1
                continue

            for field in ("path", "ownerRole", "status"):
                value = entry.get(field)
                if not isinstance(value, str) or not value.strip():
                    fail(
                        f"release-cycle-evidence/{lane_id}/{evidence_id}: field '{field}' must be non-empty"
                    )
                    failures += 1

    return failures


def main() -> int:
    matrix = load_json(MATRIX_PATH, "required asset matrix")
    manifest = load_json(os.path.join(ROOT, "assets", "manifest.json"), "asset manifest")
    app_store = load_json(APP_STORE_PATH, "app-store localization template")
    direct = load_json(DIRECT_PATH, "direct listing localization template")
    captions = load_json(CAPTIONS_PATH, "screenshot captions template")
    evidence = load_json(EVIDENCE_PATH, "release cycle evidence template")

    if any(x is None for x in [matrix, manifest, app_store, direct, captions, evidence]):
        return 1

    failures = 0
    failures += validate_metadata_template(app_store, "app-store-metadata", APP_STORE_REQUIRED_FIELDS)
    failures += validate_metadata_template(direct, "direct-listing-metadata", DIRECT_REQUIRED_FIELDS)
    failures += validate_locale_alignment(app_store, direct, captions)
    failures += validate_screenshot_captions(captions, manifest)
    failures += validate_release_cycle_evidence(evidence, matrix)

    if failures:
        print(f"Localization readiness check failed ({failures} issue(s)).")
        return 1

    print("Localization readiness check passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
