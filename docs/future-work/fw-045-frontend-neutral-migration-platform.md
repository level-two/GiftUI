---
id: FW-045
feature: giftui-mvp-architecture
title: Frontend-Neutral Semantics and Progressive Migration
status: captured
authors:
  - codex
created: 2026-11-08
updated: 2026-11-08
source:
  - docs/VISION.md
related_future_work:
  - FW-044
  - FW-035
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-045: Frontend-Neutral Semantics and Progressive Migration

## Observation / Opportunity

A team with an LVGL, Qt/QML, or Slint interface may want to evaluate GiftUI
without first rewriting its UI and hardware integration. A bounded assessment
of one representative screen or interaction could reveal what maps faithfully,
what needs approximation, and what must remain outside GiftUI.

A candidate “GiftUI Try” report could classify parts as Native, Approximate,
Opaque, or Unsupported, with behavioral differences and target compatibility
explained. Where evidence permits, it could also report resource costs and
budget gaps; unknown costs would remain explicit. This capture originated in
the maintainer's 2026-11-08 direction map.

## Why Deferred

This capture has no selected external project, source framework version,
representative UI slice, or target budget. Without those, an importer,
compatibility layer, or common semantic representation would be speculative.
Existing Swift runtime and host contracts do not by themselves establish an
interchange or compatibility contract.

## Questions to Revisit

- Can a useful subset be mapped directly, or does it need a shared semantic
  representation? Which state, binding, layout, and interaction semantics differ?
- Would source conversion or an API adapter better serve the selected case?
  What could coexist during screen-by-screen migration?
- Could existing display/SPI/DMA/platform integration be retained? What ownership,
  synchronization, input, and resource-accounting problems would that expose?
- Would an opaque surface escape hatch help, and which testing, simulation, or
  resource claims would become unavailable for that content?
- If a concrete alternate frontend or language consumer needs access, which
  boundary is actually missing? A common IR, language-neutral ABI, C/C++/Rust
  APIs, or a core extraction/rewrite are alternatives to assess, not assumed
  prerequisites for migration. The same applies to a QML-like frontend.

## Potential Value

- A small evaluation could reveal adoption blockers before a team invests in migration.
- Explicit mappings and gaps could support a realistic incremental migration plan.
- Target-specific evidence could expose resource constraints early.

## Relationship to Other Captures

[FW-035](fw-035-generated-view-graph-for-interchangeable-frontends.md) asks
whether a concrete frontend consumer needs generated graphs. Neither migration
nor an alternative frontend implies that generation is necessary.
[FW-044](fw-044-resource-accountability-development-loop.md) considers resource
comparison and attribution; migration assessment need not wait for a general
resource-analysis product to identify what can and cannot be measured.

## Current Non-goals

- A selected IR, ABI, core language, rewrite, or production frontend.
- General LVGL/Qt/Slint compatibility, automatic conversion, or a promise that
  mixed UI can preserve all behavior.
- A ForeignSurface contract or commitment to new boards/backends.
- Reintroducing generated graphs or changing current iteration requirements.

## Revisit Triggers

- A representative external project, source framework version, UI slice, and
  target are identified for migration evaluation.
- A concrete alternate frontend exposes semantics that current integration
  boundaries cannot express.
- A documented language/runtime constraint supplies a specific consumer case
  for comparing a neutral boundary with the current Swift integration.

## Disposition

Captured; no milestone assignment or implementation authorization. A trigger
invites evaluation, not automatic promotion. An Exploration could assess one
selected case; a Proposal could seek investment when its value is established.
A successful mapping would not establish general framework compatibility.

## References

- [GiftUI Vision](../VISION.md): long-term context for the original direction map.
- [Future Work index](README.md#vision-related-opportunities): capture navigation.
