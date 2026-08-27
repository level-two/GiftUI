---
id: SPEC-010
feature: observable-reference-state
title: Observable Reference State Contract
status: review
authors:
  - codex
created: 2026-08-26
updated: 2026-08-27
proposal:
  - PROPOSAL-005
related_rfcs:
  - RFC-008
  - RFC-011
related_adrs:
  - ADR-011
  - ADR-014
  - ADR-015
  - ADR-016
  - ADR-024
  - ADR-025
  - ADR-026
  - ADR-027
related_specs:
  - SPEC-001
  - SPEC-002
  - SPEC-003
  - SPEC-006
  - SPEC-009
related_future_work:
  - FW-019
related_explorations: []
related_spikes:
  - SPIKE-003
  - SPIKE-006
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPEC-010: Observable Reference State Contract

> **Review status:** The governing Proposal, approved RFC, and accepted ADRs
> are authoritative prerequisites. This Specification remains
> non-authoritative until explicit maintainer approval.

## Summary

This Specification defines portable observable reference state held by
`@State`: structural ownership, preserved model identity, one model-owned
change registration, coarse invalidation, atomic replacement and removal,
bounded profile-equivalent storage, and bounded Signal Analyzer presentation-
fact admission. It specializes SPEC-009's state-change seam without changing
its serialized cycle, publication, or failure semantics.

## Scope

This contract covers the `@State` reference-model case in the portable
`GiftUI` surface; the observation SPI; state-location reconciliation;
registration, replacement, removal, dirtiness, and stale-report behavior;
dynamic and static storage obligations; and the application-executor adapter
that creates finite immutable presentation facts.

## Goals

- Preserve one model identity at one live structural state location.
- Make every observable mutation enter SPEC-009's serialized mutation phase.
- Coalesce model reports into complete-root reevaluation and one wake intent.
- Preserve identical source and observable behavior across runtime profiles.
- Bound state locations, registrations, reports, staging, and fact admission.

## Non-goals

- Value-state semantics, `Binding`, `ObservedObject`, property-read tracking,
  multi-owner observation, automatic application lifecycle, or concurrency.
- Application model fields, capture storage, backend behavior, or host-selected
  production capacities.
- Direct mutation of a model from an application callback, interrupt, driver,
  repository sink, or backend.

## Dependencies

SPEC-002 owns portable values and module direction; SPEC-003 owns outcomes;
SPEC-006 owns structural identity; SPEC-009 owns admission, mutation, freeze,
publication, wake, and dirty-rederivation behavior. SPEC-001 supplies the MVP
fact families and 80-facts-per-second workload.

## Related ADRs

- ADR-024 requires structurally owned locations, initializer preservation,
  atomic replacement, and publication-coupled removal.
- ADR-025 requires one model-owned synchronous report seam and coarse dirty
  reevaluation inside the serialized mutation domain.
- ADR-026 requires one portable surface with bounded dynamic/static
  realizations and zero-heap static operation.
- ADR-027 requires bounded immutable presentation facts between the logically
  distinct application executor and GiftUI mutation domain.
- ADR-011 and ADR-014 through ADR-016 govern publication, failure mapping,
  disposition, health, and non-authoritative diagnostics.

## Terminology

**State location** is the runtime-owned association of one SPEC-006 structural
identity plus a declaration-local ordinal with one preserved model and active
registration. **Change report** means only that values derived from the owning
model may have changed. **Presentation fact** is a finite immutable value
copied by the target-composed adapter and queued through SPEC-009.

## Public Contract

Portable Presentation requires only `import GiftUI` and uses the same source
in every profile:

```swift
@propertyWrapper
public struct State<Value: _GiftUIObservableReference> {
    public init(wrappedValue: Value)
    public var wrappedValue: Value { get nonmutating set }
}

public struct _GiftUIObservableChangeSink: ~Copyable {
    public mutating func reportChange()
}

public protocol _GiftUIObservableReference {
    mutating func _giftUIAttachChangeSink(
        _ sink: consuming _GiftUIObservableChangeSink
    ) -> _GiftUIObservationAttachment?
    mutating func _giftUIDetachChangeSink(
        _ attachment: _GiftUIObservationAttachment
    )
}

public struct _GiftUIObservationAttachment: Equatable, Sendable {
    public let rawValue: UInt32
    public init(rawValue: UInt32)
}
```

