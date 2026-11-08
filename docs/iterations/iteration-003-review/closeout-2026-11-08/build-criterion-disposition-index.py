#!/usr/bin/env python3
"""Build a conservative P10/P11/P12 index from the current nine owner plans."""

import csv
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
OUT = Path(__file__).with_name("criterion-dispositions.csv")
PLANS = {
    "SPEC-001": ("spec-001-implementation-plan.md", r"SA-(?:AC-|RD-)\d{3}", 49),
    "SPEC-002": ("spec-002-implementation-plan.md", r"PF-\d{3}", 10),
    "SPEC-006": ("spec-006-implementation-plan.md", r"DV-(?:RD-)?\d{3}", 21),
    "SPEC-007": ("spec-007-implementation-plan.md", r"LY-(?:RD-)?\d{3}", 11),
    "SPEC-010": ("spec-010-implementation-plan.md", r"OS-(?:RD-)?\d{3}", 16),
    "SPEC-011": ("spec-011-implementation-plan.md", r"IN-(?:(?:RD|SO)-)?\d{3}", 18),
    "SPEC-012": ("spec-012-implementation-plan.md", r"DR-(?:RD-)?\d{3}", 17),
    "SPEC-013": ("spec-013-implementation-plan.md", r"RP-(?:(?:RD|SO)-)?\d{3}", 22),
    "SPEC-015": ("spec-015-implementation-plan.md", r"HC-(?:(?:RD|SO)-)?\d{3}", 25),
}
FIELDS = [
    "spec",
    "criterion_group",
    "criterion_id",
    "criterion_title",
    "implementation_tasks",
    "planned_evidence",
    "owner_plan_status",
    "P10_current_disposition",
    "P11_current_disposition",
    "P12_current_disposition",
    "analyzer_disposition",
]


def cells(line):
    return [part.strip() for part in line.strip().strip("|").split("|")]


def main():
    rows = []
    seen = set()
    for spec, (filename, criterion_pattern, expected) in PLANS.items():
        path = ROOT / "docs" / "implementation-plans" / filename
        plan_text = path.read_text(encoding="utf-8")
        plan_rows = []
        for line in plan_text.splitlines():
            parts = cells(line)
            if len(parts) < 4:
                continue
            first = parts[0]
            match = re.match(r"`?([A-Z0-9-]+)`?(?:\s+—\s+(.*))?$", first)
            if not match or not re.fullmatch(criterion_pattern, match.group(1)):
                continue
            criterion_id = match.group(1)
            if criterion_id in seen:
                raise SystemExit(f"duplicate criterion: {criterion_id}")
            seen.add(criterion_id)
            group = "P08 scoped-ownership" if "-SO-" in criterion_id else "P10 owner matrix"
            title = (match.group(2) or (
                "scoped-ownership disposition" if group == "P08 scoped-ownership"
                else "runtime-disposition requirement" if "-RD-" in criterion_id
                else "criterion"
            )).strip()
            if len(parts) < 4:
                raise SystemExit(f"malformed matrix row in {path}: {line}")
            tasks, evidence, status = parts[1], parts[2], parts[3]
            plan_rows.append(
                {
                    "spec": spec,
                    "criterion_group": group,
                    "criterion_id": criterion_id,
                    "criterion_title": title,
                    "implementation_tasks": tasks,
                    "planned_evidence": evidence,
                    "owner_plan_status": status,
                    "P10_current_disposition": (
                        "P08 scoped classification retained; P10 run-usFDdIBT "
                        "gate remains UNMET (59/83 checks failed)"
                        if group == "P08 scoped-ownership"
                        else "UNMET: all-hardware-free run-usFDdIBT failed 59/83 checks; "
                        "aggregate failure does not establish criterion conformance"
                    ),
                    "P11_current_disposition": (
                        "UNMET overall P11 gate: this index records planned evidence "
                        "and current scope, not a criterion-level proof"
                    ),
                    "P12_current_disposition": (
                        "UNMET: no cutover/removal; preserve baseline pending adoption gates"
                    ),
                    "analyzer_disposition": (
                        "Transfer analyzer-specific portion only under approved I4 "
                        "allocation; retain split owner criterion and affected-use "
                        "restrictions in I4 plan"
                    ),
                }
            )
        if len(plan_rows) != expected:
            raise SystemExit(
                f"{spec}: expected {expected} plan rows, found {len(plan_rows)}"
            )
        rows.extend(plan_rows)
    with OUT.open("w", encoding="utf-8", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=FIELDS, lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)
    print(f"wrote {len(rows)} current owner-plan rows to {OUT.name}")
    print("P10 owner matrix: 180 rows; additional scoped-ownership rows: 9; total: 189")


if __name__ == "__main__":
    main()
