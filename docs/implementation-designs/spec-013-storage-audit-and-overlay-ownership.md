---
spec: SPEC-013
feature: giftui-mvp-architecture
title: Implementation Design — Storage Audit and Overlay Ownership
status: current
authors:
  - codex
created: 2026-09-12
updated: 2026-10-11
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

## RFC-014 P07 — actual Dynamic backing repair

This current section governs the replacement implementation direction under
[the active P07 sequence](../iterations/iteration-003-review/rfc-014-implementation-plan.md)
and SPEC-013 T11.1 / RP-002 / RP-RD-001–002. The sixteen-region description below
is the retained schema-3 baseline, not evidence for the migrated typed owners.
The amended contract requires 26 exclusive fields and actual construction/audit
agreement before client traversal; later allocator/full-image gates do not waive
that requirement.

The actual Dynamic layout workspace currently has a private Dictionary index,
and Drawing creates separate point/subpath arrays for each stroke and a fresh
live-path store per path. Neither is the old raw-region recipe. Do not report
that recipe or guessed Dictionary/object sizes as their actual storage.

The bounded repair keeps the shared focused algorithms, owner boundaries,
complete record identity semantics, limits and failure precedence unchanged:

- Dynamic layout uses a preallocated ordinal-to-scope table sized from the actual
  semantic structural capacity. Every lookup also checks the complete stored
  owner/bank/revision/ordinal reference. Reset clears only occupied entries.
  Lookup remains constant work and reset is linear in occupied scopes, preserving
  SPEC-007 O(n + g) and ITERATION-003 I3-T01 indexing obligations. Out-of-range
  ordinals and duplicate occupied ordinals fail before writes; one attempt reads
  one qualified semantic snapshot. No general map subsystem is introduced.
- Resolved-layout publication swaps retained scope/glyph banks and fills the
  preallocated line bank, keeping publication data and retained extents separate.
- Dynamic Drawing reserves aggregate point and subpath pools before use. Each
  stroke stores ranges into those pools. Failed appends roll back both pool
  cursors, preserving the existing all-or-nothing append behavior.
- One preallocated live-path backing remains owned by the workspace. Begin/end
  path and Canvas cleanup reset its logical contents and scope state without
  dropping its allocation. Borrowed stroke views remain scoped to the owned plan.
- Payload extent reports use actual retained Array capacities and element
  strides; value metadata uses the pinned compiler's MemoryLayout. Runtime Core
  still performs checked summation. Runtime allocator headers/spare allocation
  overhead and complete linked-image accounting stay separately reported at
  their existing gates, never substituted for owned payload extents.

Focused evidence must cover complete Static/Dynamic cycle equivalence, drawing
rollback and capacity edges, reset/reuse, full owner identity lookup and unchanged
fault outcomes. Focused index evidence includes foreign owner/bank/revision,
out-of-range ordinal, duplicate and first-excess rejection, reset/reuse and
constant indexed lookup work. Existing controls remain historical evidence; no approval or
conformance transition is implied by this note.

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

## Amended failure carrier measurement — 2026-10-02

Framework/composed first-failure values both have 28-byte stride under macOS,
ARMv6 and Embedded compilers. The bounded application sum therefore introduces
no specialization delta in this value. Existing generated128/96-byte failure
regions are unchanged. [T9.3 evidence](../../Tests/ContractFixtures/SPEC013/Evidence/milestone-9/carrier-resources.md)
is pre-join proof; actual production placement and total binary/storage audit
remain downstream obligations. It does not authorize double-counting a value
and its backing region, stack overlay, or overlapping retained lifetimes.
