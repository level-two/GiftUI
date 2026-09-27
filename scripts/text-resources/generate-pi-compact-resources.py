#!/usr/bin/env python3
"""Generate the Pi-only bitmap font from pinned Terminus BDF glyphs."""

from __future__ import annotations

import argparse
import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "ThirdParty/Terminus-4.49.1/ter-u12n.bdf"
LICENSE = ROOT / "ThirdParty/Terminus-4.49.1/OFL.TXT"
SOURCE_SHA256 = "9e942cad8173fddf34fc8a784e9ec6d2d4cfb8b82363faf65f43b236fe2f5a99"
LICENSE_SHA256 = "c14f8d795784a547ea35e69c51dee2957bb71a1cdb492ec5321e4b61d3d97630"
REFERENCE = Path(__file__).with_name("generate-reference-resources.py")
SPEC = importlib.util.spec_from_file_location("giftui_reference_generator", REFERENCE)
assert SPEC is not None and SPEC.loader is not None
ref = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(ref)


def read_bdf() -> tuple[dict[int, dict], int, int]:
    if ref.sha256(SOURCE.read_bytes()) != SOURCE_SHA256:
        raise SystemExit("Terminus source hash mismatch")
    if ref.sha256(LICENSE.read_bytes()) != LICENSE_SHA256:
        raise SystemExit("Terminus license hash mismatch")
    lines = SOURCE.read_text(encoding="ascii").splitlines()
    glyphs: dict[int, dict] = {}
    ascent = descent = None
    position = 0
    while position < len(lines):
        line = lines[position]
        if line.startswith("FONT_ASCENT "):
            ascent = int(line.split()[1])
        elif line.startswith("FONT_DESCENT "):
            descent = int(line.split()[1])
        elif line.startswith("STARTCHAR "):
            encoding = advance = box = None
            bitmap = b""
            position += 1
            while lines[position] != "ENDCHAR":
                fields = lines[position].split()
                if fields[0] == "ENCODING":
                    encoding = int(fields[1])
                elif fields[0] == "DWIDTH":
                    advance = int(fields[1])
                elif fields[0] == "BBX":
                    box = tuple(map(int, fields[1:]))
                elif fields[0] == "BITMAP":
                    assert box is not None
                    width, height, _, _ = box
                    row_bytes = (width + 7) // 8
                    rows = lines[position + 1 : position + 1 + height]
                    bitmap = b"".join(bytes.fromhex(row) for row in rows)
                    if len(bitmap) != row_bytes * height:
                        raise SystemExit(f"invalid BDF bitmap: {encoding}")
                    position += height
                position += 1
            if encoding is not None and encoding >= 0:
                if encoding in glyphs:
                    raise SystemExit(f"duplicate BDF encoding: {encoding}")
                assert box is not None and advance is not None
                width, height, offset_x, offset_y = box
                glyphs[encoding] = {
                    "advanceX": advance, "offsetX": offset_x,
                    "offsetY": -(height + offset_y), "width": width,
                    "height": height, "rowByteCount": (width + 7) // 8,
                    "bitmap": bitmap,
                }
        position += 1
    if (ascent, descent) != (10, 2):
        raise SystemExit("unexpected Terminus line metrics")
    if any(scalar not in glyphs for scalar in ref.REQUIRED_SCALARS):
        raise SystemExit("Terminus is missing a required scalar")
    return glyphs, ascent, descent


def generate(output: Path) -> None:
    glyphs, ascent, descent = read_bdf()
    output.mkdir(parents=True, exist_ok=True)
    scalars = ref.REQUIRED_SCALARS
    mappings = [{"scalar": scalar, "glyph": index}
                for index, scalar in enumerate(scalars)]
    metrics = []
    records = []
    payload = bytearray()
    for index, scalar in enumerate(scalars):
        source = glyphs[scalar]
        metrics.append({"glyph": index, **{
            field: source[field]
            for field in ("advanceX", "offsetX", "offsetY", "width", "height")
        }})
        bitmap = source["bitmap"]
        records.append({
            "glyph": index, "offset": len(payload),
            "byteCount": len(bitmap), "rowByteCount": source["rowByteCount"],
            "pixelWidth": source["width"], "pixelHeight": source["height"],
        })
        payload.extend(bitmap)
    instance = {
        "ascent": ascent, "descent": descent, "lineGap": 0,
        "replacementGlyph": scalars.index(ord("?")),
        "glyphCount": len(scalars), "mappingCount": len(mappings),
    }
    realizations = [{
        "id": 0, "kind": 0, "payload": bytes(payload),
        "digest": ref.sha256(payload), "records": records,
    }]
    manifest = ref.canonical_manifest(instance, mappings, metrics, realizations)
    catalogue = ref.emit_catalogue(
        ref.sha256(manifest), len(manifest), instance, mappings, metrics,
        realizations, type_name="_GiftUIPiCompactGeneratedCatalogue"
    ).replace("generate-reference-resources.py", "generate-pi-compact-resources.py")
    bitmap = ref.emit_payload(
        "_GiftUIPiCompactGeneratedBitmapPayload", bytes(payload), records
    ).replace("generate-reference-resources.py", "generate-pi-compact-resources.py")
    ref.write_text(output / "PiCompactCatalogue.generated.swift", catalogue)
    ref.write_text(output / "PiCompactBitmapPayload.generated.swift", bitmap)
    ref.write_json(output / "generation-manifest.json", {
        "generator": "scripts/text-resources/generate-pi-compact-resources.py",
        "source": "ThirdParty/Terminus-4.49.1/ter-u12n.bdf",
        "sourceSHA256": SOURCE_SHA256,
        "licenseSHA256": LICENSE_SHA256,
        "resourceID": ref.sha256(manifest),
        "bitmapPayloadSHA256": ref.sha256(payload),
        "canonicalManifestByteCount": len(manifest),
        "glyphCount": len(scalars),
        "mappingCount": len(mappings),
        "outputs": {
            "PiCompactCatalogue.generated.swift": ref.sha256(catalogue.encode()),
            "PiCompactBitmapPayload.generated.swift": ref.sha256(bitmap.encode()),
        },
    })


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-directory", required=True, type=Path)
    generate(parser.parse_args().output_directory)
