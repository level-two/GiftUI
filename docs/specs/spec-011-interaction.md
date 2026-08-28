---
id: SPEC-011
feature: giftui-mvp-architecture
title: Button Interaction and Activation Contract
status: approved
authors:
  - codex
created: 2026-08-26
updated: 2026-08-28
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-004
  - RFC-011
related_adrs:
  - ADR-005
  - ADR-006
  - ADR-008
  - ADR-010
  - ADR-011
  - ADR-014
  - ADR-015
  - ADR-016
  - ADR-024
  - ADR-025
  - ADR-026
  - ADR-033
related_specs:
  - SPEC-002
  - SPEC-003
  - SPEC-006
  - SPEC-013
  - SPEC-007
  - SPEC-008
  - SPEC-009
  - SPEC-010
related_future_work:
  - FW-021
related_explorations: []
related_spikes:
  - SPIKE-007
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPEC-011: Button Interaction and Activation Contract

> **Approval status:** Explicitly reapproved by the maintainer after the
> 2026-08-28 amendment binding candidate actions to SPEC-010's exact
> publishable target generation. The amended contract is authoritative for
> implementation.

## Summary

This Specification defines the portable finite typed `Button` action surface,
`disabled`, semantic action lowering, bounded committed action/model bindings,
hit routing, pointer capture, and synchronous dispatch through one statically
known handler to the current observable root model. It retains no closure or
model reference in a semantic result, committed action record, hit map, or
pointer capture.

## Scope

The contract covers one finite application action domain per assembled MVP
runtime; text and fixed-view labels; nested disabled state; fixed-width action
normalization and typed decoding; current-model target binding; exact record
replacement; hit routing and down/move/up gestures; final target revalidation;
mutation-phase handler dispatch; bounded failures; and cross-profile evidence.

It applies to macOS dynamic, macOS static, Raspberry Pi 1/Linux dynamic, and
nRF52840/Zephyr static configurations.

## Goals

- Provide Start, Stop, Clear, and visible-window selection through one
  portable source surface in every MVP profile.
- Prevent disabled, stale, removed, moved, rebound, or model-replaced controls
  from dispatching.
- Retain only semantic identity and action generation during pointer capture.
- Keep application handlers and model ownership out of semantic, layout,
  Interaction, backend, driver, and pointer-integration state.
- Make static action storage and dispatch allocation-free and finite.

## Non-goals

- Arbitrary associated action payloads, multiple/nested action domains,
  independently targeted child models, child-to-parent action transforms,
  environment dispatch, reducers, stores, or public bindings.
- Portable escaping closure actions or compiler/macro/source-generated
  closure-to-tag conversion.
- Keyboard, focus, hover, multi-touch, drag, long press, repeat,
  accessibility activation, button styles, animation, or haptics.
- Platform event sampling, calibration, presentation eligibility, queues,
  cycle scheduling, or action-generation allocation.
- Historical hit maps, deferred input, persisted action codes, or wire-format
  compatibility.

Optional callback syntax may be specified later for a dynamic-only convenience
module. It is not part of `GiftUI`, this contract, or static semantics.

## Dependencies

- SPEC-002 supplies checked geometry and normalized pointer values.
- SPEC-003 supplies bounded failure/outcome mapping.
- Revised SPEC-006 supplies the public `GiftUIAction` value protocol, semantic
  action identity, and a borrowed typed action payload without dispatch
  authority.
- SPEC-007 supplies resolved occurrence bounds and clips.
- SPEC-008 supplies paint order and visual behavior.
- Revised SPEC-009 supplies normalized pointer admission, runtime-wide
  `ActionGeneration`, the opaque `ObservableTargetGeneration` value type,
  capture, same-cycle semantic-action ordering, candidate publication, and
  `.mutating` dispatch phase.
- SPEC-010 supplies target-generation allocation and meaning, atomic model
  replacement and removal, current target lookup, and synchronous model-owned
  change reports.

## Related ADRs

- ADR-005 keeps semantic interaction and application dispatch above backends.
- ADR-006 requires equal portable behavior across dynamic and static profiles.
- ADR-008 requires the focused Interaction owner, portable `GiftUI` leaf, and
  runtime-coordinator join to remain compiler-enforced module boundaries.
