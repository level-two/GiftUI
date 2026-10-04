---
id: FW-029
feature: giftui-mvp-architecture
title: Reduce Source Conditional Compilation
status: captured
authors:
  - codex
created: 2026-10-02
updated: 2026-10-04
source:
  - SPEC-013
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-029: Reduce Source Conditional Compilation

## Observation / Opportunity

The maintainer requested an assessment of avoiding most `#if`/`#ifdef`
directives. A 2026-10-02 working-tree inventory found 58 opening `#if`
directives in 35 files under `Sources/`. The portable Signal Analyzer
presentation, semantic core, layout, render lowering, and runtime targets had
none. Most directives select host/platform implementations or profile-specific
storage, algorithms, resources, and instrumentation.

Whole-file nRF and Linux guards are candidates for explicit build source
selection. Diagnostic-capacity and font-resource variants could potentially
emit one selected implementation instead of guarded alternatives. Small host
guards may be avoidable through shared configuration or injected values.
Canvas closure storage and raster algorithm selection need assessment of
static restrictions and resource costs. These are candidates, not accepted
decisions or verified removals.

## Why Deferred

The assessment identified no current correctness blocker. Repository-wide
elimination spans SwiftPM, firmware source lists, generators, and contract
fixtures while production joins remain in implementation. Directive counts
alone do not justify that work or introducing dynamic storage into static code.

## Potential Value

- Make shared algorithms and declarations easier to review.
- Make implementation selection explicit at build/composition boundaries.
- Reduce configuration drift while preserving compile-time exclusion.

## Current Non-goals

- No source, target graph, public contract, or profile change is selected.
- No MVP acceptance criterion or universal zero-directive rule is added.
- C header guards, Zephyr configuration selection, and fixture-only switches
  are not presumed defects.
- Runtime branches cannot substitute for compile-time exclusion without
  proving static compatibility, storage bounds, linked symbols, and parity.

## Revisit Triggers

- A maintainer schedules cleanup after current Signal Analyzer production
  joins, or requests a focused mechanical removal.
- A new directive introduces platform/profile selection into portable
  presentation or a previously neutral shared algorithm.
- Build-selection or generation work already touches these variants and can
  remove guards without changing contracts or resource bounds.

## Disposition

Captured as optional maintenance beyond current implementation commitments.
Mechanical changes that preserve contracts may use the lightweight path;
module ownership, profile semantics, public declaration, or resource changes
require the appropriate lifecycle review.

## Draft Iteration Context

The maintainer included this concern in the working scope for
[ITERATION-002: Cleanup](../iterations/iteration-002-cleanup.md) on 2026-10-04.
The scope remains open for codebase review; this link does not promote the item,
change its disposition, or establish a delivery commitment.

## Follow-up Evidence

[Step 15](../iterations/iteration-002-review/15-conditional-removal-candidates.md)
now names 15 whole-file Embedded guards and an empty compatibility file as
candidates. The isolated selected closure passes native execution and nRF
compile/link at unchanged flash/RAM size. SwiftPM selection must change with
production removal; profile, payload, instrumentation and board guards retain
their reasons. This refines optional maintenance without promoting this item.

## References

- [SPEC-013](../specs/spec-013-runtime-profiles.md)
- [ADR-006](../adrs/adr-006-shared-semantics-runtime-profiles.md)
- [ADR-008](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
- [Canvas](../../Sources/GiftUI/Canvas.swift)
- [Raster stroke coverage](../../Sources/GiftUIRasterCore/RasterStrokeCoverage.swift)
- [Reference text resources](../../Sources/GiftUIReferenceTextResources/GiftUIReferenceTextResources.swift)
- [Diagnostic buffer generator](../../scripts/contracts/generate-spec-003-diagnostic-buffer.rb)
- [Firmware build composition](../../firmware/nrf52840/applications/signal-analyzer-static/CMakeLists.txt)
