---
spec: SPEC-010
feature: observable-reference-state
title: Implementation Design — Observable Binding and Report Routing
status: current
authors:
  - codex
created: 2026-09-07
updated: 2026-09-07
implementation_plan: ../implementation-plans/spec-010-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Observable Binding and Report Routing

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## Purpose and Boundary

This note explains how the observable-state owner can join a noncopyable model
sink, transient `State` binding, candidate/live association selection, and the
cycle-local first-failure route without retaining a declaration or creating a
second execution mechanism. These ownership transfers and lifetimes are not
recoverable safely from the protocol signatures alone.

The note does not select dynamic/static storage packing, production capacities,
an executor, fact type, queue, wake implementation, target policy, Interaction
storage, or application model. It does not alter the approved public/package
surface or make SPIKE-003/SPIKE-006 authoritative.

## Governing Contract

The realization follows SPEC-010's `State and sink source shape`, `Types /
APIs`, `Logical storage contract`, `Materialization and identity`,
`Replacement`, `Reports and publication`, and `State / Lifecycle` sections. It
records plan task T2.4 and guides T3.1 through T5.4, while SPEC-006 T5.2–T5.3
consume only the resulting decorator seam.

The relevant accepted decisions are:

- ADR-024: observable reference models are structurally owned and association
  publication is atomic with semantic publication.
- ADR-025: invalidation is model-owned and coarse; property dependency
  tracking is outside MVP.
- ADR-026: dynamic and static profiles preserve the same bounded observable
  behavior despite replaceable storage representations.
- ADR-027: repository facts enter only through bounded later-cycle admission.
- ADR-033: target generations remain opaque, checked, non-aliasing runtime
  values and model borrowing occurs only at the final owning boundary.

## Current-Code Context

`GiftUI` owns `State`, `_GiftUIObservableChangeSink`, the attachment and model
protocols, the generated declaration visitor, and the state-host witness.
`GiftUISemanticCore` owns structural traversal and calls the stateful custom
category but does not interpret state. `GiftUIExecution` supplies the opaque
target generation and admission results.

`GiftUIObservableState` now owns the local values, reconciler/mutation/target
protocols, and presentation-fact façade. T3 must add candidate lifecycle and
the binding decorator without moving semantic traversal, execution queues, or
profile storage into this module.

## Proposed Internal Organization

The binding decorator is a short-lived generic value over one concrete
`ObservableStateReconciler`. It stores the current structural identity, the
reconciler value, and the first binding failure. It conforms to
`_GiftUIObservableStateDeclarationVisitor`, so the generated host witness
enumerates wrappers lexically without reflection or runtime discovery.

The entry copies the borrowed declaration into a mutable transient value,
moves the caller's reconciler into the visitor, runs the generated witness,
and moves the reconciler back. It evaluates the copied declaration's body only
when every encounter succeeds. Neither the visitor nor a wrapper binding
escapes that synchronous entry.

Candidate reconciliation is expressed through caller-owned bounded storage.
The owner coordinates begin, encounter, and exactly one publish/discard finish;
profile storage owns models and logical records. This keeps the profile-neutral
decorator independent of concrete heterogeneous model packing.

The report path has two deliberately different owners. The model consumes the
one noncopyable sink. The registration retains only attachment identity and a
bounded inactive/active/retired route state capable of validating a report.
No owner retains a second sink or callable model operation.

## Data and Control Flow

Binding follows one synchronous sequence:

```text
enter deriving
  -> begin candidate and reserve complete bounded resources
  -> copy transient declaration
  -> generated lexical wrapper visits
  -> encounter and bind each wrapper
  -> evaluate body once
  -> finish publish with semantic publication, or discard on first failure
