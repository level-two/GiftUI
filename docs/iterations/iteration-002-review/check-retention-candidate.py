"""Compile isolated five-second copies of the actual three owning modules."""
from pathlib import Path
import hashlib
import json
import os
import shutil
import subprocess

root = Path.cwd()
review = root / "docs/iterations/iteration-002-review"
out = root / ".build/iteration-002-audit/retention-candidate"
out.mkdir(parents=True, exist_ok=True)
# Independent firmware candidate: retain production module selection and change
# only capture policy/storage constants. Accepted contract files are untouched.
firmware_out = root / ".build/nrf52840/iteration-002-retention"
app = root / "firmware/nrf52840/applications/signal-analyzer-static"
copy = firmware_out / "application"
shutil.copytree(app, copy, dirs_exist_ok=True)
cmake = (app / "CMakeLists.txt").read_text().replace('${CMAKE_CURRENT_SOURCE_DIR}/../../../..', str(root))
for name in ("StaticSignalAnalyzerNRFCaptureStorage.swift", "StaticSignalAnalyzerNRFCaptureHistory.swift"):
    path = root / "Sources/SignalAnalyzerTargetHost" / name
    target = firmware_out / "Sources/SignalAnalyzerTargetHost" / name
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(path.read_text().replace("2_404", "404").replace(".seconds(30)", ".seconds(5)"))
    cmake = cmake.replace('${giftui_project_root}/Sources/SignalAnalyzerTargetHost/' + name, str(target))
(copy / "CMakeLists.txt").write_text(cmake)
path = copy / "src/StaticPreset.swift"
path.write_text(path.read_text().replace("2_404", "404").replace("115_392", "19_392"))
path = copy / "include/static_host_storage.h"
path.write_text(path.read_text().replace("115392", "19392"))
groups = {
    "SignalAnalyzerDomain": sorted((root / "Sources/SignalAnalyzerDomain").glob("*.swift")),
    "SignalAnalyzerData": [root / "Sources/SignalAnalyzerData/SignalCaptureStore.swift"],
    "SignalAnalyzerTargetHost": [root / "Sources/SignalAnalyzerTargetHost" / f"StaticSignalAnalyzerNRFCapture{x}.swift"
                               for x in ("Storage", "Record", "History")],
}
record = {"revision": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(),
          "transformations": {"2_404": "404", ".seconds(30)": ".seconds(5)"}, "sources": {}, "commands": []}
env = dict(os.environ, CLANG_MODULE_CACHE_PATH=str(out / "clang-cache"))
objects = []
for owner, paths in groups.items():
    copied = []
    for path in paths:
        source = path.read_text()
        candidate = source.replace("2_404", "404").replace(".seconds(30)", ".seconds(5)")
        target = out / owner / path.name
        target.parent.mkdir(exist_ok=True)
        target.write_text(candidate)
        record["sources"][str(path.relative_to(root))] = {"original_sha256": hashlib.sha256(source.encode()).hexdigest(),
                                                       "candidate_sha256": hashlib.sha256(candidate.encode()).hexdigest()}
        copied.append(str(target))
    obj = out / f"{owner}.o"
    cmd = ["swiftc", "-parse-as-library", "-O", "-whole-module-optimization", "-package-name", "GiftUI",
           "-module-name", owner, "-I", str(out), "-emit-module", "-emit-object", "-o", str(obj),
           "-emit-module-path", str(out / f"{owner}.swiftmodule"), *copied]
    record["commands"].append(cmd)
    subprocess.run(cmd, env=env, check=True)
    objects.append(str(obj))
cmd = ["swiftc", "-parse-as-library", "-O", "-package-name", "GiftUI", "-I", str(out),
       str(review / "retention-candidate.swift"), *objects, "-o", str(out / "probe")]
record["commands"].append(cmd)
subprocess.run(cmd, env=env, check=True)
run = subprocess.run([str(out / "probe")], capture_output=True, text=True)
record.update(exit_code=run.returncode, output=run.stdout + run.stderr,
              limits="Native actual-owner comparison and independent baseline oracle; no firmware or connected performance proof")
(review / "evidence/14-retention-candidate.json").write_text(json.dumps(record, indent=2) + "\n")
print(record["output"])
raise SystemExit(run.returncode)
