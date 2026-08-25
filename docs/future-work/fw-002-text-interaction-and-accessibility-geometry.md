---
id: FW-002
feature: giftui-mvp-architecture
title: Text Interaction and Accessibility Geometry
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

# FW-002: Text Interaction and Accessibility Geometry

## Observation / Opportunity

Canonical clusters, line membership, and positioned glyphs could later support
text hit testing, selection ranges, carets, editing, and accessibility
geometry without asking a backend to reconstruct text layout.

## Why Deferred

RFC-003 concerns presentation text. The Signal Analyzer does not require an
editable text control, selection, cursor movement, or a text-specific
accessibility contract, and the repository has not accepted such a feature.

## Potential Value

- Reuse canonical text geometry for consistent interaction and accessibility
  behavior across desktop and embedded backends.
- Identify any cluster, storage-lifetime, or bidirectional-mapping data that a
  future interaction contract needs preserved.

## Current Non-goals

- No text editor, selection model, caret API, hit-test API, or accessibility
  implementation is added to RFC-003 or MVP scope.
- This item does not change the existing general input and semantic-event
  boundaries.

## Revisit Triggers

- An accepted Proposal requires editable/selectable text or accessibility
  geometry derived from text layout.
- RFC-003 review finds that omitting a specific cluster mapping now would make
  a future interaction contract impossible or require incompatible identity.

## Disposition

Captured. Promotion requires lifecycle triage under a concrete interaction or
accessibility requirement.

## References

- [RFC-003: Deterministic Text Rendering Architecture](../rfcs/rfc-003-deterministic-text-rendering-architecture.md)
