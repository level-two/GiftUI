---
spec: SPEC-011
feature: giftui-mvp-architecture
title: SPEC-011 Implementation Plan
status: active
owners:
  - codex
created: 2026-09-09
updated: 2026-09-12
related_design_notes:
  - ../implementation-designs/spec-011-target-bound-dispatch.md
conformance_report: null
related_future_work:
  - FW-021
related_explorations: []
related_spikes:
  - SPIKE-007
supersedes: null
superseded_by: null
---

# SPEC-011 Implementation Plan

> **Execution notice:** SPEC-006's approved action-primitive-with-content
> traversal operation and `DV-017` evidence are complete. The maintainer's
> 2026-09-12 instruction to proceed started SPEC-011 implementation.

> This plan derives work from the approved Button Interaction and
> Activation Contract, including its explicitly reapproved target-generation
> amendment. It orders implementation and evidence but does not amend the
> action-domain, model-target, generation, routing, dispatch, failure,
> publication, profile, or host contracts owned by that Specification and its
> authoritative dependencies.

## Authority and Scope

The governing contract is approved
[SPEC-011](../specs/spec-011-interaction.md). Its authority chain is accepted
[PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md),
approved [RFC-002](../rfcs/rfc-002-giftui-mvp-layered-architecture.md),
[RFC-004](../rfcs/rfc-004-run-cycle-and-frame-transaction.md), and
[RFC-011](../rfcs/rfc-011-bounded-application-actions.md), and accepted
[ADR-005](../adrs/adr-005-semantic-layout-render-boundary.md),
[ADR-006](../adrs/adr-006-shared-semantics-runtime-profiles.md),
[ADR-008](../adrs/adr-008-module-dependency-graph-and-package-topology.md),
[ADR-010](../adrs/adr-010-synchronous-one-shot-frame-handoff.md),
[ADR-011](../adrs/adr-011-serialized-run-cycle-and-publication.md),
[ADR-014](../adrs/adr-014-bounded-cross-layer-outcomes.md),
[ADR-015](../adrs/adr-015-layered-failure-disposition.md),
[ADR-016](../adrs/adr-016-non-authoritative-diagnostics.md),
[ADR-024](../adrs/adr-024-structurally-owned-observable-reference-state.md),
[ADR-025](../adrs/adr-025-coarse-model-owned-observable-invalidation.md),
[ADR-026](../adrs/adr-026-profile-equivalent-bounded-observable-state.md), and
[ADR-033](../adrs/adr-033-bounded-application-actions-and-model-target-dispatch.md).

Approved [SPEC-001](../specs/spec-001-signal-analyzer-reference-application.md)
owns the exact six-case Signal Analyzer action domain, handler, and application
intent mapping. Approved [SPEC-002](../specs/spec-002-portable-foundation.md),
[SPEC-003](../specs/spec-003-failure-outcomes-and-containment.md),
[SPEC-006](../specs/spec-006-declarative-view-semantics.md),
[SPEC-007](../specs/spec-007-layout.md),
[SPEC-008](../specs/spec-008-rendering.md),
[SPEC-009](../specs/spec-009-execution-cycle-and-frame-handoff.md), and
[SPEC-010](../specs/spec-010-observable-reference-state.md) supply the exact
portable values, failures, structural identity and traversal, resolved bounds
and clips, painter order, run-cycle admission/generations/capture, and
publishable observable-target generation consumed here. Approved
[SPEC-013](../specs/spec-013-runtime-profiles.md) owns the production runtime
coordinator and dynamic/static storage realization. Approved
[SPEC-015](../specs/spec-015-host-configuration.md) owns first-party limits,
immutable handler/root-target assembly, and connected integrations. This plan
implements SPEC-011-owned behavior at those seams without duplicating the
application or host owners.

The [MVP Scope](../MVP_SCOPE.md) requires the substantially shared Signal
Analyzer Presentation to provide Start, Stop, Clear, and three visible-window
controls, enforce their disabled states, and preserve observable updates across
macOS dynamic, macOS static, Raspberry Pi 1 ARMv6, and nRF52840 static
configurations. SPEC-011 is the Rank 2 interaction and bounded action-dispatch
delivery for that requirement. It does not authorize keyboard/focus/
accessibility input, richer gestures, multiple action domains or model targets,
dynamic callback conveniences, backend event sampling, production capacity
selection, deployment, or flashing.

Completed [SPIKE-007](../spikes/spike-007-static-action-storage-feasibility.md)
is feasibility evidence only. Its disposable callable protocol, tagged cases,
storage declarations, and capacities are not production authority. Its
reproducible result does establish an implementation risk: persisting an
escaping closure retains an allocator path, while finite tagged dispatch can
remain allocator-free.

## Current Repository State

- `GiftUI` exposes SPEC-006's exact `GiftUIAction` traversal category plus the
  SPEC-011 Button, typed payloads, disabled modifier, and borrowing handler
  protocol. Button stores one initializer-built label and traverses it through
  the approved action-with-content operation.
- `GiftUISemanticCore` stages each Button action at its stable identity before
  the stored label. `GiftUIInteraction` owns effective-disabled folding and
  handler-aware finite-code normalization without retaining a declaration,
  handler, or model.
- `GiftUIExecution` already owns `ActionGeneration`,
  `ObservableTargetGeneration`, `CapturedAction`, action-generation allocation,
  pointer capture, admission, mutation ordering, and one-shot commit seams from
  SPEC-009. Interaction must consume those exact values and must not create a
  second allocator, source limit, capture table, or phase machine.
- `GiftUIObservableState` already exposes a borrowed model-free
  `publishableTargetGeneration` view and candidate-discard seam. It does not
  expose a model to Interaction and must not gain an Interaction import. The
  target-composed current-model borrow required for dispatch remains a
  SPEC-011/SPEC-013/SPEC-015 coordinator integration.
