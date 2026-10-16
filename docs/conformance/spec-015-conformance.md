---
spec: SPEC-015
feature: giftui-mvp-architecture
title: SPEC-015 Conformance Report
status: collecting
reviewers: [codex]
created: 2026-09-19
updated: 2026-10-16
implementation_plan: ../implementation-plans/spec-015-implementation-plan.md
related_future_work:
  - FW-022
  - FW-032
  - FW-033
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# SPEC-015 Conformance Report

Current Pi collection/link evidence — **409/409 and early ARMv6 hard-float ABI PASS**.
The [current Pi result and independent review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-current-pi-collection-image-result.md)
qualifies current compilation and image only; no complete stack/allocation/fit or
Pi execution is claimed. Native omissions, matched resources, caller/exit remain.

Current nRF counter resource evidence — **new image independently accepted**.
The [image review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-current-firmware-final-fit-independent-review.md)
accepts current ELF `0e54fe25` under ADR-040: complete main/ISR bounds
95,469/6,672; actual charge255,612/extent255,616 within physical262,144.
The [remaining P08 campaign](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-remaining-acceptance-campaign.md)
retains exact Pi/Native route/allocation/stack, caller and independent-exit duties.
P08/R07/T8.1 and full SO remain open; earlier resource boundaries below are historical.

Current counter-only resource direction — **independent conservative-bound PASS;
final normal image pending**. The [independent complete-bound review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-current-firmware-complete-bound-independent-review.md)
repairs a decoder writeback omission and confirms frozen main/ISR bounds
95,469 / 6,672. Approved physical-SRAM direction permits the proposed
106,496 / 8,192 reservations, projecting RAM 255,612 within 262,144. Reconcile
counter-only authority and requalify the newly hash-frozen guarded image, including
fresh address-specific proof; no source correction allowance resets. The former
199,860 > 196,608 live-path rejection remains historical evidence against the old
ceiling. P08/R07/T8.1 and full conformance remain open.

Current actual firmware evidence — **stack fit fails**. The
[linked resource result](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-current-firmware-resource-result.md)
adds complete nRF 227/227 and normal pristine ABI/layout/RAM/flash passes, but
required linked cold reservations 28,560 exceed main 27,648 before omitted costs.
Full stack/IRQ/rooted-allocation and remaining four-route/P08 acceptance stay open;
no criterion, limit or repair allowance is waived by these passes.
The [independent bounded resource review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-current-firmware-independent-review.md)
confirms the package and stack rejection, without closing P08 or full conformance.

Historical measurement prerequisite: the [resource worksheet](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-resource-worksheet.md)
clarifies applicability: the contract-object failure below does not establish
final firmware fit/failure, because the normal image recompiles 24 owners with
differing flags. A complete current nRF collection and normal guarded image are
the then-required resource-evidence prerequisite, now collected above; acceptance
dispositions remain open.

Historical P08 boundary — **focused behavior/layout passes; main-stack failure**.
The [current result](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-constructor-caller-final-result.md)
and [independent exit review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-constructor-caller-final-independent-review.md)
qualify source `51cfc960`: three focused collections pass, but required cold
28,288 exceeds main 27,648 before omitted costs. Full current four-route coverage,
images and complete resources remain open. The
[completion/resource assessment](../implementation-designs/spec-015-p08-completion-resource-assessment.md)
maps P08 versus P09–P12/I4-07 obligations and the next evidence prerequisite.
This is not a full criterion review or resource exception; collecting status,
all full SO criteria and P08/R07/T8.1 remain open, correction 2/2 closed.

## Historical RFC-014 amendment applicability — 2026-10-12

