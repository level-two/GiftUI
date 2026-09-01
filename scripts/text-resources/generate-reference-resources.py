#!/usr/bin/env python3
"""Generate the deterministic SPEC-005 reference-resource Swift inputs."""

from __future__ import annotations

import argparse
import hashlib
import json
import struct
import sys
from pathlib import Path
from typing import List, Sequence, Tuple

import fontTools
from fontTools import subset
from fontTools.pens.recordingPen import DecomposingRecordingPen
from fontTools.ttLib import TTFont
from PIL import ImageFont, __version__ as pillow_version, features


SCRIPT_DIRECTORY = Path(__file__).resolve().parent
PINS_PATH = SCRIPT_DIRECTORY / "reference-generation-pins.json"
PIXEL_SIZE = 16
RESOURCE_NAME = "GiftUI Reference Sans"
POSTSCRIPT_NAME = "GiftUIReferenceSans-Regular"
REQUIRED_SCALARS = tuple(range(0x20, 0x7F)) + (0x00B0,)
CANONICAL_TAG = b"GiftUITextResources/v1"


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def load_pins() -> dict:
    return json.loads(PINS_PATH.read_text(encoding="utf-8"))


def check_tools(pins: dict) -> None:
    observed = {
        "python": ".".join(str(value) for value in sys.version_info[:3]),
        "fontTools": fontTools.__version__,
        "Pillow": pillow_version,
        "FreeType": features.version_module("freetype2"),
    }
    if observed != pins["tools"]:
        raise SystemExit(
            "reference generator tool-pin mismatch: "
            + json.dumps({"expected": pins["tools"], "observed": observed}, sort_keys=True)
        )


def write_text(path: Path, text: str) -> None:
    with path.open("w", encoding="utf-8", newline="\n") as stream:
        stream.write(text)


def write_json(path: Path, value: object) -> None:
    write_text(path, json.dumps(value, indent=2, sort_keys=True) + "\n")


def checked_int16(value: float) -> bytes:
    rounded = round(value)
    if not -32768 <= rounded <= 32767:
        raise SystemExit(f"outline coordinate is outside Int16: {rounded}")
    return struct.pack(">h", rounded)


def derive_subset(source: Path, destination: Path) -> TTFont:
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
    names.setName("Inter 4.1 derived for GiftUI SPEC-005", 3, 3, 1, 0x0409)
    names.setName(f"{RESOURCE_NAME} Regular", 4, 3, 1, 0x0409)
    names.setName(POSTSCRIPT_NAME, 6, 3, 1, 0x0409)
    names.setName(RESOURCE_NAME, 16, 3, 1, 0x0409)
    names.setName("Regular", 17, 3, 1, 0x0409)
    font.recalcTimestamp = False
    font.save(destination, reorderTables=True)
    return TTFont(destination, recalcTimestamp=False)


def encode_outline(glyph_set: object, glyph_name: str, units_per_em: int) -> bytes:
    pen = DecomposingRecordingPen(glyph_set)
    glyph_set[glyph_name].draw(pen)
    result = bytearray(struct.pack(">BHH", 1, units_per_em, PIXEL_SIZE))
    opcodes = {
        "moveTo": 1,
        "lineTo": 2,
        "qCurveTo": 3,
        "curveTo": 4,
        "closePath": 5,
        "endPath": 6,
    }
    for operation, operands in pen.value:
        if operation not in opcodes:
            raise SystemExit(f"unsupported outline operation: {operation}")
        result.append(opcodes[operation])
        if operation in ("closePath", "endPath"):
            continue
        result.append(len(operands))
        for point in operands:
            if point is None:
                result.extend((0x7F, 0xFF, 0x7F, 0xFF))
            else:
                result.extend(checked_int16(point[0]))
                result.extend(checked_int16(point[1]))
    return bytes(result)


