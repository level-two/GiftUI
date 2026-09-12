---
spec: SPEC-013
feature: giftui-mvp-architecture
title: SPEC-013 Implementation Plan
status: active
owners:
  - codex
created: 2026-09-09
updated: 2026-09-12
related_design_notes: []
conformance_report: null
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-003
  - SPIKE-004
  - SPIKE-007
  - SPIKE-008
supersedes: null
superseded_by: null
---

# SPEC-013 Implementation Plan

> This plan is `active`. The focused render-workspace-limit amendment to
> SPEC-013 was explicitly reapproved on 2026-09-12, the plan's separate
> readiness transition was explicitly requested on 2026-09-12, and authorized
> implementation began with T0.1 on 2026-09-12.

## Authority and Scope

The governing [SPEC-013](../specs/spec-013-runtime-profiles.md) is approved,
including the coordinated render-workspace limit addition. Its Proposal, RFC,
and accepted-ADR chain fixes one portable semantic meaning,
the module graph, checked geometry, serialized execution, observable-state and
interaction lifetimes, scoped Canvas production, bounded failures, and static
restrictions. In particular, accepted
[ADR-006](../adrs/adr-006-shared-semantics-runtime-profiles.md),
[ADR-008](../adrs/adr-008-module-dependency-graph-and-package-topology.md),
[ADR-009](../adrs/adr-009-checked-integer-geometry.md),
[ADR-010](../adrs/adr-010-synchronous-one-shot-frame-handoff.md) through
[ADR-012](../adrs/adr-012-bounded-handoff-refusal-recovery.md),
[ADR-014](../adrs/adr-014-bounded-cross-layer-outcomes.md) through
[ADR-016](../adrs/adr-016-non-authoritative-diagnostics.md),
[ADR-024](../adrs/adr-024-structurally-owned-observable-reference-state.md)
through [ADR-026](../adrs/adr-026-profile-equivalent-bounded-observable-state.md),
[ADR-028](../adrs/adr-028-post-layout-canvas-derivation-and-cycle-local-plan.md),
[ADR-029](../adrs/adr-029-scoped-transient-path-snapshot-semantics.md),
[ADR-031](../adrs/adr-031-bounded-canvas-failure-and-startup-gate-integration.md),
[ADR-032](../adrs/adr-032-semantic-core-owned-layout-input.md), and
[ADR-033](../adrs/adr-033-bounded-application-actions-and-model-target-dispatch.md)
are implementation authority. ADR-013 is superseded history and is not an
implementation input.

The [MVP Scope](../MVP_SCOPE.md) requires the same portable Signal Analyzer
Presentation across macOS dynamic, macOS static, Raspberry Pi 1/Linux dynamic,
and nRF52840 static configurations. SPEC-013 supplies the two finite runtime
profiles that coordinate the approved focused contracts and prove equivalent
observable behavior across those stacks. It does not implement concrete
backends or hosts, choose Wave 7 capacities, deploy to Raspberry Pi, or flash
an nRF52840-DK.

Completed SPIKE-003, SPIKE-004, SPIKE-007, and SPIKE-008 are feasibility and
declaration evidence only. Their code, layouts, and capacity choices do not
override the approved contract.

## Current Repository State

- `GiftUI`, `GiftUISemanticCore`, `GiftUITextResources`, `GiftUILayout`,
  `GiftUIRenderCore`, `GiftUIRenderLowering`, `GiftUIExecution`, and
  `GiftUIObservableState` exist. SPEC-006, SPEC-007, and SPEC-008 are
  implemented with completed plans and conformance evidence. Their production
  semantic, borrowed-layout, render-workspace, and render-extension seams are
  available to SPEC-013.
- `GiftUIDrawing` also exists. SPEC-012 is implementing: Milestones 0 through
  5 and generator tasks `T6.1`-`T6.3` are complete, while profile-owned
  callable storage, host handles, startup/cycle integration, and final
  cross-profile evidence remain explicitly joined to SPEC-013 and SPEC-015.
- `GiftUIInteraction` does not yet exist and SPEC-011 has a ready plan.
  SPEC-009 and SPEC-010 have active plans and substantial focused-owner
  machinery, but their remaining production runtime integration is
  intentionally assigned to SPEC-013. Tasks consuming unfinished owner seams
  must wait for them; runtime code must not create substitutes or duplicate
  their algorithms. The cross-plan handoffs below separate focused-owner work
  that can land first from coordinator/profile integration that must land with
  SPEC-013.
- `Package.swift` has no `GiftUIRuntimeCore`, `GiftUIRuntimeDynamic`,
  `GiftUIRuntimeStatic`, runtime failure-adapter fixture, or runtime test
  targets. Proof-of-concept runtime sources and tests were deliberately
  removed under SPEC-002 and remain historical migration evidence only.
