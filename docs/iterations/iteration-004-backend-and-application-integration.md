---
id: ITERATION-004
title: Backend and Application Integration
status: approved
revision: 1
approved_revision: 1
created: 2026-10-09
updated: 2026-10-09
features:
  - external-application-integration
  - giftui-mvp-architecture
  - signal-analyzer
approval: "Eugene approved the presented iteration sequencing and requested scope reorganization, dependent updates and commits on 2026-10-09. Evidence: docs/iterations/iteration-003-review/efficiency-sequencing-approval.md."
closure: null
---

# ITERATION-004: Backend and Application Integration

Approved destination for the delivery transfer described in the
[iteration-3 memory/efficiency plan](iteration-003-review/memory-efficiency-plan.md).
[Eugene's approval](iteration-003-review/efficiency-sequencing-approval.md)
establishes revision 1 and the corresponding iteration-3 revision-4 transfer.
This iteration is approved, not active; production extraction waits for its
entry gates. Architecture and Specification approvals remain separate.

## Goal

Make the measured, resource-safe runtime reusable by an external application
and display-adapter author through focused packages, backend/platform
components and supported host/build entry points. Preserve the memory, timing,
semantic and runtime-derivation results established in iteration 3.

## Included Scope

| Item | Source / feature | Intended outcome | Lifecycle routing |
| --- | --- | --- | --- |
| I4-01 — Focused packages | Approved transfer of I3-01; FW-016 | External consumers select framework/runtime, rendering and required platform/display components without analyzer internals or repository-wide source lists | Review ADR-008/SPEC-002 and current cost/ownership handoff; approve affected topology/access decisions before extraction |
| I4-02 — Reusable backend and platform components | Approved transfer of I3-02; EXP-002 / PROPOSAL-007 | Reusable raster/session construction, validation and narrow adapter contracts; one external recording adapter uses the same supported assembly path | RFC-013, accepted downstream ADRs and approved SPEC-009/012/014 amendments as required; no mandatory new core module |
| I4-03 — Simpler external application integration | Approved transfer of I3-03; FW-030 / PROPOSAL-007 | Complete supported host/build/setup path for the finite counter; portable presentation imports GiftUI alone; no copied analyzer infrastructure or handwritten framework offsets | Public assembly/lifetime/build contracts and ready Spec plans before implementation |
| I4-04 — Compatibility and author documentation | Approved transfer/renewal of IT-AC-004/005 | Preserve runtime derivation and iteration-3 efficiency; reproducible quick start, adapter and migration guides | Final owner conformance, measured paired artifacts and separate criterion dispositions |

Use the same bounded counter/status application, changing text, typed actions,
disabled Button and small Canvas variant as iteration 3. It must now be a real
external package consumer without privileged shared-package access. First build
supported compositions, then substitute only the recording display through the
same backend/host assembly. Keep Signal Analyzer as the nontrivial compatibility
application. Runtime graph derivation remains mandatory for both applications.

## Delivery Order and Gates

1. Accept the iteration-3 handoff and refresh exact source/toolchain/resource
   identities. Reconcile RFC-013 with the approved ownership and storage choices.
2. Review transitive access and package alternatives together with backend and
   host construction. Obtain architecture and affected Specification approvals.
3. Derive ready implementation plans; extract one coherent vertical consumer
   path and test it before migrating further supported platform compositions.
4. Run the external consumer/adapter matrix and compare final analyzer memory,
   timing and loaded behavior with the iteration-3 baseline.
5. Publish documentation and criterion dispositions; request human closure.

## Exclusions

- A new rendering algorithm solely to justify a new backend module, universal
  backend base, new physical backend, independent repository/release system,
  arbitrary Swift lowering or generated expanded view-graph fallback.
- Unreviewed public API exposure, changed ownership/transfer semantics or
  increased budgets hidden inside mechanical package moves.
- Automatic deployment, remote service changes or connected-board flashing.
- Treating old MVP exceptions as approval of extraction regressions.

## Success Criteria and Validation

IDs below map the transferred obligations without erasing their iteration-3
history. The transfer is approved under iteration-3 revision 4.

| ID | Observable result | Required configurations | Evidence / governing contract |
| --- | --- | --- | --- |
| I4-AC-001 (from IT-AC-001) | Real external consumer selects focused packages, imports GiftUI for presentation and omits unused concrete platforms | All four configurations | Clean dependency/product builds; no analyzer internals, privileged access or framework source lists; ADR-008 and affected SPEC-002/013/014/015 |
| I4-AC-002 (from IT-AC-002) | External recording adapter reuses existing raster/session/validation owners with no copied state machine or second bootstrap | Native Dynamic/Static execution; actual ARMv6/Embedded supported and recording compile/link | Exact fill/glyph/stroke, clipping/order, borrow/transfer, refusal/health/retirement fixtures; SPEC-009/012/014 |
| I4-AC-003 (from IT-AC-003) | Each target has fewer manual setup actions and user-maintained infrastructure files than the same consumer baseline; no copied analyzer infrastructure or handwritten framework offsets | All four configurations | Reproducible before/after inventory including generation and prerequisites; supported/recording configuration and negative-activation cases; SPEC-003/004/005/013/015 |
| I4-AC-004 (renewed IT-AC-004/006) | Both applications preserve runtime-derived graphs, profile semantics, state/actions/pixels/failures and iteration-3 resource/performance results | All four configurations, actual supported targets for timing claims | Final exact artifact/flag comparisons, approved budgets and governing Spec conformance; repeat changed-path connected tests when required |
| I4-AC-005 (from IT-AC-005) | Application and adapter authors can reproduce and customize supported integration; every criterion has an evidenced disposition | All supported build routes | Quick start, custom-adapter guide, owner-input inventory, package/API compatibility and migration notes; exact evidence identities and human closure |

The matrix is macOS Dynamic, macOS Static, Raspberry Pi 1
`armv6-unknown-linux-gnueabihf` Dynamic with framebuffer/PiScreen, and
`nrf52840dk/nrf52840` Embedded Static with the existing TFT composition.
Native rehearsals and target links do not establish connected performance.
Use repository toolchains and target skills, preserve zero-heap Static and VFP
ABI checks, and obtain explicit authorization for required connected operations.

## Dependencies and Open Questions

- Iteration-3 revision 4 and this revision 1 are approved. Their feature and
  implementation gates remain separate.
- Production migration depends on iteration-3 safe memory/stack, sustained
  workload, runtime-derivation and compatibility evidence, or a specifically
  accepted exception defining the downstream risk. Inventory/design preparation
  may proceed while those gates are open.
- PROPOSAL-007 remains accepted and RFC-013 draft. Reuse valid studies and
  failures; do not reset SPIKE-067's exhausted allowance or adopt its code by
  moving files. New architecture/contracts remain separate human gates.
- Decide whether the measured owner boundaries require any new core module;
  no module name or inheritance hierarchy is selected by this scope.
- Identify minimal public transitive access and maintainable supported build
  routes after efficiency decisions stabilize the lifetime/storage requirements.

## Revision and Approval History

| Revision | Date | Change / reason | Maintainer approval |
| --- | --- | --- | --- |
| 1 | 2026-10-09 | Transfer backend/package/external-host delivery after iteration-3 memory and efficiency work | [Explicit sequencing approval](iteration-003-review/efficiency-sequencing-approval.md) |

## Closure and Follow-up

At closure, disposition I4-AC-001–005 as met, unmet or explicitly excepted with
current evidence. Preserve remaining work and triggers, and obtain a human
closure decision. Do not infer delivery from transferred scope or passed studies.

## References

- [ITERATION-003 and approved baseline](iteration-003-dev-ux-improvement.md)
- [Approved sequencing and activity plan](iteration-003-review/memory-efficiency-plan.md)
- [PROPOSAL-007](../proposals/proposal-007-external-application-integration.md)
- [RFC-013](../rfcs/rfc-013-external-application-and-backend-integration.md)
- [EXP-002](../explorations/exp-002-backend-and-application-integration-shapes.md)
- [FW-016](../future-work/fw-016-post-mvp-package-distribution-topology.md),
  [FW-030](../future-work/fw-030-application-integration-experience.md)