- ADR-010 requires candidate routing state to commit only with accepted
  one-shot frame handoff and to remain unchanged on refusal.
- ADR-011 makes action application a serialized, at-most-once mutation-phase
  effect that is never replayed after failure or refusal.
- ADR-014 through ADR-016 require bounded outcome meaning, layered mandatory
  containment before residual policy, and diagnostics with no control-flow
  authority.
- ADR-024 through ADR-026 govern root-model ownership, replacement lifetime,
  and equivalent bounded observable-state behavior across profiles.
- ADR-033 requires bounded typed actions, coordinator-owned model-target
  binding, identity-generation capture, final target revalidation, and
  cancellation when model replacement or removal changes the binding.

## Terminology

**Action domain** is the one concrete `GiftUIAction` type selected by target
assembly for the runtime lifetime.

**Bounded application action** is the fixed two-byte case code derived from a
portable action value after validating its type against the assembled action
domain. It contains no type token, callable, or model reference.

**Bound action record** is one committed semantic action identity, action
generation, enabled state, exact hit geometry/order, bounded application
action, and observable target generation.

**Target access** is the target-composed synchronous seam that compares an
expected generation and borrows the currently installed root model only for a
nonescaping call.

**Activation** is one captured identity-generation pair admitted by a valid
release. **Dispatch** is final validation, typed decode, current-model borrow,
and handler call in `.mutating`.

## Public Contract

```swift
public struct Button<Action: GiftUIAction, Label: View>: View {
    public init(action: Action, @ViewBuilder label: () -> Label)
}

public extension Button where Label == Text {
    init(_ title: StaticString, action: Action)
    init(_ title: BoundedText, action: Action)
}

public extension View {
    func disabled(_ disabled: Bool) -> some View
}

public protocol GiftUIActionHandler {
    associatedtype Action: GiftUIAction
    associatedtype Model: _GiftUIObservableReference
    mutating func handle(_ action: Action, model: borrowing Model)
}
```

SPEC-006 owns the `GiftUIAction` protocol and finite value rules. The concrete
action type selected by assembly is the domain. SPEC-001 owns the exact Signal
Analyzer domain and mapping.

All portable Buttons in one assembled runtime MUST use the configured handler's
exact `Action` type and domain. A qualified case such as
`SignalAnalyzerAction.start` is guaranteed. Contextual shorthand such as
`.start` is conforming only where ordinary Swift inference accepts it.

The `Button` initializer evaluates `label` exactly once before the initialized
declaration value becomes available and stores the resulting `Label` value.
Semantic expansion borrows that stored label exactly once as the Button's fixed
semantic child; it MUST NOT invoke the source builder again. Title initializers
lower exactly as equivalent `Button(action:) { Text(...) }` declarations.

`disabled(true)` disables every descendant action. `disabled(false)` does not
override an ancestor. Effective enabled state is the conjunction of all
enclosing and local scopes and is independent of backend behavior.

The handler protocol is target-composition SPI exposed from `GiftUI` so an
application target can supply it. Portable views do not hold, discover, or
invoke a handler. `handle` is synchronous and nonescaping; it MUST NOT retain,
register, replace, or escape `model`.

## Module Contract

`GiftUI` owns the public declarations and typed semantic payloads. It imports
no runtime, state, Interaction, backend, platform, or application module.

`GiftUISemanticCore` borrows typed Button payloads, assigns action identity,
and stages the bounded value in its successful result. It does not bind a
model target or import Interaction/Observable State.

`GiftUIInteraction` owns effective enabled lowering, bound records, hit maps,
pointer gesture resolution, local errors, and recording fixtures. It may
import `GiftUI`, `GiftUISemanticCore`, `GiftUILayout`, and `GiftUIExecution`.
It MUST NOT import `GiftUIObservableState`, a runtime profile, application
model, backend, rasterizer, platform, driver, OS/RTOS, HAL, or hardware target.

