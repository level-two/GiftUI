---
id: ITERATION-003
title: Dev UX Improvement
status: approved
revision: 2
approved_revision: 2
created: 2026-10-04
updated: 2026-10-05
features:
  - external-application-integration
  - giftui-mvp-architecture
  - signal-analyzer
approval: "Eugene authorized review, alignment, gap filling, approval and commit on 2026-10-05. Revision 2 records that reviewed scope. Evidence: docs/iterations/iteration-003-review/scope-review-and-approval.md."
closure: null
---

# ITERATION-003: Dev UX Improvement

Eugene explicitly requested review, alignment, gap filling, approval and commit
on 2026-10-05. Revision 2 is the resulting delivery commitment under
[Numbered Iteration Scopes](../engineering/ITERATION_SCOPES.md).
[Review and approval provenance](iteration-003-review/scope-review-and-approval.md)
records the findings and dispositions. Scope approval leaves architecture,
external APIs and implementation behind their separate lifecycle gates.

## Goal

Make GiftUI usable by a second application and extensible by a display-adapter
author through focused packages in this repository, reusable backend components,
and a supported application integration path. Remove the need to copy Signal
Analyzer infrastructure or understand framework storage offsets to launch that
application. Preserve portable UI semantics and constrained Static execution.

This is post-MVP work. [ITERATION-001](iteration-001-mvp.md) validated one
reference application on four stacks; it did not establish external host or
backend-extension contracts. The existing MVP features are `implemented`;
Signal Analyzer participates as the compatibility check, not a new application
feature. Existing approvals and exceptions retain their recorded scope.

The new `external-application-integration` feature is at Proposal stage under
draft [PROPOSAL-007](../proposals/proposal-007-external-application-integration.md).
Its registration supplies lifecycle traceability, not acceptance of the new
architecture or implementation contracts.

## Preparation Baseline

[FW-016](../future-work/fw-016-post-mvp-package-distribution-topology.md)
identifies product/access and build-selection barriers. [FW-030](../future-work/fw-030-application-integration-experience.md)
and [EXP-002](../explorations/exp-002-backend-and-application-integration-shapes.md)
identify assembly, Static adaptation and configuration friction. The
[backend inventory](../explorations/exp-002/backend-foundation-inventory-2026-10-05.md)
establishes substantial existing shared raster, endpoint, display and validation
owners; it supports construction/access improvements, not a raster rewrite.

Scope review used clean commit `feb40589`; ITERATION-002 is active revision 7.
Its final combined validation and closure remain separate. Refresh source,
generation, access and resource facts for the consumer study and before
restructuring; earlier inventory and cleanup runs are comparison evidence.

The [2026-10-05 preparation baseline and consumer study](../explorations/exp-002/preparation-2026-10-05/README.md)
now record current input hashes, cleanup/evidence dependencies, six bounded
native/Embedded declaration/access probes and the coordinated Proposal.
This preparation update does not amend revision 2's commitment.

## Included Scope

These are coordinated selections. Exact package/module names, external types
and factory syntax are downstream design decisions.

| Item | Source / feature | Intended outcome | Lifecycle routing |
| --- | --- | --- | --- |
| I3-01 — Focused packages | FW-016; giftui-mvp-architecture | Independently useful framework/runtime, rendering and selected environment/display components distributed as focused packages within this repository; external consumers need no reference-application internals or repository-wide source lists. | Compare closures/access first. Review ADR-008 and SPEC-002; obtain the necessary RFC/ADR and affected Spec approvals before extraction. Multiple products in the current package are a comparison baseline, not fulfillment of this outcome. |
| I3-02 — Reusable backend foundation | EXP-002 backend inventory; giftui-mvp-architecture | Externally reusable contracts, raster/session construction, validation and adapter support; a minimal recording display adapter over the existing software raster family usable through I3-03. | Inventory the required transitive types/access and duplication; preserve ADR-006/007 and SPEC-009/014 owners. An additional core module is an option, not a mandatory deliverable or universal backend base. |
| I3-03 — Simpler application integration | FW-030 / EXP-002; giftui-mvp-architecture | Documented supported host/build entry points with less application setup; supported and custom display selection use the same assembly path. Separate application behavior/resources/policy from reusable host mechanics. | Prepare a coordinated post-MVP Proposal covering all three outcomes. Public assembly/extension/access contracts and tooling choices require reviewed RFC decisions, accepted ADRs and approved Specifications before ready implementation plans. |

## Shared Consumer and Responsibility Boundaries

Use one separate counter/status consumer project outside GiftUI's distribution
packages. It may be maintained as an example in this repository, but must use
the supported external package interfaces. Shared package identity, privileged
internal access or a root-manifest target cannot substitute for consumption.

