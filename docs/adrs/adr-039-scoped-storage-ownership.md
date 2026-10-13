---
id: ADR-039
feature: external-application-integration
title: Scoped Storage Ownership
status: proposed
authors:
  - codex
created: 2026-10-13
updated: 2026-10-13
proposal:
  - PROPOSAL-007
related_rfcs:
  - RFC-015
  - RFC-014
related_adrs:
  - ADR-007
  - ADR-008
  - ADR-035
  - ADR-036
  - ADR-038
related_specs:
  - SPEC-011
  - SPEC-013
  - SPEC-015
related_future_work:
  - FW-037
related_explorations: []
related_spikes:
  - SPIKE-075
supersedes: []
superseded_by: []
target_milestone: ITERATION-004
---

# ADR-039: Scoped Storage Ownership

## Status

Proposed. Extracted from approved RFC-015 at `ec29db3c`; acceptance of this
new text remains explicit. The [readiness and approval record](../iterations/iteration-003-review/rfc-015-readiness-and-approval.md)
authorizes downstream preparation and commitment, not acceptance by inference.

## Context

PROPOSAL-007 and ITERATION-003 I3-04/I3-05 require runtime-derived analyzer and
finite-counter compositions across the four governed configurations, preserving
closed ITERATION-001 analyzer and stack regression obligations. P08's latest
construction closure uses 58,648 local stack bytes against the unchanged
27,648-byte main stack. Ordinary by-value geometry/Interaction carriers neither
bound extracted pointer access nor establish fit. The initialized old
`CounterStaticKeys?` slot is not uninitialized space for five owners.

## Decision

For the finite P08 composition, separate stable typed physical ownership from
Interaction transaction ownership and compiler-bounded exclusive access.
One physical owner MUST initialize and destroy each disjoint geometry object
and each of the five Interaction banks once in its final region. One exclusive
actual-owner session MUST lend concrete noncopyable, nonescapable accesses through
the complete supplied/pipeline/coordinator/host/retirement chain. Consuming an
access transfers authority, never physical backing or destruction responsibility.
All five banks and geometry MUST share one actual-owner session lifetime;
private immutable provenance MUST NOT become duplicated mutable authority.

Interaction MUST retain its one transaction state and complete independently
owned bounded keys, preserving accepted-offer commit, refusal/discard, identity,
generation, capacity and failure semantics. Equal immutable logical capacities
within exchanged R and H pairs MUST be validated before session acquisition.
Complete role descriptors may exchange within that session; physical destruction
inventory and retained-byte accounting MUST remain independent of roles.

Trusted restricted factories MUST hold actual typed borrows for every access,
exclude aliases/reentry, and expose no raw descriptors, arbitrary conformer entry,
mutable-bank extraction or scoped callback result. Package protocols admit scoped
Self only for the three storage and three named operation contracts. Both existing
state types MUST retain conditional owned conformances; operation-only consumers
may borrow scoped values, while retained dispatchers/analyzer consumers stay owned.
A separate duplicated owned state machine is not selected.

Checked physical initialization MUST unwind its successful prefix on failure.
The nonthrowing consuming session body MUST own structured logical cleanup,
quiescence and consuming retirement on every return. The factory owns the enclosing
borrow; physical backing ends last. Lifetime checking does not replace validation
of capacity, phase, identities, provenance, initialization or callback quiescence.

This additive decision preserves ADR-007/008 imports/composition, ADR-035 keys,
ADR-036 backing/model pins and ADR-038 explicit construction inputs. It selects
no public extension surface, universal storage architecture or resource exception.

## Rationale

The approved trade-off favors complete compiler-bounded access through the shared
Interaction machine over inline bank transfers or a fixture-specific machine.
Stable ownership permits smaller transfers without claiming target fit. Conditional
owned conformances preserve existing finite stores and the selected migration scope.

## Consequences

### Positive

- Safe supported clients cannot copy or outlive mutable accesses through carriers.
- Transaction role changes do not relocate physical objects or lose destruction ownership.
- Existing owned routes and Interaction semantics have one implementation contract.

### Negative

- Cross-module signatures, callers and retirement need migration and full lifetime tests.
- Trusted unsafe bridges, alias exclusion, initialization and cleanup still need review.
- Full compiler composition and target stack/image fit remain unproved; smaller handles
  and SPIKE-075's bounded native evidence do not establish conformance.

### Follow-up

- Accept this ADR, then approve/apply the [exact Spec packet](../iterations/iteration-003-review/rfc-015-spec-amendments.md).
- Adopt the [conditional P08 handoff](../iterations/iteration-003-review/rfc-015-p08-handoff.md),
  supply physical design notes and separately bound execution/validation authority.
- Complete the P08-applicable B1–B3 evidence before P08 acceptance; full RFC
  delivery belongs to ITERATION-004 I4-07 under the
  [delivery allocation](../iterations/iteration-003-review/rfc-015-delivery-allocation.md).
  B4 retains these authority gates.
  All historical budgets and the two-consecutive-unproductive stop rule remain.

## Deferred and Follow-up Work

[FW-037](../future-work/fw-037-core-wide-storage-ownership-generalization.md) retains
Core-wide/second-consumer assessment in ITERATION-004; it grants no P08 expansion.
Closed SPIKE-075 supplies qualified feasibility evidence only. Required B1–B4
work is not deferred there.

## Rejected Alternatives

### Retain inline owners / fixture-only owned repair

Credible but not selected: the approved choice favors compiler-bounded access
through shared Interaction. Neither impossibility of an owned repair nor sufficient
stack reduction by this choice has been demonstrated.

### Ordinary escaping handles or an outer lease

A raw pointer and separately held lease do not propagate every backing lifetime.
A genuinely retained owned handle would require a different bounded lifetime/cost
contract, not established by RFC-015.

### Per-phase borrowing or in-place construction alone

Per-phase access still needs persistent state/committed ownership; in-place
construction alone does not constrain escapes. Final-region typed initialization
complements the selected session rather than replacing its lifetime obligations.

### Erasure, rebinding live storage, or larger limits

Lifetime erasure, blanket suppressions, public generic factories, rebinding the
initialized Optional slot, semantic-bank indices as keys and relaxed heap/stack/
workload limits are excluded by the approved decision.

## References

- [Approved RFC-015](../rfcs/rfc-015-p08-scoped-storage-ownership.md), ownership graph,
  exact carriers, R1–R4, retirement, B1–B4 and Decision Summary.
- [Accepted PROPOSAL-007](../proposals/proposal-007-external-application-integration.md).
- [ITERATION-003](../iterations/iteration-003-dev-ux-improvement.md) and
  [closed ITERATION-001](../iterations/iteration-001-mvp.md).
