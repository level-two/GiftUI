---
id: FW-010
feature: giftui-mvp-architecture
title: Backend and Transport Submission Retry
status: captured
authors:
  - Yauheni Lychkouski
created: 2026-08-17
updated: 2026-08-17
source:
  - RFC-004
related_future_work:
  - FW-011
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-010: Backend and Transport Submission Retry

## Observation / Opportunity

A backend or delegated transport service could retry submission of an
already-produced frame payload after a recoverable transient failure such as
temporary transport backpressure or resource contention. This is distinct
from re-running semantic evaluation, layout, or render-operation generation.

Any such policy belongs at the backend/transport boundary that can classify
the failure and owns stable payload storage for the retry lifetime. GiftUI
Core should not provide generic retry loops, timers, allocation, or exception
machinery.

## Why Deferred

RFC-004's required frame-abort behavior is sufficient for deterministic MVP
failure handling: a pre-commit failure preserves the previous committed
logical frame and is reported once. The Signal Analyzer and current stack-
validation requirements do not establish a transient failure class, retry
budget, delay policy, or payload-retention budget shared by the first-party
backends.

## Potential Value

- Recover from measured transient display or transport failures without
  repeating semantic work.
- Let a backend use device-specific knowledge to choose a bounded retry policy.

## Current Non-goals

- No automatic frame-transaction retry or semantic reevaluation is added.
- No generic GiftUI Core retry service, timer, queue, exception, or allocation
  requirement is added.
- No MVP backend is required to retain payloads for retry.
- This item does not authorize failed-frame rescheduling; FW-011 preserves that
  separate concern.

## Revisit Triggers

- A supported MVP or post-MVP backend records recoverable transient submission
  failures for which abort-and-report behavior does not meet an accepted
  product requirement.
- A backend Specification needs a bounded retry contract to satisfy a measured
  transport availability or presentation-success target.
- At least two backend or transport implementations need materially shared
  retry semantics, prompting evaluation of a delegated Service contract.

## Disposition

Captured. Revisit through the applicable backend lifecycle when a trigger
occurs. Any shared delegated Service still requires normal Proposal/RFC/ADR
gates and does not become authoritative through this item.

## References

- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [FW-011: Failed-Frame Rescheduling](fw-011-failed-frame-rescheduling.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)