The runtime coordinator is the first owner that may join Semantic, Layout,
Rendering, Interaction, and Observable State contracts. It supplies canonical
painter order to Interaction without an Interaction-to-Rendering import and
owns the immutable handler, configured action domain, root target access,
action/target binding, final dispatch validation, and current-model borrow.
Handler type, action type, and target location are immutable after assembly.

Backends receive normalized render operations only. Input integrations stamp
and submit normalized events only. Neither may see or invoke actions, handlers,
target generations, hit maps, or models.

## Types / APIs

```swift
package struct BoundedApplicationAction: Equatable, Hashable, Sendable {
    package let code: UInt16
    package init(code: UInt16)
}

package struct ButtonSemanticPayload<Action: GiftUIAction, Label: View>:
    _GiftUISemanticActionPayload {
    package let label: Label
    package let action: Action
    package var _giftUIAction: Action { get }
}

package struct DisabledSemanticPayload: _GiftUISemanticModifierPayload,
    Equatable, Sendable {
    package let isDisabled: Bool
}

package struct InteractionLimits: Equatable, Sendable {
    package let maximumActions: UInt16
    package let maximumHitRegions: UInt16
    package init?(maximumActions: UInt16,
                  maximumHitRegions: UInt16)
}

package struct BoundActionRecord<Identity>: Equatable, Sendable
where Identity: Equatable & Sendable {
    package let identity: Identity
    package let generation: ActionGeneration
    package let isEnabled: Bool
    package let hitBounds: Rect
    package let paintOrder: UInt16
    package let action: BoundedApplicationAction
    package let targetGeneration: ObservableTargetGeneration
}

package enum InteractionError: UInt8, Equatable, Sendable {
    case capacityExhausted = 0
    case invalidIdentity = 1
    case invalidGeometry = 2
    case invalidPhase = 3
    case reentrancyViolation = 4
    case invariantViolation = 5
    case incompatibleActionDomain = 6
    case invalidActionValue = 7
    case missingModelTarget = 8
}

package enum InteractionCandidateDisposition: Equatable, Sendable {
    case commit(PresentationRevision)
    case discard
}

package enum InteractionCandidateAppendResult: Equatable, Sendable {
    case preserved
    case requiresGeneration
    case failure(InteractionError)
}

package enum PointerGestureOutcome<Identity>: Equatable, Sendable
where Identity: Equatable & Sendable {
    case captured(CapturedAction<Identity>)
    case continued(CapturedAction<Identity>)
    case activationAdmitted(CapturedAction<Identity>)
    case cancelled
    case ignored
}

package enum InteractionDispatchResult: Equatable, Sendable {
    case dispatched
    case cancelled
    case failure(InteractionError)
}

package protocol InteractionCandidateBuilder {
    associatedtype Identity: Equatable & Sendable
    mutating func beginCandidate(
        limits: InteractionLimits
    ) -> InteractionError?
    mutating func append(
        identity: Identity,
        isEnabled: Bool,
        bounds: Rect,
        clip: Rect,
        paintOrder: UInt16,
        action: BoundedApplicationAction,
        targetGeneration: ObservableTargetGeneration
    ) -> InteractionCandidateAppendResult
    mutating func assignGeneration(
        _ generation: ActionGeneration,
        to identity: Identity
    ) -> InteractionError?
    mutating func finishCandidate() -> InteractionError?
    mutating func resolveCandidate(
        _ disposition: InteractionCandidateDisposition
    )
}

package protocol InteractionGestureResolver {
    associatedtype Identity: Equatable & Sendable
    borrowing func resolveDown(at point: Point)
        -> PointerGestureOutcome<Identity>
    borrowing func resolveMove(
        _ captured: CapturedAction<Identity>, at point: Point
    ) -> PointerGestureOutcome<Identity>
    borrowing func resolveUp(
        _ captured: CapturedAction<Identity>, at point: Point
    ) -> PointerGestureOutcome<Identity>
}

package protocol ActionModelTargetAccess {
    associatedtype Model: _GiftUIObservableReference
    borrowing func currentGeneration() -> ObservableTargetGeneration?
    mutating func withCurrentModel(
        matching generation: ObservableTargetGeneration,
        _ body: (borrowing Model) -> Void
    ) -> Bool
}

package protocol InteractionDispatcher {
    associatedtype Identity: Equatable & Sendable
    mutating func dispatch(_ captured: CapturedAction<Identity>)
        -> InteractionDispatchResult
}
```

