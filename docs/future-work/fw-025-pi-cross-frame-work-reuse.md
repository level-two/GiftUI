---
id: FW-025
feature: signal-analyzer
title: Pi Cross-Frame Work Reuse
status: captured
authors:
  - codex
created: 2026-09-28
updated: 2026-09-30
source:
  - SPEC-001
related_future_work:
  - FW-027
  - FW-026
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-025: Pi Cross-Frame Work Reuse

## Observation / Opportunity

The Pi derives the fixed hierarchy and rebuilds its presentation on every
frame. A later design could reuse unchanged semantic, layout, drawing, or
pixel work across frames if identity, invalidation, bounds, and failure
behavior are made explicit. Existing bounded lookup indexes used within one
frame are outside this cross-frame idea.

## Why Deferred

The first complete frame must perform this work and still misses the 250 ms
service target. Cross-frame reuse adds persistent state and invalidation
complexity without improving that cold path. The current work first measures
and optimizes a complete frame.

## Potential Value

- Reduce repeated derivation or raster work in steady operation after an
  accurate first presentation.

## Current Non-goals

- No persistent render tree, cached frame, dependency graph, or selective
  reconciliation is added to the current implementation or specification.
- This capture does not change complete-root invalidation or the selected
  one-shot backend contract.

## Revisit Triggers

- The complete-frame path has a measured Pi floor and steady-frame derivation
  or raster work remains a material part of an approved cadence budget.
- A proposed retained or dependency-tracking design defines bounded memory,
  invalidation, and recovery behavior across the supported profiles.

## Disposition

Captured. Revisit alongside FW-004 and FW-019 through an Exploration if a
trigger occurs. Any changed contract or architecture needs normal approval.

## References

- [SPEC-001 Signal Analyzer](../specs/spec-001-signal-analyzer-reference-application.md)
- [Pi derivation follow-up](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-8/pi-derivation-followup-20260928.md)
- [FW-004 Retained Render Tree](fw-004-retained-render-tree.md)
- [FW-019 Fine-Grained Observable Dependency Tracking](fw-019-fine-grained-observable-dependency-tracking.md)
- [FW-026 Complete Physical-Surface Presentation](fw-026-pi-complete-physical-surface-presentation.md)

- [FW-027 investigation resumption](fw-027-pi-performance-investigation-resumption.md) records the 2026-09-30 postponement.
