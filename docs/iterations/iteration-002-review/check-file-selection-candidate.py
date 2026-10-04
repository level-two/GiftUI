"""Remove whole-file Embedded guards only in isolated, explicitly selected copies."""
from pathlib import Path
import csv
import hashlib
import json
import os
import shutil
import subprocess

root = Path.cwd()
review = root / "docs/iterations/iteration-002-review"
out = root / ".build/nrf52840/iteration-002-file-selection"
app = root / "firmware/nrf52840/applications/signal-analyzer-static"
copy = out / "application"
shutil.copytree(app, copy, dirs_exist_ok=True)
cmake = (app / "CMakeLists.txt").read_text().replace('${CMAKE_CURRENT_SOURCE_DIR}/../../../..', str(root))
source = (root / ".build/nrf52840/signal-analyzer-static/SignalAnalyzerStatic.swift").read_text()
record = {"revision": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(),
          "candidates": {}, "limits": "Selected Embedded closure and native rehearsal; proposed SwiftPM exclusions must be applied and validated before production removal"}
for row in csv.DictReader((review / "evidence/09-source-guards.tsv").open(), delimiter="\t"):
    path = root / row["path"]
    original = path.read_text()
    if row["line"] != "1" or not original.startswith("#if GIFTUI_NRF_EMBEDDED\n"):
        continue
    # Exclude empty compatibility shell: deleting it is a separate candidate.
    if path.name == "StaticSignalAnalyzerNRFEmbeddedFontRaster.swift":
        continue
    assert original.rstrip().endswith("#endif")
    marker = '${giftui_project_root}/' + row["path"]
    assert marker in cmake and original in source
    candidate = original.split("\n", 1)[1].rsplit("#endif", 1)[0]
    target = out / row["path"]
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(candidate)
    cmake = cmake.replace(marker, str(target))
    source = source.replace(original, candidate, 1)
    record["candidates"][row["path"]] = {"original_sha256": hashlib.sha256(original.encode()).hexdigest(),
                                          "candidate_sha256": hashlib.sha256(candidate.encode()).hexdigest()}
(copy / "CMakeLists.txt").write_text(cmake)
(out / "candidate.swift").write_text(source)
owners = root / ".build/contract-generated/spec-001/nrf-native-owners"
cmd = ["swiftc", "-I", str(owners / "modules"), "-parse-as-library", "-Osize", "-package-name", "GiftUI",
       "-DGIFTUI_REFERENCE_BITMAP_ONLY", "-DGIFTUI_NRF_EMBEDDED", str(out / "candidate.swift"),
       str(app / "tests/full_layout_native.swift"), *(owners / "owner-objects.txt").read_text().splitlines(),
       "-o", str(out / "probe")]
subprocess.run(cmd, env=dict(os.environ, CLANG_MODULE_CACHE_PATH=str(out / "clang-cache")), check=True)
run = subprocess.run([str(out / "probe")], capture_output=True, text=True)
record.update(command=cmd, exit_code=run.returncode, output=run.stdout + run.stderr)
(review / "evidence/15-file-selection-candidate.json").write_text(json.dumps(record, indent=2) + "\n")
print(len(record["candidates"]), "selected guards", record["output"])
raise SystemExit(run.returncode)