`BoundedApplicationAction` MUST occupy exactly two bytes. Its initializer
stores the exact value and has no validity authority; dispatch performs total
`Action(rawValue:)` decode. `BoundActionRecord` uses inline bounded
storage and MUST NOT persist an existential or generic declaration value.

Both Interaction limits MUST be nonzero. `maximumActions` MUST be no greater
than SPEC-009's configured `maximumCommittedActions`.
`maximumHitRegions` is independently owned by Interaction and MUST be no
greater than `maximumActions`, because one Button occurrence contributes at
most one clipped rectangular region. SPEC-009's
`maximumActiveInputSources` separately bounds per-source sequence/capture
storage; Interaction owns no duplicate source limit. A count equal to its
limit succeeds. `paintOrder` is zero-based and unique per candidate. Overflow
is candidate failure.

`beginCandidate` starts one empty staging transaction. Every successful
candidate calls `finishCandidate` exactly once before frame offer and then
`resolveCandidate` exactly once: `.commit(revision)` only for the accepted
handoff's reserved `PresentationRevision`, otherwise `.discard`. Any failure
after begin calls `.discard` exactly once. Successful finish proves that either
resolution can complete without allocation or further fallible work;
resolution itself is non-failing. Reentry returns `.reentrancyViolation`;
append/assignment before begin, duplicate identity or paint order, and finish
twice return `.invalidPhase` or `.invariantViolation` before offer as specified
under Error Handling. A conforming coordinator never requests resolution
outside the legal ready state. Candidate storage retains no borrowed semantic,
layout, observable-state, or handler value after resolution.

`append` validates identity, geometry, capacity, and paint order and computes
the exact clipped hit bounds before comparing the coordinator-validated action
code and target generation with the same identity's committed record. It returns
`.preserved` only after copying that exact record and generation into candidate
storage. Absence or any changed field stages a generation-pending replacement
and returns `.requiresGeneration`. The coordinator then reserves one fresh
SPEC-009 generation and calls `assignGeneration` exactly once for that identity.
A `.failure` stages nothing for that occurrence and requires complete candidate
discard. `finishCandidate` rejects any unresolved replacement as
`.invalidIdentity`. Interaction never allocates a generation, and the
coordinator never reproduces Interaction's geometry or record comparison.

`InteractionGestureResolver` is a stateless borrowed view over the committed
records and hit map. Execution owns every per-source capture and applies the
returned transition. `.captured`, `.continued`, and
`.activationAdmitted` carry exactly the captured identity-generation pair;
`.cancelled` and `.ignored` carry none. Down can return only `.captured` or
`.ignored`, move only `.continued` or `.cancelled`, and up only
`.activationAdmitted` or `.cancelled`.

`ActionModelTargetAccess` belongs to the target-composed coordinator adapter,
not `GiftUIObservableState` or `GiftUIInteraction`. Its body is nonescaping and
may run only when `matching` equals the current live generation. It returns
`true` exactly when it invokes the body once; absence, removal, or mismatch
returns `false` and invokes nothing.

## Behavior

### Semantic and layout lowering

Expansion visits each Button once, associates the exact SPEC-006 action
identity, validates its concrete action type against the assembled handler's
`Action`, and normalizes it to `BoundedApplicationAction(code:
action.rawValue)`. Before append, the coordinator requires
`Handler.Action(rawValue: action.rawValue) == action`; failure is
`invalidActionValue` and discards the candidate. It does not invoke or retain a
handler. The stored label expands in source order. `disabled` creates no
semantic identity.

The candidate builder traverses actions in deterministic semantic order. The
hit region is exactly the SPEC-007 Button bounds intersected with its published
logical clip. Empty intersection retains the record but creates no hittable
region. Overlapping regions resolve by greatest `paintOrder`; if that topmost
occurrence is disabled, the down is ignored. A disabled painted occurrence
therefore blocks retargeting through itself to an obscured action beneath.

