# Specifications

Specifications define precise, implementable, and testable contracts derived
from accepted ADRs. Only approved, implementing, or implemented
Specifications govern implementation.

- Canonical semantics and statuses: [Documentation Rules](../engineering/DOCUMENTATION_RULES.md)
- Lifecycle gates: [Feature Lifecycle](../engineering/FEATURE_LIFECYCLE.md)
- Starting point: [Specification template](../templates/spec.md)

Use filenames of the form `spec-NNN-short-slug.md`. Link every governing ADR,
define acceptance criteria, and update `docs/features.yaml`.

Optional optimizations or extensions discovered during authoring belong in
linked [Future Work](../future-work/README.md), not in the approved contract or
its required acceptance criteria.

## Current portfolio

- SPEC-001 — Signal Analyzer Reference Application Contract (`review`, blocked
  by unresolved application-contract details and downstream reusable contracts)
- SPEC-002 through SPEC-011 — approved contracts
- [SPEC-006](spec-006-declarative-view-semantics.md) — Declarative View
  Semantics Specification (`approved`, reapproved after ADR-033)
- [SPEC-009](spec-009-execution-cycle-and-frame-handoff.md) — Execution Cycle
  and Frame Handoff Contract (`approved`, reapproved after ADR-033)
- [SPEC-010](spec-010-observable-reference-state.md) — Observable Reference
  State Contract (`approved`)
- [SPEC-011](spec-011-interaction.md) — Button Interaction and Activation
  Contract (`approved`)
- [SPEC-012](spec-012-canvas-path-stroke-drawing.md) — Canvas, Path, and Stroke
  Drawing Contract (`draft`)
