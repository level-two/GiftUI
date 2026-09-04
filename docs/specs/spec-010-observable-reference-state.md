---
id: SPEC-010
feature: observable-reference-state
title: Observable Reference State Contract
status: approved
authors:
  - codex
created: 2026-08-26
updated: 2026-08-28
proposal:
  - PROPOSAL-005
related_rfcs:
  - RFC-008
  - RFC-011
related_adrs:
  - ADR-008
  - ADR-011
  - ADR-014
  - ADR-015
  - ADR-016
  - ADR-024
  - ADR-025
  - ADR-026
  - ADR-027
  - ADR-033
related_specs:
  - SPEC-001
  - SPEC-002
  - SPEC-003
  - SPEC-006
  - SPEC-009
  - SPEC-011
  - SPEC-013
  - SPEC-015
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

> **Approval status:** Explicitly reapproved by the maintainer after the
> 2026-08-28 amendment exposing the exact publishable candidate target
> generation needed by SPEC-011 and SPEC-013. The amended contract is
> authoritative for implementation.

## Summary

This Specification defines portable observable reference state held by
`@State`: generated declaration discovery, pre-body runtime binding,
structural ownership, preserved model identity, one model-owned change
registration, coarse invalidation, atomic replacement and removal, bounded
profile-equivalent storage, non-aliasing action-target generation, and a typed
façade over SPEC-009 presentation-fact admission. It specializes SPEC-006's
custom-view traversal and SPEC-009's state-change seam without changing their
semantic expansion, serialized cycle, publication, or failure ownership.

## Scope

This contract covers the `@State` reference-model case in the portable
`GiftUI` surface; build-time state-host generation; the observation SPI;
pre-body state binding; state-location reconciliation;
registration, replacement, removal, dirtiness, stale-report behavior, and
non-aliasing target-registration generation for action binding; dynamic and
static storage obligations; and the application-executor adapter
that creates finite immutable presentation facts.

## Goals

- Preserve one model identity at one live structural state location.
- Make every observable mutation enter SPEC-009's serialized mutation phase.
- Coalesce model reports into complete-root reevaluation and one wake intent.
- Preserve identical source and observable behavior across runtime profiles.
- Bound state locations, registrations, staging, and fact admission while
  retaining no correctness-relevant report history.
- Expose opaque live and publishable-candidate target generations to the
  runtime coordinator without exposing or transferring model ownership to
  Interaction.

## Non-goals

- Value-state semantics, `Binding`, `ObservedObject`, property-read tracking,
  multi-owner observation, automatic application lifecycle, or concurrency.
- Application model fields, capture storage, backend behavior, or the numeric
  production capacities selected by an approved runtime-profile or host
  configuration contract.
- Direct mutation of a model from an application callback, interrupt, driver,
  repository sink, or backend.

## Dependencies

SPEC-002 owns portable values and module direction; SPEC-003 owns outcomes;
the reviewed SPEC-006 revision owns structural identity and the stateful-
custom-view traversal operation; SPEC-009 owns admission storage, mutation,
freeze, publication, wake, and dirty-rederivation behavior. RFC-008 supplies
the MVP 80-facts-per-second / 250-millisecond workload. SPEC-001 is a
non-authoritative downstream instantiation until separately approved;
SPEC-010 neither imports its types nor relies on its numeric capacities for
completeness. SPEC-011 consumes only the borrowed target-generation and model-
access seams defined here.

## Related ADRs

- ADR-008 requires compiler-visible acyclic target boundaries and one package;
  the host-only macro target is build tooling and does not enter target images.
- ADR-024 requires structurally owned locations, initializer preservation,
  atomic replacement, and publication-coupled removal.
- ADR-025 requires one model-owned synchronous report seam and coarse dirty
  reevaluation inside the serialized mutation domain.
- ADR-026 requires one portable surface with bounded dynamic/static
  realizations and zero-heap static operation.
- ADR-027 requires bounded immutable presentation facts between the logically
  distinct application executor and GiftUI mutation domain.
- ADR-033 requires every committed Button action to bind to the exact current
  observable-model registration generation and requires replacement/removal to
  invalidate that binding without retaining the model in Interaction.
- ADR-011 and ADR-014 through ADR-016 govern publication, failure mapping,
  disposition, health, and non-authoritative diagnostics.

