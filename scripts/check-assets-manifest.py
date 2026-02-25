#!/usr/bin/env python3
import json
import os
import struct
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
MANIFEST = os.path.join(ROOT, "assets", "manifest.json")
SCHEMA = os.path.join(ROOT, "assets", "manifest.schema.json")

ALLOWED_CATEGORIES = {"icon", "screenshot", "open-graph", "press-kit"}
ALLOWED_FILE_TYPES = {"image", "archive", "document"}
IMAGE_FORMATS = {"png", "jpg", "jpeg"}


def png_size(path: str):
    with open(path, "rb") as f:
        if f.read(8) != b"\x89PNG\r\n\x1a\n":
            raise ValueError("invalid PNG signature")
        f.read(4)
        if f.read(4) != b"IHDR":
            raise ValueError("missing IHDR")
        return struct.unpack(">II", f.read(8))


def jpeg_size(path: str):
    with open(path, "rb") as f:
        if f.read(2) != b"\xff\xd8":
            raise ValueError("invalid JPEG signature")
        while True:
            b = f.read(1)
            if not b:
                raise ValueError("unexpected EOF")
            if b != b"\xff":
                continue
            marker = f.read(1)
            while marker == b"\xff":
                marker = f.read(1)
            if marker in [bytes([m]) for m in (0xC0, 0xC1, 0xC2, 0xC3, 0xC5, 0xC6, 0xC7, 0xC9, 0xCA, 0xCB, 0xCD, 0xCE, 0xCF)]:
                f.read(2)
                f.read(1)
                h, w = struct.unpack(">HH", f.read(4))
                return w, h
            seg_len = struct.unpack(">H", f.read(2))[0]
            f.seek(seg_len - 2, os.SEEK_CUR)


def image_size(path: str, fmt: str):
    fmt = fmt.lower()
    if fmt == "png":
        return png_size(path)
    if fmt in ("jpg", "jpeg"):
        return jpeg_size(path)
    raise ValueError(f"unsupported image format for dimension check: {fmt}")


def fail(msg: str):
    print(f"::error::{msg}")


def warn(msg: str):
    print(f"::warning::{msg}")


def load_json(path: str, label: str):
    if not os.path.isfile(path):
        fail(f"Missing {label}: {os.path.relpath(path, ROOT)}")
        return None
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def validate_manifest_shape(data: dict):
    failures = 0

    if not isinstance(data, dict):
        fail("manifest root must be an object")
        return 1

    for key in ("schemaVersion", "platform", "channels"):
        if key not in data:
            fail(f"manifest missing required key: {key}")
            failures += 1

    if data.get("platform") != "macos":
        fail("manifest platform must be 'macos'")
        failures += 1

    channels = data.get("channels")
    if not isinstance(channels, list) or not channels:
        fail("manifest channels must be a non-empty list")
        return failures + 1

    asset_ids = set()
    for channel in channels:
        if not isinstance(channel, dict):
            fail("channel entry must be an object")
            failures += 1
            continue

        channel_name = channel.get("name", "<unknown-channel>")
        assets = channel.get("assets")
        if not channel_name:
            fail("channel missing name")
            failures += 1
        if not isinstance(assets, list) or not assets:
            fail(f"channel '{channel_name}' must include a non-empty assets list")
            failures += 1
            continue

        for item in assets:
            if not isinstance(item, dict):
                fail(f"{channel_name}: asset entry must be an object")
                failures += 1
                continue

            asset_id = item.get("id", "<unknown>")
            if asset_id in asset_ids:
                fail(f"duplicate asset id: {asset_id}")
                failures += 1
            asset_ids.add(asset_id)

            for key in ("id", "category", "fileType", "export", "placeholder", "format", "required"):
                if key not in item:
                    fail(f"{channel_name}/{asset_id}: missing required field '{key}'")
                    failures += 1

            category = item.get("category")
            if category not in ALLOWED_CATEGORIES:
                fail(f"{channel_name}/{asset_id}: invalid category '{category}'")
                failures += 1

            file_type = item.get("fileType")
            if file_type not in ALLOWED_FILE_TYPES:
                fail(f"{channel_name}/{asset_id}: invalid fileType '{file_type}'")
                failures += 1

            fmt = str(item.get("format", "")).lower()
            if file_type == "image":
                if fmt not in IMAGE_FORMATS:
                    fail(f"{channel_name}/{asset_id}: image format must be png/jpg/jpeg")
                    failures += 1
                if not isinstance(item.get("width"), int) or not isinstance(item.get("height"), int):
                    fail(f"{channel_name}/{asset_id}: image assets require integer width/height")
                    failures += 1
            elif file_type == "archive" and fmt != "zip":
                fail(f"{channel_name}/{asset_id}: archive assets must use format=zip")
                failures += 1
            elif file_type == "document" and fmt != "pdf":
                fail(f"{channel_name}/{asset_id}: document assets must use format=pdf")
                failures += 1

    return failures


def check_assets(data: dict):
    failures = 0

    for channel in data.get("channels", []):
        channel_name = channel.get("name", "<unknown-channel>")
        for item in channel.get("assets", []):
            asset_id = item.get("id", "<unknown>")
            export_rel = item.get("export")
            placeholder_rel = item.get("placeholder")
            required = bool(item.get("required", True))
            file_type = item.get("fileType", "")
            fmt = str(item.get("format", "")).lower()

            if not export_rel or not placeholder_rel:
                fail(f"{channel_name}/{asset_id}: missing export/placeholder path")
                failures += 1
                continue

            export_path = os.path.join(ROOT, export_rel)
            placeholder_path = os.path.join(ROOT, placeholder_rel)

            if not os.path.isfile(placeholder_path):
                fail(f"{channel_name}/{asset_id}: missing placeholder {placeholder_rel}")
                failures += 1

            if os.path.isfile(export_path):
                if file_type == "image":
                    w_req = item.get("width")
                    h_req = item.get("height")
                    try:
                        w_act, h_act = image_size(export_path, fmt)
                        if (w_act, h_act) != (w_req, h_req):
                            fail(
                                f"{channel_name}/{asset_id}: wrong dimensions for {export_rel} "
                                f"(got {w_act}x{h_act}, expected {w_req}x{h_req})"
                            )
                            failures += 1
                    except Exception as e:
                        fail(f"{channel_name}/{asset_id}: unable to validate {export_rel}: {e}")
                        failures += 1
            elif required:
                warn(f"{channel_name}/{asset_id}: export not present yet ({export_rel}); placeholder is present")

    return failures


def main():
    schema = load_json(SCHEMA, "schema")
    data = load_json(MANIFEST, "manifest")
    if schema is None or data is None:
        return 1

    failures = 0
    failures += validate_manifest_shape(data)
    failures += check_assets(data)

    if failures:
        print(f"Asset manifest check failed ({failures} issue(s)).")
        return 1

    print("Asset manifest check passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
