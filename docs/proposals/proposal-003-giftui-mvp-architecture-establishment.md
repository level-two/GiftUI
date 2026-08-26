---
id: PROPOSAL-003
feature: giftui-mvp-architecture
title: GiftUI MVP Architecture Establishment
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-13
updated: 2026-08-26
proposal: []
related_rfcs:
  - RFC-002
  - RFC-007
  - RFC-003
  - RFC-004
  - RFC-005
  - RFC-010
related_adrs:
  - ADR-005
  - ADR-006
  - ADR-007
  - ADR-008
  - ADR-009
  - ADR-010
  - ADR-011
  - ADR-012
  - ADR-013
  - ADR-014
  - ADR-015
  - ADR-016
  - ADR-021
  - ADR-022
  - ADR-023
related_specs:
  - SPEC-002
  - SPEC-003
  - SPEC-005
  - SPEC-006
  - SPEC-007
  - SPEC-008
supersedes: []
superseded_by: []
target_milestone: MVP
---

# PROPOSAL-003: GiftUI MVP Architecture Establishment

## Summary

GiftUI should establish an explicit, reviewed architecture for the MVP before
the existing proof of concept is migrated or substantial framework feature
work proceeds. The resulting authority should give later feature and migration
work a stable destination while remaining limited by the Signal Analyzer and
the four MVP validation configurations.

## Problem

GiftUI already has a working proof-of-concept baseline spanning declarative
composition, layout, rendering, state, interaction, and several platform
paths. That implementation contains valuable evidence, but it does not by
itself establish which responsibilities, dependencies, and portability
boundaries the maintained framework should preserve.

Without an explicit architecture lifecycle, later work could preserve
accidental proof-of-concept coupling, make incompatible choices independently,
or allow desktop assumptions to harden before static, Linux, and embedded
constraints are evaluated. Specifications would then have to invent or infer
architecture instead of expressing reviewed contracts.

## Motivation

Architecture establishment is the first delivery milestone because every
subsequent MVP milestone depends on a coherent destination for migration and
feature work. The Signal Analyzer requires composition, layout, rendering,
observable state, input, and custom drawing to work together through a
substantially shared presentation across macOS dynamic, macOS static,
Raspberry Pi/Linux dynamic, and nRF52840 static configurations.

Those concrete application and stack-validation requirements make this work
necessary now. Establishing the relevant architectural authority before
migration reduces the risk that existing implementation details or the first
new feature silently determine cross-cutting framework choices.

## Users / Use Cases

- GiftUI maintainers need a reviewable basis for deciding which parts of the
  proof of concept to adopt, adapt, replace, retire, or defer.
- Framework contributors need stable architectural authority before drafting
  implementation Specifications for MVP features.
- Swift application developers need the eventual GiftUI framework to preserve
  a familiar portable presentation model across the MVP environments.
- Platform and backend contributors need platform, display, and hardware
  differences to remain representable without leaking them into portable
  Signal Analyzer presentation code.

## Goals

- Authorize architectural exploration for the GiftUI MVP through the governed
  RFC and ADR process.
- Establish reviewed authority sufficient to guide proof-of-concept
  disposition, migration, and later MVP Specifications.
- Evaluate all cross-cutting concerns required by the Signal Analyzer and the
  four MVP validation configurations together rather than in isolation.
- Make static and embedded viability, backend independence, explicit
  capabilities, resource cost, and compatibility first-order evaluation
  criteria.
- Preserve useful proof-of-concept knowledge as evidence without granting the
  current implementation implicit architectural authority.

## Non-goals

- Select a specific architecture, module graph, ownership model, API, type, or
  backend contract in this Proposal.
- Authorize framework migration or implementation work.
- Ratify the current proof-of-concept structure or behavior.
- Design application-domain concerns such as signal acquisition, persistence,
  or hardware sampling.
- Establish a comprehensive capability catalogue or speculative support for
  backends and features outside MVP scope.
- Reproduce SwiftUI architecture or guarantee SwiftUI source compatibility.

## Constraints

- Architectural exploration MUST remain traceable to the Signal Analyzer or
  validation of an MVP target configuration.
- The result MUST support substantially shared portable presentation concepts
  across macOS dynamic, macOS static, Raspberry Pi/Linux dynamic, and nRF52840
  static configurations.
- Platform-specific hosting is permitted at the application boundary;
  platform-, backend-, and hardware-specific framework details MUST remain
  outside portable presentation code.
- Static and constrained embedded requirements MUST be evaluated during
  architecture work, not deferred until after a desktop design is established.
- Memory use, binary size, runtime overhead, implementation complexity, and
  compatibility MUST be considered alongside API familiarity.
- Existing code, tests, examples, and platform paths MAY supply evidence but
  MUST NOT substitute for lifecycle approval.
- Acceptance of this Proposal authorizes RFC work only. Major implementation
  still requires accepted ADRs and approved Specifications.

## Success Criteria

- An architecture RFC evaluates the MVP's cross-cutting responsibilities,
  constraints, alternatives, trade-offs, costs, compatibility, and validation
  strategy against the Signal Analyzer and all four target configurations.
- The RFC explicitly records how proof-of-concept modules, tests, examples,
  and target paths informed the analysis without treating them as the default
  decision.
- Every architecturally significant choice required for downstream contracts
  is extracted into an accepted ADR, with unresolved matters kept out of
  Specifications until decided.
- Downstream Specifications can define MVP feature, infrastructure, and
  migration contracts without inventing layer, ownership, capability,
  backend, platform, or static/dynamic architecture.
- Roadmap milestones can trace their implementation prerequisites to the
  resulting accepted decisions and approved Specifications.

## Scope

The architectural exploration covers the cross-cutting framework concerns
needed to deliver the MVP: declarative client concepts; view and state
representation and update propagation; layout; drawing and rendering;
interaction and event dispatch; backend-independent behavior; backend,
platform, and hardware integration boundaries; static and dynamic
configurations; capability placement and propagation; and the cost and
compatibility implications of those concerns.

The Proposal establishes why these concerns must be resolved together. Their
detailed boundaries, relationships, interfaces, alternatives, and decisions
belong in downstream RFCs and ADRs.

## Risks

- The breadth of cross-cutting concerns could produce an oversized RFC;
  review should retain one coherent MVP architecture while extracting
  independently significant decisions into focused ADRs.
- Existing working code may bias exploration toward accidental structures or
  behaviors that do not satisfy the maintained framework's constraints.
- Desktop evidence may obscure static or embedded costs unless every candidate
  is evaluated against the complete validation progression.
- Speculative future flexibility may increase complexity beyond what the
  Signal Analyzer and MVP configurations justify.
- Architecture work may reveal that some proof-of-concept areas require
  replacement, increasing migration cost after the direction is accepted.

## Open Questions

None at the Proposal level. The architecture, alternatives, and trade-offs are
intentionally left to the RFC process; acceptance of this Proposal does not
prejudge them.

## Impact of Acceptance

Acceptance authorizes creation and review of the GiftUI MVP architecture RFC.
It does not approve architecture, contracts, proof-of-concept disposition, or
implementation. Those remain subject to their RFC, ADR, Specification, and
conformance gates.

## References

- [PROPOSAL-001: GiftUI MVP Baseline Charter](proposal-001-giftui-mvp-baseline-charter.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [MVP Milestones](../roadmap/MVP_MILESTONES.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [Documentation Inventory](../engineering/DOCUMENT_INVENTORY.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md)