The bounded application has one observable root, finite typed actions, changing
text and a disabled Button state, plus a tiny Canvas stroke variant exercising
resource limits. Its portable presentation stays shared and imports `GiftUI`
alone. Record every Static lowering, generated and handwritten binding. This
commits only the finite adaptation needed for this example, not arbitrary Swift
application lowering or replacement of the retained packed Static runtime.

First select existing supported compositions, then replace only the display
with an external recording adapter using the same raster implementation and
assembly path. Use deterministic clock/scheduling fixtures for repeatable host
checks. The consumer must not import Signal Analyzer Domain/Data/TargetHost or
copy pipeline, endpoint, raster or driver state machines. Recording is a contract
test adapter, not a new physical backend or evidence of physical input.

| Owner | Responsibility retained |
| --- | --- |
| Application | Views, model, action meaning, domain services, exact resources/workload, final component selection and explicit policy |
| Reusable host assembly | Configuration reconciliation, graph construction, activation/service/quiescence/teardown, input eligibility, scheduling joins and typed failure routing |
| Backend foundation | Existing one-shot endpoint, raster/session construction and validation, bounded payload/transfer mechanics and local operational health |
| Display/transport and environment adapters | Geometry/encoding/device facts, payload delivery/lifetime, clocks/wakes and OS/board mechanisms; input/calibration stays a sibling seam |
| Package/build support | Dependency/source selection, reviewed external access, configuration projection and reproducible artifact identities |

Share one access inventory, setup baseline, resource inputs and matrix across
all three items; keep their criterion results distinct. A short bootstrap does
not prove independent packages, and an adapter test does not prove host setup.
Inspect component facts/defaults; evaluate application-owned service loops and
a sample runner without selecting an API here. Adapter substitution is a
construction-time choice, not live reconfiguration.

## Delivery Order and Gates

1. Refresh Iteration 2 inputs and reproduce the bounded consumer's current setup.
   Record manual actions, user-maintained infrastructure files, copied code,
   framework concepts, dependency closure, Static adaptation and assembled costs.
   Use EXP-002 for feasibility findings; any disposable prototype needs a bounded
   Spike record with candidate, method, budgets and stop conditions before coding.
2. Draft the coordinated post-MVP Proposal and compare package/access, extension
   and host/build alternatives together. Split RFCs only for independently
   reviewable decisions. Resolve actual Embedded consumption early.
3. Obtain architecture and contract approvals, including external compatibility,
   configuration diagnostics, finite Static bindings/storage inputs and measured
   resource ceilings. Derive ready Spec plans after those gates.
4. Implement coherent package, foundation and host/build changes through those
   plans, exercising the same consumer and adapter path throughout. Retain
   Signal Analyzer as the nontrivial regression check.
5. Publish separate criterion dispositions and request human closure. If
   feasibility, approvals or evidence fail, record the affected outcome as
   unmet and request a scoped amendment or exception. An investigation
   disposition alone does not satisfy the implementation outcomes.

This is delivery coordination, not a ready implementation plan. Read-only
preparation may begin while ITERATION-002 is active. Before restructuring,
identify the cleanup revision/evidence being inherited and resolve overlapping
source/build/generation changes. No cleanup completion, new feature stage or
downstream approval is inferred from this scope.

## Exclusions

- Repository splitting, independent releases/version systems, registry publishing
  and one-package-per-module rules.
- New physical backends, GPU/non-raster implementations, a universal backend base,
  or replacement of shared raster algorithms without demonstrated need.
- General configuration generation, arbitrary application lowering, complete
  Static hierarchy replacement or a shared delegated-service framework.
- Automatic discovery, deployment, flashing or remote service changes.
- Simulator/digital-twin tooling, frontend-neutral IR/ABI, non-Swift core rewrite,
  migration/import tools, adaptive capability UI or foreign/native composition.
- Performance remediation or closing all prior connected-conformance gaps.
  Existing workloads, timing requirements and exception boundaries remain.
- ITERATION-002 source/dependency/retention/topology cleanup; integrate its result
  without reopening its approved commitment.

## Success Criteria and Validation

IT-AC-001/002/003 are retained and made concrete. IT-AC-004/005 cover shared
compatibility and documentation/evidence gaps. These define iteration exit
evidence, not replacement Specification acceptance criteria.