- `Tests/ContractFixtures/SPEC013/`, `scripts/contracts/run-spec-013.sh`, and a
  SPEC-013 driver-registry row are absent. Existing SPEC-002 through SPEC-010
  and SPEC-012 fixtures provide reusable fail-closed manifests, import checks,
  normalized transcripts, allocation interposition, report metadata,
  cross-build, ELF, and dirty-revision conventions.
- Existing exact-set boundary registries treat the absent runtime modules as
  forbidden or future owners. Those rows must be changed atomically with the
  first compiling targets so a stale negative fixture cannot masquerade as a
  conformance result.
- SPEC-014 and SPEC-015 are approved. SPEC-014 supplies
  production endpoints and SPEC-015 supplies assembled limits and host policy;
  neither may be pulled into `GiftUIRuntimeCore` or used to choose values here.

## Readiness Review

**Reviewed:** 2026-09-12

**Disposition:** Ready. Every linked ADR remains
accepted, SPEC-013 and coordinated SPEC-015 were explicitly reapproved on
2026-09-12, and all fifteen acceptance criteria map exactly once. The plan now
incorporates the new `RuntimeProfileLimits.renderWorkspace` leaf, storage
equality checks, and exact boundary evidence.
The readiness audit also reconciled the ready SPEC-011 and SPEC-012 plans:
focused Interaction and Drawing contracts land under their owners, profile
storage lands under SPEC-013, and the mutually dependent coordinator joins
have an explicit integration handoff rather than a circular prerequisite.
Missing focused-owner implementations remain task dependencies rather than
missing design decisions. The plan is executable in its stated dependency
order without inventing architectural or contractual intent.

No `docs/features.yaml` update is required. Implementation records are not
registered there, and `giftui-mvp-architecture` already reports the
implementation stage. SPEC-013 is `approved`, and this derived plan is now
`ready`.

If a pinned compiler cannot express the noncopyable storage/coordinator
contracts, the 2-byte `RuntimeOwnerFailure`, scoped borrows, generated static
Canvas dispatch, or a zero-allocation static path, the affected work returns
to Specification or architecture review. The implementation must not add a
generic profile failure, heap-backed static fallback, second semantic/layout/
render engine, retained frame or Canvas plan, retry queue, profile query in
portable source, or dependency on backend/host identity.

## Task Dependencies and Affected Surfaces

Milestone numbers define the default order. A task starts only after every
listed prerequisite is satisfied.

| Work | Prerequisites | Primary affected surfaces | Parallel boundary |
| --- | --- | --- | --- |
| `T0.1`-`T0.4` | Reapproved SPEC-013 authority chain | `Tests/ContractFixtures/SPEC013/`, `Package.swift`, boundary registries, `scripts/contracts/` | Schemas, migration inventory, and driver scaffolding may proceed together after the acceptance registry exists; package exact-set edits land with compiling targets |
| `T1.1`-`T1.5` | `T0.2`; focused limit declarations from SPEC-006 through SPEC-012 as available | `Sources/GiftUIRuntimeCore/`, core tests, validation fixtures | Value families and checked audit arithmetic may proceed independently; aggregate validation and protocol conformance follow exact declarations |
| `T2.1`-`T2.5` | `T1.*`; completed SPEC-009 execution seams and recording substitutes for unfinished owners | common coordinator, lifecycle, failure adapter, cycle fixtures | Phase orchestration and cleanup tables may be tested with focused recording owners; production adaptation waits for each owner |
| `T3.1`-`T3.5` | `T1.*`, relevant `T2.*`, production SPEC-006/007/008/010 seams, SPEC-011 `T1`-`T4`, and SPEC-012 `T1`-`T5` | `GiftUIRuntimeDynamic`, dynamic tests and probes | Independent dynamic storage families may be implemented together after audit ownership and reset lifetimes freeze; SPEC-011/012 coordinator joins land through the handoffs below |
| `T4.1`-`T4.6` | `T1.*`, relevant `T2.*`, generated SPEC-010 metadata, SPEC-011 `T1`-`T4`, SPEC-012 `T1`-`T5`, and the SPEC-012 `T6.1`-`T6.3` generator contract | `GiftUIRuntimeStatic`, generator integration, static tests and probes | Generated-contract work and fixed storage may proceed together; the integrated coordinator follows complete generated metadata |
| `T5.1`-`T5.5` | `T2.*`-`T4.*`; all focused production owners present | shared integration corpus, runtime/profile tests, owner adapter | Owner integrations may land by stage order, but finalization and equivalence use one frozen transcript vocabulary |
| `T6.1`-`T6.6` | Complete coordinators and fixture vocabulary | limits, failure, borrow, handoff, quiescence, differential fixtures | Corpus families may run independently; differential comparison consumes both complete macOS reports |
| `T7.1`-`T7.5` | `T1`-`T6`; pinned local/cross toolchains | contract driver, instrumentation, resource and ELF reports | Four hardware-free modes may run independently after the corpus freezes; normalized/resource summaries consume all reports |
| `T8.1`-`T8.4` | All applicable implementation and evidence tasks; SPEC-014/015 only for assembled integration rows | downstream integration, repository gates, plan and conformance report | Boundary audits may precede host assembly; production host and connected-hardware claims remain downstream |

