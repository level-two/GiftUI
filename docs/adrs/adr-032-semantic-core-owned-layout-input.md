---
id: ADR-032
feature: giftui-mvp-architecture
title: Semantic-Core-Owned Borrowed Layout Input
status: accepted
authors:
  - codex
created: 2026-08-26
updated: 2026-08-26
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-010
related_adrs:
  - ADR-005
  - ADR-006
  - ADR-008
related_specs:
  - SPEC-006
  - SPEC-007
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# ADR-032: Semantic-Core-Owned Borrowed Layout Input

## Status

Accepted.

## Context

GiftUI layout needs the complete successful semantic structure owned by
`GiftUISemanticCore`, including exact structural and modifier-scope identity,
typed layout-relevant payloads, and canonical child order. RFC-002 originally
placed a consumer adapter in `GiftUILayout`, requiring each runtime or
recording producer to adapt semantic children into a second contract.

[RFC-010](../rfcs/rfc-010-layout-semantic-core-adapter-boundary.md) approved
Alternative B: Semantic Core owns one immutable layout-facing view and layout
imports it directly. The decision must preserve ADR-005's semantic/layout
authority split, ADR-006's profile-equivalent behavior, and ADR-008's acyclic
compiler-enforced module graph while remaining viable for the bounded static
path.

## Decision Boundary

This record extracts RFC-010's single Decision Summary item. It owns the
semantic-to-layout input contract owner, the one-way module dependency, the
facts permitted across that edge, and the required borrow semantics. It does
not define exact SPI declarations, storage representation, layout algorithms,
limits, errors, rendering input, runtime coordination, or backend behavior.

## Decision

`GiftUISemanticCore` MUST own one package-scoped, read-only layout-facing view
over a complete successful semantic result. The view MUST expose only exact
structural or modifier-scope identity, semantic occurrence kind, typed
layout-relevant payloads, canonical ordered children, ordered layout modifier
scopes and payloads, ordinary semantic identity for action-bearing
occurrences without callable actions or committed generations, and borrowed
text content associated with its semantic occurrence.

`GiftUILayout` MUST depend directly and one-way on `GiftUISemanticCore` and
MUST synchronously borrow that view. It MUST NOT retain semantic nodes,
payloads, identities, declaration values, text sources, or actions after the
layout call returns. `GiftUISemanticCore` MUST NOT import `GiftUILayout`.

The view MUST preserve identical identity equality, ordering, and payload
meaning across recording, static, and dynamic producers while allowing their
concrete storage to differ. Crossing this boundary MUST NOT allocate, copy a
complete semantic tree into a second profile-neutral representation, or
require a runtime-profile implementation on the static path.

Semantic Core retains sole authority for expansion, structural and
modifier-scope identity, semantic/action occurrence identity, and semantic
ordering. Layout retains sole authority for proposal propagation,
measurement, placement, canonical text geometry, logical clipping, layout
limits and failures, and resolved layout results. Runtime profiles, rendering,
backends, platforms, and hardware gain no semantic or layout authority through
this dependency.

This decision refines ADR-008 without superseding it. The resulting graph
remains acyclic, `GiftUI` remains the sole portable Presentation import, and
the one-package multi-target MVP topology remains unchanged.

## Rationale

Semantic Core already owns the exact identities, scopes, ordering, and staged
semantic result required by layout. A single sealed borrowed view lets layout
consume those meanings without parallel identity types or producer-specific
adapters. Keeping the edge one-way preserves compiler-enforced ownership,
while the synchronous nonretaining contract permits generated or caller-owned
bounded storage for Embedded Swift.

## Consequences

### Positive

- Layout consumes one exact identity and traversal meaning across recording,
  static, and dynamic producers.
- Runtime profiles do not duplicate or own the semantic-to-layout contract.
- The boundary can be recorded and tested without rendering, a backend, or a
  concrete runtime profile.
- Portable client source continues to require only `import GiftUI`.

### Negative

- `GiftUILayout` gains a direct source dependency on `GiftUISemanticCore`.
- Semantic Core must maintain a narrow layout-facing SPI without exposing its
  storage representation or becoming a general dependency bucket.
- Cross-module generic specialization and metadata may increase embedded code
  size and must be measured.
- Migration must remove the RFC-002 layout-owned and runtime-owned adapter
  paths rather than retaining two authoritative inputs.

### Follow-up

- Revise SPEC-007 to define the exact nonescaping semantic layout-view SPI,
  typed payload cases, identity values, iteration shape, layout entry point,
  limits, errors, and recording fixtures.
- Add import-graph and negative dependency tests for the exact one-way edge
  and prohibited runtime, rendering, backend, and reverse imports.
- Compare static and dynamic fixture meaning and prove that static traversal
  adds no heap allocation or second complete semantic graph.
- Record nRF52840 cross-build, hard-float ELF, workspace, stack, and linked-code
  evidence for the final declarations before SPEC-007 approval.

## Deferred and Follow-up Work

None. Exact declarations, finite bounds, errors, and conformance evidence are
required SPEC-007 work rather than optional deferred architecture.

## Rejected Alternatives

### Keep the RFC-002 layout-owned adapter

Rejected because every semantic producer would need to adapt or reproduce
identity, scope, payload, and traversal meaning already owned by Semantic Core,
creating translation and profile-drift risks without a distinct MVP owner.

### Add a neutral semantic-layout contract target

Rejected because no current requirement justifies moving structural identity
out of Semantic Core or adding another target, import boundary, metadata cost,
and compatibility surface.

### Keep adapters inside runtime profiles

Rejected because runtime profiles would own or duplicate a shared contract,
contrary to profile-equivalent semantic meaning and independently testable
semantic and layout ownership.

## References

- [RFC-010: Layout and Semantic Core Adapter Boundary](../rfcs/rfc-010-layout-semantic-core-adapter-boundary.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [ADR-005: Semantic, Layout, and Render Boundary](adr-005-semantic-layout-render-boundary.md)
- [ADR-006: Shared Semantics Across Runtime Profiles](adr-006-shared-semantics-runtime-profiles.md)
- [ADR-008: Module Dependency Graph and MVP Package Topology](adr-008-module-dependency-graph-and-package-topology.md)
- [SPEC-006: Declarative View Semantics](../specs/spec-006-declarative-view-semantics.md)
- [SPEC-007: Proposal-Based Layout](../specs/spec-007-layout.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Principles](../PRINCIPLES.md)