| ID | Observable result | Required configurations | Evidence / governing contract |
| --- | --- | --- | --- |
| IT-AC-001 | The separate consumer selects focused packages without copied analyzer owners, repository-wide source lists or privileged package access. Presentation imports only `GiftUI`; constrained closures omit unused concrete platforms. | All four configurations below; package consumer and build-selection checks | Approved topology/access contracts, transitive package/product/module graphs, clean consumer builds and prohibited-dependency checks; ADR-008 and affected SPEC-002/013/014/015. |
| IT-AC-002 | An external recording display adapter uses documented narrow contracts and existing raster/session/validation support through I3-03 without another bootstrap or copied state machine. | macOS Dynamic/Static execution; Pi ARMv6 and nRF Embedded compile/link plus native contract rehearsal | Reuse/type inventory, adapter-substitution builds, exact fill/glyph/stroke and clipping/painter-order fixtures, reservation/abort/acceptance/health/cleanup cases and bounded storage; SPEC-009/012/014. |
| IT-AC-003 | Compared with the same consumer baseline, each target's setup has strictly fewer manual actions and fewer user-maintained infrastructure files. Zero copied analyzer infrastructure, zero application-maintained framework source lists and zero handwritten framework storage offsets are required. Display replacement preserves portable UI/model/action code and uses the same assembly path. | All four build configurations; native supported/recording modes with equivalent finite inputs | Reproducible before/after steps/files inventory counting prerequisites, generated inputs and work hidden by presets; startup/service/teardown and missing resources, encoding mismatch, insufficient capacity and incomplete-configuration diagnostics without partial activation; external integration contracts plus SPEC-003/004/005/013/015. |
| IT-AC-004 | Consumption and assembly changes preserve Signal Analyzer behavior, owner/import direction, Static/Dynamic semantics, failure/provenance and resource guarantees. The consumer has equivalent declared behavior across profiles with explicit bounded Static adaptation. | All four configurations; analyzer and consumer | Final affected Spec gates and combined repository hardware-free gate; profile transcripts, pixel/action oracles, stale-input/model-generation cases, one-shot borrow/transfer evidence and paired flash/RAM/storage/stack/ABI/heap checks; SPEC-001/002/009/011/012/013/014/015, current application limits and reviewed consumer budgets. |
| IT-AC-005 | Application and adapter authors can reproduce setup, inspect assumptions/failures and customize through the supported path; every scope criterion has a separate evidenced disposition. | Consumer documentation and supported build routes | Quick start, custom-adapter guide, application versus reusable input inventory, migration notes for moved products/access, external API compatibility policy, validation limits, exact source/toolchain/artifact identities, linked contract conformance and human closure. |

### Required configuration matrix

| Configuration | Consumer evidence required | Compatibility evidence |
| --- | --- | --- |
| macOS Dynamic | Clean external build and execution in supported/recording modes; setup and negative-configuration checks | Analyzer Dynamic and governing owner gates |
| macOS Static | Same behavior via documented finite Static bindings; native execution and adapter substitution | Analyzer Static and cross-profile comparison |
| Raspberry Pi 1 / ARMv6 Linux Dynamic | Actual `armv6-unknown-linux-gnueabihf` compile/link with existing framebuffer/PiScreen support and recording-adapter selection; native deterministic rehearsal | Current Pi artifact/owner gates and analyzer trace comparisons |
| nRF52840-DK / Embedded Static | Actual `nrf52840dk/nrf52840` firmware compile/link with existing TFT composition and recording-adapter selection; native finite-binding rehearsal | Current analyzer firmware/gates; Cortex-M4F hard-float/VFP ABI, forbidden-symbol, heap, storage and stack evidence |

Native rehearsal and cross-builds establish their evidence classes, not connected
execution. Use supported toolchains under `.toolchains/` and target artifacts
under `.build/raspberry-pi/` and `.build/nrf52840/`. Document toolchain prerequisites,
board/display facts and consumer-owned configuration.

Before production implementation, record matched toolchain/configuration
baselines and explicit consumer resource ceilings in the reviewed contracts.
Measure full linked images, backing storage and specialization cost. Existing
Static zero-heap and application resource/stack bounds continue to apply; changed
bounds need their normal approval. Do not retrofit budgets to a failing result.
Setup comparisons must count all manual generation/adaptation for the same
behavior and limits; shorter Swift syntax alone cannot satisfy IT-AC-003.

Run focused owner checks, format maintained Swift before the repository gate,
then run the final combined four-profile hardware-free gate with immutable
current evidence. If changed device/lifetime paths require physical evidence
under a governing contract, record the dependency and obtain separate connected
action authorization. Leave the criterion unmet until that evidence or a specific
human exception exists. Prior MVP exceptions do not cover new regressions or the
second consumer automatically.

## Dependencies and Open Questions

The outcomes, consumer, extension level and evidence matrix are bounded; there
are no remaining scope-selection blockers. Downstream gates remain explicit:

- Exact package/products and narrow transitive external access/compatibility
  surface; review ADR-008 and affected Specs rather than making all SPI public.
