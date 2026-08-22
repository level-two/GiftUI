---
id: FW-005
feature: giftui-mvp-architecture
title: Alternative Geometry Scalar Representations
status: captured
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-22
source:
  - RFC-002
  - ADR-009
  - SPEC-002
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-005: Alternative Geometry Scalar Representations

## Observation / Opportunity

RFC-002 selects checked integer coordinates, dimensions, and scalar arithmetic
for MVP layout and Canvas geometry. Future features or measured optimization
work may benefit from fractional fixed-point or floating-point geometry for
scaling, transforms, subpixel placement, antialiasing, or device-independent
coordinates.

## Why Deferred

The Signal Analyzer uses pixel-oriented stacks, text, controls, backgrounds,
and straight-line waveform drawing. Integers are sufficient for its current
geometry and map predictably to constrained framebuffer and TFT targets.
Introducing another scalar representation now would add conversion, rounding,
overflow, determinism, code-size, and cross-profile questions without an MVP
requirement.

## Potential Value

- Improve precision for future scaling, transforms, high-density output, or
  antialiased drawing.
- Compare fixed-point and floating-point cost and determinism across dynamic
  hosts, Raspberry Pi 1, and nRF52840.
- Establish explicit conversion and rounding rules if a future API needs
  device-independent geometry.

## Current Non-goals

- No fractional, fixed-point, floating-point, subpixel, scaling, transform, or
  antialiasing contract is added to RFC-002 or the MVP.
- This capture does not select a scalar width, numeric type, rounding mode, or
  optimization strategy.

## Revisit Triggers

- An accepted Proposal requires fractional transforms, scaling, subpixel
  placement, antialiasing, or device-independent coordinates.
- Measurements show checked integer conversion or arithmetic is a material
  performance, code-size, or precision bottleneck on a supported target.
- RFC-003 text geometry or a later Canvas contract demonstrates that integer
  geometry cannot preserve its approved cross-backend semantics.
- A new supported display scale or backend cannot conform without lossy or
  backend-dependent coordinate behavior.

## Disposition

Captured. Promote to an Exploration when a trigger supplies a concrete numeric
requirement. Compare integer, fixed-point, and floating-point candidates with
a bounded Spike only when target measurements are needed.

## References

- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-003: Deterministic Text Rendering Architecture](../rfcs/rfc-003-deterministic-text-rendering-architecture.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
