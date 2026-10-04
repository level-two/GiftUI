#!/usr/bin/env python3
"""Clean two-table generator from measured projections and explicit schema policy.

No generated Swift output is an input. Templates contain codec/scaffold code,
not previously populated topology cases, shapes or fingerprints.
"""
from pathlib import Path
import hashlib
import json
import re
import struct
import argparse
import os
import tempfile

NAMES = ("StaticSignalAnalyzerNRFTopologyWriter.generated.swift",
         "StaticSignalAnalyzerNRFPackedSemanticRecords.generated.swift")
KINDS = {1: "proxy", 2: "vStack", 3: "hStack", 4: "zStack", 5: "spacer", 6: "text", 7: "canvas", 8: "modifier"}

def require(condition, message):
    if not condition:
        raise ValueError(message)


def validate(rows, policy):
    require(0 < len(rows) <= policy["scope_capacity"], "scope capacity")
    ids = set()
    for index, row in enumerate(rows):
        require(row["ordinal"] == index, "contiguous ordinals")
        for key, maximum in (("identity", 65534), ("parent", 65535), ("child", 65535),
                             ("sibling", 65535), ("kind", 8), ("flags", 255),
                             ("aux", 65535), ("p0", 4294967295), ("p1", 4294967295)):
            require(type(row[key]) is int and 0 <= row[key] <= maximum, "field range")
        require(row["identity"] != 0 and row["identity"] not in ids, "unique nonzero identity")
        ids.add(row["identity"])
        require(row["kind"] in KINDS, "supported kind")
        if row["kind"] == 8:
            require(row["flags"] in (1, 2, 11, 12, 17, 25, 65), "supported modifier")
        for key in ("parent", "child", "sibling"):
            require(row[key] == 65535 or row[key] < len(rows), "relation range")
        require((index == 0) == (row["parent"] == 65535), "single root")
        if index:
            require(row["parent"] < index, "root-first acyclic parents")
        require(isinstance(row["text"], str), "text payload")
    visited = set()
    def walk(index):
        require(index not in visited, "tree cycle or duplicate reachability")
        visited.add(index)
        child = rows[index]["child"]
        while child != 65535:
            require(rows[child]["parent"] == index, "parent/child agreement")
            walk(child)
            child = rows[child]["sibling"]
    require(rows[0]["sibling"] == 65535, "root sibling")
    walk(0)
    require(len(visited) == len(rows), "complete reachability")
    require(sum(r["kind"] == 1 for r in rows) == policy["action_count"], "schema action count")
    live = set(policy["live_modifier_identities"])
    require(len(live) == len(policy["live_modifier_identities"]) and live <= ids, "live bindings")
    require(all(r["kind"] == 8 and r["flags"] not in (2, 11, 12) for r in rows if r["identity"] in live), "live modifier kind")
    expression = r"(?:0|UInt32\(layout\.(?:errorLineHeight|headerHeight|headerTextWidth|gridWidth|gridHeight|traceWidth|traceHeight|buttonSize|rulerLabelWidth|labelWidth)(?: - 4)?\))"
    for identity, values in policy["geometry_by_identity"].items():
        require(int(identity) in ids and len(values) == 2 and all(re.fullmatch(expression, v) for v in values), "geometry bindings")
        require(next(r for r in rows if r["identity"] == int(identity))["flags"] in (11, 12), "geometry modifier kind")

def shape(rows):
    return b"".join(struct.pack("<HHHHB", *(r[key] for key in ("identity", "parent", "child", "sibling", "kind"))) for r in rows)

def fingerprint(rows):
    value = 0xcbf29ce484222325
    for byte in shape(rows):
        value = ((value ^ byte) * 0x100000001b3) & ((1 << 64) - 1)
    return value

def ordinal_func(name, records, field="ordinal"):
    cases = "\n".join(f"        case {i}: {r[field]}" for i, r in enumerate(records[:-1]))
    return f"""    private static func {name}(at index: UInt16) -> UInt16 {{
        switch index {{
{cases}
        default: {records[-1][field]}
        }}
    }}"""