- Whether reuse needs a new core module or exposure/extraction of existing owners.
  Keep common contracts distinct from rendering-family-specific helpers.
- Precise application descriptor, finite Static specialization/storage producer,
  custom assembly/service-loop shape, supported build routes and structured errors.
  Consumer-specific adaptation must meet IT-AC-003; general generation is excluded.
- One immutable configuration across host/backend/display, preserving capabilities
  versus health, one-shot handoff, input provenance and typed failure policy.
- Measured resource ceilings agreed before contract approval and implementation.
- Refresh active Iteration 2 inputs and resolve overlap before restructuring;
  performance/connected gaps remain visible without another generic audit.

Preparation baseline/study and draft PROPOSAL-007 are now recorded. Next obtain
Proposal acceptance and continue the bounded full-consumer feasibility study;
the initial declaration/access probes do not establish complete host execution.
The original MVP Proposal and scope approval do not approve new external
architecture or contracts.

## Deferred and Follow-up Work

| Item | Current boundary / revisit trigger |
| --- | --- |
| [FW-016](../future-work/fw-016-post-mvp-package-distribution-topology.md), [FW-030](../future-work/fw-030-application-integration-experience.md), [EXP-002](../explorations/exp-002-backend-and-application-integration-shapes.md) | Sources for selected outcomes now feed draft PROPOSAL-007 through reciprocal promotion links. Acceptance and downstream architecture/contract gates remain separate. |
| [FW-006](../future-work/fw-006-generated-target-configuration.md), [FW-009](../future-work/fw-009-shared-delegated-service-foundation.md) | General generator/services excluded. Revisit when the bounded consumer shows residual repeated configuration or multiple approved consumers need shared service contracts. |
| [FW-022](../future-work/fw-022-contract-accurate-embedded-target-simulator.md), [EXP-002 direction comparison](../explorations/exp-002-backend-and-application-integration-shapes.md#sensitivity-to-possible-future-directions--2026-10-05) | Fixtures do not commit simulation, IR/ABI, migration or a core rewrite. Revisit the recorded questions when a concrete simulation, analysis or second-frontend consumer is selected. |
| [FW-027](../future-work/fw-027-pi-performance-investigation-resumption.md), [FW-032](../future-work/fw-032-nrf-performance-improvement.md), [FW-031](../future-work/fw-031-macos-connected-pointer-validation-resumption.md), [FW-033](../future-work/fw-033-connected-validation-follow-up.md) | Performance/full connected validation retain their existing triggers. Changed-path checks remain current obligations where required by contracts. |

## Revision and Approval History

| Revision | Date | Change / reason | Maintainer approval |
| --- | --- | --- | --- |
| 1 | 2026-10-04 | Initial candidates; backend/integration coordination added on 2026-10-05 without approval. | Pending; discussion/inventory/alignment only. Preserved in commit `232f0041`. |
| 2 | 2026-10-05 | Select coordinated outcomes, consumer/extension level, four-profile matrix, measurable setup improvement, compatibility/documentation criteria, gates and deferrals. | Eugene explicitly requested review, alignment, gap filling, then approval and commit. [Exact instruction and review](iteration-003-review/scope-review-and-approval.md). |

## Closure and Follow-up

Preparation is recorded under EXP-002; major implementation has not started.
The scope remains `status: approved` and
`closure: null` remain. At closure, disposition IT-AC-001–005 as met, unmet or
an explicitly approved exception with immutable evidence, remaining gates,
deferred triggers and the maintainer's closure decision. Architecture/Spec
approval and implemented transitions remain separate.

## References

- [Scope review and approval](iteration-003-review/scope-review-and-approval.md)
- [EXP-002](../explorations/exp-002-backend-and-application-integration-shapes.md) and [backend inventory](../explorations/exp-002/backend-foundation-inventory-2026-10-05.md)
- [ITERATION-002](iteration-002-cleanup.md) — active cleanup dependency
- [ADR-006](../adrs/adr-006-shared-semantics-runtime-profiles.md), [ADR-007](../adrs/adr-007-integration-ownership-and-host-composition.md), [ADR-008](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
- [SPEC-002](../specs/spec-002-portable-foundation.md), [SPEC-013](../specs/spec-013-runtime-profiles.md), [SPEC-014](../specs/spec-014-backend-integration.md), [SPEC-015](../specs/spec-015-host-configuration.md)
- Discussion provenance: “Assess a Core Backend Framework” (`01a0fd58-87e8-79c1-81be-b0aab9e5cc76`) and “Simplify GiftUI Backend Integration” (`01a0fd59-dd59-71f2-bf32-d42c617c8705`).
