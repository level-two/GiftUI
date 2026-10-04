"""Attach owner-review/evidence dispositions to the historical criterion inventory."""

import csv
import hashlib
from pathlib import Path

root = Path.cwd()
out = root / "docs/iterations/iteration-002-review/evidence"
steps = {1: "05/07/08", 2: "01/05", 3: "08", 4: "08", 5: "06", 6: "05/06",
         7: "06", 8: "06/08", 9: "07", 10: "05/07", 11: "02/07", 12: "06/08",
         13: "07/08", 14: "08", 15: "08"}
rows = []
for record in csv.DictReader((out / "03-criterion-coverage.tsv").open(), delimiter="\t"):
    spec, criterion = record["spec"], record["criterion"]
    historical = record["historical_recorded_status"]
    note = "owner-boundary/flow review plus current hardware-free corpus; no individual-criterion pass inferred"
    if "exception" in historical.lower():
        note = "existing approved exception retained; hardware-free gate does not close connected/timing gap"
    if criterion == "SA-AC-043":
        note = "CBR-007 challenges terminal startup coverage; actual-source reproduction supersedes a blanket historical pass"
    if spec == "SPEC-011" and criterion in {"IN-008", "IN-009"}:
        note = "CBR-001 exposes asymmetric staged storage preflight/mapping gap; standard equal-capacity corpus does not resolve it"
    rows.append([spec, criterion, historical, steps[int(spec.split("-")[1])], note,
                 hashlib.sha256((root / record["spec_path"]).read_bytes()).hexdigest()])
assert len(rows) == 240
with (out / "11-criterion-review-notes.tsv").open("w", newline="") as handle:
    writer = csv.writer(handle, delimiter="\t", lineterminator="\n")
    writer.writerow(["spec", "criterion", "historical_status_not_reapproved", "owner_review_steps", "current_evidence_disposition", "current_spec_sha256"])
    writer.writerows(rows)
print("Recorded 240 criterion review notes; no new conformance approval or blanket pass")
