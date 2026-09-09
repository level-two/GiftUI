---
spec: SPEC-009
feature: giftui-mvp-architecture
title: SPEC-009 Implementation Plan
status: active
owners:
  - codex
created: 2026-09-06
updated: 2026-09-08
related_design_notes:
  - ../implementation-designs/spec-009-execution-state-axes.md
conformance_report: null
related_future_work:
  - FW-010
  - FW-014
related_explorations: []
related_spikes:
  - SPIKE-001
supersedes: null
superseded_by: null
---

# SPEC-009 Implementation Plan

> This ready plan derives work from the approved Execution Cycle and Frame
> Handoff Contract, including its explicitly reapproved bounded generic
> focused-owner failure-carrier amendment. It orders implementation and
> evidence but does not amend the phase, admission, identity, publication,
> handoff, recovery, input-provenance, failure, profile, backend, or host
> contracts owned by that Specification and its authoritative dependencies.

## Authority and Scope

The governing [SPEC-009](../specs/spec-009-execution-cycle-and-frame-handoff.md)
is approved and authoritative. Its lifecycle chain is accepted
[PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md),
approved [RFC-002](../rfcs/rfc-002-giftui-mvp-layered-architecture.md),
[RFC-004](../rfcs/rfc-004-run-cycle-and-frame-transaction.md),
[RFC-005](../rfcs/rfc-005-failure-diagnostics-propagation.md), and
[RFC-011](../rfcs/rfc-011-bounded-application-actions.md), and accepted
[ADR-010](../adrs/adr-010-synchronous-one-shot-frame-handoff.md),
[ADR-011](../adrs/adr-011-serialized-run-cycle-and-publication.md),
[ADR-012](../adrs/adr-012-bounded-handoff-refusal-recovery.md),
[ADR-033](../adrs/adr-033-bounded-application-actions-and-model-target-dispatch.md),
[ADR-014](../adrs/adr-014-bounded-cross-layer-outcomes.md),
[ADR-015](../adrs/adr-015-layered-failure-disposition.md), and
[ADR-016](../adrs/adr-016-non-authoritative-diagnostics.md).

Approved [SPEC-002](../specs/spec-002-portable-foundation.md) owns normalized
pointer and checked-geometry values; approved
[SPEC-003](../specs/spec-003-failure-outcomes-and-containment.md) owns outcome,
failure, containment, policy, and diagnostic meaning; approved
[SPEC-006](../specs/spec-006-declarative-view-semantics.md) owns semantic and
action identity; approved [SPEC-007](../specs/spec-007-layout.md) owns resolved
layout and hit geometry; and approved
[SPEC-008](../specs/spec-008-rendering.md) owns normalized render production and
the one-attempt operation-sink lifetime. This plan consumes those contracts
without duplicating their declarations or implementations.

The [MVP Scope](../MVP_SCOPE.md) requires the substantially shared Signal
Analyzer to accept up to 80 state changes per second while presenting at a
nominal four frames per second across macOS dynamic, macOS static, Raspberry
Pi 1 ARMv6 dynamic, and nRF52840 static configurations. SPEC-009 supplies the
bounded serialized execution, coalescing, complete-publication, one-shot
handoff, refusal-recovery, and presentation-coupled input seam needed for that
stack validation. It adds no portable `GiftUI` API and does not authorize
observable-state storage, Button declarations or lowering, concrete runtime
storage, rasterization, production capacities or retry timing, platform
drivers, deployment, or connected-hardware work.

[SPIKE-001](../spikes/spike-001-tiled-one-shot-capability-fixtures.md) remains
feasibility evidence only. Its mechanisms and measurements do not replace the
approved contract or satisfy an implementation task by themselves.

## Current Repository State

- `Package.swift` has no `GiftUIRenderCore`, `GiftUIExecution`,
  `GiftUIFailureExecution`, runtime-profile, backend-integration, or execution
  test target. The exact production target edges required by SPEC-009 are not
  present.
- `GiftUI` implements SPEC-002's checked geometry and normalized pointer
  values. `GiftUISemanticCore` contains an in-progress SPEC-006 realization.
  `GiftUILayout` and `GiftUIRenderCore` do not yet exist, so no complete
  semantic-to-layout-to-render production path is available.
- SPEC-003 has reserved the future failure/execution edge in
  `Tests/ContractFixtures/SPEC003/target-boundaries.yaml`, but the reservation
  and its dependency checker still use the obsolete placeholder name
  `GiftUIExecutionContract`. SPEC-009's exact owner is `GiftUIExecution`; the
  registry and checker must change only when the compiling target lands.
- SPEC-002 through SPEC-005 boundary checks, forbidden-import registries, and
  negative compile fixtures contain additional `GiftUIExecutionContract`
  references. Each is a migration surface that must be reclassified against
  the real `GiftUIExecution` target; none is authority for a second target,
  stale negative fixture, or compatibility shim.
- There is no `Tests/ContractFixtures/SPEC009/`, scripted execution oracle,
  execution unit suite, one-shot endpoint fixture, input/recovery corpus,
  allocation or timing probe, `scripts/contracts/run-spec-009.sh`, or driver
  registry row.
- SPEC-002 and SPEC-003 provide reusable exact target-graph checks, failure
  values, correlation conventions, fixture-manifest validation, report
  publication, allocation interposition, cross-build inspection, and four-
  profile driver patterns. SPEC-006 and SPEC-010 demonstrate fail-closed
  incremental drivers while dependencies remain incomplete.
- SPEC-006 and SPEC-010 are implementing. SPEC-007 and SPEC-008 have ready
  plans but no production layout or render targets. Approved
  SPEC-013 owns the production dynamic/static coordinators and their concrete
  bounded storage; approved SPEC-014 owns production endpoints; and approved
  SPEC-015 owns assembled capacities, retry pacing, and target policy.
- The proof-of-concept runtime and rendering paths were removed from maintained
  source under SPEC-002's clean baseline. Their historical shape is migration
  evidence only and must not be restored as a parallel runtime or render path.
- The worktree contains concurrent user changes to SPEC-008 and its
  implementation plan. SPEC-009 work must preserve them and coordinate only
  through the approved render seam.

## Readiness Review

**Reviewed:** 2026-09-06

**Disposition:** Ready. SPEC-009 is approved after explicit reapproval, every
linked Proposal/RFC/ADR gate is authoritative, all fourteen acceptance
criteria map exactly once to ordered work and reproducible evidence below,
and no unresolved contract or architectural choice remains. Missing
prerequisite implementations are explicit task dependencies: fixture schemas,
owned value families, admission logic, state-machine tests, and scripted
oracles may proceed at their named boundaries, while production render,
runtime-profile, backend, and host integration waits for its owning plans and
targets.

No `docs/features.yaml` update is required. Implementation records are not
registered there, and `giftui-mvp-architecture` already reports the
implementation stage. SPEC-009 remains `approved` and this plan remains
`ready` until production implementation actually begins; that later progress
change moves the Specification to `implementing` and the plan to `active`.

If the pinned compilers cannot express the generic `OwnerFailure` result,
borrowed synchronous endpoint body, exact value layouts, or zero-allocation
static path, the affected work returns to Specification review. If execution
requires importing semantic, layout, observable-state, Interaction, runtime,
backend, platform, or failure authority upward, it returns to architecture or
Specification review. The implementation must not add a retained frame,
deferred input, historical hit map, replay queue, scheduler API, unbounded
identity, fallback action/model carrier, or profile-private outcome.

**Resolved implementation finding, 2026-09-06:** The maintainer explicitly
approved the coordinated SPEC-008/SPEC-009 correction placing the closed
`RenderProductionError` value in `GiftUIRenderCore` while leaving all detection
and production behavior in `GiftUIRenderLowering`. SPEC-009's exact
`RunCycleFailure.renderProduction(RenderProductionError)` declaration is now
implementable through the existing permitted dependency. No graph edge, error
case, raw value, translation, alias, or generic carrier changed.

## Task Dependencies and Affected Surfaces

Milestone numbers define the default order. A task may start only after every
listed prerequisite is satisfied.

