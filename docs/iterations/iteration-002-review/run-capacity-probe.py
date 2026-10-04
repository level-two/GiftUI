#!/usr/bin/env python3
"""Compile the current InteractionState source; use existing lower-owner objects.

This research probe does not modify the package or production tests. Before
rerunning on changed sources, rebuild lower owners at the intended revision.
"""
import hashlib
import json
import os
from pathlib import Path
import subprocess

root = Path.cwd()
review = root / "docs/iterations/iteration-002-review"
output = root / ".build/iteration-002-audit/capacity-probe"
output.mkdir(parents=True, exist_ok=True)
cache = output / "clang-cache"
cache.mkdir(exist_ok=True)
build = root / ".build/arm64-apple-macosx/debug"
owners = ["GiftUI", "GiftUIExecution", "GiftUILayout", "GiftUISemanticCore", "GiftUITextResources", "GiftUIRenderCore"]
objects = sorted(path for owner in owners for path in (build / (owner + ".build")).glob("*.swift.o"))
if not objects or any(not (build / "Modules" / (owner + ".swiftmodule")).exists() for owner in owners):
    raise SystemExit("Build the six lower-owner targets first; required local modules/objects are missing")
sources = [root / "Sources/GiftUIInteraction" / name for name in ["InteractionValues.swift", "InteractionStorage.swift", "InteractionState.swift"]]
probe = review / "capacity-probe.swift"
command = ["xcrun", "swiftc", "-parse-as-library", "-package-name", "giftui", "-module-name", "InteractionCapacityResearch", "-module-cache-path", str(cache), "-I", str(build / "Modules"), *map(str, sources), str(probe), *map(str, objects), "-o", str(output / "probe")]
environment = dict(os.environ, CLANG_MODULE_CACHE_PATH=str(cache))
compile_result = subprocess.run(command, env=environment, capture_output=True, text=True)
record = {
    "source_baseline": "6cf31f266987e917458f31f05ed8c390cda9a202",
    "reviewed_revision": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(),
    "source_hashes": {str(path.relative_to(root)): hashlib.sha256(path.read_bytes()).hexdigest() for path in sources + [probe]},
    "lower_owner_objects": {str(path.relative_to(root)): hashlib.sha256(path.read_bytes()).hexdigest() for path in objects},
    "command": [arg.replace(str(root) + "/", "") for arg in command],
    "compile_exit_code": compile_result.returncode,
    "compiler_output": compile_result.stdout + compile_result.stderr,
    "limits": "Compiles unchanged current InteractionState sources with instrumented storage; lower owners are existing local build artifacts identified by hashes. No claim of fresh lower-owner build, Embedded behavior, or connected execution.",
}
if compile_result.returncode == 0:
    execution = subprocess.run([str(output / "probe")], capture_output=True, text=True)
    record.update(run_exit_code=execution.returncode, observed=execution.stdout + execution.stderr)
(review / "evidence/02-capacity-probe.json").write_text(json.dumps(record, indent=2) + "\n")
print(record.get("observed", record["compiler_output"]))
raise SystemExit(compile_result.returncode or record.get("run_exit_code", 1))
