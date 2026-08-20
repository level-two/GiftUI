---
id: ADR-010
feature: giftui-mvp-architecture
title: Synchronous One-Shot Frame Handoff
status: proposed
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-20
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-004
  - RFC-005
  - RFC-006
related_adrs:
  - ADR-005
  - ADR-007
  - ADR-011
  - ADR-012
  - ADR-013
  - ADR-015
  - ADR-016
  - ADR-017
  - ADR-020
  - ADR-022
related_specs: []
related_future_work:
  - FW-010
  - FW-014
related_explorations: []
related_spikes:
  - SPIKE-001
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-010: Synchronous One-Shot Frame Handoff

## Status

Proposed.

## Context

GiftUI needs one frame boundary that works for desktop surfaces, Linux
framebuffers, and bounded tiled embedded presentation. Core cannot retain a
universal replayable frame without imposing storage on every target, while
asynchronous device work still requires an unambiguous transfer of ownership
and transaction disposition.

## Decision

The MVP frame envelope MUST offer one borrowed ordered operation stream to a
backend exactly once during a synchronous `offer` call. The backend MUST
either:

- consume the complete stream, reserve all bounded downstream capacity, retain
  or transfer only backend-owned derived presentation data, accept ordered
  presentation responsibility, and return an accepted disposition; or
- refuse before any irreversible presentation effect, retain no frame data or
  borrowed resource, and return an aborting disposition.

Accepted handoff MUST atomically commit the logical frame and its presentation-
coupled routing state. Once irreversible output begins, responsibility has
transferred: the backend MUST consume or safely drain the stream and return an
accepted disposition. Later presentation progress, device or transport
failure, retry, or abandonment MUST remain bounded backend/integration
operational state and MUST NOT reopen the Core frame transaction, roll back
semantic state, or invoke client actions.

Core MUST NOT require replayable operation storage or asynchronous completion
of its frame disposition.

## Rationale

This boundary gives every frame one deterministic commit or abort point while
allowing lower integrations to continue asynchronously from data they own. It
supports bounded tiled rasterization without imposing a retained display list
and keeps physical presentation uncertainty out of semantic transaction
control.

## Consequences

### Positive

- All first-party MVP backends share one operation lifetime and disposition.
- Borrowed operations and resources have a short, testable lifetime.
- Post-handoff hardware behavior cannot corrupt committed Core state.

### Negative

- A backend must reserve capacity before acceptance and cannot later convert
  an accepted attempt into refusal.
- Core commit does not guarantee physical visibility or rollback of partial
  device output.
- Target integrations must own bounded presentation health and input gating.

### Follow-up

- Specifications must define the frame envelope, offer result, provenance,
  capacity rules, and backend conformance fixtures.
- Every backend must prove that borrowed operations and resources are not
  retained after `offer`.

## Deferred and Follow-up Work

- [FW-010](../future-work/fw-010-backend-transport-submission-retry.md)
  preserves generalized post-handoff recovery using backend-owned data.
- [FW-014](../future-work/fw-014-replayable-operation-delivery.md) preserves a
  replayable operation form for a future measured raster requirement.

## Rejected Alternatives

### Retain or replay every operation stream

Rejected because it adds universal RAM, copying, lifetime, and capacity costs
that no MVP backend requires.

### Commit at physical presentation completion

Rejected because completion evidence differs across framebuffer, SPI, remote,
and compositor paths and published semantic state cannot generally be rolled
back.

### Treat post-handoff failure as late refusal

Rejected because irreversible effects and ownership transfer have already
occurred; reopening the transaction would make disposition ambiguous.

## References

- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-005: Failure and Diagnostics Propagation Architecture](../rfcs/rfc-005-failure-diagnostics-propagation.md)
- [RFC-006: GiftUI Capability System Architecture](../rfcs/rfc-006-capability-system-architecture.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [SPIKE-001: Tiled One-Shot Stream and Capability Compatibility Fixtures](../spikes/spike-001-tiled-one-shot-capability-fixtures.md)
