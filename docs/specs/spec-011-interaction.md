---
id: SPEC-011
feature: giftui-mvp-architecture
title: Button Interaction and Activation Contract
status: draft
authors:
  - codex
created: 2026-08-26
updated: 2026-08-27
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-004
  - RFC-011
related_adrs:
  - ADR-005
  - ADR-006
  - ADR-011
  - ADR-013
related_specs:
  - SPEC-002
  - SPEC-003
  - SPEC-006
  - SPEC-007
  - SPEC-008
  - SPEC-009
related_future_work: []
related_explorations: []
related_spikes:
  - SPIKE-007
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPEC-011: Button Interaction and Activation Contract

> **Architecture gate:** RFC-011 is in review and proposes replacing this
> draft's callable payload with a bounded application-action value bound to an
> observable-model target generation. The normative callable sections below
> preserve the pre-RFC draft for review history; they MUST NOT advance until
> RFC-011 is approved, its decision is extracted into an accepted ADR, and this
> Specification is revised against that authority.

## Summary

This Specification defines the portable `Button` and `disabled` surface,
enabled-state lowering, bounded committed action records, hit routing, and
activation. It completes ADR-013's identity-generation capture contract while
leaving normalized event admission and run-cycle ownership in SPEC-009.

## Scope

The contract covers text and fixed-view button labels, nested disabled state,
action payload lowering, exact hit geometry, action replacement generations,
pointer down/move/up gesture semantics, synchronous invocation, capacities,
fail-closed cancellation, and shared dynamic/static fixtures.

## Goals

- Provide the Signal Analyzer's Start, Stop, Clear, and window-selection
  controls with one portable source surface.
- Prevent disabled, stale, removed, moved, or replaced controls from firing.
- Retain only identity and generation during pointer capture.
- Keep backends and drivers unable to invoke client behavior.

## Non-goals

- Keyboard, focus, hover, multi-touch gestures, drag actions, long press,
  repeat, accessibility activation, button styles, animation, or haptics.
- Platform event sampling, calibration, presentation eligibility, queues,
  cycle scheduling, or action-generation allocation; SPEC-002 and SPEC-009 own
  those concerns.
- Retaining historical hit maps or callable payloads across a press.

## Dependencies

SPEC-006 supplies structural and semantic action identity; SPEC-007 supplies
resolved bounds and clips; SPEC-008 supplies text and paint behavior;
SPEC-009 supplies normalized pointer admission, action generation, capture,
candidate publication, and mutation-phase ordering.

## Related ADRs

ADR-005 keeps semantic interaction above backends. ADR-006 requires equivalent
profile behavior. ADR-011 makes invocation an at-most-once mutation-phase
effect. ADR-013 requires provenance validation, identity-generation capture,
current-state release checks, and fail-closed sequence cancellation.

## Terminology

**Effective enabled state** is the conjunction of a button's local enabled
state and every enclosing disabled scope. **Action record** is one committed
semantic action identity, SPEC-009 generation, enabled bit, hit region, and
callable payload. **Activation** is one synchronous invocation admitted by a
valid release.

## Public Contract

```swift
public struct Button<Label: View>: View {
    public init(
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    )
}

public extension Button where Label == Text {
    init(_ title: StaticString, action: @escaping () -> Void)
    init(_ title: BoundedText, action: @escaping () -> Void)
}

public extension View {
    func disabled(_ disabled: Bool) -> some View
}
```

The label builder is evaluated once when its button declaration is expanded.
The button is one action-bearing semantic occurrence whose label is its fixed
semantic child. The title initializers lower exactly as the equivalent
`Button(action:) { Text(...) }` source.

`disabled(true)` disables every descendant action. `disabled(false)` does not
re-enable content disabled by an ancestor. Modifier order remains SPEC-006
order, but effective enabled state is the conjunction of all enclosing and
local scopes and is independent of backend behavior.

## Module Contract

`GiftUI` owns declarations and typed traversal payloads.
`GiftUIInteraction` owns action lowering, action records, hit maps, gesture
resolution, invocation, local errors, and recording fixtures. It imports
`GiftUI`, `GiftUISemanticCore`, `GiftUILayout`, and `GiftUIExecution`. It MUST
NOT import a runtime profile, render backend, rasterizer, platform, driver,
OS/RTOS, HAL, hardware target, or application model.

Runtime coordinators borrow complete semantic and layout results, stage an
interaction candidate, and commit it only with SPEC-009's accepted logical
frame. Failure adapters map local errors without making Interaction import
`GiftUIFailureCore`.

## Types / APIs

