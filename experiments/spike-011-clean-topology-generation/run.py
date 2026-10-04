"""Reproduce clean generation, input refusals and native semantic parity."""
from pathlib import Path
import copy
import gzip
import hashlib
import importlib.util
import json
import os
import shutil
import subprocess

root = Path.cwd()
spike = root / "experiments/spike-011-clean-topology-generation"
out = root / ".build/nrf52840/spike-011-clean-topology-generation"
out.mkdir(parents=True, exist_ok=True)
evidence = spike / "evidence"
evidence.mkdir(exist_ok=True)
record = {"revision": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(), "inputs": {}}

def digest(path):
    record["inputs"][str(path.relative_to(root))] = hashlib.sha256(path.read_bytes()).hexdigest()
    return path.read_text()

bundle = out / "isolated-inputs"
bundle.mkdir(exist_ok=True)
shutil.copytree(spike / "templates", bundle / "templates", dirs_exist_ok=True)
shutil.copy2(spike / "policy.json", bundle / "policy.json")
fixtures = root / "Tests/ContractFixtures/SPEC001"
for variant, name in (("normal", "nrf-touch-ui-projection.json"), ("diagnostic", "nrf-touch-ui-diagnostic-projection.json")):
    (bundle / f"{variant}.json").write_text(digest(fixtures / name))
policy = json.loads(digest(spike / "policy.json"))
source_root = out / "isolated-sources"
for name in policy["source_hashes"]:
    path = root / name
    target = source_root / name
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(digest(path))
for path in (spike / "generate.py", spike / "run.py", *sorted((spike / "templates").iterdir())):
    digest(path)

# CLI only sees the bundle and registered declaration snapshots. No previous
# generated source or production output directory exists under either root.
generated_hashes = []
for index in range(2):
    output = out / f"clean-{index}"
    if output.exists():
        shutil.rmtree(output)
    command = ["python3", str(spike / "generate.py"), str(bundle), str(source_root), str(output)]
    result = subprocess.run(command, capture_output=True, text=True, check=True, cwd=out)
    generated_hashes.append(json.loads(result.stdout))
assert generated_hashes[0] == generated_hashes[1]
record["clean_generations"] = generated_hashes

module = importlib.util.spec_from_file_location("clean_generator", spike / "generate.py")
generator = importlib.util.module_from_spec(module)
module.loader.exec_module(generator)
normal = json.loads((bundle / "normal.json").read_text())
rejections = []
for name, mutate in (
    ("duplicate-identity", lambda rows: rows[1].update(identity=rows[0]["identity"])),
    ("zero-identity", lambda rows: rows[0].update(identity=0)),
    ("noncontiguous-ordinal", lambda rows: rows[1].update(ordinal=2)),
    ("out-of-range-child", lambda rows: rows[0].update(child=999)),
    ("child-cycle", lambda rows: rows[0].update(child=0)),
    ("parent-child-disagreement", lambda rows: rows[2].update(parent=0)),
    ("unsupported-modifier", lambda rows: rows[0].update(flags=255)),
    ("variant-shape-disagreement", lambda rows: rows[0].update(identity=1)),
    ("invariant-payload-disagreement", lambda rows: rows[3].update(p0=123)),
    ("scope-capacity", lambda rows: rows.extend(copy.deepcopy(rows)))):
    rows = copy.deepcopy(normal)
    mutate(rows)
    (bundle / "normal.json").write_text(json.dumps(rows))
    target = out / ("rejected-" + name)
    try:
        generator.generate(bundle, source_root, target)
    except AssertionError as error:
        assert not target.exists(), "partial output on invalid input"
        rejections.append({"mutation": name, "reason": str(error)})
    else:
        raise AssertionError("accepted " + name)
(bundle / "normal.json").write_text(json.dumps(normal))
stale = source_root / next(iter(policy["source_hashes"]))
original = stale.read_bytes()
stale.write_bytes(original + b"\n// stale declaration\n")
try:
    generator.generate(bundle, source_root, out / "rejected-stale")
except AssertionError as error:
    assert not (out / "rejected-stale").exists()
    rejections.append({"mutation": "stale-registered-declaration", "reason": str(error)})
else:
    raise AssertionError("accepted stale declaration")
stale.write_bytes(original)
try:
    generator.generate(bundle, source_root, out / "clean-0")
except AssertionError as error:
    rejections.append({"mutation": "nonempty-output", "reason": str(error)})
else:
    raise AssertionError("accepted nonempty output")
record["rejected_inputs"] = rejections

production = root / "Sources/SignalAnalyzerTargetHost/Generated"
record["generated_sources_equal_production"] = {}
combined = (root / ".build/nrf52840/signal-analyzer-static/SignalAnalyzerStatic.swift").read_text()
app = root / "firmware/nrf52840/applications/signal-analyzer-static"
copied = out / "application"
shutil.copytree(app, copied, dirs_exist_ok=True)
cmake = digest(app / "CMakeLists.txt").replace('${CMAKE_CURRENT_SOURCE_DIR}/../../../..', str(root))
for name in generator.NAMES:
    original = production / name
    emitted = out / "clean-0" / name
    original_text = digest(original)
    assert original_text == emitted.read_text(), name
    record["generated_sources_equal_production"][name] = True
    assert original_text in combined
    combined = combined.replace(original_text, emitted.read_text(), 1)
    cmake = cmake.replace('${giftui_project_root}/' + str(original.relative_to(root)), str(emitted))
(copied / "CMakeLists.txt").write_text(cmake)
candidate = out / "candidate.swift"
candidate.write_text(combined)

owners = root / ".build/contract-generated/spec-001/nrf-native-owners"
objects = (owners / "owner-objects.txt").read_text().splitlines()
record["native_owner_objects"] = {str(Path(p).relative_to(root)): hashlib.sha256(Path(p).read_bytes()).hexdigest() for p in objects}
probe = root / "experiments/spike-009-nrf-hierarchy-roles/Probe.swift"
digest(probe)
record["native"] = {}
transcripts = []
for name, source in (("baseline", root / ".build/nrf52840/signal-analyzer-static/SignalAnalyzerStatic.swift"), ("candidate", candidate)):
    command = ["swiftc", "-I", str(owners / "modules"), "-parse-as-library", "-Osize", "-package-name", "GiftUI",
               "-DGIFTUI_NRF_EMBEDDED", "-DGIFTUI_REFERENCE_BITMAP_ONLY", str(source), str(probe), *objects, "-o", str(out / name)]
    subprocess.run(command, check=True, env=dict(os.environ, CLANG_MODULE_CACHE_PATH=str(out / "native-cache")))
    result = subprocess.run([str(out / name)], capture_output=True, check=True)
    transcript = b"\n".join(line for line in result.stdout.splitlines() if not line.startswith(b"TIMING ")) + b"\n"
    transcripts.append(transcript)
    record["native"][name] = {"command": command, "exit_code": result.returncode,
                             "transcript_sha256": hashlib.sha256(transcript).hexdigest(), "bytes": len(transcript)}
assert transcripts[0] == transcripts[1]
record["semantic_transcripts_identical"] = True
(evidence / "semantic-transcript.txt.gz").write_bytes(gzip.compress(transcripts[0], mtime=0))
(evidence / "result.json").write_text(json.dumps(record, indent=2) + "\n")
print("Two clean generations; 12 refused inputs; both generated sources identical; 42 full semantic transcripts identical")
