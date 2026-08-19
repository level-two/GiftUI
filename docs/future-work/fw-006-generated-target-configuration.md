---
id: FW-006
feature: capability-system
title: Generated Target Configuration
status: captured
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-19
source:
  - RFC-006
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-006: Generated Target Configuration

## Observation / Opportunity

Static firmware targets could describe their selected runtime, capacities,
backend, drivers, device parameters, capability requirements, and policy in a
declarative board or product configuration. A build tool could validate that
description and generate specialized Swift composition, constants, and
diagnostic metadata. It could also pre-resolve capability facts that are fully
known at build time while preserving RFC-006's bounded initialization step for
surface or device facts that become known only on the target.

## Why Deferred

RFC-006 can validate capability ownership and resolution with explicit Swift
composition in the four MVP configurations. Selecting a source format,
generator, SwiftPM integration, schema, or override model now would add a
second configuration system before repeated handwritten composition has shown
its cost or failure modes.

## Potential Value

- Reduce drift between build flags, Swift composition, capacity values, and
  documented target claims.
- Reject invalid firmware combinations earlier and omit unused implementation
  families through generated specialization.
- Reduce device initialization work by pre-resolving build-known capability
  facts without changing normalized results or skipping initialization-known
  compatibility checks.
- Make supported board configurations reproducible and inspectable.

## Current Non-goals

- No YAML, JSON, TOML, DeviceTree, SwiftPM plugin, macro, or code-generation
  contract is added to the MVP.
- RFC-006 does not require generated source or replace explicit target-host
  composition.
- Build-time pre-resolution does not manufacture support, remove required
  negative configuration checks, or replace bounded initialization for facts
  that are not knowable from the build description.

## Revisit Triggers

- Two or more maintained static targets duplicate materially similar
  composition code and a review identifies configuration drift or invalid
  combinations that typed Swift composition does not catch adequately.
- A supported-board matrix requires machine-generated capacities or component
  selection to remain reproducible.
- Measurements show that generated specialization would materially reduce
  firmware RAM, flash, or startup work compared with the maintained explicit
  composition path.
- Repeated measurements show that RFC-006's bounded on-target resolver spends
  material startup time or storage on facts already fixed by static target
  composition.

## Disposition

Captured. Promotion requires triage into an Exploration or Proposal; this item
does not add configuration generation to the MVP.

## References

- [RFC-006: GiftUI Capability System Architecture](../rfcs/rfc-006-capability-system-architecture.md)
