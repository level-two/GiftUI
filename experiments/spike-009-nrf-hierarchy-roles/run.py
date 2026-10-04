"""Disposable EXP-001 experiment: real-module Embedded probe and role bindings."""
from pathlib import Path
import gzip
import hashlib
import json
import os
import re
import shlex
import shutil
import subprocess

root = Path.cwd()
spike = root / "experiments/spike-009-nrf-hierarchy-roles"
evidence = spike / "evidence"
evidence.mkdir(parents=True, exist_ok=True)
out = root / ".build/nrf52840/spike-009-hierarchy-roles"
out.mkdir(parents=True, exist_ok=True)
record = {"revision": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(), "inputs": {}}
def digest(path):
    record["inputs"][str(path.relative_to(root))] = hashlib.sha256(path.read_bytes()).hexdigest()
    return path.read_text()

# Exact selected compiler/options, without reusing an accidental host compiler.
domain_source = out / "ActualDomain.swift"
domain_paths = sorted((root / "Sources/SignalAnalyzerDomain").glob("*.swift"))
domain_source.write_text("\n".join(digest(p) for p in domain_paths))
cache = root / ".build/nrf52840/signal-analyzer-static/CMakeCache.txt"
cmake_values = dict(re.findall(r"^([^#/:]+):[^=]+=(.*)$", cache.read_text(), re.M))
ninja = cmake_values["CMAKE_MAKE_PROGRAM"]
commands = subprocess.check_output([ninja, "-C", str(cache.parent), "-t", "commands"], text=True)
command = shlex.split(next(line for line in commands.splitlines() if line.endswith("/SignalAnalyzerDomain.swift")))
for option in ("-output-file-map", "-emit-module-path"):
    index = command.index(option)
    del command[index:index+2]
command = command[:-1] + ["-emit-module-path", str(out / "SignalAnalyzerDomain.swiftmodule"),
                          "-o", str(out / "SignalAnalyzerDomain.o"), str(domain_source),
                          "-module-cache-path", str(out / "clang-cache")]
result = subprocess.run(command, capture_output=True, text=True,
                        env=dict(os.environ, CLANG_MODULE_CACHE_PATH=str(out / "clang-cache")))
record["direct_module_probe"] = {"command": command, "exit_code": result.returncode,
                                 "diagnostics": result.stdout + result.stderr}
assert result.returncode != 0 and "EmbeddedRestrictions" in result.stderr
assert "any SignalAcquisitionRepository" in result.stderr

# Infer roles from unique text anchors and their local structural context;
# there are no numeric ordinals in the anchor rules.
fixtures = root / "Tests/ContractFixtures/SPEC001"
normal = json.loads(digest(fixtures / "nrf-touch-ui-projection.json"))
diagnostic = json.loads(digest(fixtures / "nrf-touch-ui-diagnostic-projection.json"))
def infer(rows):
    by_ordinal = {r["ordinal"]: r for r in rows}
    roles = {}
    def text(value):
        found = [r for r in rows if r["kind"] == 6 and r["text"] == value]
        assert len(found) == 1, (value, len(found))
        return found[0]
    def ancestors(node):
        while node["parent"] != 65535:
            node = by_ordinal[node["parent"]]
            yield node
    for role, value in {"title": "DIGITAL SIGNAL ANALYZER", "subtitle": "Four-channel acquisition",
                        "recording": "S", "shorter": "-", "longer": "+",
                        "rulerStart": "0 s", "rulerMiddle": "1 s", "rulerEnd": "2 s"}.items():
        roles[role] = text(value)
    # Diagnostic changes only the error payload; normal's empty text identifies its role.
    errors = [r for r in rows if r["kind"] == 6 and r["identity"] == error_identity]
    assert len(errors) == 1
    roles["error"] = errors[0]
    for button in ("recording", "shorter", "longer"):
        chain = []
        for node in ancestors(roles[button]):
            if node["kind"] == 1:
                proxy = node
                break
            chain.append(node)
        styles = [r for r in chain if r["kind"] == 8 and r["flags"] in (17, 25)]
        assert len(styles) == 3 and [r["flags"] for r in styles] == [25, 25, 17]
        for suffix, node in zip(("Background", "RectangleStyle", "TextStyle"), styles):
            roles[button + suffix] = node
        if button != "recording":
            disabled = by_ordinal[proxy["parent"]]
            assert disabled["kind"] == 8 and disabled["flags"] in (1, 65)
            roles[button + "Disabled"] = disabled
    for channel in range(1, 5):
        label = text(f"CH{channel}")
        row = next(r for r in ancestors(label) if r["kind"] == 3)
        low = [r for r in rows if r["kind"] == 6 and r["text"] == "LOW"
               and any(a["ordinal"] == row["ordinal"] for a in ancestors(r))]
        assert len(low) == 1
        roles[f"channel{channel}Name"] = label
        roles[f"channel{channel}Level"] = low[0]
        style = by_ordinal[low[0]["parent"]]
        assert style["flags"] == 17
        roles[f"channel{channel}LevelStyle"] = style
    return roles