## Terminology

**State host** is a custom `View` whose generated witness enumerates its direct
observable `@State` declarations in lexical declaration order before `body`
evaluation. **State location** is the runtime-owned association of one
SPEC-006 structural identity plus a declaration-local ordinal with one
preserved model and active registration. **Change report** means only that
values derived from the owning model may have changed. **Presentation fact**
is a finite immutable value copied by a target-composed adapter and queued
through SPEC-009.

**Observable target generation** is the runtime-local non-aliasing generation
of one live model registration. It proves which installed model a bound action
was derived to address and is neither a model reference nor public identity.

## Public Contract

Portable Presentation requires only `import GiftUI` and uses the same source
in every profile:

```swift
@attached(member, names: named(_giftUIVisitObservableStateDeclarations),
          named(_giftUITraverse))
@attached(extension, conformances: _GiftUIObservableStateHost)
public macro ObservableStateHost() = #externalMacro(
    module: "GiftUIMacros",
    type: "ObservableStateHostMacro"
)

@propertyWrapper
public struct State<Value: _GiftUIObservableReference> {
    public init(wrappedValue: Value)
    public var wrappedValue: Value { get nonmutating set }
}

public enum _GiftUIObservableChangeReportOutcome: UInt8, Equatable, Sendable {
    case dirtied = 0
    case coalesced = 1
    case staleAttachment = 2
    case invalidPhaseContained = 3
    case invalidPhaseSafetyNotProven = 4
    case reentrancyViolation = 5
    case invariantViolation = 6
}

public struct _GiftUIObservableChangeSink: ~Copyable {
    public borrowing var attachment: _GiftUIObservationAttachment { get }
    public mutating func reportChange()
        -> _GiftUIObservableChangeReportOutcome
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
    public let slot: UInt16
    public let generation: UInt32
}

public protocol _GiftUIObservableStateDeclarationVisitor {
    mutating func visit<Value: _GiftUIObservableReference>(
        _ state: inout State<Value>,
        declarationOrdinal: UInt16
    )
}

public protocol _GiftUIObservableStateHost {
    mutating func _giftUIVisitObservableStateDeclarations<
        Visitor: _GiftUIObservableStateDeclarationVisitor
    >(_ visitor: inout Visitor)
}
```

`@ObservableStateHost` is required on every custom `View` that directly
declares an observable `@State`. The macro expansion MUST be deterministic,
MUST enumerate only the declaration's direct observable-state wrapper storage
in lexical declaration order, and MUST assign ordinals `0...n-1`. It MUST
synthesize the state-host witness and SPEC-006's stateful-custom-view traversal
witness inside the declaration so private wrapper storage remains accessible.
More than 65,535 direct observable declarations is a compile-time error. The
macro implementation runs only on the build host; neither it nor SwiftSyntax
may enter a target dependency closure.

The underscored types and protocols are framework conformance SPI, not
supported client UI. `_GiftUIObservationAttachment` has no public initializer;
only `GiftUIObservableState` may create one. The sink has no public initializer,
contains that exact attachment and one fixed nonescaping runtime report route,
and is transferred into the model's single registration. A conforming model
MUST read `sink.attachment`, install the complete sink, and return that same
attachment. Returning `nil` means only that the model already owns a sink;
capacity, identity-generation, and staging failures occur before the sink is
offered. Returning a different attachment is `.invariantViolation` and the
candidate is detached and discarded.

Generated static model handles and dynamic reference wrappers MAY store the
sink differently. Copying a conforming static handle MUST address the same
underlying model and registration storage; it MUST NOT copy or fork model
state or the sink. Attach MUST NOT itself report a change. Detach MUST remove
the installed sink matching the supplied attachment; retaining a callable
copy is impossible because the sink is noncopyable, and any later report route
for the retired attachment is mechanically stale.

The first successful materialization installs the initializer value. Later
transient initializers at the same live location are ignored. Assignment to
`wrappedValue` requests atomic replacement during `.mutating`; it is not a
direct storage write during body evaluation. The macro-generated traversal
witness binds every wrapper before evaluating `body`. A bound getter returns
the preserved or newly staged model. Binding failure skips `body`, discards the
complete semantic candidate, and returns the exact observable-state error;
there is no wrapper-local fallback. Direct wrapper access outside its bound
state-host traversal or mutation dispatch is unsupported client misuse and has
no portable result guarantee; the runtime MUST NOT use it as an alternate
storage mode. Every framework-owned access is preceded by successful binding,
so ordinary capacity or lifecycle failure remains a returned bounded outcome
rather than a getter trap.

