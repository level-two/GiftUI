# Approved five-second retention integration — 2026-10-05

Invocation `run-IehHOIJf`, starting revision `feb4058920efbbb541787485a28b4d727dcc8b3b`.
Concurrent documentation-only commit `8e3e5ee9` advances some child revision
identities; exact per-report identities are retained. Maintained production
inputs and the source-hashed current reference bundle remain unchanged.
Formatter preceded `scripts/test.sh all-hardware-free`. All **74 checks pass**,
including the canonical 300 XCTest / 1,168 Swift Testing corpus and all 60
registered owner/profile reports. Every report manifest verifies.

[Parent identity](metadata.txt), [results](results.tsv), [child ledger](child-reports.tsv),
[verified report identities](report-identities.json), [raw logs](validation-logs.tar.gz),
[archive hashes](archive-identity.json), [maintained inputs](maintained-input-hashes.tsv),
[approved contracts](contract-hashes.tsv), and per-owner metadata/command/criterion
snapshots under `reports/` preserve reproducible identities. Canonical reports
contain the full build/pixel payloads; these snapshots do not substitute for them.

RFC-012, accepted ADR-034 and faithful SPEC-001/013/015 amendments have
[explicit approval](../../retention-approval.md). T12.1–3 are complete.

## History and current raster oracle

The archive preserves failed/interrupted `run-bmuwVkCK`: SPEC-001 Pi frame 3
compared current 60 with historical 64, then the gate was interrupted. This
was a stale 30s reference default, not a current target parity failure.
[Correction and raw failure](../17-current-traces/result.md) require freshly
published, source-hashed reference traces. This successful run uses its own
root-corpus [reference bundle](reference-traces/identity.json), verified against
504 maintained source inputs. Dynamic comparisons cover 120 frames, nine other
observations and 12 actions; Static covers 818 frames and 12 actions. Historical
30s reports remain unchanged and are not relabelled as five-second evidence.

## Contract and resource observations

All three capture stores retain five seconds inclusive, each bounded to 404
records, total 19,392 bytes. Boundary/equal-time/404–405/Clear/snapshot/replay/reuse
and the independent 601-cycle full-history left-edge/baseline oracle pass for
1/2/5s views. The synchronized 30s / 80-event-per-second fixture still delivers
2,404 revisions and retains 404; its cutoff is 25s. Unchanged production source
patterns deliver 2,404 in the accelerated host rehearsal but span 201,770ms:
that schedule retains 61, independently computed, rather than historical 359.
Delivered count, retained count and wall time remain distinct.

[Matched linked resources](paired-retention-resources.json): flash 274,272 →
274,144 (−128); RAM 191,104 → 95,104 (−96,000). Exactly three capture slots
shrink together. Main stack remains 27,648 bytes, ISR 2,048, workqueue 1,024,
idle 320; both heaps remain zero. ARMv6 hard-float, ARMv7E-M/VFP, dependency,
forbidden-symbol and configured resource gates pass. These are linked/configured
bounds, not measured exhaustive stack use or physical timing.

Native Swift 6.3.3/macOS SDK 26.5 is recorded separately from paired artifact
Swift 6.3.2. Pi uses ARMv6 SDK SHA-256
`db81f8323c965f9ad31b60a97576f934af909c5e24f5142fbfb6ea92cf90c335`.
nRF uses SDK 0.17.4 / Zephyr `3568e1b6d5cdd51a6b964a2a1d6d29200fea2056`.
Per-profile metadata identifies exact compilers, SDKs and artifact hashes.
Current Pi artifact: `90dec11ef8cfd39480b888eb0cdef90ac9695d454ef7f9bdd12466ab7c8fa211`.
Current nRF ELF: `9822838bccedb57f2819e6d3e8b0e796c15f9e8357d5880bced3bb4cb2b68f2f`.

## Conformance limits and remaining device dependency

SPEC-001's 45 criteria retain 41 scoped passes and the four specifically
approved exceptions SA-AC-005/023/024/039; SPEC-011's 13 and SPEC-013's 15
owner criteria retain their passing tested scope. Current amended retention
rows and owner/profile resource gates are revalidated here. No lifecycle
transition, broader exception or physical-input/pixel/cadence claim follows.

[nRF connected packet](../16-nrf-connected/result.md) verifies this ELF on
J-Link 683833660: startup, software Start/Stop/1/2/5s controls, capture prefix,
zero driver/CPU faults and cleanup/restoration to running idle. Pi deployment
and its bounded production-loop check remain blocked by name resolution.
T12.4/T11.7 and dependent T11.8/FINAL-01 are incomplete; iteration stays active.
FW-027/031/032/033 and residual EXP-001/FW-029 boundaries remain unchanged.
