---
id: RFC-012
feature: kmrtm24024-spi
title: KMRTM24024-SPI nRF52840 Display and Touch Target
status: draft
authors:
  - codex
created: 2026-09-25
updated: 2026-09-25
proposal:
  - PROPOSAL-007
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

# RFC-012: KMRTM24024-SPI nRF52840 Display and Touch Target

## Summary

This draft proposes a separately selected nRF52840 target configuration for
the maintainer's 240 x 320 direct-SPI display and resistive touch module. It
would retain the portable Signal Analyzer and established render, action, and
input semantics, while supplying target-specific display framing, geometry,
touch sampling and calibration, and checked static capacities. The existing
480 x 320 ILI9486 configuration remains an independent target.

The board marking and pin labels establish connector roles and nominal extent,
but not the populated controller identities or safe electrical configuration.
Those are approval blockers, not assumptions this RFC silently settles.

## Context

[PROPOSAL-007](../proposals/proposal-007-kmrtm24024-spi-target.md) was
explicitly accepted by the maintainer on 2026-09-25. It calls for both display
and touch with all six Signal Analyzer controls. This is additional post-MVP
support; it does not replace the approved 480 x 320 connected MVP fixture.

The [connected-test record](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-8/nrf52840-connected-attempt.md)
shows that the current firmware reaches its production scheduler and an
ILI9486 display write returns success, yet the physical panel shows a white
field with stray lines or dots. The module's back reads `KMRTM24024-SPI` and
`2.4 TFT SPI 240*320`. It exposes display `CS`, `RESET`, `D/C`, `SDI`, `SCK`,
`LED`, `SDO` and separate touch `T_CLK`, `T_CS`, `T_DIN`, `T_OUT`, `T_IRQ` pins.
The board marking does not identify the display or touch IC. A historical PoC
document mentions an ILI9341 candidate, but is not authority or physical
verification.

The accepted layered architecture in [RFC-002](rfc-002-giftui-mvp-layered-architecture.md)
places controller and transport behavior below the display-target boundary,
and touch acquisition below semantic input. The current nRF implementation
embeds 480 x 320 assumptions in `ili9486.c`, its Zephyr overlay, production
host calibration, and generated/static host presets. Approved
[SPEC-001](../specs/spec-001-signal-analyzer-reference-application.md),
[SPEC-004](../specs/spec-004-capability-contribution-and-resolution.md),
[SPEC-014](../specs/spec-014-backend-integration.md), and
[SPEC-015](../specs/spec-015-host-configuration.md) prescribe exact 480 x 320
nRF MVP fixtures. This RFC cannot reinterpret them as 240 x 320 approval.

## Scope and Decision Boundary

This is one independently reviewable target-integration cluster: display
framing and extent, touch coordinates, static host selection, and physical
evidence must agree for the same board orientation. A display-only driver
could be built separately, but could not satisfy the accepted proposal. The
cluster can be approved or rejected without changing the existing 480 x 320
target's decisions. Separate ADRs may record controller integration, host
profile selection, and input calibration after design review.

Portable Signal Analyzer behavior, general drawing semantics, global
capability-resolution policy, and data acquisition stay with their existing
RFCs and ADRs. If the smaller surface exposes a need to change the portable
hierarchy or its required action set, that is an upstream contract issue for
explicit review, not a target-local shortcut here. This RFC owns no arbitrary
future 240 x 320 display family.

## Requirements

1. The target must render the full shared analyzer, including status, four
   channels, grid, four data-driven traces, and six controls, on the exact
   240 x 320 module, with no platform branch in portable Presentation.
2. Resistive touch must deliver all six actions through the established
   pointer/gesture/action path, with display and touch coordinates aligned.
3. Target selection must be explicit and reproducible; the 480 x 320 image,
   firmware behavior, and approval evidence must remain independently usable.
4. Display payloads must preserve the bounded RGB565, synchronous one-shot
   semantics required by the current embedded render pipeline, or a revised
   contract must be approved before implementation.
5. Both target variants must have measured RAM, flash, peak stack, region
   size, scan-out time, input latency, and failure behavior. Connected
   evidence must distinguish SPI return success from visible output.
6. The exact board's controller identity, power/logic levels, and wiring must
   be verified before approving controller commands or connected flashing.

## Constraints

- The nRF52840-DK build remains Embedded Swift plus Zephyr with bounded
  storage and no heap-dependent steady-state path.
- Approved 480 x 320 fixture extents and capacities remain authoritative for
  their existing MVP target. A 240 x 320 fixture needs its own approved
  contract and generated metadata rather than a substituted number.
- The display and touch may share an SPI peripheral but require independent
  selection and safe chip-select behavior; the board photo alone does not
  establish how they are wired to the DK.
- Physical tests require the connected board's safety, orientation, and
  electrical facts to be checked. Build success alone proves no screen output.

## Proposed Design

### Target composition

