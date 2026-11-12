---
id: FW-039
feature: external-application-integration
title: Counter Prepared Lending Optimization
status: captured
authors:
  - codex
created: 2026-10-16
updated: 2026-10-20
source:
  - ADR-040
  - docs/implementation-designs/spec-015-p08-prepared-lending.md
  - docs/iterations/iteration-003-review/complexity-and-efficiency-checkpoint.md
related_future_work:
  - FW-038
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-039: Counter Prepared Lending Optimization

## Observation / Opportunity

The independently reviewed [prepared-lending proposal](../implementation-designs/spec-015-p08-prepared-lending.md)
would move same-owner preflight outside the lender and reference prepared facts
while preserving original loans. It is design-only; savings, source behavior and
whole-image fit were never established by implementation.

## Why Deferred

Eugene selected larger evidence-backed stacks and the counter-only physical-SRAM
budget in [ADR-040](../adrs/adr-040-counter-physical-sram-budget.md), instead of this
source candidate. The complete fit/safety proof remains required now.

## Potential Value

It could reduce cold stack materialization and restore physical margin.

## Current Non-goals

No source attempt, renewed repair budget, corpus reduction, ownership change,
implementation commitment or resource-proof waiver is authorized here.

## Revisit Triggers

Revisit if actual final linked margin is inadequate, or when the supported counter
consumer/build restructuring under [FW-038](fw-038-scoped-contract-validation-cost.md)
requires reviewing construction cost. Establish a concrete bounded source allowance
and retain the proposal's full preservation and validation requirements first.

## Disposition

Captured, not selected for current P08 execution. No source candidate was run.

The [2026-10-20 improvement sequence](../iterations/iteration-003-review/complexity-and-efficiency-checkpoint.md)
keeps this as a candidate for step 4 if its preceding feasibility decision finds
the mechanism necessary and explicitly selects it, or for later construction
cost review during FW-038 consolidation. Planning this conditional route does
not overturn the ADR-040 decision or grant a source attempt. Define the expected
complete-path benefit and regression checks before execution; the old design's
historical stack/RAM limits are not the current ADR-040 counter configuration.
No saving or analyzer fit is established by the proposal.

## References

- [Human resource acceptance](../iterations/iteration-003-review/p08-counter-resource-acceptance.md).
