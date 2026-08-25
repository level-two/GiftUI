---
id: FW-001
feature: giftui-mvp-architecture
title: International and Rich Text Layout
status: captured
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-25
source:
  - RFC-003
  - ADR-021
  - SPEC-005
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-001: International and Rich Text Layout

## Observation / Opportunity

RFC-003 places shaping and segmentation above the backend so GiftUI can later
support pinned full OpenType shaping, complex scripts, bidirectional and
vertical layout, locale-aware segmentation, variable-font axes, color glyphs,
emoji, and alternative writing modes without redesigning every renderer.

## Why Deferred

The MVP Signal Analyzer requires only a bounded left-to-right Latin text set.
No accepted application or stack-validation requirement currently justifies
the implementation and conformance cost of richer shaping semantics.

## Potential Value

- Preserve portable geometry for applications whose scripts or typography
  exceed the MVP shaping envelope.
- Test whether RFC-003's font identity and positioned-run boundary scales to a
  pinned shared shaping engine and richer glyph representations.

## Current Non-goals

- No complex-script, bidirectional, vertical, variable-font, color-glyph, or
  locale-aware implementation is added to RFC-003 or the MVP roadmap.
- This capture does not select HarfBuzz or any other shaping engine.

## Revisit Triggers

- An accepted Proposal requires a script, writing mode, variable font, or
  color-glyph behavior outside the MVP shaping envelope proposed by RFC-003.
- Review evidence shows that the MVP package identity or positioned-run
  contract would foreclose a credible richer shaping implementation.

## Disposition

Captured. Promotion requires lifecycle triage and, if architectural research
is needed, a focused Exploration before any RFC or implementation commitment.

## References

- [RFC-003: Deterministic Text Rendering Architecture](../rfcs/rfc-003-deterministic-text-rendering-architecture.md)
