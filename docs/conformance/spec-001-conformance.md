---
spec: SPEC-001
feature: signal-analyzer
title: SPEC-001 Conformance Report
status: complete
reviewers: [codex]
created: 2026-09-19
updated: 2026-10-03
implementation_plan: ../implementation-plans/spec-001-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# SPEC-001 Conformance Report

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
| `SA-AC-005` | blocked | [host structural gates](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/host-structural-gates.md), [Pi adapter](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/piscreen-platform-adapter.md), [nRF adapter](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/nrf52840-tft-input-adapter.md) | Semantic hierarchy and device adapters are complete; connected analyzer output on PiScreen and TFT is missing. |
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
| `SA-AC-023` | blocked | [four-preset evidence](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-6/raspberry-pi-armv6.md), [Pi adapter](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/piscreen-platform-adapter.md), [Pi host loop](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/dynamic-pi-lifecycle-owner.md) | ARMv6 and host-native semantics pass. The production analyzer host loop now owns framebuffer/input devices; the earlier connected bounded display transfer did not exercise a physical control or the complete analyzer loop. |
| `SA-AC-024` | blocked | [four-preset evidence](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-6/nrf52840-static.md), [nRF adapter and host loop](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/nrf52840-tft-input-adapter.md) | The selected ILI9486/ADS7846 production firmware and exact-source native probe pass the hardware-free gate; no board was flashed or connected output/input measured. |
| `SA-AC-025` | blocked | [sustained workload](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-7/sustained-workload-and-resources.md), [nRF adapter and host loop](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/nrf52840-tft-input-adapter.md) | Production binary/RAM/storage/drawing fit is inspected; connected stack high-water, timing, and application execution remain missing. |
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
| `SA-AC-039` | blocked | [nRF evidence](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-6/nrf52840-static.md) | Typed storage, ELF, RAM/flash/stack, and forbidden symbols pass; target mutation/publication/frame timing is not collected. |
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
