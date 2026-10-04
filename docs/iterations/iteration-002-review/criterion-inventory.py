"""Inventory recorded criterion rows; this does not validate their dispositions.

Run from the repository root. Preserve the prior evidence before rerunning.
"""

import csv
import hashlib
import pathlib
import re
import subprocess

root = pathlib.Path.cwd()
output = root / "docs/iterations/iteration-002-review/evidence"
rows = []
for spec in sorted((root / "docs/specs").glob("spec-*.md")):
    text = spec.read_text()
    section = text.split("## Acceptance Criteria", 1)[1].split("\n## ", 1)[0]
    criteria = re.findall(r"^- \[[ xX]\] \*\*([A-Z][A-Z0-9-]*-\d{2,3}):\*\*", section, re.M)
    reports = sorted((root / "docs/conformance").glob(spec.name[:8] + "*.md"))
    if len(reports) != 1 or not criteria:
        raise ValueError(f"Ambiguous/missing portfolio artifact: {spec}")
    report = reports[0]
    recorded = {}
    for line in report.read_text().splitlines():
        if line.startswith("|"):
            columns = [column.strip().strip("`*") for column in line.split("|")[1:-1]]
            if len(columns) >= 2 and columns[0] in criteria:
                recorded.setdefault(columns[0], []).append(columns[1])
    for criterion in criteria:
        rows.append([
            spec.name[:8].upper(), criterion, str(spec.relative_to(root)),
            hashlib.sha256(spec.read_bytes()).hexdigest(), str(report.relative_to(root)),
            hashlib.sha256(report.read_bytes()).hexdigest(),
            " / ".join(recorded.get(criterion, ["MISSING"])),
            "recorded table text only; current disposition and evidence not validated",
        ])
with (output / "03-criterion-coverage.tsv").open("w") as stream:
    writer = csv.writer(stream, delimiter="\t", lineterminator="\n")
    writer.writerow([
        "spec", "criterion", "spec_path", "spec_sha256", "report_path", "report_sha256",
        "historical_recorded_status", "limitation",
    ])
    writer.writerows(rows)
revision = subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip()
missing = sum(row[6] == "MISSING" for row in rows)
print(f"Revision {revision}: {len(rows)} criteria; {missing} missing table entries.")