Because a Swift property setter has no result, the bound setter route MUST
store its exact `ObservableStateResult` in one cycle-local mutation-result slot
owned by the runtime coordinator. The coordinator reads and clears that slot
synchronously when the enclosing fact, handler, or test operation returns and
performs the Error Handling table before derivation. The slot preserves the
first failure until consumed and cannot be overwritten by a later success.
This reporting mechanism retains no model, candidate, callable, fact, or
unbounded history. The package `replace` operation remains the direct result-
returning conformance seam used by owner adapters and fixtures.

## Module Contract

`GiftUI` owns the public declarations and contains no active binding singleton,
task-local, registry, or runtime storage. The host-only `GiftUIMacros` target
owns `ObservableStateHostMacro`; it may import Swift compiler-support modules
but MUST NOT be linked into a GiftUI product or target image.

`GiftUIObservableState` owns locations, registrations, reconciliation, the
state-aware decorator over SPEC-006 traversal, local results, and recording
fixtures and may import `GiftUI`, `GiftUISemanticCore`, and `GiftUIExecution`.
It MUST NOT import a runtime profile, Interaction, an application model,
backend, platform, driver, OS/RTOS, HAL, or hardware target. The decorator is
the first owner allowed to combine a structural identity with the generated
declaration ordinal. It binds a mutable copy of the transient custom view
before calling its body accessor and retains no declaration after the call.

Runtime profiles provide bounded storage behind the package protocols below.
The target-composed presentation adapter imports its application contracts and
`GiftUIExecution`, but portable Domain and Presentation import neither the
adapter nor a runtime implementation. Fact storage and admission limits remain
owned by SPEC-009. Failure mapping resides in the first adapter that imports
both this owner and `GiftUIFailureCore`.

## Types / APIs

```swift
package struct ObservableStateLimits: Equatable, Sendable {
    package let maximumLocations: UInt16
    package let maximumRegistrations: UInt16
    package let maximumStagedAssociations: UInt16
    package init?(maximumLocations: UInt16,
                  maximumRegistrations: UInt16,
                  maximumStagedAssociations: UInt16)
}

package enum ObservableStateError: UInt8, Equatable, Sendable {
    case locationCapacityExhausted = 0
    case registrationCapacityExhausted = 1
    case associationStagingCapacityExhausted = 2
    case replacementStagingCapacityExhausted = 3
    case registrationGenerationExhausted = 4
    case duplicateOwner = 5
    case incompatibleAssociation = 6
    case staleAttachment = 7
    case invalidPhaseContained = 8
    case invalidPhaseSafetyNotProven = 9
    case reentrancyViolation = 10
    case invariantViolation = 11
}

package enum ObservableStateOperational: UInt8, Equatable, Sendable {
    case unchanged = 0
    case candidateStarted = 1
    case materialized = 2
    case preserved = 3
    case candidateDiscarded = 4
    case associationsCommitted = 5
    case replaced = 6
    case dirtied = 7
    case coalesced = 8
}

package enum ObservableStateResult: Equatable, Sendable {
    case success(ObservableStateOperational)
    case failure(ObservableStateError)
}

package enum ObservableStateCandidateDisposition: UInt8, Equatable, Sendable {
    case publish = 0
    case discard = 1
}

package protocol ObservableStateReconciler {
    associatedtype StructuralIdentity: Equatable & Sendable
    mutating func beginCandidate() -> ObservableStateResult
    mutating func encounter<Model: _GiftUIObservableReference>(
        structuralIdentity: StructuralIdentity,
        declarationOrdinal: UInt16,
        state: inout State<Model>
    ) -> ObservableStateResult
    mutating func finishCandidate(
        _ disposition: ObservableStateCandidateDisposition
    ) -> ObservableStateResult
}

package protocol ObservableStateMutationOwner {
    associatedtype StructuralIdentity: Equatable & Sendable
    mutating func replace<Model: _GiftUIObservableReference>(
        structuralIdentity: StructuralIdentity,
        declarationOrdinal: UInt16,
        with candidate: consuming Model
    ) -> ObservableStateResult
    mutating func acceptReport(
        attachment: _GiftUIObservationAttachment
    ) -> ObservableStateResult
}

package protocol ObservableStateTargetView {
    associatedtype StructuralIdentity: Equatable & Sendable
    borrowing func targetGeneration(
        structuralIdentity: StructuralIdentity,
        declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration?
    borrowing func publishableTargetGeneration(
        structuralIdentity: StructuralIdentity,
        declarationOrdinal: UInt16
    ) -> ObservableTargetGeneration?
}

package protocol PresentationFactAdmissionAdapter {
    associatedtype Fact: Sendable
    mutating func submit(_ fact: Fact)
        -> ExecutionAdmissionOutcome
}
```

