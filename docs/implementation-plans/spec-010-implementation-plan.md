---
spec: SPEC-010
feature: observable-reference-state
title: SPEC-010 Implementation Plan
status: ready
owners:
  - codex
created: 2026-09-04
updated: 2026-09-04
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
> Contract. It orders implementation and evidence but does not amend the
> declaration, generation, ownership, mutation, publication, failure, action-
> target, or profile contracts owned by that Specification and its accepted
> dependencies.

## Authority and Scope

The governing contract is approved
[SPEC-010](../specs/spec-010-observable-reference-state.md), under accepted
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

- `GiftUI` contains SPEC-006's portable `View`, builder/wrappers, typed
  semantic payloads, and non-stateful visitor categories. It has no `State`,
  observable model/sink/attachment declarations, or macro declaration.
- SPEC-006 T1.4 is partially implemented and blocked specifically on the
  SPEC-010-owned `_GiftUIObservableStateHost`; its later stateful integration
  milestone also waits for the generated witness and binding seam.
- There is no `GiftUIMacros`, `GiftUIObservableState`, dynamic/static state
  profile, observable-state failure adapter, test target, fixture corpus, or
  `run-spec-010.sh` driver in the package.
- Approved SPEC-009 owns `GiftUIExecution`, `ObservableTargetGeneration`, and
  `ExecutionAdmissionOutcome`, but that target and its implementation plan are
  not present. Work requiring those declarations is blocked until its owner
  supplies them; this plan must not create substitutes.
- SPEC-002's exact target/dependency registry, SPEC-003's failure owner seam,
  SPEC-006's four-profile driver conventions, and repository-local ARMv6/nRF
  toolchains are reusable. Package exact-set controls must change atomically.
- No production dynamic/static runtime targets exist. Profile realizations
  remain jointly gated by SPEC-009, SPEC-013, and host configuration rather
  than being inferred from the completed Spikes.

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

- [ ] `T0.1` — Create `Tests/ContractFixtures/SPEC010/` with an ordered compile
      registry, macro-expansion snapshot schema, semantic transcript schema,
      normalized result schema, required-evidence registry, and README that
      separates host execution, cross-build, simulator, and connected-target
      evidence. Map every `OS-001` through `OS-012` row fail-closed.
- [ ] `T0.2` — Add the approved target/dependency rows for the host-only
      `GiftUIMacros`, `GiftUIObservableState`, its tests, and narrowly named
      owner-adapter fixtures to SPEC-002's exact graph. Prove the macro target
      is neither a product nor in any target-image dependency closure, and
      reject imports of runtimes, Interaction, application models, backends,
      platforms, drivers, OS/RTOS, HAL, or hardware from the owner.
- [ ] `T0.3` — Create and register `scripts/contracts/run-spec-010.sh` with the
      exact four profile names, pinned compiler/SDK/optimization metadata,
      immutable input identity, normalized report schema, command transcript,
      and explicit `missing` evidence rows. The initial driver must compile
      only dependencies that exist and must not claim semantic or hardware
      conformance early.
- [ ] `T0.4` — Inventory every removed PoC `@State`, task-local binding,
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

- [ ] `T1.1` — Implement in `GiftUI` the exact
      `_GiftUIObservableChangeReportOutcome`, `_GiftUIObservableReference`,
      `_GiftUIObservationAttachment`, `_GiftUIObservableStateDeclarationVisitor`,
      and `_GiftUIObservableStateHost` source contracts. Preserve the
      attachment's non-forgeable public boundary and exact raw values; compile
      positive model/host conformances and access-negative clients on all four
      profiles. This task supplies the owner declaration that unblocks the
      SPEC-006 T1.4 visitor signature.
- [ ] `T1.2` — Add the host-only `GiftUIMacros` target and exact
      `@ObservableStateHost` macro declaration. Generate only the two named
      members plus state-host conformance; enumerate direct observable
      wrappers once in lexical order, assign `UInt16` ordinals from zero, and
      diagnose more than 65,535 declarations. Snapshot deterministic expansion
      for zero, one, several, private, nested, inherited/non-direct, malformed,
      and overflow-shaped fixtures.