empty = [r for r in normal if r["kind"] == 6 and r["text"] == ""]
assert len(empty) == 1
error_identity = empty[0]["identity"]
roles = infer(normal)
other = infer(diagnostic)
assert {k: (v["ordinal"], v["identity"]) for k, v in roles.items()} == {
    k: (v["ordinal"], v["identity"]) for k, v in other.items()}
assert len(roles) == 32
# Prove inference does not depend on the current ordinal numbers, and fails
# closed when a supposedly unique declaration anchor disappears/duplicates.
shifted = [dict(r, ordinal=r["ordinal"] + 1, **{
    field: r[field] + 1 if r[field] != 65535 else 65535 for field in ("parent", "child", "sibling")}) for r in normal]
shifted_roles = infer(shifted)
assert all(shifted_roles[name]["identity"] == node["identity"] and
           shifted_roles[name]["ordinal"] == node["ordinal"] + 1 for name, node in roles.items())
negative_anchors = []
for label, mutated in (("missing-title", [r for r in normal if r["text"] != "DIGITAL SIGNAL ANALYZER"]),
                       ("duplicate-title", normal + [dict(roles["title"], ordinal=92)])):
    try:
        infer(mutated)
    except AssertionError:
        negative_anchors.append(label)
assert len(negative_anchors) == 2
bindings = "package enum SpikeRoles {\n" + "".join(
    f"    package static let {name}{field.title()}: UInt16 = {node[field]}\n"
    for name, node in roles.items() for field in ("ordinal", "identity")) + "}\n"
(out / "SpikeRoles.swift").write_text(bindings)
ordinal_roles = {node["ordinal"]: name for name, node in roles.items()}
record["roles"] = {name: {key: node[key] for key in ("ordinal", "identity", "kind")} for name, node in roles.items()}
record["variant_roles_match"] = True
record["ordinal_shift_inference_passed"] = True
record["rejected_anchor_mutations"] = negative_anchors
record["bindings_sha256"] = hashlib.sha256(bindings.encode()).hexdigest()

host = root / "Sources/SignalAnalyzerTargetHost"
replacements = {}
path = host / "StaticSignalAnalyzerNRFModelTextWriter.swift"
text_writer = digest(path)
start = text_writer.index("    private static func value(")
prefix = text_writer[:start].replace("at: ordinal, variant", "at: record.identity, variant", 1)
prefix = prefix.replace("at: ordinal, variant", "at: old.identity, variant", 1)
body = text_writer[start:].replace("ordinal", "identity")
body = re.sub(r"case (\d+):", lambda m: "case SpikeRoles." + ordinal_roles[int(m[1])] + "Identity:", body)
replacements[path] = prefix + body

path = host / "StaticSignalAnalyzerNRFModelModifierWriter.swift"
modifier = digest(path)
modifier = modifier.replace("payload(at: ordinal, model", "payload(at: record.identity, model", 1)
modifier = modifier.replace("payload(at: ordinal, model", "payload(at: old.identity, model", 1)
start = modifier.index("    private static func scopeOrdinal(")
end = modifier.index("    private static func payload(")
order = ["recordingTextStyle", "recordingRectangleStyle", "recordingBackground",
         "shorterDisabled", "shorterTextStyle", "shorterRectangleStyle", "shorterBackground",
         "longerDisabled", "longerTextStyle", "longerRectangleStyle", "longerBackground",
         *[f"channel{i}LevelStyle" for i in range(1, 5)]]
lookup = "    private static func scopeOrdinal(at slot: UInt16) -> UInt16 {\n        switch slot {\n" + "\n".join(
    f"        case {i}: SpikeRoles.{name}Ordinal" for i, name in enumerate(order[:-1])) + \
    "\n        default: SpikeRoles.channel4LevelStyleOrdinal\n        }\n    }\n\n"
