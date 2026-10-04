---
id: FW-030
feature: giftui-mvp-architecture
title: Application Integration Experience
status: captured
authors:
  - codex
created: 2026-10-02
updated: 2026-10-04
source:
  - SPEC-015
related_future_work:
  - FW-016
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-030: Application Integration Experience

## Observation / Opportunity

The maintainer asked whether integrating GiftUI with a concrete backend is too
hand-wired and entangled, and requested a path toward selecting a target and
building with minimal application setup. The current nRF52840 reference host
uses shared framework owners, but its CMake source selection, packed-storage
wiring, C/Swift bridge, and UI projection tooling remain specific to the
Signal Analyzer. `StaticPreset.swift` also combines production composition
with validation probes. SPEC-015 deliberately supplies package SPI rather
than an external application integration API.

An integration study could inventory the work a second application must
repeat and distinguish application declarations, reusable host assembly,
backend/display support, and board configuration. Candidate improvements
include a narrow supported-target entry point, reusable Zephyr build support,
consistent configuration projections, and application-independent static
lowering tooling. These are possibilities, not selected architecture.

The maintainer's 2026-10-02 repository/package review additionally asks that
the application own user-facing behavior and final wiring while selecting
independently consumable framework/runtime, renderer, and platform/display
components. FW-016 records the distribution constraints found during that
review. Moving folders alone cannot provide this experience while host
contracts remain package-scoped and application workloads/presets remain in
framework modules. A consumption study should distinguish the narrow external
assembly contracts from owner internals and preserve Static resource and
ownership guarantees across any candidate package boundary.

## Why Deferred

The MVP currently validates one reference application on four stacks; its
production joins remain in implementation. A general external integration
contract and tooling workflow require evidence from a separate consumer and
must preserve accepted ownership, static resource bounds, and lifecycle rules.
The observed friction does not itself establish a current correctness blocker.

## Potential Value

- Reduce the framework internals an application author must understand.
- Avoid copying source lists, storage offsets, and lifecycle/policy glue.
- Detect configuration drift before firmware activation.
- Make supported-target builds reproducible from a small consumer project.

## Current Non-goals

- No public host API, package split, configuration format, generator, or
  module-boundary change is selected or implemented.
- No MVP requirement, approval status, or implementation task is changed.
- No automatic board discovery, connected-board flashing, or replacement of
  runtime compatibility validation is introduced.
- FW-006, FW-016, and FW-029 retain their existing scopes and dispositions.

## Revisit Triggers

- A maintainer prioritizes application integration after the current
  production joins, or an external application starts consuming GiftUI.
- A second small application requires edits to framework internals, copies
  Signal Analyzer composition, or manually maintains semantic ordinals and
  storage offsets.
- A maintained target build duplicates source selection or configuration
  values and exposes reproducibility or drift failures.

## Disposition

Captured. The smallest useful next step is a bounded Exploration of a second
consumer, recording setup steps, touched files, application glue, and build
diagnostics. Public integration and architectural changes require their normal
Proposal, RFC, ADR, and Specification gates before implementation.

## Draft Iteration Context

The maintainer included this concern in the working scope for
[ITERATION-003: Dev UX Improvement](../iterations/iteration-003-dev-ux-improvement.md) on 2026-10-04.
The scope remains open for codebase review; this link does not promote the item,
change its disposition, or establish a delivery commitment.

## References

- [SPEC-015](../specs/spec-015-host-configuration.md)
- [Package manifest](../../Package.swift)
- [Firmware build composition](../../firmware/nrf52840/applications/signal-analyzer-static/CMakeLists.txt)
- [Firmware preset and probes](../../firmware/nrf52840/applications/signal-analyzer-static/src/StaticPreset.swift)
- [Static topology generation](../../scripts/contracts/generate-spec-001-nrf-topology.py)
- [ADR-007](../adrs/adr-007-integration-ownership-and-host-composition.md)
- [ADR-008](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
- [FW-006](fw-006-generated-target-configuration.md)
- [FW-016](fw-016-post-mvp-package-distribution-topology.md)
- [FW-029](fw-029-reduce-source-conditional-compilation.md)
