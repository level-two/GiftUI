---
id: FW-033
feature: giftui-mvp-architecture
title: Connected Validation Follow-up
status: captured
authors:
  - codex
created: 2026-10-03
updated: 2026-10-04
source:
  - SPEC-001
  - SPEC-011
  - SPEC-015
related_future_work:
  - FW-031
  - FW-032
related_explorations: []
related_spikes:
  - SPIKE-013
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

- No fabricated physical observation or acceptance-criterion change.
  Immutable logs and measured failures remain intact; the later authorized
  bounded campaign supplies only its explicitly recorded observations.
- No new MVP functionality or architecture decision.

## Revisit Triggers

- The maintainer starts the next connected-validation iteration.
- Performance improvements under FW-027/FW-032 are ready for connected
  regression and sustained-load validation.

## Disposition

Captured as follow-up to the maintainer-approved closure. Coordinate the macOS
pointer subset with FW-031. Preserve original criterion and task IDs in the
future evidence record, then update conformance exceptions with actual results.

## 2026-10-04 bounded measurement update

The maintainer authorized connected measurements/experiments, superseding the
cleanup investigation's earlier hardware deferral. [Steps 22–24](../iterations/iteration-002-review/24-connected-reconciliation.md)
add identified production baselines, software Start and candidate cost/stack
observations. Software Stop was admitted but a stopped outcome was not
established. No physical contacts, complete diagnostic/pixel corpus, transport
fault/recovery or sustained 80-event/s resource corpus was collected. Preserve
this item's remaining evidence and all approved exceptions; no criterion is
upgraded solely from these bounded results.

## Service-boundary corpus and refusal follow-up

[Step25](../iterations/iteration-002-review/25-quiescent-software-input.md)
establishes stopped state through the unchanged production service boundary,
plus all windows, disabled Plus, movement cancellation and stale rejection.
The earlier mid-frame Stop remains inconclusive as a separate method. These
software observations do not prove physical contacts or exact-once dispatch.
[Step26](../iterations/iteration-002-review/26-connected-nrf-phases-and-failure.md)
adds copied-owner programmatic Clear, a96-byte model diagnostic, one injected
pixel-write refusal with cleanup, and successful fresh activation after explicit
input-graph reconstruction. This is a scoped supplement, not the complete
physical, independent-pixel/trace, overlap or multi-fault corpus. Existing
criterion exceptions retain their exact scope.

## References

- [SPEC-001](../specs/spec-001-signal-analyzer-reference-application.md)
- [SPEC-011](../specs/spec-011-interaction.md)
- [SPEC-015](../specs/spec-015-host-configuration.md)
- [macOS pointer](fw-031-macos-connected-pointer-validation-resumption.md)
- [nRF performance](fw-032-nrf-performance-improvement.md)
- [Pi performance](fw-027-pi-performance-investigation-resumption.md)
- [Closeout evidence](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md)
- [Maintainer approval](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/remaining-spec-transition-approval.md)
