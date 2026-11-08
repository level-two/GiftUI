---
id: ITERATION-004
title: Backend and Application Integration
status: approved
revision: 12
approved_revision: 12
created: 2026-10-09
updated: 2026-11-08
features:
  - external-application-integration
  - giftui-mvp-architecture
  - signal-analyzer
  - observable-reference-state
approval: "Revision 12: Eugene approved integration-focused narrowing and transfer of I4-09/I4-10 to ITERATION-005 on 2026-11-08; exact instruction in Revision and Approval History. Revision 11: Eugene approved iteration-3 closeout with named P08 S1–S3 gaps unmet and affected iteration-4 reuse blocked on 2026-11-08; docs/iterations/iteration-003-review/p08-unmet-safety-closeout-disposition.md. Revision 10: Eugene approved freezing P08 without PASS and transferring composition-specific certification on 2026-11-08; docs/iterations/iteration-003-review/p08-freeze-and-certification-transfer.md. Revision 9: Eugene approved the analyzer-specific P09–P12 transfer on 2026-11-08; exact instruction and gates: docs/iterations/iteration-003-review/analyzer-delivery-transfer.md. Eugene approved the presented iteration sequencing and requested scope reorganization, dependent updates and commits on 2026-10-09. Evidence: docs/iterations/iteration-003-review/efficiency-sequencing-approval.md. Revision 2: Eugene explicitly requested the compiler assessment as a next-iteration task on 2026-10-11; provenance in docs/future-work/fw-036-swift-compiler-upgrade-assessment.md. Revision 3: Eugene explicitly requested adding FW-037 to the next iteration scope on 2026-10-13; provenance in its Disposition section. Revision 4: Eugene explicitly requested full RFC-015 scope in the next iteration while limiting P08 to necessary changes on 2026-10-13; provenance in docs/iterations/iteration-003-review/rfc-015-delivery-allocation.md. Revision 5: Eugene explicitly requested a framework/client failure-boundary review and future-work proposal in the next iteration on 2026-11-07; provenance in FW-041 Disposition. Revision 6: Eugene explicitly requested the InlineArray/Span future-work assessment in the next iteration on 2026-11-07; provenance in FW-042 Disposition. Revision 7: Eugene explicitly requested work on RFC-016 and its changes in the next iteration and a commit on 2026-11-07; exact request recorded in the revision history. Revision 8: Eugene explicitly requested reusable black-box host capture, stronger acceptance criteria and Signal Analyzer migration on 2026-11-07; exact request recorded in the revision history."
related_future_work:
  - FW-036
  - FW-037
  - FW-038
  - FW-041
  - FW-042
  - FW-046
closure: null
---

# ITERATION-004: Backend and Application Integration

## Approved scope narrowing — 2026-11-08

Revision 12 keeps I4-01–04 as the delivery core and bounds I4-05/06/07/08 to
named dependencies of the external counter, recording adapter and reusable-host
Signal Analyzer. Compiler exploration, Core-wide generalization and unrelated
contract cleanup are not iteration-4 delivery requirements. Preserve all safety,
compatibility and certification obligations applicable to the selected compositions,
including revision 11's restricted-use disposition below.

I4-09 / I4-AC-010 transfer to ITERATION-005 I5-01 / I5-AC-001; I4-10 /
I4-AC-011 transfer to I5-02 / I5-AC-002. The old IDs are reserved and transferred,
not met. [Iteration 5](iteration-005-authoring-and-storage-assessment.md) preserves
their outcomes and feature gates. Iteration 4 uses existing approved observation
contracts and does not wait for RFC-016. Historical allocations below are
superseded only where this revision explicitly narrows or transfers them.

## Approved restricted-use closeout disposition — 2026-11-08

Revision 11 applies the [S1–S3 closeout disposition](iteration-003-review/p08-unmet-safety-closeout-disposition.md).
The named gaps may remain explicitly unmet at iteration-3 closure. They block
only affected iteration-4 reuse/adoption until resolved or replaced and validated;
unrelated qualified work and normally approved resolution work may proceed.
P08 remains FROZEN / UNMET. P10 validation/criterion dispositions, independent
overall freeze acceptance, retained P11/P12/ME-09 handoff and explicit human closure
remain required. Earlier blanket S1–S3 closure/entry blockers are superseded only
by this exact disposition; other shared defects and contract gates are unchanged.


