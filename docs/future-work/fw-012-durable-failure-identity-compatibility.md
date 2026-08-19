---
id: FW-012
feature: giftui-mvp-architecture
title: Durable Failure Identity Compatibility
status: captured
authors:
  - Yauheni Lychkouski
created: 2026-08-19
updated: 2026-08-19
source:
  - RFC-005
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-012: Durable Failure Identity Compatibility

## Observation / Opportunity

RFC-005's proposed MVP contract uses typed source-level failure identities and
shared conformance fixtures without promising that numeric representations
remain stable across builds or software versions. At a later maturity level,
GiftUI may need durable identities for persisted diagnostic records,
host/device protocols, external symbolization, fleet analysis, or other tools
that consume a condition outside the binary that produced it.

The future design space includes keeping values stable only within a declared
catalogue or product version, establishing a durable cross-version numeric
registry, or retaining source-level identity if no concrete consumer justifies
either compatibility promise.

## Why Deferred

No current MVP requirement identifies a tool, stored record, or device message
that must interpret a numeric failure identity from another build. Selecting a
registry, allocation process, versioning model, unknown-value behavior, or
serialization contract now would add permanent governance and compatibility
cost without improving Signal Analyzer behavior or validation of the four MVP
configurations.

## Potential Value

- Allow future tools to interpret failure records after the producing binary
  or software version is no longer available.
- Give host/device protocols an explicit way to negotiate or reject mismatched
  failure catalogues.
- Support stable external symbolization or aggregation when a concrete
  operational need justifies its long-term compatibility cost.

## Current Non-goals

- No cross-build numeric stability, serialized error ABI, numeric registry,
  telemetry schema, or version negotiation is added to RFC-005 or MVP scope.
- MVP failure numbers, if a Specification uses them internally, must not be
  treated as durable identifiers outside the producing build.
- This item does not select among version-scoped values, a durable registry,
  or source-level-only identity.

## Revisit Triggers

- An accepted post-MVP Proposal or approved Specification requires persisted
  failure records to remain interpretable across software builds or versions.
- An accepted host/device or inter-process protocol requires a failure
  identity produced by one build to be consumed by another.
- Approved diagnostic or fleet tooling requires external symbolization or
  aggregation without access to the exact producing binary's identity map.
- Evidence from at least two independently versioned producers or consumers
  shows that source-level identities and per-build conformance fixtures no
  longer provide sufficient interoperability.

## Disposition

Captured. When a trigger occurs, promote this item to an Exploration if the
compatibility lifetime and consumers still need evidence, or to a Proposal if
GiftUI is ready to evaluate the post-MVP investment. Any resulting architecture
and contract must pass the normal RFC, ADR, and Specification gates.

## References

- [RFC-005: Failure and Diagnostics Propagation Architecture](../rfcs/rfc-005-failure-diagnostics-propagation.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