### Cross-Plan Handoffs

These handoffs break the apparent cycles between focused owners and the
runtime coordinator without moving ownership or permitting fixture substitutes
to satisfy production tasks.

| Owner plan | Owner work that lands before SPEC-013 integration | SPEC-013 consuming/joint work | Return integration |
| --- | --- | --- | --- |
| [SPEC-011](spec-011-implementation-plan.md) | `T1.*`-`T4.*` establish the public surface, semantic payload, candidate/committed store behavior, and hit resolution | SPEC-011 `T5.*`-`T6.*` and SPEC-013 `T3.2`-`T5.5` jointly land profile storage, publication/dispatch coordination, and exact failure integration | SPEC-011 `T7.1`-`T7.3` and `T8.*` consume the landed Runtime Core/profile seam for production and evidence claims |
| [SPEC-012](spec-012-implementation-plan.md) | `T1.*`-`T5.*` establish Canvas/Path declarations, Drawing contracts, plan production, and combined streaming; `T6.1`-`T6.3` establish the generated callable contract and rejection rules | SPEC-012 `T6.5` and SPEC-013 `T3.2`-`T4.6` jointly land bounded dynamic/static callable storage, generated-metadata integration, audit, dispatch lifetime, and zero-allocation profile behavior | SPEC-012 `T6.4`, `T7.*`, and `T9.*` consume the landed profile seam for host handles, startup gates, cycle disposition, and cross-profile evidence |
| SPEC-014 / SPEC-015 | Focused endpoint and host contracts may be implemented independently of Runtime Core where their plans permit | `T8.2` joins only their production seams; no endpoint, host policy, or numeric capacity enters Runtime Core | Their assembled-profile and host evidence consumes SPEC-013 reports after the local profile corpus is complete |

## Acceptance-Criterion Matrix

The criterion text remains authoritative in SPEC-013. Every criterion appears
exactly once below.

| Criterion | Implementation tasks | Evidence | Status |
| --- | --- | --- | --- |
| `RP-001` — Both runtime targets use one portable root and focused owners without sibling/backend imports | `T0.2`, `T3.5`, `T4.6`, `T8.1` | Package graph, source-import audit, same-root positive compile, and forbidden-import negatives | pending |
| `RP-002` — One successful audit accounts exactly for every correctness store and configured render-workspace capacity | `T1.2`-`T1.4`, `T3.2`, `T4.2`, `T6.1` | Field ownership registry, four-field capacity equality, exact byte reports, checked-total tests, and overlap/overlay audit | pending |
| `RP-003` — Invalid configurations and static tables fail before client/endpoint use | `T1.1`-`T1.5`, `T4.3`, `T6.2` | Ordered startup-failure and exact SPEC-003 mapping corpus with poisoned client, callback, policy, and endpoint probes | pending |
| `RP-004` — Exact stage order, pre-body binding, Canvas release, and cleanup rows | `T2.1`-`T2.4`, `T5.1`-`T5.5`, `T6.3` | Stage transcript, injected-failure cleanup matrix, and release/finalization counters | pending |
| `RP-005` — Value-equal cross-profile semantic through disposition transcripts | `T0.1`, `T5.5`, `T6.6`, `T7.4` | Canonical tagged transcripts and zero-tolerance differential comparison | pending |
| `RP-006` — Exact-limit success and deterministic first-excess for every store | `T3.2`, `T4.2`, `T6.1` | Table-driven boundary corpus and high-water reports for every storage family | pending |
| `RP-007` — Failed derivation never replays effects and clears attempt/candidate storage | `T2.3`, `T3.3`, `T4.4`, `T6.3` | Replay-poisoning scripts, mutation counters, reset counters, and residual-state audit | pending |
| `RP-008` — Accepted handoff alone commits routing | `T2.2`, `T5.4`, `T6.4` | Accepted/refused/failed offer matrix with prior/candidate routing snapshots | pending |
| `RP-009` — Refusal recovery retains only constant-space presentation intent | `T2.2`, `T3.3`, `T4.4`, `T6.4` | Repeated-refusal high-water, pending-intent, and no-retained-payload evidence | pending |
| `RP-010` — Static generation, complete callable dispatch, destruction, zero allocation, and forbidden-facility exclusion | `T4.1`-`T4.6`, `T6.5`, `T7.2`-`T7.3` | Typed-source negatives, table coverage, capture destruction, allocation, symbol, SIL, and ELF reports | pending |
| `RP-011` — Dynamic conveniences stay outside `GiftUI` and preserve portable results | `T3.4`, `T6.6`, `T8.1` | Product/import audit and baseline-versus-convenience transcript comparison | pending |
| `RP-012` — Dependency, typed-source, borrow-poisoning, and generated coverage tests pass | `T0.2`, `T4.3`, `T6.5`, `T8.1` | Negative compile suite, lifetime probes, exact generated-case coverage, and graph checks | pending |
| `RP-013` — Reproducible resource and timing evidence under pinned toolchains | `T7.1`-`T7.5`, `T8.3` | Two pristine builds per profile with compiler/SDK/target, stack, allocation, section, timing, and digest reports | pending |
| `RP-014` — Interaction binds the exact publishable target generation and discards candidate-only generations | `T5.3`-`T5.4`, `T6.3`-`T6.4` | Initial/replacement/discard generation transcripts and committed-state preservation checks | pending |
| `RP-015` — Exact focused owner failures survive generic carrier, mapping, cleanup, and comparison | `T1.5`, `T2.4`, `T5.5`, `T6.3`, `T6.6` | 2-byte layout proof, per-owner injected failure corpus, correlated fact/disposition records, and differential report | pending |

