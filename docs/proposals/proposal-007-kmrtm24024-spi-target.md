---
id: PROPOSAL-007
feature: kmrtm24024-spi
title: KMRTM24024-SPI nRF52840 Target Support
status: accepted
authors:
  - codex
created: 2026-09-25
updated: 2026-09-25
proposal: []
related_rfcs: []
related_adrs: []
related_specs: []
related_future_work:
  - FW-023
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: null
---

# PROPOSAL-007: KMRTM24024-SPI nRF52840 Target Support

## Summary

Add the maintainer's KMRTM24024-SPI 240 x 320 module as a separate nRF52840
Signal Analyzer display-and-touch target, with all six physical controls
working. Preserve the approved 480 x 320 target and the shared portable
application.

## Problem

The connected nRF52840 bench uses a module marked `KMRTM24024-SPI` and
`2.4 TFT SPI 240*320`. Its display connector exposes direct SPI signals. The
current nRF firmware and accepted configuration instead assume a 480 x 320
ILI9486 display with a serial-to-parallel bridge. The firmware can build and
enter its production loop, and the display driver's color-bar call can return
success, while the physical module shows only stray lines and dots. That
combination cannot validate a working application on this bench.

## Motivation

GiftUI's vision and principles call for constrained embedded displays without
placing their details in portable application code. The maintainer has asked
to support this specific, available module. A second display size and
transport would provide concrete evidence that the same Signal Analyzer can
run on a smaller embedded screen. It is additional post-MVP target support,
not a substitute for the current MVP's approved 480 x 320 nRF acceptance gate.
The maintainer confirmed that the first supported configuration should include
the resistive touch path and all six analyzer controls.

## Users / Use Cases

- The maintainer wants to run and inspect the Signal Analyzer on the connected
  nRF52840-DK and KMRTM24024-SPI module.
- Embedded contributors need a reproducible build and connected test path for
  this exact module without changing the existing display target.
- Analyzer users need the screen to show channels, status, controls, grid, and
  digital traces legibly at the smaller size.

## Goals

- Display the substantially shared Signal Analyzer presentation on the exact
  240 x 320 module with correct geometry, color, text, and traces.
- Support the analyzer's required physical control actions through the
  module's touch interface after its controller and wiring have been
  confirmed. Display-only bring-up may be an intermediate step, not the
  complete target outcome.
- Preserve bounded execution and report memory, flash, stack, and timing costs
  on the connected nRF52840.
- Keep the existing 480 x 320 nRF configuration and its acceptance evidence
  intact.

## Non-goals

- Replacing or reinterpreting the approved 480 x 320 connected MVP target.
- Treating visually similar 240 x 320 modules as interchangeable without
  controller and electrical identification.
- Adding SD-card, general image, or display-readback functionality merely
  because the module exposes related pins.
- Changing the portable analyzer's actions or waveform meaning to suit one
  panel.

## Constraints

- The module's controller, supply, logic levels, backlight, touch controller,
  and wiring must be verified on the exact board before relying on them.
- Display and input differences remain at legitimate target, backend, or
  hosting boundaries; the portable Signal Analyzer stays substantially shared.
- Embedded Swift, zero-heap, bounded storage, and nRF resource limits remain
  visible requirements.
- A connected success claim requires physical display and input evidence, not
  only a cross-build or a successful SPI return value.
- Existing accepted architecture and Specifications remain authoritative until
  their normal review and approval gates change them.

## Success Criteria

- A reproducible nRF build for this module emits inspected firmware artifacts
  and does not alter the existing ILI9486 build's behavior.
- The exact connected module visibly renders the complete analyzer at 240 x
  320, including text, six controls, grid, and four data-driven traces.
- All required controls admit exactly the intended actions on connected input,
  with no lost, duplicated, or stale activations in the validated scenario.
- A sustained connected run reports display/input behavior, cadence,
  responsiveness, faults or resets, and measured resource use.

## Scope

This proposal covers one additional nRF52840 display and input configuration
for the Signal Analyzer. Architectural and contract review must determine how
the smaller extent, direct SPI controller, fitted touch hardware, resource
profile, build selection, and physical evidence fit the existing stack. It
does not select those mechanisms here.

## Risks

- `KMRTM24024-SPI` is a board marking, not conclusive controller identity;
  an assumed initialization or voltage may be wrong for this unit.
- A 240 x 320 surface may require a distinct application layout or capacity
  fixture while preserving portable behavior.
- Additional firmware variants and physical test matrices raise maintenance
  and release costs.
- The smaller screen may not make every control legible or reliably tappable
  without a reviewed presentation choice.

## Open Questions

- What controller and touch IC are populated on this exact module, and what
  supply and signal levels are safe?
- Which physical orientation and touch calibration make the complete analyzer
  usable at 240 x 320?
- Which touch controller is populated, and can all six controls be reliably
  reached at the chosen orientation and calibration?
- Which accepted nRF contracts need amendment or a separate approved profile,
  and which remain shared without change?

## Deferred and Follow-up Work

[FW-023](../future-work/fw-023-ili9341-240x320-target-variant.md) records the
original observation and is promoted into this Proposal. SD-card support,
display readback, and other 240 x 320 modules remain outside this scope;
their presence on the PCB does not establish user value or a requirement.

## References

- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [Connected nRF hardware evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-8/nrf52840-connected-attempt.md)
- [Approved SPEC-001 Signal Analyzer contract](../specs/spec-001-signal-analyzer-reference-application.md)
- [Approved SPEC-015 host configuration](../specs/spec-015-host-configuration.md)
- Historical `PoC:docs/GiftUI_KMRTM24024_SPI_nRF52840_Spec.md` is
  non-authoritative context; its proposed thermostat target and design do not
  define this Proposal.
