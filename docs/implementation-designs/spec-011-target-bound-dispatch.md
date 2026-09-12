---
spec: SPEC-011
feature: giftui-mvp-architecture
title: Implementation Design — Target-Bound Interaction Coordination
status: current
authors:
  - codex
created: 2026-09-12
updated: 2026-09-12
implementation_plan: ../implementation-plans/spec-011-implementation-plan.md
related_future_work:
  - FW-021
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Target-Bound Interaction Coordination

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## Purpose and Boundary

This note explains how the SPEC-011 Milestone 5 handoff joins already-normalized
semantic action occurrences, resolved layout geometry, the observable root's
publishable target generation, SPEC-009 action generations and frame outcome,
and synchronous current-model dispatch.

The mechanism does not own semantic expansion, layout, observable-model
storage, generation allocation, frame offering, host policy, or profile
storage. It provides bounded generic coordination over those focused owners so
SPEC-013 can bind dynamic and static storage without duplicating interaction
rules.

## Governing Contract

- [SPEC-011](../specs/spec-011-interaction.md), especially Module Contract,
  Candidate and Generation Behavior, Pointer Gesture, Dispatch and Model
  Replacement, and acceptance criteria `IN-002`, `IN-005` through `IN-008`,
  and `IN-013`.
- [ADR-010](../adrs/adr-010-synchronous-one-shot-frame-handoff.md) for
  accepted-only routing commit.
- [ADR-011](../adrs/adr-011-serialized-run-cycle-and-publication.md) for sealed,
  at-most-once mutation ordering.
- [ADR-033](../adrs/adr-033-bounded-application-actions-and-model-target-dispatch.md)
  for target-generation binding and final revalidation.
- [SPEC-011 Implementation Plan](../implementation-plans/spec-011-implementation-plan.md)
  tasks `T5.1` through `T5.6`.

## Current-Code Context

`GiftUIInteraction` owns the candidate state machine, committed records, hit
map, and gesture resolver. `GiftUIObservableState` exposes publishable target
generation and current-target seams without importing Interaction.
`GiftUIExecution` owns action-generation allocation, captures, mutation phase,
and one-shot frame values. `GiftUIRuntimeCore` is the first target importing all
focused contracts and already owns common lifecycle and cleanup tables.

The SPEC-013 dynamic and static targets currently provide bounded storage and
generated action specialization but intentionally wait for this focused-owner
coordination instead of implementing parallel candidate or dispatch paths.

## Proposed Internal Organization

`GiftUIInteraction` adds only the focused contracts needed by an external
composition owner: a borrowed committed-record view and the exact dispatcher
protocol. `InteractionState` supplies the record view without exposing its
storage representation.

`GiftUIRuntimeCore` supplies two generic value coordinators:

- candidate coordination consumes a bounded occurrence source, one borrowed
  publishable-target view, the Interaction candidate builder, and the
  SPEC-009 action-generation allocator;
- dispatch coordination consumes the borrowed committed-record view, one
  immutable handler value, and target-composed current-model access.

Neither coordinator stores a semantic payload, layout value, handler in an
Interaction record, model reference, or target-generation lookup token.
Profile targets provide concrete storage conformers in their own later tasks.

## Data and Control Flow

Candidate flow is:

```text
begin Interaction candidate
  -> read exact publishable root target generation once
  -> visit normalized occurrences in semantic order
  -> append exact enabled/bounds/clip/order/action/target fields
  -> reserve and assign one ActionGeneration only when requested
  -> finish Interaction candidate
  -> offer frame through the existing SPEC-009 owner
  -> accepted: commit under reserved PresentationRevision
     otherwise: discard
```

Missing target generation or any append/assignment/finish failure discards the
Interaction candidate. The caller then applies the already-required Observable
State disposition; the coordinator exposes a single result and never attempts
partial publication.

Dispatch flow is:

```text
captured identity/generation
  -> re-read committed record
  -> validate generation and enabled state
  -> total typed decode of the two-byte action
  -> borrow current model matching record target generation
  -> call the handler once
  -> return dispatched, cancelled, or invariant failure
```

Target absence or mismatch is ordinary cancellation. Decode failure in a
committed record is an invariant failure.

## Algorithms and Data Structures

Occurrence and committed-record access are indexed bounded views rather than
arrays or dictionaries. Candidate construction is a single forward pass.
Record lookup remains Interaction-owned and bounded by the committed action
limit. The dispatch adapter is generic over the concrete handler and target
access, allowing static specialization without an existential registry.

The handler is stored only in the target-composed dispatch adapter. It is never
copied into candidate, committed, hit-region, or capture storage. The model is
available only as the nonescaping borrow supplied by `withCurrentModel`.

## Lifecycle and State

The candidate coordinator does not add a state machine. It drives the existing
Interaction `idle -> staging -> ready-for-offer -> idle` transitions and leaves
the ready candidate immutable until frame disposition. Every begun candidate
has exactly one commit or discard resolution.

The dispatcher has no replay state. Each call operates on the current committed
record and current target access. SPEC-009 remains responsible for admitting a
captured pair at most once and invoking dispatch only in `.mutating`.

## Runtime Profiles and Platforms

Dynamic and static profiles call the same generic algorithms. Dynamic storage
may use bounded heap-backed regions; static storage supplies fixed/generated
indexed views and a concrete handler specialization. The normalized results and
failure/cancellation rules are identical. No backend, platform, or connected
hardware behavior enters this mechanism.

## Resource and Failure Behavior

Candidate coordination is linear in occurrence count and uses constant local
state. Dispatch performs bounded Interaction lookup, constant-time decode, one
target comparison, and at most one synchronous handler call. The generic path
does not allocate, reflect, launch tasks, retain borrows, or grow storage.

Generation exhaustion remains `ExecutionError.identityExhausted`. Interaction
errors retain their exact vocabulary. Cleanup is selected by existing runtime
tables after the focused result is returned; diagnostics have no input to the
algorithm.

## Test and Diagnostic Seams

Recording sources expose attempted target reads, appends, generation
reservations/assignments, finish, offer disposition, candidate resolution,
record reads, target borrows, handler calls, synchronous reports, and later-fact
admission. Fault injection covers every exit without changing production
contracts. Tests compare typed values and ordered events rather than pointers or
private storage bytes.

## Rejected Implementation Alternatives

- Putting target lookup in `GiftUIInteraction` would create the forbidden
  Interaction-to-Observable-State edge.
- Storing closures for cleanup, dispatch, or occurrence access would obscure
  static lifetime and allocator evidence.
- Capturing action values or target generations on pointer down would bypass
  current committed-record validation.
- Letting each profile implement its own candidate or dispatch algorithm would
  duplicate focused-owner semantics and weaken differential evidence.

## Open Implementation Questions

None. Profile storage packing and first-party capacities remain assigned to
SPEC-013 and SPEC-015 respectively.

## Code and Evidence Links

- [Candidate coordinator](../../Sources/GiftUIRuntimeCore/RuntimeInteractionCandidateCoordinator.swift)
- [T5.1 target-binding evidence](../../Tests/ContractFixtures/SPEC011/Evidence/t5-1-target-binding.md)
