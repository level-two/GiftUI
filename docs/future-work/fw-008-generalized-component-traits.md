---
id: FW-008
feature: capability-system
title: Generalized Component Trait System
status: captured
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-15
source:
  - RFC-006
  - RFC-007
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-008: Generalized Component Trait System

## Observation / Opportunity

RFC-006 distinguishes a Trait—a typed fact owned by one component, runtime
profile, Service, or environment—from a client-facing GiftUI Capability. A
future generalized Trait system could provide subsystem-owned namespaces,
common composition operators, inspection tooling, plugin or runtime discovery,
schema evolution, and reusable mapping from component Traits to semantic
Capabilities.

This architectural term is distinct from SwiftPM traits. A future design may
integrate with SwiftPM traits for structural build selection, but it need not
use that mechanism for value-level component facts.

## Why Deferred

The MVP needs only a closed, bounded set of typed Trait contributions used by
the four Capability fixtures. General discovery, extension, namespacing, and a
universal Trait API would add type, storage, versioning, diagnostics, and
tooling cost without an accepted requirement.

## Potential Value

- Let independently developed subsystems describe reusable facts without
  turning implementation details into client-facing Capabilities.
- Provide consistent inspection and composition when the backend and device
  matrix grows beyond the four MVP configurations.
- Reduce repeated adapter code if several Capability families consume the same
  lower-level fact.

## Current Non-goals

- No public Trait registry, dynamic discovery protocol, universal algebra,
  plugin schema, or SwiftPM-trait mapping is added to RFC-006 or the MVP.
- The fixed typed contributions needed by RFC-006 remain current scope and do
  not depend on promotion of this item.

## Revisit Triggers

- Two or more accepted features require the same lower-level fact and develop
  incompatible local Trait representations or merge rules.
- A supported third-party backend or runtime-loaded component needs to publish
  Traits without modifying the closed MVP vocabulary.
- Configuration diagnostics require cross-subsystem Trait inspection that the
  bounded RFC-006 fixtures cannot express without duplication.
- SwiftPM structural traits and runtime/value Traits demonstrably need a
  reviewed mapping to prevent configuration drift.

## Disposition

Captured. Promotion requires triage into an Exploration or Proposal. RFC-006
uses only its closed, typed MVP contributions and does not depend on a general
Trait subsystem.

## References

- [RFC-006: GiftUI Capability System Architecture](../rfcs/rfc-006-capability-system-architecture.md)
- [RFC-007: GiftUI Delegated Services Architecture](../rfcs/rfc-007-delegated-services-architecture.md)