A build-time selected, named 240 x 320 target would compose the existing
static Signal Analyzer, render integration, scheduler, action dispatcher, and
input pipeline with a separate display controller adapter and a touch adapter
for the confirmed IC. The target records its immutable orientation, surface
extent, row-tile shape, in-flight byte bound, wiring, and calibration as one
validated configuration. The 480 x 320 target keeps its present composition.
No runtime panel autodetection is proposed.

The new display adapter would accept validated RGB565 regions through the
same borrowed synchronous handoff, set a bounded address window, and send
pixel bytes using framing confirmed for the populated controller. It would
not reuse the ILI9486 serial-to-parallel register expansion merely because
both panels connect to SPI. A controller-specific initialization and shutdown
sequence would own reset, display-on, and backlight ordering. Exact commands,
delays, SPI rate, color order, and rotation remain blocked on identification
and connected evidence.

The touch adapter would sample the confirmed controller, lower contact data
through the existing normalized input path, and use target calibration tied
to the selected display orientation. The six semantic actions and their
routing remain shared. A display-only bring-up image may be a diagnostic
step, but is not a conforming target result.

### Profile and validation

The candidate 240 x 320 profile would reuse the common analyzer workload
semantics and derive target-specific display and raster bounds. For a
four-row full-width RGB565 tile, the nominal pixel storage is
`240 * 4 * 2 = 1,920` bytes, compared with 3,840 bytes at 480 pixels wide.
That arithmetic is a starting projection only. The approved workload
manifest, capability contributions, selected effective presentation, host
validation, generated constants, physical transfer behavior, and actual
linker/stack measurements must all agree. If the complete hierarchy does not
fit legibly or resource checks fail, this candidate profile must be revised
through the applicable contracts rather than weakened at runtime.

## Module Responsibilities

| Area | Proposed responsibility | Dependency impact |
| --- | --- | --- |
| Portable Presentation and Domain | Keep analyzer state, content, and six actions shared | No panel or driver import |
| Static target host | Select one named immutable target profile and assemble existing interfaces | Owns orientation, capacities, calibration and failure reporting |
| Raster/display integration | Produce bounded RGB565 regions and honor synchronous handoff | Uses selected extent and tile bounds, not a controller name |
| New controller adapter | Initialize and write the exact display through direct SPI | Below display-target boundary; no analyzer knowledge |
| Touch adapter | Sample confirmed touch IC and normalize coordinates | Below semantic input; no direct action invocation |
| Zephyr board configuration | Declare exact bus, chip selects, GPIO polarity, reset, IRQ, power/backlight wiring | Target-specific, statically selected |

## Public API Impact

The candidate design adds no portable GiftUI or Signal Analyzer API. Build
and host configuration gain a named target choice. If complete presentation
requires a portable layout change at 240 x 320, that change must be reviewed
against the already approved application contract before implementation.

## Capabilities Impact

The new target would contribute its exact 240 x 320 extent, RGB565 encoding,
operation coverage, region/payload/in-flight bounds, and synchronous handoff
to the existing resolver. Touch support is required for the complete target,
not an optional capability fallback. A missing or incompatible contribution
would fail host validation with existing deterministic failure policy.

## Backend Impact

The current operation-major tiled raster approach appears reusable if its
region and handoff contracts admit the selected tile. The board-specific
display adapter owns command framing and scan-out. The touch adapter owns
physical samples and calibration; pointer integration, gesture admission,
and action routing remain backend-neutral. Neither backend may infer a
successful presentation from an SPI return code alone in connected evidence.

## Static / Embedded Impact

Target selection is compile-time, so one firmware image need not retain both
controller implementations or both calibration tables. Each variant must
prove fixed storage, stack lifetime, Zephyr driver availability, ELF ABI,
and linker RAM/flash limits. No full RGB565 framebuffer is proposed (which
would be 153,600 bytes for 240 x 320). Shared SPI access must ensure display
and touch chip selects cannot overlap and must define behavior on transport
errors or touch release during an incomplete sample.

## Performance

A 240 x 320 full-screen RGB565 transfer contains 153,600 pixel bytes before
protocol overhead, half the 480 x 320 payload. At the current 4 MHz display
clock, a raw ideal transfer alone takes at least 307.2 ms; command overhead,
chip-select changes, software raster work, and touch bus sharing increase it.
This is a feasibility concern against the analyzer's at-most-one-frame-per-
250-ms presentation cadence, not a measured result or proposed clock. The
design review needs a measured tile/dirty-region trace and connected frame
cadence before accepting a throughput claim. Input sampling must not starve
behind display transfers.

## Memory / Binary Size

Four 240-pixel RGB565 rows require 1,920 bytes per raster or payload slot,
subject to accepted profile capacity and driver segmentation. The existing
static capture and application storage may dominate RAM, so a smaller tile
does not by itself prove the target fits. Separate target images may avoid
retaining both driver code paths in one binary, at the cost of two artifacts
and two regression matrices. Peak stack, static RAM, flash, and temporary
SPI buffers must be measured for each image; no savings are claimed yet.

## Alternatives

