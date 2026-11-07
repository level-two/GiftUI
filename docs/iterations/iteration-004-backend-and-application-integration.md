---
id: ITERATION-004
title: Backend and Application Integration
status: approved
revision: 8
approved_revision: 8
created: 2026-10-09
updated: 2026-11-07
features:
  - external-application-integration
  - giftui-mvp-architecture
  - signal-analyzer
  - observable-reference-state
approval: "Eugene approved the presented iteration sequencing and requested scope reorganization, dependent updates and commits on 2026-10-09. Evidence: docs/iterations/iteration-003-review/efficiency-sequencing-approval.md. Revision 2: Eugene explicitly requested the compiler assessment as a next-iteration task on 2026-10-11; provenance in docs/future-work/fw-036-swift-compiler-upgrade-assessment.md. Revision 3: Eugene explicitly requested adding FW-037 to the next iteration scope on 2026-10-13; provenance in its Disposition section. Revision 4: Eugene explicitly requested full RFC-015 scope in the next iteration while limiting P08 to necessary changes on 2026-10-13; provenance in docs/iterations/iteration-003-review/rfc-015-delivery-allocation.md. Revision 5: Eugene explicitly requested a framework/client failure-boundary review and future-work proposal in the next iteration on 2026-11-07; provenance in FW-041 Disposition. Revision 6: Eugene explicitly requested the InlineArray/Span future-work assessment in the next iteration on 2026-11-07; provenance in FW-042 Disposition. Revision 7: Eugene explicitly requested work on RFC-016 and its changes in the next iteration and a commit on 2026-11-07; exact request recorded in the revision history. Revision 8: Eugene explicitly requested reusable black-box host capture, stronger acceptance criteria and Signal Analyzer migration on 2026-11-07; exact request recorded in the revision history."
related_future_work:
  - FW-036
  - FW-037
  - FW-038
  - FW-041
  - FW-042
closure: null
---

# ITERATION-004: Backend and Application Integration

