---
id: FW-023
feature: signal-analyzer
title: 240 x 320 nRF Target Variant (Closed)
status: closed
authors:
  - codex
created: 2026-09-25
updated: 2026-09-27
source:
  - SPEC-001
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-023: 240 x 320 nRF Target Variant (Closed)

This record preserves the originally deferred separate-variant idea. On
2026-09-27 the maintainer directed replacement of the existing nRF display
target within the Signal Analyzer MVP instead and explicitly approved the
coordinated SPEC-001, SPEC-004, SPEC-014, and SPEC-015 amendments. This closed
Future Work item itself grants no implementation authority.

## Original 2026-09-25 Capture

## Observation / Opportunity

The connected nRF52840 test bench has a `KMRTM24024-SPI` module marked
`2.4 TFT SPI 240*320`, with direct SPI display pins and separate touch pins.
The approved nRF Signal Analyzer target is 480 x 320 with an ILI9486
serial-to-parallel display bridge. The current firmware cannot render the
approved surface correctly on this smaller module. A separate 240 x 320
ILI9341-class target variant might make this readily available hardware useful
for future development or a smaller device configuration.

## Why Deferred

The current connected campaign must validate the approved 480 x 320 target.
Changing its extent, pixel transport, controller, layout, resource fixture,
or acceptance evidence to fit this module would amend approved contracts.
The physical mismatch remains a current T8.2 blocker; this item does not
remove it.

## Potential Value

- A smaller direct-SPI board could provide an additional embedded display and
  touch profile after its behavior and resource limits are specified.

## Current Non-goals

- Treating this module as passing the 480 x 320 connected acceptance gate.
- Replacing the approved ILI9486 target or changing current nRF fixtures.
- Shipping an ILI9341 driver from the diagnostic work in this campaign.

## Revisit Triggers

- A maintainer requests a 240 x 320 nRF target as a separate product or
  validation configuration and supplies the module/controller identification.
- The 480 x 320 connected campaign is complete and additional embedded target
  coverage is prioritized.

## Disposition

Closed as a separate-target proposal after the maintainer chose replacement
within the existing feature scope. The T8.2 connected gate remains open until
the actual controller and input hardware are identified, the approved
replacement is implemented, and the connected campaign passes on that target.

## References

- [SPEC-001 implementation plan](../implementation-plans/spec-001-implementation-plan.md)
- [Connected nRF attempt](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-8/nrf52840-connected-attempt.md)
- [SPEC-015 host configuration](../specs/spec-015-host-configuration.md)