| Work | Prerequisites | Primary affected surfaces | Parallel boundary |
| --- | --- | --- | --- |
| `T0.1`-`T0.4` | Approved SPEC-009 authority chain | `Tests/ContractFixtures/SPEC009/`, `scripts/contracts/`, `Package.swift`, existing target registries | Schemas, migration inventory, and driver scaffolding may proceed together after the acceptance registry exists; exact package edits land with compiling targets |
| `T1.1`-`T1.5` | `T0.2` boundary audit, SPEC-002 values, and SPEC-008-owned render declarations for endpoint/result references; the first compiling Execution source lands with its T0.2 package rows | `Sources/GiftUIExecution/`, `Tests/GiftUIExecutionTests/`, package graph fixtures | Independent raw-value families may be implemented together; aggregate result validation follows their complete declarations |
| `T2.1`-`T2.5` | Relevant `T1.*`; fixture-owned bounded storage | execution tests and `cycles.yaml` validation | Pure allocation, summary, and phase tests may proceed in parallel after shared checked helpers are fixed |
| `T3.1`-`T3.6` | `T1.*`, `T2.1`; SPEC-002 normalized pointer values; SPEC-006 identity supplied to fixtures | execution admission/input state machines, `input.yaml`, wake fixtures | Queue-family admission may be divided only after common context, ownership, seal, and cancellation rules are fixed |
| `T4.1`-`T4.6` | `T2.*`, `T3.*`; scripted focused-owner seams | recording coordinator fixture, `cycles.yaml`, `owner-failures.yaml` | Success and focused-failure scripts may be authored independently against one frozen transcript vocabulary |
| `T5.1`-`T5.6` | `T1.*`, `T2.*`, `T4.1`; SPEC-008 producer and sink contracts | endpoint fixture, `handoff.yaml`, `recovery.yaml` | Offer normalization and retry-state tests may proceed separately; combined candidate disposition waits for both |
| `T6.1`-`T6.5` | `T3.*`-`T5.*`; SPEC-003 production failure values | `Sources/GiftUIFailureExecution/`, failure adapter tests, diagnostic isolation | Execution mapping and endpoint mapping may proceed in parallel after exact contexts and mandatory effects are observable |
| `T7.1`-`T7.5` | Complete focused implementation and fixture vocabularies | all six SPEC-009 fixture files, instrumentation, contract driver | Corpus files can be populated by domain after the canonical loader and shared-field validation are fixed |
| `T8.1`-`T8.6` | `T1`-`T7`; prerequisite owners as named by each task; SPEC-013/014 integration for production claims | runtime/backend integration fixtures, dependency audits, reports, conformance preparation | Four profile runs may execute independently after the corpus freezes; normalized comparison and conformance preparation consume all reports |

## Acceptance-Criterion Matrix

The criterion text remains authoritative in SPEC-009. Every criterion appears
exactly once below.

| Criterion | Implementation tasks | Evidence | Status |
| --- | --- | --- | --- |
| `EX-001` — Exact execution declarations, normalization, widths, construction, and layouts | `T1.1`-`T1.5`, `T2.1`, `T8.1`, `T8.4` | API/source audit, initializer and option-set corpus, four-profile layout reports | pending |
| `EX-002` — Exact sealing, late deferral, at-most-once application, frozen derivation, complete publication, and finalization | `T3.4`-`T3.6`, `T4.1`-`T4.4`, `T7.2` | Canonical phase/membership/effect/publication transcripts | pending |
| `EX-003` — Dirty pre-publication recovery without replay and post-publication render-failure behavior | `T4.3`-`T4.5`, `T5.4`, `T7.2` | Failure-at-every-phase and dirty-rederivation transcript matrix | pending |
| `EX-004` — Pre-offer reservations, one offer, complete consumption/reservation, atomic frame/routing commit, and no retained borrow | `T2.2`, `T5.1`-`T5.4`, `T7.3` | Identity-reservation, endpoint-call, commit, capacity, and lifetime probes | pending |
| `EX-005` — Exact pre-acceptance refusal/abort mapping and irrevocable-output responsibility | `T5.1`-`T5.4`, `T6.3`, `T7.3` | Exhaustive legal/illegal body-result matrix and irreversible-output fixture | pending |
| `EX-006` — Constant-space latest-only retry recovery, backpressure distinction, finite pacing, and terminal unavailability | `T5.5`, `T5.6`, `T6.4`, `T7.4` | Recovery count/coalescing/supersession/exhaustion transcripts and storage audit | pending |
| `EX-007` — Target/runtime provenance, exact sequencing, cancellation, resynchronization, and exhaustion | `T3.2`-`T3.6`, `T7.2` | Complete `input.yaml` transcript with per-source before/after state | pending |
| `EX-008` — Identity-generation-only capture and cancellation on every record/hit/enabled/target change | `T3.3`-`T3.6`, `T4.2`, `T7.2` | Capture lifetime, revision-preservation, release, replacement, and no-retention probes | pending |
| `EX-009` — Exact admission, cycle, offer, focused-owner, operational, containment, policy, context, and diagnostic behavior | `T2.4`, `T4.5`, `T4.6`, `T6.1`-`T6.5`, `T7.5` | Exhaustive mapping/precedence/mandatory-effect corpus with diagnostic fault injection | pending |
| `EX-010` — Recording/dynamic/static equality through common admission and opportunity protocols | `T4.1`, `T7.2`-`T7.5`, `T8.2`, `T8.3` | Field-by-field normalized profile comparison | pending |
| `EX-011` — Signal Analyzer 80-facts/second workload with coalesced wakes/publications and one pending intent | `T5.5`, `T7.4`, `T8.2` | Timestamped `signal-analyzer.yaml` transcript and high-water report | pending |
| `EX-012` — Four exact drivers, complete corpus, static zero heap, layouts, high-water/resource evidence, graph checks, and cross-builds | `T0.3`, `T7.1`-`T7.5`, `T8.1`-`T8.5` | Registered reports, allocation/stack/timing/link maps, ARMv6 and nRF ELF inspection | pending |
| `EX-013` — No downstream/public/profile/backend/host/hardware contract leakage | `T0.2`, `T0.4`, `T8.1`, `T8.5` | Public/package surface, import graph, migration, symbol, and connected-hardware-claim audits | pending |
| `EX-014` — Finite focused-owner value preservation, first-failure selection, exact mapping, and static zero heap | `T1.5`, `T4.5`, `T4.6`, `T6.2`, `T7.5`, `T8.4` | Complete `owner-failures.yaml`, context/mapping transcript, layout and allocation report | pending |

## Milestones and Tasks

### Milestone 0: Freeze Authority, Boundaries, and Evidence Schemas

**Entry conditions:** SPEC-009 remains approved; all linked Proposal, RFC,
ADR, and prerequisite Specification gates remain authoritative.

**Exit evidence:** The exact target graph, fixture schemas, migration surface,
acceptance registry, and registered fail-closed driver skeleton exist before
execution behavior is claimed.

- [x] `T0.1` — Create `Tests/ContractFixtures/SPEC009/` with an ordered fixture
      manifest, shared-field schema, phase-transcript vocabulary, normalized
      result/failure/operational schema, stable identity-token rules,
      acceptance/evidence registry, and README. Register exactly `cycles.yaml`,
      `handoff.yaml`, `input.yaml`, `recovery.yaml`, `owner-failures.yaml`, and
      `signal-analyzer.yaml`; reject missing, duplicate, unknown, and
      unreferenced cases or fields. Distinguish host execution, cross-build,
      inspection, simulator, and connected-hardware evidence.
- [ ] `T0.2` — Reserve the approved `GiftUIExecution`,
      `GiftUIFailureExecution`, focused test, and fixture-only adapter targets
      in the package/target graph. Land each exact-set edit only with its first
      compiling source. Replace or retire every obsolete
      `GiftUIExecutionContract` reference across the SPEC-002 through SPEC-005
      allow lists, boundary registries, dependency checkers, forbidden-import
      scans, and negative compile fixtures according to its original boundary
      intent. Positive or reserved edges must name `GiftUIExecution`; negative
      checks must reject the real target rather than a permanently missing
      placeholder. Do not add an alias target or compatibility shim.
      Enforce `GiftUIExecution -> GiftUI + GiftUIRenderCore` and
      `GiftUIFailureExecution -> GiftUIFailureCore + GiftUIExecution`, plus all
      prohibited reverse and downstream imports from SPEC-009.
      This is an incremental boundary task: complete the graph audit and exact
      intended rows before source work, land each target row atomically with
      that target's first compiling source, and mark T0.2 complete only after
      all named targets and checks exist. It is not a prerequisite requiring
      empty placeholder targets.
