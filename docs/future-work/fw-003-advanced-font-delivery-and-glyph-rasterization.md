---
id: FW-003
feature: giftui-mvp-architecture
title: Advanced Font Delivery and Glyph Rasterization
status: captured
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-15
source:
  - RFC-003
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-003: Advanced Font Delivery and Glyph Rasterization

## Observation / Opportunity

RFC-003's exact-identity raster-provider boundary could later admit runtime
font registration, deterministic strike resampling, signed-distance-field or
vector glyphs, compressed atlases, smarter corpus extraction, and incremental
shared glyph caches.

## Why Deferred

The MVP can validate the boundary with packaged outlines on a capable target
and exact precompiled bitmap strikes on embedded. The additional delivery,
transform, compression, and caching mechanisms are not required by the Signal
Analyzer and would add unmeasured code, memory, and toolchain cost.

## Potential Value

- Support applications that cannot know every font, size, scale, or transform
  at build time.
- Reduce package size or repeated raster work when measurements demonstrate a
  concrete bottleneck.

## Current Non-goals

- No runtime font discovery, arbitrary strike scaling, distance fields,
  vector-glyph render operation, shared atlas, or speculative compression
  system is added to RFC-003 or the MVP roadmap.
- This item does not authorize a particular font library or cache policy.

## Revisit Triggers

- An accepted Proposal requires runtime font registration or a transform/scale
  not representable by exact MVP strikes.
- Measured package flash, raster time, or repeated glyph work exceeds an
  approved target budget and a bounded advanced mechanism could address it.
- A new backend cannot conform to RFC-003's raster contract without one of
  these representations.

## Disposition

Captured. Promote to an Exploration when competing delivery or raster designs
need evidence; use a bounded Spike only after target questions are named.

## References

- [RFC-003: Deterministic Text Rendering Architecture](../rfcs/rfc-003-deterministic-text-rendering-architecture.md)