The underscored types are framework conformance SPI, not supported client UI.
The sink has no public initializer, owns one fixed nonescaping runtime report
route, and is transferred into the model's single registration. Returning
`nil` means no attachment was installed. Generated static model handles and
dynamic reference wrappers MAY realize the protocol differently. Copying a
conforming static handle MUST address the same underlying model; it MUST NOT
fork model state.

The first successful materialization installs the initializer value. Later
transient initializers at the same live location are ignored. Assignment to
`wrappedValue` requests atomic replacement during `.mutating`; it is not a
direct storage write during body evaluation.

## Module Contract

`GiftUI` owns the public declarations. `GiftUIObservableState` owns locations,
registrations, reconciliation, local results, and recording fixtures and may
import `GiftUI`, `GiftUISemanticCore`, and `GiftUIExecution`. It MUST NOT import
a runtime profile, backend, platform, driver, OS/RTOS, HAL, or hardware target.

Runtime profiles provide bounded storage behind the package protocols below.
The Signal Analyzer integration adapter imports its application contracts and
`GiftUIExecution`, but portable Domain and Presentation import neither the
adapter nor a runtime implementation. Failure mapping resides in the first
adapter that imports both this owner and `GiftUIFailureCore`.

## Types / APIs

```swift
package struct ObservableStateLimits: Equatable, Sendable {
    package let maximumLocations: UInt16
    package let maximumRegistrations: UInt16
    package let maximumStagedAssociations: UInt16
    package let maximumPendingReports: UInt16
    package init?(maximumLocations: UInt16,
                  maximumRegistrations: UInt16,
                  maximumStagedAssociations: UInt16,
                  maximumPendingReports: UInt16)
}

package enum ObservableStateError: UInt8, Equatable, Sendable {
    case capacityExhausted = 0
    case duplicateOwner = 1
    case incompatibleAssociation = 2
    case staleReport = 3
    case invalidPhase = 4
    case reentrancyViolation = 5
    case invariantViolation = 6
}

package enum ObservableStateOperational: UInt8, Equatable, Sendable {
    case unchanged = 0
    case coalesced = 1
}

package protocol ObservableStateReconciler {
    associatedtype StructuralIdentity: Equatable & Sendable
    mutating func beginCandidate() -> ObservableStateError?
    mutating func encounter<Model: _GiftUIObservableReference>(
        structuralIdentity: StructuralIdentity,
        declarationOrdinal: UInt16,
        initialValue: consuming Model
    ) -> ObservableStateError?
    mutating func finishCandidate(published: Bool) -> ObservableStateError?
}

package protocol ObservableStateMutationOwner {
    associatedtype StructuralIdentity: Equatable & Sendable
    mutating func replace<Model: _GiftUIObservableReference>(
        structuralIdentity: StructuralIdentity,
        declarationOrdinal: UInt16,
        with candidate: consuming Model
    ) -> ObservableStateError?
    mutating func acceptReport(
        attachment: _GiftUIObservationAttachment
    ) -> ObservableStateError?
}

package protocol PresentationFactAdmissionAdapter {
    associatedtype Fact: Sendable
    mutating func submit(_ fact: Fact)
        -> ExecutionAdmissionOutcome
}
```

The Signal Analyzer instantiates `Fact` with the bounded immutable
`SignalAnalyzerPresentationFact` owned by SPEC-001. Any conforming fact MUST
contain no reference to mutable repository storage, closure, task, platform
object, or model. The adapter is a typed façade over SPEC-009's
`submit(stateChange:)`; it creates no second queue or admission result.

All four observable limits MUST be nonzero. A count equal to its limit is
valid. No raw attachment value is a sentinel; attachments are unique during
one assembled runtime lifetime and MUST fail closed rather than wrap into a
live or retired registration.

## Behavior

### Materialization and identity

