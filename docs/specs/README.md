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
- SPEC-002 through SPEC-008 and SPEC-012 — approved contracts
- [SPEC-006](spec-006-declarative-view-semantics.md) — Declarative View
  Semantics Specification (`approved`, reapproved after ADR-033)
- [SPEC-009](spec-009-execution-cycle-and-frame-handoff.md) — Execution Cycle
  and Frame Handoff Contract (`review`, focused-owner failure amendment)
- [SPEC-010](spec-010-observable-reference-state.md) — Observable Reference
  State Contract (`review`, publishable target-generation amendment)
- [SPEC-011](spec-011-interaction.md) — Button Interaction and Activation
  Contract (`review`, candidate target-binding amendment)
- [SPEC-012](spec-012-canvas-path-stroke-drawing.md) — Canvas, Path, and Stroke
  Drawing Contract (`approved`)
- [SPEC-013](spec-013-runtime-profiles.md) — Dynamic and Static Runtime Profile
  Contract (`review`, coordinated approval of SPEC-009 through SPEC-011
  amendments required)
- [SPEC-014](spec-014-backend-integration.md) — Raster Backend and Display
  Integration Contract (`review`, SPEC-009 renewed approval required before
  approval)
