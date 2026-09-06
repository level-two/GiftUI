---
spec: SPEC-009
feature: giftui-mvp-architecture
title: SPEC-009 Implementation Plan
status: active
owners:
  - codex
created: 2026-09-06
updated: 2026-09-06
related_design_notes: []
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

**Implementation finding, 2026-09-06:** SPEC-009's exact
`RunCycleFailure.renderProduction(RenderProductionError)` declaration is not
currently implementable through its permitted `GiftUIExecution -> GiftUI +
GiftUIRenderCore` dependency. Approved SPEC-008 assigns
`RenderProductionError` to `GiftUIRenderLowering`, and forbids Render Core from
importing that owner. This is an upstream contract contradiction, not a local
implementation choice. `T1.5` and any aggregate declaration that embeds that
case are paused for renewed Specification review; dependency-independent
Milestone 0 work may continue. No alias, duplicate error, upward import, or
type-erasing substitute is authorized.

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

- [ ] `T1.1` — Implement `RunCycleID`, `SemanticRevision`,
      `CandidateFrameID`, `ActionGeneration`, `ObservableTargetGeneration`,
      `ExecutionPhase`, `ExecutionLimits`, and `ExecutionContext` with exact
      raw widths, cases, validation, `Equatable`, `Hashable` where declared,
      and `Sendable` behavior. Prove every identity bit pattern is valid and
      no sentinel is introduced.
- [ ] `T1.2` — Implement `ExecutionWakeReasons`,
      `ExecutionWakeRequester`, and `PresentationPendingIntent`. Mask unknown
      option bits, validate retry-count semantics through owning transitions,
      and prove the value retains none of the forbidden payloads.
- [ ] `T1.3` — Implement frame provenance, disposition, stream-result,
      failure, refusal-origin, `FrameOfferResult`, and
      `SynchronousFrameEndpoint` declarations exactly. Test every valid and
      invalid failable construction and the nonescaping synchronous body/sink
      borrow at compile and runtime boundaries.
- [ ] `T1.4` — Implement admission kinds/results/outcomes, admission and
      opportunity protocols, admission summaries, action view, captured
      action, and their exact validation. Prove the captured value stores only
      the unmodified SPEC-006 identity-generation pair and the producer seam
      has no existential payload or profile-private entry point.
- [ ] `T1.5` — Implement local errors, semantic/frame/intent/operational
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

- [ ] `T2.1` — Implement one checked allocator per execution-owned namespace:
      raw zero first, exact successor, reservation retirement on abort, no
      reuse or wrap, and smallest-scope fail-closed exhaustion. Keep
      `ObservableTargetGeneration` allocation outside Execution as SPEC-010
      requires.
- [ ] `T2.2` — Prove reservation ordering for cycle, semantic, candidate,
      presentation, and action-generation identities, including every
      exhaustion point before and after publication. Record reserved,
      published, committed, aborted, and permanently retired values without a
      sentinel or persistent identity claim.
- [ ] `T2.3` — Implement the legal phase transition guard and exact context
      snapshot. Reject backward, repeated, suspended, invalid, and nested
      entry; preserve the active cycle for reentrancy and `cycle == nil` for
      idle cycle-ID exhaustion.
- [ ] `T2.4` — Exhaustively generate accepted and rejected
      `AdmissionSummary` and `RunCycleSummary` combinations. Check intrinsic
      invariants, limit equality/overflow, semantic/presentation consistency,
      operational exclusions, and the complete terminal-state matrix against
      recorded entry and reservation history.
- [ ] `T2.5` — Decide whether checked identity retirement plus the independent
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

- [ ] `T3.1` — Implement one accumulated wake-reason set and
      `wakeOutstanding` transition: one request on empty-to-nonempty, atomic
      take/clear at idle opportunity entry, a new transition during every
      later phase/finalization, masking, duplicate coalescing, and no
      synchronous run or scheduling result from the requester.
- [ ] `T3.2` — Implement bounded per-source sequence/ordinal state with exact
      zero/start/successor rules, active/cancelled/quiescent states, checked
      exhaustion, and independently enforceable target-gate versus runtime
      validation. Keep target-local physical phases outside runtime-visible
      sequence allocation until submission.
