---
id: ITERATION-003
title: Dev UX Improvement
status: draft
revision: 1
approved_revision: null
created: 2026-10-04
updated: 2026-10-05
features:
  - giftui-mvp-architecture
approval: null
closure: null
---

# ITERATION-003: Dev UX Improvement

This is a working scope gathered from maintainer discussions, not a finalized
commitment. The maintainer will review the codebase and may add, remove, or
refine items before approval. Follow [Numbered Iteration Scopes](../engineering/ITERATION_SCOPES.md).

## Goal

Make GiftUI easier to consume in an application and easier to extend with a
backend, through focused packages, a reusable backend foundation, and simpler
integration of selected components.

## Included Scope

All rows are candidates; package boundaries, API design, and implementation
sequence remain open.

| Item                                                                      | Source / feature                                                                                                        | Intended outcome                                                                                                                                                                                                                     | Lifecycle routing                                                                                                                                                               |
| ------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Separate the project into focused packages within the existing repository | [FW-016](../future-work/fw-016-post-mvp-package-distribution-topology.md); giftui-mvp-architecture                      | Let consumers select coherent framework/runtime, rendering, and platform/display components without copying reference-application internals. Package boundaries remain to be evaluated.                                              | Begin with extraction/consumption evidence; package topology and cross-package access need normal Proposal/RFC/ADR/Specification gates, including review of ADR-008.            |
| Core backend module                                                       | Discussion “Assess a Core Backend Framework”; giftui-mvp-architecture                                                   | Make common backend contracts, implementations, validation, and adapter support easier to reuse across hardware and Static/Dynamic profiles. Build on existing shared owners and establish what an additional core module would own. | Inventory existing reuse and duplication before selecting a boundary. Review against ADR-006/ADR-007 and SPEC-014; do not introduce a universal backend requirement implicitly. |
| Simplify backend integration                                              | [FW-030](../future-work/fw-030-application-integration-experience.md); discussion “Simplify GiftUI Backend Integration” | Reduce manual source selection, bootstrap wiring, storage-offset knowledge, and application-specific infrastructure needed to launch an application with a selected backend.                                                         | Use a small separate consumer to establish friction and evaluate supported host/build entry points; public integration contracts and tooling choices need lifecycle approval.   |

## Backend Foundation and Integration Coordination

The core backend and integration-rework rows are coordinated candidate
outcomes: the foundation supplies reusable rendering/display components and
construction support; integration supplies application-facing host assembly
and supported build paths that consume those components. Host lifecycle,
input, scheduling and application policy retain their existing owners.

Evaluate both through one small external consumer, first using a supported
composition and then replacing its display with a recording adapter through
the same assembly path. Share the access/type inventory, configuration facts,
setup/resource baseline and target matrix with the packaging item. Keep
IT-AC-001/002/003 results distinct; neither an adapter-only test nor a short
application bootstrap proves all three outcomes.