- `Package.swift` now contains `GiftUIInteraction` with exactly `GiftUI`,
  `GiftUISemanticCore`, `GiftUILayout`, and `GiftUIExecution`, plus its focused
  test target. The failure adapter, runtime profiles, and first-party host
  targets remain downstream work owned by `T5`-`T7`.
- `Tests/ContractFixtures/SPEC011/` contains the closed declaration, semantic,
  candidate, gesture, dispatch, failure, migration, schema, and task-evidence
  inventories. The explicitly registered driver is intentionally fail-closed
  while `T5`-`T9` evidence is pending.
- Removed proof-of-concept `ActionID`, escaping-closure Button, runtime hit map,
  and platform dispatch paths remain migration evidence only. They must not be
  restored as compatibility layers or alternate production paths.

## Readiness Review

**Reviewed:** 2026-09-12

**Disposition:** Active after implementation and four-profile evidence for the
approved upstream SPEC-006 amendment. SPEC-011 was approved and explicitly reapproved after the coordinated
SPEC-009/SPEC-010 target-generation amendment. Every `IN-001` through `IN-013`
criterion maps once to ordered work and reproducible evidence below. The
action-primitive-with-content operation is a production prerequisite, not an
implementation choice owned by this plan.

After the SPEC-006 amendment is authoritative and implemented, the plan is
executable in dependency-aware slices. Portable declarations,
focused Interaction values/algorithms, recording oracles, failure mapping, and
driver scaffolding may proceed before production runtime profiles. Tasks that
consume resolved layout geometry wait for SPEC-007's production seam; tasks
that join all focused owners wait for SPEC-013's `GiftUIRuntimeCore`; exact
first-party capacities, Signal Analyzer handler assembly, and connected target
evidence wait for SPEC-015 and SPEC-001 implementation. These are explicit
implementation dependencies, not permission to add substitute owners.

If the pinned compiler cannot preserve the initializer-time stored-label
semantics, express the nonescaping borrowed model call, specialize the static
handler without a forbidden existential or allocator, or fit the exact record
and workspace within approved profile bounds, the affected task returns to
Specification or architecture review. The plan must not add closure retention,
type tokens, reflection, handler/model storage in records, historical hit maps,
retargeting, fallback dispatch, or relaxed generation semantics.

Implementation records are not registered in `docs/features.yaml`; the
feature already reports the implementation stage. Starting implementation
will separately change SPEC-011 to `implementing` and this plan to `active`.

## Task Dependencies and Affected Surfaces

Milestone numbers define the default order. A task may start only after every
listed prerequisite is satisfied.

| Work | Prerequisites | Primary affected surfaces | Parallel boundary |
| --- | --- | --- | --- |
| `T0.1`-`T0.4` | Approved SPEC-011 authority chain | `Tests/ContractFixtures/SPEC011/`, `Package.swift`, `scripts/contracts/`, SPEC-002 graph/migration fixtures | Fixture schemas, migration inventory, and driver scaffolding may proceed together; target-graph edits land only with compiling sources |
| `T1.1`-`T1.5` | `T0.1`, `T0.4`; present SPEC-006 traversal protocols | `Sources/GiftUI/`, `Tests/GiftUITests/`, public compile fixtures | Button, handler, disabled, and payload tests may proceed separately after exact API tokens are frozen; they do not wait for `GiftUIInteraction` or Layout |
| `T2.1`-`T2.5` | Relevant `T1.*`; complete SPEC-006 identity/result seam for production adaptation | `Sources/GiftUISemanticCore/`, semantic tests, declarations/candidates fixtures | Direct recording/malformed fixtures may precede the production-result adapter; domain validation waits for the assembled handler type seam |
| `T3.1`-`T3.6` | `T0.1`, `T2.*`, SPEC-002 geometry, SPEC-007 bounds/clips, SPEC-009 values; `T0.2` target edits land atomically with `T3.1` | `Sources/GiftUIInteraction/`, interaction tests, candidate fixtures | Value/limit declarations and storage probes may proceed beside fixture authoring; lifecycle/equality/generation tasks then run in order |
| `T4.1`-`T4.4` | Committed-record view from `T3.*`; SPEC-009 per-source capture owner | `Sources/GiftUIInteraction/`, `Sources/GiftUIExecution/` adapters where owned, gesture fixtures | Resolver logic and transition corpus may proceed together; Execution integration waits for both |
| `T5.1`-`T5.6` | `T2.*`-`T4.*`; SPEC-009/010 production seams; SPEC-013 runtime-core target | runtime coordinator, target-composed adapters, dispatch and candidate-publication fixtures | Candidate join and dispatch mechanics may be tested against one recording coordinator first; production integration waits for `GiftUIRuntimeCore` |
| `T6.1`-`T6.4` | Injectable owner failures and observable lifecycle from `T3`-`T5` | Interaction/failure adapter fixture, `GiftUIFailureExecution` integration, failures corpus | Local mapping and diagnostic-isolation fixtures may proceed in parallel after mandatory effects are observable |
| `T7.1`-`T7.5` | Complete focused oracle; SPEC-013 profile owners; SPEC-015/001 application owners for first-party claims | dynamic/static runtime storage, Signal Analyzer action/handler fixtures, normalized corpus | Equal-limit recording storage can precede production profiles; first-party assembly waits for approved owner implementations |
| `T8.1`-`T8.5` | Frozen complete corpus and repository-local toolchains | contract driver, allocation/value-layout/resource probes, cross-profile reports | Four profile commands may run independently; comparison consumes all four immutable reports |
| `T9.1`-`T9.5` | All hardware-free implementation/evidence; explicit authorization and available targets for connected work | package/repository gates, connected macOS/Pi/nRF fixtures, conformance report | Boundary audit may start early; connected evidence and conformance disposition wait for all production integrations |

## Acceptance-Criterion Matrix

The criterion text remains authoritative in SPEC-011. Every criterion appears
exactly once below.

