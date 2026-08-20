---
id: ADR-013
feature: giftui-mvp-architecture
title: Provenance-Validated Presentation-Coupled Input
status: proposed
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-20
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-004
related_adrs:
  - ADR-005
  - ADR-007
  - ADR-010
  - ADR-011
related_specs: []
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-013: Provenance-Validated Presentation-Coupled Input

## Status

Proposed.

## Context

Presentation can lag or fail after Core commits a frame. Routing a physical
event against whichever hit map is newest can give an old coordinate a new
meaning, while retaining historical hit maps or deferred events imposes
multi-revision storage and stale-action semantics on constrained targets.

## Decision

Input normalization MUST be a backend-neutral sibling integration seam feeding
runtime admission, not part of the render backend SPI. Presentation-coupled
events MUST carry the eligible physical-presentation revision against which
they were sampled. The target-local gate and runtime admission MUST each
validate that provenance and MUST drop, never retarget or defer, an event whose
eligibility is stale, unavailable, unknown, or no longer authoritative.

A dropped, malformed, out-of-order, or capacity-refused pointer phase MUST
cancel the affected bounded source sequence. Later phases from that sequence
MUST NOT invoke an action. Down may capture only an enabled stable action
identity; release MUST revalidate the same identity, current hit, and current
enabled state before activation.

Core MUST own the committed hit map and bounded pointer sequencing separately
from the render payload. The common MVP path MUST NOT retain historical hit
maps or a deferred-input queue.

## Rationale

Fail-closed provenance preserves the relationship between what a user could
have seen and the action GiftUI invokes. Sequence cancellation prevents
orphaned phases from acquiring meaning after loss, and current-state
revalidation prevents activation of removed, moved, or disabled controls.

## Consequences

### Positive

- Stale input cannot be silently retargeted.
- Input safety requires bounded per-source state rather than historical UI
  revisions.
- Drivers and backends cannot invoke semantic handlers directly.

### Negative

- Conservative validation may cancel interactions during rapid revision
  changes or presentation loss.
- Integrations must coordinate physical presentation eligibility with input.

### Follow-up

- Specifications must define event provenance, source and sequence identity,
  wrap handling, queues, hit maps, cancellation, and activation tests.

## Deferred and Follow-up Work

None. A future alternative that retains historical routing state would require
separate lifecycle approval and measured justification.

## Rejected Alternatives

### Retarget deferred input against the latest revision

Rejected because it can reinterpret an old coordinate against a different
layout or action.

### Retain historical hit maps

Rejected for the common MVP path because it adds multi-revision lifetime,
capacity, and stale-action rules.

### Pin presentation for the entire pointer sequence

Rejected because a failed or held pointer could block presentation progress.

## References

- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
