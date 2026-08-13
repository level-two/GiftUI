---
id: PROPOSAL-001
feature: giftui-mvp-baseline
title: GiftUI MVP Baseline Charter
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-13
updated: 2026-08-13
proposal: []
related_rfcs: []
related_adrs: []
related_specs: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# PROPOSAL-001: GiftUI MVP Baseline Charter

## Summary

GiftUI should pursue a focused MVP that proves Swift developers can build one
meaningful interactive application with a substantially shared,
SwiftUI-inspired presentation across desktop, Linux, and constrained embedded
environments. The MVP should favor a convincing end-to-end result over broad
framework coverage.

## Problem

Swift developers outside Apple's UI ecosystem lack a familiar declarative UI
model that spans desktop development, Linux framebuffer systems, and
resource-constrained embedded targets. A collection of isolated controls or
platform demos would not prove that a coherent framework can preserve one
application-level model across those environments.

## Motivation

The central GiftUI idea contains several linked uncertainties: whether a
familiar declarative model remains practical under static and embedded
constraints, whether materially different renderers and hardware can support
the same application concepts, and whether portability can be achieved
without concealing meaningful platform differences. Building a broad API
surface before testing those assumptions would create substantial design and
implementation cost without demonstrating that the framework works as a
whole.

A deliberately narrow but non-trivial application provides a concrete way to
learn. It forces composition, layout, rendering, state, interaction, custom
drawing, platform integration, and constrained execution to work together.

## Target User and Use Case

The primary user is a Swift developer building an interactive UI for Linux or
embedded hardware who wants familiar declarative composition without hiding
real platform constraints. The representative use case is a low-frequency
Signal Analyzer: a stateful application with controls, status, layout, and
data-driven waveform rendering. It can be developed rapidly on macOS and then
exercised under static, Linux framebuffer, and embedded hardware constraints.

## Suggested Direction

Use the Signal Analyzer as the MVP's definition of “enough GiftUI.” Build the
smallest coherent framework surface needed to express that application, then
prove the substantially shared presentation on macOS dynamic, macOS static,
Raspberry Pi/Linux with a framebuffer display, and nRF52840 with a TFT
display. Allow target-specific hosting and hardware integration while keeping
those concerns out of the portable presentation.

## Key Assumptions

- One non-trivial reference application is a better MVP test than broad but
  shallow API coverage.
- The Signal Analyzer exercises enough composition, layout, rendering, state,
  interaction, and drawing to test GiftUI as an application framework.
- Portable presentation code can remain substantially shared while legitimate
  hosting, backend, platform, and hardware integration stays target-specific.
- Embedded and static constraints must shape MVP boundaries from the outset.
- The existing proof-of-concept is useful evidence and migration input, but is
  not authority for architecture or contracts.

## Goals

- Prove the central GiftUI hypothesis through a coherent working Signal
  Analyzer across desktop, Linux, and constrained embedded configurations.
- Demonstrate a familiar declarative client model that keeps portable
  presentation code independent of renderer and hardware details.
- Validate dynamic, static, Linux/framebuffer, and constrained embedded use
  through actual builds and execution.

## Non-goals

- Reproduce the complete SwiftUI API or guarantee source compatibility.
- Build features, backends, or capabilities without a need demonstrated by
  the reference application or its validation environments.
- Create a general-purpose graphics or styling system.
- Define signal acquisition, persistence, or other application-domain
  architecture.
- Make legitimate platform hosting and hardware integration code portable.

## Constraints

- Static and embedded viability must be tested during the MVP rather than
  treated as a future port.
- Resource cost, binary size, runtime overhead, and implementation complexity
  matter alongside API familiarity.
- Portable application concepts must not depend on one renderer, operating
  system, or display technology.
- The framework surface must remain limited to what the end-to-end proof
  requires.

## Major Trade-offs

- Depth on one cross-platform application is preferred over breadth of API
  surface.
- Early static and embedded validation adds delivery cost but reduces the risk
  of discovering incompatible assumptions after a desktop-first design hardens.
- A narrow MVP drawing and styling surface limits immediate generality in
  exchange for lower memory, binary-size, runtime, and implementation cost.
- Substantially shared presentation is required, while target-specific hosting
  and integration are accepted where portability would obscure meaningful
  platform differences.
- Existing implementation may accelerate delivery, but lifecycle review and
  approved contracts take precedence over preserving proof-of-concept design.

## Success Criteria

- The Signal Analyzer works as one coherent interactive application rather
  than a collection of framework demonstrations.
- Its presentation is substantially shared across macOS dynamic, macOS
  static, Raspberry Pi/Linux with a framebuffer display, and nRF52840 with a
  TFT display.
- The application demonstrates composition, layout, rendering, observable
  state, input, disabled interaction, and data-driven waveform drawing.
- Platform-, renderer-, and hardware-specific concerns remain outside the
  portable presentation except for legitimate application hosting.
- Static, dynamic, Linux, and embedded claims are supported by actual builds
  and execution; required hardware claims are supported on connected hardware.
- The result is credibly an application built with GiftUI, not separate
  platform applications behind a superficial common facade.

## Scope

The rough scope is the declarative client surface and supporting framework work
needed for the Signal Analyzer: composition, layout, basic rendering, state,
interaction, narrow custom drawing, and enough platform integration to run in
the four representative configurations. Detailed feature lists, architecture,
APIs, sequencing, and validation procedures belong in downstream artifacts.

## Impact of Acceptance

- **Scope impact:** Constrains the MVP to the Signal Analyzer and the framework
  and target-stack work necessary to prove it.
- **Roadmap impact:** Calls for incremental validation from a fast desktop
  environment through static, Linux/framebuffer, and embedded environments.
- **Milestone impact:** Makes the coherent cross-platform application and real
  target execution the completion outcome.
- **Documentation impact:** Requires downstream scope, roadmap, architecture,
  and contract documents to preserve this focus without duplicating the
  proposal's rationale.

Acceptance authorizes architectural exploration. It does not approve
architecture, contracts, or implementation. A material change to the problem,
users, expected outcome, or boundaries requires explicit lifecycle review and
may require a new Proposal.

## Risks

- The reference application may not expose every future framework need; those
  needs are intentionally deferred until supported by concrete use cases.
- Cross-stack validation may reveal incompatible assumptions late despite the
  staged milestone order.
- Hardware availability can delay final evidence even when host and
  hardware-free checks pass.

## Open Questions

None for acceptance of this charter. Detailed architecture, contracts, and
delivery sequencing remain decisions for their appropriate downstream
artifacts.

## References

- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