```swift
package struct ButtonSemanticPayload<Label: View>:
    _GiftUISemanticActionPayload {
    package let label: Label
    package let action: () -> Void
}

package struct DisabledSemanticPayload: _GiftUISemanticModifierPayload,
    Equatable, Sendable {
    package let isDisabled: Bool
}

package struct InteractionLimits: Equatable, Sendable {
    package let maximumActions: UInt16
    package let maximumHitRegions: UInt16
    package let maximumActiveSources: UInt16
    package init?(maximumActions: UInt16,
                  maximumHitRegions: UInt16,
                  maximumActiveSources: UInt16)
}

package protocol InteractionCallable: ~Copyable {
    borrowing func invoke()
}

package struct ActionRecord<
    Identity: Equatable & Sendable,
    Callable: ~Copyable & InteractionCallable
>: ~Copyable {
    package let identity: Identity
    package let generation: ActionGeneration
    package let isEnabled: Bool
    package let hitBounds: Rect
    package let callable: Callable
}

package enum InteractionError: UInt8, Equatable, Sendable {
    case capacityExhausted = 0
    case invalidIdentity = 1
    case invalidGeometry = 2
    case generationExhausted = 3
    case invalidPhase = 4
    case reentrancyViolation = 5
    case invariantViolation = 6
}

package enum PointerGestureResult: UInt8, Equatable, Sendable {
    case captured = 0
    case continued = 1
    case activationAdmitted = 2
    case cancelled = 3
    case ignored = 4
}

package protocol InteractionCandidateBuilder {
    associatedtype Identity: Equatable & Sendable
    mutating func begin(limits: InteractionLimits) -> InteractionError?
    mutating func append(
        identity: Identity,
        isEnabled: Bool,
        bounds: Rect,
        clip: Rect,
        action: @escaping () -> Void
    ) -> InteractionError?
    mutating func finish() -> InteractionError?
}

package protocol InteractionDispatcher {
    associatedtype Identity: Equatable & Sendable
    mutating func invoke(_ captured: CapturedAction<Identity>)
        -> InteractionError?
}
```

All limits MUST be nonzero and MUST be no greater than the corresponding
SPEC-009 configured limits. A count equal to its limit succeeds. `ActionRecord`
is runtime-owned and MUST NOT cross into a backend or pointer-capture record.
`Callable` is always statically known at the table realization; code MUST NOT
store it as an existential. Dynamic realization MAY wrap a closure in a
bounded dynamic callable type. Static realization MUST specialize or generate
a finite tagged callable type with bounded typed payloads and no `Any`,
reflection, or heap allocation.

## Behavior

### Semantic and layout lowering

Expansion calls `visitActionPrimitive` exactly once for each button and
associates the exact SPEC-006 action identity. The label expands in source
order and contributes its normal layout/render semantics. `disabled` uses the
single modifier seam and creates no semantic identity.

The candidate builder traverses actions in deterministic semantic order. The
hit region is exactly the SPEC-007 button occurrence bounds intersected with
its published logical clip. Empty intersection produces no hittable region but
retains the action record. Overlapping enabled regions resolve in reverse
paint order so the visually topmost eligible action wins. Disabled regions
are never hit targets and do not allow an obscured action beneath the same
painted occurrence to be retargeted through them.

### Candidate and generation behavior

For each identity, a newly derived callable is replacement. The coordinator
reserves a fresh runtime-wide `ActionGeneration` before publication. It MAY
preserve a generation only by preserving the exact formerly committed record
and callable, never by comparing closures. Removed identities release callable
storage only when a new candidate commits.

Capacity, geometry, or generation failure discards the whole candidate and
leaves the committed table, hit map, callable payloads, and generations
unchanged. Frame refusal likewise leaves the prior committed interaction state
unchanged. Accepted handoff atomically commits action records and hit regions
under the new `PresentationRevision`.

### Pointer gesture

SPEC-009 performs provenance, source, sequence, ordinal, and phase admission.
For a valid down, Interaction resolves the topmost enabled hit and captures
only its identity-generation pair. Down outside an enabled hit returns
`.ignored` with no capture.

Move preserves capture while the pointer remains inside the captured action's
current hit region; leaving it cancels the sequence's activation permanently.
Re-entry after leaving does not restore capture. Up is eligible only when it
is inside the same current hit region and current action record, enabled state,
identity, and generation all match the capture. Success emits one semantic
action into the same sealed cycle and clears capture. Every other up cancels.

A removed, disabled, replaced, stale, malformed, dropped, out-of-order, or
capacity-refused sequence invokes nothing. A revision may advance without
cancellation only when the exact committed record and generation remain and
current hit/enabled checks pass.

### Invocation

The dispatcher revalidates identity, generation, and enabled state immediately
before invocation. It calls the current payload exactly once, synchronously,
in SPEC-009 `.mutating`, after state-change and completion facts and in admitted
pointer order. It does not suspend, recursively run a cycle, or retain the
capture. Any callback that produces a presentation fact re-enters through the
later admission boundary and cannot mutate the active model reentrantly.

## State / Lifecycle

```text
idle --down hit/enabled--> captured --move inside--> captured
  |                            |  \--move outside/error--> cancelled
  |                            \--valid up--> admitted --> invoked once
  \--down miss/disabled--> ignored
```

There is at most one active sequence and capture per configured input source.
Cancellation clears capture and retained no callable.

## Capability Requirements

This contract adds no Capability. Required pointer availability and host input
assembly belong to downstream host configuration; portable code cannot probe a
driver or backend.

## Backend Requirements

