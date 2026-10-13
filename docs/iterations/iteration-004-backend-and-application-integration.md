---
id: ITERATION-004
title: Backend and Application Integration
status: approved
revision: 4
approved_revision: 4
created: 2026-10-09
updated: 2026-10-13
features:
  - external-application-integration
  - giftui-mvp-architecture
  - signal-analyzer
approval: "Eugene approved the presented iteration sequencing and requested scope reorganization, dependent updates and commits on 2026-10-09. Evidence: docs/iterations/iteration-003-review/efficiency-sequencing-approval.md. Revision 2: Eugene explicitly requested the compiler assessment as a next-iteration task on 2026-10-11; provenance in docs/future-work/fw-036-swift-compiler-upgrade-assessment.md. Revision 3: Eugene explicitly requested adding FW-037 to the next iteration scope on 2026-10-13; provenance in its Disposition section. Revision 4: Eugene explicitly requested full RFC-015 scope in the next iteration while limiting P08 to necessary changes on 2026-10-13; provenance in docs/iterations/iteration-003-review/rfc-015-delivery-allocation.md."
related_future_work:
  - FW-036
  - FW-037
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
| I4-03 — Simpler external application integration | Approved transfer of I3-03; FW-030 / PROPOSAL-007 | Complete supported host/build/setup path for the finite counter; portable presentation imports GiftUI alone; no copied analyzer infrastructure or handwritten framework offsets | Public assembly/lifetime/build contracts and ready Spec plans before implementation |
| I4-04 — Compatibility and author documentation | Approved transfer/renewal of IT-AC-004/005 | Preserve runtime derivation and iteration-3 efficiency; reproducible quick start, adapter and migration guides | Final owner conformance, measured paired artifacts and separate criterion dispositions |
| I4-05 — Swift compiler compatibility assessment | Maintainer request 2026-10-11; FW-036; RFC-014 P07 compiler failure | Evaluate a newer compiler and recommend upgrade or retain with reproducible compatibility, cost and risk evidence | Assessment only; approve compiler contract/pin changes separately before adoption |
| I4-06 — Core-wide storage ownership assessment | Maintainer request 2026-10-13; FW-037; focused RFC-015 findings | Evaluate physical ownership, transaction ownership, scoped access and ownership/responsibility transfer using the [FW-037 assessment model](../future-work/fw-037-core-wide-storage-ownership-generalization.md#ownership-and-transfer-model-to-assess) across frontend/backend/platform boundaries, including a PC simulator; recommend which boundaries to generalize and which to keep local | Exploration/evidence and disposition; reuse EXP-002 where appropriate, then normal Proposal/RFC/ADR/Spec gates before adopting a Core-wide contract |
| I4-07 — Complete RFC-015 scoped-storage delivery | Maintainer request 2026-10-13; approved RFC-015; accepted ADR-039 and approved/applied SPEC-011/013/015 packet | Complete the full selected RFC scope, reusing the minimum P08 implementation/evidence and delivering the remaining contracts, implementation, compatibility, conformance and documentation | Follow the [delivery allocation](iteration-003-review/rfc-015-delivery-allocation.md); accept ADR and approve Spec amendments before implementation; separate bounded execution authority; no Core-wide generalization |

Use the same bounded counter/status application, changing text, typed actions,
disabled Button and small Canvas variant as iteration 3. It must now be a real
external package consumer without privileged shared-package access. First build
supported compositions, then substitute only the recording display through the
same backend/host assembly. Keep Signal Analyzer as the nontrivial compatibility
application. Runtime graph derivation remains mandatory for both applications.

## Delivery Order and Gates

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
5. Run the external consumer/adapter matrix and compare final analyzer memory,
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
| I4-AC-001 (from IT-AC-001) | Real external consumer selects focused packages, imports GiftUI for presentation and omits unused concrete platforms | All four configurations | Clean dependency/product builds; no analyzer internals, privileged access or framework source lists; ADR-008 and affected SPEC-002/013/014/015 |
| I4-AC-002 (from IT-AC-002) | External recording adapter reuses existing raster/session/validation owners with no copied state machine or second bootstrap | Native Dynamic/Static execution; actual ARMv6/Embedded supported and recording compile/link | Exact fill/glyph/stroke, clipping/order, borrow/transfer, refusal/health/retirement fixtures; SPEC-009/012/014 |
| I4-AC-003 (from IT-AC-003) | Each target has fewer manual setup actions and user-maintained infrastructure files than the same consumer baseline; no copied analyzer infrastructure or handwritten framework offsets | All four configurations | Reproducible before/after inventory including generation and prerequisites; supported/recording configuration and negative-activation cases; SPEC-003/004/005/013/015 |
| I4-AC-004 (renewed IT-AC-004/006) | Both applications preserve runtime-derived graphs, profile semantics, state/actions/pixels/failures and iteration-3 resource/performance results | All four configurations, actual supported targets for timing claims | Final exact artifact/flag comparisons, approved budgets and governing Spec conformance; repeat changed-path connected tests when required |
| I4-AC-005 (from IT-AC-005) | Application and adapter authors can reproduce and customize supported integration; every criterion has an evidenced disposition | All supported build routes | Quick start, custom-adapter guide, owner-input inventory, package/API compatibility and migration notes; exact evidence identities and human closure |
| I4-AC-006 | Compiler assessment records an evidenced upgrade-or-retain recommendation, target-tooling availability, estimated effort and required contract/evidence refresh | macOS Dynamic/Static, actual ARMv6 and Embedded toolchain feasibility | P07 reproducer plus lifetime-negative controls; SwiftSyntax/macros, paired SDK, ABI/VFP, zero-heap and size/stack validation plan; no adoption implied |
| I4-AC-007 | Ownership assessment records a boundary/owner/dependency map covering borrowing, mutation, ownership versus access-capability transfer, acceptance and cleanup on success/refusal/failure; concrete reuse gaps, alternatives and an adopt-later/retain-local/defer recommendation with lifecycle routing | Static/Embedded and Dynamic ownership; external frontend/backend consumer and PC simulator composition | [FW-037 assessment model](../future-work/fw-037-core-wide-storage-ownership-generalization.md#ownership-and-transfer-model-to-assess) / EXP-002 evidence and disposition; distinguish portable semantics from Swift enforcement and target realization, account for resource/lifetime costs, and identify missing P08 or second-consumer evidence; no Core or simulator implementation implied |
| I4-AC-008 | Full RFC-015 scope has accepted decisions, approved/applied Spec amendments, implemented residual work and complete conformance dispositions; P08 results are reused with no unnecessary migration | All four governed configurations; existing target evidence requirements preserved | B1–B4 and adopted IN-SO-001–003 / RP-SO-001–003 / HC-SO-001–003 mapped to current-source evidence, caller/physical inventories and owner conformance reports; exact P08 residual handoff, independent review and human lifecycle transitions; failure remains unmet unless explicitly excepted |

The matrix is macOS Dynamic, macOS Static, Raspberry Pi 1
`armv6-unknown-linux-gnueabihf` Dynamic with framebuffer/PiScreen, and
`nrf52840dk/nrf52840` Embedded Static with the existing TFT composition.
Native rehearsals and target links do not establish connected performance.
Use repository toolchains and target skills, preserve zero-heap Static and VFP
ABI checks, and obtain explicit authorization for required connected operations.

## Dependencies and Open Questions

- Iteration-3 revision 4 and this revision 4 are approved. Their feature and
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

On 2026-10-13, Eugene authorized making the ownership-and-transfer assessment
model explicit in FW-037 and referencing it from I4-06 / I4-AC-007. This clarifies
revision 3's existing assessment; it adds no implementation commitment or
ownership contract. See [FW-037 disposition](../future-work/fw-037-core-wide-storage-ownership-generalization.md#disposition).

## Closure and Follow-up

At closure, disposition I4-AC-001–008 as met, unmet or explicitly excepted with
current evidence. Preserve remaining work and triggers, and obtain a human
closure decision. Do not infer delivery from transferred scope or passed studies.

## References

- [ITERATION-003 and approved baseline](iteration-003-dev-ux-improvement.md)
- [Approved sequencing and activity plan](iteration-003-review/memory-efficiency-plan.md)
- [PROPOSAL-007](../proposals/proposal-007-external-application-integration.md)
- [RFC-013](../rfcs/rfc-013-external-application-and-backend-integration.md)
- [EXP-002](../explorations/exp-002-backend-and-application-integration-shapes.md)
- [FW-016](../future-work/fw-016-post-mvp-package-distribution-topology.md),
  [FW-030](../future-work/fw-030-application-integration-experience.md)
