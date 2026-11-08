---
id: FW-044
feature: giftui-mvp-architecture
title: Resource Accountability and Closed-Loop Development
status: captured
authors:
  - codex
created: 2026-11-08
updated: 2026-11-08
source:
  - docs/VISION.md
related_future_work:
  - FW-045
  - FW-007
  - FW-022
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-044: Resource Accountability and Closed-Loop Development

## Observation / Opportunity

A developer investigating a RAM or frame-time regression needs to compare
predicted cost, the built target image, and workload measurements. A report
that connects those evidence sources could explain the delta and identify the
responsible screen, component, or shared resource.

The immediate question is whether a useful comparison can be produced for one
application, target, and repeatable workload. Candidate outputs include a
before/after resource report, attribution of the change, and the discrepancy
between a prediction and a hardware observation. This capture originated in
the maintainer's 2026-11-08 direction map.

## Why Deferred

No integrated reporting format or calibration method has been selected. Useful
attribution, comparable measurements, and instrumentation overhead need
assessment against a concrete case. Existing resource checks and current
resource failures remain governed by their own contracts; this opportunity
does not postpone their resolution.

## Questions to Revisit

- Which costs can be linked to a screen or component, and which must remain
  shared or unattributed? How can overlapping lifetimes avoid double counting?
- Can source, compiler, target configuration, and workload identity make build
  reports and runtime observations comparable? Which results are exact values,
  bounds, estimates, or observed peaks?
- Can paired predictions and measurements reveal a useful calibration error
  range without hiding instrumentation effects or unknown costs?
- Would the resulting comparison support a useful CI budget/delta check or a
  machine-readable diagnostic for a human or agent? What evidence would make
  an optimization recommendation credible?

## Potential Value

- Shorter diagnosis of resource regressions through attributable comparisons.
- Better estimates from matched hardware observations.
- Reusable evidence for manual or automated comparison of alternatives.

## Relationship to Other Captures

[FW-007](fw-007-cost-aware-capability-planning.md) preserves configuration-cost
estimation details and the separate question of selecting among conforming
realizations. This item concerns comparing and attributing evidence; it does
not require an automatic planner. [FW-022](fw-022-contract-accurate-embedded-target-simulator.md)
concerns simulator execution and fidelity. A first reporting assessment could
use existing build and hardware evidence without waiting for that simulator.

[FW-045](fw-045-frontend-neutral-migration-platform.md) could use such evidence
for a selected migration case without depending on a general reporting product.

Optimization advice, constraint solving, and an agent-driven feedback loop
remain possible consumers of this evidence, not deliverables bundled into a
first assessment.

## Current Non-goals

- New budgets, instrumentation requirements, CI gates, or acceptance criteria
  for current iterations.
- A universal cost model, telemetry protocol, optimizer, or autonomous deployment.
- Substituting estimates or observed peaks for required bounds or hardware proof.

## Revisit Triggers

- A reproducible resource regression cannot be attributed using existing reports.
- A named application and target have matched predictions and repeatable
  measurements suitable for assessing calibration error.
- A concrete application needs screen/component attribution or resource-delta
  checks that existing tooling cannot provide.

## Disposition

Captured; no milestone assignment or implementation authorization. A trigger
invites evaluation, not automatic promotion. An Exploration could establish
feasibility for one named workload; a Proposal could seek investment when the
problem and value are concrete.

## References

- [GiftUI Vision](../VISION.md): long-term context for the original direction map.
- [Future Work index](README.md#vision-related-opportunities): capture navigation.
