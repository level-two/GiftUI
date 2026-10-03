---
id: FW-031
feature: giftui-mvp-architecture
title: macOS Connected Pointer Validation Resumption
status: captured
authors:
  - codex
created: 2026-10-03
updated: 2026-10-03
source:
  - SPEC-011
related_future_work:
  - FW-033
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-031: macOS Connected Pointer Validation Resumption

## Observation / Opportunity

SPEC-011 T9.3 still requires real macOS pointer evidence for committed
presentation provenance, exact hit regions, disabled overlap, movement
cancellation, stale replacement, and exact-once dispatch. Hardware-free
fixtures do not replace these observations.

## Why Deferred

The maintainer explicitly postponed the macOS physical-pointer campaign to
the next iterations on 2026-10-03. This capture preserves that work-ordering
instruction. The subsequent explicit closure instruction approves an
exception for this iteration; the missing connected evidence remains follow-up.

## Potential Value

- Execute the remaining physical-pointer corpus once against an identified
  final artifact and reuse its evidence in SPEC-011's conformance review.

## Current Non-goals

- No implementation change or acceptance-criterion amendment. The
  implemented transition records the separately documented human exception.
- Pi and nRF physical-input work is outside this postponement.

## Revisit Triggers

- The maintainer starts the next macOS connected-input validation iteration.
- A connected regression campaign needs macOS physical-input coverage.

## Disposition

Captured at the maintainer's explicit request. SPEC-011 T9.3's macOS portion
is closed by the maintainer-approved exception; its uncollected physical
corpus remains postponed. Historical passing host fixtures retain their scope.

## References

- [SPEC-011](../specs/spec-011-interaction.md)
- [SPEC-011 plan](../implementation-plans/spec-011-implementation-plan.md)
- [Current iteration closeout](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md)

- [Connected follow-up](fw-033-connected-validation-follow-up.md)
- [Maintainer approval](../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/remaining-spec-transition-approval.md)
