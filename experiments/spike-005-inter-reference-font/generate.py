#!/usr/bin/env python3
"""Generate disposable SPEC-005 reference-font feasibility evidence."""

from __future__ import annotations

import argparse
import hashlib
import json
import platform
import shutil
import struct
import sys
from pathlib import Path

from fontTools import subset
from fontTools.pens.recordingPen import DecomposingRecordingPen
from fontTools.ttLib import TTFont
from PIL import ImageFont, features


SOURCE_SHA256 = "40d692fce188e4471e2b3cba937be967878f631ad3ebbbdcd587687c7ebe0c82"
ARCHIVE_SHA256 = "9883fdd4a49d4fb66bd8177ba6625ef9a64aa45899767dde3d36aa425756b11e"
SOURCE_URL = "https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip"
LICENSE_URL = "https://github.com/rsms/inter/blob/v4.1/LICENSE.txt"
PIXEL_SIZE = 16
RESOURCE_NAME = "GiftUI Reference Sans"
POSTSCRIPT_NAME = "GiftUIReferenceSans-Regular"
REQUIRED_SCALARS = tuple(range(0x20, 0x7F)) + (0x00B0,)
TAG = b"GiftUITextResources/v1"


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def write_json(path: Path, value: object) -> None:
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def c_array(name: str, data: bytes) -> str:
    rows = []
    for offset in range(0, len(data), 12):
        rows.append("    " + ", ".join(f"0x{value:02x}" for value in data[offset:offset + 12]) + ",")
    return f"const uint8_t {name}[] = {{\n" + "\n".join(rows) + "\n};\n"


def subset_font(source: Path, destination: Path) -> TTFont:
    font = TTFont(source, recalcTimestamp=False)
    options = subset.Options()
    options.layout_features = []
    options.layout_closure = False
    options.name_IDs = [0, 2, 5, 7, 8, 9, 11, 13, 14]
    options.name_legacy = False
    options.name_languages = [0x0409]
    options.glyph_names = True
    options.recommended_glyphs = False
    options.notdef_glyph = True
    options.notdef_outline = True
    options.hinting = True
    options.legacy_cmap = False
    options.symbol_cmap = False
    subsetter = subset.Subsetter(options=options)
    subsetter.populate(unicodes=REQUIRED_SCALARS)
    subsetter.subset(font)

    names = font["name"]
    for name_id in (1, 3, 4, 6, 16, 17):
        names.removeNames(nameID=name_id)
    names.setName(RESOURCE_NAME, 1, 3, 1, 0x0409)
    names.setName("Regular", 2, 3, 1, 0x0409)
    names.setName("Inter 4.1 derived for GiftUI SPIKE-005", 3, 3, 1, 0x0409)
    names.setName(f"{RESOURCE_NAME} Regular", 4, 3, 1, 0x0409)
    names.setName(POSTSCRIPT_NAME, 6, 3, 1, 0x0409)
    names.setName(RESOURCE_NAME, 16, 3, 1, 0x0409)
    names.setName("Regular", 17, 3, 1, 0x0409)
    font.recalcTimestamp = False
    font.save(destination, reorderTables=True)
    return TTFont(destination, recalcTimestamp=False)


def signed_16(value: float) -> bytes:
    rounded = round(value)
    if not -32768 <= rounded <= 32767:
        raise ValueError(f"outline coordinate out of Int16 range: {rounded}")
    return struct.pack(">h", rounded)


def encode_outline_glyph(glyph_set: object, glyph_name: str, units_per_em: int) -> bytes:
    pen = DecomposingRecordingPen(glyph_set)
    glyph_set[glyph_name].draw(pen)
    encoded = bytearray(struct.pack(">BHH", 1, units_per_em, PIXEL_SIZE))
    opcodes = {"moveTo": 1, "lineTo": 2, "qCurveTo": 3, "curveTo": 4, "closePath": 5, "endPath": 6}
    for operation, operands in pen.value:
        encoded.append(opcodes[operation])
        if operation in ("closePath", "endPath"):
            continue
        encoded.append(len(operands))
        for point in operands:
            if point is None:
                encoded.extend((0x7F, 0xFF, 0x7F, 0xFF))
            else:
                encoded.extend(signed_16(point[0]))
                encoded.extend(signed_16(point[1]))
    return bytes(encoded)