After the owning state location has been encountered successfully, the
coordinator obtains its `publishableTargetGeneration` from SPEC-010 before
appending any action. It MUST NOT substitute the previous live generation for
a first-materialized or otherwise changed candidate target. No publishable
generation returns `missingModelTarget` and discards the complete Interaction
and Observable State candidates. Every action occurrence must have the exact
configured `Handler.Action` type. Dynamic validation may reject a mismatch as
`incompatibleActionDomain`; static composition MUST reject it during generated
or compile-time graph validation without reflection or a stored type token.

### Candidate and generation behavior

Complete bound-record equality includes identity, enabled state, exact hit
bounds, paint order, action code, and target generation. `append` MAY preserve
the committed `ActionGeneration` only when every one of those fields is equal.
Any changed field, missing record, or newly substituted record returns
`.requiresGeneration`; the coordinator reserves a fresh runtime-wide
generation and supplies it through `assignGeneration`.

Capacity, geometry, action-domain, action-value, target, or generation failure
discards the whole candidate. The committed table, hit map, action values,
target generations, and action generations remain unchanged. Frame refusal
likewise preserves former committed interaction state. Accepted handoff
atomically commits records and hit regions under its `PresentationRevision`.

Removed records release no captured resource because records contain no
callable or model. Generation exhaustion is SPEC-009
`ExecutionError.identityExhausted`, not an `InteractionError`. The coordinator
discards the Interaction candidate after SPEC-009 performs its required
capture cancellation and fail-closed runtime disposition; no generation or
captured pair is aliased.

### Pointer gesture

SPEC-009 owns provenance, source, sequence, ordinal, phase admission, and the
per-source capture table. For an admitted down, Execution calls
`resolveDown(at:)`; a topmost enabled hit returns `.captured` with only its
semantic identity and action generation. No hit or a disabled topmost hit
returns `.ignored`.

For move, Execution passes its current capture to `resolveMove`; `.continued`
returns that same pair while the pointer remains inside the captured action's
current hit region. `.cancelled` clears it permanently, and re-entry does not
restore it. For up, `resolveUp` returns `.activationAdmitted` only inside the
same current region when identity, action generation, and enabled state still
match. Execution emits that pair into the same sealed cycle and clears capture.
Every other up returns `.cancelled` and clears capture.

A removed, disabled, moved, rebound, model-replaced, stale, malformed, dropped,
out-of-order, or capacity-refused sequence dispatches nothing. A committed
revision may advance without cancellation only when the exact complete bound
record and generation remain and current hit/enabled checks pass.

### Dispatch and model replacement

For each admitted captured pair, the dispatcher immediately re-reads the
current bound record and revalidates semantic identity, action generation,
enabled state, and target generation in SPEC-009 `.mutating`. A missing or
mismatched record returns `.cancelled` and invokes no handler.

The dispatcher decodes `Handler.Action(rawValue: code)` against the statically
known action type. An invalid code is a pre-publication error during candidate
build. If detected in committed state, dispatch returns
`.failure(.invariantViolation)` and invokes nothing. A missing record, changed
identity/generation/enabled state, or target mismatch is ordinary
`.cancelled`; a complete successful handler call returns `.dispatched`.

Finally, `ActionModelTargetAccess.withCurrentModel(matching:)` compares the
record target generation to the current live generation. Mismatch or absence
returns `false`; dispatch returns `.cancelled` and invokes neither former nor
replacement model. Success borrows the current model and calls
`handler.handle(action, model:)` exactly once. Dispatch is synchronous,
non-suspending, and ordered after admitted state-change and completion facts.

Every successful observable mutation performed by the handler must report
through SPEC-010 before `handle` returns. A repository callback caused by an
action ends at bounded fact admission and may affect a model only in a later
cycle; it cannot reenter current dispatch.

Successful model replacement allocates a fresh SPEC-010 target generation.
The next candidate replaces continuing records and allocates fresh action
generations. A press captured before replacement fails release validation after
that candidate commits. If replacement occurs after admission but before a
later action dispatch in the same mutation phase, final target validation
cancels the later action. Neither former nor replacement model is invoked.
Published removal behaves the same. Failed or staged replacement preserves the
former generation and records.