- [x] `T0.3` — Create and explicitly register
      `scripts/contracts/run-spec-009.sh --profile <profile>` for exactly
      `macos-dynamic`, `macos-static`, `raspberry-pi-armv6`, and
      `nrf52840-embedded`. Use the SPEC-002 compiler/SDK/target/optimization
      identities and repository report helpers. Initially record `missing` or
      `blocked` rows fail-closed; never skip unavailable toolchains, fixture
      data, layouts, allocations, dependency checks, target inspection, or
      acceptance evidence.
- [x] `T0.4` — Inventory every historical or current immediate-invalidation
      path, direct action dispatch, unsealed/reentrant mutation, runtime-owned
      render operation, unbounded queue, retained/replayed frame, closure or
      model capture, stale hit-map route, backend/platform action path, and
      `GiftUIExecutionContract` placeholder. Assign adopt, replace-through-
      owner, retire, downstream-owned, evidence-only, or already-absent
      dispositions and add regression scans against a second execution path.

### Milestone 1: Implement the Focused Execution Value and Protocol Surface

**Entry conditions:** Milestone 0 fixes the graph. SPEC-002's package values
exist, and SPEC-008 has supplied `RenderOperationSink` and
`RenderProductionError` through `GiftUIRenderCore`. Until that exact owner
exists, target creation and declarations referencing it remain blocked.

**Exit evidence:** `GiftUIExecution` compiles with every exact package SPI
declaration, raw value, initializer, normalization rule, generic constraint,
and value-layout bound, without importing a coordinator owner.

- [x] `T1.1` — Implement `RunCycleID`, `SemanticRevision`,
      `CandidateFrameID`, `ActionGeneration`, `ObservableTargetGeneration`,
      `ExecutionPhase`, `ExecutionLimits`, and `ExecutionContext` with exact
      raw widths, cases, validation, `Equatable`, `Hashable` where declared,
      and `Sendable` behavior. Prove every identity bit pattern is valid and
      no sentinel is introduced.
- [x] `T1.2` — Implement `ExecutionWakeReasons`,
      `ExecutionWakeRequester`, and `PresentationPendingIntent`. Mask unknown
      option bits, validate retry-count semantics through owning transitions,
      and prove the value retains none of the forbidden payloads.
- [x] `T1.3` — Implement frame provenance, disposition, stream-result,
      failure, refusal-origin, `FrameOfferResult`, and
      `SynchronousFrameEndpoint` declarations exactly. Test every valid and
      invalid failable construction and the nonescaping synchronous body/sink
      borrow at compile and runtime boundaries.
- [x] `T1.4` — Implement admission kinds/results/outcomes, admission and
      opportunity protocols, admission summaries, action view, captured
      action, and their exact validation. Prove the captured value stores only
      the unmodified SPEC-006 identity-generation pair and the producer seam
      has no existential payload or profile-private entry point.
- [x] `T1.5` — Implement local errors, semantic/frame/intent/operational
      values, masked operational event set, generic `RunCycleFailure`,
      `RunCycleSummary`, and `RunCycleResult`. Use a finite fixture
      `OwnerFailure` to prove every specialization, exact `Equatable` and
      `Sendable` behavior, legal summary invariants, raw widths, and all value
      ceilings without inspecting or translating the owner value.

### Milestone 2: Establish Checked Identities, Phase State, and Result Invariants

**Entry conditions:** Milestone 1's complete value surface compiles and the
fixture can observe every reserved and committed identity separately.

**Exit evidence:** Pure focused tests exhaust every namespace and legal
summary/phase combination without a semantic owner, runtime profile, backend,
or host.

- [x] `T2.1` — Implement one checked allocator per execution-owned namespace:
      raw zero first, exact successor, reservation retirement on abort, no
      reuse or wrap, and smallest-scope fail-closed exhaustion. Keep
      `ObservableTargetGeneration` allocation outside Execution as SPEC-010
      requires.
- [x] `T2.2` — Prove reservation ordering for cycle, semantic, candidate,
      presentation, and action-generation identities, including every
      exhaustion point before and after publication. Record reserved,
      published, committed, aborted, and permanently retired values without a
      sentinel or persistent identity claim.
- [x] `T2.3` — Implement the legal phase transition guard and exact context
      snapshot. Reject backward, repeated, suspended, invalid, and nested
      entry; preserve the active cycle for reentrancy and `cycle == nil` for
      idle cycle-ID exhaustion.
- [x] `T2.4` — Exhaustively generate accepted and rejected
      `AdmissionSummary` and `RunCycleSummary` combinations. Check intrinsic
      invariants, limit equality/overflow, semantic/presentation consistency,
      operational exclusions, and the complete terminal-state matrix against
      recorded entry and reservation history.
- [x] `T2.5` — Decide whether checked identity retirement plus the independent
      semantic/candidate/frame/intent/input axes require a focused
      Implementation Design Note. If reconstruction would otherwise be
      difficult, create `spec-009-execution-state-axes.md` covering only
      replaceable storage and validation mechanics; any altered transition or
      identity meaning goes upstream.

### Milestone 3: Implement Admission, Wake Coalescing, and Pointer Sequencing

**Entry conditions:** Exact limits, contexts, identities, phase guards, and
summary validation are available. Fixture storage is bounded explicitly and
does not select SPEC-013 production storage.

**Exit evidence:** All submission families, wake transitions, ordered sealing,
source sequencing, capture, cancellation, and after-seal deferral have exact
standalone transcripts.

- [x] `T3.1` — Implement one accumulated wake-reason set and
      `wakeOutstanding` transition: one request on empty-to-nonempty, atomic
      take/clear at idle opportunity entry, a new transition during every
      later phase/finalization, masking, duplicate coalescing, and no
      synchronous run or scheduling result from the requester.
- [x] `T3.2` — Implement bounded per-source sequence/ordinal state with exact
      zero/start/successor rules, active/cancelled/quiescent states, checked
      exhaustion, and independently enforceable target-gate versus runtime
      validation. Keep target-local physical phases outside runtime-visible
      sequence allocation until submission.
- [x] `T3.3` — Implement down capture, move cancellation seam, release
      revalidation, and activation-candidate formation through the borrowed
      `ExecutionActionView`. Prove stable records survive unrelated commits
      and that removal, movement, disablement, generation change, target
      change, exhaustion, or ambiguity dispatches neither old nor replacement
      behavior.
- [x] `T3.4` — Implement pointer, state-change, and completion submission with
      exact ownership transfer/refusal, context, capacity, disabled-
      completion, unavailable, invalid-value, provenance, cancellation, and
      wake behavior. Submission never applies a fact, dispatches an action, or
      promises current-cycle membership.
- [x] `T3.5` — Implement exact ordered prefix selection and complete sealing:
      pointer validation and staged transitions, fact categories, same-cycle
      activations, dirty intent, then latest presentation recovery. Leave
      valid suffixes and after-seal arrivals queued in original order, record
      deferral, and request the next wake.
- [x] `T3.6` — Fault every seal reservation, stale/malformed pointer,
      semantic-action capacity, active-source capacity, and queue boundary.
      Prove complete affected-sequence cancellation where required, zero
      admission counts on failed seal, preservation of all unrelated queued
      work, no orphan activation, and clean reuse after finalization.

### Milestone 4: Build the Serialized Recording Cycle Oracle

**Entry conditions:** Admission can produce one immutable sealed transcript;
phase and result state is observable; focused fixture owners expose bounded
non-retaining apply/derive/publish operations. Production profile storage is
not required.

**Exit evidence:** A standalone coordinator fixture drives only
`ExecutionAdmissionSink` and `ExecutionOpportunityRunner` and proves the full
cycle independently of concrete semantic, layout, state, Interaction,
render-lowering, runtime, or backend implementations.

