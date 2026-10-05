---
id: FW-016
feature: giftui-mvp-architecture
title: Post-MVP Package and Distribution Topology
status: promoted
authors:
  - Yauheni Lychkouski
created: 2026-08-19
updated: 2026-10-05
source:
  - RFC-002
  - ADR-008
  - SPEC-002
related_future_work:
  - FW-030
related_explorations:
  - EXP-002
related_spikes:
  - SPIKE-014
promoted_to:
  - PROPOSAL-007
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

On 2026-10-02, the maintainer requested a repository/package boundary review
so applications can compose portable GiftUI, a selected runtime profile,
rendering, and platform/display support as independently usable building
blocks. Inspection found more than co-location: most runtime/render/backend
targets have no library product; their integration contracts use `package`
access; `GiftUIHostConfiguration` contains Signal Analyzer workload types and
generated presets; generic SPI display support is under
`SignalAnalyzerTargetHost`; and firmware CMake selects framework and application
sources through a shared repository root. Host-configuration tests also mix
generic owner checks with application and target-stack integration checks.
These are consumption and extraction constraints, not evidence that every
module needs its own repository or that current runtime behavior is incorrect.

The requested review makes independent application consumption an explicit
goal to evaluate. Candidate boundaries include the portable framework,
software raster implementation, Linux adapters, Zephyr adapters, and the
reference application. Static and Dynamic could remain separate products of
one framework package. These candidates are not selected architecture;
cross-package contracts, reusable build inputs, and separation of application
workload configuration must be evaluated before moving sources.

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

Initially captured for post-MVP consideration. Promote to an Exploration when a trigger
provides concrete distribution constraints or measurements and competing
topologies need comparison. Any architecture change must then pass the normal
RFC and ADR gates before package restructuring is treated as authoritative.

The 2026-10-02 request supplies a concrete composition goal for re-evaluation,
but no external-consumer build or cost measurement has yet been performed.
The recommended next step is a bounded extraction/consumption Exploration
with FW-030: verify a separate small application can select components without
copying reference-application owners, using repository-relative source lists,
or granting access to all framework internals. ADR-008 still governs MVP
distribution; this capture does not authorize a split or change its milestone.

## Iteration Context

[EXP-002](../explorations/exp-002-backend-and-application-integration-shapes.md)
now compares typed assembly, supported presets and generated composition,
including packaging/access constraints. At that point this item remained captured;
no package extraction or consumer build has been performed.

The maintainer included this concern in the working scope for
[ITERATION-003: Dev UX Improvement](../iterations/iteration-003-dev-ux-improvement.md) on 2026-10-04.
At that point the scope remained open for codebase review; the initial link did
not promote the item, change its disposition or establish a delivery commitment.

On 2026-10-05 Eugene explicitly requested scope review, alignment, gap filling,
approval and commit. [ITERATION-003 revision 2](../iterations/iteration-003-dev-ux-improvement.md)
now selects focused-package consumption through the shared external consumer,
with separate topology/access/contract gates. [Review and approval](../iterations/iteration-003-review/scope-review-and-approval.md)
records that prioritization. That scope approval selected no package design.

The subsequent instruction “Please then proceed.” authorizes preparation of
the refreshed baseline, consumer study and coordinated investment Proposal.
This item is now promoted to draft
[PROPOSAL-007](../proposals/proposal-007-external-application-integration.md),
which takes ownership of the selected distribution problem; acceptance remains
pending. [SPIKE-014](../spikes/spike-014-external-consumer-access-baseline.md)
supplies bounded declaration/access evidence. No package split or compatibility
contract is approved by promotion.

## References

- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [`Package.swift`](../../Package.swift) — current one-package, multiple-target
  implementation evidence only
- [FW-030: Application Integration Experience](fw-030-application-integration-experience.md)
- [Host configuration values](../../Sources/GiftUIHostConfiguration/HostConfigurationValues.swift)
- [Firmware build composition](../../firmware/nrf52840/applications/signal-analyzer-static/CMakeLists.txt)