- [ ] `T3.3` — Implement down capture, move cancellation seam, release
      revalidation, and activation-candidate formation through the borrowed
      `ExecutionActionView`. Prove stable records survive unrelated commits
      and that removal, movement, disablement, generation change, target
      change, exhaustion, or ambiguity dispatches neither old nor replacement
      behavior.
- [ ] `T3.4` — Implement pointer, state-change, and completion submission with
      exact ownership transfer/refusal, context, capacity, disabled-
      completion, unavailable, invalid-value, provenance, cancellation, and
      wake behavior. Submission never applies a fact, dispatches an action, or
      promises current-cycle membership.
- [ ] `T3.5` — Implement exact ordered prefix selection and complete sealing:
      pointer validation and staged transitions, fact categories, same-cycle
      activations, dirty intent, then latest presentation recovery. Leave
      valid suffixes and after-seal arrivals queued in original order, record
      deferral, and request the next wake.
- [ ] `T3.6` — Fault every seal reservation, stale/malformed pointer,
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

- [ ] `T4.1` — Implement the canonical recording coordinator and closed event
      vocabulary for idle, admitting, mutating, deriving, publishing,
      offering, finalizing, result selection, wake transitions, and
      authoritative state. The fixture may inject focused owner results but
      must not create a second production semantic/layout/render contract.
- [ ] `T4.2` — Apply sealed state-change facts, completion facts, and semantic
      actions exactly once in category and producer/pointer order. Revalidate
      identity, action generation, enabled state, and target generation at the
      fixture dispatcher boundary; prove no admission-time dispatch and no
      replay after every later outcome.
- [ ] `T4.3` — Freeze mutation membership, coalesce invalidation, derive from
      stable current state, reserve staged action generations, and publish a
      complete semantic revision atomically. Prove unchanged/no-obligation
      cycles produce no candidate or frame.
- [ ] `T4.4` — Inject semantic, layout, action-table, routing, and immutable-
      render-input failure before publication. Discard all partial downstream
      results, preserve already-applied effects as dirty, request one later
      semantic wake, and rederive without replay, recursive entry, or partial
      publication.
- [ ] `T4.5` — Inject every finite fixture `OwnerFailure` at its focused
      boundary and every simultaneous later cleanup fault. Preserve the first
      exact value and detecting context, complete mandatory cleanup and a
      failure summary, and never replace it with a generic execution error or
      diagnostic.
- [ ] `T4.6` — Implement deterministic final result selection: failure before
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

- [ ] `T5.1` — Implement a recording `SynchronousFrameEndpoint` with finite
      sink capacity, pre-consumption reservation, body-call counting,
      operation/vocabulary validation, retained local producer error, and
      post-return borrow poisoning. It must retain only endpoint-owned derived
      values after acceptance and no candidate data after any other result.
- [ ] `T5.2` — Implement the runtime-side adapter from SPEC-008 production to
      `FrameStreamResult`, preserving the exact local render error. Normalize
      every body observation/result pairing according to SPEC-009, including
      all illegal pairings and the distinct render-producer versus endpoint
      refusal origins.
- [ ] `T5.3` — Implement candidate allocation and presentation-revision
      reservation at the exact new-publication and unchanged-recovery phase
      boundaries, then invoke `offer` at most once. Exercise candidate-ID,
      presentation-ID, invalid-envelope, required-facility, and direct
      contract failures before offer/body entry.
- [ ] `T5.4` — Commit accepted frame, reserved presentation revision, hit
      geometry, bound action records, and routing state atomically only after
      complete consumption/reservation. Abort all staged state for every
      non-accepted result, preserve prior committed routing, preserve new
      semantic publication, and prove irreversible output can only finish as
      accepted endpoint health.
- [ ] `T5.5` — Implement constant-space latest-revision pending intent.
      Preserve or start count zero for backpressure, checked-increment from
      one for retryable refusal, keep the two outcomes mutually exclusive,
      coalesce newer publication with `superseded`, and request one separately
      paced presentation wake without retaining a root, graph, frame, stream,
      operation, action, model, or borrow.
- [ ] `T5.6` — Exercise configured maxima `1...255`, exact below/equal-limit
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

