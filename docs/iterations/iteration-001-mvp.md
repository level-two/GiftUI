---
id: ITERATION-001
title: GiftUI MVP
status: closed
revision: 1
approved_revision: 1
created: 2026-10-04
updated: 2026-10-04
features:
  - giftui-mvp-baseline
  - signal-analyzer
  - giftui-mvp-architecture
  - capability-system
  - observable-reference-state
  - canvas-drawing
approval: "Maintainer instruction on 2026-10-04: improve the process with numbered iterations and mark MVP as ITERATION-001. This registers the existing scope and disposition."
closure: Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/remaining-spec-transition-approval.md
---

# ITERATION-001: GiftUI MVP

## Goal

Prove that a meaningful interactive Signal Analyzer can use a substantially
shared declarative presentation across desktop, Linux/framebuffer, and
constrained embedded environments. The authoritative outcome and detailed
requirements remain in [MVP Scope](../MVP_SCOPE.md).

## Included Scope

This numbered record registers the existing baseline; it adds no requirements.
The included feature surface, architecture, capabilities, backend/profile
validation, and drawing requirements are defined by [MVP Scope](../MVP_SCOPE.md).
The [feature manifest](../features.yaml) indexes the governing artifacts for
the feature keys above. Delivery order is recorded in
[MVP Milestones](../roadmap/MVP_MILESTONES.md), and contract coverage in the
[Specification Portfolio](../roadmap/MVP_SPECIFICATION_PORTFOLIO.md).

## Exclusions

The existing [MVP non-goals](../MVP_SCOPE.md#explicit-non-goals) remain in force.
Broader cleanup, restructuring, package distribution, and external application
integration are candidates for subsequent iteration selection, including
[FW-029](../future-work/fw-029-reduce-source-conditional-compilation.md),
[FW-016](../future-work/fw-016-post-mvp-package-distribution-topology.md), and
[FW-030](../future-work/fw-030-application-integration-experience.md).

## Success Criteria and Validation

The eleven [MVP Exit Criteria](../MVP_SCOPE.md#mvp-exit-criteria) and
[Definition of Success](../MVP_SCOPE.md#definition-of-success) remain the
baseline. This registration neither renumbers nor duplicates those criteria.
Required configurations remain macOS Dynamic, macOS Static, Raspberry Pi 1
Dynamic with framebuffer/PiScreen, and nRF52840 Static with a TFT display.

Specification-level dispositions and evidence are linked by the
[Specification Portfolio](../roadmap/MVP_SPECIFICATION_PORTFOLIO.md).
The [final closeout evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md)
and [recorded maintainer approval](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/remaining-spec-transition-approval.md)
preserve passing checks, failing timing measurements, and incomplete connected
coverage. Build and hardware-free checks do not replace connected evidence.

## Dependencies and Open Questions

The participating features' dependencies remain in [features.yaml](../features.yaml).
Outstanding measured conformance is preserved in the follow-up below;
numbered registration does not resolve it or select the next iteration.

## Revision and Approval History

| Revision | Date | Change / reason | Maintainer approval |
| --- | --- | --- | --- |
| 1 | 2026-10-04 | Register the established MVP scope as ITERATION-001; retain existing scope links and closeout history. | Explicit request to introduce numbered iterations and mark MVP as ITERATION-001. |

## Closure and Follow-up

The current iteration was closed under the
[2026-10-03 maintainer authorization](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/remaining-spec-transition-approval.md).
All fifteen MVP Specifications are implemented under recorded approvals,
including exceptions for timing and incomplete connected coverage.
Full measured MVP conformance remains outstanding; `closed` records the
iteration disposition, not universal satisfaction of the MVP exit criteria.

The existing follow-up captures remain outside this closed commitment:

- [FW-027](../future-work/fw-027-pi-performance-investigation-resumption.md): Pi performance.
- [FW-031](../future-work/fw-031-macos-connected-pointer-validation-resumption.md): macOS physical pointer validation.
- [FW-032](../future-work/fw-032-nrf-performance-improvement.md): nRF performance.
- [FW-033](../future-work/fw-033-connected-validation-follow-up.md): remaining connected validation.

Their existing revisit triggers and scope boundaries remain in force. They
require explicit prioritization before entering a subsequent iteration.

## References

- [PROPOSAL-001: MVP Baseline Charter](../proposals/proposal-001-giftui-mvp-baseline-charter.md)
- [Numbered Iteration Scopes](../engineering/ITERATION_SCOPES.md)
