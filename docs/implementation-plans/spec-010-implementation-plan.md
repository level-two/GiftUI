---
spec: SPEC-010
feature: observable-reference-state
title: SPEC-010 Implementation Plan
status: active
owners:
  - codex
created: 2026-09-04
updated: 2026-09-06
related_design_notes: []
conformance_report: null
related_future_work:
  - FW-019
related_explorations: []
related_spikes:
  - SPIKE-003
  - SPIKE-006
supersedes: null
superseded_by: null
---

# SPEC-010 Implementation Plan

> This ready plan derives work from the approved Observable Reference State
> Contract, including its explicitly reapproved 2026-09-05 completeness
> amendment. It orders implementation and evidence but does not amend the
> declaration, generation, ownership, mutation, publication, failure, action-
> target, or profile contracts owned by that Specification and its accepted
> dependencies.

## Authority and Scope

The governing [SPEC-010](../specs/spec-010-observable-reference-state.md)
contract is approved, under accepted
[PROPOSAL-005](../proposals/proposal-005-observable-reference-state.md),
approved [RFC-008](../rfcs/rfc-008-observable-reference-state-architecture.md)
and [RFC-011](../rfcs/rfc-011-bounded-application-actions.md), and accepted
[ADR-008](../adrs/adr-008-module-dependency-graph-and-package-topology.md),
[ADR-011](../adrs/adr-011-serialized-run-cycle-and-publication.md),
[ADR-014](../adrs/adr-014-bounded-cross-layer-outcomes.md),
[ADR-015](../adrs/adr-015-layered-failure-disposition.md),
[ADR-016](../adrs/adr-016-non-authoritative-diagnostics.md),
[ADR-024](../adrs/adr-024-structurally-owned-observable-reference-state.md),
[ADR-025](../adrs/adr-025-coarse-model-owned-observable-invalidation.md),
[ADR-026](../adrs/adr-026-profile-equivalent-bounded-observable-state.md),
[ADR-027](../adrs/adr-027-bounded-presentation-fact-admission.md), and
[ADR-033](../adrs/adr-033-bounded-application-actions-and-model-target-dispatch.md).

The MVP scope requires one substantially shared Signal Analyzer Presentation
to preserve a root reference model and reflect Start, Stop, Clear, acquisition,
error, capture, and visible-window changes on macOS dynamic/static, Raspberry
Pi 1 ARMv6, and nRF52840 static configurations. This plan supplies that
observable-state stack seam only. It does not add value state, public binding,
property dependency tracking, multiple owners, application lifecycle,
backends, platform scheduling, or production capacities owned by SPEC-013 and
SPEC-015.

Completed [SPIKE-003](../spikes/spike-003-portable-observable-reference-state-feasibility.md)
and [SPIKE-006](../spikes/spike-006-spec-010-embedded-declarations.md) are
feasibility evidence only. Their disposable declarations, storage, widths,
and generated code are not implementation authority.

## Current Repository State

- `GiftUI` now contains the exact SPEC-010 portable `State`, observable model,
  sink, attachment, visitor, state-host, and macro declarations. Focused unit,
  access-negative, ownership, and four-profile compile fixtures cover the
  completed declaration work without claiming owner-runtime conformance.
- `GiftUIMacros` is the pinned host-only macro target. Its deterministic
  expansion and generated SPEC-006 traversal witnesses are implemented, and
  the four target-image checks exclude macro and compiler-support linkage.
- SPEC-006's stateful visitor category and generated traversal seam are
  present. The SPEC-010 binding decorator and owner reconciliation that make
  that traversal operational remain future `T3.2` work.
- `GiftUIObservableState`, dynamic/static observable-state storage, and the
  observable-state failure adapter do not exist. Package exact-set edits for
  those owners remain assigned to `T0.2`, `T2.1`, `T6.*`, and `T7.1`.
- Approved SPEC-009 now has a ready implementation plan, but the
  `GiftUIExecution` target, `ObservableTargetGeneration`,
  `ExecutionAdmissionOutcome`, phase/wake seams, and coordinator are not yet
  implemented. Work requiring them remains dependency-blocked; this plan must
  not create substitutes.
- SPEC-002's exact target/dependency registry, SPEC-003's failure owner seam,
  SPEC-006's four-profile driver conventions, and repository-local ARMv6/nRF
  toolchains are reusable. Package exact-set controls must change atomically.
- SPEC-013 and SPEC-015 are approved, but they have no ready implementation
  plans or production runtime/host targets. Profile realization and assembled
  host claims remain jointly gated by their owner work and SPEC-009 rather
  than being inferred from the completed Spikes.

## Readiness Review

**Reviewed:** 2026-09-06