- [x] `T4.1` — Implement the canonical recording coordinator and closed event
      vocabulary for idle, admitting, mutating, deriving, publishing,
      offering, finalizing, result selection, wake transitions, and
      authoritative state. The fixture may inject focused owner results but
      must not create a second production semantic/layout/render contract.
- [x] `T4.2` — Apply sealed state-change facts, completion facts, and semantic
      actions exactly once in category and producer/pointer order. Revalidate
      identity, action generation, enabled state, and target generation at the
      fixture dispatcher boundary; prove no admission-time dispatch and no
      replay after every later outcome.
- [x] `T4.3` — Freeze mutation membership, coalesce invalidation, derive from
      stable current state, reserve staged action generations, and publish a
      complete semantic revision atomically. Prove unchanged/no-obligation
      cycles produce no candidate or frame.
- [x] `T4.4` — Inject semantic, layout, action-table, routing, and immutable-
      render-input failure before publication. Discard all partial downstream
      results, preserve already-applied effects as dirty, request one later
      semantic wake, and rederive without replay, recursive entry, or partial
      publication.
- [x] `T4.5` — Inject every finite fixture `OwnerFailure` at its focused
      boundary and every simultaneous later cleanup fault. Preserve the first
      exact value and detecting context, complete mandatory cleanup and a
      failure summary, and never replace it with a generic execution error or
      diagnostic.
- [x] `T4.6` — Implement deterministic final result selection: failure before
      operational, complete event-set retention, exact operational primary
      precedence, summary presence for every started cycle, finalizing
      exactly once, release of all scratch/borrows, and return to idle.

### Milestone 5: Implement One-Shot Handoff and Refusal Recovery

**Entry conditions:** The recording cycle can publish or recover one semantic
revision; SPEC-008 provides atomic producer/sink behavior; candidate,
presentation, routing, and pending-intent state are independently observable.

**Exit evidence:** Every legal and illegal offer/body combination, commit,
abort, borrow lifetime, backpressure, refusal, supersession, retry count, and
terminal state has an exact transcript.

- [x] `T5.1` — Implement a recording `SynchronousFrameEndpoint` with finite
      sink capacity, pre-consumption reservation, body-call counting,
      operation/vocabulary validation, retained local producer error, and
      post-return borrow poisoning. It must retain only endpoint-owned derived
      values after acceptance and no candidate data after any other result.
- [x] `T5.2` — Implement the runtime-side adapter from SPEC-008 production to
      `FrameStreamResult`, preserving the exact local render error. Normalize
      every body observation/result pairing according to SPEC-009, including
      all illegal pairings and the distinct render-producer versus endpoint
      refusal origins.
- [x] `T5.3` — Implement candidate allocation and presentation-revision
      reservation at the exact new-publication and unchanged-recovery phase
      boundaries, then invoke `offer` at most once. Exercise candidate-ID,
      presentation-ID, invalid-envelope, required-facility, and direct
      contract failures before offer/body entry.
- [x] `T5.4` — Commit accepted frame, reserved presentation revision, hit
      geometry, bound action records, and routing state atomically only after
      complete consumption/reservation. Abort all staged state for every
      non-accepted result, preserve prior committed routing, preserve new
      semantic publication, and prove irreversible output can only finish as
      accepted endpoint health.
- [x] `T5.5` — Implement constant-space latest-revision pending intent.
      Preserve or start count zero for backpressure, checked-increment from
      one for retryable refusal, keep the two outcomes mutually exclusive,
      coalesce newer publication with `superseded`, and request one separately
      paced presentation wake without retaining a root, graph, frame, stream,
      operation, action, model, or borrow.
- [x] `T5.6` — Exercise configured maxima `1...255`, exact below/equal-limit
      behavior, checked-increment failure, non-retryable refusal, facility
      loss before/after candidate allocation, capture cancellation, input
      quiescence, and reassembly boundary. Verify terminal residual policy
      excludes paced retry and cannot reinterpret unavailable as success.

### Milestone 6: Complete Failure Correlation and Diagnostic Isolation

**Entry conditions:** Every local admission, execution, render, endpoint,
refusal, focused-owner, and operational result is injectable after its exact
mandatory mechanical effects.

**Exit evidence:** `GiftUIFailureExecution` supplies exact SPEC-003 facts and
correlation without an import cycle, fallback owner mapping, or diagnostic
control path.

- [x] `T6.1` — Add `GiftUIFailureExecution` importing exactly
      `GiftUIFailureCore` and `GiftUIExecution`. Map every admission result and
      `ExecutionError` to its exact condition, origin, smallest proven scope,
      containment, and preserved `ExecutionContext` after mandatory pointer
      cancellation or cycle effects.
- [x] `T6.2` — Preserve `.focusedOwner` as the concrete finite value through
      the common result. Add a fixture owner adapter that switches exhaustively
      over its own sum and proves `GiftUIFailureExecution` supplies neither a
      fallback mapping nor generic invalid/invariant/diagnostic translation.
- [x] `T6.3` — Map exact render-production errors, frame-offer failures,
      illegal endpoint pairings, and both non-retryable-refusal origins.
      Reject legal-impossible `.frameOffer(.insufficientCapacity)` and
      `.frameOffer(.producerFailed)` coordinator results in favor of the
      retained producer error.
- [x] `T6.4` — Map every operational primary result with exact origin, scope,
      context, attempt ordinal/limit, and complete event-set evidence. Prove
      mandatory abort, dirty, unavailable, cancellation, and quiescence
      effects precede total residual target policy.
- [x] `T6.5` — Run diagnostics omitted, selected, saturated, dropped, and
      failing. Prove identical admissions, effects, revisions, identities,
      offers, wakes, retries, mappings, summaries, and authoritative state;
      reject any diagnostic callback or sink mutation/action path.

### Milestone 7: Freeze the Canonical Corpus and Resource Instrumentation

**Entry conditions:** Focused unit and recording fixtures pass for every
individual behavior. The canonical loader rejects any transcript or summary
that violates the shared schema or lifecycle matrix.

**Exit evidence:** All six required fixture files form one complete,
nonduplicated corpus and the driver records every required measurement.

- [x] `T7.1` — Finish the manifest and canonical loader. Validate every shared
      field, explicit `none`, stable symbolic identity token, primary
      operational precedence, summary matrix, endpoint script, referenced
      case, and expected evidence row. Reject pointer/closure/string/hash/
      metatype-address or profile-private semantic identity comparisons.
- [x] `T7.2` — Complete `cycles.yaml` and `input.yaml` for every phase,
      admission timing, ordering, capacity, publication, dirtiness,
      at-most-once, provenance race, sequence/ordinal, cancellation,
      resynchronization, exhaustion, capture, replacement, movement, disabled,
      and quiescence case required by SPEC-009.
- [x] `T7.3` — Complete `handoff.yaml` for every legal/illegal endpoint/body
      pair, acceptance, refusal, reservation, discard, lifetime, operation
      count, producer error, contract violation, and irreversible-output
      case.
- [x] `T7.4` — Complete `recovery.yaml` and `signal-analyzer.yaml` for
      backpressure, retryable refusal, pacing, count boundaries,
      supersession, terminal state, 20 facts between each of four
      opportunities, one coalesced wake/publication per opportunity, and at
      most one pending intent.
- [x] `T7.5` — Complete `owner-failures.yaml` and instrumentation for every
      finite owner case, first-failure/cleanup ordering, exact context and
      mapping, phase duration, seal-to-publication and offer latency,
      dirty-to-opportunity latency, retry attempts/pacing, queue/workspace and
      stack high-water, stale drops, cancellations, operation count, heap
      allocation, section delta, and link map.

### Milestone 8: Integrate Owners and Produce Four-Profile Evidence

**Entry conditions:** The focused contract and corpus pass independently.
Each production integration begins only after its governing Specification's
plan has supplied the named target and exact seam. No connected hardware or
remote target change is authorized.

**Exit evidence:** The exact four standalone commands pass complete source,
semantic, failure, resource, dependency, and cross-build checks; every
criterion is ready for conformance review.