- [ ] `T1.3` — Implement `State<Value>` and the noncopyable change sink with
      their exact public source shapes and package-only construction/binding
      facilities. Prove the wrapper has one logical `initial` or bound case,
      consumes rather than retains a repeated initializer after binding, has
      no task-local/global fallback, and preserves the first setter failure in
      the coordinator-owned cycle-local result route.
- [ ] `T1.4` — Coordinate with SPEC-006 to add the exact
      `visitStatefulCustomView` visitor operation after T1.1 exists, then make
      the macro synthesize the only supported client traversal override. Prove
      an ordinary custom view remains in `visitCustomView`, a generated host
      enters the stateful category, and handwritten application traversal
      overrides remain unsupported and absent from maintained source.
- [ ] `T1.5` — Compile the same portable model, `@State`, and generated host
      source under macOS dynamic/static, ARMv6, and nRF52840 modes. Inspect the
      generated declaration output for deterministic bytes at equal inputs and
      the embedded image closure for no macro/compiler-support linkage.

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
      to-limit behavior, `Equatable`/`Sendable`, and owned layouts.
- [ ] `T2.2` — Implement the exact reconciler, mutation-owner, and target-view
      package protocols without concrete runtime storage. Add fixture-only
      bounded structural identity and prove live/publishable target views
      expose no model, attachment, sink, handler, or mutating operation.
- [ ] `T2.3` — Implement `PresentationFactAdmissionAdapter` as the typed façade
      over SPEC-009 admission. Prove only finite immutable `Sendable` facts
      pass, no second queue/limit/sequence/result exists, and refusal never
      falls back to direct model mutation.
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
- [ ] `T3.2` — Implement the state-aware SPEC-006 visitor decorator. Copy the
      transient declaration, visit direct wrappers in generated lexical order,
      bind each successfully, evaluate the body exactly once only after all
      bindings succeed, and retain no declaration/binding after the call.
- [ ] `T3.3` — Implement first materialization, same-key compatible
      preservation, distinct ordinal handling, incompatible association,
      duplicate ownership, staged removal, published retirement, reinsertion,
      failed-derivation discard, and runtime shutdown.
- [ ] `T3.4` — Fault-inject location, registration, association staging,
      duplicate-owner, incompatible-association, attach-return mismatch, and
      finish invariant failures. Prove complete candidate discard, candidate-
      only detach, prior-live preservation, and body suppression.

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
      generation, dirtiness, and publication.
- [ ] `T4.3` — Implement live and publishable borrowed target lookup. Enforce
      successful-encounter timing, preserved versus candidate-only results,
      invalid query `nil`, no lazy materialization, and publication making the
      staged generation live.
- [ ] `T4.4` — Prove candidate discard detaches and permanently retires
      candidate-only generations, published removal retires the live value,
      failed/staged replacement preserves the former value, and no lookup
      retains or exposes a model.

### Milestone 5: Implement Reporting, Dirtiness, and Mutation Phases

**Entry conditions:** Registrations have active/stale lifetime and the SPEC-009
coordinator supplies phase, wake, publication, and mutation-result seams.

**Exit evidence:** Every synchronous report produces its exact outcome and
mandatory effect with bounded, coalesced state.

- [ ] `T5.1` — Activate the noncopyable sink only after verified attachment;
      implement exact sink/package outcome correspondence, synchronous model
      reporting, one dirty transition, repeated coalescing, and no-op omission.
- [ ] `T5.2` — Integrate one wake intent, complete-root dirty derivation,
      freeze, successful-publication clearing, frame-refusal independence, and
      derivation-failure dirty retention without mutation replay.
- [ ] `T5.3` — Reject reports during attach, candidate state, detach, after
      retirement/slot reuse, outside mutation, across semantic dispatch, and
      after shutdown. Implement contained-phase paced rederivation versus
      safety-not-proven/reentrancy normal-cycle exclusion exactly.