## State / Lifecycle

Candidate storage follows this exact transaction:

```text
idle --beginCandidate--> staging --finishCandidate--> ready-for-offer
  ^            | failure/discard              | discard/non-accepted
  |            +------------------------------+
  +---- resolveCandidate(commit(revision)) <-- accepted handoff
```

Only `staging` accepts `append` and `assignGeneration`. `finishCandidate`
requires every replacement to have a generation and performs every capacity
and commit-storage preflight. `ready-for-offer` is immutable until resolution.
Commit installs the complete table, hit map, and revision by an infallible
bounded state swap; discard releases the complete candidate. Both return to
`idle`. A conforming coordinator MUST call only the transitions shown and MUST
resolve every begun candidate exactly once.

Per-source gesture state follows:

```text
idle --down hit/enabled--> captured --move inside--> captured
  |                            |  \--move outside/error--> cancelled
  |                            \--valid up--> admitted
  |                                      \--target current--> dispatched once
  |                                      \--target changed--> cancelled
  \--down miss/disabled--> ignored
```

There is at most one active sequence and capture per configured source.
Cancellation clears capture and retains no action value, target generation,
callable, handler, or model.

## Capability Requirements

This contract adds no Capability or Trait. The action domain, handler, and root
model binding are required immutable assembly components. Pointer availability
and production capacities belong to host configuration.

## Backend Requirements

Backends MUST NOT receive Buttons, disabled scopes, action values, handlers,
hit maps, records, captures, target generations, or models. Input integrations
MUST NOT hit-test, decode, bind, borrow a model, or dispatch.

## Error Handling

`GiftUIInteraction` produces the geometry, capacity, identity, gesture, and
phase cases below. The target-composed coordinator adapter produces the
action-domain, action-value, and missing-target cases while building or
dispatching through this contract. Sharing the closed result vocabulary does
not authorize an Interaction import of Observable State or application code.

| Local error | condition | origin | scope | containment |
| --- | --- | --- | --- | --- |
| `capacityExhausted` | `.capacityExhausted` | `.interaction` | `.candidateFrame` | `.contained` |
| `invalidIdentity` | `.invalidIdentity` | `.interaction` | `.candidateFrame` | `.contained` |
| `invalidGeometry` | `.invalidValue` | `.interaction` | `.candidateFrame` | `.contained` |
| `incompatibleActionDomain` | `.invalidValue` | `.interaction` | `.candidateFrame` | `.contained` |
| `invalidActionValue` | `.invalidValue` | `.interaction` | `.candidateFrame` | `.contained` |
| `missingModelTarget` | `.invalidIdentity` | `.observableState` | `.candidateFrame` | `.contained` |
| `invalidPhase` | `.invalidPhase` | `.interaction` | `.activeCycle` | `.safetyNotProven` |
| `reentrancyViolation` | `.reentrancyViolation` | `.interaction` | `.activeCycle` | `.safetyNotProven` |
| `invariantViolation` | `.invariantViolation` | `.interaction` | `.runtime` | `.safetyNotProven` |

Ordinary cancellation due to changed target generation is not a failure fact.
Errors never dispatch a fallback, retarget an event, publish a partial table,
preserve an invalid binding, or trap as their only behavior.
SPEC-009 generation exhaustion remains its exact
`ExecutionError.identityExhausted` mapping and MUST NOT be translated into the
Interaction vocabulary.

When multiple local conditions are simultaneously visible at one boundary,
Interaction selects in this order: `reentrancyViolation`, `invalidPhase`,
`incompatibleActionDomain`, `missingModelTarget`, `invalidIdentity`,
`invalidGeometry`, `invalidActionValue`, `capacityExhausted`, then
`invariantViolation`. An already-selected SPEC-009 or SPEC-010 error retains
its owning contract's precedence and is not re-ranked here.

