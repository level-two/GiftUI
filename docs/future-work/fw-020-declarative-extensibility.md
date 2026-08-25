---
id: FW-020
feature: giftui-mvp-architecture
title: Declarative Extensibility
status: captured
authors:
  - codex
created: 2026-08-25
updated: 2026-08-25
source:
  - SPEC-006
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-020: Declarative Extensibility

## Observation / Opportunity

Applications beyond the Signal Analyzer may need declarative facilities that
SPEC-006 intentionally excludes: unrestricted or data-driven child
collections, keyed collection identity, public type erasure, public custom
modifiers, or client-visible explicit view identity. These facilities interact
through structural identity, state lifetime, modifier lowering, and bounded
static storage, so adding one may constrain the others.

## Why Deferred

The fixed Signal Analyzer hierarchy is expressible with custom views and
zero-through-five fixed builder composition. None of these extensions is
required to validate Rank 0 or any MVP target stack, and accepted architecture
does not yet select their ownership, lifetime, compatibility, or static-profile
semantics.

## Potential Value

- Express variable application data without manually nesting fixed groups.
- Preserve stable state and interaction identity across collection edits.
- Permit reusable modifier abstractions or intentionally erased view storage
  when a concrete feature can justify their cost.

## Current Non-goals

- No `ForEach`, `buildArray`, keyed collection, `AnyView`-like erasure,
  public custom-modifier protocol, explicit identity API, registry, or dynamic
  plug-in surface is added to SPEC-006 or the MVP.
- This capture does not choose one combined design or imply that all listed
  facilities must be promoted together.
- It does not weaken SPEC-006 fixed composition, identity, allocation, or
  traversal requirements.

## Revisit Triggers

- An accepted feature Proposal requires a child count determined by runtime
  application data rather than a fixed declaration hierarchy.
- An approved observable-state or interaction contract requires stable keyed
  identity across insertion, removal, or reordering.
- Two maintained view libraries require a public custom-modifier or type-
  erasure boundary that cannot be expressed with opaque view returns.
- Static-profile measurements demonstrate a bounded representation for one of
  these facilities and a concrete application requirement justifies its RAM,
  flash, and specialization cost.

## Disposition

Captured as post-MVP work. When a trigger fires, triage the concrete facility
independently and promote through a Proposal or Exploration as appropriate;
do not treat this cluster as one preapproved architecture.

## References

- [SPEC-006: Declarative View Semantics Specification](../specs/spec-006-declarative-view-semantics.md)
- [FW-017: Public Binding Abstraction](fw-017-public-binding-abstraction.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