The location key is the exact SPEC-006 structural identity plus a zero-based
declaration ordinal assigned in deterministic declaration order. Same key and
compatible model type preserves the live model and registration. A different
key is a different location. Same key with incompatible type/layout returns
`.incompatibleAssociation` and reinterprets no bytes.

One model may own exactly one active location. A second attachment returns
`.duplicateOwner`; the original remains unchanged. A candidate hierarchy is
staged. Only complete semantic publication commits additions and removals.
Failed derivation discards candidate changes and preserves the prior live set.
Reinsertion after published removal creates fresh state.

### Replacement

Replacement is legal only in `.mutating`. The runtime first validates type and
ownership, reserves all location/registration/staging resources, and attaches
the candidate. It then atomically installs the candidate, makes its
registration active, detaches the former registration, retires the former
model association, and marks the location dirty. Failure before commit undoes
the candidate attachment and leaves the former association unchanged.

### Reports and publication

An admitted mutation that changes observable model state MUST synchronously
call `reportChange()` before returning. It MAY omit the call only when it proves
no observable state changed. A report contains no property, value, snapshot,
or scheduler metadata.

Valid reports mark the owner dirty and join SPEC-009's `semanticDirty` wake.
Further reports while dirty return `.coalesced`, allocate no event record, and
request no additional wake. The runtime freezes mutation before derivation.
Any dirty live location permits complete-root reevaluation.

Successful semantic publication clears exactly the dirtiness represented by
that revision and commits candidate association changes. Frame refusal does
not restore dirtiness. Derivation failure leaves applied model changes dirty,
preserves the prior live set, requests paced dirty rederivation, and never
replays mutations.

### Presentation-fact admission

Repository delivery runs synchronously on the application executor and ends at
the adapter. The adapter copies a complete bounded fact and calls SPEC-009's
`submit(stateChange:)`. `.queued` means later mutation-domain application, not
immediate model change. Refusal retains no fact and MUST NOT fall back to
direct mutation. During `.mutating`, each sealed fact is applied exactly once
in queue order before semantic actions, using the model's synchronous mutation
API and report seam.

An action-triggered application use case may synchronously cause repository
delivery, but that delivery still becomes a fact for a later admission. It
MUST NOT reenter the active action's model mutation.

## State / Lifecycle

```text
vacant -> candidate-attached -> live -> replacement-staged -> live
                         |        |             \-> failure: prior live
                         |        \-> removal-staged -> retired on publication
                         \-> discarded on failed derivation
```

Detachment MUST make every later report bearing the retired attachment stale.
Removal does not call application `startObserving` or `stopObserving`; the host
owns those effects explicitly.

## Capability Requirements

This contract defines no Capability or Trait. State and registration capacity
are structural host inputs, not additions to SPEC-004's closed catalogue.

## Backend Requirements

Backends, rasterizers, integrations, and drivers MUST NOT own models, attach
change sinks, mutate state, clear dirtiness, or schedule semantic work.

## Error Handling

Owner adapters map local errors to SPEC-003 facts as follows:

| Local error | condition | origin | scope | containment |
| --- | --- | --- | --- | --- |
| `capacityExhausted` | `.capacityExhausted` | `.observableState` | `.activeCycle` | `.contained` |
| `duplicateOwner` | `.invalidIdentity` | `.observableState` | `.operation` | `.contained` |
| `incompatibleAssociation` | `.invalidIdentity` | `.observableState` | `.activeCycle` | `.contained` |
| `staleReport` | `.invalidIdentity` | `.observableState` | `.operation` unless wider safety is unproven | `.contained` or `.safetyNotProven` |
| `invalidPhase` | `.invalidPhase` | `.observableState` | `.activeCycle` | `.safetyNotProven` |
| `reentrancyViolation` | `.reentrancyViolation` | `.observableState` | `.activeCycle` | `.safetyNotProven` |
| `invariantViolation` | `.invariantViolation` | `.observableState` | narrowest proven scope | `.safetyNotProven` |

Ordinary exhaustion MUST NOT trap, allocate an unbounded fallback, publish a
partial association set, or detach a working replacement target.

## Performance Requirements