**Disposition:** Ready to continue. SPEC-010 remains an approved, implementing contract;
all twelve acceptance criteria map exactly once to ordered tasks and
reproducible evidence. The declaration and generation slice already completed
under the approved contract remains recorded as completed work. This
maintainer-requested readiness refresh means the remaining plan is executable
without inventing architecture or contract; it does not roll back source,
tests, evidence, the Specification's `implementing` status, or completed task
dispositions.

No `docs/features.yaml` update is required. Implementation records are not
registered there, and `observable-reference-state` already reports the
implementation stage. Missing owner implementations are explicit task
dependencies: profile-neutral fixture and design preparation may proceed at
the boundaries below, while production execution, runtime-profile, host,
Interaction, and Signal Analyzer claims wait for their authoritative owners.

If implementation cannot express the exact noncopyable sink, transient bound
wrapper, atomic replacement, no-ordinary-failure publication, or zero-heap
static behavior on the pinned toolchains, the affected work returns to
Specification review. Any need to change module ownership, focused failure
precedence, publication timing, registration-generation meaning, or profile
equivalence returns to the applicable ADR or Specification rather than being
resolved in code or a design note.

## Task Dependencies and Affected Surfaces

Milestone numbers define the default order. A task may start only after every
listed prerequisite is satisfied.

| Work | Prerequisites | Primary affected surfaces | Parallel boundary |
| --- | --- | --- | --- |
| `T0.1`-`T0.4` | Approved SPEC-010 authority chain | `Tests/ContractFixtures/SPEC010/`, contract-driver registry, package boundary registries | Completed schemas, driver, and migration work remain stable; `T0.2` closes incrementally only with compiling owner targets |
| `T1.1`-`T1.5` | Milestone 0 boundaries; pinned host macro and cross-toolchains | `Sources/GiftUI/`, `Sources/GiftUIMacros/`, focused tests and evidence | Completed; no remaining task may revise these declarations without upstream review |
| `T2.1`-`T2.4` | SPEC-009 `GiftUIExecution` declarations and package edge available | `Sources/GiftUIObservableState/`, owner tests, package graph | Value/protocol tests may proceed together after the complete execution types exist; design-note decision follows concrete complexity |
| `T3.1`-`T3.4` | `T2.1`-`T2.2`; SPEC-006 structural identity/traversal seam | owner reconciliation, state-aware decorator, candidate fixtures | Lifecycle and decorator implementation may divide only after one shared result/rollback vocabulary is fixed |
| `T4.1`-`T4.4` | Stable reconciliation plus SPEC-009 target-generation value | replacement storage, generation allocator, borrowed target views | Lookup fixtures may be authored alongside replacement fixtures; lifetime comparison consumes both |
| `T5.1`-`T5.4` | Active/stale registrations; SPEC-009 phase, wake, publication, and mutation-result seams | report routing, coordinator integration, phase fixtures | Outcome routing and publication integration may proceed separately against one frozen phase/effect transcript |
| `T6.1`-`T6.4` | Complete profile-neutral owner behavior; SPEC-013/SPEC-015 owner plans and targets for production claims | dynamic/static fixture storage, runtime profiles, fact-admission adapter | Fixture profiles may precede production realization; normalized equivalence follows both fixture reports |
| `T7.1`-`T7.3` | Injectable local failures and SPEC-003 values | failure adapter, precedence/policy corpus, diagnostic isolation | Mapping and diagnostic-isolation fixtures may proceed together after mandatory effects are observable |
| `T8.1`-`T8.4` | Complete corpus and profile workspaces; repository-local toolchains | four driver reports, ELF/link/allocation/stack/resource inspection | Profile commands may run independently; comparison consumes all four immutable reports |
| `T9.1`-`T9.3` | All owner tasks and available downstream integrations | conformance audit/report and Specification cross-references | Surface audit may start early; conformance disposition waits for every criterion and required integration |

## Acceptance-Criterion Matrix

