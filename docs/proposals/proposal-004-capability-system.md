---
id: PROPOSAL-004
feature: capability-system
title: GiftUI Capability System
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-22
proposal: []
related_rfcs:
  - RFC-002
  - RFC-006
related_adrs:
  - ADR-017
  - ADR-018
  - ADR-019
  - ADR-020
related_specs:
  - SPEC-004
supersedes: []
superseded_by: []
target_milestone: MVP
---

# PROPOSAL-004: GiftUI Capability System

## Summary

GiftUI should establish an explicit capability system so one portable UI model
can remain useful across dynamic desktop and Linux environments, static
builds, constrained embedded runtimes, different rendering backends, and
materially different display and input hardware.

The system should let an assembled GiftUI configuration state what behavior it
can provide and under which relevant constraints. Framework and application
code should then be able to respond deliberately to supported, constrained,
optional, accelerated, or unavailable behavior without inferring those facts
from a platform name or scattering hardware-specific conditions through
portable code.

## Problem

GiftUI targets environments whose facilities differ in more than operating
system name. A dynamic framebuffer stack may have heap allocation and a full
pixel buffer, while a static microcontroller stack may use bounded storage and
write directly to a display. A behavior absent in hardware may still be
provided in software, and a nominally supported behavior may have limits that
matter to correctness or resource use.

Without a coherent capability system, each feature or backend must discover
and interpret these differences independently. That creates several risks:

- portable UI code may depend on platform, backend, or device identity;
- compile-time conditions may become an informal and inconsistent capability
  model;
- a hardware facility may be confused with the semantic behavior it can
  accelerate;
- invalid configurations may fail late or silently provide different
  semantics;
- dynamic and static stacks may expose separate client models;
- new backends and devices may require invasive changes instead of supplying
  their own constraints through established framework boundaries.

These outcomes would undermine GiftUI's central value: a familiar declarative
model that remains configurable and useful across very different execution and
hardware environments without hiding meaningful differences.

## Motivation

The capability system is required now by both the Signal Analyzer reference
application and the MVP stack-validation matrix. The same portable Signal
Analyzer presentation must execute on macOS dynamic, macOS static, Raspberry
Pi/Linux dynamic, and nRF52840 static configurations. Those configurations
differ in runtime facilities, resource bounds, rendering paths, input
integration, display hardware, and opportunities for software or hardware
realization.

The MVP scope therefore requires GiftUI to establish the architectural place
and propagation model for capabilities and to demonstrate at least one real
capability difference without leaking platform- or backend-specific decisions
into portable application code. This work is also necessary before later
capability-intensive features can be designed consistently.

Investing in the feature during MVP prevents the first maintained backend or
desktop runtime from becoming an implicit universal profile. It also provides
an evidence-based way to validate that GiftUI's configurability is a framework
property rather than a collection of target-specific forks.

## Users / Use Cases

- Application developers need to write substantially shared GiftUI
  presentation code while preserving explicit behavior when a target cannot
  provide a requested feature.
- Target integrators need to assemble a runtime, backend, platform adapters,
  and hardware while determining whether the resulting configuration can
  support the application correctly.
- Backend and device contributors need to describe relevant behavior and
  constraints without exposing concrete implementation identity to portable
  views.
- Embedded developers need unsupported facilities and resource assumptions to
  be excluded or rejected without requiring allocation-heavy runtime
  discovery.
- Maintainers and test authors need supported configurations to be
  inspectable, reproducible, and testable across the four MVP environments.
- The Signal Analyzer needs all required composition, layout, opaque
  rendering, text, drawing, state, timing, and input behavior to be available
  in every configuration that claims conformance, even when the underlying
  realization differs.

## Goals

- Make capability differences explicit across runtime profiles, framework
  facilities, backends, platforms, transports, displays, input devices, and
  concrete target configurations.
- Preserve one portable client programming model wherever the required
  semantic behavior can be provided conformingly.
- Represent relevant restrictions and limits as well as simple availability.
- Distinguish application-visible behavior from the software or hardware path
  used to realize or accelerate it.
- Define deliberate behavior for required, optional, constrained, and
  unavailable functionality rather than allowing silent semantic drift.
- Support both static and dynamic configuration without making either model a
  secondary compatibility path.
- Allow unsupported implementation families to remain outside constrained
  builds when required for memory, binary-size, safety, or runtime reasons.
- Make the effective behavior of a supported configuration deterministic,
  inspectable, and testable.
- Establish a bounded MVP foundation that later features can extend from
  concrete requirements.

## Non-goals

- Define a comprehensive catalogue for every possible GiftUI feature,
  backend, display controller, transport, or board.
- Implement speculative capabilities such as shadows, alpha compositing,
  advanced transforms, or hardware scrolling unless an MVP requirement needs
  them.
- Select package boundaries, concrete Swift types, public APIs, configuration
  file formats, code-generation tools, or capability-resolution algorithms in
  this Proposal.
- Require every capability to use one representation or to be decided at the
  same build or runtime phase.
- Guarantee that every GiftUI API is available, equivalent, or silently
  approximated on every target.
- Hide meaningful resource, hardware, or behavioral constraints from
  developers and integrators.
- Authorize capability-system implementation or migration of the existing
  proof of concept.

## Constraints

- MVP capability work MUST trace to the Signal Analyzer or validation of one
  of the four supported stack configurations.
- The MVP implementation MUST remain limited to capabilities actually needed
  to admit and validate those configurations.
- Portable presentation code MUST NOT infer capabilities from operating-system,
  backend, board, or device identity.
