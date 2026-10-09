---
id: FW-035
feature: giftui-mvp-architecture
title: Generated View Graphs for Interchangeable Frontends
status: captured
authors:
  - codex
created: 2026-10-06
updated: 2026-10-06
source:
  - docs/iterations/iteration-003-dev-ux-improvement.md
  - RFC-013
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-035: Generated View Graphs for Interchangeable Frontends

## Observation / Opportunity

Eugene's 2026-10-06 iteration amendment selects complete runtime derivation of
the expanded/unwrapped view graph, following the existing Pi Dynamic path.
Generated/pre-expanded graphs might become useful again when GiftUI supports
interchangeable frontend modules and a concrete integration needs that boundary.
That possibility remains a hypothesis, not a retained generation requirement.

## Why Deferred

Current iteration 3 work removes the generated graph dependency. Interchangeable
frontends and their contracts are outside its delivery scope; no demonstrated
need justifies retaining a second graph production path now.

## Potential Value

- A generated graph might enable a future frontend integration or meet a
  measured resource constraint that runtime derivation cannot satisfy.

## Current Non-goals

- Retaining or reintroducing generated view graphs in ITERATION-003.
- Implementing interchangeable frontends, a frontend-neutral IR/ABI or a
  general-purpose graph generator.
- Removing unrelated generated font/resource/configuration artifacts.

## Revisit Triggers

- Interchangeable frontend modules have supported contracts, and a concrete
  consumer or reproducible resource/compatibility evidence shows why a generated
  graph would be needed. Frontend availability alone does not select generation.

## Disposition

Captured. Revisit through Exploration or the main lifecycle when the trigger
occurs. Any adoption requires reviewed architecture and approved contracts;
this item grants no implementation authority.

## References

- [ITERATION-003](../iterations/iteration-003-dev-ux-improvement.md), I3-04 / IT-AC-006.
- [Maintainer instruction and amendment](../iterations/iteration-003-review/runtime-derivation-scope-amendment.md).
- [RFC-013](../rfcs/rfc-013-external-application-and-backend-integration.md).
- [EXP-002 future-direction context](../explorations/exp-002-backend-and-application-integration-shapes.md#sensitivity-to-possible-future-directions--2026-10-05).