## Milestones and Tasks

### Milestone 0: Freeze Boundaries, Fixtures, and Driver Shape

**Entry conditions:** SPEC-013 is reapproved and its Proposal/RFC/ADR chain
remains authoritative.

**Exit evidence:** The exact target graph, acceptance registry, fixture and
report schemas, migration inventory, and fail-closed driver skeleton exist
before profile behavior is claimed.

- [x] `T0.1` — Create `Tests/ContractFixtures/SPEC013/` with an ordered fixture
      manifest, README, artificial-limit schema, canonical tagged transcript,
      acceptance/evidence registry, and report schema. Distinguish host run,
      cross-build/inspection, simulator, and connected-hardware evidence.
- [ ] `T0.2` — Record the exact permitted imports for `GiftUIRuntimeCore`,
      `GiftUIRuntimeDynamic`, `GiftUIRuntimeStatic`, and the sibling failure
      adapter. Update the existing SPEC-002 through SPEC-010 and SPEC-012
      exact-set registries and stale negative fixtures atomically with the
      first compiling targets; add bidirectional sibling/backend/host
      forbidden-import tests.
- [ ] `T0.3` — Create a SPEC-013 migration inventory covering every removed
      proof-of-concept runtime/store/test path and assign each concept to
      replace-through-owner, evidence-only, or retire. Reject compatibility
      shims and any second semantic, layout, rendering, state, or hit-map path.
- [ ] `T0.4` — Add a fail-closed `run-spec-013.sh` skeleton with the four exact
      profile modes and register it explicitly in `driver-registry.tsv` and
      `scripts/test.sh`. Missing toolchains, fixtures, targets, required fields,
      or commands report blocked/failure and are never silently skipped.

### Milestone 1: Runtime-Core Values, Limits, Audit, and Failure Carrier

**Entry conditions:** `T0.1` and `T0.2` are complete; each referenced focused
limit type is supplied by its owning module before production compilation.

**Exit evidence:** Runtime Core compiles with exact package SPI, ordered
validation, checked non-overlapping audit totals, and the bounded focused
failure carrier, independent of concrete profile storage.

- [ ] `T1.1` — Implement the exact `RuntimeProfileKind`,
      `RuntimeProfileLimits`, validation error/result, and initializer
      relations in `GiftUIRuntimeCore`, including the four-field
      `renderWorkspace` value. Test each valid edge, each relation,
      `staticCanvas` iff `.static`, zero ordinary drawing-only fixtures, and
      first-failure ordering without clamping or deriving render structural
      values from SPEC-006 node/depth limits.
- [ ] `T1.2` — Implement `RuntimeStorageAudit` checked byte accounting and a
      fixture storage-family registry naming exclusive ownership, simultaneous
      lifetimes, overlay charging, exclusions, and dynamic bookkeeping. Test
      every field, overflow, double-count rejection, and exact total.
- [ ] `T1.3` — Implement storage-capacity validation in the six mandated steps:
      focused limits, cross-relations, presence including the render workspace,
      sufficiency and exact render-workspace capacity equality,
      representability, then static Canvas metadata. Poison client body,
      Canvas, attachment, admission, wake, policy, and endpoint seams to prove
      startup purity.
- [ ] `T1.4` — Implement the noncopyable `RuntimeProfileStorage` contract,
      structural identity, successful-audit retention, and reset legality.
      Test capacity immutability, attempt-versus-all reset boundaries, rejected
      construction, and before-use/after-quiescence all-storage reset.
