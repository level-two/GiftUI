"""Clean two-table generator from measured projections and explicit schema policy.

No generated Swift output is an input. Templates contain codec/scaffold code,
not previously populated topology cases, shapes or fingerprints.
"""
from pathlib import Path
import hashlib
import json
import re
import struct
import sys

NAMES = ("StaticSignalAnalyzerNRFTopologyWriter.generated.swift",
         "StaticSignalAnalyzerNRFPackedSemanticRecords.generated.swift")
KINDS = {1: "proxy", 2: "vStack", 3: "hStack", 4: "zStack", 5: "spacer", 6: "text", 7: "canvas", 8: "modifier"}

def validate(rows, policy):
    assert 0 < len(rows) <= policy["scope_capacity"], "scope capacity"
    ids = set()
    for index, row in enumerate(rows):
        assert row["ordinal"] == index, "contiguous ordinals"
        for key, maximum in (("identity", 65534), ("parent", 65535), ("child", 65535),
                             ("sibling", 65535), ("kind", 8), ("flags", 255),
                             ("aux", 65535), ("p0", 4294967295), ("p1", 4294967295)):
            assert type(row[key]) is int and 0 <= row[key] <= maximum, "field range"
        assert row["identity"] != 0 and row["identity"] not in ids, "unique nonzero identity"
        ids.add(row["identity"])
        assert row["kind"] in KINDS, "supported kind"
        if row["kind"] == 8:
            assert row["flags"] in (1, 2, 11, 12, 17, 25, 65), "supported modifier"
        for key in ("parent", "child", "sibling"):
            assert row[key] == 65535 or row[key] < len(rows), "relation range"
        assert (index == 0) == (row["parent"] == 65535), "single root"
        if index:
            assert row["parent"] < index, "root-first acyclic parents"
        assert isinstance(row["text"], str), "text payload"
    visited = set()
    def walk(index):
        assert index not in visited, "tree cycle or duplicate reachability"
        visited.add(index)
        child = rows[index]["child"]
        while child != 65535:
            assert rows[child]["parent"] == index, "parent/child agreement"
            walk(child)
            child = rows[child]["sibling"]
    assert rows[0]["sibling"] == 65535, "root sibling"
    walk(0)
    assert len(visited) == len(rows), "complete reachability"
    assert sum(r["kind"] == 1 for r in rows) == policy["action_count"], "schema action count"
    live = set(policy["live_modifier_identities"])
    assert len(live) == len(policy["live_modifier_identities"]) and live <= ids, "live bindings"
    assert all(r["kind"] == 8 and r["flags"] not in (2, 11, 12) for r in rows if r["identity"] in live), "live modifier kind"
    expression = r"(?:0|UInt32\(layout\.(?:errorLineHeight|headerHeight|headerTextWidth|gridWidth|gridHeight|traceWidth|traceHeight|buttonSize|rulerLabelWidth|labelWidth)(?: - 4)?\))"
    for identity, values in policy["geometry_by_identity"].items():
        assert int(identity) in ids and len(values) == 2 and all(re.fullmatch(expression, v) for v in values), "geometry bindings"
        assert next(r for r in rows if r["identity"] == int(identity))["flags"] in (11, 12), "geometry modifier kind"

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
    assert policy["schema"] == 1, "schema version"
    normal = json.loads((bundle / "normal.json").read_text())
    diagnostic = json.loads((bundle / "diagnostic.json").read_text())
    for rows in (normal, diagnostic):
        validate(rows, policy)
    assert shape(normal) == shape(diagnostic), "variant topology agreement"
    for path, expected in policy["source_hashes"].items():
        assert path.startswith("Sources/") and ".." not in Path(path).parts, "source path"
        assert hashlib.sha256((source_root / path).read_bytes()).hexdigest() == expected, "stale registered declaration source"
    primitives = [r for r in normal if r["kind"] in (2, 3, 4, 5)]
    modifiers = [r for r in normal if r["kind"] == 8 and r["flags"] in (2, 11, 12)]
    live = [r for r in normal if r["identity"] in policy["live_modifier_identities"]]
    styles = [r for r in normal if r["kind"] == 8 and r not in live and r not in modifiers]
    actions = [r for r in normal if r["kind"] == 1]
    canvases = [r for r in normal if r["kind"] == 7]
    for row in primitives + modifiers + styles:
        other = diagnostic[row["ordinal"]]
        assert all(row[k] == other[k] for k in ("flags", "aux", "p0", "p1")), "invariant variant payloads"
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
        assert "@@" not in source, "complete template expansion"
        sources.append(source)
    assert not output.exists() or not any(output.iterdir()), "clean output directory required"
    output.mkdir(parents=True, exist_ok=True)
    for name, source in zip(NAMES, sources):
        (output / name).write_text(source)
    return {name: hashlib.sha256(source.encode()).hexdigest() for name, source in zip(NAMES, sources)}

if __name__ == "__main__":
    assert len(sys.argv) == 4, "usage: generate.py INPUT_BUNDLE DECLARATION_SOURCE_ROOT EMPTY_OUTPUT"
    print(json.dumps(generate(*(Path(value) for value in sys.argv[1:]))))