| Criterion | Implementation tasks | Evidence | Status |
| --- | --- | --- | --- |
| `IN-001` — Exact `GiftUIAction`, qualified `Button`, handler, and `disabled` source compiles in all MVP profiles | `T1.1`-`T1.5`, `T7.4`, `T8.1`-`T8.3` | Exact public/package surface audit, declaration corpus, and four-profile compile reports | pending |
| `IN-002` — Six exact action normalizations/decodes; wrong type and invalid code dispatch nothing and map exactly | `T2.3`-`T2.5`, `T5.3`, `T5.4`, `T7.4`, `T8.2` | Action-domain/code corpus, dispatch transcript, and failure mapping | pending |
| `IN-003` — One stable identity and exact bounded value per Button without handler/model retention | `T1.2`, `T2.1`-`T2.4`, `T3.2`, `T8.4` | Semantic transcript, payload/borrow audit, record layout, and forbidden-retention scan | pending |
| `IN-004` — Exact clipped bounds, reverse painter order, and disabled blocking without retargeting | `T2.2`, `T3.3`, `T3.4`, `T4.1`, `T8.2` | Candidate and hit-resolution golden corpus | pending |
| `IN-005` — Identity/generation-only capture and cancellation of every invalid, stale, moved, disabled, removed, or rebound release | `T4.1`-`T4.4`, `T5.2`, `T8.2` | Capture-layout audit and complete gesture/commit interleaving transcript | pending |
| `IN-006` — Replacement after down/admission invokes neither model; failed replacement preserves the former binding | `T5.1`-`T5.5`, `T7.2`, `T8.2` | Observable-target replacement/removal/failure dispatch corpus | pending |
| `IN-007` — Valid activation dispatches once in SPEC-009 order to the borrowed current model and reports synchronously | `T5.2`-`T5.6`, `T7.4`, `T8.2` | Mutation-order, borrow-lifetime, exact-once handler, report, and later-fact transcript | pending |
| `IN-008` — Exact candidate lifecycle and all-or-nothing commit/discard/refusal behavior | `T3.3`-`T3.6`, `T5.1`, `T5.2`, `T8.2` | State-machine, fault-injection, generation-reservation, offer, and atomic-publication corpus | pending |
| `IN-009` — Exact error/cancellation precedence, mapping, mandatory effects, policy bounds, and no fallback/alias | `T3.5`, `T4.4`, `T5.4`, `T6.1`-`T6.4`, `T8.2` | Exhaustive individual/simultaneous failure matrix and diagnostic-isolation transcript | pending |
| `IN-010` — Equal-limit dynamic/static results and zero static heap allocation | `T7.1`-`T7.3`, `T8.2`-`T8.4` | Normalized profile comparison and allocation interposer reports | pending |
| `IN-011` — No forbidden Interaction imports/dependencies, reflection, unrestricted existential, or allocator | `T0.2`, `T3.2`, `T7.3`, `T8.4`, `T9.1` | Exact target graph, import-negative corpus, source/SIL/symbol/link-map audit | pending |
| `IN-012` — nRF52840 and ARMv6 ABI, fixed storage, stack, flash, RAM, direct dispatch, and forbidden-symbol evidence | `T7.3`, `T8.3`-`T8.5` | Cross-target compiler/ELF/link/resource reports and direct-switch inspection | pending |
| `IN-013` — Every staged record binds the exact publishable target generation before finish and observable non-publication discards Interaction once | `T3.4`-`T3.6`, `T5.1`, `T5.5`, `T7.2`, `T8.2` | Initial/preserved/replaced/discarded target-generation and exact-once discard transcript | pending |

## Milestones and Tasks

### Milestone 0: Freeze Scope, Package Boundaries, and Evidence Schemas

**Entry conditions:** SPEC-011 remains `approved`; its Proposal/RFC/ADR chain
remains authoritative; related approved Specifications retain their exact
ownership boundaries.

**Exit evidence:** Every criterion, dependency owner, fixture row, report field,
migration path, and driver failure condition is explicit before behavior is
claimed.

- [x] `T0.1` — Create `Tests/ContractFixtures/SPEC011/` with the five required
      `declarations.yaml`, `candidates.yaml`, `gestures.yaml`, `dispatch.yaml`,
      and `failures.yaml` corpora; an ordered fixture manifest; normalized
      transcript and resource schemas; a versioned `task-evidence.yaml` mapping
      every plan task to acceptance criteria, implementation/check paths,
      profiles, evidence, disposition, and blockers; and a README. Reject
      unknown/duplicate rows, unreferenced data, missing edges, and
      profile-private comparison fields. Distinguish host execution,
      cross-build/inspection, simulator, and connected-hardware evidence.
- [x] `T0.2` — Freeze the exact `GiftUIInteraction`, focused-test, and narrowly
      named interaction/failure-adapter target graph in dependency fixtures.
      Land each `Package.swift` target or edge only with its first compiling
      source, and complete this task only when all named targets and checks
      exist; this task does not require empty placeholder targets and does not
      block the portable Milestone 1 work. The exact production dependencies
      of `GiftUIInteraction` are `GiftUI`,
      `GiftUISemanticCore`, `GiftUILayout`, and `GiftUIExecution`; it must not
      import Observable State, runtime profiles, rendering implementation,
      backend, platform, driver, application, OS/RTOS, HAL, or hardware. Update
      SPEC-002 exact target/dependency fixtures atomically and add reverse-edge,
      forbidden-import, non-re-export, reflection, existential, allocator, and
      task/async negatives.
- [x] `T0.3` — Create `scripts/contracts/run-spec-011.sh --profile <profile>`
      with exactly `macos-dynamic`, `macos-static`, `raspberry-pi-armv6`, and
      `nrf52840-embedded`; register it explicitly in
      `scripts/contracts/driver-registry.tsv`. Fail closed for unavailable
      toolchains/SDKs, compiler/target/optimization mismatch, missing repository
      identity, absent commands/digests/layouts/limits/high-water values,
      allocation, dependency/ABI/resource/symbol failures, target inspection
      failure, or any required fixture/evidence marked missing. Use the
      repository's content-hashed immutable report identity, record dirty state
      without rejecting local iteration, and reject cross-profile comparison of
      different revisions or input-set hashes.
