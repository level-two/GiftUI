---
id: ADR-013
feature: giftui-mvp-architecture
title: Provenance-Validated Presentation-Coupled Input
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-26
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
related_specs:
  - SPEC-002
  - SPEC-006
  - SPEC-009
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-013: Provenance-Validated Presentation-Coupled Input

## Status

Accepted.

## Context

Presentation can lag or fail after Core commits a frame. Routing a physical
event against whichever hit map is newest can give an old coordinate a new
meaning, while retaining historical hit maps or deferred events imposes
multi-revision storage and stale-action semantics on constrained targets.

## Decision Boundary

This record extracts RFC-004 Decision Summary item 6 and RFC-002 Decision
Summary item 10. It owns normalization placement, presentation provenance,
fail-closed runtime admission, and bounded pointer sequencing. It does not
define device sampling or calibration, target-specific eligibility evidence,
or semantics for input explicitly independent of presentation.

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
identity and its committed action generation; it MUST NOT capture or retain the
callable payload. Release MUST revalidate the same identity-generation pair,
current hit, and current enabled state before activation.

Each committed action record MUST associate its stable semantic identity with
a finite non-aliasing generation and the current callable payload. Installing
a newly derived callable payload at the same identity is replacement and MUST
install a new generation. Implementations MUST NOT compare closures or infer
their equivalence. They MAY preserve a generation only by preserving the exact
previously committed payload rather than substituting the newly derived one.
An aborted or refused candidate MUST leave the committed payload and generation
unchanged.

If the captured generation no longer matches at release, activation MUST be
cancelled and neither the former nor replacement payload may be invoked.
Pointer capture therefore does not extend the former payload's lifetime. A
committed revision may advance without cancelling the press when the complete
action record remains unchanged. Generation exhaustion or ambiguous reuse MUST
fail closed and MUST NOT alias a captured or admitted identity-generation pair.

Core MUST own the committed hit map and bounded pointer sequencing separately
from the render payload. The common MVP path MUST NOT retain historical hit
maps or a deferred-input queue.

## Rationale

Fail-closed provenance preserves the relationship between what a user could
have seen and the action GiftUI invokes. Sequence cancellation prevents
orphaned phases from acquiring meaning after loss, and current-state
revalidation prevents activation of removed, moved, or disabled controls. The
generation distinguishes replacement at one stable structural identity
without retaining an obsolete callable or pretending that Swift closures have
portable equality.

## Consequences

### Positive

- Stale input cannot be silently retargeted.
- Replaced action behavior cannot be invoked through an older press, and a
  press cannot unexpectedly acquire newly substituted behavior.
- Input safety requires bounded per-source state rather than historical UI
  revisions.
- Drivers and backends cannot invoke semantic handlers directly.

### Negative

- Conservative validation may cancel interactions during rapid revision
  changes or presentation loss.
- Replacing a callable payload during a press cancels that activation even when
  the client regards the old and new closures as behaviorally equivalent.
- Static profiles require bounded generation storage and fail-closed wrap
  handling.
- Integrations must coordinate physical presentation eligibility with input.

### Follow-up

- Specifications must define event provenance, source, sequence, and action-
  generation widths, wrap handling, queues, committed action records, payload
  ownership, hit maps, cancellation, and activation tests.

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

### Capture the callable payload on pointer down

Rejected because it extends obsolete client behavior across committed
revisions and requires pointer state to retain callable payload lifetime.

### Resolve only the stable identity on release

Rejected because replacement at the same structural identity could give an
existing press newly substituted behavior that was not committed when the
press began.

### Compare old and new closures for equivalence

Rejected because Swift closures do not provide the portable, deterministic
equality required by dynamic and static profiles.

## References

- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [SPEC-006: Declarative View Semantics Specification](../specs/spec-006-declarative-view-semantics.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