Any conforming `Fact` MUST be a finite immutable value and MUST contain no
reference to mutable repository storage, closure, task, platform object, or
model. The adapter is a typed façade over SPEC-009's
`submit(stateChange:)`; it creates no second queue, limit, sequence namespace,
or admission result. A downstream application Specification may select a
concrete fact enum and numeric `ExecutionLimits` only after its own approval.

All three observable limits MUST be nonzero.
`maximumRegistrations` MUST be at least `maximumLocations`, and
`maximumStagedAssociations` MUST be at least `maximumLocations`; otherwise the
initializer returns `nil`. A count equal to its limit is valid. Replacement
uses one record from the declared staging capacity only while its candidate is
being validated and attached; it does not require permanent duplicate
registration capacity for every location. The independent conformance fixture
uses two locations, two registrations, and two staged associations. Fact queue
capacity is owned by the selected SPEC-009 runtime profile; per-cycle fact
selection is bounded by `ExecutionLimits.maximumStateChangeFacts`. Neither is
an observable-state limit.

`ObservableStateResult` is the only package result of the operations above.
`nil`, Boolean success, traps, and profile-specific result cases are not
conforming substitutes. `.preserved` means an existing compatible association
was bound; `.materialized` means a candidate association was created;
`.dirtied` and `.coalesced` are the exact successful report outcomes.

Each registration receives one `_GiftUIObservationAttachment`. `slot` indexes
the bounded registration record. `generation` is allocated from the same
runtime-wide checked `UInt32` namespace exposed to SPEC-011 as
`ObservableTargetGeneration`; raw value `0` is allocated first and no value is
a sentinel. The complete `(slot, generation)` pair is unique for the assembled
runtime lifetime. Generation values are never reused even when a slot is
recycled. Failure to form the checked successor returns
`.registrationGenerationExhausted`, installs no candidate, and requires a
fresh assembled runtime; it never wraps or searches for a reusable value.

SPEC-009 owns the four-byte opaque `ObservableTargetGeneration` declaration so
Interaction and Observable State can exchange it through their existing
Execution dependency without importing one another. This Specification owns
its allocation and meaning. Its raw value is exactly the current attachment's
`generation`; no second target-generation counter exists. A value is not
public API, ABI, persisted data, or a cross-runtime identifier.
`ObservableStateTargetView` is a synchronous borrowed view. `targetGeneration`
observes only the current published live set and returns `nil` for absence or a
retired location. `publishableTargetGeneration` is legal only after
`beginCandidate`, after the named location's successful `encounter`, and before
`finishCandidate`. It returns the exact registration generation that the
current complete candidate will own if published: the existing live generation
for a preserved association, or the already-reserved candidate generation for
first materialization. A key not yet encountered, absent from the candidate,
or queried outside that interval returns `nil`; the method performs no lazy
materialization and cannot fail after a successful encounter.

Both methods expose no model, attachment, change sink, state value, handler,
or mutation operation. The publishable view is borrowed from staged storage
and MUST NOT escape Interaction candidate construction. On
`finishCandidate(.publish)`, every returned candidate generation becomes the
corresponding live generation atomically with semantic publication. On
`.discard`, candidate-only registrations detach and every generation exposed
only through the publishable view is retired permanently; it is never reused,
and the prior live view remains unchanged. Interaction candidate discard is
mandatory whenever observable candidate publication does not occur.

