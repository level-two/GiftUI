---
id: FW-037
feature: giftui-mvp-architecture
title: Core-wide Storage Ownership Generalization
status: captured
authors:
  - codex
created: 2026-10-13
updated: 2026-10-13
source:
  - RFC-015
related_future_work:
  - FW-022
  - FW-035
related_explorations:
  - EXP-002
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: ITERATION-004
---

# FW-037: Core-wide Storage Ownership Generalization

## Observation / Opportunity

P08 exposed a distinction between physical backing ownership, state-machine
ownership and scoped access. [Draft RFC-015](../rfcs/rfc-015-p08-scoped-storage-ownership.md)
proposes a focused geometry/Interaction contract. A future frontend-, backend-
and platform-independent GiftUI Core might benefit from a consistent version of
this distinction across owner boundaries, using Swift to exclude unsupported
safe-client escapes and aliases while preserving explicit trusted implementation
and runtime checks. That benefit and a common representation remain hypotheses.

## Why Deferred

P08 needs a coherent finite carrier and physical slot design, not a universal
Core redesign. Its draft has unresolved approval blockers and no new compiler or
resource proof. FW-022 already owns simulator investment/fidelity; FW-035 owns
generated graphs for interchangeable frontends; EXP-002 compares integration
shapes. None captures the separate question of whether storage/access ownership
should generalize across them. This item adds only that narrow observation.

## Potential Value

- Reduce accidental ownership coupling when a second frontend, backend or
  simulated platform composes production owners with different backing lifetimes.
- Reuse explicit ownership and lifetime evidence without making one target's
  pointer layout, region allocator or Swift adapter the universal Core contract.

## Current Non-goals

- No new P08 requirement, associated-type scheme, universal owner protocol,
  frontend IR/ABI, allocator, simulator implementation or language-independent Core.
- No deferral of RFC-015's complete lifetime propagation, safe-client boundary,
  disjoint initialization, swap/destruction or exact existing-consumer obligations.
- The scheduled assessment does not approve architecture, implementation or
  experiments, compiler changes or reopened repair allowances.

## Revisit Triggers

- Start of ITERATION-004 I4-06, alongside package/access and host integration
  review; inventory gaps even if the P08 evidence below is not yet complete.

- An adopted P08 ownership contract has complete compiler and physical-lifecycle
  evidence, and a concrete second frontend/backend/platform consumer demonstrates
  different backing/access needs or repeated incompatible adapter code.
- A separately prioritized FW-022 simulator or RFC-013 external integration
  encounters a reproducible ownership boundary that cannot compose the existing
  production owners without duplicating state or erasing lifetime guarantees.

## Disposition

Captured and scheduled as an assessment in
[ITERATION-004](../iterations/iteration-004-backend-and-application-integration.md)
revision 3, I4-06 / I4-AC-007. On 2026-10-13, Eugene explicitly requested:
“Add the produced future work item to the next iteration scope.” In context,
the produced item is FW-037. This authorizes the assessment scope addition,
not a Core-wide architecture or simulator implementation.

Evaluate concrete ownership boundaries through Exploration (reuse EXP-002 when
its scope fits), including a second consumer and PC simulator composition.
Record evidence gaps and recommend generalization, retaining local contracts,
or deferral. Then use normal Proposal/RFC/ADR/Spec gates for any adoption.
RFC-015's current blockers remain in P08. Status stays captured: scheduling the
assessment does not itself promote this item to an Exploration or Proposal.

## References

- [RFC-015](../rfcs/rfc-015-p08-scoped-storage-ownership.md), source and current blockers.
- [FW-022](fw-022-contract-accurate-embedded-target-simulator.md), simulator ownership and fidelity.
- [FW-035](fw-035-generated-view-graph-for-interchangeable-frontends.md), frontend graph opportunity.
- [EXP-002](../explorations/exp-002-backend-and-application-integration-shapes.md), integration alternatives.