- [x] `T8.1` — Audit public/package interfaces, exact target dependencies,
      compiled imports, and negative fixtures. Reject any public Execution
      identity, portable-client observation, failure import upward, runtime or
      downstream owner import, backend-to-runtime dependency, input-adapter
      semantic-storage import, placeholder target, compatibility shim, or
      second execution path.
- [ ] `T8.2` — Integrate the common corpus with SPEC-013's production dynamic
      and static coordinators only after that owner exists. Drive both solely
      through `ExecutionAdmissionSink` and `ExecutionOpportunityRunner`; compare
      sealed membership, phases, identities, effects, publications, frame
      dispositions, cancellations, event sets, owner failures, and mappings
      field by field against the recording oracle.
- [ ] `T8.3` — Integrate SPEC-014 recording/backend endpoints and the
      SPEC-010/SPEC-011 owner seams only through their approved boundaries.
      Prove Execution does not gain state storage, action dispatch ownership,
      raster meaning, production endpoint storage, target gating, or host
      policy. Keep missing owners as explicit blocked evidence rather than
      substitutes.
- [ ] `T8.4` — Run value-layout and allocation probes on every supported
      compiler. Prove every exact/non-generic width and aggregate ceiling,
      `OwnerFailure <= 4` bytes, generic result ceilings, zero heap in all
      static execution paths, and bounded dynamic queue/workspace high-water
      at the approved fixture limits.
- [ ] `T8.5` — Run macOS dynamic, macOS static, Raspberry Pi ARMv6, and
      nRF52840 Embedded Swift drivers. Preflight cross-compilation with
      `scripts/raspberry-pi/doctor.sh --probe` and
      `scripts/nrf52840/doctor.sh --probe` under their repository skills and
      tracked pins; keep toolchains under `.toolchains/` and emitted evidence
      under the approved `.build/` paths. Record exact commands, compiler/SDK,
      repository revision, fixture digest, timings, high-water values,
      allocations, stack, sections, and link maps; verify ARMv6 target
      identity and nRF Cortex-M4F hard-float VFP attributes. Do not deploy,
      flash, access a remote target, or claim connected-hardware conformance.
- [ ] `T8.6` — Run `scripts/format-swift.sh`, the focused unit/contract suite,
      exact standalone SPEC-009 drivers, driver-registry check, dependency
      checks, and the repository test gate. Create
      `docs/conformance/spec-009-conformance.md`, link it from SPEC-009 and
      this plan, and populate every `EX-001` through `EX-014` row with stable
      evidence or an explicit deviation/exception request. Do not mark the
      Specification `implemented` without human authorization.

## Design-Note Triggers

- Create `docs/implementation-designs/spec-009-execution-state-axes.md` only
  if the checked identity allocators, independent authoritative state axes,
  summary validation, and failure cleanup are difficult to reconstruct from
  local code. Document internal storage and invariant-checking order, not new
  transitions or identity meaning.
- Create `docs/implementation-designs/spec-009-admission-and-input-state.md`
  only if bounded queue selection, staged seal ownership, per-source
  sequence/capture state, and cancellation rollback require maintained
  explanation. The exact ordering and provenance rules remain normative in
  SPEC-009.
- Create `docs/implementation-designs/spec-009-one-shot-offer.md` only if the
  producer/body/endpoint adapter and reservation/borrow cleanup are not
  locally evident. It may explain a replaceable implementation but cannot add
  replay, retention, asynchronous Core completion, or backend policy.
- Production dynamic/static storage and the full cross-owner coordinator
  belong to SPEC-013 design notes, not this plan. Concrete backend reservation
  and raster/display ownership belong to SPEC-014. Host pacing and numeric
  policies belong to SPEC-015.

## Integration and Validation Order

1. Freeze fixture schemas, graph intent, migration inventory, and a fail-
   closed registered driver before production source can hide missing
   evidence.
2. Land the focused value/protocol target after SPEC-008 supplies its exact
   render declarations. Prove layouts, failable construction, identity
   allocation, phase guards, and summary invariants before stateful cycle
   work.
3. Prove wake coalescing, admission ownership, pointer sequencing/capture, and
   complete sealing independently. Then build the recording cycle oracle and
   at-most-once/dirty-publication corpus without production runtime storage.
4. Prove the one-shot endpoint and exhaustive offer normalization before
   combining candidate commit/abort and refusal recovery. Prove all mandatory
   state effects before adding failure and policy adapters.
5. Run focused unit and recording tests before any dynamic/static comparison.
   Integrate production profiles only through SPEC-013, endpoints only through
   SPEC-014, and target policy only through SPEC-015.
6. Run macOS dynamic first, macOS static second, then the repository-skill
   toolchain doctors/probes and hardware-free Raspberry Pi ARMv6 and nRF52840
   cross-build/inspection. Cross-build success is not connected-hardware
   evidence, and the nRF path never flashes a board.
7. Collect timing/resource evidence after the canonical corpus freezes so
   instrumentation cannot change semantics. Register every exact standalone
   command with the top-level gate before conformance review.

## Risks and Upstream Blockers

### Implementation risks

- The exhaustive cycle matrix spans independent semantic, candidate, frame,
  presentation-intent, physical-health, and input-source axes. A monolithic
  mutable state object could admit illegal combinations; keep construction
  validated and fault every transition boundary.
- Swift generic specialization around `OwnerFailure`, endpoint sinks, state-
  change facts, completion facts, and action identities can exceed the strict
  layout or linked-section ceilings. Measure each specialization on every
  pinned compiler before production profile integration.
- Borrowed producer operations, glyph/resources, endpoint sinks, action views,
  and current models can escape through apparently harmless recording or
  diagnostic helpers. Use poison lifetimes and compiled dependency/symbol
  audits in addition to source review.
- Pointer cancellation and seal rollback can accidentally remove unrelated
  work or let an orphan release dispatch. Record complete per-source and queue
  state before and after every refusal and provenance race.
- Wake acknowledgment during an active opportunity can lose a later reason or
  emit duplicate requests. Inject each reason in every phase and finalization
  with exact transition counts.
- Retry recovery can accidentally retain a frame or conflate backpressure
  with retry budget. Audit stored fields and exercise the entire `1...255`
  range plus checked overflow.
- The repository has concurrent SPEC-008 work. Package and shared fixture
  edits must preserve those changes and use the exact approved render seam.

### Upstream blockers

- `GiftUIExecution` depends on `GiftUIRenderCore`, which is owned by approved
  SPEC-008 and its ready plan but has no target yet. Declarations and tests
  that reference `RenderOperationSink` or `RenderProductionError` wait for
  that owner. This plan must not create a substitute render protocol.
- Complete production semantic/layout/render integration waits for the
  implementation tasks of SPEC-006, SPEC-007, and SPEC-008. The recording
  execution oracle remains independently executable with focused finite
  owner fixtures.
- Dynamic/static production storage and the full cross-owner coordinator are
  SPEC-013 responsibilities. SPEC-009 supplies focused values, protocols,
  state machines, failure correlation, and fixtures; it must not preempt
  runtime-profile representation or capacity accounting.
- Committed bound action records and final handler/model dispatch require
  SPEC-010 and SPEC-011 implementations. SPEC-009 may test the exact generic
  identity/generation seams with finite fixture values but cannot define
  observable storage, action payload lowering, or handlers.
- Production endpoints and post-handoff health belong to SPEC-014. Host
  capacities, retry maximum, pacing, capability gate, reassembly, and fatal
  policy belong to SPEC-015. Fixture values prove the focused contract only.
- Any need for historical hit maps, deferred stale input, retained/replayed
  operation streams, asynchronous frame disposition, a scheduler object,
  public execution identity, or a new failure meaning is an upstream
  architecture/Specification issue, not an implementation-plan choice.

## Deferred and Follow-up Work

- [FW-010](../future-work/fw-010-backend-transport-submission-retry.md)
  preserves optional post-handoff recovery using backend-owned derived data.
  It is not a Core retry task and is not scheduled here.
- [FW-014](../future-work/fw-014-replayable-operation-delivery.md) preserves a
  future bounded replayable delivery form. SPEC-009 remains synchronous and
  one-shot and this plan creates no retained operation payload.
