# T10.8 — Final cleanup review remains blocked

Implementation reviewed: `44ac06a8` and preceding T10.1–T10.7 commits.
T10.1–T10.4 are complete; T10.5/T10.6 are blocked by the reproduced SPEC-013
application mutation/failure seam. T10.7 delivers independent dependency
cleanup but its final production-join check is blocked. T10.8 cannot close
without those joins and a passing registered hardware-free gate.

Final `scripts/test.sh all-hardware-free` completed at implementation revision
`44ac06a801f86900b2210a3a23a002f43b12fd1a`: **30 of 72 checks passed; 42 failed**.
Root Swift tests pass: **1,151 tests**. All 12 common checks pass. SPEC-001
macOS Dynamic/Static and SPEC-002/007/010/015 in all four profiles pass.
SPEC-001 Pi/nRF fail because independently reviewed pixel references are
missing. SPEC-003/004/005/006/008/009/011/012/013/014 fail in every profile.
These current failures are not waived exceptions or final conformance.

`final-gate-results.tsv` preserves every exit status and original log path;
`final-gate-metadata.txt` preserves the invocation and implementation revision.
`final-gate-logs.tar.gz` preserves all 72 raw gate logs, identified by
`final-gate-log-hashes.tsv`. Documentation/evidence changes were present during
collection; maintained implementation sources match the named revision.

The inspected macOS Dynamic owner failures include:

| Owner | Current assertion requiring reconciliation |
| --- | --- |
| SPEC-003 | Direct production Failure Core consumer set differs. |
| SPEC-004 | Target-host dependency fixture differs from selected dependencies. |
| SPEC-005 | Reference-resource generator input hash is stale. |
| SPEC-006 | Legacy Pi screen device surface remains. |
| SPEC-008 | Semantic/Layout join found outside approved producer list. |
| SPEC-009 | ExecutionOpportunityRunner declaration ownership differs from the fixture. |
| SPEC-011 | Two ActionGenerationAllocator constructions instead of one canonical owner. |
| SPEC-012 | Combined stroke emission includes an embedded host owner. |
| SPEC-013 | Dynamic direct-dependency fixture differs; the separate partial-mutation reproduction also remains a correctness blocker. |
| SPEC-014 | Migration inventory and conformance-report prerequisites fail; the report requires a completed plan. |

These assertions need owner review and code/fixture reconciliation on their
merits. Updating allowlists, hashes or lifecycle statuses merely to pass the
gate would not establish the missing production ownership or contract evidence.

All 45 SPEC-001 criteria have a disposition in `criterion-revalidation.tsv`,
which preserves the scope of historical tested evidence and identifies the
assembled-production criteria requiring revalidation. This is not authorization
for an implemented transition. No deployment, service restart or flashing was
performed. The shared-runtime defect is a current correctness blocker;
FW-028 captures only the unrelated unanswered Embedded partition-output
diagnostic question.

A fresh Pi build verifies ARMv6 hard-float. T10.4 nRF ARMv7E-M hard-float, fixed
stores, zero heap and resource evidence remains source-applicable: all 151
selected source hashes match the current code. RAM 195,132 bytes and flash
270,700 bytes remain under unchanged 196,608 / 1,048,576 ceilings. Connected
stack high-water, display/input/cadence and reviewed pixel criteria stay open.

Supporting records: `final-source-applicability.txt`,
`canonical-embedded-contracts.md`, `executable-dependency-isolation.md`,
`dynamic-runner-blocker.md`, `static-runner-blocker.md`.