Lookup, attach, detach, report, and reconciliation MUST be bounded by declared
capacities. Report coalescing is constant-space per live location. Shared
fixtures MUST sustain 80 admitted facts per second with 250 ms opportunities,
one dirty bit per location, and at most one outstanding semantic wake.

Static fixtures MUST allocate zero heap bytes and use no reflection, `Any`,
task-local state, or target discovery. Both profiles report location,
registration, staging, pending-fact, stack, heap, and linked-size high-water
evidence.

## Compatibility

The same `@State` source and model mutation behavior MUST compile in dynamic
and static profiles. Profile storage layout and generated attachment mechanics
are not public ABI. No attachment or state identity is persisted or serialized.

## Testing Requirements

Provide `scripts/contracts/run-spec-010.sh` for macOS dynamic, macOS static,
Raspberry Pi ARMv6 compile/link, and nRF52840 hardware-free compile/link modes.
Shared fixtures cover initialization preservation, multiple declarations,
replacement success/failure, removal/reinsertion, failed derivation,
duplicate ownership, stale reports, phase violations, exhaustion, coalescing,
fact order/refusal, action callback non-reentrancy, and profile transcript
equivalence. Connected hardware is not required for Specification approval.

## Acceptance Criteria

- [ ] **OS-001:** The exact public source compiles for every MVP profile.
- [ ] **OS-002:** Same-location reevaluation preserves one model identity and
  one registration; different declaration ordinals remain distinct.
- [ ] **OS-003:** Replacement and removal fixtures prove atomic failure and
  publication behavior with no stale report alias.
- [ ] **OS-004:** Twenty admitted changes before one opportunity yield one
  dirty owner, one wake, one complete reevaluation, and no replay.
- [ ] **OS-005:** Every local condition produces the exact outcome mapping and
  no partial association publication.
- [ ] **OS-006:** Dynamic and static transcripts are identical at equal limits;
  the static run records zero heap allocation.
- [ ] **OS-007:** Presentation-fact fixtures prove ordered later application,
  explicit refusal, and absence of direct/reentrant model mutation.
- [ ] **OS-008:** Dependency and symbol checks find no backend/platform import,
  reflection, unrestricted existential registry, task, or allocator dependency
  in the static observable-state path.

## Implementation Notes

SPIKE-003 is feasibility evidence only. Generated typed slots or a dynamic
table are both suitable when they preserve this contract.

SPIKE-006 provides hardware-free compile/link evidence for the exact public
declaration spellings in this review. Against a configuration-equivalent
nRF52840 baseline, its exercised fixture added 16 linked flash bytes and zero
linked RAM bytes, retained no allocator entry point with both configured heaps
at zero, and preserved the ARMv7E-M VFP calling convention. Its model, sink
route, attachment value, and optimized resource delta remain disposable
evidence rather than a selected production representation or capacity.

## Open Issues

No open Specification issue blocks review. SPIKE-006 resolves the Embedded
Swift compile/link question for the exact declarations above. SPEC-001 remains
responsible for its exact application fact cases and production capacities;
those facts instantiate this generic admission contract without blocking its
independent fixtures or review.

## Deferred and Follow-up Work

- [FW-019](../future-work/fw-019-fine-grained-observable-dependency-tracking.md) retains
  property-level dependency tracking outside MVP scope.

## References

- [PROPOSAL-005](../proposals/proposal-005-observable-reference-state.md)
- [RFC-008](../rfcs/rfc-008-observable-reference-state-architecture.md)
- [ADR-024](../adrs/adr-024-structurally-owned-observable-reference-state.md)
- [ADR-025](../adrs/adr-025-coarse-model-owned-observable-invalidation.md)
- [ADR-026](../adrs/adr-026-profile-equivalent-bounded-observable-state.md)
- [ADR-027](../adrs/adr-027-bounded-presentation-fact-admission.md)
- [SPEC-009](spec-009-execution-cycle-and-frame-handoff.md)
- [SPIKE-003](../spikes/spike-003-portable-observable-reference-state-feasibility.md)
- [SPIKE-006](../spikes/spike-006-spec-010-embedded-declarations.md)