- Richer action domains, generalized schedulers, historical routing, lossless
  input, physical-visibility transactions, and concrete host policies remain
  outside this plan under their existing downstream or deferred owners.

No new deferred item was discovered while preparing this plan. A required
correctness, capacity, profile-equivalence, or acceptance-evidence obligation
from SPEC-009 cannot be deferred.

## Completion Record

The plan was drafted and marked ready on 2026-09-06 after the complete
authority chain, repository baseline, fourteen acceptance criteria, dependency
gates, and evidence strategy were reviewed.

Implementation began on 2026-09-06 at the maintainer's request. SPEC-009 is
`implementing` and this plan is `active`; these progress transitions do not
change the approved contract or authorize the eventual `implemented`
transition.

`T0.1` is complete: the checked-in
[fixture schema evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-0/fixture-schema.md)
records the exact six-file fixture registry, shared fields, phase-event
vocabulary, normalized result/failure/operational records, symbolic identity
rules, and fourteen-row acceptance registry. The focused harness rejects
missing or extra fixture files, duplicate or unknown cases and fields,
unreferenced populated cases, invalid symbolic identities, and non-pending
initial evidence while permitting the canonical corpus to remain empty until
its owning tasks populate it. `T0.3` and `T0.4` may now proceed independently;
`T0.2` remains coupled to the first compiling `GiftUIExecution` target and its
SPEC-008-owned prerequisites.

The 2026-09-06 dependency audit found the former `RenderProductionError`
ownership contradiction. The maintainer approved the preferred correction:
Render Core owns only the shared bounded value, Render Lowering retains all
detection and production behavior, and Execution preserves the value through
its existing Core dependency. T1.5 is no longer blocked by type ownership.

`T0.4` is complete: the checked-in
[migration baseline](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-0/migration-baseline.md)
pins the immutable PoC revision and reproduces exact path/count maps for
immediate invalidation, direct dispatch, reentrancy guards, runtime-owned
render operations, retained frames, closure/model capture, stale hit-map
routing, and backend/platform action paths. It also inventories all eight
current `GiftUIExecutionContract` placeholders for replacement only when T0.2
lands the real compiling target. The standalone regression scan rejects an
unbounded execution queue or a restored second execution path. `T0.3` is the
next dependency-complete SPEC-009 task; T0.2 remains incrementally coupled to
its first compiling sources.

`T0.3` is complete: the
[registered contract driver](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-0/contract-driver.md)
exposes the four exact profile commands, validates the fixture and migration
schemas, and records the pinned compiler, SDK/target, optimization, repository
revision, input digest, and complete command transcript. All four profiles
pass on the project-local toolchains while explicitly reporting the execution
target, dependency audit, and target inspection as blocked and every
acceptance row as missing. The reports remain fail-closed with
`evidence_complete=false`; no target build, simulator, remote access,
deployment, service restart, connected hardware, or flashing occurs.
Milestone 0 now waits only for the incrementally coupled T0.2 package boundary.

The first incremental `T0.2` boundary slice is complete. `GiftUIExecution`
and `GiftUIExecutionTests` landed with the exact `GiftUI` plus
`GiftUIRenderCore` production edge, and every SPEC-002 through SPEC-005
placeholder reference now names the real owner. The obsolete
`GiftUIExecutionContract` target name is absent and has no alias or shim. T0.2
remains open for `GiftUIFailureExecution` and the fixture-only adapters, which
must still land atomically with their first compiling sources.

`T1.1` is complete: five exact four-byte identity values preserve every raw
bit pattern without sentinels; the seven execution phases retain their exact
one-byte raw order; limits enforce every required nonzero capacity while
permitting zero completion capacity; and context preserves exact optional
correlation. Focused tests prove the 12-byte limits layout and 24-byte context
ceiling, while the registered source audit excludes dynamic storage, public
surface, and prohibited upward coupling; see the
[execution value evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-1/execution-values.md).
T1.2 is the next dependency-complete execution value task.

`T1.2` is complete: the one-byte wake-reason set masks unknown bits and owns
the exact three flags, the requester remains a non-suspending notification
seam, and pending presentation retains only revision plus retry count within
its eight-byte ceiling. Fixture-owned transitions prove zero-count
backpressure, first and repeated refusal counts, maximum exhaustion, and
newer-revision replacement without adding a runtime owner; see the
[wake value evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-1/wake-values.md).
T1.3 is the next dependency-complete execution value task.

`T1.3` is complete: exact provenance, offer/logical/stream dispositions,
failures, refusal origin, validated offer result, and the synchronous generic
endpoint now live in `GiftUIExecution`. Focused tests prove raw values, layout
bounds, all valid and invalid result constructions, one body call for every
consumed envelope, zero calls under backpressure, and exact stream-result
mapping. The registered audit fixes the nonescaping `inout` sink boundary and
excludes retained frame/operation/resource storage; see the
[frame handoff evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-1/frame-handoff-values.md).
T1.4 is the next dependency-complete execution value task.

`T1.4` is complete: exact admission kinds, results, contextual outcomes,
typed admission and opportunity seams, bounded admission summaries, borrowed
action view, and identity-generation-only capture now live in
`GiftUIExecution`. Focused tests prove raw values, layouts, count validation,
disabled completion capacity, semantic-action count bounds, typed protocol
conformance, and unchanged passage of a SPEC-006-shaped identity beside the
runtime-wide generation. The source audit rejects existential payloads,
profile-private entry points, forbidden owners, and any captured field beyond
that pair; see the
[admission value evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-1/admission-values.md).
The opportunity seam's exact return type requires the transitive T1.5 value
declarations in this buildable increment; their invariant, specialization,
and layout evidence remains T1.5 work. T1.5 is next.

`T1.5` is complete: exact execution errors, semantic and intent dispositions,
masked operational events, generic focused-owner failures, validated cycle
summaries, and generic cycle results now have complete focused evidence.
Tests prove every raw value and width, unknown-bit normalization, exact
`Equatable` and `Sendable` specialization, every failure carrier, intrinsic
legal and rejected summary combinations, direct owner-value preservation, and
the at-most-4/8/40/72-byte owner, failure, summary, and result ceilings. The
registered source audit excludes existential or diagnostic carriers,
owner-value inspection, prohibited imports, and profile coupling; see the
[run-cycle value evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-1/run-cycle-values.md).
Milestone 1's task surface is implemented. Consolidated complete-surface and
cross-profile evidence is the next boundary before T2.1.

Milestone 1 is complete: the registered value-profile check compiles the
complete T1.1-T1.5 module surface and extracts 31 optimized target-IR layouts
under macOS dynamic, macOS static, Raspberry Pi ARMv6, and nRF52840 Embedded
Swift. The four normalized reports are byte-for-byte equal and satisfy every
exact width and ceiling, including the 72-byte specialized cycle-result bound;
see the
[consolidated execution value evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-1/execution-value-surface.md).
This is compilation and cross-build inspection, not simulator or connected-
hardware execution. The focused test row now names the direct `GiftUI` import
introduced by its first admission-contract source. T0.2 correctly remains
open: neither `GiftUIFailureExecution` nor a fixture-only adapter has its first
compiling source, so no placeholder package row was added. T2.1 is the next
dependency-complete task.

`T2.1` is complete: five distinct package-scoped allocators reserve cycle,
semantic-revision, candidate-frame, presentation-revision, and runtime-wide
action-generation identities through one private checked cursor. Focused tests
prove zero-first exact successors, independent namespaces, valid maximum
reservation, permanent exhaustion without reuse or wrap, caller normalization
to `identityExhausted`, and finite `Equatable`/`Sendable` state. The source
audit rejects sentinels, wrapping arithmetic, prohibited imports, and any
Execution-owned `ObservableTargetGeneration` allocator; see the
[checked allocator evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-2/checked-identity-allocators.md).
T2.2 is next.

`T2.2` is complete: a fixture-owned finite transcript proves cycle,
replacement action-generation, semantic publication, candidate, presentation,
offer, and commit/abort ordering. It records reserved, published, committed,
aborted, and retired typed values; proves exact successors after abort; and
exercises exhaustion before and after publication without an offer, alias,
sentinel, persistent identity, or coordinator representation. See the
[reservation ordering evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-2/reservation-ordering.md).
T2.3 is next.

