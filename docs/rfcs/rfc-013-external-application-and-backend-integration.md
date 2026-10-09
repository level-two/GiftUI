---
id: RFC-013
feature: external-application-integration
title: External Application and Backend Integration
status: draft
authors:
  - codex
created: 2026-10-05
updated: 2026-10-09
proposal:
  - PROPOSAL-007
related_rfcs:
  - RFC-002
  - RFC-008
  - RFC-009
  - RFC-011
related_adrs:
  - ADR-006
  - ADR-007
  - ADR-008
  - ADR-010
  - ADR-025
  - ADR-026
  - ADR-033
related_specs:
  - SPEC-002
  - SPEC-009
  - SPEC-010
  - SPEC-011
  - SPEC-012
  - SPEC-013
  - SPEC-014
  - SPEC-015
related_future_work:
  - FW-016
  - FW-030
  - FW-035
related_explorations:
  - EXP-002
related_spikes:
  - SPIKE-014
supersedes: []
superseded_by: []
target_milestone: ITERATION-004
---

# RFC-013: External Application and Backend Integration

**Draft; design reconsideration required.** This compact record retains the RFC
identity, investment authority and unresolved decision boundary. The original
candidate designs, alternatives and experimental reasoning remain in the
[preparation archive](../iterations/iteration-003-review/preparation-archive.md).
No candidate is accepted by this reconstruction. This is not ready for RFC
approval or implementation planning.

## Problem and authority

[Accepted PROPOSAL-007](../proposals/proposal-007-external-application-integration.md)
defines external application and adapter consumption, focused packages, simpler
setup and compatibility outcomes. Existing accepted ADRs and implemented owner
Specifications remain authoritative. Iteration commitments do not approve
architecture or implementation.

Runtime derivation and measured memory/performance work belong to
[ITERATION-003](../iterations/iteration-003-dev-ux-improvement.md). External
package/backend/host delivery belongs to
[ITERATION-004](../iterations/iteration-004-backend-and-application-integration.md).
Runtime and external API decisions may be reviewed separately where independently
coherent. PROPOSAL-007 does not grant blanket authority for performance redesign.

## Constraints to preserve

- Portable presentation imports GiftUI alone; platform and display selection
  belongs at composition boundaries.
- Both Signal Analyzer and the finite counter retain identity, state/actions,
  layout/pixels, publication, failure and teardown semantics across profiles.
- Static remains bounded and zero-heap; real target stack, backing, ABI and
  resource evidence is required. Native execution cannot establish target safety.
- Runtime graph derivation remains the approved delivery requirement. Generated
  pre-expanded topology under a different name is not an equivalent result.
- Reuse established semantic, layout, raster, endpoint and platform owners unless
  a separately reviewed change is necessary. No new module or public API is
  selected by this document.

## Evidence and alternatives

[The findings summary](../iterations/iteration-003-review/preparation-findings.md)
identifies reusable positive results, failed approaches and precise limitations.
It replaces the active chain of per-attempt reconciliation documents.

The archived design compared runtime traversal into packed records and
caller-owned typed records, explicit backing and different construction/service
lifetimes, as well as package/access and host-boundary alternatives. Preserve
those tradeoffs as evidence. Do not assume a previous candidate must be completed
because substantial experimental code already exists.

## Required decisions before review

1. A feasible complete runtime/storage/lifetime realization and explicit resource
   bounds, including unresolved callback, escape and alias behavior.
2. The smallest compatible ownership/contract changes justified by that result;
   identify affected ADRs and Specs without treating a draft as authority.
3. After iteration-3 constraints stabilize, a minimal transitive public surface,
   package partition, supported construction/activation path and build inputs.
4. Compatibility and migration behavior, error/provenance visibility, equivalent
   external setup measurements and the final configuration/evidence matrix.

Rebuild a reviewable design recommendation only around the next decision and
its measured alternatives. The [current plan](../iterations/iteration-003-review/memory-efficiency-plan.md)
sets the order. Human RFC approval, accepted ADRs, approved Spec amendments and
ready implementation plans remain prerequisites for major production adoption.

## Deferred work

[FW-016](../future-work/fw-016-post-mvp-package-distribution-topology.md) and
[FW-030](../future-work/fw-030-application-integration-experience.md) feed the
accepted investment. [EXP-002](../explorations/exp-002-backend-and-application-integration-shapes.md)
and [SPIKE-014](../spikes/spike-014-external-consumer-access-baseline.md) preserve
the original preparation baseline. [FW-035](../future-work/fw-035-generated-view-graph-for-interchangeable-frontends.md)
retains a future generated-frontend trigger. Full current memory/lifetime safety
cannot be deferred as an optional optimization.
