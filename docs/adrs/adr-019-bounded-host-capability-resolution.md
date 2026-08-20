---
id: ADR-019
feature: capability-system
title: Bounded Target-Host Capability Resolution
status: proposed
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-20
proposal:
  - PROPOSAL-004
related_rfcs:
  - RFC-002
  - RFC-006
related_adrs:
  - ADR-006
  - ADR-007
  - ADR-008
  - ADR-017
  - ADR-018
  - ADR-020
related_specs: []
related_future_work:
  - FW-006
  - FW-015
related_explorations: []
related_spikes:
  - SPIKE-002
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-019: Bounded Target-Host Capability Resolution

## Status

Proposed.

## Context

Presentation conformance depends on facts owned by render producers,
backends, surfaces, and host resource policy. Some facts become known only
while a selected surface or device is initialized, but constrained static
targets cannot rely on heap allocation, discovery, reflection, or unbounded
registries.

## Decision Boundary

This record extracts RFC-006 Decision Summary items 3 and 5. It owns the host
composition point, deterministic initialization-time resolution, foundational
module placement, immutable result/failure boundary, and allocator-independent
static path. It does not define family-specific semantics (ADR-018 and ADR-020),
exact storage layouts or budgets, or generated composition tooling (FW-006).

## Decision

The target host MUST gather typed facts contributed only by their owning
components and perform deterministic capability resolution during bounded
initialization. Resolution MUST be independent of contribution, discovery, or
iteration order and MUST produce either an immutable effective result or a
stable validation failure before the first run cycle.

Capability vocabulary and pure domain-specific resolution MUST reside in an
acyclic foundational `GiftUICapabilities` target that imports no `GiftUI`,
semantic, layout, render, execution, failure, runtime, backend, platform,
driver, OS/RTOS, HAL, or concrete integration module. The host is the
composition root and supplies explicit policy without moving that policy into
the foundation.

On static and constrained targets, contribution construction, resolution,
validation-result construction, effective-result storage, and steady-state
access MUST be allocator-independent and use generated, fixed-capacity,
caller-owned, or otherwise explicitly bounded storage. Their incremental RAM,
stack, flash, initialization work, and zero-allocation behavior MUST be
measured.

## Rationale

Host resolution combines facts across otherwise acyclic owners without
upward imports. Bounded initialization accommodates device facts unavailable
at build time while preserving one normalized result across static and dynamic
profiles.

## Consequences

### Positive

- Cross-component compatibility is resolved once and before runtime work.
- Static and dynamic configurations can produce comparable effective results.
- Capability resolution does not enter view evaluation or per-frame work.

### Negative

- Hosts must assemble contributions and maintain explicit validation failure.
- The foundational target and snapshot have measurable code and storage cost.

### Follow-up

- Specifications must define contribution counts, storage, ordering,
  duplicate/malformed handling, snapshots, budgets, and startup integration.
- nRF52840 conformance must preserve explicit zero-allocation and resource
  evidence.

## Deferred and Follow-up Work

- [FW-006](../future-work/fw-006-generated-target-configuration.md) preserves
  generated composition tooling.
- [FW-015](../future-work/fw-015-capability-resolver-input-minimization.md)
  preserves later input reduction if ownership and negative fixtures remain
  enforceable.

## Rejected Alternatives

### Build-time-only resolution

Rejected because some required surface and device facts appear only during
bounded initialization.

### Feature-local probing

Rejected because it duplicates resolution, leaks concrete identity, and makes
results inconsistent.

### Encode every fact in generic types

Rejected because it creates disproportionate type and specialization surface
and cannot proportionately own initialization-time facts.

## References

- [RFC-006: GiftUI Capability System Architecture](../rfcs/rfc-006-capability-system-architecture.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [PROPOSAL-004: GiftUI Capability System](../proposals/proposal-004-capability-system.md)
- [SPIKE-002: nRF52840 Capability Path Resource Evidence](../spikes/spike-002-nrf52840-capability-path-resource-evidence.md)
