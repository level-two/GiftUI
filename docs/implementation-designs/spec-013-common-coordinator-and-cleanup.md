---
spec: SPEC-013
feature: giftui-mvp-architecture
title: Implementation Design — Common Coordinator and Cleanup
status: current
authors:
  - codex
created: 2026-09-12
updated: 2026-09-12
implementation_plan: ../implementation-plans/spec-013-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Common Coordinator and Cleanup

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## Purpose and Boundary

This note explains the shared Runtime Core mechanism for SPEC-013 T2.1-T2.5:
construction, serialized opportunity ownership, ordered attempt stages,
mandatory cleanup, retained execution correlation, and synchronous
quiescence. Dynamic and static storage representations, Canvas generation,
backend realization, host policy, and production capacities remain outside
this note.

## Governing Contract

The mechanism realizes SPEC-013's Construction and validation, Run-cycle
coordination, Storage ownership and borrowing, State / Lifecycle, and Error
Handling sections, plus acceptance criteria RP-001, RP-003, RP-004, RP-005,
RP-006, RP-008, RP-010, and RP-012. The principal accepted decisions are
ADR-010's one-shot handoff, ADR-011's sealed at-most-once execution and complete
publication, ADR-012's constant-space refusal intent, ADR-014's bounded outcome
meaning, ADR-015's ordered disposition ownership, and ADR-016's
non-authoritative diagnostics.

The active implementation plan orders the realization through T2.1-T2.5.

## Current-Code Context

`GiftUIExecution` already owns checked identities, admission sealing, phase
transitions, mutation batching, candidate offer/commit, pending presentation,
wake accumulation, focused-failure selection, and finalization recording
seams. `GiftUIRuntimeCore` owns immutable profile limits/audit, validated
storage lifetime, the finite owner-failure carrier, and the coordinator
protocol. The common coordinator composes those owners; it does not reproduce
their algorithms.

## Proposed Internal Organization

Runtime Core uses two small value mechanisms:

- a lifecycle machine retains the successful storage audit, current execution
  context, use/quiescence state, and exclusive-opportunity bit;
- an attempt record retains only stage and cleanup obligations that have
  actually begun, using finite enums and flags rather than closures or a
  history collection.

Profile coordinators own their concrete focused stores and invoke the common
mechanism at each contract boundary. Dynamic and static coordinators therefore
share transitions and cleanup decisions while keeping storage layout in their
own modules.

## Data and Control Flow

Construction accepts only a successful immutable storage audit. The lifecycle
then follows:

```text
unvalidated -> validated -> idle <-> active -> quiescent -> torn down
       \-> rejected
```

Beginning an opportunity atomically checks availability and exclusivity,
allocates or accepts the SPEC-009 context, and enters `active`. Each successful
stage records its cleanup obligation before the next fallible stage begins.
Failure selects the first focused value, runs only mandatory cleanup in reverse
ownership order, finalizes once, releases exclusivity, and returns the exact
correlated result. Successful acceptance commits routing before attempt reset.

Quiescence first makes admission unavailable. Idle quiescence performs
teardown immediately. Active quiescence records a finite request; the active
attempt performs mandatory containment/finalization and then the same teardown
without beginning another stage or opportunity.

## Algorithms and Data Structures

Lifecycle and attempt stages are `UInt8`-backed enums. Cleanup obligations use
a bounded option set whose bits correspond one-to-one with acquired or begun
owners: Observable candidate, Semantic candidate, Layout workspace, Canvas
callable, Drawing plan, Render workspace, Interaction candidate, and offer
transaction. A bit is set only after acquisition/begin succeeds and cleared
immediately after its exactly-once cleanup.

The cleanup oracle is a fixed table indexed by detecting stage. It produces a
bounded mask and disposition facts; it cannot store callbacks or dispatch
behavior. Runtime code intersects that mask with obligations actually present,
then performs owner calls in the normative reverse order. Published semantic
state, applied mutation state, committed routing, pending presentation intent,
and queued later facts are never represented as attempt-cleanup bits.

## Lifecycle and State

Validation failure is terminal and cannot enter idle. `beginOpportunity`
succeeds only from idle without an active owner. Finalization returns active
work to idle unless quiescence was requested, in which case it proceeds to
quiescent teardown. Teardown is idempotent, ends every callback/borrow before
all-storage reset, and makes restart impossible.

The retained audit and execution context are value snapshots. Profile storage
capacity is never re-read as permission to grow; post-validation audit drift is
an invariant violation through the validated storage owner.

## Runtime Profiles and Platforms

Both profiles call the same lifecycle and cleanup mechanism. They differ only
in concrete storage/callable realization described by later profile-specific
design notes. No common transition depends on allocation, reflection, backend
identity, platform APIs, or profile selection from portable presentation code.

## Resource and Failure Behavior

All common state is fixed-size. Attempt bookkeeping is constant-space and
contains no frame payload, diagnostic record, existential, string, closure, or
unbounded history. Arithmetic and identity allocation remain delegated to the
checked focused owners.

The first fallible stage wins. Cleanup failure is recorded separately and may
only widen containment where its owner contract requires it. Diagnostics are
called, if selected, after correctness state and never feed lifecycle,
cleanup, result, wake, or policy decisions.

## Test and Diagnostic Seams

Table-driven recording owners expose calls, stage, cleanup count, retained
context, and quiescence transitions. Fault injection at every boundary proves
later stages are skipped, earlier obligations clean once, applied mutations
are not replayed, and diagnostics do not affect the result. The same oracle
rows feed dynamic/static transcript comparison and later resource probes.

## Rejected Implementation Alternatives

- Profile-private lifecycle machines were rejected because they invite
  semantic drift between dynamic and static execution.
- A stack of cleanup closures was rejected because it retains behavior,
  allocates in common paths, and obscures exact lifetime ownership.
- Reusing a single candidate/committed store with rollback was rejected because
  publication and accepted-only routing require distinct lifetimes.
- Quiescing by recursively running another opportunity was rejected because it
  violates serialized admission and can invoke prohibited work.

## Open Implementation Questions

No correctness-blocking implementation question remains. Concrete profile
storage field packing and static generated capture layout are intentionally
owned by later profile-specific tasks and notes.

## Code and Evidence Links

- T2.1 lifecycle: `Sources/GiftUIRuntimeCore/RuntimeCoordinatorLifecycle.swift`
- T2.1 focused tests:
  `Tests/GiftUIRuntimeCoreTests/RuntimeCoordinatorLifecycleTests.swift`
- T2.1 evidence:
  `Tests/ContractFixtures/SPEC013/Evidence/milestone-2/common-lifecycle.md`

The remaining code and focused evidence links will be added as T2.2-T2.5
land. The authoritative behavior remains SPEC-013 and its accepted ADRs.