**Option B documents approved; implementation separate/not started.** Accepted
[ADR-038](../adrs/adr-038-construction-graph-and-operational-contracts.md) and the
[exact approval with execution limit](../iterations/iteration-003-review/rfc-014-spec-approval.md#option-b-construction-graph-amendment--2026-10-12)
now govern HC-003's direct construction graph and separate operational/lifetime
proofs. This report remains collecting. HC-003's amended requirements are pending;
historical passing rows below prove only their named baseline. No current mask,
compiler feasibility or P08 exit is established by document approval. Follow
[P08-B01→B02→B03](../iterations/iteration-003-review/rfc-014-implementation-plan.md#option-b-resumption-sequence--separate-activity)
in a separate implementation activity, then the remaining P08 gates. Historical
2/2 remains closed; latest 0/1 remains unconsumed. No new implementation evidence
was produced in this documentation activity.

Collecting for the approved schema-4 amendment. Historical completed evidence
below applies to its frozen baseline, not the amended host/runtime migration.
P08 orientation exposes an [exact scoped host contract blocker](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-host-constraint.md);
the exact correction is now explicitly approved and applied after separate review.
Approved host/schema component slices compile complete HostConfiguration and pass
320 assertions per native route plus missing-field/generator/ownership controls.
Complete supplied application audits and runtime-host conformance remain unclaimed. T8.1,
HC-RD-001–004 and full P10–P12 obligations remain open; P07's finite pass does
not satisfy them. [P08 receipt](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/progress.md)
records source/compiler identities, expected compile controls and historical 2/2 guards.
The [activation-time containing-owner stop](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/activation-join-stop/stop.md)
preserves exact failed controls; no package acceptance or compiler-bug attribution is claimed.
Separately authorized evidence-only investigation, continued under independent
accounting review `c05e6d35`, stopped after3/6 invocations on2/2 layouts with no
positive/negative pass; conservative candidate guard2/2, production guard2/2 unchanged.
Its [finite result](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/activation-join-investigation/result.md)
has completed [independent final review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/activation-join-investigation/final-review.md).
The maintainer subsequently authorized bounded blocker resolution. The
[independently reviewed minimal comparison](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/compiler-comparison/final-review.md)
at `80161faa` verifies Swift 6.4 as a candidate while 6.3.3 accepts the wrapped
escape, matching frozen 6.3.2 controls. [Fresh actual native feasibility](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/compiler-native-join/result.md)
at `ceaed326` / `6a0fb348` rebuilds 25 dependencies, executes the actual positive
and rejects reachable callback escape. [Independent review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/compiler-native-join/final-review.md)
at `156f3fb4` passes the bounded pair and supports proposal presentation. This is a
Static coordinator under preserved Dynamic-profile flags, not full profile coverage.
The [baseline correction is approved](../iterations/iteration-003-review/rfc-014-spec-approval.md#swift-64-compiler-baseline-correction--2026-10-12)
and applied. **The P08 activation construction/lifetime blocker is resolved.**
[Independent final audit](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/activation-integration/baseline-final-review.md)
`0555805f` passes the actual generic-host join, both maintained native P08 gates
(368 assertions/37 checks each), four-profile macro/core/runtime/Foundation
regressions, matched resource pairs, target ABI and isolated native latency.
Existing contracts and resource limits are unchanged. Historical guards and
closed budgets remain preserved.

Full validator/application owners, finite counter, four-route application/early
images and remaining P08/P10–P12 criteria still require their own evidence.
Component synthetic reports and adapter traces do not satisfy those criteria.
SPEC-015 remains implementing, its plan active, and T8.1/P08 incomplete.

**Current amendment — 2026-10-05:** Approved five-second retention is implemented and all four hardware-free profiles pass in the [fresh integration](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Focused nRF connected checks/restoration and current Pi deployment/ARMv6 rehearsal/bounded physical endpoint loop succeed. Original exception authority remains unchanged.


**Current disposition — 2026-10-03:** The maintainer explicitly directed
performance work to future iterations and closure of the remaining Specifications.
[Recorded authorization](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/remaining-spec-transition-approval.md) closes SPEC-001, SPEC-011, and SPEC-015
as `implemented` with approved exceptions for measured timing failures and
missing connected evidence. The original requirements and raw results are retained.
FW-027/FW-032 track performance; FW-031/FW-033 track connected validation.
Earlier open-gate statements below describe the pre-approval history.

> **Validation before closeout approval — 2026-10-03:** [Final-artifact closeout](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md) revalidates the approved seam and all four hardware-free profiles. Calibration is confirmed and final artifacts are deployed/flashed. Connected cadence and complete physical/fault/trace coverage were unresolved; the subsequent approval above closes this iteration with exceptions.

> **Historical amendment applicability — 2026-10-02:** The maintainer approved the
> coordinated SPEC-013/SPEC-015 seam amendment. Earlier passing rows remain historical evidence
> for the frozen baseline and their tested inputs. This report is `collecting`
> for the amendment; partial admitted-work failure and exact application
> rejection through the host opportunity boundary need new evidence from
> [SPEC-013 Milestone 9](../implementation-plans/spec-013-implementation-plan.md#milestone-9-preserve-partial-mutation-and-exact-application-failures).
> No blanket current conformance or implemented transition is claimed.

## 2026-09-27 Landscape Follow-up

The approved nRF preset and generated workload now use 320×240 with a 320×4
RGB565 tile and 2,560-byte raster, payload, and in-flight limits. Generator
freshness and the [four-preset comparison](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-6/320x240-four-preset-comparison.md)
pass. A [connected photograph](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-8/nrf52840-320x240-connected-landscape.jpg)
confirms a visible landscape idle frame. Input and sustained connected-host
evidence remain open. The old 240×320 comparison below is historical.

> This report records evidence. It does not authorize the governing
> Specification's `implemented` transition.
>
> **Replacement-target applicability:** The nRF pass rows below are the
> historical review of the original 480 x 320 fixture and frozen contract
> hash. The [240 x 320 four-preset follow-up](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-6/240x320-four-preset-comparison.md)
> verifies the approved `KMRTM24024-SPI` preset and hardware-free resource
> bounds. Connected display/input behavior remains unverified.

## Review Scope

The review freezes [SPEC-015](../specs/spec-015-host-configuration.md) at
pre-report SHA-256
`599afed02b15a8116ed76c68fd4461fe0582f611620df8d43d7475711a794d3f`,
the active [implementation plan](../implementation-plans/spec-015-implementation-plan.md),
its current generated-workload and wake/pacing design notes, and reviewed
implementation revision `6202efd`. The four immutable profile reports share
run ID `6202efd224733528dd679e7426f82ea6b9544a7f-7c95f8e7532ba3bf`.
This amendment review includes schema-3 semantic structural capacity and the
2026-09-20 reapproval. Evidence covers Apple Swift 6.3.3 host
execution and project-local Swift 6.3.2 ARMv6/nRF hardware-free artifact
inspection. Connected PiScreen and nRF TFT/input evidence is intentionally not
collected.

## Acceptance-Criterion Results

| Criterion | Result | Evidence | Notes / exception authority |
| --- | --- | --- | --- |
| `HC-001` | pass | [source boundaries](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-7/source-boundary-scan.md) | Authority, manifest, portfolio, and upstream relationships remain correctly scoped. |
| `HC-002` | pass | [validation guard](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-1/component-graph-and-validation-guard.md), [policy/report validation](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-3/policy-and-report-validation.md) | Nine pure stages stop at first failure and construction follows a complete report. |
| `HC-003` | pass | [source boundaries](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-7/source-boundary-scan.md), [graph validation](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-1/component-graph-and-validation-guard.md) | Exact owner graph and all forbidden imports/ambient lookup scans pass. |
| `HC-004` | pass | [complete workload validation](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-3/complete-workload-validation.md) | Complete schema-3/profile/storage/static-table equality, including semantic structural capacity, and per-leaf negatives pass. |
| `HC-005` | pass | [generated workload](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-2/generated-workload-and-presets.md) | Five-Canvas, point/subpath/operation, and all producer limits are exact. |
| `HC-006` | pass | [capability validation](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-3/capability-validation.md) | Drawing and capability gates remain independent and conjunctive. |
| `HC-007` | pass | [capability validation](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-3/capability-validation.md), [endpoint validation](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-3/endpoint-validation.md) | Four roles, five bits, one resolution, and endpoint equality pass. |
| `HC-008` | pass | [profile/text validation](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-3/profile-and-text-validation.md) | Exact immutable resources and all nine text mappings pass. |
| `HC-009` | pass | [normalized input/action](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-5/normalized-input-and-action.md) | Six actions, owner cardinalities, stale/replacement faults, and non-retention pass. |
| `HC-010` | pass | [application opportunity](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-5/application-opportunity-integration.md) | Same-thread/distinct-executor admission and mutation transcripts are equal. |
| `HC-011` | pass | [wake/pacing](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-5/wake-and-pacing.md), [presentation recovery](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-5/presentation-recovery.md) | Exact timing, 20/2/6 burst, 28/32/33, category excess, and refusal rules pass. |
| `HC-012` | pass | [failure adapter](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-4/host-failure-adapter.md) | Total policy/no-policy matrix follows mandatory effects and ignores diagnostics. |
| `HC-013` | pass | [four presets](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-6/four-preset-comparison.md) | macOS equality and exact Pi/nRF tiled projections pass. |
| `HC-014` | pass | [activation lifecycle](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-4/activation-lifecycle.md), [endpoint health](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-5/endpoint-health-and-reconstruction.md) | Every intermediate teardown and fresh-construction trigger passes. |
| `HC-015` | pass | [nRF static](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-6/nrf52840-static.md), [repository gates](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-7/repository-gates.md) | Zero prohibited facility/allocation and exact resource categories are inspected. |
| `HC-016` | pass | [four-profile driver](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-7/four-profile-driver.md) | Every hardware-free fixture is explicit and evidence output is bounded to build roots. |
| `HC-017` | pass | [four presets](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-6/four-preset-comparison.md) | Cross-build rows are labeled and make no connected-target claim. |
| `HC-018` | pass | [preset host instance](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-4/two-phase-preset-construction.md), [activation lifecycle](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-4/activation-lifecycle.md) | Finite lifecycle, illegal-state rejection, payload preservation, and report exposure pass. |

## Required-Test Results

The exhaustive negative audit and all 144 focused Host Configuration tests
pass. All four exact driver modes, formatter, governance/documentation checks,
generated freshness, source/import scans, and
`scripts/test.sh --profile all-hardware-free` pass; see the
[repository-gate evidence](../../Tests/ContractFixtures/SPEC015/Evidence/milestone-7/repository-gates.md).

## Profile, Backend, and Platform Evidence

macOS Dynamic/Static are host execution. Raspberry Pi is exact ARMv6 EABI5
cross-build inspection with a 240×16 RGB565 region plus supplemental connected
adapter evidence: deployment without service restart, device validation, and
one exact bounded framebuffer transfer. It is not connected application/input
evidence. nRF is ARMv7E-M/VFP hard-float link inspection with a 480×4 RGB565
region, 3,840-byte bounds, and a finite device-validation entry. No nRF flash
or connected nRF display/input result is claimed.

## Resource and Performance Evidence

Static evidence records zero prohibited allocation/runtime facilities and
separate profile, host, application, capability, backend, staging, stack,
flash, and RAM costs under pinned toolchains. Dynamic reports retain bounded
allocation/bookkeeping and equal semantic checksums.

## Deviations and Exceptions

No implementation divergence or approved exception was found. The authorized
[PiScreen adapter evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/piscreen-platform-adapter.md)
now includes production device ownership and a bounded connected framebuffer
transfer, but not the configured analyzer host or a physical touch. The
[nRF adapter evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-6/nrf52840-tft-input-adapter.md)
is hardware-free pending the physical safety gate and production Static host.
PiScreen and nRF52840 application-level TFT/input validation therefore remains
missing; this is an explicit
downstream conformance gate, not an exception.

## Deferred Work Audit

FW-022 remains a post-MVP simulator idea and cannot replace connected evidence.
Contextual FW-006, FW-009, and FW-018 remain outside this Specification. No
deferred item conceals a current host-configuration correctness requirement.

## Review Conclusion

All eighteen contract criteria have passing hardware-free dispositions, but
the Specification requires separately named connected PiScreen and nRF TFT/
input evidence before the assembled configuration may transition to
`implemented`. This report is ready for human review but does not yet support
that transition. SPEC-015 and its plan remain active/`implementing` with the
connected-target rows open.

## Approved amendment seam handoff — 2026-10-02

The [SPEC-013 Milestone 9 handoff](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-9/owner-handoff.md)
records the implemented partial-mutation/generic owner seam, passing behavior
and bounded carrier checks, and four passing registered profiles for this
owner at f6ef6fb6. This supersedes the pre-amendment seam defect only.
Assembled SPEC-001 T10.5/T10.6 and total budget/fault revalidation remain
outstanding; historical criterion rows do not silently become current
production conformance. No implemented transition is requested.

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

Hardware-free acceptance rows retain their passing scope. The remaining
connected gate is closed by the explicit exception in the linked authorization,
with its uncollected physical/fault/trace evidence retained as follow-up.

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
| `HC-001` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `HC-002` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `HC-003` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `HC-004` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `HC-005` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `HC-006` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `HC-007` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `HC-008` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `HC-009` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `HC-010` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `HC-011` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `HC-012` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `HC-013` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `HC-014` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `HC-015` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `HC-016` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `HC-017` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |
| `HC-018` | pass | [Current profile/criterion evidence](../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md). Four current owner/profile reports and composed evidence in packet 18; passing scope is hardware-free unless packet 16 explicitly supplies a connected subset. |

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

## I3-T01 correction regression — 2026-10-09

[The bounded correction report](../iterations/iteration-003-review/i3-t01-result.md)
records the existing-contract scheduling/raster/layout changes and their exact
commits. The changed-path mapping is HC-009–011 and 014–018; unchanged
criteria retain their prior dispositions. All 74 aggregate checks and 60
owner/profile report-integrity checks pass on `7d618db7`, with focused boundary,
ordering, pixel, storage/reuse and target-build evidence in that report.
This is hardware-free regression evidence on the generated production graph.
It does not broaden earlier exceptions or prove connected timing, complete
stack/lifetime safety, runtime graph migration or iteration-3 closure.
The Specification remains `implemented` under its existing approval.
