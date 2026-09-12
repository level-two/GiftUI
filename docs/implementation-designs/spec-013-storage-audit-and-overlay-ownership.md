---
spec: SPEC-013
feature: giftui-mvp-architecture
title: Implementation Design — Storage Audit and Overlay Ownership
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

# Implementation Design — Storage Audit and Overlay Ownership

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## Purpose and Boundary

This note makes the byte ownership and logical-capacity enforcement for
SPEC-013 T3.2 and T4.2 locally reviewable. It covers only profile-owned
storage regions, their audit accounting, and high-water counters. Focused
owner algorithms, coordinator sequencing, generated Canvas grammar, backend
storage, host policy, and production capacity selection remain outside it.

## Governing Contract

SPEC-013 requires sixteen exclusive audit fields, a checked total, independent
logical limits despite spare physical storage, exact render-workspace
capacity, and separate Dynamic allocator reporting. RP-002 and RP-006 require
the resulting ownership and boundary behavior to be reproducible. ADR-006 and
ADR-008 keep the two profile realizations behind Runtime Core, while ADR-010
through ADR-012 fix attempt, publication, committed-routing, and refusal
lifetimes that storage must preserve.

## Current-Code Context

Runtime Core already owns `RuntimeStorageCapacities`, the ordered validation
gate, `RuntimeStorageByteCounts`, checked audit summation, and the reset
lifetime protocol. Focused modules own their record and workspace protocols.
Profile modules therefore supply concrete memory and counters without
redefining any focused record, traversal, layout, rendering, drawing,
observable-state, Interaction, or execution behavior.

## Dynamic Storage Organization

Dynamic storage uses one independently allocated region for each of the
sixteen audit families. Regions never overlap and are not pooled. Each region
retains:

- its fixed family tag;
- its exact addressable payload byte count;
- its configured logical dimensions;
- current and high-water use for each dimension; and
- the allocation's observed reserved payload capacity.

Construction allocates every region before validation and derives the audit
byte fields from region payload counts, not from requested limits or a global
estimate. The checked Runtime Core audit remains the sole total calculation.
The Dynamic report records allocation count and reserved payload headroom
separately. Allocator headers that Swift does not expose are measured by the
T7.2 allocation probe and never folded into `totalProfileBytes`.

Logical reservation compares the requested count with the configured
dimension before changing state. A failed reservation leaves current and
high-water counts unchanged. Physical `Array` capacity or heap availability
never grants permission to exceed the configured dimension.

## Static Storage Organization

Static storage follows the same sixteen-family registry and logical dimension
mapping, but each region is backed by fixed/generated/inline or caller-supplied
typed storage. It performs no allocation and reports no allocator headroom.
The concrete layout and generated Canvas capture bindings land only after the
owning SPEC-010 and SPEC-012 generator seams are available.

## Family and Lifetime Mapping

Candidate/attempt reset owns semantic candidate, layout candidate, render
workspace, Canvas callable, Path workspace, drawing plan, observable
candidate, and Interaction candidate regions. Published semantic, observable
live, Interaction committed, admission queue, sealed batch, pointer,
coordinator, and failure regions survive attempt reset. All-storage reset
clears every region only before use or after quiescent teardown.

The admission queue and sealed batch remain distinct simultaneous regions.
Candidate and committed Interaction remain distinct. Published and candidate
semantic/observable regions remain distinct. No family donates capacity or
bytes to another family.

## Resource and Failure Behavior

Byte-count conversion and total summation are checked before construction
succeeds. Missing regions, insufficient logical dimensions, incompatible
limits, or arithmetic overflow return the existing validation errors. Dynamic
allocation failure is not translated into a new contract error; the normal
Swift process allocation behavior applies before a storage value exists.

High-water counters saturate nowhere: an increment that cannot be represented
is rejected before mutation. Counters and reports contain no history,
callbacks, diagnostics, or retained borrowed payloads.

## Test Seams

Focused tests construct artificial regions, reserve every logical dimension at
its exact limit, reject first excess, and compare unchanged state after
rejection. Audit tests compare each region's payload count with its exact
`RuntimeStorageAudit` field and verify the checked total. Reset tests remain in
T3.3/T4.2 because they exercise candidate/published lifetime distinctions.

## Rejected Alternatives

- A shared byte pool was rejected because overlapping family ownership would
  obscure audit reconstruction and allow accidental capacity donation.
- Reporting requested bytes without allocating regions was rejected because
  it would not be a concrete storage audit.
- Using physical `Array` capacity as a logical limit was rejected because
  allocator headroom is implementation-dependent and violates equal-limit
  behavior.
- Moving focused record algorithms into profile storage was rejected because
  those owners already define the authoritative protocols and behavior.

## Open Implementation Questions

No T3.2 correctness question remains. T4.2's exact fixed packing depends on
the landed generated metadata and will be documented here when implemented;
it cannot change the family registry, logical dimensions, or audit fields.