| Criterion | Implementation tasks | Evidence | Status |
| --- | --- | --- | --- |
| `OS-001` — Exact portable declarations and deterministic macro on every profile | `T1.1`–`T1.5`, `T8.1`–`T8.3` | Public/package surface audit, macro snapshots, four-profile compile/link reports | pending |
| `OS-002` — Same-location preservation and distinct ordinals | `T3.1`, `T3.2`, `T6.1` | Shared identity/preservation transcript | pending |
| `OS-003` — Atomic replacement/removal and no stale alias | `T3.3`, `T4.1`, `T4.2` | Replacement/removal/slot-reuse fault corpus | pending |
| `OS-004` — Twenty changes produce one dirty owner/wake/reevaluation | `T5.1`, `T5.2`, `T6.2` | Exact operation and publication transcript | pending |
| `OS-005` — Exact local mapping and no partial publication | `T2.2`, `T3.4`, `T7.1`–`T7.3` | Exhaustive error/mapping/mandatory-effect matrix | pending |
| `OS-006` — Equal profile transcripts and zero static heap | `T6.1`–`T6.3`, `T8.2`–`T8.4` | Normalized comparison and allocation reports | pending |
| `OS-007` — Ordered later fact application and no direct/reentrant mutation | `T2.3`, `T5.3`, `T6.4` | Admission/refusal/order/reentrancy fixtures | pending |
| `OS-008` — No forbidden static dependencies | `T0.2`, `T6.3`, `T8.3`, `T9.1` | Target graph, import-negative, symbols, link-map audit | pending |
| `OS-009` — Fresh target generations and retirement/exhaustion | `T4.1`–`T4.4`, `T6.1` | Live/publishable target transcript and lifetime probes | pending |
| `OS-010` — Generated lexical visitation and bind-before-body | `T1.2`–`T1.5`, `T3.2` | Macro expansion and stateful traversal transcript | pending |
| `OS-011` — Exact report outcomes and phase/lifecycle effects | `T5.1`–`T5.4`, `T7.2` | Report-outcome and mandatory-disposition corpus | pending |
| `OS-012` — Candidate publishable lookup timing and commit/discard | `T3.1`, `T4.3`, `T4.4`, `T6.1` | Candidate lookup timing/equality transcript | pending |

## Milestones and Tasks

### Milestone 0: Freeze Authority, Package Boundaries, and Evidence Schemas

**Entry conditions:** SPEC-010 is approved; linked accepted decisions are
authoritative. No runtime or macro implementation is inferred from a Spike.

**Exit evidence:** Every acceptance label, dependency owner, existing gap,
fixture schema, and migration surface is explicit before declarations land.

- [x] `T0.1` — Create `Tests/ContractFixtures/SPEC010/` with an ordered compile
      registry, macro-expansion snapshot schema, semantic transcript schema,
      normalized result schema, required-evidence registry, and README that
      separates host execution, cross-build, simulator, and connected-target
      evidence. Map every `OS-001` through `OS-012` row fail-closed.
- [ ] `T0.2` — Reserve and audit the approved target/dependency rows for the
      host-only `GiftUIMacros`, `GiftUIObservableState`, its tests, and narrowly
      named owner-adapter fixtures. Add `GiftUIMacros` to the exact package
      graph only with its first buildable plugin implementation in `T1.2`; add
      `GiftUIObservableState` and its exact `GiftUIExecution` edge only in
      `T2.1` after that owned target exists. Prove the macro is neither a
      product nor in any target-image dependency closure, and reject imports
      of runtimes, Interaction, application models, backends, platforms,
      drivers, OS/RTOS, HAL, or hardware from the owner. Do not add empty or
      dependency-incomplete placeholder targets merely to reserve names.
- [x] `T0.3` — Create and register `scripts/contracts/run-spec-010.sh` with the
      exact four profile names, pinned compiler/SDK/optimization metadata,
      immutable input identity, normalized report schema, command transcript,
      and explicit `missing` evidence rows. The initial driver must compile
      only dependencies that exist and must not claim semantic or hardware
      conformance early.
- [x] `T0.4` — Inventory every removed PoC `@State`, task-local binding,
      string key, `Any` store, runtime-specific state path, direct model
      mutation, Apple Observation use, and disposable Spike spelling. Assign
      remove, replace-through-owner, downstream-owned, or evidence-only
      dispositions and add a registered regression check.

### Milestone 1: Implement Portable Declarations and Deterministic Generation

**Entry conditions:** Milestone 0 fixes target direction and compile evidence.
The checked-in toolchain evidence confirms macro support on the build host;
macro implementation dependencies are pinned and do not enter target images.

**Exit evidence:** Portable clients use only `import GiftUI`; generated hosts
enumerate direct state lexically and enter SPEC-006's stateful category.

- [x] `T1.1` — Implement in `GiftUI` the exact
      `_GiftUIObservableChangeReportOutcome`, `_GiftUIObservableReference`,
      `_GiftUIObservationAttachment`, `_GiftUIObservableStateDeclarationVisitor`,
      and `_GiftUIObservableStateHost` source contracts. Preserve the
      attachment's non-forgeable public boundary and exact raw values; compile
      positive model/host conformances and access-negative clients on all four
      profiles. This task supplies the owner declaration that unblocks the
      SPEC-006 T1.4 visitor signature.

  **Source-contract blocker resolved.** The 2026-09-05 maintainer-directed
  amendment replaces the invalid declaration-level ownership modifier with a
  read-only property whose nonmutating getter borrows the noncopyable sink.
  The positive compiler witness and
  [Specification review](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-1/borrowing-property-specification-blocker.md)
  unblock this declaration family and the dependent SPEC-006 visitor method.
