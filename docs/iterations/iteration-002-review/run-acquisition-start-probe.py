"""Compile unchanged Data sources, linked to existing hashed Domain objects."""

import hashlib
import json
import os
from pathlib import Path
import subprocess

root = Path.cwd()
review = root / "docs/iterations/iteration-002-review"
output = root / ".build/iteration-002-audit/acquisition-start-probe"
cache = output / "clang-cache"
cache.mkdir(parents=True, exist_ok=True)
build = root / ".build/arm64-apple-macosx/debug"
objects = sorted((build / "SignalAnalyzerDomain.build").glob("*.swift.o"))
if not objects:
    raise SystemExit("Build root-package Domain objects before running the probe")
sources = [root / "Sources/SignalAnalyzerData" / name for name in [
    "DefaultSignalAcquisitionRepository.swift", "SignalCaptureStore.swift",
    "DeterministicSignalDataSource.swift", "DeterministicSignalGenerator.swift",
]]
probe = review / "acquisition-start-probe.swift"
command = ["xcrun", "swiftc", "-parse-as-library", "-package-name", "giftui",
           "-module-name", "AcquisitionStartResearch", "-module-cache-path", str(cache),
           "-I", str(build / "Modules"), *map(str, sources), str(probe),
           *map(str, objects), "-o", str(output / "probe")]
result = subprocess.run(command, env=dict(os.environ, CLANG_MODULE_CACHE_PATH=str(cache)),
                        capture_output=True, text=True)
record = {
    "source_baseline": "6cf31f266987e917458f31f05ed8c390cda9a202",
    "reviewed_revision": subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip(),
    "source_hashes": {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
                      for p in sources + [probe]},
    "domain_object_hashes": {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
                             for p in objects},
    "command": command,
    "compile_exit_code": result.returncode,
    "compiler_output": result.stdout + result.stderr,
    "limits": "Actual unchanged Data sources and deterministic source; existing hashed host Domain objects; no Embedded or connected proof",
}
if result.returncode == 0:
    run = subprocess.run([str(output / "probe")], capture_output=True, text=True)
    record.update(run_exit_code=run.returncode, observed=run.stdout + run.stderr)
(review / "evidence/05-acquisition-start-probe.json").write_text(json.dumps(record, indent=2) + "\n")
print(record.get("observed", record["compiler_output"]))
raise SystemExit(result.returncode or record.get("run_exit_code", 1))