## Approved P08 freeze — 2026-11-08

Revision 10 applies the [P08 freeze and certification transfer](iteration-003-review/p08-freeze-and-certification-transfer.md).
P08 is FROZEN / UNMET, not PASS. Iteration 3 retains shared safety blockers,
bounded freeze/handoff reconciliation and applicable framework/counter validation.
Composition-specific counter certification and dependent adoption move to I4-03/04/07
and I4-AC-013. Full P08 PASS is no longer an iteration-4 entry gate; reviewed
classification, human handoff/closure and normal contract gates remain required.
Earlier complete-P08/whole-counter-fit prerequisites below are superseded by this
allocation; no criterion, resource limit or safety requirement is waived.


## Approved delivery allocation — 2026-11-08

Revision 9 applies the [approved analyzer transfer](iteration-003-review/analyzer-delivery-transfer.md).
P08 and framework/counter P10–P12 remain in iteration 3. Analyzer P09 and
analyzer-specific P10–P12 move to iteration 4 with reusable-host adoption.
The transfer map preserves IT-AC-004–010 and every Spec obligation; the original
criterion wording below defines the required results across the two iterations.
Analyzer obligations are transferred and unmet, never implicitly passed.
Earlier sequencing statements are historical where superseded by this allocation.


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
components and supported host/build entry points. Preserve the framework/counter results established in iteration 3 and establish
the transferred analyzer runtime-derivation, resource and timing results on the
final reusable-host composition.

## Delivery Waves and Priorities

Revision 12 organizes eight retained items around external integration. P0 means
an evidenced prerequisite or certification gate for a named dependent outcome;
P1 means required delivery. Reviews and assessments are P1 unless a concrete
blocking dependency is recorded. No optional optimization is on the critical path.

| Wave | Items and priority | Exit / dependency |
| --- | --- | --- |
| **W0 — Baseline and handoff** | I4-04 source/evidence handoff and I4-07 dependency classification: P0; I4-05 baseline compatibility review: P1, P0 only for a named tooling blocker | Pin approved Swift 6.4/SDK/source/artifacts; classify reuse/refresh/unmet and required/deferred RFC-015 residuals. Record I4-AC-006. Preserve human iteration-3 handoff and revision-11 affected-reuse gates. |
| **W1 — Integration contracts** | I4-01/02/03 public package/backend/host decisions: P0 before extraction; I4-06 ownership and I4-08 failure-boundary review: P1, P0 only for unresolved required public contracts | Deliver bounded I4-AC-007/009 dispositions for the counter, recording adapter and analyzer. Resolve RFC-013 and obtain required ADR/Spec approvals and ready plans. No Core-wide or simulator study is a prerequisite. |
| **W2 — External counter** | I4-01 packages, I4-02 reusable backend/recording adapter, counter I4-03: P1; applicable I4-07 storage dependencies and I4-04 counter certification: P0 | Qualify supported/recording compositions on all four configurations, including I4-AC-013 before dependent analyzer adoption; map responsibilities and evidence reuse. |
| **W3 — Analyzer adoption** | Analyzer I4-03 migration: P1; I4-07 actual dispatcher/ownership residuals and I4-04 resource/workload certification: P0 | Use the qualified reusable host and existing approved observation contracts. Complete analyzer P09–P12, applicable I4-AC-001–004/008 and I4-AC-012 before production cutover. No RFC-016 migration dependency. |
| **W4 — Conformance and documentation** | I4-04 guides/comparisons: P1; final evidence dispositions and I4-07 applicability reconciliation: P0 | Complete I4-AC-005; disposition active I4-AC-001–009/012/013 and transferred IT-AC-004–010. Record I4-AC-010/011 as transferred to iteration 5, and non-integration RFC-015 residuals under FW-046. Obtain human closure; no full-Spec pass inferred from partial coverage. |