def generate(bundle, source_root, output):
    policy = json.loads((bundle / "policy.json").read_text())
    require(policy["schema"] == 1, "schema version")
    registered = {
        "Sources/SignalAnalyzerPresentation/SignalAnalyzerView.swift",
        "Sources/SignalAnalyzerPresentation/SignalAnalyzerLayoutConstraints.swift",
        "Sources/SignalAnalyzerPresentation/SignalAnalyzerWaveformGeometry.swift",
        "Sources/SignalAnalyzerPresentation/SignalAnalyzerPresentationValues.swift",
    }
    require(set(policy["source_hashes"]) == registered, "registered declaration set")
    require(policy["scope_capacity"] == 98 and policy["action_count"] == 3, "supported binding schema")
    projections = {}
    for variant, entry in policy["projection_sources"].items():
        path = Path(entry["path"])
        require(not path.is_absolute() and ".." not in path.parts, "projection path")
        data = (source_root / path).read_bytes()
        require(hashlib.sha256(data).hexdigest() == entry["sha256"], "stale registered projection")
        projections[variant] = json.loads(data)
    require(set(projections) == {"normal", "diagnostic"}, "projection variants")
    normal, diagnostic = projections["normal"], projections["diagnostic"]
    for rows in (normal, diagnostic):
        validate(rows, policy)
    require(shape(normal) == shape(diagnostic), "variant topology agreement")
    for path, expected in policy["source_hashes"].items():
        require(path.startswith("Sources/") and ".." not in Path(path).parts, "source path")
        require(hashlib.sha256((source_root / path).read_bytes()).hexdigest() == expected, "stale registered declaration source")
    primitives = [r for r in normal if r["kind"] in (2, 3, 4, 5)]
    modifiers = [r for r in normal if r["kind"] == 8 and r["flags"] in (2, 11, 12)]
    live = [r for r in normal if r["identity"] in policy["live_modifier_identities"]]
    styles = [r for r in normal if r["kind"] == 8 and r not in live and r not in modifiers]
    actions = [r for r in normal if r["kind"] == 1]
    canvases = [r for r in normal if r["kind"] == 7]
    for row in primitives + modifiers + styles:
        other = diagnostic[row["ordinal"]]
        require(all(row[k] == other[k] for k in ("flags", "aux", "p0", "p1")), "invariant variant payloads")
    tokens = {"NORMAL_SHAPE": shape(normal).hex(), "DIAGNOSTIC_SHAPE": shape(diagnostic).hex(),
              "NORMAL_FINGERPRINT": str(fingerprint(normal)), "DIAGNOSTIC_FINGERPRINT": str(fingerprint(diagnostic)),
              "SCOPE_COUNT": str(len(normal)), "PRIMITIVE_COUNT": str(len(primitives)),
              "LAYOUT_MODIFIER_COUNT": str(len(modifiers)), "LIVE_MODIFIER_COUNT": str(len(live)),
              "CANVAS_COUNT": str(len(canvases)), "TEXT_COUNT": str(sum(r["kind"] == 6 for r in normal))}
    for name, records, field in (("invariantPrimitiveOrdinal", primitives, "ordinal"),
        ("invariantModifierOrdinal", modifiers, "ordinal"), ("liveModifierOrdinal", live, "ordinal"),
        ("actionOrdinal", actions, "ordinal"), ("actionIdentity", actions, "identity"),
        ("canvasOrdinal", canvases, "ordinal"), ("canvasIdentity", canvases, "identity")):
        tokens[name] = ordinal_func(name, records, field)
    cases = "\n".join(f"        case {i}: (.{KINDS[r['kind']]}, {r['aux']}, {r['p0']})" for i, r in enumerate(primitives[:-1]))
    last = primitives[-1]
    tokens["invariantPrimitivePayload"] = f"""    private static func invariantPrimitivePayload(at slot: UInt16)
        -> (kind: StaticSignalAnalyzerNRFScopeKind, auxiliary: UInt16, payload0: UInt32) {{
        switch slot {{
{cases}
        default: (.{KINDS[last['kind']]}, {last['aux']}, {last['p0']})
        }}
    }}"""
    cases = []
    for i, row in enumerate(modifiers):
        p0, p1 = policy["geometry_by_identity"].get(str(row["identity"]), (str(row["p0"]), str(row["p1"])))
        label = "default" if i == len(modifiers) - 1 else f"case {i}"
        cases.append(f"        {label}: ({row['flags']}, {row['aux']}, {p0}, {p1})")
    tokens["invariantModifierPayload"] = """    private static func invariantModifierPayload(at slot: UInt16)
        -> (flags: UInt8, auxiliary: UInt16, payload0: UInt32, payload1: UInt32) {
        let layout = SignalAnalyzerLayoutConstraints.reference
        return switch slot {
""" + "\n".join(cases) + "\n        }\n    }"
    tokens["invariantStyle"] = """    private static func invariantStyle(at ordinal: UInt16) -> (flags: UInt8, color: UInt32)? {
        switch ordinal {
""" + "\n".join(f"        case {r['ordinal']}: ({r['flags']}, {r['p0']})" for r in styles) + "\n        default: nil\n        }\n    }"
    sources = []
    for template in ("Topology.swift.in", "PackedRecords.swift.in"):
        source = (bundle / "templates" / template).read_text()
        source = re.sub(r"@@([A-Za-z_]+)@@", lambda m: tokens[m[1]], source)
        require("@@" not in source, "complete template expansion")
        sources.append(source)
    require(not output.exists() or not any(output.iterdir()), "clean output directory required")
    output.mkdir(parents=True, exist_ok=True)
    for name, source in zip(NAMES, sources):
        (output / name).write_text(source)
    return {name: hashlib.sha256(source.encode()).hexdigest() for name, source in zip(NAMES, sources)}

def main():
    root = Path(__file__).resolve().parents[2]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input-bundle", type=Path, default=root / "scripts/contracts/nrf-topology")
    parser.add_argument("--source-root", type=Path, default=root)
    parser.add_argument("--output", type=Path, help="emit both files into an empty directory")
    parser.add_argument("--check", action="store_true", help="compare freshly emitted files with maintained outputs")
    args = parser.parse_args()
    require(not (args.output and args.check), "--output and --check are mutually exclusive")
    if args.output:
        hashes = generate(args.input_bundle, args.source_root, args.output)
    else:
        with tempfile.TemporaryDirectory(prefix="giftui-topology-") as temporary:
            output = Path(temporary) / "clean"
            hashes = generate(args.input_bundle, args.source_root, output)
            destination = root / "Sources/SignalAnalyzerTargetHost/Generated"
            if args.check:
                for name in NAMES:
                    require((destination / name).read_bytes() == (output / name).read_bytes(),
                            f"stale generated output: {name}")
            else:
                # Validate/render the complete pair before touching either output.
                # Other independently generated files are outside this generator.
                for name in NAMES:
                    path = destination / name
                    temporary_path = path.with_name("." + name + ".tmp")
                    temporary_path.write_bytes((output / name).read_bytes())
                    os.replace(temporary_path, path)
    print(json.dumps(hashes, sort_keys=True))


if __name__ == "__main__":
    try:
        main()
    except (ValueError, KeyError, OSError, TypeError, IndexError) as error:
        raise SystemExit(f"nRF topology generation failed: {error}") from error
