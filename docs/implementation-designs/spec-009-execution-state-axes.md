---
spec: SPEC-009
feature: giftui-mvp-architecture
title: Implementation Design — Execution Identity and State Axes
status: current
authors:
  - codex
created: 2026-09-07
updated: 2026-09-07
implementation_plan: ../implementation-plans/spec-009-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Execution Identity and State Axes

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## Purpose and Boundary

This note explains the bounded internal mechanics used to allocate and retire
execution-owned identities, validate phase movement, preserve correlation, and
check cycle summaries against recorded history. It exists because a phase enum
alone does not reconstruct permanent identity retirement or SPEC-009's
independent semantic, candidate, logical-frame, presentation-intent,
physical-presentation, and input-source axes.

The note does not define those meanings. It does not select production
workspace, queue, action-table, retry, endpoint, or profile storage; allocate
`ObservableTargetGeneration`; implement admission or handoff; or add package
SPI for historical validation. Those contracts remain with SPEC-009,
SPEC-010, SPEC-013 through SPEC-015, and their downstream implementations.

## Governing Contract

The realization follows SPEC-009's `Execution identities and phases`, `Limits
and phase context`, `Opportunity and sealing`, `Mutation, freeze, derivation,
and publication`, `Candidate frame and handoff`, `Finalization`, and `State /
Lifecycle` sections. It implements plan tasks T2.1 through T2.4 and records the
T2.5 design decision.

The relevant accepted decisions are:

- ADR-010: frame handoff is synchronous and one-shot, with complete
  reservation before acceptance.
- ADR-011: one run cycle is serialized, non-suspending, and publishes only a
  complete semantic result.
- ADR-012: pending presentation recovery is bounded and independent of
  already-applied mutation.
- ADR-033: action generation is a runtime-wide bounded identity distinct from
  semantic action identity, while observable target generation remains owned
  downstream.

## Current-Code Context

`GiftUIExecution` owns the opaque identities and `ExecutionContext` in
`ExecutionValues.swift`, one allocator wrapper per execution-owned namespace
in `IdentityAllocators.swift`, the focused transition and correlation guard in
`ExecutionPhaseMachine.swift`, and intrinsic admission/cycle-summary
validation in `AdmissionValues.swift` and `RunCycleValues.swift`.

Fixture tests own reservation transcripts and historical terminal-state
validation. No production coordinator exists yet, so those fixtures describe
required observations without becoming a second runtime representation.

## Proposed Internal Organization

`CheckedIdentityCursor` is a private, representation-sharing helper. Five
package-scoped wrappers give cycle, semantic revision, candidate frame,
presentation revision, and action generation distinct type-level namespaces.
Only the typed wrappers cross the package boundary; the shared cursor does
not. `ObservableTargetGeneration` intentionally has no allocator here.

`ExecutionPhaseMachine` stores only the correlation needed at the focused
phase boundary: the current cycle, latest complete semantic revision, current
candidate, and current phase. Its `context` property creates an immutable
snapshot. It does not store a logical frame, presentation intent, physical
endpoint progress, input-source state, or terminal history.

Intrinsic summary validation remains in the value initializers. Validation
that depends on prior entry state or reservation events remains fixture-owned
until the recording coordinator supplies one authoritative bounded history.

## Data and Control Flow

The reservation order for a changed cycle is:

```text
cycle
  -> replacement action generation
  -> semantic revision and complete publication
  -> candidate frame
  -> presentation revision
  -> offer
  -> commit or abort
