---
id: FW-009
feature: giftui-mvp-architecture
title: Shared Delegated Service Foundation
status: captured
authors:
  - Yauheni Lychkouski
created: 2026-08-16
updated: 2026-08-20
source:
  - RFC-002
  - RFC-005
  - RFC-007
  - ADR-007
  - ADR-016
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-009: Shared Delegated Service Foundation

## Observation / Opportunity

Several future GiftUI consumers may need environmental operations such as
monotonic time, wake scheduling, diagnostic delivery, or other host-provided
facilities. If those consumers require materially shared semantics, one small
foundation package and explicit host-injected contracts could prevent
duplication and dependency cycles across runtime profiles and platforms.

RFC-007 explored this direction using a candidate `GiftUIServices` package,
but current MVP work does not yet demonstrate enough independent approved
consumers to justify a shared catalogue or package.

## Why Deferred

RFC-002 already requires explicit target-host composition and downward
dependencies. RFC-004 can own any concrete runtime wake/re-entry contract, and
RFC-005 can own its optional diagnostic observation seam. Signal Analyzer
timing remains an application or host concern unless a GiftUI feature
establishes a framework consumer.

Creating a shared foundation now would select package ownership, common
primitives, dispatch, lifetime, and static storage before repeated use proves
that those choices reduce complexity.

## Potential Value

- Reduce duplicated environmental-operation semantics across approved
  consumers.
- Provide one bounded static/dynamic conformance surface when direct contracts
  would otherwise drift.
- Prevent dependency cycles if several lower packages require the same
  operation contract.

## Current Non-goals

- No `GiftUIServices` package, Clock, Scheduler, Diagnostic Sink, Service
  bundle, locator, adapter, or implementation is added to MVP scope.
- This item does not authorize a general dependency-injection system or
  environmental-operation catalogue.
- It does not change RFC-002, RFC-004, RFC-005, or RFC-006 ownership.

## Revisit Triggers

- Two or more approved GiftUI consumers require environmental operations with
  materially shared semantics and consumer-owned contracts would duplicate
  behavior or conformance tests.
- An approved Specification exposes a package dependency cycle that a lower
  shared environmental contract would resolve.
- A supported static and dynamic pair cannot preserve equivalent behavior
  through direct host wiring without a common contract.
- Measured RAM, flash, stack, dispatch, or maintenance cost shows a shared
  foundation is cheaper than the approved consumer-specific alternatives.

## Disposition

Captured. RFC-007 remains a paused draft with `target_milestone: null`. When a
trigger occurs, re-evaluate whether to revise RFC-007 under PROPOSAL-003 or
promote this item to a new Exploration if evidence is still missing.

## References

- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-005: Failure and Diagnostics Propagation Architecture](../rfcs/rfc-005-failure-diagnostics-propagation.md)
- [RFC-007: GiftUI Delegated Services Architecture](../rfcs/rfc-007-delegated-services-architecture.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
