"""Run the actual hierarchy updater twice in an isolated copy; never edit Sources."""

import difflib
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

root = Path.cwd()
review = root / "docs/iterations/iteration-002-review"
scratch = root / ".build/iteration-002-audit"
scratch.mkdir(parents=True, exist_ok=True)
script = "scripts/contracts/generate-spec-001-nrf-topology.py"
inputs = [script, "Tests/ContractFixtures/SPEC001/nrf-touch-ui-projection.json",
          "Tests/ContractFixtures/SPEC001/nrf-touch-ui-diagnostic-projection.json"]
outputs = ["Sources/SignalAnalyzerTargetHost/Generated/StaticSignalAnalyzerNRFTopologyWriter.generated.swift",
           "Sources/SignalAnalyzerTargetHost/Generated/StaticSignalAnalyzerNRFPackedSemanticRecords.generated.swift"]
hash_bytes = lambda data: hashlib.sha256(data).hexdigest()
record = {"source_baseline": "6cf31f26", "command": f"python3 {script} (isolated copy, twice)",
          "input_hashes": {p: hash_bytes((root / p).read_bytes()) for p in inputs + outputs},
          "limits": "Updater uses existing generated files as inputs; idempotence is not clean generation or semantic parity"}
with tempfile.TemporaryDirectory(prefix="hierarchy-generator-", dir=scratch) as temporary:
    clone = Path(temporary)
    for p in inputs + outputs:
        target = clone / p
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(root / p, target)
    runs = []
    snapshots = []
    for _ in range(2):
        run = subprocess.run(["python3", str(clone / script)], capture_output=True, text=True)
        runs.append({"exit_code": run.returncode, "output": run.stdout + run.stderr})
        snapshots.append({p: (clone / p).read_bytes() for p in outputs})
    record["runs"] = runs
    record["outputs"] = {}
    for p in outputs:
        original = (root / p).read_bytes()
        first = snapshots[0][p]
        second = snapshots[1][p]
        difference = list(difflib.unified_diff(original.decode().splitlines(), first.decode().splitlines(),
                                             fromfile=p, tofile="regenerated", lineterm=""))
        record["outputs"][p] = {"original_sha256": hash_bytes(original), "first_sha256": hash_bytes(first),
                                "second_sha256": hash_bytes(second), "matches_checked_in": first == original,
                                "idempotent": first == second, "diff_line_count": len(difference),
                                "diff_preview": difference[:90]}
(review / "evidence/09-hierarchy-generator.json").write_text(json.dumps(record, indent=2) + "\n")
for p, result in record["outputs"].items():
    print(p, "matches_checked_in=", result["matches_checked_in"], "idempotent=", result["idempotent"])
    print("\n".join(result["diff_preview"][:40]))
raise SystemExit(1 if any(r["exit_code"] for r in runs) else 0)