| Alternative | Benefit | Cost and suitability |
| --- | --- | --- |
| Separate build-time target, shared interfaces (candidate) | Explicit wiring and capacities, small static image, protects existing fixture | Requires a second image and exact profile contract |
| One runtime-selected multi-panel image | Single artifact and potential field switching | Detection/wiring ambiguity, retains both drivers and resources, adds embedded state and failure paths |
| Reuse ILI9486 driver with changed dimensions | Small initial diff | Serial-to-parallel register framing is wrong for the pictured direct-SPI connector; controller identity still unverified |
| Display-only target with external buttons | Faster visual bring-up | Does not satisfy accepted touch and six-control goal; useful only as a diagnostic intermediate |
| Full-frame RGB565 storage | Simpler scan-out model | 153,600-byte surface alone conflicts with the current 192 KiB firmware RAM envelope and existing static storage |

## Rejected Approaches

None by this draft. The alternatives remain candidates until review; the
display-only path is useful as diagnostic bring-up but cannot close the
Proposal's success criteria.

## Compatibility

The new target should be additive. Existing firmware names, 480 x 320
metadata, ILI9486 framing, and connected evidence must remain intact.
Portable sources and action semantics should remain common. No on-device
state migration is proposed. A new host profile or revision may require
amendments to SPEC-001, SPEC-004, SPEC-014, and SPEC-015; these are explicit
contract changes subject to normal approval, not implied by this RFC.

## Testing Strategy

- Identify the populated display and touch ICs and document safe electrical
  characteristics and exact pin-to-DK wiring before selecting commands.
- Exercise controller initialization, command/data framing, windows, RGB565
  ordering, chip-select isolation, shutdown, and bounded error behavior in
  hardware-free tests with an SPI/GPIO recorder.
- Compare target profile, generated metadata, capability joins, layout,
  raster bounds, complete hierarchy, and six actions in host fixtures.
- On the connected module, photograph a known diagnostic pattern, full
  analyzer with text/traces, and all six touch actions; collect timed run,
  fault/reset, RAM/flash/stack, and input responsiveness evidence.
- Rebuild and recheck the 480 x 320 target and its existing contract fixtures
  after adding the variant. The old T8.2 hardware gate remains separate.

## Risks

- Board marking may cover different controller populations; an incorrect
  initialization or voltage can cause a blank screen or damage.
- Small-screen layout or touch targets may fail usability despite correct
  pixels and samples.
- 4 MHz transfer timing may be inadequate for visible update cadence.
- Existing approved exact-profile fixtures may need a new target profile
  rather than a small implementation-only change.
- Shared SPI operations and partially submitted frames may complicate touch
  latency and recovery.

## Open Questions

1. **Approval blocker:** Which display and touch ICs are populated on this
   exact board, with what supply, logic level, reset/backlight behavior, and
   verified DK wiring? The board photo alone does not answer this.
2. **Approval blocker:** What orientation, pixel color order, SPI mode/rate,
   and touch calibration give visible correct output and six reliable actions
   on this board? A bounded diagnostic connected experiment is needed.
3. **Approval blocker:** Does the existing analyzer hierarchy fit and remain
   legible/tappable at 240 x 320? Host layout evidence and a physical review
   are needed; any required portable redesign needs its own approved route.
4. **Approval blocker:** Which exact Specifications should gain a second
   target fixture versus a separate variant Specification, and what resource
   ceiling is justified? Contract owners must resolve this before approval.
5. What measured connected transfer, render, and touch latency can the
   selected bus configuration sustain? This may block approval if it makes
   the complete target infeasible.

## Deferred and Follow-up Work

[FW-023](../future-work/fw-023-ili9341-240x320-target-variant.md) records the
original 240 x 320 observation and is promoted through PROPOSAL-007. Its
controller guess is not a decision. SD-card integration, display readback,
and support for other modules remain outside this RFC because the accepted
Proposal asks for this exact display and touch target. Revisit those ideas
only if a concrete application requirement appears; none is used to resolve
the blockers above.

## Decision Summary

If approved after the blockers are resolved, review may extract separate
ADRs for (1) additive build-time target composition and display transport,
(2) 240 x 320 static host profile and capability/region bounds, and (3)
touch-controller acquisition, coordinate calibration, and SPI arbitration.
These are candidate decisions, not accepted architecture.

## References

- [Accepted PROPOSAL-007](../proposals/proposal-007-kmrtm24024-spi-target.md)
- [Connected nRF test and module photo evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-8/nrf52840-connected-attempt.md)
- [RFC-002 layered architecture](rfc-002-giftui-mvp-layered-architecture.md)
- [Approved SPEC-001 Signal Analyzer](../specs/spec-001-signal-analyzer-reference-application.md)
- [Approved SPEC-004 capability resolution](../specs/spec-004-capability-contribution-and-resolution.md)
- [Approved SPEC-014 backend integration](../specs/spec-014-backend-integration.md)
- [Approved SPEC-015 host configuration](../specs/spec-015-host-configuration.md)
- Historical `PoC:docs/GiftUI_KMRTM24024_SPI_nRF52840_Spec.md` is
  non-authoritative and does not identify this board's populated ICs.