```

Every reservation precedes the boundary that can make its value observable or
irrevocably consume output. A pre-publication failure leaves no new complete
semantic revision. Candidate or presentation exhaustion after publication
preserves that published revision, makes no endpoint call, and either creates
no candidate or aborts the already-reserved candidate. Commit and abort both
consume their reservations permanently.

`beginCycle` first verifies `.idle`, then asks the cycle allocator for a
value. Nested entry therefore returns `reentrancyViolation` with the active
context and consumes no identity. Exhaustion while idle returns
`identityExhausted` with no cycle. Accepted transitions update only the phase;
publication and candidate recording are separate checked operations so their
identities appear only at the contractually valid points.

## Algorithms and Data Structures

The checked cursor stores `UInt32?`. A non-`nil` value is the next valid raw
identity. Reservation returns that value and computes its successor with
`addingReportingOverflow`. Reserving `UInt32.max` succeeds because every bit
pattern is valid, then stores `nil` as private allocator state. `nil` is not an
identity sentinel: it is unreachable through any identity value and means
that this allocator can never reserve again.

The five wrappers deliberately duplicate their small forwarding surface.
This prevents accidental namespace interchange while retaining one reviewed
successor algorithm. Test-only internal initializers seed the cursor at a
chosen boundary; production package clients can only begin at zero.

The phase guard uses an exhaustive pair switch for the exact twelve accepted
edges. All other 37 phase pairs fail without mutation. Correlation fields are
updated only by their dedicated operations. Returning to idle clears cycle
and candidate identity while retaining the latest complete semantic revision.

`AdmissionSummary` and `RunCycleSummary` initializers check facts derivable
from their own fields and limits. The finite history oracle independently
checks entry state, reservations, publication, offer, and terminal disposition
against the thirteen normative rows. Keeping these layers separate prevents a
value initializer from inventing hidden coordinator history.

## Lifecycle and State

Each allocator is constructed once for an assembled runtime lifetime and
moves monotonically from raw zero through `UInt32.max` to permanent
exhaustion. Reserved values are never returned to the allocator after discard,
refusal, abort, or failure.

The phase machine begins idle with no cycle or candidate. A cycle advances
only through the normative graph, enters finalizing exactly once, and returns
to idle. Its retained semantic revision is correlation with the latest
complete publication, not evidence that semantics are clean or that any frame
was committed.

The independent axes remain represented by their owning state:

| Axis | Focused realization |
| --- | --- |
| Semantic | latest published revision in context; clean/dirty disposition in cycle values |
| Candidate | optional current candidate in context; later coordinator owns staged content |
| Logical frame | prior/new disposition in cycle summary; later coordinator owns committed frame |
| Presentation intent | bounded intent and disposition values; later coordinator owns pending state |
| Physical presentation | not stored in Execution's phase machine; endpoint/integration owned |
| Input source | not stored in Execution's phase machine; admission/target-gate state owned |

No axis is inferred from another. In particular, a retained semantic revision
does not imply a candidate, an accepted logical frame, satisfied presentation,
or synchronized input.

## Runtime Profiles and Platforms

The cursor algorithm, namespace separation, phase graph, and validation rules
are identical for macOS dynamic, macOS static, Raspberry Pi ARMv6 dynamic, and
nRF52840 static configurations. Cross-profile contract drivers compile these
same sources. Later profile contracts may choose different bounded container
representations around them but cannot change successor, retirement,
transition, correlation, or terminal-summary meaning.

## Resource and Failure Behavior

The allocators and phase machine contain fixed-width values and optional
fixed-width identities only. They require no collection, existential payload,
reflection, task, actor, lock, retry loop, or profile branch. Exact allocation
and stack measurements remain T8 evidence rather than a claim of this note.

Identity arithmetic is constant time and fails closed after the last valid
value. An invalid or repeated phase transition leaves all stored correlation
unchanged. The first detecting owner maps exhaustion or phase rejection later;
these helpers do not emit diagnostics, choose containment, or inspect a
generic owner failure.

## Test and Diagnostic Seams

`IdentityAllocatorTests` exercises zero-first allocation, exact successors,
namespace independence, maximum-value reservation, permanent exhaustion, and
`Equatable`/`Sendable` evidence. `IdentityReservationOrderingTests` records
every reservation, publication, offer, commit, abort, retirement, and
pre-/post-publication exhaustion point.

`ExecutionPhaseMachineTests` generates all 49 phase pairs and checks nested
entry, idle exhaustion, publication/candidate correlation, finalization, and
reuse. `SummaryValidationMatrixTests` compares intrinsic initializers with
independent predicates across 768 admission and 10,368 cycle-summary
combinations, then checks every normative terminal row against fixture-owned
history.

Source audits reject wrapping arithmetic, sentinels, an Execution-owned
observable-target allocator, suspension, owner imports, and production history
storage. Diagnostics remain downstream observations and do not control any
mechanism described here.

## Rejected Implementation Alternatives

- One externally visible untyped allocator was rejected because it would make
  namespace aliasing easy even if its counter arithmetic were correct.
- Wrapping, reuse, or reserving a raw identity as an exhaustion sentinel was
  rejected because every `UInt32` bit pattern is a valid identity and aborted
  reservations remain retired.
- A combined phase-and-state mega-enum was rejected because the six axes move
  independently and would create invalid implied correlations or a multiplying
  case surface.
- Treating phase alone as history was rejected because reservation and
  publication boundaries are separately observable.
- Storing the terminal history in `RunCycleSummary` was rejected because its
  approved fields support only intrinsic validation.
- Allocating `ObservableTargetGeneration` in Execution was rejected because
  SPEC-010 owns that namespace's lifecycle.

## Open Implementation Questions

No implementation question blocks Milestone 2. T3 and later milestones must
choose bounded fixture/coordinator state for admission, history, and handoff
without changing these identities or axes. SPEC-013 through SPEC-015 retain
the production storage, capacity, and policy choices.

## Code and Evidence Links

- [`IdentityAllocators.swift`](../../Sources/GiftUIExecution/IdentityAllocators.swift)
- [`ExecutionPhaseMachine.swift`](../../Sources/GiftUIExecution/ExecutionPhaseMachine.swift)
- [`IdentityAllocatorTests.swift`](../../Tests/GiftUIExecutionTests/IdentityAllocatorTests.swift)
- [`IdentityReservationOrderingTests.swift`](../../Tests/GiftUIExecutionTests/IdentityReservationOrderingTests.swift)
- [`ExecutionPhaseMachineTests.swift`](../../Tests/GiftUIExecutionTests/ExecutionPhaseMachineTests.swift)
- [`SummaryValidationMatrixTests.swift`](../../Tests/GiftUIExecutionTests/SummaryValidationMatrixTests.swift)
- [Checked allocator evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-2/checked-identity-allocators.md)
- [Reservation ordering evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-2/reservation-ordering.md)
- [Phase-machine evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-2/phase-machine.md)
- [Summary-matrix evidence](../../Tests/ContractFixtures/SPEC009/Evidence/milestone-2/summary-validation-matrix.md)
- [SPEC-009](../specs/spec-009-execution-cycle-and-frame-handoff.md)
- [SPEC-009 Implementation Plan](../implementation-plans/spec-009-implementation-plan.md)
