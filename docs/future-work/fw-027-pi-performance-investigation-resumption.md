---
id: FW-027
feature: signal-analyzer
title: Pi Performance Investigation Resumption
status: captured
authors:
  - codex
created: 2026-09-30
updated: 2026-09-30
source:
  - SPEC-001
related_future_work:
  - FW-024
  - FW-025
  - FW-026
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-027: Pi Performance Investigation Resumption

## Observation / Opportunity

The Pi cold-frame investigation retained bounded semantic/layout lookup reuse,
sort-once publication, exact raster scan and pixel access improvements, and
framebuffer row projection reuse. Historical complete-frame measurements still
exceed the 250 ms policy; the timer-free sort-once runs averaged approximately
1.56 seconds. This is a known conformance gap, not a completed performance gate.

## Why Deferred

On 2026-09-30 the maintainer stopped performance experiments to prioritize the
remaining MVP work. Preserve measured evidence and compatible improvements;
do not continue speculative optimization during this closeout.

## Potential Value

- Resume from recorded phase measurements instead of repeating investigation.
- Compare bounded alternatives against exact pixels, failure semantics, and
  complete-frame cost once the remaining MVP work is ready for review.

## Current Non-goals

- No waiver or weakening of SPEC-001 cadence, resource, or connected-input
  requirements; their acceptance criteria and tasks remain open.
- No architecture or Specification amendment, new buffer, endpoint bypass,
  partial frames, cross-frame reuse, deployment, or hardware experiment.

## Revisit Triggers

- Remaining MVP functionality is ready for integrated conformance review and
  the Pi cadence gap blocks the completion decision.
- A maintainer explicitly reprioritizes Pi responsiveness after reviewing the
  current measured gap and resource/failure constraints.

## Disposition

Captured. Further investigation is postponed. Resume compatible internal work
under the existing approved contract; any changed contract or architecture
must first pass its normal review and human approval gates.

## References

- [Closeout and retained implementation](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-8/pi-performance-closeout-20260930.md)
- [SPEC-001 implementation plan](../implementation-plans/spec-001-implementation-plan.md)
- [FW-024 partial frames](fw-024-pi-partial-frame-presentation.md)
- [FW-025 cross-frame reuse](fw-025-pi-cross-frame-work-reuse.md)
- [FW-026 physical-surface presentation](fw-026-pi-complete-physical-surface-presentation.md)
