---
id: FW-011
feature: giftui-mvp-architecture
title: Handoff-Refusal Frame Rescheduling
status: closed
authors:
  - Yauheni Lychkouski
created: 2026-08-17
updated: 2026-08-20
source:
  - RFC-004
  - ADR-012
related_future_work:
  - FW-010
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-011: Handoff-Refusal Frame Rescheduling

## Observation / Opportunity

After a semantic revision has been published but a backend refuses the
synchronous frame handoff, the runtime must mark the latest revision for
another presentation attempt on a later run-cycle iteration. This is a new
frame opportunity, not a tight retry loop and not resubmission of the refused
frame's payload. Review also established that refusal is permitted only before
irreversible presentation output; once output begins, responsibility has
transferred and later failures are post-handoff operational conditions.

RFC-004 now owns the distinct pre-publication case: when reconciliation,
layout, or frame preparation fails after mutations were applied, state remains
dirty and requests a later host-paced recomputation without replaying the
admitted batch.

## Why Originally Deferred

The original capture treated deterministic abort, preservation of the previous
logical frame, and failure reporting as sufficient for MVP. Review showed that
this could leave the Signal Analyzer permanently stale, especially when its
presentation-coupled input is gated and no later mutation is guaranteed. That
evidence fired the item's first revisit trigger and made convergence or
explicit unavailability necessary for current RFC coherence.

## Potential Value

- Recover after transient handoff refusal without requiring a new external
  mutation or invalidation.
- Coalesce recovery with the host's next natural run-cycle opportunity.

## Remaining Non-goals

- No immediate or unbounded retry loop is added.
- No retained frame payload or replayable operation representation is added to
  MVP scope.
- RFC-004's required dirty flag and wake request after pre-publication
  derivation failure are not deferred by this item.
- This item does not authorize backend/transport recovery after accepted
  handoff; FW-010 preserves that separate concern.

## Trigger Resolution

- Trigger fired: RFC review demonstrated that the Signal Analyzer may receive
  no later invalidation after refusal and may gate input while presentation is
  incoherent.
- RFC-004 now owns constant-space latest-revision presentation intent,
  separately paced rederivation after retryable refusal, refusal before
  irreversible output only, and a finite unavailable/quiescent terminal
  policy.
- Exact counters, attempt limits, delays, and readiness APIs remain
  Specification details within those architectural bounds.

## Disposition

Closed after its recorded MVP trigger fired during RFC review. The required
decision returned to its source, RFC-004, because deferral made that RFC
incoherent. Closure does not approve RFC-004 or authorize implementation;
accepted ADRs and approved Specifications remain required. Generalized
retained-payload replay and post-handoff recovery remain outside this item and
under FW-010.

## References

- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [FW-010: Backend and Transport Post-Handoff Recovery](fw-010-backend-transport-submission-retry.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
