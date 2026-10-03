---
id: FW-033
feature: giftui-mvp-architecture
title: Connected Validation Follow-up
status: captured
authors:
  - codex
created: 2026-10-03
updated: 2026-10-03
source:
  - SPEC-001
  - SPEC-011
  - SPEC-015
related_future_work:
  - FW-031
  - FW-032
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-033: Connected Validation Follow-up

## Observation / Opportunity

Current final-artifact evidence lacks the complete connected screen/input,
physical provenance, disabled-overlap, movement/stale cancellation,
exact-once dispatch, transport-fault/recovery corpus and full independent
semantic/action/drawing trace comparison. Pi display/control signoff and nRF
calibration are confirmed; the software-Start capture prefix matches. Neither
proves the missing corpus. Complete loaded resource evidence also remains
uncollected; performance investigation is tracked separately.

## Why Deferred

On 2026-10-03 the maintainer directed the remaining Specifications to be
considered done after the recorded failures and evidence gaps were presented.
SPEC-001 T8.1/T8.2/T8.3, SPEC-011 T9.3/T9.4 and SPEC-015's assembled connected
gate close under an approved exception. This item preserves their missing
evidence without reporting a test pass.

## Potential Value

- Execute the missing connected corpus against identified final artifacts and
  compare full normalized traces with the independent oracle.
- Replace scoped closeout exceptions with reproducible connected evidence.

## Current Non-goals

- No fabricated physical observation, acceptance-criterion change, or current
  hardware operation. The immutable logs and measured failures remain intact.
- No new MVP functionality or architecture decision.

## Revisit Triggers

- The maintainer starts the next connected-validation iteration.
- Performance improvements under FW-027/FW-032 are ready for connected
  regression and sustained-load validation.

## Disposition

Captured as follow-up to the maintainer-approved closure. Coordinate the macOS
pointer subset with FW-031. Preserve original criterion and task IDs in the
future evidence record, then update conformance exceptions with actual results.

## References

- [SPEC-001](../specs/spec-001-signal-analyzer-reference-application.md)
- [SPEC-011](../specs/spec-011-interaction.md)
- [SPEC-015](../specs/spec-015-host-configuration.md)
- [macOS pointer](fw-031-macos-connected-pointer-validation-resumption.md)
- [nRF performance](fw-032-nrf-performance-improvement.md)
- [Pi performance](fw-027-pi-performance-investigation-resumption.md)
- [Closeout evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md)
- [Maintainer approval](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/remaining-spec-transition-approval.md)
