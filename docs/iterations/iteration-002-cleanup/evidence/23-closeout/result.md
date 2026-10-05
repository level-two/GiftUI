# ITERATION-002 final reconciliation — 2026-10-05

All nine selected production outcomes and their bounded validation are complete.
Final production inputs are unchanged from the [74-check/60-report integration](../18-retention-integration/result.md).
[Pi deployment](../21-pi-deployment/result.md) and [ARMv6 acquisition/control
rehearsal plus bounded physical endpoint loop](../22-pi-connected/result.md)
resolve the prior connectivity blocker. [nRF current-image software controls,
capture/fault/cleanup and idle restoration](../16-nrf-connected/result.md)
complete the other required connected subset. T12.1–4, T11.1–8, owner maintenance
and TOOL/RET tasks are complete. No new exception or Specification transition.

## Maintainer authorization and closure provenance

Eugene requested all iteration-002 tasks without another proceed question and
commits for each step, then explicitly instructed:

> Please proceed. I approve everything, both five-second retention, by deployment and NRF deployment.

[Contemporaneous authorization](../../retention-approval.md) records the faithful
workflow and device scope. This final record applies that standing approval to
completion and closure of the fulfilled selected iteration; it does not claim
an additional post-result approval message. Later “Please proceed, it should now
be online” and “.44 is the ip, please try once again” authorize resumed execution.
No failed or unavailable criterion is turned into a pass by authorization.
The scope is closed at its approved revision 7 with this provenance. Existing
MVP exceptions retain their original explicit 2026-10-03 authority and limits.

## Final iteration criterion dispositions

| Criterion | Disposition | Evidence and limit |
| --- | --- | --- |
| IT-AC-001 | Met | Approved numbered scope, authority and fresh governed task/criterion records; validator results retained below. |
| IT-AC-002 | Met | Packet 18: all four dependency/source/import/executable closure configurations. |
| IT-AC-003 | Met | Packet 08 clean two-output generation, exact deterministic bytes, 42 semantic cases/refusals/freshness, isolated zero linked delta; packet 18 regression. CBR-002 residual mappings remain deferred. |
| IT-AC-004 | Met | Packet 07 exact 15 guards and shell, coherent source lists/negatives/native behavior, isolated zero linked delta; packet 18 all profiles. |
| IT-AC-005 | Met | Approved RFC-012/ADR-034/Specs, packets 13/14/18 five-second/404/all-three-store and independent boundary/history/parity oracles; −96,000 linked RAM. Packets 16/22 scoped connected observations with software versus physical provenance explicit. |
| IT-AC-006 | Met | Historical steps 00–30, coverage, raw research and limits retained separately from current production evidence. |
| IT-AC-007 | Met | All nine outcomes traced to authority, ordered owner tasks, per-step commits and current hashes; this final reconciliation and standing maintainer approval close the fulfilled scope. |
| IT-AC-008 | Met | Packets 01/09/18 callback-safe real source/admission/terminal lifecycle regressions, packet 22 actual ARMv6 source/control rehearsal and bounded physical endpoint cleanup. No original Pi reproduction is mislabeled an nRF defect. |
| IT-AC-009 | Met | Packet 02 independently unequal real Dynamic/Static five-store capacity/error/rollback/reuse corpus; packet 18 composed profiles/resources. |
| IT-AC-010 | Met | Packet 04 isolated/serialized writers, overlap/failure/interruption and retained ledgers; packets 17/18 actual failed and successful run identities. |
| IT-AC-011 | Met | Packet 03 safe documented source paths, authority/reciprocal semantics and refusal fixtures; governance. |
| IT-AC-012 | Met | Packet 05 native versus paired compiler fixture; packet 18 all current compiler/SDK/artifact metadata. |
| IT-AC-013 | Met | Packet 06 shared Layout startup/codec/failure/cleanup corpus and paired no growth; packet 18 ABI/native regression; packet 16 current connected startup/control/fault/restoration. |

## Conformance, final devices and deferred boundaries

SPEC-001 retains 41 scoped passes and four approved exceptions SA-AC-005/023/024/039;
SPEC-011 13, SPEC-013 15 and SPEC-015 18 owner criteria retain their tested scope.
No blanket physical-pixel/input, sustained 80-event/s wall-time or exhaustive
stack proof follows. Current Pi frame costs 1,322,263–1,509,253us still fail
four fps; the old timing exception is not relabelled as success. Its accelerated
recording rehearsal delivers 2,404 revisions and retains schedule-specific 61;
the synchronized 30s fixture independently retains 404. Final Pi hash matches
packet 18, process is stopped after bounded SIGINT cleanup, no service restart.
The nRF approved image remains running idle as verified in packet 16.

CBR-001/003/004/006/007/008 are corrected in the selected scope. CBR-002 is
partial: clean generator only; named roles/ordinal/model mapping remain EXP-001.
CBR-005 lookup share remains unmeasured under FW-032. Fifteen named guards and
alias are retired; residual policy remains FW-029. FW-027/032 retain performance,
FW-031/033 broad physical/pixel/failure validation, FW-028 separate compiler
output diagnostics. No deferred item is promoted by this closure.

## Governance verification boundary

`governance.log` validates a snapshot of current tracked working-tree files plus
this new closeout packet. `snapshot-input-hashes.tsv` freezes those inputs.
This excludes concurrently authored, untracked SPIKE-015 and its experiment:
its unfinished reciprocal links fail full working-tree authority validation in
`working-tree-governance.log`. That independent iteration-003 preparation is
not silently changed or committed here. The owned closeout task ledger and
committed repository authority set are validated separately; the transient
working-tree failure remains visible and is not reported as a pass.

The first snapshot attempt did not preserve executable modes, so the validator could not launch its graph helper. The retry restores tracked file modes and passes; the initial transport failure is preserved in `governance-initial-snapshot.log`. No production/governance code was changed for this retry.