The [EXP-002 coordinated study](../explorations/exp-002-backend-and-application-integration-shapes.md#coordinated-backend-foundation-and-integration-rework--2026-10-05)
records the responsibility mapping and proposed sequence, using the
[backend inventory](../explorations/exp-002/backend-foundation-inventory-2026-10-05.md)
and FW-030 as evidence. Select compatible extension/assembly/access contracts
before deriving implementation tasks. No additional module, preset API or
package topology is selected by this alignment.

## Exclusions

- No repository split at this stage. Independent releases, versioning, or
  repository migration are not selected outcomes.
- No one-package-per-module rule or final package/module naming is selected.
- No new hardware backend or replacement of all backends with one rendering
  implementation is proposed.
- Cleanup of dependencies, nRF hierarchy projections, conditionals, and
  analyzer retention belongs to [ITERATION-002](iteration-002-cleanup.md).
- Automatic board discovery, flashing, deployment, and a general configuration
  generator are not implied by simpler integration.

## Success Criteria and Validation

These are provisional outcomes to refine before scope approval.

| ID | Observable result | Required configurations | Evidence / governing contract |
| --- | --- | --- | --- |
| IT-AC-001 | A separate small application can consume selected focused packages without copying Signal Analyzer owners or relying on repository-wide source lists. | Consumer/toolchain matrix to be selected, including Static/Embedded feasibility | Approved topology/access contracts, package dependency graph, reproducible consumer builds, and preserved owner-boundary tests. |
| IT-AC-002 | Backend developers have an explicit reusable foundation and a minimal adapter/composition example showing common and target-specific responsibilities; the example is usable through the integration path evaluated for IT-AC-003. | Existing Pi Dynamic and nRF Static stacks as initial inventory; shared consumer/target matrix with IT-AC-003 to be selected | Reuse inventory, selected module responsibilities, adapter-substitution and conformance checks, and profile-specific resource evidence under governing contracts. |
| IT-AC-003 | A consumer can select a supported backend and build/run through a documented integration path with less manual wiring, and use the IT-AC-002 adapter example through the same assembly path. | Shared consumer/target matrix with IT-AC-002 to be selected | Before/after setup steps and touched-file inventory, runnable consumer example using the reusable foundation, configuration-error diagnostics, and startup/lifecycle checks under approved integration contracts. |

## Dependencies and Open Questions

- The architecture feature is currently `implemented`; these post-MVP
  candidates do not amend its accepted decisions or implemented contracts.
- Refresh the baseline from active ITERATION-002 revision 7 before settling
  package boundaries. ITERATION-003 remains draft; numbering alone does not
  approve its scope or establish an implementation schedule.
- Which focused packages/products form independently useful consumption units?
  Which currently package-scoped contracts need narrowly scoped external access?
- What belongs in the core backend module, given existing `GiftUISurfaceCore`,
  `GiftUIRasterCore`, `GiftUIDisplayCore`, and `GiftUIBackendIntegration`?
  Distinguish common contracts from rendering-family-specific algorithms.
- Which setup belongs to the application, reusable host assembly, backend,
  platform/display adapter, and board configuration? The application should
  retain user behavior and final component selection.
- Which small consumer and target matrix demonstrate the intended UX? Decide
  measurable setup goals after collecting a baseline rather than inventing a
  one-button guarantee.
- Preserve Static bounded storage, zero heap allocation, ownership, capabilities,
  and Dynamic/Static semantic parity across any selected package boundary.
- Complete the maintainer's codebase review and resolve scope-invalidating
  questions before approval. Architecture changes require their normal gates;
  the scope does not select them.

## Deferred and Follow-up Work

- [FW-016](../future-work/fw-016-post-mvp-package-distribution-topology.md)
  and [FW-030](../future-work/fw-030-application-integration-experience.md)
  supply the packaging and integration observations. This draft is context
  for re-evaluation, not promotion or implementation authorization.
- [FW-006](../future-work/fw-006-generated-target-configuration.md) and
  [FW-009](../future-work/fw-009-shared-delegated-service-foundation.md)
  remain separate candidates; no configuration generator or shared service
  foundation is selected here.

## Revision and Approval History

| Revision | Date | Change / reason | Maintainer approval |
| --- | --- | --- | --- |
| 1 | 2026-10-04 | Initial candidate scope from recent discussions and the maintainer's two-iteration outline; further code review expected. | Pending |

On 2026-10-05 the maintainer requested alignment of backend foundation and
integration rework, plus committing the documentation. The draft now records a
joint consumer study and compatible contract evaluation, preserving the three
criterion IDs. This instruction is not scope or architecture approval.

## Closure and Follow-up

Not started. At closure, record every criterion's disposition, evidence,
approved exceptions, and remaining deferred work.

## References

- [EXP-002 backend foundation inventory](../explorations/exp-002/backend-foundation-inventory-2026-10-05.md) — existing reuse, extension/access gaps and IT-AC-002 evidence coordinated with integration rework; no scope or design approval
- [EXP-002: Backend and Application Integration Shapes](../explorations/exp-002-backend-and-application-integration-shapes.md) — documentation-only candidate comparison; no scope or architecture approval
- [ADR-006: Shared Semantics and Runtime Profiles](../adrs/adr-006-shared-semantics-runtime-profiles.md)
- [ADR-007: Integration Ownership and Host Composition](../adrs/adr-007-integration-ownership-and-host-composition.md)
- [ADR-008: Module Dependency Graph and Package Topology](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
- [SPEC-014: Backend Integration](../specs/spec-014-backend-integration.md)
- [SPEC-015: Host Configuration](../specs/spec-015-host-configuration.md)
- Discussion provenance: “Assess a Core Backend Framework” (`01a0fd58-87e8-79c1-81be-b0aab9e5cc76`) and “Simplify GiftUI Backend Integration” (`01a0fd59-dd59-71f2-bf32-d42c617c8705`).
