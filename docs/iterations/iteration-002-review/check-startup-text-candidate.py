"""Disposable source transformation; production sources are never modified."""
from pathlib import Path
import argparse
import hashlib
import json
import os
import shutil
import subprocess

root = Path.cwd()
review = root / "docs/iterations/iteration-002-review"
parser = argparse.ArgumentParser()
parser.add_argument("--prepare-only", action="store_true")
args = parser.parse_args()
out = root / ".build/nrf52840/iteration-002-startup-text"
out.mkdir(parents=True, exist_ok=True)
app = root / "firmware/nrf52840/applications/signal-analyzer-static"
copy = out / "application"
shutil.copytree(app, copy, dirs_exist_ok=True)
test = (root / "Tests/GiftUIHostConfigurationTests/StaticSignalAnalyzerNRFEmbeddedSemanticRegionTests.swift").read_text()
helper = test[test.index("private struct StaticNRFOneTextSemantic"):test.index("private func staticNRFEmbeddedTextMeasureMatchesHost")]
original = (app / "src/StaticPreset.swift").read_text()
start = original.index("    guard\n        let semantic =", original.index("public func giftUISignalAnalyzerLayoutTextValid"))
end = original.index("    return 1\n}", start)
replacement = '''    guard let semantic = StaticSignalAnalyzerNRFEmbeddedSemanticView(published: published),
        let limits = LayoutLimits(maximumScopes: 98, maximumDepth: 19,
            maximumTextScalars: 224, maximumTextLines: 128, maximumPositionedGlyphs: 224),
        let proposal = ProposedSize(width: 320, height: 240),
        let zero = Size(width: 0, height: 0)
    else { return 0 }
    let oneText = StaticNRFOneTextSemantic(rootIdentity: title.identity, source: semantic)
    var shared = StaticSignalAnalyzerNRFCommonLayoutWorkspace(packed: layout)
    var engine = LayoutEngine(limits: limits, validatedCounters: LayoutCounters(limits: limits))
    guard shared.acquireLayout(), shared.appendScope(identity: title.identity,
        measurement: LayoutMeasurement(idealSize: zero, resolvedSize: zero)),
        let measurement = engine.measure(semantic: oneText,
            metrics: StaticSignalAnalyzerNRFEmbeddedFontMetrics(), proposal: proposal,
            workspace: &shared),
        let bounds = Rect(origin: Point(x: 0, y: 0), size: measurement.resolvedSize),
        engine.place(semantic: oneText, metrics: StaticSignalAnalyzerNRFEmbeddedFontMetrics(),
            rootBounds: bounds, workspace: &shared),
        shared.packed.textLineCount > 0, shared.packed.positionedGlyphCount > 0,
        shared.packed.reserveTextScalars(engine.finalCounters.textScalarCount),
        let resolved = shared.packed.publish(rootIdentity: title.identity, expectedScopeCount: 1),
        resolved.isPublished, resolved.scope(at: 0)?.identity == title.identity,
        resolved.line(at: 0)?.identity == title.identity,
        resolved.glyph(at: 0)?.identity == title.identity
    else { shared.resetLayout(); return 0 }
    shared.resetLayout()
    guard !resolved.isPublished else { return 0 }
'''
candidate = helper + original[:start] + replacement + original[end:]
(copy / "src/StaticPreset.swift").write_text(candidate)
cmake = (app / "CMakeLists.txt").read_text().replace('${CMAKE_CURRENT_SOURCE_DIR}/../../../..', str(root))
retired = [root / "Sources/SignalAnalyzerTargetHost" / f"StaticSignalAnalyzerNRFEmbeddedText{x}.swift" for x in ("Measure", "Place")]
for path in retired:
    cmake = cmake.replace(f'    "${{giftui_project_root}}/Sources/SignalAnalyzerTargetHost/{path.name}"\n', '')
(copy / "CMakeLists.txt").write_text(cmake)
if args.prepare_only:
    print(copy)
    raise SystemExit(0)

owners = root / ".build/contract-generated/spec-001/nrf-native-owners"
objects = (owners / "owner-objects.txt").read_text().splitlines()
source = (root / ".build/nrf52840/signal-analyzer-static/SignalAnalyzerStatic.swift").read_text()
harness = (app / "tests/full_layout_native.swift").read_text()
anchor = '        precondition(\n            giftUISignalAnalyzerFullLayoutValid'
extra = '''        precondition(giftUISignalAnalyzerLayoutTextValid(profile, 39_696) == 1)
        precondition(giftUISignalAnalyzerLayoutTextValid(nil, 39_696) == 0)
        precondition(giftUISignalAnalyzerLayoutTextValid(profile, 39_695) == 0)
        precondition(giftUISignalAnalyzerLayoutTextValid(profile, 39_696) == 1)
'''
assert anchor in harness
harness = harness.replace(anchor, extra + anchor, 1)
(out / "harness.swift").write_text(harness)
record = {"revision": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(),
          "source_hashes": {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
                            for p in [app / "src/StaticPreset.swift", app / "CMakeLists.txt", *retired]},
          "checks": {}}
for label in ("baseline", "candidate"):
    transformed = source
    if label == "candidate":
        assert original in source
        transformed = source.replace(original, candidate, 1)
        for path in retired:
            assert path.read_text() in transformed
            transformed = transformed.replace(path.read_text(), "", 1)
    source_path = out / f"{label}.swift"
    source_path.write_text(transformed)
    command = ["swiftc", "-I", str(owners / "modules"), "-DGIFTUI_REFERENCE_BITMAP_ONLY",
               "-parse-as-library", "-Osize", "-package-name", "GiftUI", "-DGIFTUI_NRF_EMBEDDED",
               str(source_path), str(out / "harness.swift"), *objects, "-o", str(out / label)]
    result = subprocess.run(command, capture_output=True, text=True,
                            env=dict(os.environ, CLANG_MODULE_CACHE_PATH=str(out / "clang-cache")))
    (out / f"{label}-compile.log").write_text(result.stdout + result.stderr)
    check = {"command": command, "compile_exit": result.returncode}
    if result.returncode == 0:
        run = subprocess.run([str(out / label)], capture_output=True, text=True)
        check.update(run_exit=run.returncode, output=run.stdout + run.stderr)
    else:
        check["output"] = result.stdout + result.stderr
    record["checks"][label] = check
    print(label, check)
(review / "evidence/13-startup-text-candidate.json").write_text(json.dumps(record, indent=2) + "\n")
assert all(c.get("run_exit") == 0 for c in record["checks"].values())