`T2.3` is complete: `ExecutionPhaseMachine` enforces the exact twelve-edge
forward/finalization graph and maintains bounded cycle, semantic, candidate,
and detecting-phase context. A 49-pair matrix rejects every repeat, backward,
and invalid skip without state change; focused tests also prove nested entry
preserves the active cycle without allocation, idle identity exhaustion keeps
`cycle == nil`, and idle cleanup retains only the latest semantic revision.
The source audit excludes suspension and prohibited owner coupling; see the
[phase machine evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-2/phase-machine.md).
T2.4 is next.

`T2.4` is complete: independent finite predicates match 768 exhaustive
admission-summary combinations and 10,368 exhaustive cycle-summary
combinations. A fixture-owned history oracle accepts all thirteen terminal
matrix rows and rejects contradictions between entry state, reservations, and
an otherwise intrinsically valid summary. Historical representation remains
outside package SPI until the recording coordinator owns it; see the
[summary matrix evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-2/summary-validation-matrix.md).
T2.5 is next.

`T2.5` is complete: reconstruction warrants the focused, non-authoritative
[Execution Identity and State Axes design note](../implementation-designs/spec-009-execution-state-axes.md).
It records the private checked-cursor representation, typed namespace
wrappers, permanent retirement, exact phase/correlation guard, separation of
intrinsic summary validation from fixture history, and the six independent
state axes. It selects no production coordinator or profile storage and
changes no transition or identity meaning. Milestone 2 is complete; T3.1 is
the next dependency-complete task.

`T3.1` is complete: one internal accumulator owns the normalized wake-reason
set and outstanding bit, requests only on empty-to-nonempty transitions, and
atomically takes and acknowledges both at idle opportunity entry. Focused
tests prove masking, duplicate coalescing, a fresh transition for reasons
arising after the take in every active/finalizing phase, non-idle rejection,
and redundant idle opportunities. The generic requester returns no scheduling
result and cannot synchronously select or run a cycle; see the
[wake accumulation evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-3/wake-accumulation.md).
T3.2 is next.

`T3.2` is complete: the target gate consumes a runtime-visible sequence only
when submitting a down, beginning at zero and exhausting permanently after
the checked maximum. The independent runtime validator enforces exact down,
move, and up ordinals and sequences across synchronized, active, cancelled,
and quiescent source states. It cancels malformed provenance without adopting
it as a baseline, consumes cancelled suffixes without dispatch, requires a
separate target-gate proof for unfinished-sequence replacement, and maintains
independent fixed-width state per bounded source. See the
[input sequence evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-3/input-sequences.md).
T3.3 is next.

`T3.3` is complete: the finite capture clears older state before down hit
resolution, stores only the exact identity-generation pair from the borrowed
action view, supports movement cancellation, and releases only after complete
identity, generation, enabled-state, provenance, and ambiguity revalidation.
Tests prove stable records survive unrelated commits while removal, movement,
disablement, generation/target-record change, unavailable lookup, or ambiguous
reuse produces no activation and no retargeting; see the
[pointer capture evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-3/pointer-capture.md).
T3.4 is next.

`T3.4` is complete: the internal fixture-finite admission controller implements
the shared sink over caller-owned bounded storage and the existing wake and
per-source sequence mechanisms. Tests cover exact contexts, complete-value
ownership, pointer/state/completion capacity, disabled completion, invalid
facts, stale and malformed provenance, active-source refusal, quiescence,
mandatory pointer cancellation, and one coalesced wake without applying or
dispatching work; see the
[admission controller evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-3/admission-controller.md).
T3.5 is next.

`T3.5` is complete: the focused sealer selects exact category prefixes in
pointer, state-change, completion, same-cycle activation, dirty, and latest-
presentation order. It accepts equality at every limit, leaves excess valid
suffix counts deferred, and rejects activation membership that exceeds either
selected pointers or semantic-action capacity. The admission controller marks
after-seal arrivals deferred and requests a fresh coalesced wake while
preserving storage order; see the
[admission seal evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-3/admission-seal.md).

`T3.6` is complete: the finite seal transaction faults pointer-transition and
complete-batch reservation independently, keeps the first failure sticky, and
returns an all-zero admission summary on every failed seal. Provenance and
semantic-action failures identify the complete affected sequence, discard all
staged counts and activations, preserve unrelated queue order, and reset the
workspace during finalization for clean reuse. The admission-controller and
sealer boundary fixtures complete active-source refusal, full-queue refusal,
and valid suffix deferral coverage; see the
[admission seal fault evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-3/admission-seal-faults.md).
Milestone 3 is complete.

`T4.1` is complete: the canonical fixture implements the common opportunity
runner, drives the existing phase and wake mechanisms, and emits a closed
caller-owned event transcript for wake transition/take, every phase, result
selection, and final authoritative state. Unchanged and published/offered paths
prove exact phase coverage, coalescing, fresh later wake transitions, monotonic
cycle/revision identities, and idle preservation without importing or
redefining downstream owner contracts; see the
[recording coordinator evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-4/recording-coordinator.md).

`T4.2` is complete: a bounded one-shot sealed batch applies state-change,
completion, and semantic-action values exactly once in contract and
producer/pointer order. Action dispatch immediately revalidates identity,
action generation, enabled state, and observable target generation; every
mismatch suppresses dispatch without retargeting. Construction and admission
dispatch nothing, while every later phase and repeated mutation attempt leaves
the applied transcript unchanged; see the
[recording mutation evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-4/recording-mutation.md).

`T4.3` is complete: mutation membership freezes exactly once, invalidations
coalesce separately before and after that boundary, and changed derivation
reserves bounded staged action generations before its semantic revision. Only
a fully reserved derivation replaces the published revision; capacity and
identity failures preserve the prior publication while consumed identities
remain retired. An unchanged result creates no semantic revision, action
generation, candidate identity, or frame, and an outstanding presentation
obligation selects recovery without inventing semantic change; see the
[recording derivation evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-4/recording-derivation.md).

`T4.4` is complete: the bounded recovery seam injects semantic, layout,
action-table, routing, and immutable-render-input failures, discards every
accumulated partial result, and preserves the prior complete semantic and
presentation state. A failure after applied effects returns a dirty summary
and requests one coalesced semantic wake; recovery is barred until that wake is
taken at a later idle opportunity and leaves the applied-effect count unchanged.
A clean pre-publication failure remains unchanged and requests no dirty wake;
see the
[recording recovery evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-4/recording-recovery.md).

`T4.5` is complete: a five-case inline fixture sum captures the first exact
focused-owner value and detecting context across mutation, completion,
semantic, layout, and immutable-render-input boundaries. The exhaustive matrix
crosses every value with all 32 subsets of later cleanup faults; mandatory
partial-result discard, candidate abort, scratch and borrow release, and
summary production still complete, while neither later focused failures nor
diagnostic faults can replace the original result. The concrete owner value
and specialized failure stay within their four- and eight-byte bounds; see the
[focused-owner failure evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-4/focused-owner-failures.md).

`T4.6` is complete: the bounded finalizer retains the complete operational
event set, selects any retained failure first, and otherwise applies the exact
retryable-refusal, backpressure, supersession, later-admission, and no-change
precedence before using success only for an empty set. Success, operational,
and failure paths retain complete summaries. Every active exit phase enters
finalizing once, releases scratch and borrow state, clears active identities,
and restores the idle authoritative context; repeated finalization is refused.
See the
[cycle finalization evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-4/cycle-finalization.md).
Milestone 4 is complete.

`T5.1` is complete: the bounded recording endpoint validates envelope and
downstream capacity before reserving an attempt and calling its body once. Its
sink enforces finite capacity and exact operation vocabulary, retains the first
local producer error, and is poisoned on every return. Acceptance retains only
endpoint-derived frame values; every other result releases the reservation and
retains no candidate data. See the
[recording endpoint evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-5/recording-endpoint.md).