body = modifier[end:].replace("ordinal", "identity")
body = re.sub(r"case ([\d, ]+):", lambda m: "case " + ", ".join(
    "SpikeRoles." + ordinal_roles[int(n)] + "Identity" for n in m[1].split(",")) + ":", body)
body = re.sub(r"identity == (\d+)", lambda m: "identity == SpikeRoles." + ordinal_roles[int(m[1])] + "Identity", body)
body = body.replace("identity < 56", "(identity == SpikeRoles.shorterTextStyleIdentity || identity == SpikeRoles.shorterRectangleStyleIdentity || identity == SpikeRoles.shorterBackgroundIdentity)")
body = body.replace("let channel = Int((identity - 69) / 7) + 1", "let channel: Int\n            switch identity {\n" + "\n".join(
    f"            case SpikeRoles.channel{i}LevelStyleIdentity: channel = {i}" for i in range(1, 4)) + "\n            default: channel = 4\n            }")
replacements[path] = modifier[:start] + lookup + body

app = root / "firmware/nrf52840/applications/signal-analyzer-static"
copy = out / "application"
shutil.copytree(app, copy, dirs_exist_ok=True)
cmake = digest(app / "CMakeLists.txt").replace('${CMAKE_CURRENT_SOURCE_DIR}/../../../..', str(root))
combined = (cache.parent / "SignalAnalyzerStatic.swift").read_text()
for path, candidate in replacements.items():
    target = out / path.relative_to(root)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(candidate)
    cmake = cmake.replace('${giftui_project_root}/' + str(path.relative_to(root)), str(target))
    original = path.read_text()
    assert original in combined
    combined = combined.replace(original, candidate, 1)
cmake = cmake.replace('    "${CMAKE_CURRENT_SOURCE_DIR}/src/StaticPreset.swift"',
                      f'    "{out / "SpikeRoles.swift"}"\n    "${{CMAKE_CURRENT_SOURCE_DIR}}/src/StaticPreset.swift"')
(copy / "CMakeLists.txt").write_text(cmake)
(out / "candidate.swift").write_text(bindings + combined)
record["candidate_sources"] = {str(path.relative_to(root)): hashlib.sha256(value.encode()).hexdigest()
                               for path, value in replacements.items()}

owners = root / ".build/contract-generated/spec-001/nrf-native-owners"
objects = (owners / "owner-objects.txt").read_text().splitlines()
record["native_object_hashes"] = {str(Path(p).relative_to(root)): hashlib.sha256(Path(p).read_bytes()).hexdigest() for p in objects}
record["paired_compiler"] = subprocess.check_output([command[0], "--version"], text=True)
for path in (spike / "run.py", spike / "Probe.swift", cache.parent / "SignalAnalyzerStatic.swift", root / "scripts/nrf52840/toolchain.env"):
    digest(path)
record["native"] = {}
outputs = {}
for name, source in (("baseline", cache.parent / "SignalAnalyzerStatic.swift"), ("candidate", out / "candidate.swift")):
    cmd = ["swiftc", "-I", str(owners / "modules"), "-parse-as-library", "-Osize", "-package-name", "GiftUI",
           "-DGIFTUI_NRF_EMBEDDED", "-DGIFTUI_REFERENCE_BITMAP_ONLY", str(source), str(spike / "Probe.swift"),
           *objects, "-o", str(out / name)]
    subprocess.run(cmd, env=dict(os.environ, CLANG_MODULE_CACHE_PATH=str(out / "native-cache")), check=True)
    run = subprocess.run([str(out / name)], capture_output=True, check=True)
    outputs[name] = b"\n".join(line for line in run.stdout.splitlines() if not line.startswith(b"TIMING ")) + b"\n"
    record["native"][name] = {"command": cmd, "exit_code": run.returncode,
                              "transcript_sha256": hashlib.sha256(outputs[name]).hexdigest(), "bytes": len(outputs[name]),
                              "host_stage_ns_per_call": [line.decode() for line in run.stdout.splitlines() if line.startswith(b"TIMING ")]}
assert outputs["baseline"] == outputs["candidate"]
record["semantic_transcripts_identical"] = True
(evidence / "semantic-transcript.txt.gz").write_bytes(gzip.compress(outputs["baseline"], mtime=0))
(evidence / "result.json").write_text(json.dumps(record, indent=2) + "\n")
print("direct module route: rejected by EmbeddedRestrictions; roles=32; semantic transcripts identical")