- [ ] `T5.4` — Implement the cycle-local mutation-result slot used by bound
      setters and sink failures. Preserve the first failure until synchronous
      coordinator consumption; retain no model, fact, callable, candidate, or
      history and allow no later success to overwrite it.

### Milestone 6: Realize Equal Dynamic and Static Profiles

**Entry conditions:** Profile-neutral owner behavior and complete shared
transcripts pass. SPEC-013 has supplied authorized runtime-profile targets and
SPEC-015 has supplied host assembly inputs before production realization.

**Exit evidence:** Both profiles satisfy the same finite corpus at equal limits
while the static path remains typed, bounded, and zero-heap.

- [ ] `T6.1` — Implement dynamic and static fixture workspaces behind the same
      owner protocols. Run one canonical corpus covering preservation,
      ordinals, candidate lookup, replacement, removal/reinsertion, stale slot
      reuse, exhaustion, and generation lifetime; compare normalized outputs.
- [ ] `T6.2` — Exercise twenty reports and the 80-facts-per-second /
      250-millisecond selection workload with exactly one dirty owner, one
      outstanding wake, one complete reevaluation, no correctness history,
      and no replay.
- [ ] `T6.3` — Implement the static typed/fixed storage path with no heap,
      reflection, `Any`, strings, task-local state, arbitrary existential
      registry, tasks, threads, exceptions, Apple Observation, Objective-C, or
      runtime discovery. Measure each finite storage category separately.
- [ ] `T6.4` — Implement the fixture presentation-fact adapter and same-thread
      versus logically distinct executor cases. Prove ordered later
      application, explicit refusal, action-triggered callback deferral, and no
      direct/reentrant model mutation.

### Milestone 7: Complete Failure Ownership and Mandatory Effects

**Entry conditions:** Every local failure is injectable and mechanical owner /
coordinator effects are observable without diagnostics.

**Exit evidence:** Exhaustive mappings preserve the exact local condition,
scope, containment, mandatory effects, and allowed residual policy rows.

- [ ] `T7.1` — Add the first narrow adapter importing
      `GiftUIObservableState` and `GiftUIFailureCore`; map every candidate,
      replacement, stale, phase, generation, reentrancy, and invariant context
      to the exact SPEC-003 fact after mandatory effects complete.
- [ ] `T7.2` — Exhaust the residual-policy table, including rows with no policy
      call. Prove policy cannot weaken containment, narrow scope, skip cleanup,
      retry without a bound, or reinterpret failure as success.
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
      `armv6-unknown-linux-gnueabihf`; inspect ELF/ABI, static-runtime closure,
      stack/heap/linked-size evidence, and compare the canonical corpus without
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

Tasks `T0.1`, `T0.3`, and `T0.4` may proceed together after this plan is ready.
`T1.1` may proceed after `T0.2`; it is the smallest slice that unblocks
SPEC-006. Macro work `T1.2` and `T1.4` is ordered around that coordinated
visitor addition. Milestone 2 and later execution-dependent work waits for
SPEC-009. Profile-neutral fixture work may proceed before production runtime
profiles, but `T6.1` production claims wait for SPEC-013 and SPEC-015 owners.

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

- SPEC-009 is approved but has no implementation plan or `GiftUIExecution`
  target. T2.1 and all phase, wake, admission, target-generation, and
  coordinator work must wait for that owner; this plan cannot define aliases.
- SPEC-006 must accept the exact stateful visitor method after T1.1. Any
  compiler conflict in that coordinated public underscored surface returns to
  SPEC-006/SPEC-010 review rather than adding a second traversal engine.
- Production dynamic/static profile targets and numeric capacities belong to
  SPEC-013 and SPEC-015. Fixture-finite conformance work may proceed, but
  production realization and host claims wait for those owners.
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

Plan drafted on 2026-09-04. No implementation task is credited complete by
the planning artifact. The plan is ready because every OS criterion maps to
ordered code and evidence, independent declaration work is separated from
SPEC-009/013/015 blockers, and no Spike mechanism or downstream contract is
treated as production authority.