- A configuration MUST NOT claim Signal Analyzer conformance when required
  behavior is absent or violates its contract.
- Capability handling MUST preserve GiftUI semantics across different valid
  realizations; acceleration alone MUST NOT define whether a semantic feature
  exists.
- Static and embedded configurations MUST be viable without assuming heap
  allocation, reflection, unrestricted existential use, unbounded storage, or
  runtime facilities unavailable to Embedded Swift.
- Memory, binary size, execution cost, transfer cost, and diagnostic cost MUST
  be considered alongside configurability and API familiarity.
- Capability architecture MUST conform to accepted GiftUI layering decisions
  and MUST NOT create upward dependencies from portable framework code to
  concrete backends, platforms, drivers, operating systems, RTOS facilities,
  or hardware abstraction layers.
- Acceptance of this Proposal authorizes architectural exploration only.
  Major implementation still requires accepted ADRs and approved
  Specifications.

## Evidence and Assumptions

Observed project evidence includes the established four-configuration MVP
matrix, the requirement for substantially shared Signal Analyzer presentation,
and existing proof-of-concept stacks with different runtime, rendering,
storage, platform, and hardware characteristics. The GiftUI principles also
explicitly require capabilities, embedded constraints, backend independence,
and resource costs to influence the design.

This Proposal assumes that more than one valid implementation may sometimes
provide the same application-visible behavior, and that some relevant facts
are constraints or quantities rather than Boolean support flags. These
assumptions must be tested during RFC work rather than treated as accepted
architecture.

## Success Criteria

- Each of the four MVP configurations can declare and expose the capability
  information required to determine whether it supports the Signal Analyzer.
- The same assembled configuration produces the same effective capability and
  policy result in diagnostics and tests.
- At least one genuine difference between two MVP configurations is handled
  without platform, backend, or hardware identity checks in portable Signal
  Analyzer presentation code.
- Required Signal Analyzer behavior is either provided conformingly or causes
  the configuration to be rejected before presentation begins where the
  target permits that validation.
- Tests demonstrate that the same required semantic behavior may be supplied
  through different valid realization paths without changing the portable
  application contract.
- Static validation demonstrates bounded behavior and absence of dependencies
  on unavailable dynamic-runtime facilities.
- Diagnostics or test fixtures can explain the effective support, relevant
  constraints, and selected policy for every capability exercised by MVP.
- The MVP capability catalogue contains no entries that lack a Signal Analyzer
  or supported-configuration validation requirement.
- Downstream feature Specifications can state capability requirements,
  absence behavior, and validation expectations without introducing new
  cross-layer architecture.

## Scope

The feature covers the framework-wide concept of capability contribution,
composition, propagation, consumption, absence behavior, policy interaction,
diagnostics, and validation for supported GiftUI configurations. It includes
the relationship between application-visible semantics and alternative
software or hardware realizations, and it includes both build-time and runtime
constraints where the MVP configurations require them.

For MVP, the concrete catalogue is restricted to facts needed by the Signal
Analyzer and its four validation configurations. Candidate entries, ownership,
representations, combination rules, and enforcement phases belong in an RFC
and subsequent accepted ADRs and approved Specifications.

## Risks

- A broad capability catalogue could become speculative and impose binary,
  memory, testing, and maintenance cost before features need it.
- Excessive compile-time specialization could create difficult type surfaces,
  long builds, or a combinatorial configuration matrix.
- Excessive runtime representation could retain unavailable code and impose
  unacceptable storage or discovery costs on embedded targets.
- Treating capabilities as Boolean flags could discard limits that determine
  whether an implementation is correct or affordable.
- Automatic fallback could conceal semantic changes or unacceptable resource
  cost if behavior and policy are not separated clearly.
- Backend-centric capability reporting could misrepresent behavior supplied by
  another part of the assembled stack.
- Capability work could duplicate or prematurely freeze unresolved decisions
  in the broader GiftUI layered-architecture RFC.

## Open Questions

- Which concrete differences among the four MVP configurations form the
  minimum capability set needed for Signal Analyzer admission and validation?
- Which application-visible behaviors may vary by explicit policy, and which
  must be identical or cause configuration rejection?
- Which capability facts must be fixed by the build, which may be established
  during target composition or initialization, and which may change during
  execution?
- What diagnostic detail is required for developers and conformance tests
  without imposing unacceptable embedded cost?
- After the broader layered architecture is approved and its decisions are
  extracted, does this feature require a focused RFC or can its remaining
  design be handled through explicitly linked follow-on decisions and
  Specifications?

## Impact of Acceptance

Acceptance authorizes focused architecture work for the Capability System
within the boundaries established by the GiftUI MVP architecture. It does not
approve the architectural mechanisms proposed in legacy material. Those
mechanisms require their own RFC approval, ADR acceptance, and Specification
approval gates; this Proposal does not authorize public APIs, package changes,
implementation, or claims of configuration conformance.

## References

- [PROPOSAL-001: GiftUI MVP Baseline Charter](proposal-001-giftui-mvp-baseline-charter.md)
- [PROPOSAL-002: Signal Analyzer Reference Application](proposal-002-signal-analyzer-reference-application.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md) — approved design consensus extracted into accepted ADRs
- [RFC-006: GiftUI Capability System Architecture](../rfcs/rfc-006-capability-system-architecture.md) — approved design consensus extracted into accepted ADRs
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [MVP Milestones](../roadmap/MVP_MILESTONES.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md) — legacy implementation and design provenance