- [x] `T1.2` — Add the host-only `GiftUIMacros` target and exact
      `@ObservableStateHost` macro declaration. Generate only the two named
      members plus state-host conformance; enumerate direct observable
      wrappers once in lexical order, assign `UInt16` ordinals from zero, and
      diagnose more than 65,535 declarations. Snapshot deterministic expansion
      for zero, one, several, private, nested, inherited/non-direct, malformed,
      and overflow-shaped fixtures.
- [x] `T1.3` — Implement `State<Value>` and the noncopyable change sink with
      their exact public source shapes and package-only construction/binding
      facilities. Prove the wrapper has one logical `initial` or bound case,
      consumes rather than retains a repeated initializer after binding, has
      no task-local/global fallback, and preserves the first setter failure in
      the coordinator-owned cycle-local result route.
- [x] `T1.4` — Coordinate with SPEC-006 to add the exact
      `visitStatefulCustomView` visitor operation after T1.1 exists, then make
      the macro synthesize the only supported client traversal override. Prove
      an ordinary custom view remains in `visitCustomView`, a generated host
      enters the stateful category, and handwritten application traversal
      overrides remain unsupported and absent from maintained source.
- [x] `T1.5` — Compile the same portable model, `@State`, and generated host
      source under macOS dynamic/static, ARMv6, and nRF52840 modes. Inspect the
      generated declaration output for deterministic bytes at equal inputs and
      the embedded image closure for no macro/compiler-support linkage.

  **Completed 2026-09-06.** The canonical annotated source and checked-in
  expansion compile as the same optimized target object on all four profiles.
  Each report records generated-source SHA-256
  `02831ec5318c786ef899dcae52c0f82910981af79658f4e81bdb45e8645c862b`;
  target symbol-closure audits reject macro, SwiftSyntax, diagnostic, and
  compiler-plugin linkage. See the
  [four-profile generated-host evidence](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-1/four-profile-generated-host.md).

### Milestone 2: Establish Owner Values and Execution Seams

**Entry conditions:** SPEC-009 has supplied `GiftUIExecution`,
`ObservableTargetGeneration`, `ExecutionAdmissionOutcome`, and the relevant
phase/admission protocols. Until then, this milestone is upstream-blocked.

**Exit evidence:** `GiftUIObservableState` compiles as the one focused owner
with exact local values, protocols, module direction, and no profile storage.

- [ ] `T2.1` — Add `GiftUIObservableState` depending exactly on `GiftUI`,
      `GiftUISemanticCore`, and `GiftUIExecution`. Implement exact
      `ObservableStateLimits`, error, operational, result, and candidate-
      disposition values; exhaust raw values, initializer validation, equal-
      to-limit behavior, `Equatable`/`Sendable`, owned layouts, and every exact
      operation-to-success-result row. Reject `nil`, Boolean, trap, and
      profile-private result substitutes at owner boundaries.
- [ ] `T2.2` — Implement the exact reconciler, mutation-owner, and target-view
      package protocols plus every logical storage field fixed by SPEC-010,
      without selecting concrete runtime packing. Add fixture-only bounded
      structural identity and prove live/publishable target views expose no
      model, attachment, sink, handler, or mutating operation. Account
      independently for location, registration, candidate association,
      replacement staging, and fixed runtime bookkeeping; prove replacement
      borrows one declared staging record rather than permanent duplicate
      registration capacity.
- [ ] `T2.3` — Implement `PresentationFactAdmissionAdapter` as the typed façade
      over SPEC-009 admission. Prove only finite immutable `Sendable` facts
      with no model, callable, task, platform object, or mutable repository
      reference pass; prove no second queue/limit/sequence/result exists and
      refusal never falls back to direct model mutation.
- [ ] `T2.4` — Decide whether sink routing, noncopyable ownership, wrapper
      binding, candidate/live selection, and the mutation-result slot require
      a focused Implementation Design Note. If reconstruction is difficult,
      create `spec-010-binding-and-report-routing.md` without changing the
      public/package contracts or profile authority.

### Milestone 3: Implement Candidate Binding and Structural Reconciliation

**Entry conditions:** The generated host and owner protocols compile; a
fixture-finite reconciler can observe SPEC-006 structural identities.

**Exit evidence:** One complete candidate preserves/materializes/removes
locations atomically and binds every wrapper before its body.

- [ ] `T3.1` — Implement begin/encounter/finish lifecycle, checked capacities,
      active-candidate guard, and staged association storage. Reserve every
      required resource before body evaluation and preserve the first failure.
      Enforce one begin after `.deriving`, exactly one publish/discard finish,
      exact success results, and no ordinary failure path from publication
      after successful reservation; classify invalid entry and impossible
      publication failure exactly.
- [ ] `T3.2` — Implement the state-aware SPEC-006 visitor decorator. Copy the
      transient declaration, visit direct wrappers in generated lexical order,
      bind each successfully, evaluate the body exactly once only after all
      bindings succeed, and retain no declaration/binding after the call.
