---
id: FW-010
feature: giftui-mvp-architecture
title: Backend and Transport Post-Handoff Recovery
status: captured
authors:
  - Yauheni Lychkouski
created: 2026-08-17
updated: 2026-08-18
source:
  - RFC-002
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

# FW-010: Backend and Transport Post-Handoff Recovery

## Observation / Opportunity

A backend or delegated transport service could retry, repair, reset, or
resynchronize downstream presentation after a recoverable failure that occurs
after RFC-004's accepted handoff. The logical frame is already committed at
that point, so this recovery remains backend-local and cannot reopen the frame
transaction, roll back semantic state, or replay client actions.

Any such policy belongs at the backend/transport boundary that can classify
the failure, coordinate presentation-coupled input, and own stable bounded data
for the recovery lifetime. Future design must determine whether recovery uses
only backend-derived presentation data or whether a separately justified
replayable normalized-operation representation is needed. GiftUI Core should
not provide generic retry loops, timers, allocation, or exception machinery.

## Why Deferred

RFC-004 commits the logical frame at complete accepted handoff and assigns
later device, transport, compositor, and physical-display health to the target
integration. The Signal Analyzer and current stack-validation requirements do
not establish a transient post-handoff failure class, recovery budget, delay
policy, resynchronization contract, or payload-retention budget shared by the
first-party backends.

## Potential Value

- Recover from measured downstream display or transport failures without
  repeating semantic work or changing logical-frame disposition.
- Let a backend use device-specific knowledge to choose a bounded recovery and
  presentation/input-coherence policy.

## Current Non-goals

- No post-handoff outcome reopens or changes a committed frame transaction.
- No automatic semantic reevaluation is added.
- No generic GiftUI Core retry service, timer, queue, exception, or allocation
  requirement is added.
- Every MVP backend remains a one-shot synchronous operation consumer; no MVP
  backend retains or replays GiftUI operations for retry.
- No replayable operation representation or retry payload is added to the MVP
  frame contract.
- This item does not authorize rescheduling after a pre-handoff frame abort;
  FW-011 preserves that separate concern.

## Revisit Triggers

- A supported MVP or post-MVP backend records recoverable post-handoff device
  or transport failures for which bounded abandonment, reset, or full redraw
  does not meet an accepted product requirement.
- A backend Specification needs a bounded recovery contract to satisfy a
  measured availability or presentation/input-coherence target.
- A supported backend demonstrates that retry must begin from normalized
  GiftUI operations rather than from backend-derived presentation data.
- At least two backend or transport implementations need materially shared
  retry semantics, prompting evaluation of a delegated Service contract.

## Disposition

Captured with post-handoff scope. Revisit through the applicable backend
lifecycle when a trigger occurs. Any shared delegated Service still requires
normal Proposal/RFC/ADR gates and does not become authoritative through this
item.

## References

- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [FW-011: Pre-Handoff Aborted-Frame Rescheduling](fw-011-failed-frame-rescheduling.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