- [x] `T0.4` — Inventory every removed or residual PoC action identifier,
      escaping Button closure, direct model/use-case capture, runtime/backend/
      platform hit test, historical map, deferred event, and callback registry.
      Record adopt, adapt, replace-through-owner, downstream-owned,
      evidence-only, or already-absent dispositions and add regression scans
      preventing a second action, hit-routing, or dispatch path.

### Milestone 1: Implement the Portable Button and Disabled Surface

**Entry conditions:** `T0.1` and `T0.4` freeze exact declarations and migration
boundaries; SPEC-006's traversal categories are present. `T0.2` may remain
pending until the first compiling Interaction source lands.

**Exit evidence:** Portable source constructs the exact six qualified action
Buttons and disabled scopes with only `import GiftUI`; label construction and
payload values obey the exact declaration contract.

- [x] `T1.1` — Implement the exact generic `Button<Action, Label>` declaration,
      initializer, `View` conformance, and `ButtonSemanticPayload`. Evaluate the
      label builder once during initialization, store its result by value, and
      borrow that same value once as the fixed semantic child. Add poison-count
      tests proving semantic expansion never re-invokes the builder.
- [x] `T1.2` — Implement the `StaticString` and `BoundedText` title initializers
      as exact `Text`-label equivalents. Prove value/action preservation,
      qualified and ordinarily inferred cases, zero/maximum `UInt16` action
      codes, and the absence of closure, handler, model, type-token, runtime,
      or backend storage.
- [x] `T1.3` — Implement `DisabledSemanticPayload` and
      `View.disabled(_:)` as a semantic modifier with no identity of its own.
      Test nested `true`/`false` scopes and modifier order without introducing
      backend-specific state.
- [x] `T1.4` — Implement the exact public `GiftUIActionHandler` protocol and
      borrowing `handle` signature. Add positive handler compile fixtures and
      negative retained/escaping/replacement/registration shapes without
      introducing a runtime dependency into `GiftUI`.
- [x] `T1.5` — Compile the exact SPEC-011 and SPEC-001 six-Button source corpus
      in ordinary Swift and Embedded Swift modes, including rejected wrong raw
      widths, associated values, incompatible domains, invalid contextual
      inference, and callback-shaped compatibility attempts. Record public
      interface tokens and value layouts.

### Milestone 2: Complete Typed Semantic Lowering and Effective Disabled State

**Entry conditions:** Milestone 1 declarations compile; SPEC-006 supplies its
complete bounded expansion, stable identity, deterministic traversal, and
borrowed typed action occurrence.

**Exit evidence:** Each Button contributes one stable identity, one stored
label child, one exact typed action, and one effective enabled value in
deterministic semantic order, with no handler invocation or retained borrow.

- [x] `T2.1` — Extend the SPEC-006 production semantic path to recognize the
      Button payload exactly once, stage its action at the Button identity, and
      expand only its stored label in source order. Preserve all existing
      expansion capacity, reentrancy, atomicity, and borrow-lifetime rules.
- [x] `T2.2` — Fold enclosing/local disabled scopes as conjunction in
      Interaction's semantic-to-candidate lowering adapter. Emit no identity
      for the modifier; prove `disabled(false)` never overrides an ancestor and
      sibling scopes do not leak.
- [x] `T2.3` — At the first assembled-handler-aware coordinator boundary,
      validate every occurrence's concrete action type against
      `Handler.Action`, validate total raw-value round trip, and normalize to
      the exact two-byte `BoundedApplicationAction`. Dynamic mismatches return
      `incompatibleActionDomain`; static generated/compile-time validation
      rejects them without reflection or retained type tokens.
- [x] `T2.4` — Build exact recording transcripts for identity, action token,
      normalized code, label visitation, modifier chain, semantic order, and
      effective enabled state. Add poisoned semantic values and borrowed-
      lifetime probes proving no declaration, payload, label, handler, or model
      escapes its allowed scope.
- [x] `T2.5` — Add invalid-code and wrong-domain fault injection at the
      coordinator adapter. Verify validation precedes candidate append and
      frame offer, dispatches nothing, discards all candidates as required,
      and preserves the exact local error rather than substituting a semantic
      or execution error.

### Milestone 3: Implement Bounded Candidate and Committed Interaction State

**Entry conditions:** Typed semantic occurrences and effective enabled state
are available; SPEC-007 supplies exact Button bounds/logical clips and
SPEC-008 supplies canonical painter order; SPEC-009 values and generation
allocator are present.

**Exit evidence:** `GiftUIInteraction` owns the exact finite values, candidate
state machine, record comparison, hit map, and atomic committed state while
allocating no identity or retaining any upstream borrow.

- [x] `T3.1` — Implement the exact package value/protocol surface:
      `BoundedApplicationAction`, `InteractionLimits`, `BoundActionRecord`,
      `InteractionError`, candidate dispositions/results, gesture outcomes,
      `InteractionCandidateBuilder`, and `InteractionGestureResolver`. Prove
      the action value is exactly two bytes and `InteractionLimits` rejects
      zero values or hit regions greater than actions. Cross-owner validation
      against SPEC-009's `maximumCommittedActions` belongs to `T7.3`.
- [x] `T3.2` — Provide caller-owned/fixed storage contracts for staging and
      committed records/hit regions with finite counts and no arrays,
      dictionaries, unrestricted existentials, reflection, allocator, task,
      callable, handler, model, or borrowed semantic/layout storage on the
      static path. Record exact record/workspace/value sizes.
- [x] `T3.3` — Implement `beginCandidate`, ordered `append`, exact clip
      intersection, identity/geometry/capacity/unique-zero-based-paint-order
      validation, and empty-intersection retention without a hit region. A
      count equal to each limit succeeds; the first excess fails deterministically.
