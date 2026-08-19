---
id: FW-011
feature: giftui-mvp-architecture
title: Handoff-Refusal Frame Rescheduling
status: captured
authors:
  - Yauheni Lychkouski
created: 2026-08-17
updated: 2026-08-18
source:
  - RFC-004
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
synchronous frame handoff, the runtime could mark that revision for another
presentation attempt on a later run-cycle iteration. This would be a new frame
opportunity, not a tight retry loop and not resubmission of the refused frame's
payload. Failures after accepted handoff do not abort the logical frame and
remain outside this item's scope.

RFC-004 now owns the distinct pre-publication case: when reconciliation,
layout, or frame preparation fails after mutations were applied, state remains
dirty and requests a later host-paced recomputation without replaying the
admitted batch.

## Why Deferred

Handoff refusal already leaves GiftUI in a deterministic state, preserves the
previous committed logical frame and routing state, and reports failure. The
MVP does not currently require another presentation opportunity for an
already-published revision after refusal. Adding one would require refusal
classification, retained presentation intent, pacing, and loop-avoidance
policy beyond RFC-004's dirty-state recovery contract.

## Potential Value

- Recover after transient handoff refusal without requiring a new external
  mutation or invalidation.
- Coalesce recovery with the host's next natural run-cycle opportunity.

## Current Non-goals

- No immediate or unbounded retry loop is added.
- No retained frame payload, presentation-pending flag, refusal classifier, or
  retry counter is added to MVP scope.
- RFC-004's required dirty flag and wake request after pre-publication
  derivation failure are not deferred by this item.
- This item does not authorize backend/transport recovery after accepted
  handoff; FW-010 preserves that separate concern.

## Revisit Triggers

- A supported host or reference-application flow requires recovery from a
  refused handoff when no later external invalidation is guaranteed.
- Connected-target evidence shows that handoff refusal leaves the last
  committed logical frame current beyond an accepted product requirement.
- An approved host run-cycle or backend Specification establishes refusal
  classification and retained presentation intent sufficient to reschedule
  without an unbounded failure loop.

## Disposition

Captured with scope narrowed to post-publication handoff refusal after RFC-004
incorporated dirty recovery for pre-publication derivation failures. Promote
through the appropriate feature lifecycle only when a trigger occurs and an
accepted product need justifies retained presentation intent and rescheduling
policy.

## References

- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [FW-010: Backend and Transport Post-Handoff Recovery](fw-010-backend-transport-submission-retry.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