- [ ] `T1.5` — Implement exact `RuntimeOwnerFailure` cases and the coordinator
      protocol surface. In the sibling adapter that alone imports Runtime Core
      and SPEC-003 failure authority, map every `RuntimeProfileValidationError`
      to the specified condition, origin, scope, and containment and preserve
      each focused owner value through execution correlation. Prove
      `RuntimeOwnerFailure` is at most 2 bytes on every compiler, the two
      mapping tables are total, and Runtime Core imports neither
      `GiftUIFailureCore` nor `GiftUIFailureExecution`.

### Milestone 2: Common Coordinator, Lifecycle, and Cleanup Oracle

**Entry conditions:** Milestone 1 is complete; SPEC-009 production admission,
phase, wake, offer, and finalization seams are available. Recording focused
owners may stand in only where the production owner is not yet implemented.

**Exit evidence:** One common coordinator oracle realizes the exact state
machine, stage order, first-failure rule, cleanup table, routing transaction,
and quiescence behavior without profile-private semantics.

- [ ] `T2.1` — Implement common construction and lifecycle states
      `unvalidated -> validated -> idle <-> active -> quiescent -> torn down`,
      exclusive opportunity acquisition, reentry failure, retained immutable
      audit/context, and serialized admission/opportunity entry points.
- [ ] `T2.2` — Compose SPEC-009 admission, at-most-once mutation, candidate
      frame/revision allocation, one-shot offer, accepted-only routing commit,
      constant-space pending intent, refusal convergence, and finalization.
      Use recording seams until production focused owners land.
- [ ] `T2.3` — Encode the normative stage-order and cleanup matrix as shared
      coordinator behavior and a table-driven oracle. Prove earlier failures
      skip later fallible work, applied mutation is never replayed, begun
      candidates discard exactly once, and every acquired workspace resets.
- [ ] `T2.4` — Preserve the first exact focused failure through SPEC-009's
      generic carrier, correlated SPEC-003 fact, mandatory disposition, and
      residual-policy input. Cleanup failures remain secondary except where
      their owner widens containment; diagnostics cannot affect results.
- [ ] `T2.5` — Implement synchronous idempotent `quiesce()`: refuse new work,
      cancel pointer sources, finish only mandatory active-cycle containment,
      detach registrations, release queues/routing, and prohibit new cycle,
      offer, handler, or diagnostic calls.

### Milestone 3: Dynamic Profile Storage and Coordinator

**Entry conditions:** Milestones 1 and relevant Milestone 2 seams are complete;
the focused production owners consumed by each task are available.

**Exit evidence:** `GiftUIRuntimeDynamic` provides bounded heap-backed storage
and the shared coordinator semantics without importing Static or a backend.

- [ ] `T3.1` — Add `GiftUIRuntimeDynamic` and focused test targets with only
      permitted dependencies. Implement one validated structural identity and
      typed construction path; no target or portable Presentation gains a
      profile-selection branch.
- [ ] `T3.2` — Implement bounded dynamic live, published, candidate, queue,
      sealed-batch, pointer, layout, render, drawing-plan, observable,
      Interaction, coordinator, and failure stores. Enforce configured logical
      limits despite spare heap and report exact owned bytes plus allocator
      bookkeeping separately.
- [ ] `T3.3` — Implement exclusive acquisition and exact attempt/all reset
      behavior, candidate/committed separation, refusal intent retention, and
      quiescent teardown. Add deinitialization and release counters without
      making them common correctness dependencies.
- [ ] `T3.4` — Consume SPEC-012's callable and invocation contracts to implement
      the bounded profile-owned dynamic Canvas closure wrapper in
      `GiftUIRuntimeDynamic`, plus the separate `GiftUIDynamicConveniences`
      product. Do not recreate Drawing's plan or invocation algorithms.
      Release every occurrence once immediately after invocation; prove
      conveniences lower to portable contracts and produce identical fixture
      transcripts.
- [ ] `T3.5` — Bind the dynamic stores to the common coordinator and production
      focused owners. Audit that Dynamic does not duplicate their algorithms,
      import Static, inspect a backend/host, or retain borrowed payloads.

### Milestone 4: Static Generation, Storage, and Coordinator

**Entry conditions:** Milestones 1 and relevant Milestone 2 seams are complete;
the SPEC-010 and SPEC-012 generated contracts and all consumed focused owner
seams are available.

**Exit evidence:** `GiftUIRuntimeStatic` uses only fixed/generated/inline or
caller-supplied typed storage, complete static tables, zero heap allocation,
and the same coordinator semantics.

- [ ] `T4.1` — Integrate SPEC-010's observable-slot generation and SPEC-012
      `T6.1`-`T6.3`'s deterministic Canvas generator contract with the static
      runtime build. Produce the profile-owned generated metadata and storage
      bindings for observable slots, action specialization, callable IDs,
      exact capture layouts, and complete switch tables. Record source
      provenance, stable regeneration, checked IDs, and generated-code-size
      reporting without defining a second generator grammar.