- [x] `T3.4` — Implement exact complete-record comparison. Copy a preserved
      record and generation only when identity, enabled state, clipped bounds,
      paint order, action code, and publishable target generation all match;
      otherwise stage a generation-pending replacement. Interaction must not
      allocate a generation or reproduce target lookup.
- [x] `T3.5` — Implement exactly-once `assignGeneration`, `finishCandidate`,
      preflight, first-error precedence, illegal-phase/reentry/duplicate checks,
      and immutable ready-for-offer state. Prove unresolved replacements fail
      before offer and generation exhaustion remains SPEC-009's exact
      `ExecutionError.identityExhausted` with required capture cancellation.
- [x] `T3.6` — Implement non-failing exactly-once
      `resolveCandidate(.commit(revision)/.discard)` as an infallible bounded
      swap or discard. Commit records, hit regions, and revision atomically;
      every failure/refusal/non-accepted offer preserves the previous complete
      committed state and releases all candidate borrows/workspace.

### Milestone 4: Implement Hit Resolution and Gesture Transitions

**Entry conditions:** Milestone 3 supplies immutable committed records/hit map;
SPEC-009 owns admission provenance, source sequencing, and capture storage.

**Exit evidence:** A stateless borrowed resolver returns only the legal
identity-generation transitions, while Execution owns and clears every
per-source capture.

- [x] `T4.1` — Implement `resolveDown(at:)` using exact clipped regions and
      greatest painter order. Return `.captured` only for the topmost enabled
      occurrence; a disabled topmost occurrence returns `.ignored` and blocks
      retargeting to an obscured action.
- [x] `T4.2` — Implement `resolveMove(_:at:)` so only the exact captured pair
      continues while inside its current matching region. Moving outside,
      record replacement/removal, disabled state, or generation mismatch
      cancels permanently; re-entry does not restore capture.
- [x] `T4.3` — Implement `resolveUp(_:at:)` so only a matching current
      identity/generation/enabled hit admits activation. Every other release
      cancels, and Execution clears capture after either result.
- [x] `T4.4` — Integrate the resolver with SPEC-009's admitted down/move/up
      sequence and capture table without duplicating provenance, ordinal,
      sequence, source, or capacity logic. Cover malformed, dropped,
      out-of-order, capacity-refused, stale-revision, moved, disabled, removed,
      rebound, and multi-revision interleavings; none may dispatch or retarget.

### Milestone 5: Join Publishable Targets and Dispatch Through the Current Model

**Entry conditions:** Focused Semantic, Layout, Interaction, Execution, and
Observable State seams exist; SPEC-013 supplies the production
`GiftUIRuntimeCore` composition owner before production integration lands.

**Exit evidence:** The coordinator binds every candidate action to the exact
publishable target generation and synchronously dispatches admitted actions
once through one immutable typed handler to a nonescaping borrow of the exact
current model.

- [x] `T5.1` — Implement the coordinator sequence that encounters the root
      observable location, obtains its exact SPEC-010
      `publishableTargetGeneration`, and appends that value to every action
      before finish. Missing generation fails as `missingModelTarget` and
      discards Interaction and Observable State candidates exactly once. Never
      substitute a prior live generation for first materialization or replacement.
- [x] `T5.2` — Integrate action-generation reservation and candidate resolution
      with SPEC-009 derivation and one-shot frame offer. Reserve only for
      `.requiresGeneration`, retire failed reservations according to SPEC-009,
      commit only on accepted handoff under its reserved revision, and discard
      on every other outcome.
- [x] `T5.3` — Implement `ActionModelTargetAccess`, `InteractionDispatcher`,
      and the target-composed adapter at the runtime/host seam. Immediately
      re-read and validate identity, action generation, enabled state, and
      target generation; decode through the statically known total
      `Handler.Action(rawValue:)`; borrow the matching current model for one
      nonescaping call; return exactly dispatched/cancelled/failure.
- [x] `T5.4` — Prove missing/changed records or target generations cancel
      ordinarily, invalid committed action codes return
      `.failure(.invariantViolation)`, and wrong-type/invalid-code candidate
      failures invoke no handler. No path may fall back, search another model,
      invoke a previous model, trap as its only behavior, or retain the handler
      or model in Interaction/capture state.
- [x] `T5.5` — Integrate SPEC-010 replacement/removal and failed/staged
      replacement. Cover replacement after down and after admission but before
      a later same-phase dispatch; invoke neither former nor replacement model.
      Prove failed replacement preserves the former target/record, so an
      otherwise still-current capture or a new valid gesture follows ordinary
      validation rather than being cancelled by an uncommitted replacement.
- [x] `T5.6` — Integrate dispatch into SPEC-009 `.mutating` after admitted
      state-change and completion facts. Prove admitted semantic-action order,
      at-most-once synchronous handling, a change report before handler return,
      coalesced dirtiness/wake behavior, and action-triggered repository
      callbacks entering only as later-cycle bounded facts.

### Milestone 6: Complete Failure Ownership and Mandatory Effects

**Entry conditions:** Every local error is injectable at its detecting boundary
and candidate/capture/dispatch side effects are observable in fixtures.

**Exit evidence:** All individual and simultaneous conditions preserve exact
origin/scope/containment, apply mandatory effects before residual policy, and
remain independent of diagnostics.

- [x] `T6.1` — Implement or complete the narrow owner adapter mapping every
      SPEC-011 local error to the exact SPEC-003 fact table while preserving
      Interaction versus coordinator origin. Do not translate SPEC-009
      generation exhaustion or rerank an already selected SPEC-009/SPEC-010
      failure.
- [x] `T6.2` — Implement the exact simultaneous-condition precedence:
      reentrancy, phase, domain, missing target, identity, geometry, action
      value, capacity, invariant. Exercise every individual case and every
      precedence pair at the same boundary.
- [ ] `T6.3` — Verify candidate-frame contained failures discard the complete
      candidate, preserve committed state, and follow SPEC-009's exact dirty/
      wake rule after mutation. Verify active-cycle/runtime safety-not-proven
      failures cancel affected captures, discard candidates, admit no later
      normal cycle, quiesce first, and expose only allowed residual policy.
