---
id: FW-007
feature: capability-system
title: Cost-Aware Capability Realization Planning
status: captured
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-15
source:
  - RFC-006
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-007: Cost-Aware Capability Realization Planning

## Observation / Opportunity

A future GiftUI feature may have several conforming realizations with
materially different RAM, CPU, transfer-bandwidth, latency, energy, or flash
costs. A planner could compare declared costs and target budgets when choosing
between hardware acceleration, framebuffer operations, partial redraw, full
redraw, or another conforming implementation.

## Why Deferred

The MVP capability set is small and can use explicit composition policy with
deterministic preference among the few realizations actually present. A
general cost algebra or optimizer would be speculative until an accepted
feature supplies competing measured implementations and a choice that fixed
policy cannot express adequately.

## Potential Value

- Select a conforming implementation that fits target-specific resource and
  responsiveness budgets.
- Make hardware acceleration an explicit optimization rather than a semantic
  prerequisite.
- Explain why one realization was selected when several are available.

## Current Non-goals

- No universal cost units, optimization function, benchmark framework, or
  capability-aware render planner is required by RFC-006.
- Hardware scrolling, alpha compositing, shadows, and other non-MVP rendering
  features are not added to the current milestone.

## Revisit Triggers

- An accepted feature has at least two conforming realizations whose measured
  trade-offs cannot be handled by a simple explicit target policy.
- A hardware-acceleration feature such as scrolling is proposed and must
  choose among hardware, buffered software, partial-redraw, and full-redraw
  paths under real target budgets.
- Repeated target-specific preference rules demonstrate a shared planning
  problem rather than intentional product policy.

## Disposition

Captured. Promotion requires measured evidence and the normal Exploration or
Proposal gate; it does not expand the MVP capability system.

## References

- [RFC-006: GiftUI Capability System Architecture](../rfcs/rfc-006-capability-system-architecture.md)

