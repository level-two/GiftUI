---
id: FW-030
feature: giftui-mvp-architecture
title: Application Integration Experience
status: promoted
authors:
  - codex
created: 2026-10-02
updated: 2026-10-05
source:
  - SPEC-015
related_future_work:
  - FW-016
related_explorations:
  - EXP-002
related_spikes: []
promoted_to:
  - EXP-002
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

The MVP validated one reference application on four stacks and closed with
recorded exceptions. A general external integration
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

Promoted to [EXP-002](../explorations/exp-002-backend-and-application-integration-shapes.md)
on 2026-10-04 after the maintainer explicitly requested candidate solutions
and constraints for Iteration 3 preparation without production code changes.
The Exploration compares integration shapes and proposes a bounded second
consumer study; no consumer code or Spike has been implemented. Public
integration and architectural changes still require their normal Proposal,
RFC, ADR, and Specification gates before implementation.

## Iteration Context

The maintainer included this concern in the working scope for
[ITERATION-003: Dev UX Improvement](../iterations/iteration-003-dev-ux-improvement.md) on 2026-10-04.
At that point the scope remained open for codebase review and did not establish
a delivery commitment. The subsequent explicit request to explore solutions is recorded
in the promotion disposition above.

On 2026-10-05 the maintainer requested alignment with the core backend item.
EXP-002's [coordinated study](../explorations/exp-002-backend-and-application-integration-shapes.md#coordinated-backend-foundation-and-integration-rework--2026-10-05)
now evaluates application assembly and backend extension through the same
small consumer, access inventory and setup/resource baseline. Its
[backend inventory](../explorations/exp-002/backend-foundation-inventory-2026-10-05.md)
provides the reuse/extraction evidence. Backend reservation/raster/display
mechanics remain below the host lifecycle/input/scheduling joins. This updates
the existing Exploration context; FW-030 remained promoted to EXP-002 and that
alignment request alone supplied no implementation or scope approval.

The subsequent 2026-10-05 request explicitly authorizes review, alignment, gap
filling, approval and commit. [ITERATION-003 revision 2](../iterations/iteration-003-dev-ux-improvement.md)
now selects the coordinated consumption/foundation/integration commitment with
one bounded consumer and four-profile matrix. [Review and approval](../iterations/iteration-003-review/scope-review-and-approval.md)
records this later instruction. FW-030 remains promoted to active EXP-002;
Proposal acceptance, architecture and external integration contracts remain
separate gates. No consumer experiment or production implementation is claimed.

## References

- [EXP-002 backend foundation inventory](../explorations/exp-002/backend-foundation-inventory-2026-10-05.md) — coordinated backend extension and application integration study
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