Approved destination for the delivery transfer described in the
[iteration-3 memory/efficiency plan](iteration-003-review/memory-efficiency-plan.md).
[Eugene's approval](iteration-003-review/efficiency-sequencing-approval.md)
establishes revision 1 and the corresponding iteration-3 revision-4 transfer.
Revision 2 adds the explicitly requested compiler assessment (I4-05); see the
revision history and [FW-036](../future-work/fw-036-swift-compiler-upgrade-assessment.md).
Revision 3 adds the requested Core-wide ownership assessment (I4-06), sourced
from [FW-037](../future-work/fw-037-core-wide-storage-ownership-generalization.md).
Revision 4 adds full RFC-015 delivery (I4-07), with only its necessary dependency
path retained in P08; see the [delivery allocation](iteration-003-review/rfc-015-delivery-allocation.md).
Revision 5 adds the requested framework/client failure-boundary review and
migration proposal (I4-08); see [FW-041](../future-work/fw-041-framework-client-failure-boundary.md).
Revision 6 adds the requested fixed-buffer InlineArray/Span assessment (I4-09),
sourced from [FW-042](../future-work/fw-042-inline-array-and-span-storage-assessment.md).
Revision 7 adds RFC-016 authoring API review and gated migration (I4-10), under
accepted PROPOSAL-005; scheduling does not approve the draft API.
Revision 8 strengthens I4-03 and I4-AC-001–005: supported reusable hosts must
encapsulate framework assembly, and both counter and Signal Analyzer must adopt
them. RFC-013 retains the unresolved API and ownership design.
This iteration is approved, not active; production extraction waits for its
entry gates. Architecture and Specification approvals remain separate.

## Goal

Make the measured, resource-safe runtime reusable by an external application
and display-adapter author through focused packages, backend/platform
components and supported host/build entry points. Preserve the memory, timing,
semantic and runtime-derivation results established in iteration 3.

## Included Scope

| Item | Source / feature | Intended outcome | Lifecycle routing |
| --- | --- | --- | --- |
| I4-01 — Focused packages | Approved transfer of I3-01; FW-016 | External consumers select framework/runtime, rendering and required platform/display components without analyzer internals or repository-wide source lists | Review ADR-008/SPEC-002 and current cost/ownership handoff; approve affected topology/access decisions before extraction |
| I4-02 — Reusable backend and platform components | Approved transfer of I3-02; EXP-002 / PROPOSAL-007 | Reusable raster/session construction, validation and narrow adapter contracts; one external recording adapter uses the same supported assembly path | RFC-013, accepted downstream ADRs and approved SPEC-009/012/014 amendments as required; no mandatory new core module |
| I4-03 — Simpler external application integration | Approved transfer of I3-03; FW-030 / PROPOSAL-007 | Reusable hosts encapsulate framework assembly/lifecycle for the external counter and Signal Analyzer; clients supply application behavior/services/resources/configuration; migrate bespoke analyzer wiring; portable presentation imports GiftUI alone | Public assembly/lifetime/build contracts and ready Spec plans before implementation |
| I4-04 — Compatibility and author documentation | Approved transfer/renewal of IT-AC-004/005 | Preserve runtime derivation and iteration-3 efficiency; reproducible quick start, adapter and migration guides | Final owner conformance, measured paired artifacts and separate criterion dispositions |
| I4-05 — Swift compiler compatibility assessment | Maintainer request 2026-10-11; FW-036; RFC-014 P07 compiler failure | Evaluate a newer compiler and recommend upgrade or retain with reproducible compatibility, cost and risk evidence | Assessment only; approve compiler contract/pin changes separately before adoption |
| I4-06 — Core-wide storage ownership assessment | Maintainer request 2026-10-13; FW-037; focused RFC-015 findings | Evaluate physical ownership, transaction ownership, scoped access and ownership/responsibility transfer using the [FW-037 assessment model](../future-work/fw-037-core-wide-storage-ownership-generalization.md#ownership-and-transfer-model-to-assess) across frontend/backend/platform boundaries, including a PC simulator; recommend which boundaries to generalize and which to keep local | Exploration/evidence and disposition; reuse EXP-002 where appropriate, then normal Proposal/RFC/ADR/Spec gates before adopting a Core-wide contract |
| I4-07 — Complete RFC-015 scoped-storage delivery | Maintainer request 2026-10-13; approved RFC-015; accepted ADR-039 and approved/applied SPEC-011/013/015 packet | Complete the full selected RFC scope, reusing the minimum P08 implementation/evidence and delivering the remaining contracts, implementation, compatibility, conformance and documentation | Follow the [delivery allocation](iteration-003-review/rfc-015-delivery-allocation.md); accept ADR and approve Spec amendments before implementation; separate bounded execution authority; no Core-wide generalization |
| I4-08 — Framework/client failure ownership | Maintainer request 2026-11-07; [FW-041](../future-work/fw-041-framework-client-failure-boundary.md), findings F-01–06 | Review the mixed failure boundary and propose framework-owned containment, client-owned business failures and a narrow host lifecycle seam; deliver an explicit contract/migration/validation plan | Review and proposal only; route through RFC-013 under PROPOSAL-007 where covered, or obtain investment approval for expanded scope; accepted ADRs and approved Spec amendments before implementation |
| I4-09 — Fixed-buffer InlineArray and Span assessment | Maintainer request 2026-11-07; [FW-042](../future-work/fw-042-inline-array-and-span-storage-assessment.md) | Inventory homogeneous tuple buffers; assess InlineArray ownership and Span/MutableSpan borrowing with exact layout, allocation, copying, lifetime and stable-address evidence; recommend migrate/retain/defer per candidate | Assessment and disposition; coordinate I4-05/06/07, use an Exploration/bounded Spike if needed, and route adoption through applicable maintenance or contract gates |

| I4-10 — Observable model authoring API | Maintainer request 2026-11-07; [RFC-016](../rfcs/rfc-016-observable-model-authoring-api.md); PROPOSAL-005 / observable-reference-state | Resolve the draft API, remove handwritten observation plumbing through approved generation, and migrate counter then Signal Analyzer while preserving Dynamic/Static/Embedded semantics | Resolve Q1–Q5; human RFC approval, any required ADR acceptance and affected Spec approval; ready implementation plan before M2–M6 delivery; coordinate I4-03/04/07 and actual analyzer dispatcher residuals |

Use the same bounded counter/status application, changing text, typed actions,
disabled Button and small Canvas variant as iteration 3. It must now be a real
external package consumer without privileged shared-package access. First build
supported compositions, then substitute only the recording display through the
same backend/host assembly. Migrate Signal Analyzer to the same supported reusable host contracts as the
nontrivial adoption and compatibility application. Its capture/domain services
remain application-owned. Runtime graph derivation remains mandatory for both
applications; RFC-014 P09/P12 alone does not establish reusable-host adoption.

## Delivery Order and Gates

For I4-10, follow RFC-016 M0–M6: inventory the adopted baseline, resolve and
review Q1–Q5, obtain architecture/contract approvals, derive a ready plan, migrate
the counter and analyzer, then validate all four profiles and author documentation.
Coordinate source/build integration with I4-03 and owned dispatcher compatibility
with I4-07; reuse qualified evidence without closing their residuals by inference.
Review may proceed before implementation gates; production migration retains this
iteration's entry gates. No P08 execution allowance or resource budget is reset.

Assess I4-09 after identifying the compiler baseline under I4-05 and alongside
I4-06/I4-07 ownership work. Record candidate-specific evidence and routing before
any replacement; retaining a tuple is valid where semantics, ABI, address stability
or target evidence require it. This assessment does not activate production migration.

1. Assess the compiler baseline under I4-05 early enough to inform extraction.
   Establish the exact P07 failure/reproducer result, matching ARMv6 SDK availability,
   Embedded compatibility and migration cost; retaining 6.3.2 is a valid disposition.
   An upgrade requires separate approval and fresh affected evidence.
2. Accept the iteration-3 handoff and refresh exact source/toolchain/resource
   identities. Reconcile RFC-013 with the approved ownership and storage choices.
3. Assess I4-06 alongside transitive access, package alternatives and backend/host
   construction. Compare the evidenced P08 boundary (or its unresolved limits)
   with a concrete second consumer and a PC simulator composition; record missing
   evidence explicitly. Feed the disposition into the package/access review.
   Obtain architecture and affected Specification approvals.
   For I4-07, reconcile the P08 residual matrix against every RFC-015 B1–B4
   obligation and all nine adopted ownership criteria. Complete remaining work
   through the approved owner plans before dependent integration; reuse qualified
   P08 evidence and refresh only changed paths. I4-06 assessment is not a prerequisite
   to realizing RFC-015's already selected finite ownership contract.
4. Derive ready implementation plans; extract one coherent vertical consumer
   path and test it before migrating further supported platform compositions.
5. Migrate Signal Analyzer to the qualified reusable host path; inventory each
   bespoke assembly responsibility, retain justified application adapters, and
   retire replaced production wiring after equivalent validation. Run the external
   consumer/adapter matrix and compare final analyzer memory,
   timing and loaded behavior with the iteration-3 baseline.
6. Publish documentation and criterion dispositions; request human closure.

I4-07 explicitly includes the accepted P08 residual for the two unchanged legacy
Dynamic/StaticSignalAnalyzerActionDispatcher factories: reconcile the actual
SignalAnalyzerViewModel/reference contract, root adapters, scoped target aliases/
initializer and owned ActionModelTargetAccess integration; produce actual-factory
owned returned/copyable positive and scoped-Records rejection evidence on all
applicable governed configurations. This is mandatory unresolved next-iteration
work, coordinated with the existing separate P09 analyzer integration package and
P10–P12 evidence; it is not optional cleanup or passing compatibility evidence.
IN-SO-003 and full RFC conformance remain unmet. The [accepted disposition](iteration-003-review/rfc-015-delivery-allocation.md#accepted-pre-existing-integration-gap-disposition--2026-10-13)
also assigns analogous pre-existing gaps outside the selected counter safety/
dependency path to exact mandatory next-iteration residuals, preserving required
counter fixes, new regressions/shared breaks and architectural gates in scope.

## Contract Cleanup after ITERATION-003

On 2026-10-31 Eugene agreed to keep the broader cleanup after ITERATION-003 and
instructed: “capture these concrete cleanup findings in FW-037/FW-038 and the
Iteration 04 plan, with clear scope and success criteria, keeping Iteration 03
focused on delivery.” This is a concrete allocation within existing I4-06
assessment and I4-01–04 consolidation, with I4-07 compatibility where affected.
Revision 4 and I4-AC-001–008 remain the governing delivery commitment; this does
not add a new cleanup milestone or select a replacement API/architecture.

**Entry:** begin this cleanup after the explicit iteration-3 delivery/closure
decision and the applicable iteration-4 entry gates. P08 PASS alone is not its
start trigger. Read-only capture here does not activate iteration 4. Keep P08–P12
focused on analyzer/counter delivery, measured performance and adoption. A
specific contract simplification necessary to resolve a current delivery blocker
still belongs to that existing task and its normal authority; it does not start
the broader cleanup.

| Finding / source | Focused scope and candidate outcome | Existing allocation |
| --- | --- | --- |
| CC-01 / [FW-037](../future-work/fw-037-core-wide-storage-ownership-generalization.md#concrete-contract-cleanup-findings--2026-10-31) | Reconcile overlapping limits/audit/profile-validation inputs; assess one authoritative checked representation after raw validation, with fewer independently supplied facts and consistency joins | I4-06 boundary assessment; I4-03 assembly; I4-AC-003/004/007 |
| CC-02 / FW-037 | Reduce semantic traversal's adapter-visible bookkeeping and forwarding; keep shared control/failure state with its owner and retain concrete storage/lifetime enforcement | I4-06 assessment; applicable I4-01/03 owner plans; I4-AC-004/007 |
| CC-03 / [FW-038](../future-work/fw-038-scoped-contract-validation-cost.md#concrete-accounting-cleanup-finding--2026-10-31) | Simplify Counter physical accounting's request/resume/callback machinery through owner-supplied concrete facts and bounded accounting; preserve complete costs and independent ordered-report oracles | I4-01–04 consolidation; I4-07 only for affected selected ownership duties; I4-AC-004/005/008 |
| CC-04 / FW-037 | Confine incomplete resource descriptors to genuine input boundaries; assess complete owner-specific internal values instead of repeatedly propagating optional facts | I4-06 assessment; I4-03 assembly; I4-AC-003/004/007 |

### Cleanup assessment and adoption success criteria

1. **Reproducible baseline:** identify adopted iteration-3 source/compiler/profile
   and artifacts. Recount the selected interfaces: independently supplied facts,
   duplicated limits/audits, mutable protocol requirements, forwarding methods,
   accounting phases/callback layers and relevant compilation commands. The
   captured 17-method/six-property traversal count is an observation, not a fixed
   future target or an instruction to merge all operations.
2. **Focused disposition:** give each CC-01–04 finding an adopt/retain/defer result,
   affected owner/contracts and reason. Assess the finite Counter first; verify
   the selected boundary against Signal Analyzer and I4-06's existing second
   consumer/PC-simulator composition requirements. Name evidence gaps. This
   satisfies the assessment portion without promising an unproved redesign.
3. **Demonstrated structural reduction for adoption:** a selected cleanup must
   reduce the counted obligations it targets, such as separately supplied audit
   copies or adapter mutation/forwarding requirements. No duplicate state machine,
   replacement universal-owner abstraction, hidden mutable authority or equivalent
   obligations relocated into extra wrappers. Explain any necessary trade-off.
4. **Equivalent guarantees:** preserve invalid-input/first-error order, all
   semantic/action/pixel results, complete ordered region reports, overflow and
   refusal, ownership/escape/exclusivity, partial initialization and backing-last
   cleanup. Reconcile every affected required test to retained or replacement
   coverage with an independent oracle; preserve applicable compiler negatives.
5. **Measured costs:** compare before/after backing, temporary/copy costs,
   heap/stack/RAM/flash and code size where affected, plus focused/full validation
   time and repeated compiler invocations under identified conditions. Meet the
   accepted per-application resource/performance limits; report regressions and
   unknowns explicitly. No percentage speedup or total reduction is assumed.
6. **Contract and delivery integration:** route cross-module/API/ownership changes
   through RFC-013 or the affected accepted ADR/Specification amendment before
   implementation. Realize selected changes in the existing owner plans and
   supported consumer build paths, reuse applicable evidence, refresh invalidated
   dependencies and record final results under I4-AC-003/004/005/007/008 as relevant.
   Do not create a second runner or proof controller solely for this cleanup.

The scope is the four named boundaries. Package proliferation, a whole-Core
rewrite, unrelated style work and weaker acceptance coverage are excluded.
FW-037/FW-038 stay `captured`; scheduling an assessment does not approve their
candidate realizations or promote their lifecycle status.

## Framework/Client Failure Boundary Review

I4-08 reviews FW-041 F-01–06 before dependent I4-01/03 public package and host
assembly decisions are finalized, alongside I4-06's ownership assessment.
Inventory and design preparation may proceed under the existing entry gates;
this addition does not activate iteration 4 or move iteration-3 blockers.

The review proposes a separation between framework containment, application
failure state and host product lifecycle choices. It must distinguish ordinary
client errors from contract violations/unsafe partial mutation, and assess the
shared failure carrier without assuming generic transport itself is a leak.
Produce a mapping of current contracts to preserved or proposed behavior,
including failure during admission, partial mutation, publication, backend
handoff and teardown. Specify migration order and the owner of each retained
outcome/effect. No replacement API or weaker failure semantics is approved here.

The validation plan covers an external counter and Signal Analyzer on all four
configurations: client errors displayed without poisoning healthy framework
state; framework faults contained without client switches over internal error
catalogues; contract violations safely rejected; no partial publication,
duplicate action, lost accepted fact or diagnostic-dependent behavior; bounded
Static storage and preserved resource budgets. Identify required compile-time
boundary checks, fault injection, target builds and later measured evidence.
This iteration item commits to review/proposal and a testable migration plan;
implementation requires its separate lifecycle gates.

## Exclusions

- A new rendering algorithm solely to justify a new backend module, universal
  backend base, new physical backend, independent repository/release system,
  arbitrary Swift lowering or generated expanded view-graph fallback.
- Unreviewed public API exposure, changed ownership/transfer semantics or
  increased budgets hidden inside mechanical package moves.
- Core-wide implementation, a universal owner protocol or simulator delivery
  solely from I4-06 assessment; any adoption needs its own approved contracts.
- Automatic deployment, remote service changes or connected-board flashing.
- Treating old MVP exceptions as approval of extraction regressions.

## Success Criteria and Validation

IDs below map the transferred obligations without erasing their iteration-3
history. The transfer is approved under iteration-3 revision 4.

| ID | Observable result | Required configurations | Evidence / governing contract |
| --- | --- | --- | --- |
| I4-AC-001 (from IT-AC-001) | Real external counter and Signal Analyzer consume supported reusable hosts; portable presentation imports GiftUI and unused concrete platforms are omitted | All four configurations | External counter clean-package builds plus actual analyzer entry-point/dependency scans; no analyzer internals, privileged access or framework source lists in the external consumer; ADR-008 and affected SPEC-002/013/014/015 |
| I4-AC-002 (from IT-AC-002) | External recording adapter reuses existing raster/session/validation owners with no copied state machine or second bootstrap | Native Dynamic/Static execution; actual ARMv6/Embedded supported and recording compile/link | Exact fill/glyph/stroke, clipping/order, borrow/transfer, refusal/health/retirement fixtures; SPEC-009/012/014 |
| I4-AC-003 (from IT-AC-003) | Each target has fewer manual setup actions and user-maintained infrastructure files than the same consumer baseline; reusable hosts own framework assembly and lifecycle orchestration for both applications; clients supply views/state/services/resources/configuration without internal owner wiring, copied framework state machines or handwritten framework offsets | All four configurations | Reproducible before/after inventory including generation and prerequisites; classify every SignalAnalyzerTargetHost/firmware assembly responsibility as reusable-host-owned, justified application adapter/configuration or retired; source/build scans prove removal of replaced bespoke production wiring; supported/recording configuration, negative activation and teardown cases; SPEC-003/004/005/013/015 |
| I4-AC-004 (renewed IT-AC-004/006) | Both applications use reusable hosts and preserve runtime-derived graphs, profile semantics, state/actions/pixels/failures and iteration-3 resource/performance results; analyzer regression-only coverage or runtime traversal migration alone is insufficient | All four configurations, actual supported targets for timing claims | Final exact artifact/flag comparisons, approved budgets and governing Spec conformance; repeat changed-path connected tests when required |
| I4-AC-005 (from IT-AC-005) | Application and adapter authors can reproduce and customize supported integration; every criterion has an evidenced disposition | All supported build routes | Quick start using the supported host, custom-adapter guide through the same host path, explicit client/host responsibility and resource/capability/diagnostic inventory, Signal Analyzer migration/removal map, package/API compatibility notes; exact evidence identities and human closure |
| I4-AC-006 | Compiler assessment records an evidenced upgrade-or-retain recommendation, target-tooling availability, estimated effort and required contract/evidence refresh | macOS Dynamic/Static, actual ARMv6 and Embedded toolchain feasibility | P07 reproducer plus lifetime-negative controls; SwiftSyntax/macros, paired SDK, ABI/VFP, zero-heap and size/stack validation plan; no adoption implied |
| I4-AC-007 | Ownership assessment records a boundary/owner/dependency map covering borrowing, mutation, ownership versus access-capability transfer, acceptance and cleanup on success/refusal/failure; concrete reuse gaps, alternatives and an adopt-later/retain-local/defer recommendation with lifecycle routing | Static/Embedded and Dynamic ownership; external frontend/backend consumer and PC simulator composition | [FW-037 assessment model](../future-work/fw-037-core-wide-storage-ownership-generalization.md#ownership-and-transfer-model-to-assess) / EXP-002 evidence and disposition; distinguish portable semantics from Swift enforcement and target realization, account for resource/lifetime costs, and identify missing P08 or second-consumer evidence; no Core or simulator implementation implied |
| I4-AC-008 | Full RFC-015 scope has accepted decisions, approved/applied Spec amendments, implemented residual work and complete conformance dispositions; P08 results are reused with no unnecessary migration | All four governed configurations; existing target evidence requirements preserved | B1–B4 and adopted IN-SO-001–003 / RP-SO-001–003 / HC-SO-001–003 mapped to current-source evidence, caller/physical inventories and owner conformance reports; exact P08 residual handoff, independent review and human lifecycle transitions; failure remains unmet unless explicitly excepted |
| I4-AC-009 | F-01–06 each have an owner/disposition, proposed client/framework/host boundary, affected ADR/Spec map and ordered migration/validation plan; unresolved decisions and gates are explicit | External counter and Signal Analyzer; macOS Dynamic/Static, ARMv6 Dynamic, nRF52840 Static addressed by the plan | FW-041 review evidence; RFC-013 proposal or explicit upstream routing; fault scenarios and resource/compatibility checks above; no implementation or target pass inferred from the review |
| I4-AC-010 | Fixed-buffer assessment inventories tuple candidates and records migrate/retain/defer recommendations with ownership, borrowing and lifetime rationale; distinguishes semantic tuples, ABI storage and pinned/asynchronous buffers | macOS Dynamic/Static, Raspberry Pi 1 ARMv6 and nRF52840 Embedded feasibility on identified toolchains | [FW-042](../future-work/fw-042-inline-array-and-span-storage-assessment.md): layout/stride/alignment, backing and temporary/copy costs, zero-heap/stack/RAM/flash implications, lifetime/exclusivity negative controls and positive twins, stable-address constraints; reproducible evidence or explicit gaps, affected contracts and adoption gates; no replacement or compiler upgrade implied |
| I4-AC-011 | RFC-016 Q1–Q5 have reviewed resolutions; required decisions and Spec amendments are explicitly approved; counter and analyzer use the supported authoring surface without handwritten observation SPI, with complete migration/conformance dispositions | macOS Dynamic/Static, Raspberry Pi 1 ARMv6 Dynamic and nRF52840 Embedded Static | OA-01–07 and M0–M6 evidence: generated-source/diagnostic fixtures, service/fact and actual owned-dispatcher integration, ownership/refusal/reporting equivalence, resource comparisons and migration guide; unresolved approval or unimplemented migration remains unmet unless explicitly excepted |

The matrix is macOS Dynamic, macOS Static, Raspberry Pi 1
`armv6-unknown-linux-gnueabihf` Dynamic with framebuffer/PiScreen, and
`nrf52840dk/nrf52840` Embedded Static with the existing TFT composition.
Native rehearsals and target links do not establish connected performance.
Use repository toolchains and target skills, preserve zero-heap Static and VFP
ABI checks, and obtain explicit authorization for required connected operations.

## Dependencies and Open Questions

- Iteration-3 revision 4 and this revision 7 are approved. Their feature and
  implementation gates remain separate.
- Production migration depends on iteration-3 safe memory/stack, sustained
  workload, runtime-derivation and compatibility evidence, or a specifically
  accepted exception defining the downstream risk. Inventory/design preparation
  may proceed while those gates are open.
- PROPOSAL-007 remains accepted and RFC-013 draft. Reuse valid studies and
  failures; do not reset SPIKE-067's exhausted allowance or adopt its code by
  moving files. New architecture/contracts remain separate human gates.
- I4-06 may inventory boundaries before P08 closes. RFC-015 is approved, but
  ADR-039 and exact Spec amendments are accepted/approved/applied under the
  [2026-10-13 acceptance](iteration-003-review/rfc-015-contract-acceptance.md). I4-07 owns full RFC delivery;
  P08 retains every obligation required by its adopted paths under the delivery
  allocation. Neither item moves a P08 safety or fit blocker into optional work.
  For I4-06 assessment, missing P08 or second-consumer evidence permits an explicit defer disposition;
  no compiler/repair allowance is reset by this scope addition.
- Decide whether the measured owner boundaries require any new core module;
  no module name or inheritance hierarchy is selected by this scope.
- Identify minimal public transitive access and maintainable supported build
  routes after efficiency decisions stabilize the lifetime/storage requirements.

## Revision and Approval History

| Revision | Date | Change / reason | Maintainer approval |
| --- | --- | --- | --- |
| 1 | 2026-10-09 | Transfer backend/package/external-host delivery after iteration-3 memory and efficiency work | [Explicit sequencing approval](iteration-003-review/efficiency-sequencing-approval.md) |
| 2 | 2026-10-11 | Add I4-05 / I4-AC-006 compiler assessment; upgrade adoption remains separately gated | Eugene: “Please add this as a task to the next iteration.” In context, “this” is evaluation of the cost and impact of bumping Swift; [request record](../future-work/fw-036-swift-compiler-upgrade-assessment.md#disposition) |
| 3 | 2026-10-13 | Add I4-06 / I4-AC-007 Core-wide storage ownership assessment, including frontend/backend/platform and PC simulator boundaries | Eugene: “Add the produced future work item to the next iteration scope.” The item is FW-037; [request record](../future-work/fw-037-core-wide-storage-ownership-generalization.md#disposition) |
| 4 | 2026-10-13 | Add I4-07 / I4-AC-008 full RFC-015 delivery; retain only necessary changes and their complete proof in P08 | Eugene: “Please include full RFC 015 scope work into the next iteration, while preserving P08 staying focused on the only necessary changes”; [allocation and provenance](iteration-003-review/rfc-015-delivery-allocation.md) |
| 5 | 2026-11-07 | Add I4-08 / I4-AC-009 framework/client failure-boundary review, proposal and migration/validation plan; architecture and implementation remain gated | Eugene: “Put it into the next iteration scope and commit”; [full request and scope](../future-work/fw-041-framework-client-failure-boundary.md#disposition) |
| 6 | 2026-11-07 | Add I4-09 / I4-AC-010 fixed-buffer InlineArray/Span assessment; implementation and compiler adoption remain separately gated | Eugene: “please formalize it in the future work item and add to the next iteration”, followed by “and commit”; [request record](../future-work/fw-042-inline-array-and-span-storage-assessment.md#disposition) |
| 7 | 2026-11-07 | Add I4-10 / I4-AC-011 RFC-016 review and gated authoring API migration; preserve accepted profile architecture and existing entry/implementation gates | Eugene: “please add work on this rfc and changes into the next iteration and commit”; “this rfc” refers to the drafted RFC-016 and its migration plan |
| 8 | 2026-11-07 | Strengthen I4-03 / I4-AC-001–005 with encapsulated reusable hosts and mandatory Signal Analyzer adoption; retain draft RFC-013 and all architecture/implementation gates | Eugene: “Please capture this explicitly in RFC-013 and strengthen the iteration-004 acceptance criteria, including migrating Signal Analyzer to the reusable host. Update dependent documents and commit.” |

On 2026-10-13, Eugene authorized making the ownership-and-transfer assessment
model explicit in FW-037 and referencing it from I4-06 / I4-AC-007. This clarifies
revision 3's existing assessment; it adds no implementation commitment or
ownership contract. See [FW-037 disposition](../future-work/fw-037-core-wide-storage-ownership-generalization.md#disposition).

The 2026-10-31 [contract cleanup allocation](#contract-cleanup-after-iteration-003)
records the maintainer's explicit scheduling instruction within existing revision-4
outcomes. It refines assessment/adoption evidence and preserves criterion IDs;
it does not advance the iteration status or authorize a candidate contract.

## Closure and Follow-up

At closure, disposition I4-AC-001–011 as met, unmet or explicitly excepted with
current evidence. Preserve remaining work and triggers, and obtain a human
closure decision. Do not infer delivery from transferred scope or passed studies.

The [FW-038 consolidation candidate](../future-work/fw-038-scoped-contract-validation-cost.md)
records Eugene's 2026-10-15 request to assess removal of parallel P08 build/test
infrastructure while preserving meaningful coverage. Revisit during RFC-013
package/assembly design for I4-01–04 and coordinate with I4-07. This is a linked
follow-up, not a new approved criterion or amendment to revision 4; current P08
proof obligations remain in force.

## Deferred and Follow-up Work

[FW-042](../future-work/fw-042-inline-array-and-span-storage-assessment.md) remains
`captured`; I4-09 commits to assessment, not wholesale tuple replacement. Its
trigger is iteration-4 storage planning after compiler identification. Route
remaining uncertainty to an Exploration and adoption through normal gates.
Current iteration-3 obligations and prior I4-AC-001–009 remain unchanged.

## References

- [RFC-016: Observable Model Authoring API](../rfcs/rfc-016-observable-model-authoring-api.md)

- [ITERATION-003 and approved baseline](iteration-003-dev-ux-improvement.md)
- [Approved sequencing and activity plan](iteration-003-review/memory-efficiency-plan.md)
- [PROPOSAL-007](../proposals/proposal-007-external-application-integration.md)
- [RFC-013](../rfcs/rfc-013-external-application-and-backend-integration.md)
- [EXP-002](../explorations/exp-002-backend-and-application-integration-shapes.md)
- [FW-016](../future-work/fw-016-post-mvp-package-distribution-topology.md),
  [FW-030](../future-work/fw-030-application-integration-experience.md)

## Failure Boundary Follow-up

- [FW-041](../future-work/fw-041-framework-client-failure-boundary.md) records the
  mixed failure ownership findings and candidate separation. I4-08 schedules its
  review; capture and scope approval do not select its architecture.