Backends may receive normalized render operations only. They MUST NOT receive
buttons, disabled scopes, hit maps, action records, captures, or callables.
Input integrations normalize and stamp events but MUST NOT hit-test or invoke.

## Error Handling

| Local error | condition | origin | scope | containment |
| --- | --- | --- | --- | --- |
| `capacityExhausted` | `.capacityExhausted` | `.interaction` | `.candidateFrame` | `.contained` |
| `invalidIdentity` | `.invalidIdentity` | `.interaction` | `.candidateFrame` | `.contained` |
| `invalidGeometry` | `.invalidValue` | `.interaction` | `.candidateFrame` | `.contained` |
| `generationExhausted` | `.invalidIdentity` | `.execution` | `.runtime` | `.contained` |
| `invalidPhase` | `.invalidPhase` | `.interaction` | `.activeCycle` | `.safetyNotProven` |
| `reentrancyViolation` | `.reentrancyViolation` | `.interaction` | `.activeCycle` | `.safetyNotProven` |
| `invariantViolation` | `.invariantViolation` | `.interaction` | narrowest proven scope | `.safetyNotProven` |

Ordinary errors never invoke a fallback action, retarget an event, retain a
former callable, publish a partial table, or trap as their only behavior.

## Performance Requirements

Candidate construction is linear in actions; hit resolution is bounded by
`maximumHitRegions`; per-source sequencing is constant-space. The independent
fixture uses 32 actions, 32 regions, and 4 sources, matching SPEC-009. Static
construction, routing, capture, and dispatch allocate zero heap bytes.

## Compatibility

The public API intentionally resembles SwiftUI but does not promise source or
behavioral compatibility beyond this contract. Callable storage, table layout,
and identity encoding are not public ABI or persisted data.

## Testing Requirements

Provide `scripts/contracts/run-spec-011.sh` for both macOS profiles and
hardware-free Raspberry Pi ARMv6/nRF52840 compile/link modes. Fixtures cover
label equivalence, nested disabled scopes, exact clipped bounds, overlap order,
down/move/up behavior, replacement during press, removal, disabled-at-release,
stale revisions, cancellation, refusal atomicity, generation exhaustion,
at-most-once invocation, and cross-profile transcript equivalence.

## Acceptance Criteria

- [ ] **IN-001:** Exact `Button` and `disabled` source compiles in all profiles.
- [ ] **IN-002:** Semantic transcripts contain one action identity per button,
  stable across equivalent re-expansion and distinct across structural paths.
- [ ] **IN-003:** Hit fixtures use exact bounds/clip and deterministic reverse-
  paint overlap order.
- [ ] **IN-004:** Disabled, stale, moved-out, removed, or replaced controls
  never invoke a callable.
- [ ] **IN-005:** Capture stores only identity and generation; valid release
  invokes exactly once in SPEC-009 order.
- [ ] **IN-006:** Candidate failure/refusal preserves the complete committed
  table and generations and publishes no partial interaction state.
- [ ] **IN-007:** Equal-limit dynamic/static fixtures have identical results
  and the static path allocates zero heap bytes.
- [ ] **IN-008:** Dependency checks prove no backend, platform, driver, task,
  reflection, or unrestricted existential dependency.

## Implementation Notes

A generated callable union and a bounded dynamic closure table are both
possible profile realizations. Neither changes the callable replacement rule.
SPIKE-007 proves the exact `Callable: ~Copyable & InteractionCallable` generic
constraint compiles and links with the supported Embedded Swift toolchain. It
also proves that storing a captured escaping closure across the committed-
record lifetime retains an allocator path and is therefore not a valid static
realization, even when the enclosing record is noncopyable.

## Open Issues

The portable action representation and model-target dispatch boundary are an
upstream architecture blocker. RFC-011 proposes a bounded application-action
value, an assembled typed handler, and cancellation when model replacement
changes the target registration generation. This Specification must not choose
or implement that direction before RFC approval and accepted ADR extraction.

SPIKE-007 remains evidence that persisting an arbitrary captured closure is not
a valid zero-heap static realization. It does not prove closure-to-tag lowering
and does not authorize retaining the callable contract in this draft.

## Deferred and Follow-up Work

[SPIKE-007](../spikes/spike-007-static-action-storage-feasibility.md) tests the
exact public declaration shape, direct stored-closure feasibility, and a
generated bounded static callable representation. It supplies evidence only;
it does not select production storage or authorize implementation.

Richer gestures, focus, keyboard, accessibility, and styling require a future
concrete use case and normal lifecycle work.

## References

- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-004](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-011](../rfcs/rfc-011-bounded-application-actions.md)
- [ADR-013](../adrs/adr-013-provenance-validated-input-admission.md)
- [SPEC-006](spec-006-declarative-view-semantics.md)
- [SPEC-007](spec-007-layout.md)
- [SPEC-009](spec-009-execution-cycle-and-frame-handoff.md)
- [SPIKE-007](../spikes/spike-007-static-action-storage-feasibility.md)
- [FW-021](../future-work/fw-021-scoped-action-domains.md)
