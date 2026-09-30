---
id: FW-026
feature: signal-analyzer
title: Pi Complete Physical-Surface Presentation
status: captured
authors:
  - codex
created: 2026-09-28
updated: 2026-09-30
source:
  - SPEC-001
related_future_work:
  - FW-027
  - FW-024
  - FW-025
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-026: Pi Complete Physical-Surface Presentation

## Observation / Opportunity

An isolated Pi 1 prototype painted a complete 480 × 320 RGB565 physical image
in drawing-operation order and copied it to the framebuffer. Its initial
framebuffer hash matched the selected tiled path. Two 60-second runs averaged
528–538 ms application frame service, versus 1,534 ms for a same-binary tiled
control. This improves the complete-frame path but still misses 250 ms.

## Why Deferred

The prototype adds a 307,200-byte offscreen framebuffer and bypasses the
selected endpoint's reserve, transfer, and failure behavior. The extra full
buffer conflicts with the selected SPEC-014 BI-006 resource bound. Evidence
from an experimental branch cannot authorize that contract change. The
maintainer asked to leave Specifications unchanged for now.

## Potential Value

- A reviewed complete-surface path might remove repeated tile payload and
  mapped-region work from both initial and steady complete frames.
- The matching pixel hash and measured application service give a concrete
  starting point for comparing resource and failure-semantics alternatives.

## Current Non-goals

- No change to SPEC-014, the selected Pi realization, or its resource bound.
- No production adoption of the prototype or its endpoint bypass.
- No partial-frame damage or cross-frame content reuse; those remain in
  [FW-024](fw-024-pi-partial-frame-presentation.md) and
  [FW-025](fw-025-pi-cross-frame-work-reuse.md).

## Revisit Triggers

- A maintainer decides to review the Pi presentation resource and failure
  contract after the complete-frame path remains above the 250 ms target.
- A bounded alternative demonstrates comparable exact pixels and cold-frame
  cost without an extra full framebuffer or endpoint bypass.

## Disposition

Captured. If revisited, first compare resource, operation order, atomicity,
and failure semantics in an Exploration or RFC. Any changed accepted
architecture and Specification require their normal human approval gates.

## References

- [Physical-surface experiment](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-8/pi-physical-surface-experiment-20260928.md)
- Prototype commits `e807e330` and `6324fef2` on
  `feature/pi-cold-full-surface-experiment`.
- [SPEC-014 selected backend contract](../specs/spec-014-backend-integration.md).

- [FW-027 investigation resumption](fw-027-pi-performance-investigation-resumption.md) records the 2026-09-30 postponement.
