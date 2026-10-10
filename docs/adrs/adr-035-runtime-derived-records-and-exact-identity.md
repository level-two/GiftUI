---
id: ADR-035
feature: external-application-integration
title: Runtime-Derived Records and Exact Identity
status: accepted
authors:
  - codex
created: 2026-10-10
updated: 2026-10-10
proposal:
  - PROPOSAL-007
related_rfcs:
  - RFC-014
related_adrs:
  - ADR-006
  - ADR-008
  - ADR-011
  - ADR-032
  - ADR-033
related_specs:
  - SPEC-006
  - SPEC-007
  - SPEC-010
  - SPEC-011
  - SPEC-013
  - SPEC-015
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: ITERATION-003
---

# ADR-035: Runtime-Derived Records and Exact Identity

## Status

Accepted by Eugene on 2026-10-10: “Let's accept ADRs and commit everything.
And after that let's proceed with specs update.” The
[acceptance record](../iterations/iteration-003-review/rfc-014-adr-acceptance.md)
preserves the reviewed commits, supersession and downstream contract gate.

## Context

Accepted PROPOSAL-007 and its runtime scope amendment require actual declaration
and state-dependent graph derivation for the analyzer and finite counter under
ITERATION-003 I3-04 / IT-AC-006. The four configurations are macOS Dynamic and
Static, Raspberry Pi 1 ARMv6 Dynamic, and nRF52840 Embedded Static. The closed
MVP supplies analyzer semantics and stack regression requirements.

The production baseline still consumes generated topology. Retaining a complete
expanded typed declaration tree instead introduces large aggregate copies and
stack costs. Approved RFC-014 selects compact runtime-emitted records while
preserving Semantic Core, Layout and Interaction ownership and exact structural
identity across revisions.

## Decision Boundary

This record owns runtime occurrence construction, exact identity, semantic bank
publication and retirement. It preserves ADR-006/008/011/032/033. Scoped model
access and protocol Canvas are separate RFC-014 decisions. Exact Swift APIs,
record layouts, pool capacities and error mappings belong in Specifications;
external package partition and delivery remain RFC-013's concern.

## Decision

Semantic Core MUST traverse the actual root through its visitor and state-binding
orchestration. It MUST bind each stateful custom declaration before evaluating
its body and evaluate each encountered body once. Runtime and Layout MUST NOT
derive an additional graph or retain the expanded declaration tree.

Traversal MUST append bounded candidate occurrence records containing ordered
links, kind, an exact identity reference and a typed payload reference. Owned
text, modifier and other payloads MUST use bounded side pools. Record ordinals
MUST be local to their bank/revision, never persistent State or action identity.

Each semantic bank MUST own an exact path table encoding parent, component kind,
branch/child ordinal, concrete declaration-role tag and modifier discriminator.
Finite type-role tags MAY be generated; expanded occurrences and parent/child
topology MUST arise from actual traversal. Candidate/published path tries MUST
be reconciled by paired traversal and exact bounded child matching, comparing
complete components and endpoints. Hash matches, prefixes or equal table indices
MUST NOT establish identity. The implementation MUST prove finite child-fanout
and path-prefix bounds and account for matching scratch. With fixed fanout K,
identity processing MUST preserve O(N × K) expansion; an all-pairs O(N² × D)
identity scan inside expansion is excluded.

Candidate and published banks MUST remain disjoint. Failure MUST discard the
candidate while preserving published semantics and the governed live set.
Complete semantic publication MUST swap bank roles under the existing atomic
publication/order and failure rules. A retired bank MUST NOT be reused until
all its borrows have ended. Interaction MUST copy complete bounded committed
identity keys into its own accounted storage so action routing remains valid
after semantic-bank reuse.

Layout and Render MUST consume Semantic Core's borrowed semantic views in the
governed semantic/painter order. Neither consumer nor an application-owned layout
representation may become an alternate canonical graph. Runtime supplies storage
and phase coordination without taking over Semantic Core's expansion ownership.