```

An encounter either preserves a compatible live association or stages one new
candidate-only association. It consumes the wrapper initializer only after a
valid binding is available. Any failure stops later wrapper visits, suppresses
the body, and causes one complete candidate discard.

Attachment follows reserve, construct inactive route, transfer sink, call
model attach, verify returned attachment, then activate. A report before
activation is stale and makes the enclosing attach fail even if the model
later returns the expected attachment. Detach invalidates the route before
calling the model and releasing candidate/live storage.

A valid mutating-phase report checks the complete slot/generation attachment,
marks the live location dirty once, joins one execution wake intent, and
returns dirtied or coalesced. Before any failure outcome returns, its exact
`ObservableStateError` is offered to the cycle-local mutation-result slot.

## Algorithms and Data Structures

Candidate state is a closed finite lifecycle: inactive, active, and finished.
The active state owns encountered marks for at most
`maximumStagedAssociations`. Begin validates phase and reserves capacities
before body evaluation. Each encounter marks exactly one structural-
identity/ordinal key and classifies it preserved or candidate-only. Finish
computes removals from live keys not encountered in the complete candidate.

Publication must be prevalidated: after successful reservation and traversal,
ordinary `.publish` cannot fail. Additions and removals commit together;
discard invalidates and detaches candidate-only routes and leaves the prior
live set unchanged.

The transient binding visitor stores `ObservableStateError?` as a sticky first
failure. Once set, later generated visitor calls are no-ops. The cycle-local
mutation slot uses the same first-write-wins representation and is read and
cleared after the enclosing fact, handler, or fixture operation. These are
separate lifetimes and must not be merged into one global error.

Target lookup compares the complete structural-identity/ordinal key.
`targetGeneration` reads only the published live set.
`publishableTargetGeneration` reads only a successfully encountered active
candidate and returns its preserved or already-reserved generation. Neither
path materializes lazily or exposes model storage.

## Lifecycle and State

One candidate begins after entry to deriving and ends exactly once. A semantic
or binding failure ends it with discard. Complete semantic publication ends it
with publish. Query before successful encounter or after finish returns `nil`.

One registration progresses inactive during attach, active after exact
attachment verification, and retired before detach/release. Slot reuse does
not revive an old route because every report validates the never-reused full
generation. Replacement stages a fresh inactive registration while the prior
one remains active, then either commits and retires the prior route or discards
the candidate and preserves the prior association.

Runtime shutdown invalidates all active and staged routes before detaching each
installed sink once. It admits no later report, fact, action, or candidate.

## Runtime Profiles and Platforms

The decorator, operation results, lifecycle, ordering, first-failure rule, and
normalized transcript are identical on all four profiles. A dynamic profile
may use a bounded table/box for heterogeneous models. A static profile uses
generated typed direct slots. Both must expose the same caller-owned protocol
behavior and the five complete logical field families.

This note does not select either packing. SPEC-013 owns those production
representations and SPEC-015 owns assembled capacities and policy.

## Resource and Failure Behavior

Traversal performs one wrapper encounter per generated direct declaration and
one body evaluation at most. Candidate and registration work is bounded by the
three `ObservableStateLimits`; report coalescing retains only one dirty bit per
live location and the shared execution wake state. No report history, property
key, snapshot, retry queue, or diagnostic payload is retained.

Capacity, compatibility, duplicate ownership, stale attachment, phase,
generation exhaustion, reentrancy, and invariant failures use the exact
focused precedence. Cleanup cannot replace the first failure. Static zero-heap
and stack/link high-water claims remain T8 measurements rather than assumptions
in this note.

## Test and Diagnostic Seams

The fixture reconciler uses a finite structural identity and explicit bounded
arrays or generated slots. Its transcript records lifecycle, key/ordinal,
attachment slot/generation, association class, dirty state, wake state, result,
body count, detach count, and publication/discard.

Fault injection occurs at each reservation, attach/report/detach boundary,
association compatibility check, begin/finish transition, and body access.
SPEC-006 observes only lexical binding order, one copied declaration, body
suppression, semantic atomicity, and preservation of the exact owner error.

Diagnostics run only after local result and mandatory effects are fixed. They
cannot activate a route, clear dirtiness, publish a candidate, invoke a model,
or change the first failure.

## Rejected Implementation Alternatives

- Reflection, string paths, metatype-address keys, and an unbounded
  existential registry were rejected because generation is lexical and
  structural identity is already supplied by SPEC-006.
- Retaining the declaration, wrapper, binding, or body closure was rejected
  because binding is synchronous and attempt-local.
- Copying the noncopyable sink or storing it beside the model was rejected
  because the model consumes the sole sink and the registration needs only
  bounded route state.
- Activating a report route before attachment verification was rejected
  because attach-time reports must fail the complete candidate/replacement.
- Publishing associations incrementally was rejected because failed semantic
  derivation must preserve the prior live set.
- Combining binding failure and the cycle mutation-result slot was rejected
  because they have different owners, scopes, and clearing points.
- Lazy target lookup materialization was rejected because candidate resources
  must be reserved before body evaluation and lookup cannot fail afterward.

## Open Implementation Questions

No implementation question blocks T3's fixture-finite lifecycle and binding
decorator. Concrete heterogeneous dynamic storage and generated static slot
packing remain T6/SPEC-013 work. Exact execution wake and phase integration
remains T5 and waits for the corresponding SPEC-009 coordinator seams.

## Code and Evidence Links

- [`ObservableState.swift`](../../Sources/GiftUI/ObservableState.swift)
- [`ObservableStateValues.swift`](../../Sources/GiftUIObservableState/ObservableStateValues.swift)
- [`ObservableStateProtocols.swift`](../../Sources/GiftUIObservableState/ObservableStateProtocols.swift)
- [`PresentationFactAdmission.swift`](../../Sources/GiftUIObservableState/PresentationFactAdmission.swift)
- [Owner value evidence](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-2/owner-values.md)
- [Owner protocol evidence](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-2/owner-protocols.md)
- [Fact-admission evidence](../../Tests/ContractFixtures/SPEC010/Evidence/milestone-2/fact-admission.md)
- [SPEC-010](../specs/spec-010-observable-reference-state.md)
- [SPEC-010 Implementation Plan](../implementation-plans/spec-010-implementation-plan.md)