- [ ] `T4.2` — Implement fixed static storage for every audit family with exact
      capacities, structural identity, high-water counters, exclusive attempt
      ownership, reset rules, and checked byte totals. No unrelated store may
      donate spare capacity.
- [ ] `T4.3` — Implement `StaticCanvasCallableTable` validation: nonzero bounded
      case count, exact `1...count` coverage once, exact capture sizes, and
      startup rejection. Add build negatives for unsupported capture source
      and runtime invariant tests for zero/range/size mismatch before body or
      Canvas invocation.
- [ ] `T4.4` — Implement inline Canvas capture staging, one complete dispatch
      table, immediate exactly-once destruction after invocation, and cleanup
      after typed throws. Prove no source closure, fallback box, capture, Path,
      or plan survives its contract boundary.
- [ ] `T4.5` — Bind fixed stores and generated tables to the common coordinator
      and focused owners with zero allocation during construction and every
      later operation. Scan source, SIL, symbols, and linked images for every
      forbidden static facility named by SPEC-013.
- [ ] `T4.6` — Add macOS-static and nRF embedded compile/link fixtures proving
      the same portable root, no Dynamic import, no backend/host dependency,
      Embedded Swift restrictions, exact value layouts, and hard-float-ready
      generated declarations.

### Milestone 5: Production Focused-Owner Integration

**Entry conditions:** Both profile realizations compile; SPEC-006 through
SPEC-012 production seams used by each task are implemented. Recording seams
cannot satisfy this milestone's production claims.

**Exit evidence:** Both profiles execute one shared complete pipeline with
identical owner values and no duplicate algorithm or vocabulary.

- [ ] `T5.1` — Integrate state binding before body, SPEC-010 candidate begin/
      encounter/finish, SPEC-006 state-aware expansion, and borrowed SPEC-007
      layout input/output. Preserve published state and dirty recovery on all
      prepublication failures.
- [ ] `T5.2` — Integrate post-layout SPEC-012 Canvas invocation/Path snapshots,
      immediate callable/capture release, plan formation, combined SPEC-008/
      SPEC-012 preflight, painter-order streaming, and synchronous endpoint
      borrowing without retained payloads.
- [ ] `T5.3` — Integrate SPEC-011 candidate construction in semantic order with
      the exact SPEC-010 publishable target generation after encounter and
      reserved SPEC-009 action generations. Test initial materialization,
      preservation, replacement, and candidate-only retirement.
- [ ] `T5.4` — Integrate atomic semantic/observable publication, unchanged-
      presentation recovery, at-most-once endpoint offer, accepted-only action/
      hit-map commit, every other result's candidate discard, and prior
      committed routing preservation.
- [ ] `T5.5` — Integrate exact Semantic, Layout, Observable State, Interaction,
      and Drawing errors through `RuntimeOwnerFailure` and the sibling failure
      adapter. Compare exact value/context, correlation, cleanup, disposition,
      policy input, and returned result across both profiles.

### Milestone 6: Boundary, Failure, Lifetime, and Differential Corpus

**Entry conditions:** Milestone 5 is complete and the canonical transcript
schema is frozen.

**Exit evidence:** The shared suite covers all limits, lifecycle transitions,
cleanup rows, borrows, offers, generations, and equal results with zero
semantic tolerance.

- [ ] `T6.1` — Run exact-limit and first-excess cases for every contained limit
      and every physical storage family. Record limits, concrete capacities,
      audit fields, high-water counts, allocator bookkeeping, and deterministic
      failure identity.
- [ ] `T6.2` — Run startup missing/small/overflow/incompatible/table-invalid
      cases in exact detection order, verify each exact SPEC-003 condition,
      origin, scope, and containment mapping, and use poison probes proving no
      client, attachment, input, wake, policy, backend, or endpoint use.
- [ ] `T6.3` — Inject every focused failure at every stage and verify the exact
      cleanup row, first-error precedence, no effect replay, candidate discard,
      callable/capture release, dirty state, finalization, and wake behavior.
- [ ] `T6.4` — Exercise accepted/refused/failed endpoint outcomes, retry
      exhaustion, backpressure, late admission, reentrancy, coalesced wake,
      pointer cancellation, committed-routing preservation, constant-space
      recovery, and idle/active quiescence.
- [ ] `T6.5` — Add borrow-poisoning and typed-source negatives covering Canvas,
      Path, plan, operations, glyphs, resources, actions, model access,
      endpoint storage, generated tables, forbidden static types/facilities,
      and dependency direction. Prove exact coverage for both the generated
      observable-slot table and generated Canvas callable table.
- [ ] `T6.6` — Run both profiles against identical roots, resources, limits,
      initial models, facts, pointers, capabilities, endpoint scripts, and
      policy. Compare every SPEC-013 observable field value-for-value while
      explicitly excluding addresses, private bytes, allocation strategy,
      generated-code addresses, and diagnostic volume.

