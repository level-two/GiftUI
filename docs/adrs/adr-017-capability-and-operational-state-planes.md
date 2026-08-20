---
id: ADR-017
feature: capability-system
title: Capability and Operational-State Decision Planes
status: proposed
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-20
proposal:
  - PROPOSAL-004
related_rfcs:
  - RFC-002
  - RFC-005
  - RFC-006
related_adrs:
  - ADR-006
  - ADR-008
  - ADR-010
  - ADR-012
  - ADR-015
  - ADR-016
  - ADR-018
  - ADR-019
  - ADR-020
related_specs: []
related_future_work:
  - FW-018
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-017: Capability and Operational-State Decision Planes

## Status

Proposed.

## Context

An assembled GiftUI stack has facts fixed by build composition, semantic
behavior established during initialization, target policy selecting among
conforming realizations, and health that changes while the runtime operates.
Conflating those facts would let temporary device loss silently rewrite the
stack's semantic promise or make ordinary component selection appear as a
portable Capability.

## Decision

GiftUI MUST separate four kinds of facts:

1. structural selection of implementation families, runtime profile, storage
   model, and component graph;
2. immutable effective semantic capability declarations resolved before the
   first run cycle;
3. explicit realization policy and ordinary configuration; and
4. mutable runtime operational state such as health, availability to accept
   work, backpressure, disconnection, or failure outcomes.

The active profile, component graph, and effective capability snapshot MUST
remain immutable for the assembled runtime lifetime. A materially changed
graph or semantic declaration requires construction of a new runtime. Runtime
conditions MUST enter through operational outcomes and explicit health; they
MUST NOT silently mutate capability declarations.

Post-handoff device and transport conditions are classified as operational
state by this ADR, while ADR-010 exclusively governs their frame-disposition
and responsibility-transfer meaning.

## Rationale

Stable declarations make capability consumption deterministic within a cycle,
while explicit operational state represents real runtime changes without
claiming that configured semantics changed. Separating policy prevents a
preferred realization from manufacturing support.

## Consequences

### Positive

- Portable and framework code can rely on a stable capability snapshot.
- Device loss and backpressure remain visible without changing semantic
  declarations.
- Structural validation and capability resolution remain distinct startup
  gates.

### Negative

- Live reconfiguration cannot be modeled as mutation of the snapshot.
- Hosts must maintain separate configuration, policy, capability, and health
  representations.

### Follow-up

- Specifications must define snapshot lifetime, startup gates, health/outcome
  paths, and runtime reconstruction behavior.

## Deferred and Follow-up Work

- [FW-018](../future-work/fw-018-live-surface-reconfiguration.md) preserves
  the lifecycle required for live extent or orientation changes.

## Rejected Alternatives

### Mutable capability registry

Rejected because it conflates semantic promises with temporary health and
destabilizes runtime behavior.

### Treat every selected component as a Capability

Rejected because structural presence and configuration are not semantic
capability families without a demonstrated portable difference or constraint.

## References

- [RFC-006: GiftUI Capability System Architecture](../rfcs/rfc-006-capability-system-architecture.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-005: Failure and Diagnostics Propagation Architecture](../rfcs/rfc-005-failure-diagnostics-propagation.md)
- [PROPOSAL-004: GiftUI Capability System](../proposals/proposal-004-capability-system.md)
