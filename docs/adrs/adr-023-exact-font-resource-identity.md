---
id: ADR-023
feature: giftui-mvp-architecture
title: Exact Font Resource Identity and Ownership
status: accepted
authors:
  - Yauheni Lychkouski
created: 2026-08-20
updated: 2026-08-25
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-003
related_adrs:
  - ADR-005
  - ADR-008
  - ADR-020
  - ADR-021
  - ADR-022
related_specs:
  - SPEC-005
  - SPEC-007
  - SPEC-008
related_future_work:
  - FW-003
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-023: Exact Font Resource Identity and Ownership

## Status

Accepted.

## Context

Canonical text measurement and rasterization may use separately stored metric,
outline, or bitmap assets. Without one exact identity and contract owner,
layout and raster providers could silently use incompatible resources or
require adapters that translate identity across layers.

## Decision Boundary

This record extracts RFC-003 Decision Summary item 3. It owns the one exact
resource-set identity, compatibility invariant, shared contract owner, and
host lifetime for selected immutable resources. It does not choose concrete
font assets, package schemas, shaping/raster implementations, cache policy,
licensing terms, or resource budgets.

## Decision

One immutable font-resource-set identity MUST join the canonical character
mapping, metrics, admitted shaping data, and every selectable exact outline or
bitmap raster realization. Build and assembly tooling MUST validate those
views as one compatible resource set. Missing, mismatched, malformed, or
unsupported resources MUST fail deterministically and MUST NOT cause ambient
font substitution.

The dedicated `GiftUITextResources` target/module MUST be the sole physical
owner of font-resource, font-instance, and glyph identity types; canonical
metrics/shaping and raster-resource view contracts; and their compatibility
and integrity facts. It MUST depend only on portable values from `GiftUI` and
MUST NOT own concrete assets, discovery, layout or raster implementation,
cache policy, platform handles, or backend selection.

`GiftUILayout`, `GiftUIRenderCore`, raster providers, concrete packages, and
tooling MUST depend on that shared owner as applicable. They MUST NOT introduce
parallel or translated identity types. The target host MUST own the selected
immutable concrete resource package for the assembled runtime lifetime.

## Rationale

One identity makes compatible metrics and raster payloads a compiler-visible
invariant while keeping their implementations in sibling layers. A dedicated
leaf avoids overloading `GiftUI` or creating an upward dependency between
layout and render core.

## Consequences

### Positive

- Layout and rasterization provably refer to the same exact resource set.
- Outline and precompiled bitmap realizations share one logical text contract.
- The module graph keeps layout, render core, and raster providers as siblings.

### Negative

- The dedicated target adds module, metadata, and specialization cost that
  must be measured.
- Resource packages and tooling must maintain compatibility and integrity
  metadata.

### Follow-up

- Specifications must define identity fields, package schema, resource views,
  integrity validation, lifetimes, access control, licensing, bounds, and
  concrete reference-resource evidence.

## Deferred and Follow-up Work

- [FW-003](../future-work/fw-003-advanced-font-delivery-and-glyph-rasterization.md)
  preserves runtime registration, resampling, distance fields, compression,
  and advanced shared caching.

## Rejected Alternatives

### Own all shared contracts in `GiftUI`, layout, or render core

Rejected because those placements either overload the client leaf or create
an upward import between sibling layers.

### Split consumer-owned views around a minimal identity

Rejected because no one compiler-visible owner would enforce compatibility
between metrics and raster resources.

### Separate metric and raster identities

Rejected because every loader and build path would need an additional runtime
compatibility relation without an MVP benefit.

## References

- [RFC-003: Deterministic Text Rendering Architecture](../rfcs/rfc-003-deterministic-text-rendering-architecture.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [GiftUI Principles](../PRINCIPLES.md)