### Milestone 7: Four-Profile Resource and Timing Evidence

**Entry conditions:** The common corpus is frozen; all hardware-free toolchain
checks needed by a profile are available under repository-local `.toolchains/`.

**Exit evidence:** All four exact driver modes produce reproducible,
truthfully scoped reports containing every required metadata and resource
field.

- [ ] `T7.1` — Complete `run-spec-013.sh` so every report records revision and
      dirty state, compiler/SDK/target, complete command, limits, audit,
      high-water counts, transcript digest, fixture pass/fail, and evidence
      classification. Preserve the exact standalone invocations.
- [ ] `T7.2` — Add allocation, peak-heap, stack-by-stage, value-layout, symbol,
      borrow-lifetime, section-size, generated-code, greatest-capture, and
      timing instrumentation. Report excluded text/capability/backend/host
      bytes and dynamic allocator bookkeeping separately.
- [ ] `T7.3` — Run static forbidden-symbol/facility scans, prove zero heap, and
      inspect nRF ELF attributes for Cortex-M4F hard-float calling convention.
      Inspect Raspberry Pi artifacts for exactly
      `armv6-unknown-linux-gnueabihf`, rejecting ARMv7/AArch64 substitution.
- [ ] `T7.4` — Run macOS dynamic/static and hardware-free Raspberry Pi/nRF
      modes from two pristine builds, compare transcript digests and resource
      reports, and explain any permitted private/layout variance. Cross-build
      evidence must never be labeled connected-board execution.
- [ ] `T7.5` — Run the shared small fixture and approved Signal Analyzer
      fixture timing/resource workloads when their portable source and exact
      Wave 7 configuration are available. Record a blocked disposition rather
      than inventing production capacities before SPEC-015's owning
      implementation generates and validates them.

### Milestone 8: Downstream Integration and Conformance Preparation

**Entry conditions:** Milestones 0 through 7 have checkable dispositions;
SPEC-014/015 production seams are available for rows that consume them.

**Exit evidence:** Repository gates pass, downstream contracts consume the
runtime seam without ownership leakage, and a SPEC-013 conformance report is
ready for independent review.

- [ ] `T8.1` — Audit `Package.swift`, public/package interfaces, source imports,
      generated source, fixture registries, and product graphs. Prove `GiftUI`
      exposes no profile API, profiles do not import each other or concrete
      backend/host modules, and owner algorithms remain in focused targets.
- [ ] `T8.2` — Integrate SPEC-013's profile construction/audit/coordinator seam
      with SPEC-014 recording/production endpoints and SPEC-015 host
      configuration only through their approved contracts. Keep numeric
      capacities, policy, facilities, and connected hardware outside Runtime
      Core.
- [ ] `T8.3` — Run `scripts/format-swift.sh`, focused unit suites, SPEC-013's
      four exact driver modes, dependency/governance checks, and the repository
      local gate. Preserve stable reports under `Tests/ContractFixtures/SPEC013/Evidence/`.
- [ ] `T8.4` — Create `docs/conformance/spec-013-conformance.md`, map every RP
      criterion to reproducible evidence, distinguish hardware-free from
      connected-target results, record deviations/exceptions, and request the
      human `implemented` transition only after conformance review.

## Design-Note Triggers

- Create `spec-013-storage-audit-and-overlay-ownership.md` if concrete storage
  uses overlays or if byte ownership cannot be reconstructed directly from
  local types and the audit registry. The note may explain packing and checked
  summation but cannot change audit fields or capacity relations.
- Create `spec-013-common-coordinator-and-cleanup.md` before production
  integration if the stage machine, borrowed owner calls, and cleanup table
  span enough types that exact first-failure and reset behavior is difficult to
  review locally.
- Create `spec-013-static-generation-and-capture-lifetime.md` for generator
  inputs, deterministic IDs, fixed capture layouts, dispatch coverage, and
  destruction mechanics once the SPEC-012 production generation seam exists.
  It must not select unsupported-capture semantics or a heap fallback.

No note is required for mechanical target registration, fixture manifests,
straightforward value declarations, or report wiring.

## Integration and Validation Order

1. Freeze fixture schemas, import boundaries, and the migration baseline.
2. Implement and test Runtime Core values, limits, audits, protocols, and the
   focused failure carrier before either concrete profile.
3. Prove common lifecycle, sequencing, cleanup, routing, and quiescence against
   recording focused owners.
4. Implement dynamic and static storage independently against that seam;
   validate each profile locally before connecting production owners.
5. Integrate focused production owners in normative stage order. A missing
   owner blocks only tasks that consume it; it never authorizes a substitute.
