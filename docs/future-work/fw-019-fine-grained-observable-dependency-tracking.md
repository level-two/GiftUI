---
id: FW-019
feature: observable-reference-state
title: Fine-Grained Observable Dependency Tracking
status: captured
authors:
  - Yauheni Lychkouski
created: 2026-08-21
updated: 2026-08-21
source:
  - RFC-008
related_future_work:
  - FW-004
related_explorations: []
related_spikes:
  - SPIKE-003
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-019: Fine-Grained Observable Dependency Tracking

## Observation / Opportunity

RFC-008's approved MVP architecture marks one observable model owner dirty and reevaluates
the complete portable root. A future larger hierarchy or higher update rate
could benefit from recording which model properties affect which semantic
subtrees and reevaluating only the affected work.

The optimization may make sense only for runtime profiles with enough memory
and runtime metadata support, or as an optional add-on for high-load or UI-rich
systems. A future Exploration should determine whether it can remain a
transparent implementation optimization or whether an opt-in module,
capability, or public contract is actually necessary.

## Why Deferred

RFC-002 explicitly permits complete-root reevaluation for MVP, and the fixed
Signal Analyzer does not currently demonstrate that a property dependency
graph is necessary. Property identities, read scopes, dependency edges,
stale-edge cleanup, bounded graph capacity, and selective reconciliation would
add memory, binary-size, and lifetime decisions before measurements justify
them.

## Potential Value

- Reduce semantic evaluation, layout, or lowering work for large hierarchies
  whose observable models change frequently but locally.
- Allow capable runtime profiles or high-load applications to pay dependency-
  tracking costs without imposing them on small static targets.
- Provide evidence for a future retained or selectively reconciled semantic
  representation without changing backend render semantics.
- Preserve complete-root reevaluation as a simple fallback when selective
  tracking is disabled, unavailable, exhausted, or not beneficial.

## Current Non-goals

- No property token, read-tracking API, dependency graph, partial subtree
  reconciliation, or retained lifecycle is part of RFC-008 or the MVP.
- No optional module, capability, runtime-profile distinction, or public opt-in
  is selected by this capture.
- This item does not authorize Apple Observation, dynamic-only behavior, an
  unbounded graph, or implementation work.
- Whole-root invalidation remains conforming unless a later accepted artifact
  changes the architecture.

## Revisit Triggers

- SPIKE-003 or complete Signal Analyzer measurements show that whole-root
  reevaluation cannot sustain an accepted cadence, CPU, stack, RAM, or power
  requirement on a supported target.
- An accepted Proposal introduces a substantially larger or dynamic hierarchy
  with a concrete selective-update requirement.
- Measurements from a high-load or UI-rich application show that complete-root
  reevaluation dominates an accepted CPU, latency, memory-bandwidth, or power
  budget while updates affect only a small portion of the hierarchy.
- A runtime profile or optional-module design can demonstrate bounded metadata
  costs and identical published semantics with selective tracking both enabled
  and disabled.
- FW-004 is promoted and a retained producer requires an independently
  reviewable invalidation/dependency architecture.

## Disposition

Captured for post-MVP or evidence-triggered reconsideration. If a trigger
fires, promote this item to an Exploration that measures invalidation sources,
affected work, graph cardinality, reconciliation cost, and bounded static
representation. The Exploration should compare at least:

1. a transparent optimization inside capable runtime profiles;
2. an optional add-on for high-load or UI-rich systems; and
3. retaining complete-root reevaluation everywhere.

If the preferred direction changes public API, capability semantics, module
boundaries, or cross-profile guarantees, it must proceed through an accepted
Proposal and RFC rather than entering implementation directly.

## References

- [RFC-008: Observable Reference State Architecture](../rfcs/rfc-008-observable-reference-state-architecture.md)
- [PROPOSAL-005: Observable Reference State](../proposals/proposal-005-observable-reference-state.md)
- [FW-004: Retained Render Tree](fw-004-retained-render-tree.md)
- [SPIKE-003: Portable Observable Reference State Feasibility](../spikes/spike-003-portable-observable-reference-state-feasibility.md)