All banks, paths, payloads and work stacks MUST have declared bounds. An explicit
record/path stack MUST NOT be treated as eliminating Swift body-return temporaries
or recursive generic visitor frames. Both remain in complete stack accounting.
Existing analyzer maxima, including 126 structural identities and 98 layout/render
scopes, MUST NOT be silently increased by the new representation.

The generated production path MUST remain until replacement contract and
conformance gates pass. Generated fonts, finite type roles and access adapters
may remain in the replacement; pre-expanded production topology may not.

## Rationale

Runtime emission lets declaration branches and bound state determine topology
without retaining the expanded declaration aggregate. Exact paths preserve State
and action meaning independently of allocation order or bank reuse. Separate
candidate/published banks maintain complete publication and bounded failure,
while consumer borrows retain the accepted one-way ownership graph.

The approved RFC records representative feasibility evidence, not production
integration or a measured complete resource budget. This choice makes costs
explicit without claiming that fewer copies alone prove a speedup or image fit.

## Consequences

### Positive

- Actual declarations determine topology on every supported configuration.
- State and action identity survive record reordering and bank reuse.
- Layout and Render retain a single semantic source and complete publication.
- Typed bounded payloads allow profile-specific storage without changing meaning.

### Negative

- Two semantic banks, exact path tables, payload codecs and reconciliation scratch
  require explicit capacity and lifetime management.
- Visitor specialization, body temporaries and recursive frames still have costs.
- Interaction's independently owned keys add accounted storage and copy work.
- The production migration needs semantic, action and pixel equivalence evidence;
  fixture layouts and the old conditional memory subtotal cannot supply it.

### Follow-up

- Amend/review SPEC-006/007 for traversal, borrowed inputs, record/identity contracts
  and ownership; align SPEC-010/011/013 publication, live-set and routing rules.
- Specify exact pools, limits and failure routing in SPEC-013/015. Measure actual
  linked RAM/flash, complete feasible stack/IRQ overlap and allocation reachability;
  Static's zero-heap requirement and matched Dynamic costs remain mandatory.
- Under handoff IH-4/5/6, verify declaration/branch perturbation, modifier order,
  exact identity, first-excess capacities, state preservation, last-reader cleanup,
  bank reuse and independent semantic/action/pixel equivalence on all four
  configurations. Keep transport performance obligations separate and unchanged.

## Deferred and Follow-up Work

No new deferred item. The required work above remains in RFC-014's IH-1–6
implementation handoff after ADR acceptance and Spec approval. Terminal
SPIKE-069–074 evidence stays linked through the source RFC; no successor
investigation is authorized. External delivery remains RFC-013 / ITERATION-004.

## Rejected Alternatives

### Retain the complete expanded typed declaration tree

Ordinary values simplify representation, but large aggregate/capture copies and
stack costs make this unsuitable for the selected runtime representation.

### Keep pre-expanded generated topology or a second consumer-owned graph

Generated topology violates actual runtime derivation. A second canonical graph
duplicates ownership and weakens Semantic Core's accepted responsibility.

### Use record ordinals, hashes or all-pairs matching as identity

Ordinals and hashes do not prove complete cross-revision identity. An all-pairs
scan fails the selected bounded linear-expansion approach; exact paired tries
with fixed child bounds provide the required semantics and cost model.

## References

- [Approved RFC-014](../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md), especially Runtime records and exact identity, Publication and retirement, Performance, and Decision Summary item 1.
- [Accepted PROPOSAL-007](../proposals/proposal-007-external-application-integration.md) and [runtime scope amendment](../iterations/iteration-003-review/runtime-derivation-scope-amendment.md).
- [RFC approval provenance](../iterations/iteration-003-review/rfc-014-final-review.md).
- [Implementation handoff](../iterations/iteration-003-review/rfc-014-implementation-handoff.md).
- [GiftUI Principles](../PRINCIPLES.md).
