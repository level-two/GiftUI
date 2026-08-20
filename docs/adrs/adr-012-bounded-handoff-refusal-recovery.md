---
id: ADR-012
feature: giftui-mvp-architecture
title: Bounded Handoff-Refusal Recovery
status: proposed
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-20
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-004
  - RFC-005
related_adrs:
  - ADR-010
  - ADR-011
  - ADR-014
  - ADR-015
  - ADR-017
related_specs: []
related_future_work:
  - FW-011
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-012: Bounded Handoff-Refusal Recovery

## Status

Proposed.

## Context

A semantic revision may already be published when a backend refuses its frame
before acceptance. Dropping the obligation forever can leave a stale but
apparently interactive UI, while retaining and replaying the refused payload
would violate the one-shot contract and repeat work or effects.

## Decision Boundary

This record extracts RFC-004 Decision Summary item 5. It owns recovery after
a retryable refusal before acceptance and irreversible presentation effects,
including constant-space intent, finite pacing, and terminal unavailability.
It does not govern failure after accepted handoff, retain or replay an offered
payload, or define the general outcome vocabulary in ADR-014.

## Decision

After a retryable handoff refusal before acceptance and before any irreversible
presentation effect, the runtime MUST retain only
constant-space presentation intent for the latest published revision and
request a separately paced host opportunity. Recovery MUST rederive from
current state without replaying admitted facts, actions, effects, or the
refused operation payload. Newer published revisions MUST coalesce over older
pending intent.

The target composition MUST provide finite pacing and attempt policy. Policy
exhaustion or non-retryable refusal of a required presentation facility MUST
make that facility explicitly unavailable and quiesce affected interaction.

## Rationale

Latest-revision intent is sufficient to converge presentation without storing
a frame or replaying semantic effects. Finite host pacing prevents hot retry
loops and supplies a deterministic terminal state.

## Consequences

### Positive

- Recovery remains constant-space and compatible with one-shot handoff.
- New state naturally supersedes obsolete pending presentation.
- Terminal failure cannot leave a misleading interactive stale display.

### Negative

- Recovery recomputes layout and rendering.
- Hosts must define pacing, attempt limits, and terminal behavior.
- Some intermediate published revisions may never receive a committed frame.

### Follow-up

- Specifications must define presentation-pending state, coalescing, wake
  requests, finite policies, and unavailability/input-quiescence behavior.

## Deferred and Follow-up Work

- [FW-011](../future-work/fw-011-failed-frame-rescheduling.md) records the
  resolved review trigger that brought this behavior into MVP scope.

## Rejected Alternatives

### Retain or replay the refused payload

Rejected because it extends the operation lifetime and adds storage while
still risking stale presentation.

### Unbounded immediate retry

Rejected because deterministic refusal could create recursion, consume power,
and prevent a stable terminal disposition.

### Rely only on a periodic frame tick

Rejected because it neither records the outstanding obligation nor bounds
retry exhaustion.

## References

- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-005: Failure and Diagnostics Propagation Architecture](../rfcs/rfc-005-failure-diagnostics-propagation.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
