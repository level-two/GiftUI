---
id: PROPOSAL-002
feature: signal-analyzer
title: Signal Analyzer Reference Application
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-13
updated: 2026-08-14
proposal: []
related_rfcs:
  - RFC-001
related_adrs:
  - ADR-001
  - ADR-002
  - ADR-003
  - ADR-004
related_specs: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# PROPOSAL-002: Signal Analyzer Reference Application

## Summary

GiftUI should use a low-frequency digital Signal Analyzer as its primary
reference application. The analyzer should provide one coherent, non-trivial
workload for evaluating whether GiftUI can express a substantially shared,
SwiftUI-inspired presentation across desktop, Linux, and constrained embedded
environments.

## Problem

Small control examples and isolated framework demonstrations can show that
individual mechanisms work, but they do not establish that GiftUI can support
a complete interactive application. They leave composition, layout,
rendering, state, interaction, custom drawing, and platform integration to be
evaluated separately, allowing gaps between those areas to remain hidden.

GiftUI needs a stable application-level problem that is demanding enough to
expose those gaps without requiring a broad product or a speculative framework
surface. Without that reference, framework work can optimize for isolated
examples rather than for a credible end-to-end developer experience.

## Motivation

A low-frequency digital Signal Analyzer combines several representative UI
needs in a compact and understandable application: a structured screen,
reusable channel presentation, acquisition controls, status and error
feedback, observable state, selectable viewing windows, and data-driven
waveform visualization.

The same application also provides useful pressure on portability. It can be
developed rapidly on a desktop while remaining meaningful on Linux
framebuffer systems and constrained embedded displays. This makes it a strong
test of whether GiftUI preserves familiar application concepts without hiding
real differences in hosting, rendering, input, and hardware resources.

The repository already relies on the Signal Analyzer as a representative
workload. Recording the rationale as an accepted Proposal gives that choice a
clear lifecycle origin without treating later technical descriptions or
existing implementation as retroactive authority for architecture or
contracts.

## Users / Use Cases

- Swift application developers need evidence that GiftUI supports a complete
  interactive application rather than only isolated UI demonstrations.
- GiftUI maintainers need one bounded workload for evaluating whether
  framework features work together coherently.
- Platform and backend contributors need a shared application through which
  to expose portability gaps and meaningful capability differences.
- Embedded developers need the reference application to remain viable under
  static composition, limited memory, constrained display geometry, and
  hardware-specific hosting.
- A user of the analyzer needs to view multiple digital channels, understand
  acquisition status, start or stop capture, clear captured data, select a
  visible time window, and inspect data-driven traces.

## Goals

- Provide one coherent reference application that exercises GiftUI as an
  application framework.
- Demonstrate a substantially shared declarative presentation across desktop,
  Linux framebuffer, and constrained embedded environments.
- Exercise non-trivial composition, reusable views, layout, text and color
  presentation, interaction, disabled state, observable updates, and custom
  waveform drawing together.
- Keep platform-, backend-, and hardware-specific concerns outside the
  portable presentation except for legitimate application hosting.
- Give framework and platform work an observable end-to-end validation target
  with deliberately bounded application behavior.

## Non-goals

- Define GiftUI architecture, module boundaries, public APIs, concrete types,
  backend contracts, or implementation sequencing.
- Authorize implementation of the analyzer or any framework feature.
- Build a laboratory-grade oscilloscope, high-frequency acquisition system,
  or general-purpose signal-processing product.
- Define signal acquisition hardware, persistence, transport, or application
  data-layer architecture.
- Reproduce the complete SwiftUI API or justify unrelated framework features.
- Require platform hosting, device setup, or hardware access code to be shared
  across fundamentally different environments.

## Constraints

- The analyzer MUST remain a bounded reference application rather than grow
  into a general-purpose measurement product.
- Its portable presentation MUST remain substantially shared across supported
  environments.
- Legitimate hosting, input, display, and signal-source differences MAY be
  handled at platform or application boundaries.
- Static composition and constrained embedded execution MUST be treated as
  first-class conditions, not as later ports of a desktop-only application.
- Memory use, binary size, runtime overhead, display size, and implementation
  complexity MUST remain visible costs.
- Custom drawing SHOULD stay focused on the grid and digital traces required
  by the analyzer.
- Existing code and documents MAY provide evidence, but MUST NOT determine
  architecture or implementation contracts by precedent.

## Success Criteria

- The Signal Analyzer operates as one coherent interactive application rather
  than a collection of disconnected framework demonstrations.
- Its presentation is substantially shared across macOS, Raspberry Pi/Linux
  with a framebuffer display, and nRF52840 with a TFT display.
- The application visibly presents multiple signal channels and data-driven
  digital traces against a time grid.
- Users can observe acquisition and error status, invoke the required capture
  actions, clear data, and select a visible time window, with unavailable
  actions visibly disabled.
- State changes update the relevant presentation without requiring
  platform-specific application variants.
- Platform-, renderer-, input-, and hardware-specific details remain outside
  the portable presentation except for legitimate application hosting.
- Execution claims for each environment are supported by actual execution;
  claims involving physical displays or input are supported on the relevant
  connected hardware.

## Scope

The feature covers the Signal Analyzer as an application-level validation
target: its portable presentation, user-visible behavior, representative
signal data, and the minimum target-specific hosting needed to run it in the
intended environments.

The rough presentation includes a screen structure, status and controls,
reusable channel rows, a selectable time view, and a waveform area containing
a time grid and multiple digital traces. Detailed behavior, APIs, ownership,
architecture, backend integration, and validation procedures belong in
downstream lifecycle artifacts.

## Risks

- A single reference application will not expose every future framework need;
  apparent generality must not be inferred from this validation alone.
- Desktop development could conceal static, resource, display, or input
  assumptions until the analyzer is exercised on constrained targets.
- Application-domain complexity could distract from UI framework validation if
  acquisition or signal processing expands beyond representative data needs.
- Target-specific code could accumulate inside the presentation and create the
  appearance of portability without a genuinely shared application model.
- The reference application could become an informal source of framework
  contracts unless downstream architecture and Specifications remain explicit.

## Open Questions

None for acceptance of this Proposal. Detailed application contracts,
architecture, framework APIs, target integrations, and validation procedures
remain subject to their appropriate lifecycle artifacts.

## Impact of Acceptance

Acceptance establishes the Signal Analyzer as an approved application-level
problem and authorizes architectural exploration of how GiftUI should support
it. It does not approve architecture, contracts, or implementation.

## References

- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md)
