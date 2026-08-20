---
id: FW-016
feature: giftui-mvp-architecture
title: Post-MVP Package and Distribution Topology
status: captured
authors:
  - Yauheni Lychkouski
created: 2026-08-19
updated: 2026-08-20
source:
  - RFC-002
  - ADR-008
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-016: Post-MVP Package and Distribution Topology

## Observation / Opportunity

RFC-002 selects one Swift package containing multiple targets and products for
MVP distribution. The target/module graph preserves architectural ownership
and prohibited-import boundaries without requiring a separate package manifest
or release boundary for each logical layer.

After MVP, independently consumed components, platform-specific toolchains,
versioning needs, dependency constraints, or measured build and release costs
may justify splitting GiftUI into several Swift packages or adopting another
distribution topology. That decision should follow evidence rather than map
packages mechanically to logical layers.

## Why Deferred

The four MVP configurations can be developed and distributed from one package
while using multiple targets to enforce the required import graph. No accepted
MVP requirement currently needs independent package versioning, separately
resolved dependencies, or distinct release artifacts. Introducing those
boundaries now would add manifest, dependency-resolution, integration,
release, and cross-package testing work without improving the Signal Analyzer
or target-stack validation.

## Potential Value

- Permit a component to be consumed, versioned, or released independently when
  a maintained user requires that boundary.
- Isolate platform or toolchain requirements that cannot coexist cleanly in
  one package manifest and target graph.
- Improve build, dependency-resolution, or release behavior when measurements
  show that the one-package topology has become a material cost.

## Current Non-goals

- No additional Swift package, manifest, repository, versioning scheme, or
  release pipeline is added to the MVP.
- The one-package, multiple-target MVP decision in RFC-002 is unchanged.
- This item does not map one package to every logical layer or select any
  future package, product, target, or module names.

## Revisit Triggers

- A maintained external consumer needs one GiftUI component to be depended on,
  versioned, or released independently from the rest of GiftUI.
- A supported platform or toolchain requires manifest settings or dependencies
  that cannot coexist safely in the single package.
- The approved target/module graph cannot enforce a required ownership boundary
  without introducing a dependency cycle or exposing an implementation target
  that should not be distributed together.
- Measured clean-build time, incremental-build behavior, dependency resolution,
  package metadata, binary linkage, or release coordination exceeds an approved
  project budget and package decomposition is a credible remedy.

## Disposition

Captured for post-MVP consideration. Promote to an Exploration when a trigger
provides concrete distribution constraints or measurements and competing
topologies need comparison. Any architecture change must then pass the normal
RFC and ADR gates before package restructuring is treated as authoritative.

## References

- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [`Package.swift`](../../Package.swift) — current one-package, multiple-target
  implementation evidence only