- [ ] `T6.4` — Add no-fallback/no-retarget/no-partial-publication/no-alias and
      diagnostic-isolation fixtures. Diagnostic selection, loss, saturation,
      callback, or sink failure must not affect results, containment, action
      dispatch, candidate resolution, capture cleanup, or policy eligibility.

### Milestone 7: Realize Equal Profiles and the Signal Analyzer Domain

**Entry conditions:** One complete profile-neutral recording oracle passes;
SPEC-013 runtime targets and SPEC-015/SPEC-001 application assembly surfaces
exist before their respective production tasks land.

**Exit evidence:** Dynamic and static implementations consume the same focused
contracts, and the six Signal Analyzer cases produce identical bounded
interaction and dispatch transcripts at equal limits.

- [ ] `T7.1` — Integrate and verify SPEC-013's bounded dynamic Interaction
      candidate/committed storage. Heap-backed internals are permitted only within
      configured limits and must expose no unbounded success behavior or
      different error/cancellation semantics.
- [ ] `T7.2` — Integrate and verify SPEC-013's fixed/generated/caller-supplied
      static Interaction storage and direct typed dispatch. Use no heap,
      reflection, `Any`, arbitrary existential registry, task/thread,
      exception, Objective-C runtime, string identity, closure-to-tag
      synthesis, or dynamically growing collection.
- [ ] `T7.3` — Audit both profile workspaces, record/action/hit/source capacities,
      overlapping candidate/committed lifetimes, reset behavior, and startup
      validation, including rejection when Interaction `maximumActions`
      exceeds SPEC-009 `maximumCommittedActions`. Equal configured limits must
      accept/fail at the same row and normalize to byte-for-byte equivalent
      semantic fields.
- [ ] `T7.4` — Consume and verify SPEC-001's implemented
      `SignalAnalyzerAction` codes `0...5` and total
      `SignalAnalyzerActionHandler` switch: Start, Stop, Clear, and 1/2/5-second
      selection. SPEC-011 fixtures may reproduce the approved six-case mapping,
      but this task must not become the production application owner. Through
      SPEC-015 assembly, verify exactly one immutable handler bound to the one
      root `SignalAnalyzerViewModel`; no default, closure path, stored model, or
      profile-specific portable source.
- [ ] `T7.5` — Integrate SPEC-015's first-party action/hit capacities of six,
      one normalized input source, and startup graph validation without making
      those production values Interaction defaults. Add the exact acquisition
      and selected-window disabled-state application corpus.

### Milestone 8: Produce Four-Profile Contract and Resource Evidence

**Entry conditions:** The fixture manifest is frozen, all hardware-free
implementation tasks pass locally, and repository-managed toolchains validate
their pinned identities.

**Exit evidence:** All four exact driver commands produce complete immutable
reports; equal-limit transcripts match; cross-target images meet allocation,
ABI, storage, stack, flash, RAM, and forbidden-symbol requirements.

- [ ] `T8.1` — Run exact declaration/API/negative compilation for macOS
      dynamic and static, Raspberry Pi `armv6-unknown-linux-gnueabihf`, and
      nRF52840 `armv7em-none-none-eabi`. Record compiler identity, target, SDK,
      optimization, full commands, revision, and fixture digest.
- [ ] `T8.2` — Run the complete declarations/candidates/gestures/dispatch/
      failures corpus through recording, dynamic, and static paths. Compare
      only reports with the same repository revision and input-set hash, and
      compare exact symbolic identity, action, generation, target generation,
      enabled, geometry, paint order, candidate transition, gesture, dispatch,
      failure, and publication fields; reject missing edges and profile-private
      semantic differences.
- [ ] `T8.3` — Run static allocation interposition and workspace/stack
      high-water probes at the 32-action, 32-hit-region, four-source independent
      fixture bounds. Require zero heap bytes for construction, record storage,
      routing, capture, decode, lookup, borrow, and dispatch.
- [ ] `T8.4` — Record exact value layouts, record/candidate/committed workspace
      bytes, timing samples, source/SIL dependency audits, target graph,
      forbidden symbols, full link maps, section deltas, stack, flash, and RAM.
      Prove no closure box, reflection/type metadata discovery, unrestricted
      existential, allocator, handler/model retention, or indirect registry
      dispatch enters the static path.
- [ ] `T8.5` — Inspect final ARMv6 and nRF52840 artifacts. Require the exact Pi
      target, nRF board/module target, Cortex-M4F flags, VFP-register calling
      convention, fixed storage, and statically specialized direct dispatch.
      Keep downloads under `.toolchains/`, Pi artifacts under
      `.build/raspberry-pi/`, and Nordic artifacts under `.build/nrf52840/`;
      make no connected-hardware claim.

### Milestone 9: Integrate, Audit, and Prepare Conformance

**Entry conditions:** All applicable production and hardware-free evidence
tasks are complete. Connected operations require a separate explicit user
request and verified target identity.

**Exit evidence:** Repository gates pass, all downstream owner seams use the
SPEC-011 path, connected evidence is recorded distinctly, and the conformance
report has a disposition for every criterion.

- [ ] `T9.1` — Audit package boundaries and all SPEC-006/007/008/009/010/013/
      015 and Signal Analyzer integration points. Prove there is one action
      identity/generation allocator, one capture owner, one Interaction owner,
      one observable target-generation owner, one coordinator join, and no
      backend/platform/driver dispatch path or portable re-export.
- [ ] `T9.2` — Run `scripts/format-swift.sh`, the focused unit suites, exact
      `scripts/contracts/run-spec-011.sh` commands, dependency checks, and
      `scripts/test.sh --profile all-hardware-free`. Preserve standalone driver
      invocations and top-level explicit registration.
- [ ] `T9.3` — With explicit authorization, validate macOS physical pointer
      behavior and Raspberry Pi 1 connected input/display behavior against
      committed presentation provenance, exact hit regions, disabled overlap,
      movement cancellation, stale replacement, and exact-once dispatch.
      Require the Pi remote to report `armv6l` before deployment.