- [ ] `T6.1` — Add `GiftUIFailureExecution` importing exactly
      `GiftUIFailureCore` and `GiftUIExecution`. Map every admission result and
      `ExecutionError` to its exact condition, origin, smallest proven scope,
      containment, and preserved `ExecutionContext` after mandatory pointer
      cancellation or cycle effects.
- [ ] `T6.2` — Preserve `.focusedOwner` as the concrete finite value through
      the common result. Add a fixture owner adapter that switches exhaustively
      over its own sum and proves `GiftUIFailureExecution` supplies neither a
      fallback mapping nor generic invalid/invariant/diagnostic translation.
- [ ] `T6.3` — Map exact render-production errors, frame-offer failures,
      illegal endpoint pairings, and both non-retryable-refusal origins.
      Reject legal-impossible `.frameOffer(.insufficientCapacity)` and
      `.frameOffer(.producerFailed)` coordinator results in favor of the
      retained producer error.
- [ ] `T6.4` — Map every operational primary result with exact origin, scope,
      context, attempt ordinal/limit, and complete event-set evidence. Prove
      mandatory abort, dirty, unavailable, cancellation, and quiescence
      effects precede total residual target policy.
- [ ] `T6.5` — Run diagnostics omitted, selected, saturated, dropped, and
      failing. Prove identical admissions, effects, revisions, identities,
      offers, wakes, retries, mappings, summaries, and authoritative state;
      reject any diagnostic callback or sink mutation/action path.

### Milestone 7: Freeze the Canonical Corpus and Resource Instrumentation

**Entry conditions:** Focused unit and recording fixtures pass for every
individual behavior. The canonical loader rejects any transcript or summary
that violates the shared schema or lifecycle matrix.

**Exit evidence:** All six required fixture files form one complete,
nonduplicated corpus and the driver records every required measurement.

- [ ] `T7.1` — Finish the manifest and canonical loader. Validate every shared
      field, explicit `none`, stable symbolic identity token, primary
      operational precedence, summary matrix, endpoint script, referenced
      case, and expected evidence row. Reject pointer/closure/string/hash/
      metatype-address or profile-private semantic identity comparisons.
- [ ] `T7.2` — Complete `cycles.yaml` and `input.yaml` for every phase,
      admission timing, ordering, capacity, publication, dirtiness,
      at-most-once, provenance race, sequence/ordinal, cancellation,
      resynchronization, exhaustion, capture, replacement, movement, disabled,
      and quiescence case required by SPEC-009.
- [ ] `T7.3` — Complete `handoff.yaml` for every legal/illegal endpoint/body
      pair, acceptance, refusal, reservation, discard, lifetime, operation
      count, producer error, contract violation, and irreversible-output
      case.
- [ ] `T7.4` — Complete `recovery.yaml` and `signal-analyzer.yaml` for
      backpressure, retryable refusal, pacing, count boundaries,
      supersession, terminal state, 20 facts between each of four
      opportunities, one coalesced wake/publication per opportunity, and at
      most one pending intent.
- [ ] `T7.5` — Complete `owner-failures.yaml` and instrumentation for every
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

- [ ] `T8.1` — Audit public/package interfaces, exact target dependencies,
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

- SPEC-009's normative focused-failure sum stores SPEC-008's
  `RenderProductionError`, but the two approved module contracts place that
  error in `GiftUIRenderLowering` while allowing `GiftUIExecution` to import
  only `GiftUIRenderCore`. `T1.5` is blocked until renewed Specification review
  supplies one coherent owner/dependency contract. Implementation must not
  resolve this by moving or duplicating the type, adding the forbidden
  Lowering import, or weakening the exact failure carrier.
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

The same 2026-09-06 dependency audit found that SPEC-008 owns
`RenderProductionError` in `GiftUIRenderLowering`, while SPEC-009 both embeds
that value in `RunCycleFailure` and prohibits `GiftUIExecution` from importing
Lowering. The affected `T1.5` work is paused for Specification review. This
blocker does not invalidate completed `T0.1` evidence or prevent independent
`T0.3` and `T0.4` work.

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

Plan completion will mean every task has a recorded disposition; it will not
mean SPEC-009 conforms or is `implemented`. The conformance report remains
`null` until `T8.6` creates it, and the Specification's final lifecycle
transition requires explicit human authorization.
