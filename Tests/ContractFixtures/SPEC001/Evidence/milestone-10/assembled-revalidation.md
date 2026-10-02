# T10.8 — Assembled review with two external pixel-reference gates

2026-10-02. T10.1 through T10.7 are complete. The canonical Dynamic and Static
production common-runner joins are delivered, their exact failures and no-replay
behavior agree, executable dependencies are isolated, and the final Static
image's connected stack measurement passes. Earlier seam, closure and 42-check
blocker records remain historical; this record supersedes their current status.

The complete registered `scripts/test.sh all-hardware-free` invocation records
**62 passing / 10 failing checks**, 72 total, at starting revision `5058ff50`.
It includes 1,159 root tests and both full macOS reference corpora. It ran across
subsequent reviewed fixture changes; per-owner input hashes retain their exact
scope. Original exit statuses, metadata and all 72 logs are preserved in the
`assembled-gate-*` artifacts. This is not presented as one uniform final-revision
pass or rewritten after the fact.

Four SPEC-004/005 macOS fixture checks subsequently pass. Both widest-resolver
height fixtures now use approved 320×240 landscape geometry, and SPEC-005's
exact direct-consumer set reflects the canonical runtime/host join. All four
SPEC-014 drivers pass after fresh owner evidence reviews the six amended-fixture
criteria (19 normalized fixture IDs agree exactly; unchanged ceilings).
`assembled-focused-reruns.tsv` and its archive record these eight actual reruns.
Thus **70 of the 72 registered checks have passing recorded evidence**, using
the gate and named reruns, while two SPEC-001 constrained-profile checks remain
blocked by missing independently reviewed RGB565 references. No check is removed,
waived, or supplied with self-approved output.

Final-source checks add the 1,158-test root run (excluding the two already-run
expensive reference corpora), 818-frame/12-action actual firmware-native/reference
agreement, production prefix/fault/recovery tests, exact current source inventory,
84-target/375-edge interface and executable closure checks, actual firmware
negative import checks, Static allocation/storage/profile checks, Swift formatting
and governance. Later edits are documentation/evidence only. Archives preserve
commands, logs, source hashes and profile scopes. Supporting owner conformance
records preserve historical evidence and attach current review applicability.

Resources: final flashed image FLASH 275,504 and RAM 191,104 bytes, against
unchanged 1,048,576/196,608 ceilings; main stack 27,648 capacity, 19,480 measured
high-water and 8,168 untouched bytes. Common coordinator/first-failure regions
remain 192/96 bytes. The actual fixed six-slot interaction backing reduces
unused stored capacity while preserving canonical algorithms and routing.
This is a measured connected case, not an exhaustive worst-case or timing proof.

All 45 acceptance criteria have current scoped dispositions: **41 pass in their
recorded evidence scope; four remain blocked** (SA-AC-005/023/024/039). SA-AC-025
now has connected fit-and-run evidence. Physical display/input acceptance, locked
pixels and target admission/mutation/publication/frame cost/cadence remain open.
T10.8 remains blocked solely on the two registered pixel-reference gates; neither
milestone completion nor an implemented transition is claimed.

The current raster-candidate packet is prepared for independent review. It does
not install any output in PixelReferences. Connected measurement was explicitly
user-authorized; no Pi deployment or remote restart was performed.

Both final candidate-only raster runs pass, with Pi's 120 workload/nine
initial-action/12-action and nRF's 818-frame/12-action independent comparisons.
The stale Pi behavior transcript is replaced by the verbatim independent gate
corpus; no comparison is weakened. The [24-image review packet](pixel-review/README.md)
and raw recording archive are current and remain unapproved.