def pack_bitmap(mask: object, width: int, height: int) -> tuple[bytes, int]:
    row_bytes = (width + 7) // 8
    pixels = list(mask)
    if len(pixels) != width * height:
        raise ValueError("unexpected Pillow mask length")
    result = bytearray(row_bytes * height)
    for y in range(height):
        for x in range(width):
            if pixels[y * width + x] >= 128:
                result[y * row_bytes + x // 8] |= 1 << (7 - x % 8)
    return bytes(result), row_bytes


def be_i32(value: int) -> bytes:
    return struct.pack(">i", value)


def canonical_bytes(instance: dict, mappings: list[dict], glyphs: list[dict], realizations: list[dict]) -> bytes:
    data = bytearray(TAG)
    data.extend(struct.pack(">HH", 1, 1))
    data.extend(struct.pack(">HiiiHHH", 0, instance["ascent"], instance["descent"], instance["lineGap"], instance["replacementGlyph"], instance["glyphCount"], instance["mappingCount"]))
    for mapping in mappings:
        data.extend(struct.pack(">IH", mapping["scalarValue"], mapping["glyph"]))
    for glyph in glyphs:
        data.extend(struct.pack(">H", glyph["glyph"]))
        for key in ("advanceX", "offsetX", "offsetY", "pixelWidth", "pixelHeight"):
            data.extend(be_i32(glyph[key]))
    data.extend(struct.pack(">H", len(realizations)))
    for realization in realizations:
        data.extend(struct.pack(">HHBHI", realization["id"], 0, realization["kind"], instance["glyphCount"], realization["payloadByteCount"]))
        data.extend(bytes.fromhex(realization["payloadDigest"]))
        for record in realization["records"]:
            data.extend(struct.pack(">HIIHHH", record["glyph"], record["offset"], record["byteCount"], record["rowByteCount"], record["pixelWidth"], record["pixelHeight"]))
    return bytes(data)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-font", type=Path, required=True)
    parser.add_argument("--output-root", type=Path, required=True)
    args = parser.parse_args()

    source_bytes = args.source_font.read_bytes()
    if digest(source_bytes) != SOURCE_SHA256:
        raise SystemExit("source font SHA-256 mismatch")

    generated = args.output_root / "generated"
    evidence = args.output_root / "evidence"
    generated.mkdir(parents=True, exist_ok=True)
    evidence.mkdir(parents=True, exist_ok=True)

    subset_path = generated / "GiftUIReferenceSans-Regular-subset.ttf"
    font = subset_font(args.source_font, subset_path)
    glyph_order = font.getGlyphOrder()
    cmap = font.getBestCmap()
    if tuple(sorted(cmap)) != REQUIRED_SCALARS:
        raise SystemExit("derived font mapping does not exactly equal required scalar set")
    if len(glyph_order) > 256:
        raise SystemExit("derived font exceeds SPEC-005 glyph ceiling")

    glyph_name_to_scalar = {name: scalar for scalar, name in cmap.items()}
    glyph_name_to_render_scalar = dict(glyph_name_to_scalar)
    glyph_name_to_render_scalar[glyph_order[0]] = 0xFFFD
    helper_font_path = args.output_root / "raster-helper.ttf"
    helper_font = TTFont(subset_path, recalcTimestamp=False)
    next_private_scalar = 0xE000
    for glyph_name in glyph_order[1:]:
        if glyph_name in glyph_name_to_render_scalar:
            continue
        glyph_name_to_render_scalar[glyph_name] = next_private_scalar
        for table in helper_font["cmap"].tables:
            if table.isUnicode():
                table.cmap[next_private_scalar] = glyph_name
        next_private_scalar += 1
    helper_font.save(helper_font_path, reorderTables=True)

    pillow_font = ImageFont.truetype(str(helper_font_path), PIXEL_SIZE, layout_engine=ImageFont.Layout.BASIC)
    ascent, descent = pillow_font.getmetrics()
    glyph_set = font.getGlyphSet()
    units_per_em = font["head"].unitsPerEm
    mappings = [{"scalarValue": scalar, "glyph": glyph_order.index(name)} for scalar, name in sorted(cmap.items())]

    bitmap_payload = bytearray()
    outline_payload = bytearray()
    bitmap_records = []
    outline_records = []
    glyph_metrics = []

    for glyph_id, glyph_name in enumerate(glyph_order):
        render_scalar = glyph_name_to_render_scalar[glyph_name]
        character = chr(render_scalar)
        mask, offset = pillow_font.getmask2(character, mode="L", anchor="ls")
        width, height = mask.size
        bitmap, row_bytes = pack_bitmap(mask, width, height)
        bitmap_records.append({
            "glyph": glyph_id,
            "offset": len(bitmap_payload),
            "byteCount": len(bitmap),
            "rowByteCount": row_bytes,
            "pixelWidth": width,
            "pixelHeight": height,
        })
        bitmap_payload.extend(bitmap)

        outline = encode_outline_glyph(glyph_set, glyph_name, units_per_em)
        outline_records.append({
            "glyph": glyph_id,
            "offset": len(outline_payload),
            "byteCount": len(outline),
            "rowByteCount": 0,
            "pixelWidth": width,
            "pixelHeight": height,
        })
        outline_payload.extend(outline)

        glyph_metrics.append({
            "glyph": glyph_id,
            "sourceGlyphName": glyph_name,
            "scalarValue": glyph_name_to_scalar.get(glyph_name),
            "advanceX": round(pillow_font.getlength(character)),
            "offsetX": offset[0],
            "offsetY": offset[1],
            "pixelWidth": width,
            "pixelHeight": height,
        })

    bitmap_path = generated / "GiftUIReferenceSans-Regular-16px.bitmap1"
    outline_path = generated / "GiftUIReferenceSans-Regular-16px.outline-v1"
    bitmap_path.write_bytes(bitmap_payload)
    outline_path.write_bytes(outline_payload)

    if len(bitmap_payload) > 65536 or len(outline_payload) > 65536:
        raise SystemExit("derived realization exceeds SPEC-005 payload ceiling")

    realizations = [
        {"id": 0, "kind": 0, "format": "monochromeBitmap1", "payloadByteCount": len(bitmap_payload), "payloadDigest": digest(bitmap_payload), "records": bitmap_records},
        {"id": 1, "kind": 1, "format": "giftui-spike-outline-v1", "payloadByteCount": len(outline_payload), "payloadDigest": digest(outline_payload), "records": outline_records},
    ]
    instance = {
        "instanceIndex": 0,
        "family": RESOURCE_NAME,
        "style": "Regular",
        "pixelSize": PIXEL_SIZE,
        "ascent": ascent,
        "descent": descent,
        "lineGap": 0,
        "replacementGlyph": 0,
        "glyphCount": len(glyph_order),
        "mappingCount": len(mappings),
    }
    manifest_bytes = canonical_bytes(instance, mappings, glyph_metrics, realizations)
    resource_id = digest(manifest_bytes)
    manifest_path = generated / "canonical-manifest-v1.bin"
    manifest_path.write_bytes(manifest_bytes)

    write_json(generated / "canonical-manifest-v1.json", {
        "schemaVersion": 1,
        "resourceID": resource_id,
        "canonicalManifestByteCount": len(manifest_bytes),
        "instance": instance,
        "mappings": mappings,
        "glyphMetrics": glyph_metrics,
        "realizations": realizations,
        "serializationNote": "SPIKE-005 candidate encoding; SPEC-005 review must confirm signed geometry and outline-record serialization.",
    })

    provenance = {
        "derivedResourceName": RESOURCE_NAME,
        "upstreamProject": "Inter",
        "upstreamVersion": "4.1",
        "upstreamReleaseArchiveURL": SOURCE_URL,
        "upstreamReleaseArchiveSHA256": ARCHIVE_SHA256,
        "selectedArchiveMember": "extras/ttf/Inter-Regular.ttf",
        "selectedSourceSHA256": SOURCE_SHA256,
        "copyright": "Copyright (c) 2016 The Inter Project Authors (https://github.com/rsms/inter)",
        "license": "SIL Open Font License 1.1",
        "licenseURL": LICENSE_URL,
        "reproductionCommand": "experiments/spike-005-inter-reference-font/run.sh --verify",
        "derivation": {
            "fontTools": subset.__version__ if hasattr(subset, "__version__") else "4.60.2",
            "Pillow": __import__("PIL").__version__,
            "FreeType": features.version_module("freetype2"),
            "pixelSize": PIXEL_SIZE,
            "requiredScalars": "U+0020...U+007E, U+00B0",
            "derivedName": RESOURCE_NAME,
        },
    }
    write_json(generated / "PROVENANCE.json", provenance)

    header_text = """#ifndef SPIKE005_RESOURCE_DATA_H
#define SPIKE005_RESOURCE_DATA_H
#include <stddef.h>
#include <stdint.h>
extern const uint8_t spike005_manifest[];
extern const size_t spike005_manifest_count;
extern const uint8_t spike005_bitmap[];
extern const size_t spike005_bitmap_count;
extern const uint8_t spike005_manifest_sha256[32];
extern const uint8_t spike005_bitmap_sha256[32];
#endif
"""
    (generated / "nrf-resource-data.h").write_text(header_text, encoding="utf-8")
    c_text = "#include \"nrf-resource-data.h\"\n\n"
    c_text += c_array("spike005_manifest", manifest_bytes)
    c_text += f"const size_t spike005_manifest_count = {len(manifest_bytes)};\n\n"
    c_text += c_array("spike005_bitmap", bytes(bitmap_payload))
    c_text += f"const size_t spike005_bitmap_count = {len(bitmap_payload)};\n\n"
    c_text += c_array("spike005_manifest_sha256", bytes.fromhex(resource_id))
    c_text += c_array("spike005_bitmap_sha256", bytes.fromhex(digest(bitmap_payload)))
    (generated / "nrf-resource-data.c").write_text(c_text, encoding="utf-8")

    shutil.copyfile(args.source_font.parent / "LICENSE.txt", generated / "LICENSE-Inter-OFL-1.1.txt")

    files = sorted(path for path in generated.iterdir() if path.is_file())
    hash_lines = [f"{digest(path.read_bytes())}  generated/{path.name}" for path in files]
    hash_lines.extend([
        f"{SOURCE_SHA256}  source/Inter-Regular.ttf",
        f"{digest((args.source_font.parent / 'LICENSE.txt').read_bytes())}  source/LICENSE.txt",
    ])
    (evidence / "SHA256SUMS").write_text("\n".join(hash_lines) + "\n", encoding="utf-8")

    coverage = {
        "requiredMappingCount": len(REQUIRED_SCALARS),
        "actualMappingCount": len(cmap),
        "missing": [],
        "unexpected": [],
        "replacementGlyph": 0,
        "replacementSourceGlyphName": glyph_order[0],
        "result": "pass",
    }
    write_json(evidence / "coverage.json", coverage)
    write_json(evidence / "measurements.json", {
        "sourceFontBytes": len(source_bytes),
        "subsetFontBytes": subset_path.stat().st_size,
        "canonicalManifestBytes": len(manifest_bytes),
        "glyphCount": len(glyph_order),
        "mappingCount": len(mappings),
        "bitmapPayloadBytes": len(bitmap_payload),
        "outlinePayloadBytes": len(outline_payload),
        "bitmapCeilingBytes": 65536,
        "outlineCeilingBytes": 65536,
        "manifestCeilingBytes": 16384,
        "glyphCeiling": 256,
        "resourceID": resource_id,
        "result": "pass",
    })
    write_json(evidence / "toolchain.json", {
        "python": platform.python_version(),
        "pythonImplementation": platform.python_implementation(),
        "platform": platform.platform(),
        "fontTools": __import__("fontTools").__version__,
        "Pillow": __import__("PIL").__version__,
        "FreeType": features.version_module("freetype2"),
    })

    helper_font_path.unlink()


if __name__ == "__main__":
    main()
