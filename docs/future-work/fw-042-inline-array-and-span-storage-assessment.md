---
id: FW-042
feature: external-application-integration
title: InlineArray and Span for Fixed Buffer Storage
status: captured
authors:
  - codex
created: 2026-11-07
updated: 2026-11-07
source:
  - docs/iterations/iteration-004-backend-and-application-integration.md
  - Sources/GiftUIRuntimeStatic/StaticProfileStorage.swift
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: ITERATION-004
---

# FW-042: InlineArray and Span for Fixed Buffer Storage

## Observation / Opportunity

On 2026-11-07 Eugene asked whether homogeneous UInt8 tuples could be replaced
with InlineArray or Span while retaining precise control of memory allocation,
ownership and lifetime. Assess InlineArray as owned fixed-capacity storage and
Span/MutableSpan as borrowed access to that storage, not as interchangeable owners.
GiftUI already uses both families; the 51-element UInt16 tuple in
StaticLimitCounters is a related candidate for removing unsafe offset indexing.

For positive N, InlineArray<N, UInt8> has N-byte size/stride and alignment 1,
with no separate backing allocation. Inline placement does not promise stack
placement, a stable address or freedom from temporary copies. UInt8 inline arrays
remain copyable; assess noncopyable owners and borrowing/inout/consuming APIs
where required. Safe spans constrain access to the backing lifetime; unsafe
construction and escaped pointers still require explicit proof. Neither type
alone solves DMA or other asynchronous pointer retention.

## Why Deferred

This is post-MVP maintenance assessment for iteration 4, not an identified
current delivery blocker. Compiler availability alone does not establish target
costs, ABI compatibility or lifetime correctness for each replacement. Current
iteration-3 delivery and resource evidence must remain intact.

## Potential Value

- Replace homogeneous buffer tuples and unsafe indexing with bounded typed access.
- Express ownership separately from borrowed algorithms without extra backing allocation.
- Reduce maintenance while preserving exact resource and lifetime guarantees.

## Current Non-goals

- Blanket replacement of semantic tuples, imported C layouts or hardware buffers.
- New ownership contracts, compiler upgrades, changed budgets or production edits
  authorized solely by this record.
- Assuming noncopyability pins addresses, or that host results prove ARMv6/Embedded
  feasibility, complete peak stack usage or connected hardware behavior.

## Revisit Triggers

- During ITERATION-004 I4-09 planning, after I4-05 identifies the compiler baseline,
  inventory tuple buffers and coordinate with I4-06 ownership and I4-07 delivery.
- Earlier only if a measured tuple-buffer cost or safety defect blocks an existing
  requirement; route that specific blocker through its current owner and gates.

## Disposition

Captured. Eugene instructed on 2026-11-07: “please formalize it in the future work
item and add to the next iteration”, then “and commit”. This explicitly schedules
the assessment as I4-09 / I4-AC-010 in ITERATION-004 revision 6; it does not approve
a replacement design or change current implementation authority.

Record migrate/retain/defer per candidate, including semantic role, owner and
borrow boundaries, exact size/stride/alignment, containing padding, initialization,
temporary/copy costs, allocation and complete stack/RAM/flash implications.
Identify compiler/SDK/flags for macOS Dynamic/Static, Raspberry Pi 1 ARMv6 and
nRF52840 Embedded. Include positive access cases and compiler-negative lifetime,
escape and exclusivity controls; preserve address stability through asynchronous
completion where applicable. Mark missing evidence explicitly rather than
assuming portability or savings.

Use an Exploration and bounded Spike if uncertainty needs experiments. Mechanical
contract-preserving replacements may use the lifecycle's lightweight path after
assessment; public/cross-module, ownership, ABI or material resource changes need
the applicable Proposal/RFC/ADR/Specification review before adoption. Retaining
existing storage is a valid outcome. Promotion remains unset until another
lifecycle artifact takes ownership.

## References

- [ITERATION-004](../iterations/iteration-004-backend-and-application-integration.md).
- [StaticLimitCounters](../../Sources/GiftUIRuntimeStatic/StaticProfileStorage.swift).
- [Existing InlineArray and mutable span usage](../../Sources/GiftUIObservableState/ObservableStateRootScope.swift).
- [Swift SE-0453: InlineArray](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0453-vector.md).
- [Swift Span documentation](https://docs.swift.org/latest/documentation/swift/span/).
