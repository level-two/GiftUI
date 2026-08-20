---
id: FW-014
feature: giftui-mvp-architecture
title: Replayable Operation Delivery for Future Raster Strategies
status: captured
authors:
  - Yauheni Lychkouski
created: 2026-08-19
updated: 2026-08-20
source:
  - RFC-004
  - RFC-006
  - ADR-010
  - ADR-020
related_future_work:
  - FW-010
related_explorations: []
related_spikes:
  - SPIKE-001
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-014: Replayable Operation Delivery for Future Raster Strategies

## Observation / Opportunity

A future accepted raster feature may require bounded multi-pass traversal of a
normalized GiftUI operation sequence. Examples could include a renderer whose
measured algorithm must revisit operations for several physical regions, a
remote or recorded presentation path, or another strategy that cannot consume
RFC-004's one-shot borrowed stream while meeting its accepted resource or
behavioral requirements.

A separately justified replayable representation could preserve normalized
operation meaning across those passes. It would need explicit ownership,
lifetime, capacity, failure, static-storage, and compatibility semantics rather
than silently extending the MVP frame payload.

## Why Deferred

RFC-004 and RFC-006 select one synchronous borrowed one-shot stream for every
first-party MVP raster path, including RGB565 tiled paths. No current Signal
Analyzer or four-target validation requirement demonstrates a need to retain or
replay GiftUI operations, and adding such a mode now would create storage and
failure costs before a supported consumer exists.

FW-010 separately preserves replay only when post-handoff recovery requires
it. This item concerns a raster strategy's normal operation, not retry after an
accepted handoff.

## Potential Value

- Enable a measured future multi-pass raster strategy without forcing repeated
  semantic derivation or target-specific operation reconstruction.
- Give static and dynamic implementations one reviewed bounded replay contract
  if a supported feature truly needs it.
- Keep future replay ownership and resource cost explicit rather than allowing
  an implementation-local lifetime extension.

## Current Non-goals

- No replayable payload, retained display list, persistent frame capture, or
  additional operation-delivery mode is added to the MVP.
- Existing tiled paths must continue to satisfy the common one-shot stream
  contract selected by RFC-004 and RFC-006.
- This item does not authorize backend retry, frame rescheduling, semantic
  replay, or reopening a committed frame.

## Revisit Triggers

- An accepted post-MVP raster or presentation feature demonstrates through a
  bounded fixture that one-shot operation consumption cannot meet its required
  semantics or resource budget.
- Measurements show that a maintained multi-pass backend repeatedly derives or
  reconstructs equivalent operations at materially greater RAM, CPU, transfer,
  or energy cost than a bounded replay representation.
- Two supported raster implementations independently introduce incompatible
  operation-retention schemes, indicating a shared architectural decision.
- A supported backend demonstrates that normalized-operation replay is needed
  for ordinary rendering rather than the post-handoff recovery covered by
  FW-010.

## Disposition

Captured for post-MVP consideration. A trigger requires lifecycle triage and,
because this would change RFC-004's payload lifetime architecture, an amended
or superseding RFC/ADR path before any Specification or implementation adopts
it.

## References

- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-006: GiftUI Capability System Architecture](../rfcs/rfc-006-capability-system-architecture.md)
- [FW-010: Backend and Transport Post-Handoff Recovery](fw-010-backend-transport-submission-retry.md)
- [SPIKE-001: Tiled One-Shot Stream and Capability Compatibility Fixtures](../spikes/spike-001-tiled-one-shot-capability-fixtures.md)