- [ ] `T3.3` — Implement first materialization, same-key compatible
      preservation, distinct ordinal handling, incompatible association,
      duplicate ownership, staged removal, published retirement, reinsertion,
      failed-derivation discard, and runtime shutdown. Prove repeated
      initializers are consumed without attachment, removal/shutdown synthesize
      no application start/stop lifecycle effect, shutdown detaches every
      installed sink once, and no later report, fact, action, or candidate is
      admitted.
- [ ] `T3.4` — Fault-inject location, registration, association staging,
      duplicate-owner, incompatible-association, `nil`/mismatched attachment
      return, report-during-attach, mismatched detach, and finish invariant
      failures. Prove first-failure preservation, complete candidate discard,
      candidate-only route invalidation/detach, prior-live preservation, exact
      detach behavior, and body suppression for every binding failure.

### Milestone 4: Implement Replacement and Target-Generation Lifetime

**Entry conditions:** Candidate reconciliation owns stable live registrations
and SPEC-009's opaque target value is available.

**Exit evidence:** Initial, replacement, removal, publish, and discard produce
fresh, non-aliasing target generations with exact borrowed lookup timing.

- [ ] `T4.1` — Implement checked runtime-wide attachment-generation allocation
      with raw zero first, no sentinel/reuse/wrap, slot recycling protected by
      the full attachment, and fail-closed initial/replacement exhaustion.
- [ ] `T4.2` — Implement atomic mutation-phase replacement: validate and
      reserve, attach/verify the candidate, commit it, activate its fresh
      generation, detach/retire the former registration, and dirty the
      location. Every precommit failure preserves the former model, route,
      generation, dirtiness, and publication. Prove report-during-attachment
      rejects the candidate even if attach later returns a matching attachment,
      and prove successful replacement remains current and dirty when later
      derivation fails.
- [ ] `T4.3` — Implement live and publishable borrowed target lookup. Enforce
      successful-encounter timing, preserved versus candidate-only results,
      invalid query `nil`, no lazy materialization, and publication making the
      staged generation live.
- [ ] `T4.4` — Prove candidate discard detaches and permanently retires
      candidate-only generations, published removal retires the live value,
      failed/staged replacement preserves the former value, and no lookup
      retains or exposes a model. Couple observable non-publication to mandatory
      Interaction candidate discard and prove a borrowed publishable view
      cannot escape candidate construction.

### Milestone 5: Implement Reporting, Dirtiness, and Mutation Phases

**Entry conditions:** Registrations have active/stale lifetime and the SPEC-009
coordinator supplies phase, wake, publication, and mutation-result seams.

**Exit evidence:** Every synchronous report produces its exact outcome and
mandatory effect with bounded, coalesced state.

- [ ] `T5.1` — Activate the noncopyable sink only after verified attachment;
      implement exact sink/package outcome correspondence, synchronous model
      reporting before a changed mutation returns, one dirty transition,
      repeated coalescing, and proven no-op omission. Keep the registration
      record to bounded route validation rather than a callable sink copy or
      report history.
- [ ] `T5.2` — Integrate one wake intent, complete-root dirty derivation,
      freeze, successful-publication clearing, frame-refusal independence, and
      derivation-failure dirty retention without mutation replay.
- [ ] `T5.3` — Reject reports during attach, candidate state, detach, after
      retirement/slot reuse, outside mutation, across semantic dispatch, and
      after shutdown. Implement contained-phase paced rederivation versus
      safety-not-proven/reentrancy normal-cycle exclusion exactly, including
      preserved last publication, partial-candidate discard, dirty/wake state,
      and the no-residual-policy-call contained row.
- [ ] `T5.4` — Implement the cycle-local mutation-result slot used by bound
      setters and sink failures. Preserve the first failure until synchronous
      coordinator consumption; retain no model, fact, callable, candidate, or
      history and allow no later success to overwrite it. Read and clear the
      slot after each enclosing fact, handler, or test operation before
      derivation; when no cycle is active, route mandatory disposition through
      the owner adapter directly.

### Milestone 6: Realize Equal Dynamic and Static Profiles

**Entry conditions:** Profile-neutral owner behavior and complete shared
transcripts pass. SPEC-013 has supplied authorized runtime-profile targets and
SPEC-015 has supplied host assembly inputs before production realization.

**Exit evidence:** Both profiles satisfy the same finite corpus at equal limits
while the static path remains typed, bounded, and zero-heap.

- [ ] `T6.1` — Implement dynamic and static fixture workspaces behind the same
      owner protocols. Run one canonical corpus covering preservation,
      ordinals, candidate lookup, replacement, removal/reinsertion, stale slot
      reuse, all independent capacity boundaries, initial/replacement
      generation exhaustion, exact success rows, and generation lifetime;
      compare normalized outputs at equal limits.
