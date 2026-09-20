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

- SPEC-001 through SPEC-015 — allocated contracts; consult each artifact for
  its current lifecycle status
- [SPEC-001](spec-001-signal-analyzer-reference-application.md) — Signal
  Analyzer Reference Application Contract (`approved`)
- [SPEC-003](spec-003-failure-outcomes-and-containment.md) — Failure Outcomes
  and Containment (`implementing`; macOS 26.6.2 build 25G83 reference-runner
  amendment explicitly reapproved on 2026-09-19)
- [SPEC-015](spec-015-host-configuration.md) — MVP Target-Host
  Configuration Contract (`implementing`; schema-3 semantic-structural and
  measured 53-scope layout-capacity amendments explicitly reapproved on
  2026-09-20)
- [SPEC-006](spec-006-declarative-view-semantics.md) — Declarative View
  Semantics Specification (`approved`; action-primitive-with-content amendment
  explicitly reapproved on 2026-09-12)
- [SPEC-008](spec-008-rendering.md) — Normalized Rendering Contract
  (`implementing`; foreground-stack and arithmetic-evidence amendment
  explicitly approved on 2026-09-11)
- [SPEC-009](spec-009-execution-cycle-and-frame-handoff.md) — Execution Cycle
  and Frame Handoff Contract (`approved`, including focused-owner failure
  amendment)
- [SPEC-010](spec-010-observable-reference-state.md) — Observable Reference
  State Contract (`implementing`, including publishable target-generation
  amendment)
- [SPEC-011](spec-011-interaction.md) — Button Interaction and Activation
  Contract (`approved`; implementation plan draft pending SPEC-006 amendment
  implementation)
- [SPEC-012](spec-012-canvas-path-stroke-drawing.md) — Canvas, Path, and Stroke
  Drawing Contract (`implementing`; render-extension completion-seam amendment
  explicitly approved on 2026-09-12)
- [SPEC-013](spec-013-runtime-profiles.md) — Dynamic and Static Runtime Profile
  Contract (`implementing`; measured 53-scope layout-capacity amendment
  explicitly reapproved on 2026-09-20)
- [SPEC-014](spec-014-backend-integration.md) — Raster Backend and Display
  Integration Contract (`approved`)
