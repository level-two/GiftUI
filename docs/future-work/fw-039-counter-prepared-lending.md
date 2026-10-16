---
id: FW-039
feature: external-application-integration
title: Counter Prepared Lending Optimization
status: captured
authors:
  - codex
created: 2026-10-16
updated: 2026-10-16
source:
  - ADR-040
  - docs/implementation-designs/spec-015-p08-prepared-lending.md
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

## References

- [Human resource acceptance](../iterations/iteration-003-review/p08-counter-resource-acceptance.md).