- [ ] `T6.2` — Exercise twenty reports and the 80-facts-per-second /
      250-millisecond selection workload with exactly one dirty owner, one
      outstanding wake, one complete reevaluation, no correctness history,
      and no replay.
- [ ] `T6.3` — Implement the static typed/fixed storage path with no heap,
      reflection, `Any`, strings, task-local state, arbitrary existential
      registry, tasks, threads, exceptions, Apple Observation, Objective-C, or
      runtime discovery. Measure each finite storage category separately,
      including live locations, registrations, candidate associations,
      replacement staging, fixed bookkeeping, SPEC-009 pending facts, and the
      application-owned model; record bounded attach/detach/report/reconcile
      operation counts and lookup space.
- [ ] `T6.4` — Implement the fixture presentation-fact adapter and same-thread
      versus logically distinct executor cases. Prove ordered later
      application in SPEC-009's fact-before-action order, explicit refusal,
      after-seal/freeze deferral, action-triggered callback deferral, exact
      admission-outcome forwarding, and no direct/reentrant model mutation.

### Milestone 7: Complete Failure Ownership and Mandatory Effects

**Entry conditions:** Every local failure is injectable and mechanical owner /
coordinator effects are observable without diagnostics.

**Exit evidence:** Exhaustive mappings preserve the exact local condition,
scope, containment, mandatory effects, and allowed residual policy rows.

- [ ] `T7.1` — Add the first narrow adapter importing
      `GiftUIObservableState` and `GiftUIFailureCore`; map every candidate,
      replacement, stale, phase, generation, reentrancy, and invariant context
      to the exact SPEC-003 fact after mandatory effects complete.
- [ ] `T7.2` — Exhaust individual and simultaneous failures in SPEC-010's exact
      focused-owner precedence plus the residual-policy table, including rows
      with no policy call. Prove policy cannot weaken containment, narrow scope,
      skip cleanup, retry without a bound, or reinterpret failure as success.
      Verify secondary cleanup failure never replaces the first selected local
      condition and every context-specific scope/containment row is exact.
- [ ] `T7.3` — Run correctness with diagnostics absent and with permitted
      projections enabled/disabled/lost/saturated. Compare identical typed
      results, live sets, generations, dirtiness, wake, and publication state.

### Milestone 8: Produce Four-Profile Resource and Compatibility Evidence

**Entry conditions:** The complete shared corpus and profile workspaces are
stable; no production capacity is invented by this plan.

**Exit evidence:** All four exact driver commands publish comparable immutable
reports with compiler, ABI, resource, transcript, and dependency evidence.

- [ ] `T8.1` — Run pristine macOS dynamic then macOS static profiles; compare
      macro bytes, complete normalized transcripts, local layouts, allocation,
      stack, linked sections, and undefined/forbidden symbols.
- [ ] `T8.2` — Cross-build Raspberry Pi 1 only for
      `armv6-unknown-linux-gnueabihf`; inspect ELF/ABI, dynamic-profile
      dependency closure, stack/heap/linked-size evidence, and compare the
      canonical corpus without
      claiming remote execution or deployment.
- [ ] `T8.3` — Cross-build `nrf52840dk/nrf52840` with the bundled
      `armv7em-none-none-eabi` module and Cortex-M4F hard-float flags. Require
      VFP calling convention, both heaps zero, no allocator/forbidden symbol,
      macro-support exclusion, complete storage/flash/RAM/stack reports, and
      no flashing or connected-board claim.
- [ ] `T8.4` — Compare all profile-independent rows value-for-value and classify
      host execution, compile/link, simulator, and connected evidence exactly.
      Leave connected timing/stack/application claims to the relevant host
      plans unless explicitly authorized later.

### Milestone 9: Audit Conformance and Downstream Integration

**Entry conditions:** Every prior task has reproducible evidence and every
remaining dependency is available through its authoritative owner.

**Exit evidence:** A clause-by-clause report supports the requested lifecycle
transition without overclaiming hardware or downstream application completion.

- [ ] `T9.1` — Audit exact public/package/source surfaces, target graph,
      generated symbols, migration closure, static forbidden dependencies,
      bounds, layouts, and complete OS-001 through OS-012 traceability.
- [ ] `T9.2` — Run SPEC-006 stateful traversal, SPEC-009 execution,
      SPEC-011 action-target, SPEC-013 profile, SPEC-015 host, and SPEC-001
      Signal Analyzer integration seams that are implemented. Record missing
      owners as downstream blockers rather than substitutes.
- [ ] `T9.3` — Use the conformance-reviewer role to produce
      `docs/conformance/spec-010-conformance-report.md`; update status and
      cross-references only through the required human transition gate.

## Design-Note Triggers

- Create a focused binding/report-routing note at `T2.4` only if the
  noncopyable sink, bound wrapper route, and mutation-result ownership are hard
  to reconstruct locally.