| Item | Primary wave | Priority / boundary |
| --- | --- | --- |
| I4-01 — Focused packages | W1 → W2 | P1 delivery; required public decisions P0 |
| I4-02 — Reusable backend and platform components | W1 → W2 | P1 delivery; required adapter contracts P0 |
| I4-03 — External application integration | W2 counter → W3 analyzer | P1; dependent adoption waits for certification |
| I4-04 — Compatibility and author documentation | W0, W2–W4 | P0 certification / P1 documentation |
| I4-05 — Integration toolchain compatibility | W0 | P1; P0 only for a named supported-build blocker |
| I4-06 — Integration ownership boundaries | W1 | P1; P0 only for a named host/package/adapter decision |
| I4-07 — Integration-required RFC-015 residuals | W0 classification, W2–W3 delivery, W4 reconciliation | P0 applicable correctness and certification; unrelated residuals excluded |
| I4-08 — Public host failure boundary | W1 | P1; P0 only for required public failure/lifecycle decisions |

Independent preparation may overlap. P0 classification must identify the blocked
item/criterion and evidence needed to unblock it. Complete applicable safety and
resource proof before adoption; cost or failure is never grounds for deferring a
required dependency. Preserve equivalent coverage before retiring orchestration.

## Included Scope

| Item | Source / feature | Intended outcome | Lifecycle routing |
| --- | --- | --- | --- |
| I4-01 — Focused packages | Approved transfer of I3-01; FW-016 | External consumers select framework/runtime, rendering and required platform/display components without analyzer internals or repository-wide source lists | Review ADR-008/SPEC-002 and current cost/ownership handoff; approve affected topology/access decisions before extraction |
| I4-02 — Reusable backend and platform components | Approved transfer of I3-02; EXP-002 / PROPOSAL-007 | Reusable raster/session construction, validation and narrow adapter contracts; one external recording adapter uses the same supported assembly path | RFC-013, accepted downstream ADRs and approved SPEC-009/012/014 amendments as required; no mandatory new core module |
| I4-03 — Simpler external application integration | Approved transfer of I3-03; FW-030 / PROPOSAL-007 | Reusable hosts encapsulate framework assembly/lifecycle for the external counter and Signal Analyzer; clients supply application behavior/services/resources/configuration; migrate bespoke analyzer wiring; portable presentation imports GiftUI alone | Public assembly/lifetime/build contracts and ready Spec plans before implementation |
| I4-04 — Compatibility and author documentation | Approved transfer/renewal of IT-AC-004/005 | Preserve runtime derivation and iteration-3 efficiency; reproducible quick start, adapter and migration guides | Final owner conformance, measured paired artifacts and separate criterion dispositions |
| I4-05 — Integration toolchain compatibility | FW-036; revision 12 | Verify approved Swift 6.4 and paired SDK/build tooling for supported external consumer routes; record concrete incompatibilities and the minimum remedy | Reuse qualified comparisons; no broad upgrade survey. Further compiler/pin changes require separate approval and fresh affected evidence |
| I4-06 — Integration ownership boundaries | FW-037 / EXP-002; revision 12 | Map physical/transaction ownership, borrowing, transfer and cleanup at the actual counter, recording-adapter and analyzer host boundaries; resolve only dependencies of selected public contracts | RFC-013 and affected ADR/Spec gates; broader Core/frontend/PC-simulator generalization remains FW-037 |
| I4-07 — Integration-required RFC-015 residuals | RFC-015, ADR-039, SPEC-011/013/015; revision 12 | Classify every B1–B4 / ownership-criterion residual; complete all shared, counter, adapter and analyzer dependencies, including actual owned dispatcher factories and certification | Approved owner plans; retain full-contract unmet dispositions for excluded residuals in FW-046; no weakening of applicable contracts |
| I4-08 — Public host failure boundary | FW-041 F-01–06; revision 12 | Classify findings against the supported host API; review framework containment, client business failures and host lifecycle only where needed by the counter/adapter/analyzer integration; produce affected contract and migration/validation map | Review/proposal through RFC-013 and required ADR/Spec gates; unrelated failure-system redesign remains FW-041 |

Use the same bounded counter/status application, changing text, typed actions,
disabled Button and small Canvas variant as iteration 3. It must now be a real
external package consumer without privileged shared-package access. First build
supported compositions, then substitute only the recording display through the
same backend/host assembly. Migrate Signal Analyzer to the same supported reusable host contracts as the
nontrivial adoption and compatibility application. Its capture/domain services
remain application-owned. Runtime graph derivation remains mandatory for both
applications; RFC-014 P09/P12 alone does not establish reusable-host adoption.

