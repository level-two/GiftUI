---
id: PROPOSAL-007
feature: external-application-integration
title: External Application and Backend Integration
status: draft
authors:
  - codex
created: 2026-10-05
updated: 2026-10-05
proposal: []
related_rfcs: []
related_adrs:
  - ADR-006
  - ADR-007
  - ADR-008
  - ADR-010
  - ADR-033
related_specs:
  - SPEC-002
  - SPEC-009
  - SPEC-012
  - SPEC-013
  - SPEC-014
  - SPEC-015
related_future_work:
  - FW-016
  - FW-030
related_explorations:
  - EXP-002
related_spikes:
  - SPIKE-014
supersedes: []
superseded_by: []
target_milestone: ITERATION-003
---

# PROPOSAL-007: External Application and Backend Integration

Draft investment proposal prepared under approved
[ITERATION-003 revision 2](../iterations/iteration-003-dev-ux-improvement.md).
It does not select package names, public APIs, an additional backend module,
assembly factories or a generation strategy. Human acceptance is pending.

## Summary

Enable an application outside GiftUI's distribution packages to select and use
framework/runtime, rendering and platform/display components through supported
interfaces and build routes. Enable a display-adapter author to reuse the same
backend machinery through the application's integration path. Evaluate these
outcomes together so package access, backend construction and application setup
form one usable experience while retaining their existing semantic owners.

## Problem

The MVP delivered Signal Analyzer on four stacks, with recorded exceptions,
but that application is also the privileged composition and build environment.
An outside developer cannot currently consume its complete host/backend path
through independently supported products and external contracts.

The [refreshed baseline](../explorations/exp-002/preparation-2026-10-05/README.md)
and [SPIKE-014](../spikes/spike-014-external-consumer-access-baseline.md) show:

- The current manifest has 13 products and 84 targets. Eight inspected
  runtime/surface/raster/display/backend/host modules have no direct library
  product. Products alone also would not expose their package-scoped contracts.
- A distinctly named consumer can compile the small portable declaration with
  native Swift and the actual Embedded compiler. The same consumer cannot name
  `DisplayTarget` or `HostPresetBootstrap` through those module boundaries.
- Host workload/configuration and firmware source/storage bindings remain tied
  to Signal Analyzer. A separate application has no demonstrated supported
  launch path, and the developer would encounter internal construction and
  adaptation requirements before reaching application behavior.
- Backend raster/session/endpoint and validation machinery is already shared
  between Pi and nRF. The missing experience concerns external reuse, supported
  construction and application-independent inputs, rather than a missing raster
  implementation.

These are source and bounded compiler observations. No complete second consumer,
paired setup reduction or assembled consumer resource result is established.

## Motivation

This is post-MVP work, selected by the maintainer in ITERATION-003. It advances
GiftUI's vision of application code focusing on UI/state/interaction and its
principles of backend independence, first-class Embedded support and explicit
costs. A second bounded application tests whether the existing framework can
be consumed without inheriting the reference application's infrastructure.

Iteration 2 supplies cleanup of the current owners and build/generation paths.
Its current 74-check final hardware-free packet passed during this preparation;
the Pi connected dependency and human closure remain open. Refresh that evidence
before restructuring overlapping owners. This is not a new ITERATION-001 need.

## Users / Use Cases

- An application developer brings portable views, observable state, finite
  actions, resources/workload and policy, selects supported components, and
  builds a working application without copying analyzer infrastructure.
- A display/transport adapter developer replaces the selected display through
  the same application assembly path, reusing existing software raster support.
- An Embedded integrator needs finite storage, predictable diagnostics,
  supported cross-build inputs and auditable linked resource costs.
- A maintainer needs independent consumption tests, bounded migration work and
  evidence that Signal Analyzer and existing owner semantics remain intact.

## Goals

- Deliver focused, independently useful consumption packages within the same
  repository, using the bounded consumer to justify their interfaces.
- Reuse existing backend foundation contracts and implementations through a
  narrow supported extension surface and minimal recording-adapter example.
- Reduce application-owned setup and build/lifecycle infrastructure using a
  documented supported integration path, including a customization route.
- Preserve shared portable presentation, profile-equivalent behavior, typed
  failures, explicit resources/configuration and bounded Static execution.
- Make selected component facts, assumptions, consumer responsibilities,
  diagnostics and migration/compatibility expectations discoverable.

## Non-goals

- Separate repositories, independent release/version pipelines or registry
  publishing; one package per logical module.
- New hardware backends, GPU/non-raster realization, universal backend base,
  wholesale raster replacement or changes to portable UI features.
- General configuration generation, arbitrary application lowering, replacement
  of the packed Static runtime, runtime discovery or shared global services.
- Simulator, frontend-neutral IR/ABI, non-Swift core, import/migration tooling,
  adaptive UI or mixed foreign/native composition.
- Connected deployment/flashing, performance optimization or closing all prior
  physical-input/pixel/timing conformance gaps.

## Constraints

- Existing accepted ADRs and implemented Specs remain authoritative until
  necessary successors/amendments pass their own gates. In particular, package
  topology, SPI visibility and host workload contracts cannot change implicitly.
- Preserve `GiftUI` as the portable declaration import; platform/renderer/runtime
  selection remains at host composition. Packaging cannot merge semantic owners.
- Preserve equivalent identity, state/action meaning, layout, operation order,
  failure/publication and one-shot handoff behavior across profiles. Display
  delivery and input/scheduling remain separate responsibilities.
