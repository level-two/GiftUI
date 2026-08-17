---
id: FW-011
feature: giftui-mvp-architecture
title: Failed-Frame Rescheduling
status: captured
authors:
  - Yauheni Lychkouski
created: 2026-08-17
updated: 2026-08-17
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

# FW-011: Failed-Frame Rescheduling

## Observation / Opportunity

After a frame abort, the runtime could keep an invalidation pending and offer
a newly evaluated frame on a later run-cycle iteration. This is a new frame
opportunity, not a tight retry loop and not resubmission of the aborted frame's
payload.

## Why Deferred

Required frame abort already leaves GiftUI in a deterministic state, preserves
the previous committed logical frame, and reports failure. The MVP does not
require an automatic recovery opportunity, and rescheduling would introduce
host wake behavior, invalidation lifetime, failure classification, pacing, and
loop-avoidance policy that are not needed to establish the transaction model.

## Potential Value

- Recover presentation after a transient condition without requiring a new
  external mutation or invalidation.
- Coalesce recovery with the host's next natural run-cycle opportunity.

## Current Non-goals

- No immediate or unbounded retry loop is added.
- No scheduler, timer, wake service, retained dirty flag, or retry counter is
  added to MVP scope.
- No guarantee is made that identical deterministic computation will be run
  again after failure.
- This item does not authorize backend/transport payload retry; FW-010
  preserves that separate concern.

## Revisit Triggers

- A supported host or reference-application flow requires recovery from an
  aborted frame when no later external invalidation is guaranteed.
- Connected-target evidence shows that abort-and-report behavior leaves the
  display stale beyond an accepted product requirement.
- An approved observable-state or host run-cycle Specification establishes the
  invalidation and wake contracts needed to reschedule without an unbounded
  failure loop.

## Disposition

Captured. Promote through the appropriate feature lifecycle only when a
trigger occurs and an accepted product need justifies scheduler and
invalidation policy.

## References

- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [FW-010: Backend and Transport Submission Retry](fw-010-backend-transport-submission-retry.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)