The package representation of a transient `State` is exactly one logical
two-case storage: `initial(Value)` before encounter, or `bound` with one
nonescaping route to the candidate/live location selected for the current
expansion attempt. Successful encounter consumes the initializer and replaces
that case with the binding; the wrapper never retains both. The binding
contains the structural identity, declaration ordinal, and registration
generation but no
backend, platform, fact queue, task-local, string path, `Any`, or unbounded
existential registry. Dynamic profiles may realize the binding through a
bounded runtime-owned box; static profiles MUST use generated typed direct
access. The binding cannot escape the traversal call or become persisted
client state.

## Behavior

### Materialization and identity

The location key is the exact SPEC-006 structural identity plus a zero-based
declaration ordinal emitted by `ObservableStateHostMacro` in lexical
declaration order. Before a stateful custom body runs, the SPEC-006 visitor
decorator copies the transient declaration, calls its generated state-host
witness, and invokes `encounter` once per enumerated wrapper. Same key and
compatible model type binds the wrapper to the live model and returns
`.preserved`; the repeated initializer is consumed and discarded without
attachment. A different key is a different location. Same key with
incompatible type/layout returns `.incompatibleAssociation`, evaluates no
body, and reinterprets no bytes.

One model may own exactly one active location. A second attachment returns
`.duplicateOwner`; the original remains unchanged. A candidate hierarchy is
staged. Only complete semantic publication commits additions and removals.
Failed derivation discards candidate changes and preserves the prior live set.
Reinsertion after published removal creates fresh state.

`beginCandidate` is called exactly once after entry to `.deriving` and before
root traversal. A binding or semantic failure calls
`finishCandidate(.discard)` exactly once; it detaches every candidate-only
registration, invalidates its report route, clears transient wrapper bindings,
and preserves the prior published live set. The coordinator calls
`finishCandidate(.publish)` exactly once as part of the atomic semantic
publication operation after all ordinary validation has succeeded. Because
all location, registration, staging, and generation resources were reserved
before body evaluation, `.publish` has no ordinary failure path; failure there
is `.invariantViolation`, publishes neither semantic output nor association
changes, and leaves the runtime safety not proven. Calling begin or finish in
any other state is `.reentrancyViolation` or the appropriate phase error.

### Replacement

Replacement is legal only in `.mutating`. The runtime first validates type and
ownership, reserves all location/registration/staging resources, and attaches
the candidate. It then atomically installs the candidate, makes its
registration active, detaches the former registration, retires the former
model association, and marks the location dirty. Failure before commit undoes
the candidate attachment and leaves the former association unchanged.

The first successful model registration allocates a fresh attachment whose
generation is also its `ObservableTargetGeneration`. Every successful
replacement reserves another fresh attachment/generation before commit and
retires the former pair atomically with the former registration. Published
removal retires the live pair. A staged or failed replacement preserves the
former generation. Exhaustion fails closed, preserves any formerly live
model/registration/generation, and requires a fresh assembled runtime before
another registration can be installed.

The candidate sink is not active until the candidate attachment has been
verified. A report attempted during attach, before activation, during detach,
or after retirement returns `.staleAttachment`; it cannot dirty the candidate,
former location, or a reused slot. Detach is idempotent only for the exact
currently installed attachment. A mismatched detach is
`.invariantViolation`; it does not retire another registration.

### Reports and publication

An admitted mutation that changes observable model state MUST synchronously
call `reportChange()` before returning. It MAY omit the call only when it proves
no observable state changed. A report contains no property, value, snapshot,
or scheduler metadata.

During `.mutating`, the first valid report for a clean live owner marks it
dirty, joins SPEC-009's `semanticDirty` wake, and returns `.dirtied`. Further
reports while that represented dirtiness remains return `.coalesced`, allocate
no event record, and request no additional wake. `acceptReport` returns the
corresponding `ObservableStateResult`. A stale attachment returns
`.staleAttachment` and changes no dirty or wake state. The runtime freezes
mutation before derivation. Any dirty live location permits complete-root
reevaluation.

The sink and package-owner results correspond exactly:

| Sink outcome | `acceptReport` result |
| --- | --- |
| `.dirtied` | `.success(.dirtied)` |
| `.coalesced` | `.success(.coalesced)` |
| `.staleAttachment` | `.failure(.staleAttachment)` |
| `.invalidPhaseContained` | `.failure(.invalidPhaseContained)` |
| `.invalidPhaseSafetyNotProven` | `.failure(.invalidPhaseSafetyNotProven)` |
| `.reentrancyViolation` | `.failure(.reentrancyViolation)` |
| `.invariantViolation` | `.failure(.invariantViolation)` |

Before returning a failure outcome, the sink route records the same package
failure in the coordinator's cycle-local mutation-result slot when a cycle is
active. A model cannot hide the failure by ignoring the returned enum. Outside
an active cycle the owner adapter performs the mandatory disposition directly.

A report outside `.mutating` is rejected. If the coordinator proves that no
model write occurred and the last complete publication remains stable, it
returns `.invalidPhaseContained`, marks the live owner dirty (or preserves its
existing dirtiness), and schedules exactly one paced dirty rederivation. If
that proof is unavailable, it returns
`.invalidPhaseSafetyNotProven`, discards partial derived work, and prevents
another normal cycle pending target disposition. Reentrant reporting across an
active report or semantic dispatch returns `.reentrancyViolation` with the
same safety-not-proven behavior. A no-op mutation that proves no observable
change makes no report and changes no dirty or wake state.

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

The adapter itself owns no application-executor entry operation. A downstream
application contract must define that entry, its callback result mapping, and
its concrete fact type. This reusable contract requires only that the adapter
is invoked synchronously within that domain and forwards the complete fact and
exact `ExecutionAdmissionOutcome` without reinterpretation.

## State / Lifecycle

```text
vacant -> candidate-reserved -> candidate-attached -> live
             |                    |                  |
             \-> discarded <------/                  +-> replacement-reserved
                                                    |       |
                                                    |       +-> live(new)
                                                    |       \-> live(prior) on failure
                                                    \-> removal-staged -> retired
```

Only semantic publication performs `candidate-attached -> live`, commits a
replacement, or performs `removal-staged -> retired`. Candidate discard and
failed replacement invalidate candidate routes before releasing their staging
records. Detachment MUST make every later report bearing the retired
attachment stale, including after slot reuse. Runtime shutdown invalidates all
live and staged routes, detaches every installed sink once, releases all
profile-owned model storage, and admits no later report, fact, action, or
candidate. Removal and shutdown do not call application `startObserving` or
`stopObserving`; the host owns those effects explicitly.

## Capability Requirements

This contract defines no Capability or Trait. State and registration capacity
are structural host inputs, not additions to SPEC-004's closed catalogue.

## Backend Requirements

Backends, rasterizers, integrations, and drivers MUST NOT own models, attach
change sinks, mutate state, clear dirtiness, or schedule semantic work.

## Error Handling

Owner adapters map local errors to SPEC-003 facts as follows:

| Local error and detection context | condition | origin | scope | containment |
| --- | --- | --- | --- | --- |
| `locationCapacityExhausted`, initial/candidate binding | `.capacityExhausted` | `.observableState` | `.component` | `.contained` |
| `registrationCapacityExhausted`, initial/candidate binding | `.capacityExhausted` | `.observableState` | `.component` | `.contained` |
| `registrationCapacityExhausted`, replacement | `.capacityExhausted` | `.observableState` | `.operation` | `.contained` |
| `associationStagingCapacityExhausted` | `.capacityExhausted` | `.observableState` | `.activeCycle` | `.contained` |
| `replacementStagingCapacityExhausted` | `.capacityExhausted` | `.observableState` | `.operation` | `.contained` |
| `registrationGenerationExhausted` | `.invalidIdentity` | `.observableState` | `.runtime` | `.safetyNotProven` |
| `duplicateOwner`, initial/candidate binding | `.invalidIdentity` | `.observableState` | `.component` | `.contained` |
| `duplicateOwner`, replacement | `.invalidIdentity` | `.observableState` | `.operation` | `.contained` |
| `incompatibleAssociation`, candidate binding | `.invalidIdentity` | `.observableState` | `.component` | `.contained` |
| `incompatibleAssociation`, replacement | `.invalidIdentity` | `.observableState` | `.operation` | `.contained` |
| `staleAttachment` | `.invalidIdentity` | `.observableState` | `.operation` | `.contained` |
| `invalidPhaseContained` | `.invalidPhase` | `.observableState` | `.activeCycle` | `.contained` |
| `invalidPhaseSafetyNotProven` | `.invalidPhase` | `.observableState` | `.activeCycle` | `.safetyNotProven` |
| `reentrancyViolation` | `.reentrancyViolation` | `.observableState` | `.activeCycle` | `.safetyNotProven` |
| `invariantViolation` | `.invariantViolation` | `.observableState` | `.runtime` | `.safetyNotProven` |

