---
spec: SPEC-006
feature: giftui-mvp-architecture
title: Implementation Design — Bounded Semantic Expansion
status: current
authors:
  - codex
created: 2026-09-05
updated: 2026-09-05
implementation_plan: ../implementation-plans/spec-006-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Bounded Semantic Expansion

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## Purpose and Boundary

This note explains how `GiftUISemanticCore` realizes one synchronous,
fixed-width, all-or-nothing semantic expansion attempt. It covers attempt
state, profile-owned path and identity operations, sealed declaration
dispatch, modifier-chain state, publication, rollback, and test seams.

The note does not define identity equality, public or package SPI, concrete
workspace storage, runtime-profile capacities, layout input, state binding,
failure-fact mapping, or canonical recording vocabulary. Those meanings remain
with SPEC-006, SPEC-010, later runtime-profile contracts, and the tasks that own
them.

## Governing Contract

The realization follows SPEC-006's `Expansion limits and summary`, `Expansion
order`, `Structural identity`, `Action identity`, `Modifier order`,
`Atomicity`, `State / Lifecycle`, `Error Handling`, and `Performance
Requirements` sections. It implements plan tasks T2.1 through T2.3 and records
the T2.4 design decision.

The relevant accepted decisions are:

- ADR-005: Semantic Core, not a backend, owns expansion and identity.
- ADR-006: dynamic and static profiles preserve equal observable semantics
  while their storage may differ.
- ADR-008: `GiftUISemanticCore` depends downward only on `GiftUI`.
- ADR-032: complete successful semantic storage remains owned by Semantic Core
  and is later borrowed by layout without a second graph.
- ADR-033: expansion stages a bounded action value and stable semantic action
  identity, but no generation, target, callable, handler, or model.

## Current-Code Context

`GiftUI` owns the public underscored visitor and typed payload protocols.
`GiftUISemanticCore` owns the local values, caller-owned workspace and sink
protocols, `SemanticExpansionAttempt`, the private
`SemanticExpansionTraversal`, and the sole generic `expandSemanticTree` entry.

T2.1 introduced the exact local values and collaborator operations. T2.2 added
the lifecycle and reservation coordinator. T2.3 connected the fixed visitor
categories to that coordinator. The SPEC-010 stateful category is present but
remains fail-closed without body access until Milestone 5 supplies the owning
binding decorator.

## Proposed Internal Organization

`SemanticExpansionAttempt` contains only immutable limits, fixed-width
counters, capacity snapshots, current and maximum depth, begin-state flags,
and the first local failure. It knows no `View` type and retains no declaration
or payload.

`SemanticExpansionTraversal<Workspace, Sink>` owns one attempt plus value
copies of the two generic collaborators for the duration of the synchronous
call. The entry copies the updated values back to the caller's `inout`
arguments before success or rollback completes. This keeps the visitor a plain
generic value and avoids an escaping reference, existential, registry, or
profile-specific dependency. A static profile can supply fixed-storage value
collaborators; a dynamic fixture may supply different bounded storage.

The workspace alone realizes path components and profile-private identity.
The traversal requests path changes in normative order and treats the returned
identity as an opaque `Equatable` value. The sink alone realizes staged and
published semantic storage. Neither collaborator can change declared counts,
path order, modifier indices, or the closed local result.

## Data and Control Flow

`expandSemanticTree` performs these phases:

1. Construct an attempt from immutable limits.
2. Reject an already-active workspace before touching the sink.
3. Snapshot every reported finite capacity, then begin workspace and sink.
4. Move the collaborators into the generic visitor, enter the root component,
   and traverse the root through its sealed witness.
5. Copy the mutated attempt, workspace, and sink back to the entry point.
6. On the first local failure, discard both staged collaborators and reset
   them to idle. Otherwise require balanced path depth, complete the workspace,
   publish the sink once, reset both, and return the exact summary.

Every recursive declaration call saves its parent identity, visitor-category
flag, and modifier-chain state on the bounded machine stack. It enters one
declaration-role component, stages the structural occurrence, invokes exactly
one visitor category, leaves the component, and restores its parent state.
Fixed children, selected conditional branches, optional presence, and custom
bodies add their required components around that declaration call.

## Algorithms and Data Structures

### Reservations

All counters use `UInt16.addingReportingOverflow`. A reservation computes and
validates the next value before storing it. Rejected reservations therefore do
not wrap or increment a published count.

Path entry checks declared depth and the workspace's reported path capacity
before calling the workspace. The workspace then validates and returns the
resulting identity. Declared body, semantic-node, modifier, and action counts
are reserved before sink capacity and staging hooks. An action-bearing
primitive reserves its semantic node before its action occurrence.

The first local error is sticky. Later attempt operations return it without
calling another workspace, sink, declaration, or body hook. The entry point is
the only owner that translates that error into the public local result and
performs discard/reset.

### Traversal and category validation

The private visitor is specialized over concrete workspace and sink types.
Each `View` witness must call exactly one visitor category. A per-declaration
flag detects zero or multiple category calls before success; this is a
framework invariant check, not a client extension mechanism.

Custom views enter `customBody`, reserve one body evaluation, and call the
nonescaping accessor once. Fixed groups visit children by increasing `UInt8`
index. Conditional and optional wrappers enter only selected or present paths.
Primitives stage their typed payload. Action primitives stage their borrowed
bounded action value after semantic-node admission.

### Modifier-chain state

`nextModifierChainIndex` is scope-local traversal state. A modifier expands its
content while continuing the current chain, then stages itself and advances
the index. Ordinary child, custom-body, and sibling declaration calls save and
restart the index at zero, then restore the enclosing value. Consequently
nested wrappers for `base.a().b()` emit indices `0, 1`, while a sibling or an
inner custom body begins a separate chain at zero.

## Lifecycle and State

An attempt advances from idle to expanding and then either to published
success or discarded local failure. `workspaceBegan` and `sinkBegan` ensure
cleanup calls only collaborators that actually began. Success requires both
collaborators, balanced path depth, and nonzero observed depth.

Publication calls the workspace completion hook before asking the sink to
publish the complete summary. A publish refusal after sufficient reported
capacity is an invariant violation; the staged attempt is discarded and both
collaborators reset. Successful reset ends expansion but does not redefine how
a profile exposes its now-current complete semantic result.

## Runtime Profiles and Platforms

The algorithm and visitor categories are identical for macOS dynamic/static,
Raspberry Pi ARMv6 dynamic, and nRF52840 static builds. Profiles vary only the
associated identity representation and finite workspace/sink storage. The
generic core never branches on profile, platform, backend, capability, driver,
OS, RTOS, HAL, or hardware identity.

The standalone macOS contract driver builds a `GiftUI` library before linking
the Semantic Core library because the concrete visitor references `GiftUI`
protocol metadata. Cross-build drivers continue to use the pinned toolchains
and target configurations established by SPEC-002.

## Resource and Failure Behavior

The attempt itself has fixed-width value state and performs no allocation.
Traversal specialization requires no `Any`, reflection, string path, runtime
registry, Objective-C, task, or actor. Actual staged-memory and identity-memory
bounds remain those reported by the caller-owned collaborators.

Recursive work proceeds only after a successful path reservation. Its nesting
therefore remains bounded by the declared structural depth. Every admitted
body, semantic node, modifier, and action is visited a constant number of
times; no failure retries, truncates, overwrites, or selects an allocating
fallback.

A reported capacity reached before a hook returns `.capacityExhausted`. A hook
that refuses after advertising sufficient capacity returns
`.invariantViolation`. Workspace identity validation may return
`.invalidIdentity`; same-workspace active entry returns
`.reentrancyViolation`. All failures preserve the first error, discard staged
output, and reset for later reuse.

## Test and Diagnostic Seams

`SemanticExpansionAttemptTests` independently observe begin, reservation,
stage, complete, publish, discard, reset, overflow-before-wrap, false capacity
reporting, first-failure stability, and reuse.

`SemanticExpansionTraversalTests` use symbolic fixture identities and an
attempted-versus-committed sink to observe order, counters, maximum depth,
active/inactive body access, action staging, modifier indices, and atomic
failure. The canonical recording vocabulary, identity-relation corpus,
cross-profile comparison, allocation instrumentation, and owner failure
mapping remain assigned to Milestones 3, 4, and 6.

Diagnostics do not participate in this mechanism. The later test-only owner
adapter may observe the closed result only after Semantic Core returns.

## Rejected Implementation Alternatives

- Retaining the borrowed root or body closures in a workspace was rejected
  because attempt lifetime is synchronous and declarations are transient.
- A second runtime-specific traversal engine was rejected because profiles may
  vary storage, not semantic order or visitor categories.
- String paths, metatype-address identity, hashing without collision proof,
  existential payloads, reflection, and a global declaration registry were
  rejected by the approved contract.
- Publishing sink entries incrementally was rejected because no partial tree,
  identity map, modifier chain, or action map may become current.
- Implementing observable-state binding inside Semantic Core was rejected
  because SPEC-010 owns that mechanism and its exact failures.

## Open Implementation Questions

No open implementation choice blocks T2.1 through T2.3. Milestone 3 must choose
the checked-in recording workspace and sink representations while preserving
this coordinator and SPEC-006's exact canonical equality and transcript rules.
Milestone 5 must compose the SPEC-010 binding decorator without converting its
binding failures into `SemanticExpansionError`.

## Code and Evidence Links

- [`GiftUISemanticCore.swift`](../../Sources/GiftUISemanticCore/GiftUISemanticCore.swift)
- [`SemanticExpansionAttemptTests.swift`](../../Tests/GiftUISemanticCoreTests/SemanticExpansionAttemptTests.swift)
- [`SemanticExpansionTraversalTests.swift`](../../Tests/GiftUISemanticCoreTests/SemanticExpansionTraversalTests.swift)
- [Expansion values evidence](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-2/expansion-values.md)
- [Attempt lifecycle evidence](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-2/attempt-lifecycle.md)
- [Atomic traversal evidence](../../Tests/ContractFixtures/SPEC006/Evidence/milestone-2/atomic-traversal.md)
- [SPEC-006](../specs/spec-006-declarative-view-semantics.md)
- [SPEC-006 Implementation Plan](../implementation-plans/spec-006-implementation-plan.md)