- [ ] `T9.4` — With explicit authorization, build, inspect, flash, and exercise
      the connected `nrf52840dk/nrf52840` target through its approved host/input/
      display stack. Record VFP ABI again and distinguish hardware-observed
      routing/dispatch evidence from hardware-free compilation. Never infer
      this result from simulator, host, or ELF evidence.
- [ ] `T9.5` — Create `docs/conformance/spec-011-conformance.md`, map every
      `IN-001` through `IN-013` criterion to reproducible evidence, record
      deviations/exceptions and connected-evidence status, link it from
      SPEC-011 and this plan, and request human conformance review. Do not mark
      SPEC-011 `implemented` without explicit human authorization.

## Design-Note Triggers

- Create `docs/implementation-designs/spec-011-candidate-record-lifecycle.md`
  when `T3.3` begins if live/candidate storage, exact preservation comparison,
  generation assignment, preflight, and infallible resolution span enough
  files or profile adapters that the state-swap invariant is not locally clear.
- Create `docs/implementation-designs/spec-011-target-bound-dispatch.md` when
  `T5.1` begins if the publishable-target join, admitted-action revalidation,
  nonescaping current-model borrow, replacement timing, and synchronous report
  route cannot be reconstructed from one coordinator implementation and its
  tests. This trigger fired when Milestone 5 began; the
  [current design note](../implementation-designs/spec-011-target-bound-dispatch.md)
  records the cross-owner handoff without changing the governing contracts.
- Record dynamic/static storage packing in a design note only when needed to
  explain a replaceable bounded mechanism or resource result. Do not turn
  private storage names, SPIKE-007's tagged callable, or first-party capacities
  into architecture.

## Integration and Validation Order

1. Freeze fixture schemas, target direction, and migration inventory; register
   the driver before any partial result can be mistaken for conformance.
2. Land the portable Button/disabled/handler declarations and initializer-time
   label tests before adapting Semantic Core.
3. Complete typed semantic action and disabled-state recording before layout
   geometry or action-domain normalization is joined.
4. Wait for SPEC-007's exact bounds/clip and SPEC-008's painter order; never
   create an Interaction-owned approximation.
5. Prove candidate lifecycle and exact record preservation before gesture
   routing, then prove gesture transitions before dispatch.
6. Consume SPEC-010's publishable target generation before candidate finish;
   prove initial materialization, replacement, absence, publication, and
   discard timing before current-model dispatch.
7. Establish one complete recording coordinator oracle before integrating
   SPEC-013 dynamic/static owners. Production runtime targets must reuse the
   focused algorithms rather than fork them.
8. Validate local errors and mandatory effects without diagnostics before
   comparing optional diagnostic projections or residual policy.
9. Integrate SPEC-001's six actions and SPEC-015 capacities only through their
   approved application/host owners; keep the 32/32/four independent resource
   fixture separate from first-party production values.
10. Run macOS dynamic, macOS static, Raspberry Pi ARMv6, and nRF52840
    hardware-free checks in that order, then compare normalized reports.
11. Collect connected macOS, Raspberry Pi, and nRF evidence only under explicit
    authorization. Deployment/flashing is never part of a routine host gate.
12. Prepare conformance only after all criteria, required profiles, resource
    checks, and connected input/display evidence have dispositions.

## Risks and Upstream Blockers

### Implementation risks

- Swift's generic payload and borrowing rules could cause the stored Button
  label, handler, or model borrow to escape or introduce hidden copies. Use
  poison lifetimes, SIL inspection, and allocation probes before profile work.
- Complete-record equality spans geometry, painter order, enabled state,
  action code, and two generations. Omitting one field can alias a stale press;
  use one centralized comparison and fault every field independently.
- Candidate/observable publication and frame acceptance have adjacent but
  distinct lifetimes. Fault injection must cover every exit after begin and
  prove exactly one Interaction resolution and required Observable State
  disposition.
- Dynamic storage can accidentally mask a missing static bound or accept a row
  that static rejects. Run all semantic fixtures at equal declared limits and
  compare the first failing operation, not only the final outcome.
- Reverse painter order and disabled overlap are easy to implement as
  search-past-disabled behavior. Keep the topmost occurrence authoritative and
  test empty clips, exact edges, and overlapping equal geometry.
- Static direct dispatch may still link allocation or metadata paths despite a
  total switch. Inspect the linked artifact and call path rather than relying
  on source shape or SPIKE-007 alone.
- Connected interaction evidence depends on presentation provenance and host
  calibration owned downstream. Record raw fixture inputs and revisions so a
  platform failure is not misreported as Interaction conformance.

### Upstream blockers

- SPEC-006's action-with-content amendment and `DV-017` evidence are complete;
  SPEC-007 layout geometry and SPEC-009 generation/capture seams are present
  and consumed by `T1`-`T4`. SPEC-010's publishable target seam remains reserved
  for the downstream coordinator join in `T5`.
- SPEC-013 and SPEC-015 are approved, and their production runtime/host
  targets are absent from the current implementation baseline.
  `T5` production
  coordinator integration, `T7` profile/first-party assembly, and assembled
  resource claims wait for those owners and their normal readiness gates;
  recording fixtures may proceed without claiming production integration.
- SPEC-001 owns the exact Signal Analyzer handler and application intents.
  SPEC-011 fixtures may encode the approved six-case mapping, but production
  application behavior and end-to-end reference-application claims wait for
  SPEC-001 implementation.
- A compiler failure of the exact public/package declarations, inability to
  borrow the current model nonescaping, need for retained type metadata or a
  closure box, or inability to meet finite static storage is an upstream
  contract/architecture issue. Do not relax the API, add a registry, or hide
  the divergence in this plan.
- SPEC-011 requires connected input/display evidence before its implemented
  transition. That evidence is operationally blocked until approved hosts and
  hardware are available and the user explicitly authorizes deployment or
  flashing; hardware-free completion must remain labeled separately.

