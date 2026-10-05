---
spec: SPEC-001
feature: signal-analyzer
title: SPEC-001 Conformance Report
status: complete
reviewers: [codex]
created: 2026-09-19
updated: 2026-10-05
implementation_plan: ../implementation-plans/spec-001-implementation-plan.md
related_future_work:
  - FW-027
  - FW-032
  - FW-033
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# SPEC-001 Conformance Report

**Current amendment — 2026-10-05:** Approved five-second retention is implemented and all four hardware-free profiles pass in the [fresh integration](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Focused nRF connected checks/restoration and current Pi deployment/ARMv6 rehearsal/bounded physical endpoint loop succeed. Original exception authority remains unchanged.


**Current disposition — 2026-10-03:** The maintainer explicitly directed
performance work to future iterations and closure of the remaining Specifications.
[Recorded authorization](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/remaining-spec-transition-approval.md) closes SPEC-001, SPEC-011, and SPEC-015
as `implemented` with approved exceptions for measured timing failures and
missing connected evidence. The original requirements and raw results are retained.
FW-027/FW-032 track performance; FW-031/FW-033 track connected validation.
Earlier open-gate statements below describe the pre-approval history.

> **Validation before closeout approval — 2026-10-03:** [Final-artifact closeout](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md): 41 scoped passes, two timing failures and two connected-evidence blockers. Calibration is confirmed. The subsequent approval above closes the four outstanding criteria by exception. The final current-artifact startup/idle stack measurement is 19,480 / 27,648 bytes. Historical sections below retain their original scope.

## 2026-09-27 Landscape Follow-up

The [320×240 candidate](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-8/nrf52840-320x240-landscape-candidate.md)
has a passing cross-build and host-native raster rehearsal and was flashed to
the connected nRF52840-DK. The maintainer's
[connected photograph](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-8/nrf52840-320x240-connected-landscape.jpg)
confirms a horizontal, readable, non-mirrored idle image with four channels,
both control rows, and no visible white strip. The host-native raster clips
longer failure diagnostics. Pixel reference review, physical control actions,
touch calibration, cadence, and resource high-water remain open; the connected
criteria are still blocked. The older review below applies to its stated
target.

> This report records evidence. It does not authorize the governing
> Specification's `implemented` transition.
>
> **Replacement-target applicability:** The table and frozen hashes below are
> the historical review of the original 480 x 320 ILI9486 fixture. The
> [240 x 320 hardware-free follow-up](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-8/nrf52840-240x320-hardware-free.md)
> covers the approved `KMRTM24024-SPI` geometry, direct-SPI transport, static
> host, and cross-build. Independent pixel review and connected display/input
> evidence remain open; the table's five blocked criteria are unchanged.

The [connected 240 x 320 attempt](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-8/nrf52840-240x320-connected-attempt.md)
adds a successful flash and sustained production-scheduler observation.
Display pixels, touch behavior, and the complete connected criteria remain
unverified.

## Review Scope

The review freezes [SPEC-001](../specs/spec-001-signal-analyzer-reference-application.md)
at pre-report SHA-256
`b68b72236c06ba4515acdfd9cb8d68c4d43f0b489a3a556d48b62adeb1bdbb4d`,
the active [implementation plan](../implementation-plans/spec-001-implementation-plan.md),
the current implementation design notes, and reviewed implementation revision
`b5b2640`. Evidence covers Apple Swift 6.3.3 host execution, project-local
Swift 6.3.2 ARMv6/nRF cross-build inspection, and host-native Pi/nRF semantic
fixtures. Connected PiScreen and nRF52840 TFT/input execution was not
authorized or collected.

The 2026-09-24 hardware-free follow-up is recorded at implementation revision
`da4a410d` under the current approved Spec SHA-256
`042e21d20ac320d998fa2f7b8cbdf603981692c2ab32ad3918f0e303d1bc50df`.
T6.7 and T6.8 now compose production target host loops. This update revises
the connected-gate descriptions below; it does not claim a connected run. The
registered SPEC-001 `nrf52840-embedded` gate passed at
`.build/contract-reports/spec-001/20260924T020406Z-13454/nrf52840-embedded/`
with zero failed checks.

## Acceptance-Criterion Results

| Criterion | Result | Evidence | Notes / exception authority |
| --- | --- | --- | --- |
| `SA-AC-001` | pass | [interface audit](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-9/interface-and-dependency-audit.md) | Authority, manifest, and reciprocal implementation links pass governance. |
| `SA-AC-002` | pass | [interface audit](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-9/interface-and-dependency-audit.md) | Exact Domain/Data/Presentation/host direction is audited. |
| `SA-AC-003` | pass | [interface audit](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-9/interface-and-dependency-audit.md) | Domain forbidden-import/facility scans pass. |
| `SA-AC-004` | pass | [interface audit](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-9/interface-and-dependency-audit.md) | Presentation forbidden-import/facility scans pass. |
| `SA-AC-005` | approved exception | [current connected packet](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md) | Reviewed host pixels pass and prior target display/control approvals are retained; complete final connected screen/input coverage is still open. |
| `SA-AC-006` | pass | [host structural gates](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/host-structural-gates.md) | One source identity and fixed hierarchy compile across all profiles. |
| `SA-AC-007` | pass | [repository corpus](../../Tests/ContractFixtures/SPEC001/repository-lifecycle-cases.tsv) | Current-value, replacement, detach, and bounded-return cases pass. |
| `SA-AC-008` | pass | [interface audit](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-9/interface-and-dependency-audit.md), [integrated cycle](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-5/integrated-cycle.md) | Serialized delivery and distinct mutation domains pass without portable concurrency facilities. |
| `SA-AC-009` | pass | [repository corpus](../../Tests/ContractFixtures/SPEC001/repository-lifecycle-cases.tsv) | Complete action/state table passes. |
| `SA-AC-010` | pass | [capture publication corpus](../../Tests/ContractFixtures/SPEC001/capture-publication-cases.tsv) | Clear/rebase/state preservation passes. |
| `SA-AC-011` | pass | [sustained workload](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/sustained-workload-and-resources.md) | Exact 2,400-event logical workload has no loss or duplication. |
| `SA-AC-012` | pass | [sustained workload](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/sustained-workload-and-resources.md) | Static capture storage contains 2,404 transitions and four baselines. |
| `SA-AC-013` | pass | [retention corpus](../../Tests/ContractFixtures/SPEC001/retention-cases.tsv) | Oldest-first eviction and lower-bound levels pass. |
| `SA-AC-014` | pass | [retention corpus](../../Tests/ContractFixtures/SPEC001/retention-cases.tsv) | Stable ordering and invalid/out-of-horizon behavior pass. |
| `SA-AC-015` | pass | [source corpus](../../Tests/ContractFixtures/SPEC001/deterministic-source-cases.tsv) | Exact patterns, restart, cancellation, and teardown pass. |
| `SA-AC-016` | pass | [fact application](../../Tests/ContractFixtures/SPEC001/fact-application-cases.tsv), [integrated cycle](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-5/integrated-cycle.md) | Initial state, mutation-only changes, and synchronous reports pass. |
| `SA-AC-017` | pass | [control matrix](../../Tests/ContractFixtures/SPEC001/control-state-cases.tsv) | All control enabled/disabled states pass. |
| `SA-AC-018` | pass | [presentation values](../../Tests/ContractFixtures/SPEC001/presentation-value-cases.tsv) | Exact one/two/five-second ranges pass. |
| `SA-AC-019` | pass | [waveform corpus](../../Tests/ContractFixtures/SPEC001/waveform-drawing-cases.tsv) | Baselines, transition mapping, and right-edge extension pass. |
| `SA-AC-020` | pass | [waveform corpus](../../Tests/ContractFixtures/SPEC001/waveform-drawing-cases.tsv) | Ruler bytes and 11-plus-one grid pass. |
| `SA-AC-021` | pass | [sustained workload](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/sustained-workload-and-resources.md) | 120 consistent frames cover 2,400 events with coalescing. |
| `SA-AC-022` | pass | [driver suite](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-9/hardware-free-driver-suite.md) | Both macOS executables build, execute, and compare equal. |
| `SA-AC-023` | approved exception | [current connected packet](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md) | Final ARMv6 artifact deployed and hash verified; 32 updates measure 0.72335 frames/second and 1.294–1.522-second costs. Display/control signoff is retained; timing work is postponed under the recorded maintainer-approved closeout exception. |
| `SA-AC-024` | approved exception | [current connected packet](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md) | Clean final firmware flashed; calibration confirmed, software Start accepted and live execution measured. Complete final physical interaction/display/failure corpus remains uncollected; cadence is separately failing. |
| `SA-AC-025` | pass | [current connected packet](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md) | Historical painted stack-fit case passes within its recorded scope. Final firmware builds and runs at 191,104-byte RAM/275,600-byte flash; fresh painted startup/idle stack high-water is 19,480 / 27,648 bytes. The unpainted diagnostic dump is excluded. |
| `SA-AC-026` | pass | [source substitution](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/source-and-facility-substitution.md) | Conforming source replacement changes no portable owner. |
| `SA-AC-027` | pass | [source/facility evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/source-and-facility-substitution.md) | Every required facility fails closed before publication. |
| `SA-AC-028` | pass | [host structural gates](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/host-structural-gates.md) | Host lifecycle owns observation and adapter sinks. |
| `SA-AC-029` | pass | [sustained workload](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/sustained-workload-and-resources.md) | Exact 1/32/1 stores and first-excess corpus pass. |
| `SA-AC-030` | pass | [fact admission](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-5/static-fact-admission.md) | Nonzero sequence, merge order, sealing, and at-most-once application pass. |
| `SA-AC-031` | pass | [fact application](../../Tests/ContractFixtures/SPEC001/fact-application-cases.tsv) | Full replay and mismatch containment pass. |
| `SA-AC-032` | pass | [observable origin](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-5/observable-generation-origin.md) | One portable declaration preserves identity in both profiles. |
| `SA-AC-033` | pass | [observable origin](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-5/observable-generation-origin.md) | Replacement/removal/reinsertion lifecycle passes. |
| `SA-AC-034` | pass | [failure matrix](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/exhaustive-failure-matrix.md) | Every bounded observable failure has a deterministic nonaliasing disposition. |
| `SA-AC-035` | pass | [fact mutation/publication](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-5/fact-mutation-publication.md) | Twenty reports coalesce without fact or publication loss. |
| `SA-AC-036` | pass | [integrated cycle](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-5/integrated-cycle.md) | Button callback becomes a later fact; executor transcripts agree. |
| `SA-AC-037` | pass | [interface audit](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-9/interface-and-dependency-audit.md) | Six qualified actions and total noncapturing handler pass all profiles. |
| `SA-AC-038` | pass | [action target access](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-5/action-model-target-access.md) | Replacement cancellation and failed-replacement preservation pass. |
| `SA-AC-039` | approved exception | [current connected packet](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md) | Current firmware ABI/storage/build evidence passes, but approximately 21-second connected presentation intervals fail cadence. Compliant sustained admission/mutation/publication/frame timing remains unproved. |
| `SA-AC-040` | pass | [failure matrix](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/exhaustive-failure-matrix.md), [diagnostic matrix](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/diagnostic-profile-equivalence.md) | Exact normalization, effect order, policy, and diagnostic independence pass. |
| `SA-AC-041` | pass | [diagnostic matrix](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/diagnostic-profile-equivalence.md) | Complete bounded UTF-8 and projection corpus passes both profiles. |
| `SA-AC-042` | pass | [driver suite](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-9/hardware-free-driver-suite.md) | Both CH4 vectors compare equal in all four fixtures. |
| `SA-AC-043` | pass | [revision exhaustion](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/revision-exhaustion.md) | Transition and Clear boundaries quiesce without wrap or policy. |
| `SA-AC-044` | pass | [interface audit](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-9/interface-and-dependency-audit.md) | Only normalized failure plus bounded diagnostic is representable. |
| `SA-AC-045` | pass | [sustained workload](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/sustained-workload-and-resources.md) | All manifests, limits, Drawing minima, extents, regions, bounds, and assembly values match. |

## Required-Test Results

On 2026-09-19, `scripts/test.sh --profile all-hardware-free` passed from
revision `b5b2640`: governance, formatter lint, root tests, static compiler
probes, and all 60 SPEC-001-through-SPEC-015 profile-driver combinations. The
machine report is `.build/test-reports/all-hardware-free/` with
`failure_count=0`. Standalone SPEC-001 invocations and 24-field normalized
comparison also pass; see the [driver-suite evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-9/hardware-free-driver-suite.md).

## Profile, Backend, and Platform Evidence

macOS Dynamic and Static are executable host evidence. Raspberry Pi includes
an exact ARMv6 hard-float cross-build, host-native Dynamic semantic fixture,
and supplemental connected adapter evidence: deployment without service
restart, validated framebuffer/input descriptors, and one bounded framebuffer
transfer. That transfer is not analyzer-host or physical-touch evidence.
nRF52840 remains ARMv7E-M/VFP hard-float ELF/resource inspection plus a
host-native Static semantic fixture; no board was flashed.

## Resource and Performance Evidence

All four fixtures execute 2,400 events over the exact 30-second logical range
and 120 frame opportunities, with equal workload checksums and exact 28/32/33
capacity boundaries. macOS records host execution. Pi/nRF runtime timing is
`not-collected`; cross-build reports record ABI, maps, symbols, workspaces,
RAM/flash, and supported stack evidence without inferring connected behavior.

## Deviations and Exceptions

No exception is approved. Historical connected Pi frame service exceeds the
250 ms policy; the selected integration has no new connected timing or
six-control evidence. That performance gap remains part of the open Pi
conformance work. Five criteria remain blocked by connected validation: `SA-AC-005`, `SA-AC-023`,
`SA-AC-024`, `SA-AC-025`, and `SA-AC-039`. These are requirements, not waived
exceptions.

## Deferred Work Audit

The 2026-09-30 [Pi performance closeout](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-8/pi-performance-closeout-20260930.md)
records retained internal improvements and postponed investigation under
[FW-027](../future-work/fw-027-pi-performance-investigation-resumption.md).
Historical connected Pi timing exceeds 250 ms; cadence and connected-control
validation remain open. No requirement or exception is approved by the
closeout. FW-024 through FW-026 preserve unselected optimization directions.

FW-017, FW-019, and FW-021 remain
post-MVP extensions and are unnecessary for the fixed analyzer. No deferred
artifact conceals a current correctness or conformance requirement.

## Review Conclusion

Forty criteria pass and five have explicit connected-hardware blockers. The
hardware-free implementation and evidence boundary is complete, but this
report does not yet support requesting SPEC-001's `implemented` transition.
T8.1 through T8.3 remain open for complete connected conformance, including
Pi cadence and six-control validation. Further performance experiments are
postponed under FW-027; any connected work requires its normal authorization. Human conformance review may proceed
with those gates visible.

## Milestone 10 implementation review — 2026-10-02

Code scope: `44ac06a8` and its T10.1–T10.7 prerequisite commits.
T10.1–T10.4 are implemented. T10.5/T10.6 are blocked by the
[reproduced SPEC-013 mutation/failure seam](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/dynamic-runner-blocker.md);
T10.7 delivers independent dependency cleanup but awaits both production
runner joins. The [criterion dispositions](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/criterion-revalidation.tsv)
cover all 45 criteria and distinguish retained historical tested scope from
required assembled-production revalidation. They supersede any inference that
the historical pass table proves the missing production common-runner joins.

Canonical embedded contracts, native layout/Canvas/offer probes, 129-frame /
12-action comparison and ARMv7E-M hard-float fixed-storage/zero-heap/resource
inspection pass. The [source applicability record](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/final-source-applicability.txt)
checks the current firmware selection against T10.4 hashes and records a fresh
ARMv6 hard-float Pi build. No board or remote service was changed. Reviewed
pixels, connected input/display/cadence and stack high-water remain blocked.
The complete cleanup does not support an implemented transition.

The [final registered gate](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/revalidation-disposition.md)
records 30 passing and 42 failing checks across 72 checks, with 1,151 root
Swift tests passing. Owner failures and missing reviewed pixel references
remain explicit; T10.8 is blocked rather than complete.

## T10.5 resumed production join — 2026-10-02

The approved carrier amendments and owning SPEC-013/SPEC-015 handoff resolve the
previous runner seam blocker. T10.5 is complete: the real Dynamic Pi host joins
canonical sequencing, exact focused failures, application effects, recovery and
backend health. See the [reproducible evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/dynamic-failure-recovery.md).
T10.6, final closure checks and assembled revalidation remain outstanding; this
increment does not claim full conformance or any connected hardware evidence.

## Current assembled milestone-10 review — 2026-10-02

T10.1–T10.7 are complete. The [current review packet](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/assembled-revalidation.md)
supersedes earlier seam/closure/gate blocker dispositions while preserving
their original revision scope. The current 45-row criterion ledger records
41 scoped passes and four blocked criteria (SA-AC-005/023/024/039).
SA-AC-025 now passes the measured connected fit-and-run case in the
[raw stack record](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/connected-stack.md).
This supersedes that criterion's historical table row, not the remaining
physical input/display/cadence or admission/mutation/publication/frame-cost gates.

The registered gate records 62/72 passes; eight named focused reruns pass,
leaving two missing reviewed-pixel references. Current root/native/fault/ABI/
resource/isolation checks pass. The final actual-source hashes and raw artifacts
are preserved. T10.8 remains blocked on the references; an implemented transition
is not requested. The flash and debugger measurement were explicitly authorized;
no remote service was deployed or restarted.

## Maintainer-approved pixel closure — 2026-10-03

Eugene explicitly approved the 24 displayed state/target images in chat. The
[locked pixel closure](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/approved-pixel-closure.md)
records unchanged approved bytes, exact final Pi/nRF driver passes and
physical/diagnostic corruption negatives. The 21 current images match exactly;
three cleared-state pairs are historical and current-source cleared capture is
missing. T7.7/T7.9 remain open on that requirement; SA-AC-005 retains its blocker.

All 72 registered checks have passing evidence from the original gate and
named reruns; this does not claim a single fresh 72-check invocation. T10.8
and milestone 10 are complete. The ledger retains 41 scoped passes and four
blocked criteria (SA-AC-005/023/024/039). T8.1/T8.2/T8.3 remain open for connected
input/display, all controls, sustained cadence/costs and trace comparison.
No implemented transition, flash, deployment or service restart follows.

### Current cleared-state recordings — 2026-10-03

Both host-native production recorders now capture Clear after the preserved stop/restart and window-control sequence. Restart preserves history under the approved contract; explicit Clear resets the capture and preserves channel levels. Fresh Pi logical/physical and nRF images, zero-transition/running assertions, unchanged independent behavior comparisons, 21 exact approved-reference matches and 17 passing focused tests are retained in [the capture packet](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/current-cleared-20261003/README.md). T7.7 now awaits visual acceptance of these three fresh candidates; T7.9 awaits their eight-state reviewed-reference gate. Historical cleared references remain preserved. Connected tasks and Specification lifecycle status are unchanged.

### Approved current cleared references and gate closure — 2026-10-03

Eugene accepted all three fresh cleared images. Both registered constrained-profile drivers pass the complete eight-state reviewed-reference set, including Pi physical mapping: 24 current exact pixel comparisons. Independent behavior comparisons, production-loop faults and 269 selected Swift tests per profile pass. [Approval and immutable validation](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/current-cleared-20261003/approval.md) close T7.7 and T7.9. T8.1/T8.2/T8.3 and the connected scope of SA-AC-005/023/024/039 remain open. This evidence is host-native-fixture/cross-build evidence, not connected execution; SPEC-001 remains implementing.

## Pi display/control signoff verified — 2026-10-03

The [connected approval packet](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/connected-pi-20261003/README.md) supersedes the older statements that
production Pi physical controls were unobserved. Eugene confirmed plus/minus
and the calibrated S toggle worked, then explicitly marked the Pi application
verified after reviewing the repeated-R deadline failure. The approval-only
Pi application display/control signoff is complete. This is connected-target
evidence with exact binary identities, raw/normalized contacts, dispatch counts,
health observations, and code-1 exit status; it is not inferred from a build.

The full connected obligations remain open: four-frame/second cadence and
250 ms fact-service latency are not met, burst input includes refusals, and
complete connected interaction/trace/failure-recovery coverage is not collected.
No timing exception or whole-Spec `implemented` transition is inferred from
application signoff. These current blockers cannot be deferred as Future Work.
Temporary stopped-startup hosting and monitoring helpers are removed, with the
working calibration and captured-tap regression retained.

## Current connected closeout and maintainer dispositions — 2026-10-03

The [final-artifact closeout](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md) supersedes earlier claims that no
production artifact was deployed/flashed or that calibration is provisional.
The maintainer explicitly confirmed touch calibration; that subtask is complete.
Pi timing work is postponed under FW-027, and macOS physical-pointer work is
postponed under FW-031. Neither postponement is an acceptance-criterion waiver.

All 72 final registered hardware-free checks pass, including this owner's four
profiles and current production-join/pixel evidence. The final Pi hash is
verified on the target. Its 32 measured updates average approximately 0.72
frames/second, with 1.294–1.522-second costs and 9,740 KiB peak sampled RSS;
bounded SIGINT teardown prints `status=completed`. The cleaned final nRF image
is flashed and running. Its recorded software Start succeeds, driver/CPU fault
samples are zero, and nine live records match the deterministic source prefix.
Observed presentation intervals of approximately 21 seconds fail cadence.

Complete connected physical/failure coverage, sustained 80-Hz acceptance,
target costs and full connected semantic/action/drawing trace comparison remain
unproved. The macOS physical-pointer subset is explicitly postponed. The
Specification and connected plan remain implementing/active; this complete
evidence disposition does not support a full `implemented` transition.

## Final current-artifact stack case — 2026-10-03

The [painted final-firmware snapshot](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md) measures 19,480 / 27,648 bytes after startup/idle, with zero driver/CFSR/HFSR faults and production revision 1. This closes the current startup/idle measurement subcase; it does not establish sustained-load timing or exhaustive worst-case stack use.

## Approved exception and implemented transition — 2026-10-03

**Current disposition — 2026-10-03:** The maintainer explicitly directed
performance work to future iterations and closure of the remaining Specifications.
[Recorded authorization](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/remaining-spec-transition-approval.md) closes SPEC-001, SPEC-011, and SPEC-015
as `implemented` with approved exceptions for measured timing failures and
missing connected evidence. The original requirements and raw results are retained.
FW-027/FW-032 track performance; FW-031/FW-033 track connected validation.
Earlier open-gate statements below describe the pre-approval history.

Final acceptance disposition: 41 scoped passes and four approved exceptions
(SA-AC-005/023/024/039). Raw timing failures and missing coverage remain
unchanged in the evidence packet.

## Iteration 2 maintenance integration — 2026-10-05

[Fresh 30s-contract packet](../iterations/iteration-002-cleanup/evidence/10-integration/result.md)
reviews all 45 criteria against the unchanged approved contract at revision
759cf594. All four owner profiles and their composed resource/dependency gates
pass; all 74 repository checks and 60 immutable reports verify. The original
criterion table and historical raw evidence retain their dispositions. New
startup/capacity/source-selection/generator/compiler observations apply only
to their maintained and hardware-free evidence, with exact hashes and limits
in the linked packet. No lifecycle transition or new exception follows.
Connected changed-path checks and final application reconciliation remain
SPEC-001 T11.7/T11.8. Retention remains 30s/2,404 pending RFC/ADR/Spec gates.

## Current maintenance limits — 2026-10-05

[Connected attempt](../iterations/iteration-002-cleanup/evidence/11-connected-attempt/result.md)
is incomplete and cannot satisfy a new connected criterion or enlarge the
2026-10-03 exceptions. SPEC-001 T11.7 and its dependent T11.8 remain blocked.
The production fixes and all fresh hardware-free observations stand separately;
iteration closure and retention's RFC/ADR/Spec gates remain unmet.

| New maintenance observation | Criteria affected | Evidence and limit |
| --- | --- | --- |
| Terminal source-start publication/quiescence | SA-AC-007/008/009/015/043 | [Real-source admission](../iterations/iteration-002-cleanup/evidence/09-startup-admission/result.md), current hardware-free profiles; no Pi connected pass. |
| Common startup Layout, source closure and exact generated topology | SA-AC-005/006/025/028/030/036/040/041/045 | [Startup](../iterations/iteration-002-cleanup/evidence/06-startup-text/result.md), [selection](../iterations/iteration-002-cleanup/evidence/07-source-selection/result.md), [generator](../iterations/iteration-002-cleanup/evidence/08-topology/result.md), fresh profile reports; no independent connected pixels. |
| Actual compiler/SDK/artifact and resource identities | SA-AC-022/023/024/025/039/045 | [Integration](../iterations/iteration-002-cleanup/evidence/10-integration/result.md); ABI/configured resources pass, timing and whole-stack limits preserved. |
| Authority/source provenance and repeatable reports | SA-AC-001/002/003/004 | [Source paths](../iterations/iteration-002-cleanup/evidence/03-source-paths/result.md), [runner](../iterations/iteration-002-cleanup/evidence/04-runner/result.md), 60 verified owner/profile reports; no approval inferred. |

## Current approved retention amendment — 2026-10-05

[Explicit approval](../iterations/iteration-002-cleanup/retention-approval.md)
and accepted ADR-034 supersede earlier pending-approval/30s descriptions for
current production. [Five-second integration](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md)
verifies all four owner profiles with current source-hashed raster references:
74 checks and 60 report manifests pass. Five-second/404-record baseline,
eviction, snapshots, replay and independent full-history 1/2/5s left edges pass;
the 30s/80-event-per-second delivery workload remains unchanged. Linked nRF
RAM is 95,104 (−96,000), flash 274,144 (−128), configured stacks unchanged,
heaps zero and hard-float ABI verified. Exact criteria/commands/compiler/
artifact identities and raw failures are retained in the packet.

[nRF connected verification](../iterations/iteration-002-cleanup/evidence/16-nrf-connected/result.md)
completes startup/software Start/Stop/1/2/5s/capture/fault/cleanup observations
on the current firmware and restores running idle. This is not physical-input,
independent pixel, sustained 80-Hz, cadence or exhaustive stack evidence.
Pi connectivity blocks its new deployment/production-loop check and dependent
SPEC-001 T12.4/T11.7/T11.8. Prior specifically approved exceptions and original
criterion/raw evidence remain unchanged; no broader exception or lifecycle
transition is inferred. Earlier connected-failure statements are historical;
current nRF restoration succeeds and explicit deployment approval is recorded.

### Current criterion dispositions for the approved amendment

| Criterion | Disposition | Current evidence and limit |
| --- | --- | --- |
| `SA-AC-001` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-002` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-003` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-004` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-005` | approved exception | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Original 2026-10-03 exception retained unchanged; packet 18 revalidates hardware-free portions and packet 16 supplies only its bounded nRF subset. Pi changed-path work remains blocked. |
| `SA-AC-006` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-007` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-008` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-009` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-010` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-011` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-012` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). 404 records per store, five seconds inclusive, separate baselines, 19,392 bytes for three slots; delivery workload remains 2,404. |
| `SA-AC-013` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-014` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-015` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-016` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-017` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-018` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-019` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-020` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-021` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-022` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-023` | approved exception | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Original 2026-10-03 exception retained unchanged; packet 18 revalidates hardware-free portions and packet 16 supplies only its bounded nRF subset. Pi changed-path work remains blocked. |
| `SA-AC-024` | approved exception | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Original 2026-10-03 exception retained unchanged; packet 18 revalidates hardware-free portions and packet 16 supplies only its bounded nRF subset. Pi changed-path work remains blocked. |
| `SA-AC-025` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Current linked RAM 95,104 and flash 274,144; configured stacks unchanged. Historical painted high-water applies only to its historical artifact; no new exhaustive stack measurement. |
| `SA-AC-026` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-027` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-028` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-029` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-030` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-031` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-032` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-033` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-034` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-035` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-036` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-037` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-038` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-039` | approved exception | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Original 2026-10-03 exception retained unchanged; packet 18 revalidates hardware-free portions and packet 16 supplies only its bounded nRF subset. Pi changed-path work remains blocked. |
| `SA-AC-040` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-041` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-042` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-043` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-044` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `SA-AC-045` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |

## Current Pi completion and iteration reconciliation — 2026-10-05

[Verified deployed image](../iterations/iteration-002-cleanup/evidence/21-pi-deployment/result.md)
and [current ARMv6 connected packet](../iterations/iteration-002-cleanup/evidence/22-pi-connected/result.md)
supersede the previous connectivity blocker. Actual ARMv6 production-owner
software/recording rehearsal passes 120 workload frames, nine startup/action
frames and 12 actions against the current hashed reference. Real physical
framebuffer/touch loop runs boundedly, observes no supplied contacts, and ends
`status=completed` with no remaining process and unchanged hash. Physical-loop
frame costs remain 1.322–1.509s; no timing pass is inferred. Software/control/
source proof and physical endpoint startup/cleanup remain separately classified.
Together with nRF packet 16, T12.4/T11.7 and final T11.8 are complete.
[Final criterion/closure record](../iterations/iteration-002-cleanup/evidence/23-closeout/result.md)
retains the original exception and deferred boundaries; no Specification
lifecycle transition or broader physical/timing/stack conformance follows.