- Static operation must remain finite and zero-heap under current constraints;
  finite consumer adaptation and all generated/manual inputs must be explicit.
- Validate macOS Dynamic/Static, Raspberry Pi 1 ARMv6 Dynamic and nRF52840-DK
  Embedded Static with supported project-local toolchains. A host rehearsal is
  not actual target compilation or connected-device evidence.
- Define measured consumer ceilings before implementation. Existing application
  resource limits and exceptions do not automatically establish new consumer
  limits or waive new failures.

## Success Criteria

| ID | Observable outcome | Iteration trace |
| --- | --- | --- |
| EI-001 | The bounded outside consumer selects focused packages with no analyzer-owner dependency, copied framework source lists or privileged package access; presentation imports only `GiftUI`. | IT-AC-001 |
| EI-002 | A minimal external recording display adapter uses existing foundation support through the same host path without copied endpoint/session/raster state machines. | IT-AC-002 |
| EI-003 | Each target's setup requires fewer manual actions and user-maintained infrastructure files than its reproduced control, with no copied analyzer infrastructure or handwritten framework storage offsets. Count generated inputs and hidden prerequisites. | IT-AC-003 |
| EI-004 | Consumer and Signal Analyzer preserve governing semantics, lifecycle/failure behavior, dependency direction and resource guarantees across the four required configurations, with current identified evidence. | IT-AC-004 |
| EI-005 | Application and adapter guides explain setup, responsibilities, customization, diagnostics, migration and compatibility; every outcome has an explicit evidence-based disposition. | IT-AC-005 |

The [consumer study](../explorations/exp-002/preparation-2026-10-05/consumer-study.md)
defines the bounded behavior, observations and measurement protocol. A blocked
current host path is not a zero-step baseline; a reproducible equivalent control
must precede numerical improvement claims. Architecture/Spec work will refine
exact contracts while retaining these product outcomes.

## Scope

Affected areas are distribution/access, reusable backend construction and
adapter support, application-independent host/build integration, documentation,
and compatibility/evidence tooling. The small counter/status application, Canvas
variant and recording adapter supply one shared evaluation vehicle. Signal
Analyzer remains the nontrivial regression consumer.

Package/API names, additional modules, assembly forms, finite Static producers
and tool interfaces remain architectural alternatives. Upon acceptance, compare
them as the smallest coherent decision cluster; use separate RFCs only for
independently reviewable concerns, not merely for each package or row.

## Risks

- Exposure of transitive internal types could enlarge the compatibility burden
  without giving consumers a simpler contract.
- A desktop convenience path may fail under Embedded specialization or impose
  excessive flash/RAM/stack costs. Early actual compiler evidence is essential.
- Shorter bootstrap syntax can hide prerequisites or move manual work into
  generators; measure the complete developer workflow.
- Fixed workload/resource bindings could be mistaken for general lowering.
  Bound the example and preserve application-owned inputs and diagnostics.
- Concurrent cleanup source/generation changes can stale the comparison.
  Match source/toolchain/configuration identities before claiming improvement.

## Open Questions

- Which focused consumption units and external compatibility policy satisfy
  the selected users without forcing internal owner details into their code?
- Which finite Static binding/storage inputs are required for the complete
  observable-state/Canvas consumer, and what remains application-maintained?
- What reviewed resource ceilings are appropriate after a matched consumer
  control is built? Current analyzer totals are comparison evidence only.
- Can supported and custom assembly share lifecycle/configuration support
  while fitting an application-owned event loop and documented sample runner?

These are evidence/design questions for later gates; the investment problem,
users and bounded outcomes are ready for consideration. Feasibility failure
requires an explicit scope disposition, not silent reduction of the commitment.

## Deferred and Follow-up Work

FW-016 and FW-030 now feed this Proposal with reciprocal promotion links;
EXP-002 remains active while supplying preparation evidence. Their promotion is
not Proposal acceptance. SPIKE-014 remains an evidence-only compile/access study.

General generation and services remain with
[FW-006](../future-work/fw-006-generated-target-configuration.md) and
[FW-009](../future-work/fw-009-shared-delegated-service-foundation.md); simulation
remains with [FW-022](../future-work/fw-022-contract-accurate-embedded-target-simulator.md).
The [EXP-002 direction comparison](../explorations/exp-002-backend-and-application-integration-shapes.md#sensitivity-to-possible-future-directions--2026-10-05)
retains IR/frontend/core-rewrite questions. Revisit only for a selected concrete
consumer or demonstrated residual need. Existing performance/connected follow-up
under FW-027/031/032/033 is not added to this investment.

## References

- [GiftUI Vision](../VISION.md), [Principles](../PRINCIPLES.md), [MVP scope](../iterations/iteration-001-mvp.md)
- [ITERATION-003](../iterations/iteration-003-dev-ux-improvement.md)
- [Preparation baseline and triage](../explorations/exp-002/preparation-2026-10-05/README.md)
- [Consumer study](../explorations/exp-002/preparation-2026-10-05/consumer-study.md)
- [FW-016](../future-work/fw-016-post-mvp-package-distribution-topology.md), [FW-030](../future-work/fw-030-application-integration-experience.md)
- [EXP-002](../explorations/exp-002-backend-and-application-integration-shapes.md), [SPIKE-014](../spikes/spike-014-external-consumer-access-baseline.md)