6. Freeze and run the shared failure/lifetime/differential corpus on macOS.
7. Run four hardware-free profile modes and resource/ELF inspection under
   pinned toolchains, then run downstream endpoint/host assembly.
8. Collect connected Raspberry Pi and nRF52840 evidence later under the owning
   host/backend plans and only after an explicit request for remote deployment
   or flashing. Hardware-free builds do not satisfy connected-hardware claims.

## Risks and Upstream Blockers

### Implementation risks

- Aggregate generic types and noncopyable borrows may create excessive compile
  complexity or compiler-specific layouts. Keep the common coordinator split
  by contract stage and measure each supported compiler without erasing types.
- A byte audit can look exact while hiding allocator headers, shared overlays,
  or overlapping lifetimes. Maintain one ownership registry, use checked sums,
  and report dynamic allocator bookkeeping and excluded subsystems separately.
- Static source generation can drift from the portable root or generate an
  incomplete switch. Make regeneration deterministic, coverage exact, and
  unsupported source a build error with no runtime fallback.
- Cleanup paths can accidentally replay admitted work, publish partial state,
  or retain a borrow. Drive implementation from the normative cleanup table
  and poison every lifetime and callback boundary.
- Resource results can vary with toolchain, optimization, dirty state, or
  instrumentation. Pin all identities, preserve full commands, use matched
  pristine builds, and distinguish measurement overhead from candidate data.

### Upstream blockers

- SPEC-007 and SPEC-008 are implemented. Their `GiftUILayout` and
  `GiftUIRenderLowering` production seams are available and are no longer
  upstream blockers for `T5.1` and `T5.2`.
- SPEC-011 has a ready plan but no `GiftUIInteraction` target. Its `T1`-`T4`
  focused declarations and behavior precede SPEC-013 profile binding;
  production coordinator work in the two plans then lands through the explicit
  cross-plan handoff above. `T5.3` and routing integration cannot substitute
  local candidate, generation, hit, or dispatch ownership.
- SPEC-012 is implementing and its `GiftUIDrawing` target, focused `T1`-`T5`
  behavior, and `T6.1`-`T6.3` generated callable contract are available. Its
  unfinished `T6.4`-`T7.4` production profile, host, startup, failure, and
  cycle joins depend on SPEC-013/SPEC-015 through the handoff above.
  Dynamic/static Canvas storage and full drawing evidence cannot proceed by
  duplicating its callable, capture, Path, plan, or producer algorithms.
- SPEC-009 and SPEC-010 remain implementing. Their already available focused
  seams may be consumed, but tasks requiring unfinished production integration
  remain blocked and must not move ownership into Runtime Core.
- SPEC-015 integration and Signal Analyzer production resource rows consume
  its approved schema-2 workload amendment and exact host values after the
  owning plan is ready and dependencies land. SPEC-014 remains governed by its
  normal plan.

Any discovery that requires another public/profile selection API, a changed
dependency edge, asynchronous semantics, retained/replayable frames, relaxed
static restrictions, a new failure case, or different publication/routing
lifetime returns upstream before affected work proceeds.

## Deferred and Follow-up Work

No new deferred artifact was required while drafting this plan. Retained
rendering, fine-grained observable tracking, replayable delivery, extra
runtime profiles, and richer Canvas features remain outside SPEC-013 under
their existing lifecycle or deferred records. Do not schedule them here.

## Completion Record

Plan audited and marked ready on 2026-09-09. At that gate all fifteen RP
criteria map to ordered code and evidence, immediately executable Runtime Core
and harness work is separated from unfinished focused-owner and downstream
integration dependencies, SPEC-011/012 cyclic-looking joins are split into
explicit owner/profile handoffs, and no proof-of-concept or Spike mechanism is
treated as production authority.

On 2026-09-11 the plan returned to `draft` with SPEC-013 so the new explicit
render-workspace limit, capacity-equality audit, and boundary evidence can be
reviewed together with SPEC-015's schema-2 workload amendment. No task had been
marked complete, so no implementation evidence is invalidated.

The maintainer explicitly reapproved SPEC-013 and coordinated SPEC-015 on
2026-09-12, then explicitly requested the plan's separate `ready` transition.
The plan was marked `ready` on 2026-09-12 after confirming that its tasks,
dependencies, and evidence mappings remain executable under the amended
contract.

Implementation began on 2026-09-12. T0.1 froze the ordered eight-corpus
fixture manifest, complete artificial-limit vocabulary, canonical normalized
transcript, RP-001 through RP-015 evidence registry, report field schema, and
hardware-free versus connected-hardware evidence labels under
`Tests/ContractFixtures/SPEC013/`. The Specification moved from `approved` to
`implementing` and this plan moved from `ready` to `active` in the same change.

Task checkboxes and evidence links must be updated with implementation. Plan
completion requires a disposition for every task but does not mark SPEC-013
implemented; that transition remains gated on conformance review and explicit
human authorization.