Every candidate-frame contained failure discards the complete candidate,
preserves the prior committed record/hit-map/revision state, and follows
SPEC-009's exact dirty/wake rule when mutation has already occurred. No
residual policy call may reinterpret it as a partial success. An active-cycle
or runtime safety-not-proven failure cancels affected captures, discards
candidate state, admits no later normal cycle, and permits only
`quiesceAffectedScope` or an already configured `invokeFatalHook` after
quiescence. The first adapter importing both the producer contract and
`GiftUIFailureCore` performs mapping only after these mandatory effects and
preserves the exact local error and execution context. Diagnostic selection,
delivery, loss, or saturation cannot change any of these effects or results.

## Performance Requirements

Candidate construction is linear in action count. Hit resolution is bounded by
`maximumHitRegions`; per-source sequencing is constant-space; target comparison,
decode, and six-case Signal Analyzer dispatch are constant-time.

The independent fixture uses 32 actions, 32 hit regions, and four sources.
Static construction, record storage, routing, capture, decode, target lookup,
model borrow, and dispatch MUST allocate zero heap bytes. Both profiles record
stack, workspace, record size, flash, RAM, and timing high-water evidence.

## Compatibility

Proof-of-concept source using `ActionID` or `Button(action: () -> Void)` must
migrate to a finite `GiftUIAction` enum. Action codes, target generations,
record layout, and action generations are build-local and not persisted.

Dynamic-only callback conveniences, if later specified, must adapt through a
separately bounded dynamic domain and cannot affect portable/static semantics.

## Testing Requirements

Provide one checked-in driver with these exact repository-root invocations:

```text
scripts/contracts/run-spec-011.sh --profile macos-dynamic
scripts/contracts/run-spec-011.sh --profile macos-static
scripts/contracts/run-spec-011.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-011.sh --profile nrf52840-embedded
```

`Tests/ContractFixtures/SPEC011/` MUST contain:

- `declarations.yaml` for exact qualified source, initializer-time label
  evaluation, all six actions, and rejected domains/codes;
- `candidates.yaml` for limits, paint order, every replacement field,
  generation preservation/reservation, first target materialization,
  publishable-target replacement, finish, commit, discard, and refusal;
- `gestures.yaml` for clipped/disabled overlap plus every legal and cancelled
  down/move/up transition through `InteractionGestureResolver`;
- `dispatch.yaml` for model replacement/removal before release and after
  admission, exact-once order, synchronous reporting, and later fact admission;
  and
- `failures.yaml` for every local error, SPEC-009 generation exhaustion,
  mandatory containment, and no fallback, retarget, partial publication, or
  diagnostic control-flow effect.

Recording, dynamic, and static fixtures MUST compare exact symbolic identity,
action token, generation, target generation, enabled state, geometry,
paint-order, candidate transition, gesture outcome, dispatch result, failure,
and publication fields. They MUST NOT compare pointers, type metadata, hashes,
or profile-private storage bytes except in explicit value-layout evidence.

The driver MUST fail on unavailable toolchains/SDKs, unknown or duplicate
fixture cases, unreferenced fixture data, transcript mismatch, missing edge
coverage, allocation, dependency, ABI, value-layout, stack, flash, or RAM
violations, or target-inspection failure. It records compiler identity,
repository revision, full command lines, fixture-manifest digest, value
layouts, capacity/workspace/stack high-water values, heap allocation count,
timing samples, section deltas, forbidden-symbol inspection, and link maps.
Connected input/display evidence remains an implemented-conformance gate.

## Acceptance Criteria

- [ ] **IN-001:** Exact `GiftUIAction`, qualified `Button`, handler, and
  `disabled` source compiles in all MVP profiles.
- [ ] **IN-002:** All six actions normalize/decode exactly; wrong-type and
  invalid-code cases dispatch nothing and map exactly.
- [ ] **IN-003:** Semantic transcripts contain one stable identity and exact
  bounded value per Button without handler/model retention.
- [ ] **IN-004:** Hit fixtures use exact bounds, clip, and reverse painter order;
  disabled occurrences cannot retarget through themselves.
- [ ] **IN-005:** Capture stores only identity/action generation and every
  invalid, stale, moved, disabled, removed, or rebound release dispatches
  nothing.