def encode_bitmap(mask: object, width: int, height: int) -> Tuple[bytes, int]:
    row_bytes = (width + 7) // 8
    pixels = list(mask)
    if len(pixels) != width * height:
        raise SystemExit("rasterizer returned an unexpected mask length")
    result = bytearray(row_bytes * height)
    for y in range(height):
        for x in range(width):
            if pixels[y * width + x] >= 128:
                result[y * row_bytes + x // 8] |= 1 << (7 - x % 8)
    return bytes(result), row_bytes


def canonical_manifest(
    instance: dict,
    mappings: Sequence[dict],
    metrics: Sequence[dict],
    realizations: Sequence[dict],
) -> bytes:
    result = bytearray(CANONICAL_TAG)
    result.extend(struct.pack(">HH", 1, 1))
    result.extend(struct.pack(
        ">HiiiHHH",
        0,
        instance["ascent"],
        instance["descent"],
        instance["lineGap"],
        instance["replacementGlyph"],
        instance["glyphCount"],
        instance["mappingCount"],
    ))
    for mapping in mappings:
        result.extend(struct.pack(">IH", mapping["scalar"], mapping["glyph"]))
    for metric in metrics:
        result.extend(struct.pack(
            ">Hiiiii",
            metric["glyph"],
            metric["advanceX"],
            metric["offsetX"],
            metric["offsetY"],
            metric["width"],
            metric["height"],
        ))
    result.extend(struct.pack(">H", len(realizations)))
    for realization in realizations:
        result.extend(struct.pack(
            ">HHBHI",
            realization["id"],
            0,
            realization["kind"],
            instance["glyphCount"],
            len(realization["payload"]),
        ))
        result.extend(bytes.fromhex(realization["digest"]))
        for record in realization["records"]:
            result.extend(struct.pack(
                ">HIIHHH",
                record["glyph"],
                record["offset"],
                record["byteCount"],
                record["rowByteCount"],
                record["pixelWidth"],
                record["pixelHeight"],
            ))
    return bytes(result)


def digest_expression(value: str) -> str:
    words = [value[index:index + 8] for index in range(0, 64, 8)]
    arguments = ", ".join(f"word{index}: 0x{word}" for index, word in enumerate(words))
    return f"TextResourceDigest({arguments})"


def emit_catalogue(
    resource_id: str,
    manifest_count: int,
    instance: dict,
    mappings: Sequence[dict],
    metrics: Sequence[dict],
    realizations: Sequence[dict],
) -> str:
    lines = [
        "// Generated by scripts/text-resources/generate-reference-resources.py. Do not edit.",
        "import GiftUI",
        "import GiftUITextResources",
        "",
        "enum _GiftUIReferenceGeneratedCatalogue {",
        f"    static let resourceDigest = {digest_expression(resource_id)}",
        "    static let resourceID = FontResourceID(rawValue: resourceDigest)",
        "    static let instanceID = FontInstanceID(resource: resourceID, instanceIndex: 0)",
        f"    static let canonicalManifestByteCount: UInt32 = {manifest_count}",
        f"    static let glyphCount: UInt16 = {instance['glyphCount']}",
        f"    static let mappingCount: UInt16 = {instance['mappingCount']}",
        "    static let descriptor = TextResourceDescriptor(",
        "        schemaVersion: 1,",
        "        resource: resourceID,",
        "        instanceCount: 1,",
        "        realizationCount: 2,",
        "        canonicalManifestByteCount: canonicalManifestByteCount",
        "    )",
        "    static let instanceDescriptor = FontInstanceDescriptor(",
        "        id: instanceID,",
        f"        lineMetrics: FontLineMetrics(ascent: {instance['ascent']}, descent: {instance['descent']}, lineGap: {instance['lineGap']}),",
        f"        replacementGlyph: GlyphID(rawValue: {instance['replacementGlyph']}),",
        "        glyphCount: glyphCount,",
        "        mappingCount: mappingCount",
        "    )",
        "",
        "    static func mapping(at index: UInt16) -> ScalarGlyphMappingRecord? {",
        "        switch index {",
    ]
    for index, mapping in enumerate(mappings):
        lines.append(
            f"        case {index}: return ScalarGlyphMappingRecord(scalarValue: 0x{mapping['scalar']:04x}, glyph: GlyphID(rawValue: {mapping['glyph']}))"
        )
    lines.extend(["        default: return nil", "        }", "    }", ""])
    lines.extend([
        "    static func metrics(for glyph: GlyphID) -> GlyphMetrics? {",
        "        switch glyph.rawValue {",
    ])
    for metric in metrics:
        lines.append(
            "        case {glyph}: return GlyphMetrics(advanceX: {advanceX}, offsetX: {offsetX}, offsetY: {offsetY}, inkSize: Size(width: {width}, height: {height})!)".format(**metric)
        )
    lines.extend(["        default: return nil", "        }", "    }", ""])
    lines.extend([
        "    static func realization(at index: UInt16, instance: FontInstanceID) -> RasterRealizationDescriptor? {",
        "        switch index {",
    ])
    kinds = ["monochromeBitmap1", "packagedOutline"]
    for realization in realizations:
        lines.append(
            "        case {id}: return RasterRealizationDescriptor(id: RasterRealizationID(rawValue: {id}), instance: instance, kind: .{kindName}, glyphCount: glyphCount, payloadByteCount: {count}, payloadDigest: {digest})".format(
                id=realization["id"],
                kindName=kinds[realization["kind"]],
                count=len(realization["payload"]),
                digest=digest_expression(realization["digest"]),
            )
        )
    lines.extend(["        default: return nil", "        }", "    }", ""])
    lines.extend([
        "    static func record(for glyph: GlyphID, realization: RasterRealizationID) -> GlyphRasterRecord? {",
        "        switch (realization.rawValue, glyph.rawValue) {",
    ])
    for realization in realizations:
        for record in realization["records"]:
            lines.append(
                "        case ({realization}, {glyph}): return GlyphRasterRecord(glyph: glyph, offset: {offset}, byteCount: {byteCount}, rowByteCount: {rowByteCount}, pixelWidth: {pixelWidth}, pixelHeight: {pixelHeight})".format(
                    realization=realization["id"], **record
                )
            )
    lines.extend(["        default: return nil", "        }", "    }", "}", ""])
    return "\n".join(lines)


def emit_payload(type_name: str, payload: bytes) -> str:
    lines = [
        "// Generated by scripts/text-resources/generate-reference-resources.py. Do not edit.",
        "import GiftUITextResources",
        "",
        f"enum {type_name} {{",
        f"    static let byteCount: UInt32 = {len(payload)}",
        f"    static let digest = {digest_expression(sha256(payload))}",
        "    static let bytes = (",
    ]
    chunks = [payload[index:index + 32] for index in range(0, len(payload), 32)]
    for chunk in chunks:
        values = ", ".join(f"0x{value:02x} as UInt8" for value in chunk)
        lines.append(f"        ({values}),")
    lines.extend(["    )", "}", ""])
    return "\n".join(lines)


def generate(source: Path, license_path: Path, output: Path, pins: dict) -> None:
    source_bytes = source.read_bytes()
    license_bytes = license_path.read_bytes()
    if sha256(source_bytes) != pins["inputs"]["sourceFontSHA256"]:
        raise SystemExit("adopted Inter source hash mismatch")
    if sha256(license_bytes) != pins["inputs"]["licenseSHA256"]:
        raise SystemExit("adopted Inter license hash mismatch")

    output.mkdir(parents=True, exist_ok=False)
    subset_path = output.parent / f"{output.name}-subset.ttf"
    helper_path = output.parent / f"{output.name}-raster-helper.ttf"
    font = derive_subset(source, subset_path)
    glyph_order = font.getGlyphOrder()
    cmap = font.getBestCmap()
    if tuple(sorted(cmap)) != REQUIRED_SCALARS:
        raise SystemExit("derived mapping set differs from required coverage")
    if len(glyph_order) > 256:
        raise SystemExit("derived glyph count exceeds SPEC-005 capacity")

    scalar_by_name = {name: scalar for scalar, name in cmap.items()}
    render_scalar_by_name = dict(scalar_by_name)
    render_scalar_by_name[glyph_order[0]] = 0xFFFD
    helper = TTFont(subset_path, recalcTimestamp=False)
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
    glyph_set = font.getGlyphSet()
    units_per_em = font["head"].unitsPerEm
    mappings = [
        {"scalar": scalar, "glyph": glyph_order.index(name)}
        for scalar, name in sorted(cmap.items())
    ]
    metrics: List[dict] = []
    bitmap_payload = bytearray()
    outline_payload = bytearray()
    bitmap_records: List[dict] = []
    outline_records: List[dict] = []

    for glyph, glyph_name in enumerate(glyph_order):
        character = chr(render_scalar_by_name[glyph_name])
        mask, offset = rasterizer.getmask2(character, mode="L", anchor="ls")
        width, height = mask.size
        bitmap, row_bytes = encode_bitmap(mask, width, height)
        bitmap_records.append({
            "glyph": glyph,
            "offset": len(bitmap_payload),
            "byteCount": len(bitmap),
            "rowByteCount": row_bytes,
            "pixelWidth": width,
            "pixelHeight": height,
        })
        bitmap_payload.extend(bitmap)
        outline = encode_outline(glyph_set, glyph_name, units_per_em)
        outline_records.append({
            "glyph": glyph,
            "offset": len(outline_payload),
            "byteCount": len(outline),
            "rowByteCount": 0,
            "pixelWidth": width,
            "pixelHeight": height,
        })
        outline_payload.extend(outline)
        metrics.append({
            "glyph": glyph,
            "advanceX": round(rasterizer.getlength(character)),
            "offsetX": offset[0],
            "offsetY": offset[1],
            "width": width,
            "height": height,
        })

    realizations = [
        {
            "id": 0,
            "kind": 0,
            "payload": bytes(bitmap_payload),
            "digest": sha256(bitmap_payload),
            "records": bitmap_records,
        },
        {
            "id": 1,
            "kind": 1,
            "payload": bytes(outline_payload),
            "digest": sha256(outline_payload),
            "records": outline_records,
        },
    ]
    instance = {
        "ascent": ascent,
        "descent": descent,
        "lineGap": 0,
        "replacementGlyph": 0,
        "glyphCount": len(glyph_order),
        "mappingCount": len(mappings),
    }
    manifest = canonical_manifest(instance, mappings, metrics, realizations)
    observed = {
        "bitmapPayloadSHA256": realizations[0]["digest"],
        "canonicalManifestByteCount": len(manifest),
        "glyphCount": len(glyph_order),
        "mappingCount": len(mappings),
        "outlinePayloadSHA256": realizations[1]["digest"],
        "resourceID": sha256(manifest),
    }
    if observed != pins["adopted"]:
        raise SystemExit(
            "generated reference identity differs from adopted SPEC-005 input: "
            + json.dumps({"expected": pins["adopted"], "observed": observed}, sort_keys=True)
        )

    outputs = {
        "ReferenceCatalogue.generated.swift": emit_catalogue(
            observed["resourceID"], len(manifest), instance, mappings, metrics, realizations
        ),
        "ReferenceBitmapPayload.generated.swift": emit_payload(
            "_GiftUIReferenceGeneratedBitmapPayload", bytes(bitmap_payload)
        ),
        "ReferenceOutlinePayload.generated.swift": emit_payload(
            "_GiftUIReferenceGeneratedOutlinePayload", bytes(outline_payload)
        ),
    }
    for name, contents in outputs.items():
        write_text(output / name, contents)

    write_json(output / "generation-manifest.json", {
        "derivedName": RESOURCE_NAME,
        "generator": "scripts/text-resources/generate-reference-resources.py",
        "inputs": pins["inputs"],
        "license": "SIL Open Font License 1.1",
        "outputs": {
            name: {"bytes": len(contents.encode("utf-8")), "sha256": sha256(contents.encode("utf-8"))}
            for name, contents in sorted(outputs.items())
        },
        "resource": observed,
        "tools": pins["tools"],
        "upstream": {"project": "Inter", "version": "4.1"},
    })
    subset_path.unlink()
    helper_path.unlink()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-font", type=Path)
    parser.add_argument("--license", type=Path)
    parser.add_argument("--output-directory", type=Path)
    parser.add_argument("--check-tools-only", action="store_true")
    arguments = parser.parse_args()
    pins = load_pins()
    check_tools(pins)
    if arguments.check_tools_only:
        return
    if not arguments.source_font or not arguments.license or not arguments.output_directory:
        parser.error("source font, license, and output directory are required")
    generate(
        arguments.source_font,
        arguments.license,
        arguments.output_directory,
        pins,
    )


if __name__ == "__main__":
    main()
