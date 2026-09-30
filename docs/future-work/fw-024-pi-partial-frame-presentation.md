---
id: FW-024
feature: signal-analyzer
title: Pi Partial Frame Presentation
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

# FW-024: Pi Partial Frame Presentation

## Observation / Opportunity

Connected Pi framebuffer samples changed only 1.36–5.63% of physical pixels
between frames, while the current operation-major path submits about 220 KB
through roughly 3,900 regions on each complete frame. A future damage model
could reduce work after the first complete presentation.

## Why Deferred

The current investigation prioritizes the complete-frame cold path, which is
needed for initial rendering and remains over the 250 ms service target.
Partial presentation would require separately reviewed damage, initialization,
failure, and latest-state semantics. The sampled pixel difference alone does
not establish a correct damage region.

## Potential Value

- Reduce repeat-frame raster, payload, and framebuffer work when only a small
  part of the presented image changes.

## Current Non-goals

- No partial-damage contract, retained prior frame, selective operation
  traversal, or changed SPEC-001 cadence criterion is added now.
- This capture does not authorize using sampled pixel differences as damage.

## Revisit Triggers

- Complete-frame optimization has a measured floor on the Pi and a maintainer
  prioritizes steady-frame cadence beyond that floor.
- A proposed backend contract defines exact initial-frame, damage, recovery,
  and latest-state behavior for the selected Pi profile.

## Disposition

Captured. Promote to an Exploration when a trigger supplies concrete damage
semantics and cost questions; route contract or architecture changes through
the normal approval gates before implementation.

## References

- [SPEC-001 Signal Analyzer](../specs/spec-001-signal-analyzer-reference-application.md)
- Pi full-surface and damage investigation on
  `experiment/pi-frame-paths-20260928` at `7de0cb9b`.
- [FW-026 Complete Physical-Surface Presentation](fw-026-pi-complete-physical-surface-presentation.md)

- [FW-027 investigation resumption](fw-027-pi-performance-investigation-resumption.md) records the 2026-09-30 postponement.