- [ ] **IN-006:** Model replacement after down or admission invokes neither
  model; failed replacement preserves the former binding.
- [ ] **IN-007:** Valid activation dispatches once in SPEC-009 order to a
  borrowed current model and synchronously reports observable changes.
- [ ] **IN-008:** Every candidate follows begin, append, required generation
  assignment, finish, and exactly one commit/discard resolution; failure or
  refusal preserves complete committed state with no partial publication.
- [ ] **IN-009:** Every simultaneous and individual error/cancellation follows
  the exact precedence, mapping, mandatory effects, and residual-policy bounds
  and never falls back, retargets, traps alone, or aliases.
- [ ] **IN-010:** Equal-limit dynamic/static fixtures match and the static path
  allocates zero heap bytes.
- [ ] **IN-011:** Dependency checks prove no Interaction-to-Observable-State,
  backend, platform, driver, task, reflection, unrestricted existential, or
  allocator dependency.
- [ ] **IN-012:** nRF52840 and ARMv6 evidence records ABI, fixed storage, stack,
  flash, RAM, direct dispatch, and forbidden symbols.
- [ ] **IN-013:** Initial-materialization, preservation, replacement, and
  discard fixtures bind every staged record to SPEC-010's exact publishable
  target generation before finish; no fixture substitutes a prior live value,
  and observable non-publication discards the Interaction candidate exactly
  once.

## Implementation Notes

This section is non-authoritative. A static profile may specialize decode and
the concrete handler into a direct switch. A dynamic profile may use bounded
table storage. Both must produce identical observable transcripts.

SPIKE-007 proves persistent captured-closure storage retains an allocator path
on nRF52840 and a manually constructed finite tagged representation can
dispatch without it. Its callable protocol, cases, and capacities are not
production declarations.

## Open Issues

No unresolved contract or architectural choice remains in this amendment.
The coordinated SPEC-009 and SPEC-010 amendments are approved. Production
capacities and profile storage belong to later runtime-profile and host-
configuration contracts.

## Deferred and Follow-up Work

- [FW-021](../future-work/fw-021-scoped-action-domains.md) preserves multiple
  or nested domains, independently replaceable targets, action transformation,
  and reusable feature routing. It remains post-MVP.
- Keyboard, focus, accessibility, richer gestures, styling, and dynamic-only
  callback conveniences require separate lifecycle work.

## References

- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-004](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-011](../rfcs/rfc-011-bounded-application-actions.md)
- [ADR-005](../adrs/adr-005-semantic-layout-render-boundary.md)
- [ADR-006](../adrs/adr-006-shared-semantics-runtime-profiles.md)
- [ADR-008](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
- [ADR-010](../adrs/adr-010-synchronous-one-shot-frame-handoff.md)
- [ADR-011](../adrs/adr-011-serialized-run-cycle-and-publication.md)
- [ADR-014](../adrs/adr-014-bounded-cross-layer-outcomes.md)
- [ADR-015](../adrs/adr-015-layered-failure-disposition.md)
- [ADR-016](../adrs/adr-016-non-authoritative-diagnostics.md)
- [ADR-024](../adrs/adr-024-structurally-owned-observable-reference-state.md)
- [ADR-025](../adrs/adr-025-coarse-model-owned-observable-invalidation.md)
- [ADR-026](../adrs/adr-026-profile-equivalent-bounded-observable-state.md)
- [ADR-033](../adrs/adr-033-bounded-application-actions-and-model-target-dispatch.md)
- [SPEC-002](spec-002-portable-foundation.md)
- [SPEC-003](spec-003-failure-outcomes-and-containment.md)
- [SPEC-006](spec-006-declarative-view-semantics.md)
- [SPEC-007](spec-007-layout.md)
- [SPEC-008](spec-008-rendering.md)
- [SPEC-009](spec-009-execution-cycle-and-frame-handoff.md)
- [SPEC-010](spec-010-observable-reference-state.md)
- [SPIKE-007](../spikes/spike-007-static-action-storage-feasibility.md)
- [FW-021](../future-work/fw-021-scoped-action-domains.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Principles](../PRINCIPLES.md)
