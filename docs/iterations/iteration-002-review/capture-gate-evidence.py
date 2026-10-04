"""Preserve a completed fixed-revision aggregate gate before another run."""

import csv
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile

root = Path.cwd()
out = root / "docs/iterations/iteration-002-review/evidence"
gate = root / ".build/test-reports/all-hardware-free"
console = root / ".build/iteration-002-audit/gate-b18da84a.log"
demo = root / ".build/iteration-002-audit/demo-tests.log"
sha = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
metadata = dict(line.split("=", 1) for line in (gate / "metadata.txt").read_text().splitlines())
assert "failure_count" in metadata, "Gate has not completed"
assert subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip() == metadata["repository_revision"]
results = list(csv.reader((gate / "results.tsv").open(), delimiter="\t"))
assert len(results) == 72
members = {console, demo, gate / "metadata.txt", gate / "results.tsv"}
members.update(gate / "logs" / (row[0] + ".log") for row in results)
compiler_case = out / "11-pi-compiler-identity.json"
if compiler_case.exists():
    members.update(root / path for path in json.loads(compiler_case.read_text())["hashes"])
driver_rows = []
for identifier, status, log in results:
    match = re.fullmatch(r"SPEC-(\d{3})-(.+)", identifier)
    if not match:
        continue
    content = (root / log).read_text()
    run_ids = re.findall(r"run ID: ([a-f0-9]+-[a-f0-9]+)", content)
    application_reports = re.findall(r"SPEC-001 [^\n]+ complete(?: \(cross-build only\))?: (\S+)", content)
    if match[1] == "001" and application_reports:
        directory = Path(application_reports[-1])
        run_id = directory.parent.name
    elif run_ids:
        run_id = run_ids[-1]
        publications = re.findall(r"^published=(\S+)$", content, re.M)
        matching = [Path(path) for path in publications if Path(path).parent.name == run_id and Path(path).name == match[2]]
        directory = matching[-1] if matching else root / ".build/contract-reports" / ("spec-" + match[1]) / run_id / match[2]
    else:
        driver_rows.append([identifier, status, "-", "-", "-", "no published report; inspect archived log"])
        continue
    verify = subprocess.run(["scripts/contracts/verify-contract-report.rb", str(directory)], capture_output=True, text=True)
    assert verify.returncode == 0, verify.stdout + verify.stderr
    inputs = directory / "input-hashes.tsv"
    members.update(path for path in directory.iterdir() if path.is_file() and path.suffix in {".txt", ".tsv", ".json", ".log"})
    identity = inputs if inputs.exists() else directory / "metadata.txt"
    execution = "idempotent verified reuse" if "idempotent match" in content else "fresh immutable report"
    if match[1] == "001":
        execution = "fresh timestamp report; metadata source/fixture/artifact identity, narrower than full closure"
    driver_rows.append([identifier, status, run_id, str(directory.relative_to(root)), sha(identity), execution])

with (out / "11-gate-results.tsv").open("w", newline="") as handle:
    writer = csv.writer(handle, delimiter="\t", lineterminator="\n")
    writer.writerow(["check", "exit_code", "raw_log"])
    writer.writerows(results)
with (out / "11-contract-runs.tsv").open("w", newline="") as handle:
    writer = csv.writer(handle, delimiter="\t", lineterminator="\n")
    writer.writerow(["check", "exit_code", "run_id", "report_directory", "input_inventory_or_metadata_sha256", "execution_class"])
    writer.writerows(driver_rows)
assert len(driver_rows) == 60
archive = out / "11-validation-logs.tar.gz"
with tarfile.open(archive, "w:gz") as tar:
    for path in sorted(members):
        tar.add(path, arcname=str(path.relative_to(root)))
root_tests = (gate / "logs/root-tests.log").read_text()
production_diff = subprocess.check_output(["git", "diff", "6cf31f266987e917458f31f05ed8c390cda9a202", "--name-only", "--", "Sources", "Tests", "demo", "firmware", "scripts", "Package.swift"], text=True)
assert not production_diff, "Maintained production/test/build inputs changed"
summary = {
    "command": "scripts/test.sh --profile all-hardware-free",
    "metadata": metadata,
    "check_count": len(results),
    "failed_checks": [row[0] for row in results if row[1] != "0"],
    "contract_report_count": len(driver_rows),
    "verified_immutable_reports": sum(row[2] != "-" for row in driver_rows),
    "maintained_source_test_build_inputs_unchanged_from_baseline": True,
    "working_tree_note": "SPEC-001 reports repository_dirty=true because research documentation was pending during the fixed-HEAD gate; maintained production/test/build inputs were unchanged. SPEC-001 uses timestamp report IDs and narrower metadata identities; SPEC-002 through SPEC-015 use hashed input inventories.",
    "root_test_summary_lines": [line for line in root_tests.splitlines() if re.search(r"Executed \d+ tests|Test run with \d+ tests", line)][-3:],
    "demo_summary_lines": [line for line in demo.read_text().splitlines() if re.search(r"Executed \d+ tests|Test run with \d+ tests", line)][-3:],
    "archive": str(archive.relative_to(root)),
    "archive_sha256": sha(archive),
    "archive_bytes": archive.stat().st_size,
    "raw_file_hashes": {str(path.relative_to(root)): sha(path) for path in sorted(members)},
    "limits": "Current hardware-free corpus and immutable report integrity only; no connected proof, candidate replacement feasibility, or blanket criterion pass. CBR-001/007 reproductions remain valid.",
}
(out / "11-gate-summary.json").write_text(json.dumps(summary, indent=2) + "\n")
print(json.dumps({key: value for key, value in summary.items() if key != "raw_file_hashes"}, indent=2))