Ordinary exhaustion MUST NOT trap, allocate an unbounded fallback, publish a
partial association set, or detach a working replacement target.

Mandatory containment and remaining policy choices are exact:

| Condition context | Mandatory owner/coordinator effects | Allowed residual response |
| --- | --- | --- |
| Initial/candidate capacity, duplicate-owner, or incompatible-association failure | Skip the affected body, discard the complete candidate, detach candidate-only registrations, and preserve the prior publication | `quiesceAffectedScope` or `invokeFatalHook` when no prior root exists; otherwise `continueOperation` or `quiesceAffectedScope` |
| Replacement capacity, duplicate-owner, or incompatible-association failure | Detach candidate-only state and preserve the former model, attachment, target generation, dirtiness, and publication | `continueOperation` or `quiesceAffectedScope` |
| Stale attachment | Reject the report and preserve current dirtiness without addressing a reused slot | `continueOperation` |
| Contained phase violation | Preserve the last complete publication, mark the live owner dirty, and schedule exactly one retry no earlier than the next host pace | no residual policy call |
| Registration-generation exhaustion | Preserve any former live association and publication; admit no new registration and require a fresh runtime | `quiesceAffectedScope` or `invokeFatalHook` |
| Safety-not-proven phase, reentrancy, or invariant failure | Discard partial candidate/publication work and admit no later normal cycle | `quiesceAffectedScope` or `invokeFatalHook` |

The first adapter importing `GiftUIObservableState` and `GiftUIFailureCore`
constructs the SPEC-003 fact only after the mandatory effects complete. It
MUST preserve the exact local error until mapping, MUST invoke residual policy
only for rows that list a choice, and MUST NOT narrow scope, weaken
containment, reinterpret failure as success, or use diagnostics as recovery.

## Performance Requirements

Lookup, attach, detach, report, and reconciliation MUST be bounded by declared
capacities. Report coalescing is constant-space per live location. Shared
fixtures MUST configure SPEC-009 for at least 20 state-change facts per
250-millisecond selection opportunity and sustain 80 admitted facts per second,
one dirty bit per location, and at most one outstanding semantic wake. Reports
retain no queue, counter, mutation record, or history beyond the location dirty
bit and SPEC-009 wake-reason state.

Static fixtures MUST allocate zero heap bytes and use no reflection, `Any`,
task-local state, runtime source scanning, or target discovery. Both profiles
report location, registration, staging, SPEC-009 pending-fact, macro-expanded
code, stack, heap, and linked-size high-water evidence.

Live and publishable target-generation lookup and equality MUST be constant-
space and bounded by the configured location/staging representation. They MUST
allocate zero heap bytes in the static profile.

## Compatibility

The same `@ObservableStateHost` plus `@State` source and model mutation behavior
MUST compile in dynamic and static profiles. Macro expansion is deterministic
build input and MUST be byte-identical for the same source and compiler/plugin
versions. Profile location-record packing may differ, but both representations
MUST contain the exact logical fields specified above. Generated attachment
mechanics are not public ABI. No attachment, target generation, or state
identity is persisted or serialized.

## Testing Requirements

Provide `scripts/contracts/run-spec-010.sh` for macOS dynamic, macOS static,
Raspberry Pi ARMv6 compile/link, and nRF52840 hardware-free compile/link modes.
Shared fixtures cover initialization preservation, multiple declarations,
replacement success/failure, removal/reinsertion, failed derivation,
duplicate ownership, stale reports, phase violations, exhaustion, coalescing,
fact order/refusal, action-triggered repository non-reentrancy, and profile
transcript equivalence. They MUST additionally cover macro ordinal output;
binding before body; body suppression on every binding failure; no wrapper-
local fallback; a proven no-op; report attempts during attach, candidate state,
detach, freeze, and shutdown; distinct capacity mappings; initial and
replacement attachment-generation exhaustion; exact mandatory-effects and
policy-call rows; initial target generation; successful and failed replacement;
published removal; live and publishable borrowed target lookup; first-
materialization publish/discard; query before encounter and after finish;
Interaction candidate discard when observable publication does not occur; and
stale-report rejection after slot reuse. Connected hardware is not required
for Specification approval.

