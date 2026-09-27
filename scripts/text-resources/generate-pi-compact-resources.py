#!/usr/bin/env python3
"""Generate the Pi-only 8 px bitmap font from the pinned SPEC-005 source."""

from __future__ import annotations

import argparse
import importlib.util
from pathlib import Path

from PIL import ImageFont


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "ThirdParty/Inter-4.1/Inter-Regular.ttf"
LICENSE = ROOT / "ThirdParty/Inter-4.1/LICENSE.txt"
REFERENCE = Path(__file__).with_name("generate-reference-resources.py")
SPEC = importlib.util.spec_from_file_location("giftui_reference_generator", REFERENCE)
assert SPEC is not None and SPEC.loader is not None
ref = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(ref)
PIXEL_SIZE = 10
INK_THRESHOLD = 64


def encode_bitmap(mask: object, width: int, height: int) -> tuple[bytes, int]:
    row_bytes = (width + 7) // 8
    pixels = list(mask)
    if len(pixels) != width * height:
        raise SystemExit("Pi rasterizer returned an unexpected mask length")
    result = bytearray(row_bytes * height)
    for y in range(height):
        for x in range(width):
            if pixels[y * width + x] >= INK_THRESHOLD:
                result[y * row_bytes + x // 8] |= 1 << (7 - x % 8)
    return bytes(result), row_bytes


def generate(output: Path) -> None:
    pins = ref.load_pins()
    ref.check_tools(pins)
    if ref.sha256(SOURCE.read_bytes()) != pins["inputs"]["sourceFontSHA256"]:
        raise SystemExit("Pi font source hash mismatch")
    if ref.sha256(LICENSE.read_bytes()) != pins["inputs"]["licenseSHA256"]:
        raise SystemExit("Pi font license hash mismatch")
    output.mkdir(parents=True, exist_ok=True)
    subset_path = output.parent / (output.name + "-subset.ttf")
    helper_path = output.parent / (output.name + "-helper.ttf")
    font = ref.derive_subset(SOURCE, subset_path)
    glyph_order = font.getGlyphOrder()
    cmap = font.getBestCmap()
    if tuple(sorted(cmap)) != ref.REQUIRED_SCALARS:
        raise SystemExit("Pi font scalar coverage mismatch")
    render_scalar_by_name = {name: scalar for scalar, name in cmap.items()}
    render_scalar_by_name[glyph_order[0]] = 0xFFFD
    helper = ref.TTFont(subset_path, recalcTimestamp=False)
    private_scalar = 0xE000
    for glyph_name in glyph_order[1:]:
        if glyph_name in render_scalar_by_name:
            continue
        render_scalar_by_name[glyph_name] = private_scalar
        for table in helper["cmap"].tables:
            if table.isUnicode():
                table.cmap[private_scalar] = glyph_name
        private_scalar += 1
    helper.save(helper_path, reorderTables=True)

    rasterizer = ImageFont.truetype(
        str(helper_path), PIXEL_SIZE, layout_engine=ImageFont.Layout.BASIC
    )
    ascent, descent = rasterizer.getmetrics()
    mappings = [
        {"scalar": scalar, "glyph": glyph_order.index(name)}
        for scalar, name in sorted(cmap.items())
    ]
    metrics = []
    records = []
    payload = bytearray()
    for glyph, glyph_name in enumerate(glyph_order):
        character = chr(render_scalar_by_name[glyph_name])
        mask, offset = rasterizer.getmask2(character, mode="L", anchor="ls")
        width, height = mask.size
        bitmap, row_bytes = encode_bitmap(mask, width, height)
        records.append({
            "glyph": glyph,
            "offset": len(payload),
            "byteCount": len(bitmap),
            "rowByteCount": row_bytes,
            "pixelWidth": width,
            "pixelHeight": height,
        })
        payload.extend(bitmap)
        metrics.append({
            "glyph": glyph,
            "advanceX": round(rasterizer.getlength(character)),
            "offsetX": offset[0],
            "offsetY": offset[1],
            "width": width,
            "height": height,
        })
    instance = {
        "ascent": ascent,
        "descent": descent,
        "lineGap": 0,
        "replacementGlyph": 0,
        "glyphCount": len(glyph_order),
        "mappingCount": len(mappings),
    }
    realizations = [{
        "id": 0,
        "kind": 0,
        "payload": bytes(payload),
        "digest": ref.sha256(payload),
        "records": records,
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
        "pixelSize": PIXEL_SIZE,
        "inkThreshold": INK_THRESHOLD,
        "sourceFontSHA256": pins["inputs"]["sourceFontSHA256"],
        "resourceID": ref.sha256(manifest),
        "bitmapPayloadSHA256": ref.sha256(payload),
        "canonicalManifestByteCount": len(manifest),
        "glyphCount": len(glyph_order),
        "mappingCount": len(mappings),
        "tools": pins["tools"],
        "outputs": {
            "PiCompactCatalogue.generated.swift": ref.sha256(catalogue.encode()),
            "PiCompactBitmapPayload.generated.swift": ref.sha256(bitmap.encode()),
        },
    })
    subset_path.unlink()
    helper_path.unlink()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-directory", required=True, type=Path)
    generate(parser.parse_args().output_directory)