- Create a candidate/reconciliation note if live/staged/removal association
  ownership, rollback, and target-generation retirement span enough files or
  profile implementations to obscure the invariant.
- Do not document dynamic/static private packing as architecture. Record it
  only when needed to explain replaceable bounded representation and resource
  evidence.

## Integration and Validation Order

1. Freeze fixture schemas, target direction, and migration inventory.
2. Land `_GiftUIObservableStateHost`, then let SPEC-006 add its exact stateful
   visitor method; only then land the macro-generated traversal witness.
3. Compile portable declarations and deterministic macro output independently
   before adding runtime owner state.
4. Wait for SPEC-009's execution declarations before creating substitutes for
   target generation, phase, wake, or fact admission.
5. Prove candidate reconciliation before replacement; prove generation
   lifetime before Interaction consumes it; prove report mechanics before
   coordinator publication behavior.
6. Establish one complete profile-neutral oracle before comparing dynamic and
   static realizations or production profiles.
7. Run failure/mandatory-effect fixtures without diagnostics before optional
   diagnostic comparisons.
8. Validate macOS dynamic, macOS static, Raspberry Pi ARMv6, and nRF52840 in
   that order. Build and inspect hardware-free targets only; deploy, restart,
   flash, or operate connected hardware only under a later explicit request.
9. Audit downstream SPEC-006/009/011/013/015 and Signal Analyzer integration
   only after each owner exists.

Tasks `T0.1`, `T0.3`, `T0.4`, and `T1.1` through `T1.5` are complete. `T0.2`
remains open only for the execution-dependent `GiftUIObservableState` and
adapter edges that must land with compiling `T2.1` and `T7.1` targets rather
than placeholders. Milestone 2 and later execution-dependent work waits for
SPEC-009's implementation. Profile-neutral fixture work may proceed before
production runtime profiles, but production portions of `T6.*`, assembled
resource claims, and downstream integration wait for ready SPEC-013 and
SPEC-015 implementation plans and their implemented owner seams.

## Risks and Upstream Blockers

### Implementation risks

- Swift macro/plugin dependencies can accidentally enter target images or
  require network/global installation. Pin them in-package, test dependency
  closure, and keep all build support host-only.
- Public protocol witness visibility, noncopyable sinks, consuming attachment,
  and nonmutating property-wrapper setters may lower differently across pinned
  compilers. Compile the exact contract before relying on a host-only result.
- A bound wrapper route can accidentally escape, retain both initializer and
  live model, or become a task-local fallback. Poison lifetimes and audit SIL.
- Candidate cleanup, replacement, and stale-slot reuse can detach a valid
  registration or alias a retired generation. Test every interleaving before
  profile specialization.
- Static typed storage may satisfy semantic fixtures while exceeding assembled
  flash/RAM/stack budgets. Report each category and the full target image;
  never infer production cost from the Spikes.

### Upstream blockers

- SPEC-009 is approved and has a ready implementation plan, but no
  `GiftUIExecution` target. `T2.1` and all phase, wake, admission,
  target-generation, mutation-result, and coordinator work must wait for that
  owner; this plan cannot define aliases or fixture substitutes in production.
- SPEC-006 now supplies the exact stateful visitor method and generated-host
  routing required by completed `T1.4`. Any later compiler conflict in that
  coordinated public underscored surface returns to SPEC-006/SPEC-010 review
  rather than adding a second traversal engine.
- Production dynamic/static profile targets and numeric capacities belong to
  SPEC-013 and SPEC-015. Both Specifications are approved but neither has a
  ready implementation plan or production owner target. Fixture-finite
  conformance work may proceed, but production realization and host claims
  wait for those owners and their normal readiness gates.
- Interaction target binding belongs to SPEC-011. Observable State exposes
  only the borrowed generation views fixed by SPEC-010 and must not import or
  implement Interaction to accelerate integration.

## Deferred and Follow-up Work

- [FW-019](../future-work/fw-019-fine-grained-observable-dependency-tracking.md)
  retains property-level tracking and selective reevaluation. Do not schedule
  it unless its evidence-driven revisit trigger is met.
- Public `Binding`, externally owned observation, multiple owners, reactive
  streams, persistence, lifecycle callbacks, and dynamic closure conveniences
  remain outside this plan under their existing owners or future lifecycle.

## Completion Record

Plan drafted and marked ready on 2026-09-04. At that gate every OS criterion
mapped to ordered code and evidence, independent declaration work was separated
from SPEC-009/013/015 blockers, and no Spike mechanism or downstream contract
was treated as production authority.

Implementation began on 2026-09-04 under the then-approved contract. The
2026-09-05 completeness amendment temporarily returned the feature to
`specification`, the Specification to `review`, and this plan to `draft`.
The maintainer explicitly reapproved the amendment the same day; the
Specification remains `implementing`. On 2026-09-06 the maintainer requested
a completeness review and readiness refresh. That review confirmed the
remaining work is executable; because implementation is already in progress,
the plan remains `active` and completed task dispositions remain unchanged.