## Acceptance Criteria

- [ ] **OS-001:** The exact `@ObservableStateHost`, `@State`, sink, attachment,
  and model-conformance source plus deterministic macro expansion compiles for
  every MVP profile.
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
- [ ] **OS-009:** Target-generation fixtures prove fresh non-aliasing initial
  and replacement values, preservation on failed replacement, retirement on
  published removal, fail-closed exhaustion, and equal dynamic/static lookup
  transcripts without exposing or retaining a model.
- [ ] **OS-010:** Generated host fixtures enumerate direct state declarations
  exactly once in lexical order, bind every wrapper before body evaluation,
  suppress body on binding failure, and expose no task-local or local-value
  fallback.
- [ ] **OS-011:** Every report returns the exact dirtied, coalesced, stale,
  contained-phase, safety-not-proven, reentrancy, or invariant result; no-op,
  attach/detach, freeze, slot-reuse, and shutdown cases produce the specified
  dirty/wake and mandatory-disposition transcripts.
- [ ] **OS-012:** During one active candidate, publishable lookup returns the
  exact preserved or already-reserved generation only after successful
  encounter; publication makes it live, discard retires candidate-only values
  without reuse, invalid timing returns `nil`, and dynamic/static transcripts
  remain identical without exposing or retaining a model.

## Implementation Notes

SPIKE-003 is feasibility evidence only. Generated typed slots or a dynamic
table are both suitable when they preserve this contract.

SPIKE-006 provides hardware-free compile/link evidence for the earlier
property-wrapper, consuming-sink, and model-conformance declaration family.
Against a configuration-equivalent nRF52840 baseline, its exercised fixture
added 16 linked flash bytes and zero linked RAM bytes and retained no allocator
entry point. Its `Void` report result, forgeable raw attachment, wrapper body,
and lack of state-host generation were deliberately replaced by this review;
the Spike is feasibility evidence only and does not satisfy OS-001, OS-010, or
OS-011 for the revised declarations.

## Open Issues

No unresolved contract or architectural choice remains in this amendment.
SPEC-006 and SPEC-009 remain approved. OS-001 compile
evidence is an implementation-conformance requirement, not authority for the
declaration contract. SPEC-001 remains responsible for its own fact cases,
application-executor entry contract, and production capacities; because this
contract is generic over `Fact` and delegates all fact storage to SPEC-009,
that downstream work does not define or weaken SPEC-010.

## Deferred and Follow-up Work

- [FW-019](../future-work/fw-019-fine-grained-observable-dependency-tracking.md) retains
  property-level dependency tracking outside MVP scope.

## References

- [SPEC-010 Implementation Plan](../implementation-plans/spec-010-implementation-plan.md)
- [PROPOSAL-005](../proposals/proposal-005-observable-reference-state.md)
- [RFC-008](../rfcs/rfc-008-observable-reference-state-architecture.md)
- [ADR-008](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
- [ADR-024](../adrs/adr-024-structurally-owned-observable-reference-state.md)
- [ADR-025](../adrs/adr-025-coarse-model-owned-observable-invalidation.md)
- [ADR-026](../adrs/adr-026-profile-equivalent-bounded-observable-state.md)
- [ADR-027](../adrs/adr-027-bounded-presentation-fact-admission.md)
- [RFC-011](../rfcs/rfc-011-bounded-application-actions.md)
- [ADR-033](../adrs/adr-033-bounded-application-actions-and-model-target-dispatch.md)
- [SPEC-002](spec-002-portable-foundation.md)
- [SPEC-003](spec-003-failure-outcomes-and-containment.md)
- [SPEC-006](spec-006-declarative-view-semantics.md)
- [SPEC-009](spec-009-execution-cycle-and-frame-handoff.md)
- [SPEC-011](spec-011-interaction.md)
- [SPIKE-003](../spikes/spike-003-portable-observable-reference-state-feasibility.md)
- [SPIKE-006](../spikes/spike-006-spec-010-embedded-declarations.md)
