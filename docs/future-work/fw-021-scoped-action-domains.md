---
id: FW-021
feature: giftui-mvp-architecture
title: Scoped Action Domains and Model Targets
status: captured
authors:
  - codex
created: 2026-08-27
updated: 2026-08-27
source:
  - RFC-011
  - ADR-033
  - SPEC-011
related_future_work:
  - FW-017
  - FW-020
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: null
---

# FW-021: Scoped Action Domains and Model Targets

## Observation / Opportunity

Applications beyond the Signal Analyzer may contain independently replaceable
nested observable models, reusable view libraries, or child features whose
actions must route to different typed handlers. RFC-011's one finite action
domain bound to one root model does not establish how such scopes compose,
transform child actions into parent actions, inherit handlers, or preserve
target identity across insertion and removal.

## Why Deferred

The MVP Signal Analyzer has exactly one structurally owned root ViewModel and
one finite action domain. It needs no environment dispatch, child reducer,
public binding, arbitrary action payload, runtime registry, or dynamic feature
tree. Choosing those semantics now would expand the MVP and could constrain
declarative identity and observable-state architecture without a concrete
application requirement.

## Potential Value

- Permit reusable child views to emit their own typed actions without knowing
  an application root action vocabulary.
- Route actions safely to multiple independently replaced model locations.
- Support explicit child-to-parent action transformation without callback
  capture or global identifier registries.

## Current Non-goals

- No action environment, reducer hierarchy, scoped store, action mapping
  modifier, public binding, runtime action registry, or dynamic feature graph is
  added to the MVP.
- RFC-011 and SPEC-011 remain limited to one Signal Analyzer action domain and
  one root observable-model target.
- This item does not select an Elm, Redux, Composable Architecture, SwiftUI
  environment, key-path, or callback-based design.

## Revisit Triggers

- An accepted application Proposal requires two independently replaceable
  observable model targets in one portable hierarchy.
- A maintained reusable GiftUI view library must emit a child action without
  depending on the consuming application's root action enum.
- Promotion of FW-017 or FW-020 requires a public action-scope or transformation
  contract to preserve state and interaction identity.
- Static-profile evidence demonstrates a bounded nested-domain representation
  and a concrete application requirement justifies its RAM, flash, and generic
  specialization cost.

## Disposition

Captured as post-MVP work. When a trigger fires, triage the concrete use case
and promote it to a Proposal or Exploration; do not treat RFC-011's single-root
binding as preapproval for a generalized action architecture.

## References

- [RFC-011: Bounded Application Actions and Model-Target Dispatch](../rfcs/rfc-011-bounded-application-actions.md)
- [ADR-033: Bounded Application Actions and Model-Target Dispatch](../adrs/adr-033-bounded-application-actions-and-model-target-dispatch.md)
- [FW-017: Public Binding Abstraction](fw-017-public-binding-abstraction.md)
- [FW-020: Declarative Extensibility](fw-020-declarative-extensibility.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