`T0.1` is complete: the checked-in
[authority audit](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-0/authority-audit.md)
verifies the accepted/approved lifecycle chain, all twelve acceptance labels,
MVP need, upstream ownership, and the non-authoritative status of both Spikes.
The fixture README, ordered compile and macro schemas, semantic transcript and
normalized-result schemas, and exact pending evidence registry form a
fail-closed baseline validated by the new harness check.

The first T1.1 compile attempt exposed a source-spelling defect in the
normative public contract rather than an implementation defect. On 2026-09-05
the maintainer directed its correction to a compiler-valid read-only getter.
`check-spec-010-attachment-property.sh` proves that the getter borrows without
consuming the noncopyable sink. T1.1 is unblocked and remains unchecked until
the complete declaration family and its profile evidence land.

The subsequent completeness review found missing exact success-result routing,
logical storage fields, attach-time report disposition, focused-owner failure
precedence, and a contradiction over replacement commit timing. SPEC-010 now
closes those gaps without changing accepted architecture. The maintainer
explicitly reapproved the contract on 2026-09-05. Implementation resumed at
T1.2 the same day, returning this plan to `active`.

`T0.3` is complete: the
[registered contract driver](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-0/contract-driver.md)
exposes all four exact profile commands, compiles only the current portable
prerequisite module, and records pinned compiler/target/optimization plus
immutable input/report identity. Every report
contains exactly twelve `missing` acceptance rows and remains explicitly
conformance-incomplete. After the approved getter correction, the two macOS
profiles compile its positive ownership witness and every profile reports the
full public contract as `pending` rather than blocked.

`T0.4` is complete: the checked-in
[migration baseline](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-0/migration-baseline.md)
and exact inventory classify every obsolete PoC state mechanism, direct
thermostat mutation site, absent Apple Observation dependency, and disposable
SPIKE-003/SPIKE-006 spelling. The registered check pins the PoC revision,
reproduces every path/count map, and rejects a legacy compatibility path in
maintained source. `T0.2` now includes the first buildable macro target and
remains intentionally open until the SPEC-009-owned execution target makes the
remaining owner graph changes valid.

`T1.2` is complete: the pinned host-only `GiftUIMacros` target implements the
exact attached declaration, state-host conformance, lexical direct-wrapper
enumeration, zero-based `UInt16` ordinals, accessible witnesses, and the
65,535-declaration boundary. Checked-in macro snapshots cover zero, one,
several, private, nested/non-direct, inherited/non-direct, malformed, and
overflow-shaped cases. Package graph and source audits prove the macro is not a
product and imports only its pinned compiler-support dependencies; see the
[macro generation evidence](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-1/deterministic-host-generation.md).
The macro also emits the already-authorized SPEC-006 stateful traversal witness;
its category behavior remains assigned to dependent T1.4.

`T1.3` is complete: `State<Value>` has exactly one logical `initial(Value)` or
fixed-route `bound` case, and successful package binding replaces and returns
the initializer without retaining both cases. Focused tests prove live reads,
replacement forwarding, repeated-binding refusal, repeated-initializer release,
and first-failure preservation until synchronous coordinator-style consumption.
The noncopyable sink owns exactly one attachment and one report route; an
SIL-generating compiler-negative fixture rejects a second consuming use. The
registered source audit rejects task-local/global fallback, strings, `Any`,
reflection, and legacy state registries; see the
[state and sink ownership evidence](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-1/state-and-sink-ownership.md).
Exact `ObservableStateResult` creation and the production coordinator slot
remain with T2.1/T5.4 after SPEC-009 supplies `GiftUIExecution`.

`T1.4` is complete: SPEC-006's exact borrowed-declaration stateful visitor
operation is present, and `ObservableStateHostMacro` synthesizes the sole
supported client `_giftUITraverse` override. A real annotated view with direct
private state selects `visitStatefulCustomView`, never selects the ordinary
custom category, and evaluates its body through the borrowed declaration.
The registered traversal audit rejects manual application witnesses and a
second traversal requirement; see the
[generated stateful traversal evidence](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-1/generated-stateful-traversal.md).
This closes the SPEC-006 T1.4 dependency.

`T1.5` is complete: one canonical annotated model/host source and its
byte-stable generated expansion compile as optimized target objects for macOS
dynamic, macOS static, Raspberry Pi ARMv6, and nRF52840 Embedded Swift. The
four reports record the same generated-source SHA-256 and reject target-image
macro/compiler-support linkage; see the
[four-profile generated-host evidence](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-1/four-profile-generated-host.md).
The next executable owner task is `T2.1`, blocked only on SPEC-009 supplying
the exact `GiftUIExecution` declarations and package edge identified above.