## Deferred and Follow-up Work

- [FW-021](../future-work/fw-021-scoped-action-domains.md) retains multiple or
  nested action domains, independently replaceable model targets, child-to-
  parent action transformation, and reusable feature routing. No task in this
  plan implements or prefigures those facilities.
- Keyboard, focus, hover, accessibility activation, multi-touch, drag, long
  press, repeat, styles, animation, haptics, historical hit maps, deferred
  input, persisted action codes, and dynamic-only callback conveniences remain
  outside the approved MVP interaction contract and require separate lifecycle
  work if a concrete trigger appears.

## Completion Record

The maintainer's 2026-09-12 instruction started implementation after SPEC-006
`DV-017` became reproducibly passing. `T0.1`, `T0.3`, `T0.4`, and every task in
Milestones 1 through 4 are complete, each in its own task commit. The package
suite passes 298 XCTest tests and 435 Swift Testing cases; focused Interaction,
Semantic Core, and existing Execution capture suites pass. Package dependency,
fixture, declaration, migration, formatting, and driver-registration checks
also pass.

The portable GiftUI declarations cross-compile in the ARMv6 and nRF52840
Embedded Swift SPEC-006 driver at revision
`d5fce4483513e07f67357e2ebdac7bba68b4e634`, run identity
`d5fce4483513e07f67357e2ebdac7bba68b4e634-6e7089c05700ca66`. This is
hardware-free artifact evidence, not simulator or connected-hardware evidence.
`T0.2` remains pending until the narrowly named failure adapter lands with its
first compiling `T6.1` source. `T5`-`T9` and conformance remain pending under
their explicit runtime, host, profile, evidence, and authorization gates, so
this plan correctly remains `active` and SPEC-011 remains `implementing`.

During SPEC-013 T1.5 on 2026-09-12, the exact `ActionModelTargetAccess`
declaration landed in `GiftUIInteraction` as the declaration-only portion of
the plans' explicit integration handoff. SPEC-011 T5.3 subsequently completed
`InteractionDispatcher`, the target-composed adapter, and the required
dispatch behavior and evidence.

`T5.1` is complete: Runtime Core now performs one bounded semantic-order pass
over normalized Interaction occurrences, reads the exact post-encounter
publishable root target generation once, supplies it to every append, and
finishes a ready candidate only after all required generations are assigned.
Missing target generation and every later build failure discard both begun
candidates exactly once. Focused tests distinguish candidate-only and changed
publishable generations from any former live value; see the
[target-binding evidence](../../Tests/ContractFixtures/SPEC011/Evidence/t5-1-target-binding.md).

`T5.2` is complete: the runtime transaction reserves from SPEC-009's one
monotonic action-generation namespace only for replacements, commits
Interaction only for an accepted offer under its reserved presentation
revision, and discards every refusal or failure. Candidate-only generations
remain consumed and are recorded as retired; exhaustion discards both
candidates and cancels all captures. See the
[generation/offer evidence](../../Tests/ContractFixtures/SPEC011/Evidence/t5-2-generation-offer.md).

`T5.3` is complete: Interaction exposes the exact dispatcher contract and a
borrowed committed-record view, while Runtime Core supplies the target-composed
generic adapter. Dispatch immediately re-reads the committed record, validates
identity/generation/enabled/target state, totally decodes the configured action
type, and borrows the matching current model for one synchronous handler call.
See the
[current-model dispatch evidence](../../Tests/ContractFixtures/SPEC011/Evidence/t5-3-current-model-dispatch.md).

`T5.4` is complete: focused dispatch tests cover missing, changed, disabled,
removed, and corrupt committed state without fallback or handler invocation;
candidate validation tests prove wrong-domain and invalid-code values never
reach an offer or handler. See the
[dispatch cancellation evidence](../../Tests/ContractFixtures/SPEC011/Evidence/t5-4-dispatch-cancellation.md).

`T5.5` is complete: Runtime Core replacement-timing tests consume SPEC-010's
atomic live/staged target view. Committed replacement after down or after
admission invokes neither model, removal finds no retained former model, and
staged or failed replacement leaves the former route valid until publication.
See the
[replacement timing evidence](../../Tests/ContractFixtures/SPEC011/Evidence/t5-5-replacement-timing.md).

`T5.6` is complete: Execution supplies the bounded, one-shot production
mutation batch and Runtime Core composes its action step with the current-model
dispatcher. Focused integration proves category and action order, synchronous
change reporting, at-most-once application, dirty/wake coalescing, and deferral
of action-triggered repository facts to a later sealed batch. See the
[mutation dispatch evidence](../../Tests/ContractFixtures/SPEC011/Evidence/t5-6-mutation-dispatch.md).

`T0.2` and `T6.1` are complete together as required by the incremental target
rule. `GiftUIInteractionFailureAdapterFixture` and its focused tests landed
with their first compiling mapping source. The exact graph keeps Interaction
on `GiftUI`, Semantic Core, Layout, and Execution only; the narrow adapter
joins Interaction with Failure Core and Failure Execution without a reverse
edge. Its exhaustive table preserves the exact local error, detecting owner,
execution context, condition, origin, scope, and containment for all nine
cases, and mapping is unavailable before mandatory effects or for the wrong
detecting owner. See the
[boundary evidence](../../Tests/ContractFixtures/SPEC011/Evidence/t0-2-target-boundaries.md)
and [mapping evidence](../../Tests/ContractFixtures/SPEC011/Evidence/t6-1-failure-mapping.md).

`T6.2` is complete: the finite inline visible-failure set selects the exact
nine-case order without allocating or relying on raw-value order. Focused
tests exercise every individual condition, all 36 simultaneous pairs at the
same boundary, empty selection, and duplicate insertion. The canonical failure
fixture records the same pair matrix. See the
[precedence evidence](../../Tests/ContractFixtures/SPEC011/Evidence/t6-2-failure-precedence.md).