`T5.2` is complete: the runtime-side seam adapts successful production and all
seven exact render errors to the narrow stream vocabulary while retaining the
local error separately. The exhaustive stream/error/endpoint matrix accepts
only the five legal called-body pairings, normalizes all other pairings to an
endpoint contract violation, and distinguishes render-producer refusal from a
no-body endpoint refusal. See the
[offer normalization evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-5/offer-normalization.md).

`T5.3` is complete: candidate and presentation identities reserve in order at
the publishing boundary for a new revision and the deriving boundary for
unchanged recovery. Exhaustion, facility loss before/after candidate
allocation, and direct contract failure preserve the semantic revision and
never enter the body. Invalid envelopes enter one offer but no body; repeated
offer is rejected. See the
[candidate offer evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-5/candidate-offer.md).

`T5.4` is complete: one transaction stages the reserved presentation revision,
logical frame, hit geometry, action table, and routing values and publishes all
five only after complete accepted consumption. Every non-accepted result aborts
all staged state while preserving prior committed routing and the newer semantic
publication. Incomplete acceptance fails closed, and irreversible output is
legal only when endpoint health finishes accepted. See the
[frame commit evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-5/frame-commit.md).

`T5.5` is complete: the coordinator retains only the latest semantic revision
and retryable-refusal count. Backpressure preserves a same-revision count or
starts a newer revision at zero, while retryable refusal checked-increments
from one; the outcomes remain mutually exclusive. Newer publication replaces
the complete intent and records supersession. Recovery requests coalesce into
one presentation-pending wake until a separately paced idle opportunity, and
revision-scoped clearing cannot discard newer work. See the
[presentation-pending evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-5/presentation-pending.md).

`T5.6` is complete: the exhaustive matrix crosses all configured maxima from
one through 255, proves exact below-limit retention and at-limit exhaustion,
and injects checked-increment overflow without wrap or wake. Exhaustion, both
non-retryable-refusal origins, and required-facility loss clear pending state
and capture, quiesce presentation input, mark intent unavailable, and exclude
paced retry. Pre-candidate facility loss leaves the frame unproduced, later
loss aborts it, and only explicit reassembly reopens admission. See the
[presentation-recovery evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-5/presentation-recovery.md).
Milestone 5 is complete.

`T6.1` is complete: `GiftUIFailureExecution` imports only Failure Core and
Execution and maps queued admission plus every admission failure and local
execution error after mandatory effects. The exhaustive matrix preserves the
detecting context, both capacity scopes, all identity-exhaustion scopes,
safe-reuse containment, and every exact condition and origin while rejecting
unproven narrowing or pre-containment mapping. See the
[execution failure adapter evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-6/execution-failure-adapter.md).

`T6.2` is complete: the common adapter recognizes only `.focusedOwner` and
returns its unchanged finite value and detecting context. The fixture owner
exhaustively maps its five-case sum without a default; every non-focused common
failure returns no focused mapping, so Failure Execution supplies no fallback
fact or generic translation. See the
[focused-owner adapter evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-6/focused-owner-adapter.md).

`T6.3` is complete: six directly representable producer errors retain their
SPEC-008 mappings, while sink refusal maps only through the distinct render-
producer refusal origin. Invalid-envelope and contract-violation frame failures
map exactly; coordinator-impossible insufficient-capacity and producer-failed
forms cannot replace the retained producer error. All offer mappings require
mandatory abort and terminal effects first. See the
[render and offer mapping evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-6/render-offer-mapping.md).

`T6.4` is complete: all five operational primaries map to exact SPEC-003 facts
while retaining detecting context, the complete event set, and attempt
ordinal/limit. The adapter rejects primary-precedence mismatches, malformed
attempts, and mapping before mandatory effects. Its residual-policy input
admits every legal target while paced retry is limited to backpressure or
retryable refusal strictly below exhaustion. See the
[operational mapping evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-6/operational-mapping.md).

`T6.5` is complete: omitted, selected-and-accepted, saturated, dropped, and
failing diagnostic configurations preserve an identical complete execution
snapshot. Omitted records remain lazily unconstructed, and an attacking sink
cannot mutate authoritative state or invoke a client action after diagnostic
delivery begins. Failure Diagnostics remains a test-only dependency of the
execution failure adapter. See the
[diagnostic isolation evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-6/diagnostic-isolation.md).
Milestone 6 is complete; T7.1 is next.

`T7.1` is complete: the canonical loader requires every registered field and
explicit `none`, recursively validates stable symbolic identities, checks the
operational bitset and primary precedence, mirrors the legal summary matrix,
validates the closed endpoint script, and preserves reciprocal criterion/case
evidence rows. A temporary reference corpus proves rejection of missing fields,
forbidden identity representations, wrong precedence, illegal summaries, and
malformed endpoint scripts. See the
[canonical loader evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-7/canonical-loader.md).
T7.2 is next.

`T7.2` is complete: ten canonical cycle and input cases cover every active
phase, seal timing, ordering and capacity, atomic publication, dirty recovery,
at-most-once effects, per-source provenance and sequencing, cancellation and
resynchronization, both exhaustion paths, capture/release, replacement,
movement, disabled targets, and quiescence. See the
[cycle/input corpus evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-7/cycle-input-corpus.md).
T7.3 is next.

`T7.3` is complete: twelve canonical handoff cases cover accepted completion,
every legal called-body and no-body outcome, all illegal-pair collapse,
reservation and discard, post-return poisoning, operation-count mismatch,
exact retained producer errors, candidate lifetime, and the rule that
irreversible output requires accepted endpoint health. See the
[handoff corpus evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-7/handoff-corpus.md).
T7.4 is next.

`T7.4` is complete: seven recovery cases cover backpressure, checked retry
counts at every boundary, later-idle pacing, revision supersession, and every
terminal unavailable/quiescent path. The Signal Analyzer corpus records 80
explicit fact timestamps in four exact 20-fact windows, with one coalesced
wake, publication, and offer per opportunity and one pending-intent high-water.
See the
[recovery/signal corpus evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-7/recovery-signal-corpus.md).
T7.5 is next.

`T7.5` is complete: the canonical corpus retains all five finite owner values,
exact detecting contexts and mappings, first-failure precedence, all 32 cleanup
fault combinations, and static layout/allocation bounds. Fixture-only
instrumentation registers all required timing, retry, high-water, drop,
cancellation, operation, allocation, section, and link-map measurements without
an allocating carrier. See the
[owner/instrumentation evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-7/owner-instrumentation.md).
Milestone 7 is complete; T8.1 is next.

`T8.1` is complete: the consolidated audit fixes both internal target
dependency sets, rejects a public Execution product or declaration, limits
compiled imports to approved owners, proves portable declarations cannot
observe execution identity/context, and preserves input-adapter isolation. The
registered negative fixture names the real module, while placeholder targets,
compatibility shims, forbidden upward imports, and a second execution surface
remain rejected. See the
[interface audit evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-8/interface-audit.md).
T8.2 remains blocked on SPEC-013's production coordinators; T8.3 is next for
the currently available owner seams.

`T8.2` remains blocked because the SPEC-013 dynamic and static production
coordinator targets are absent. `T8.3` has integrated the available SPEC-010
typed presentation-fact admission seam, but remains blocked on the absent
SPEC-011 Interaction and SPEC-014 Backend endpoint targets. The
[owner integration status](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-8/owner-integration-status.md)
and fail-closed registry preserve these gates without substituting recording
fixtures. T8.4 is the next independent task.

`T8.4` has completed the four-compiler 31-value layout pass and both tracked
hardware-free toolchain probes. `T8.5` has completed all four standalone driver
preflights against one complete 35-case corpus. Neither task is complete:
production allocation and dynamic high-water evidence remain blocked on
SPEC-013, while production backend target inspection remains blocked on
SPEC-014. See the
[four-profile checkpoint](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-8/four-profile-checkpoint.md).

Plan completion will mean every task has a recorded disposition; it will not
mean SPEC-009 conforms or is `implemented`. The conformance report remains
`null` until `T8.6` creates it, and the Specification's final lifecycle
transition requires explicit human authorization.
