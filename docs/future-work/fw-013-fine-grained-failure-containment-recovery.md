---
id: FW-013
feature: giftui-mvp-architecture
title: Fine-Grained Failure Containment and Recovery
status: captured
authors:
  - Yauheni Lychkouski
created: 2026-08-19
updated: 2026-08-19
source:
  - RFC-005
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-013: Fine-Grained Failure Containment and Recovery

## Observation / Opportunity

RFC-005's proposed MVP direction deliberately uses a conservative portable
distinction: a failure is either proven contained to its reported affected
scope or safety is not proven for that scope. Unknown and richer
profile-specific values take the conservative meaning. Straightforward
operation, cycle, frame, integration, and runtime scopes avoid making static
targets carry a detailed severity or recovery taxonomy.

Future requirements may justify finer affected scopes, recoverable
invariant-violation subclasses, before-effect rejection or deferral for more
reentrancy cases, condition-specific continuation, or another bounded recovery
mechanism. Such refinement must preserve RFC-004 publication and handoff
boundaries and must never reinterpret an unknown condition less safely.

## Why Deferred

The Signal Analyzer and four MVP validation configurations do not require
continued operation after an invariant violation that cannot already prove
containment. A finer taxonomy would require additional state, policy, fault
fixtures, static representation, and cross-profile equivalence rules without
changing required MVP behavior. Rollback, nested semantic execution, and
specialized recovery could also weaken at-most-once effects or complete
publication if introduced without concrete evidence.

## Potential Value

- Continue a component or runtime after a fault that later evidence proves is
  safely isolated more narrowly than the conservative MVP scope.
- Distinguish more recovery choices without exposing platform-specific details
  to portable policy.
- Improve availability for a future product with an explicit recovery
  requirement and a measured resource budget.

## Current Non-goals

- No finer severity, containment, or affected-scope catalogue is added to MVP.
- No invariant violation is treated as recoverable without a contract and
  fault-injection evidence proving containment before publication or handoff.
- No rollback, nested action dispatch, recursive rendering, unbounded retry,
  or profile-specific weakening of portable safety is authorized.
- This item does not change RFC-004 transaction boundaries, RFC-005 policy
  ownership, or current Signal Analyzer behavior.

## Revisit Triggers

- An accepted product or target requirement cannot meet its availability goal
  because the conservative MVP rule quiesces a component or runtime that could
  be proven safe to continue.
- Fault-injection evidence across static and dynamic profiles proves a named
  reentrancy or forbidden-phase mutation is rejected or deferred before any
  affected state, publication, action, or handoff effect.
- At least two supported components need the same finer affected scope or
  recovery distinction and can demonstrate bounded RAM, stack, code-size, and
  runtime cost on the constrained target.
- An approved Specification needs a recovery behavior that cannot be expressed
  as contained operation/cycle/frame/integration handling under RFC-005.

## Disposition

Captured outside MVP. When a trigger occurs, promote to an Exploration if the
containment proof, taxonomy, or resource cost still needs evidence, or to a
Proposal if GiftUI is ready to evaluate a broader availability investment.
Any architectural or contractual change must pass the normal RFC, ADR, and
Specification gates.

## References

- [RFC-005: Failure and Diagnostics Propagation Architecture](../rfcs/rfc-005-failure-diagnostics-propagation.md)
- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