## Delivery Order and Gates

Production entry requires an explicit human iteration-3 delivery/closure decision
and reviewed P08 freeze classification plus retained framework/counter P10–P12
evidence, or an explicit applicable
exception for a retained failure. The handoff records exact source/toolchain/artifact
identities, budgets and counter/analyzer unknowns. Full P08 PASS and S1–S3 resolution are not required
for blanket iteration entry; affected reuse remains blocked under the register; the freeze alone does not activate this
iteration. Transferred analyzer P09–P12 results are delivery/adoption gates here,
not entry prerequisites; their absence alone requires no entry exception.
Normal architecture, Specification and ready-plan gates remain before implementation.
See the [complete entry/adoption rules](iteration-003-review/analyzer-delivery-transfer.md#iteration-4-entry-and-adoption-gates).


### Counter-first extraction and evidence handoff

The maintainer's 2026-11-08 instruction is recorded in
[RFC-013's counter-first migration section](../rfcs/rfc-013-external-application-and-backend-integration.md#counter-first-migration-and-p08-reuse--2026-11-08).
This clarifies execution of approved revision 9 within I4-03/04 and existing
acceptance criteria; it adds no scope or architecture approval.

Use the frozen, incomplete P08 implementation and qualified evidence as the concrete
baseline. Inventory CounterHostOwner, CounterPipelineOwner, profile/scoped storage
and the existing shared host machinery; classify framework assembly, application
behavior and test instrumentation before extraction. After entry and contract
gates, first deliver the external counter on the reusable GiftUI-owned host,
then migrate Signal Analyzer through the same supported contracts. Counter
qualification must cover all four governed configurations, supported and recording
compositions, and activation/refusal/teardown before dependent analyzer adoption.
Analyzer-specific design preparation may proceed earlier; no intermediate bespoke
analyzer host migration or second bootstrap is required.

For I4-AC-001/003/004/005/008, the migration receipt must include:

- A pinned P08 source/compiler/SDK/flags/profile/artifact and criterion baseline,
  preserving incomplete results, plus a symbol/responsibility destination map.
- Explicit reuse/refresh/unmet dispositions for relevant P08 evidence. Check
  changed module/access, generic/type, dependency, backing/lifetime and measurement
  conditions; reuse only with an applicability argument and refresh invalidated
  actual-consumer, cold/allocation, safety, resource/ABI and target checks.
- External counter builds without privileged access, internal owner wiring or
  handwritten framework source lists; application behavior/configuration remains
  in the consumer and fault injection remains in tests. Preserve component owners.
- Independent semantic/action/pixel and failure/cleanup oracles, applicable compiler
  negatives, before/after resource costs and replacement-coverage mappings before
  retiring duplicated fixture orchestration. Counter evidence does not satisfy
  analyzer fit or I4-AC-012 sustained-workload certification.

Reviewed freeze classification and the iteration-3 handoff replace the full-P08
completion prerequisite. S1–S3 affected-reuse restrictions remain binding; transferred
certification must pass on the supported counter host before dependent adoption.
Reuse does not declare P08 passed or expand its scope. RFC-013 stays draft.

RFC-016 authoring work is scheduled in iteration 5; use existing approved
model/observation contracts for iteration-4 integration. No resource or execution
allowance is reset by the transfer.

I4-09 is transferred to iteration 5; no tuple-buffer assessment or replacement
is required for iteration-4 extraction.

1. Assess the compiler baseline under I4-05 early enough to inform extraction.
   Verify supported consumer build compatibility and reuse P07/lifetime controls
   where applicable. Investigate only named integration blockers. Start from the
   approved Swift 6.4
   baseline recorded in [FW-036](../future-work/fw-036-swift-compiler-upgrade-assessment.md#revisit--2026-10-12),
   reusing qualified earlier comparisons; retaining that baseline is a valid
   disposition. A further upgrade requires separate approval and fresh affected evidence.
2. Accept the iteration-3 handoff and refresh exact source/toolchain/resource
   identities. Reconcile RFC-013 with the approved ownership and storage choices.
3. Assess I4-06 alongside transitive access, package alternatives and backend/host
   construction. Compare the evidenced P08 boundary (or its unresolved limits)
   with the external counter, recording adapter and Signal Analyzer; record missing
   integration evidence explicitly. Core-wide/frontend/PC-simulator studies are
   excluded. Feed the disposition into the package/access review.
   Obtain architecture and affected Specification approvals.
   For I4-07, reconcile the P08 residual matrix against every RFC-015 B1–B4
   obligation and all nine adopted ownership criteria. Classify each residual by
   concrete integration dependency; retain excluded residuals under FW-046.
   Complete applicable work
   through the approved owner plans before dependent integration; reuse qualified
   P08 evidence and refresh only changed paths. I4-06 assessment is not a prerequisite
   to realizing RFC-015's already selected finite ownership contract.
4. Derive ready implementation plans; extract the P08-based counter into the
   supported reusable host, qualify its external supported/recording compositions
   on all four routes, and record evidence reuse/refresh before analyzer adoption.
5. Migrate Signal Analyzer to the qualified reusable host path; inventory each
   bespoke assembly responsibility, retain justified application adapters, and
   retire replaced production wiring after equivalent validation. Run the external
   consumer/adapter matrix and compare final analyzer memory,
   timing and loaded behavior with the identified pre-migration analyzer baseline.
   Complete transferred P09–P12 and IT-AC-004–010 obligations on the final host,
   including required connected certification before production cutover.
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
Revision 12 limits this allocation to selected integration dependencies. CC-01–04
receive a dependency disposition; only necessary integration changes are delivered.
Other cleanup remains in FW-037/FW-038, without a new architecture commitment.

**Entry:** begin this cleanup after the explicit iteration-3 delivery/closure
decision and the applicable iteration-4 entry gates. P08 PASS alone is not its
start trigger. Read-only capture here does not activate iteration 4. Keep iteration-3 P08 and framework/counter P10–P12 focused on delivery;
coordinate analyzer P09–P12 with I4-03/04 rather than an intermediate host. A
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
   the selected boundary against Signal Analyzer and the external recording adapter.
   Broader second-frontend and PC-simulator research remains in FW-037. Name evidence gaps. This
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

The scope is the integration-required subset of the four named boundaries;
record a dependency or a FW-037/FW-038 defer disposition for each. Package proliferation, a whole-Core
rewrite, unrelated style work and weaker acceptance coverage are excluded.
FW-037/FW-038 stay `captured`; scheduling an assessment does not approve their
candidate realizations or promote their lifecycle status.

## Framework/Client Failure Boundary Review

I4-08 classifies FW-041 F-01–06 and reviews integration-required findings before dependent I4-01/03 public package and host
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
This iteration item commits to an integration-bounded review/proposal and testable migration plan;
implementation requires its separate lifecycle gates.

## Exclusions

- I4-09 buffer assessment and I4-10 authoring API work, transferred to iteration 5.
- Broad compiler upgrade surveys (FW-036), Core-wide/frontend/simulator ownership
  research (FW-037), unrelated cleanup (FW-038), unrelated failure redesign
  (FW-041) and non-integration RFC-015 residual delivery (FW-046).

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
| I4-AC-004 (renewed IT-AC-004/006) | Both applications use reusable hosts and runtime-derived graphs; preserve framework/counter results and establish transferred analyzer derivation, semantics, state/actions/pixels/failures and resource/performance results; analyzer regression-only coverage or runtime traversal migration alone is insufficient | All four configurations, actual supported targets for timing claims | Final exact artifact/flag comparisons, approved budgets and governing Spec conformance; repeat changed-path connected tests when required |
| I4-AC-005 (from IT-AC-005) | Application and adapter authors can reproduce and customize supported integration; every criterion has an evidenced disposition | All supported build routes | Quick start using the supported host, custom-adapter guide through the same host path, explicit client/host responsibility and resource/capability/diagnostic inventory, Signal Analyzer migration/removal map, package/API compatibility notes; exact evidence identities and human closure |
| I4-AC-006 | Approved compiler/SDK baseline supports the selected external consumer build routes, or each concrete blocker has an evidenced minimum-remedy recommendation and adoption gate | macOS Dynamic/Static, actual ARMv6 and Embedded supported integration tooling | FW-036; exact pinned identities, applicable existing P07/lifetime controls and build evidence; retain baseline is valid; no broad version survey or unapproved upgrade |
| I4-AC-007 | Actual counter, recording-adapter and analyzer host ownership/transfer/cleanup boundaries are mapped; each integration decision has evidence and contract routing; broader questions have a FW-037 disposition | Dynamic and Static/Embedded supported integration compositions | FW-037 assessment model applied only to selected consumers; map physical/transaction ownership, borrow/mutation, acceptance/refusal and cleanup; resolve required public-contract questions before extraction; no Core-wide or PC-simulator study required |
| I4-AC-008 | Every RFC-015 B1–B4 and nine adopted ownership criteria has a residual/applicability disposition; all dependencies of selected shared/counter/adapter/analyzer paths are implemented and evidenced; excluded residuals remain explicitly unmet under FW-046 | All four governed configurations; applicable target evidence unchanged | Exact caller/physical inventory and P08 reuse/refresh ledger, approved owner plans and independent conformance review; mandatory actual analyzer factory positives/negatives retained. Dependency evidence required for exclusion; no full RFC/Spec completion inferred |
| I4-AC-009 | F-01–06 are classified by integration dependency; required public host failure/lifecycle decisions have review, affected ADR/Spec mapping and ordered migration/validation plan; unrelated findings retain FW-041 follow-up | External counter, recording adapter and analyzer; all four configurations addressed | FW-041 / RFC-013; admission, partial mutation, publication, backend handoff and teardown scenarios; no weaker failure/resource semantics or implementation pass inferred from review |
| I4-AC-010 | Reserved ID; delivery transferred to I5-AC-001, not met or waived | Unchanged in iteration 5 | [ITERATION-005](iteration-005-authoring-and-storage-assessment.md); revision-12 transfer |
| I4-AC-011 | Reserved ID; delivery transferred to I5-AC-002, not met or waived | Unchanged in iteration 5 | [ITERATION-005](iteration-005-authoring-and-storage-assessment.md); revision-12 transfer |
| I4-AC-012 (transferred IT-AC-007–010) | Final reusable-host analyzer has complete cost accounting, safe bounded actual compositions and meets the unchanged sustained acquisition/presentation requirements; resolve transferred storage/transfer unknowns before adoption | All four configurations; connected Pi and nRF supported artifacts for target claims | P11 exact linked artifacts, complete live-storage/main/IRQ stack, ABI/zero-heap/RAM/flash proof and phase measurements; at least 30 continuous seconds at 80 events/s and four-FPS target cadence, no loss/reordering/duplicates/stale facts/capacity rejection, original SPEC-001 latency/coalescing/frame/state checks; [full transfer map](iteration-003-review/analyzer-delivery-transfer.md#acceptance-transfer-map) |
| I4-AC-013 (counter portions of IT-AC-007/008) | Frozen P08 composition-specific residuals are mapped to retained/replacement evidence; supported reusable counter host has complete required safety, cold/allocation, stack/IRQ, ABI and resource certification before adoption and dependent analyzer adoption | All four governed configurations; applicable provider/target evidence and supported/recording compositions | [Freeze allocation and classification](iteration-003-review/p08-freeze-and-certification-transfer.md); exact input/artifact and reuse/refresh/unmet ledger, early target feasibility, independent final conformance review, unchanged budgets; no implied historical P08 PASS |

The matrix is macOS Dynamic, macOS Static, Raspberry Pi 1
`armv6-unknown-linux-gnueabihf` Dynamic with framebuffer/PiScreen, and
`nrf52840dk/nrf52840` Embedded Static with the existing TFT composition.
Native rehearsals and target links do not establish connected performance.
Use repository toolchains and target skills, preserve zero-heap Static and VFP
ABI checks, and obtain explicit authorization for required connected operations.

## Dependencies and Open Questions

- Iteration-3 revision 8 and iteration-4 revision 12 are approved. Feature and
  implementation approvals remain separate.
- Production migration uses the entry gates above: retained framework/counter
  evidence and human handoff/closure, or a specific retained-gate exception.
  Analyzer derivation, safety/fit, sustained workload and cutover are transferred
  delivery requirements, not prerequisites to beginning their own migration.
  Inventory/design preparation may proceed while entry gates remain open.
- PROPOSAL-007 remains accepted and RFC-013 draft. Reuse valid studies and
  failures; do not reset SPIKE-067's exhausted allowance or adopt its code by
  moving files. New architecture/contracts remain separate human gates.
- I4-06 may inventory boundaries before P08 closes. RFC-015 is approved, but
  ADR-039 and exact Spec amendments are accepted/approved/applied under the
  [2026-10-13 acceptance](iteration-003-review/rfc-015-contract-acceptance.md). I4-07 owns integration-required RFC delivery and complete residual classification;
  P08 retains every obligation required by its adopted paths under the delivery
  allocation. Neither item moves a P08 safety or fit blocker into optional work.
  For I4-06, missing evidence is recorded explicitly; only non-required research
  may be deferred. Required public-contract questions remain blockers;
  no compiler/repair allowance is reset by this scope addition.
- Decide whether the measured owner boundaries require any new core module;
  no module name or inheritance hierarchy is selected by this scope.
- Identify minimal public transitive access and maintainable supported build
  routes after efficiency decisions stabilize the lifetime/storage requirements.

## Revision and Approval History

| Revision | Date | Change / reason | Maintainer approval |
| --- | --- | --- | --- |
| 12 | 2026-11-08 | Narrow I4-05/06/07/08 to integration dependencies; transfer I4-09/10 and I4-AC-010/011 to iteration 5; revise waves/priorities, preserve revision-11 safety gates | Eugene: “Please narrow iteration 4 as recommended, move I4-09 and I4-10 to the next iteration, and update the waves, priorities, and dependent documents.” |
| 11 | 2026-11-08 | Permit closeout with S1–S3 unmet and affected reuse blocked; retain remaining gates | [Explicit restricted-use disposition](iteration-003-review/p08-unmet-safety-closeout-disposition.md) |
| 10 | 2026-11-08 | Freeze P08 UNMET; transfer counter composition certification and dependent adoption; preserve shared safety blockers and revise entry gates | [Explicit approval and allocation](iteration-003-review/p08-freeze-and-certification-transfer.md) |
| 9 | 2026-11-08 | Transfer analyzer P09–P12 to iteration 4; retain P08/framework/counter validation and revise entry gates without waiving acceptance | [Explicit approval and transfer map](iteration-003-review/analyzer-delivery-transfer.md) |
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

At closure, disposition I4-AC-001–009/012/013 and transferred IT-AC-004–010 as met, unmet or explicitly excepted with
current evidence. Record I4-AC-010/011 as transferred to I5-AC-001/002, not met.
Preserve remaining work and triggers, and obtain a human closure decision. Do not infer delivery from transferred scope or passed studies.

The [FW-038 consolidation candidate](../future-work/fw-038-scoped-contract-validation-cost.md)
records the opportunity to remove parallel build/test infrastructure while
preserving meaningful coverage. Revision 12 limits its iteration-4 delivery to
integration dependencies; unrelated optimization remains captured in FW-038.
Applicable P08 safety and proof obligations remain in force.

## Deferred and Follow-up Work

[Iteration 5](iteration-005-authoring-and-storage-assessment.md) receives FW-042's
assessment and RFC-016 authoring delivery, with reciprocal item/criterion mapping.
FW-042 remains captured; RFC-016 remains draft.

Broader compiler, ownership, cleanup and failure questions remain in
[FW-036](../future-work/fw-036-swift-compiler-upgrade-assessment.md),
[FW-037](../future-work/fw-037-core-wide-storage-ownership-generalization.md),
[FW-038](../future-work/fw-038-scoped-contract-validation-cost.md) and
[FW-041](../future-work/fw-041-framework-client-failure-boundary.md). Revisit when
a named consumer dependency or measured integration limitation demonstrates need;
they are not automatically assigned to iteration 5.
[FW-046](../future-work/fw-046-non-integration-scoped-storage-residuals.md)
preserves RFC-015 residual delivery outside the selected compositions. W0/W4
must record exact exclusions, evidence and revisit triggers; required dependencies
cannot be classified away. Full Spec conformance remains open where appropriate.

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
