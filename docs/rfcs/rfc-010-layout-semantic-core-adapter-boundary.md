---
id: RFC-010
feature: giftui-mvp-architecture
title: Layout and Semantic Core Adapter Boundary
status: approved
authors:
  - codex
created: 2026-08-26
updated: 2026-08-26
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
related_adrs:
  - ADR-005
  - ADR-008
  - ADR-032
related_specs:
  - SPEC-006
  - SPEC-007
  - SPEC-008
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# RFC-010: Layout and Semantic Core Adapter Boundary

## Summary

This RFC selects one narrow source-level dependency from `GiftUILayout` to
`GiftUISemanticCore`. Semantic Core would own a borrowed, immutable layout
input view over the complete successful semantic result, including structural
and modifier-scope identity, typed layout payloads, and ordered children.
Layout would consume that view while retaining sole ownership of measurement,
placement, text geometry, layout limits, and resolved layout results.

The proposal changes RFC-002's physical module graph. RFC-002 currently places
the semantic-child adapter in `GiftUILayout` and requires the runtime to adapt
semantic children to it, allowing `GiftUILayout` to depend only on `GiftUI`
and `GiftUITextResources`. SPEC-007 cannot introduce the alternative direct
dependency without this RFC, a later accepted ADR, and a corresponding
Specification revision.

Alternative B is the approved direction. Approval establishes reviewed design
consensus but does not itself authorize implementation. The dependency still
requires an accepted ADR and a corresponding approved SPEC-007 revision before
implementation may rely on it.

## Context

[PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
authorizes architecture sufficient for one substantially shared Signal
Analyzer presentation across macOS dynamic, macOS static, Raspberry Pi/Linux
dynamic, and nRF52840 static configurations.

[RFC-002](rfc-002-giftui-mvp-layered-architecture.md) and
[ADR-005](../adrs/adr-005-semantic-layout-render-boundary.md) assign semantic
expansion and identity to GiftUI above layout, assign proposal-based layout to
GiftUI above rendering, and prohibit backends from acquiring either authority.
[ADR-008](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
requires an acyclic compiler-visible target graph inside one Swift package.

Approved [SPEC-006](../specs/spec-006-declarative-view-semantics.md) makes
`GiftUISemanticCore` the owner of structural paths, structural identity,
modifier scopes, semantic occurrences, and the complete staged semantic
result. Draft [SPEC-007](../specs/spec-007-layout.md) needs all of those facts
to measure modifier scopes, associate resolved geometry with exact identity,
and traverse children in canonical source order.

The first SPEC-007 review found that the draft required a direct
`GiftUISemanticCore` dependency without routing that change through the
architecture lifecycle. It also found that merely saying “complete successful
semantic result” did not define a reviewable input boundary. This RFC resolves
the architectural ownership choice only; SPEC-007 must define the exact
borrowed APIs after the decision is accepted.

## Scope and Decision Boundary

The decision cluster is the physical ownership and dependency direction of the
semantic-to-layout input contract:

- which module owns the immutable layout-facing view of semantic structure;
- whether `GiftUILayout` imports `GiftUISemanticCore` directly;
- which semantic facts cross that edge; and
- which facts and authorities are prohibited from crossing it.

This concern is independently reviewable because either choice preserves
RFC-002's semantic, layout, render, runtime, and backend responsibility layers.
It can be accepted or rejected without changing public view syntax, layout
algorithms, text-resource ownership, rendering operations, frame transactions,
runtime storage strategy, backend behavior, or host composition.

RFC-002 remains the integrating layer and package architecture. RFC-010 would
refine only its layout-input edge. SPEC-006 continues to own semantic expansion
and identity. SPEC-007 continues to own exact layout input APIs, algorithms,
outputs, errors, capacities, and conformance fixtures after an accepted ADR
selects the dependency direction.

## Requirements

- One exact structural and modifier-scope identity relation MUST cross from a
  successful semantic result into layout without string keys, hashes used as
  equality, parallel identity types, or profile-specific semantic behavior.
- Static and dynamic runtimes MUST present the same observable ordered semantic
  structure and layout-relevant payload meaning.
- Layout MUST synchronously borrow its semantic input and MUST NOT retain a
  semantic node, payload, child view, declaration value, or callable action.
- The dependency graph MUST remain acyclic and compiler-enforced.
- Layout MUST retain sole authority for proposal propagation, measurement,
  placement, canonical text geometry, logical clipping, and resolved results.
- Semantic Core MUST retain sole authority for expansion, structural identity,
  modifier scope, semantic/action occurrence identity, and semantic ordering.
- The boundary MUST support caller-owned finite layout workspace and zero heap
  allocation on the static path.
- The boundary MUST be independently recordable and testable without a runtime
  profile implementation, renderer, backend, platform, or hardware.

## Constraints

- `GiftUI` remains the sole portable Presentation import and cannot import or
  re-export Semantic Core or layout.
- `GiftUITextResources` remains a sibling leaf imported by layout and cannot
  import Semantic Core.
- `GiftUIRenderCore` remains a sibling of layout and cannot use this edge to
  acquire layout authority.
- `GiftUISemanticCore` cannot import `GiftUILayout`; the proposed dependency is
  one-way.
- The boundary cannot expose state storage, invalidation mutation, action
  payloads, committed action generations, hit dispatch, frame state, backend
  objects, platform handles, or target identity.
- Embedded Swift conformance cannot require allocation, reflection, `Any`, an
  unrestricted existential, runtime discovery, Objective-C, `Task`, or
  `MainActor`.
- Exact SPI spellings, storage representations, limits, and error cases remain
  Specification work and cannot silently add another architectural owner.

## Proposed Design

`GiftUISemanticCore` owns one package-scoped, read-only layout input view over
a complete successful semantic expansion. The view exposes only facts already
owned by SPEC-006 plus typed layout-relevant declaration payloads introduced
through SPEC-006's sealed traversal surface:

- exact structural or modifier-scope identity;
- semantic occurrence kind and layout-relevant typed payload;
- ordered child access in canonical source order;
- ordered layout modifier scopes and their typed payloads;
- action-bearing occurrence identity only as ordinary semantic identity, with
  no callable payload or committed action generation; and
- borrowed text content associated with the relevant semantic occurrence once
  the public text declaration contract exists.

`GiftUILayout` imports `GiftUISemanticCore` and consumes this borrowed view. It
does not consume a runtime-owned graph, retained node representation, state
store, action map, or runtime profile. The view's concrete storage may differ
between recording, static, and dynamic producers, but its equality, ordering,
and borrowing semantics are profile-neutral.

`GiftUILayout` continues to own:

- the layout entry point and its caller-owned workspace;
- layout limits, local errors, summaries, and recording results;
- proposal propagation and every measurement/placement algorithm;
- canonical text measurement and positioned logical glyph geometry;
- resolved bounds and logical clips for semantic and modifier scopes; and
- the sink or result contract consumed later by runtime coordination and
  rendering.

The dependency graph becomes:

```text
GiftUILayout -------> GiftUISemanticCore -> GiftUI
       |------------> GiftUITextResources -> GiftUI

runtime profiles ---> GiftUISemanticCore
       |------------> GiftUILayout
```

No reverse edge exists. Runtime profiles remain storage and coordination
implementations; they do not own the semantic-to-layout contract. Render Core
continues to receive resolved layout through its separately governed
coordinator boundary and does not import `GiftUILayout` through this RFC.

The exact semantic layout-view protocol, typed payload cases, iteration shape,
scope-identity value, layout entry point, and recording fixtures belong in a
revised SPEC-007 after an ADR is accepted. Those declarations must make every
borrow nonescaping and allow generic specialization or another bounded static
representation without changing observable meaning.

## Module Responsibilities

| Module | Responsibility | Dependency impact |
| --- | --- | --- |
| `GiftUI` | Public declarations and typed semantic payload declarations | Imports neither Semantic Core nor layout |
| `GiftUISemanticCore` | Expansion, structural/modifier-scope identity, and the borrowed layout-facing semantic view | Depends on `GiftUI`; imports no layout or runtime implementation |
| `GiftUILayout` | Measurement, placement, canonical text geometry, logical clips, limits, results, and layout recording | Depends on `GiftUI`, `GiftUISemanticCore`, and `GiftUITextResources` |
| Runtime profiles | Profile-specific semantic storage and semantic-to-layout coordination | Depend on Semantic Core and layout; neither contract depends on a runtime profile |
| `GiftUIRenderCore` | Normalized rendering from resolved semantic/layout inputs under its own contract | Gains no dependency or authority from this RFC |

## Public API Impact

None. Portable Presentation continues to use only `import GiftUI`. No semantic
identity, semantic snapshot, layout node, adapter, workspace, or runtime
profile becomes public Client API.

## Capabilities Impact

None. The semantic-to-layout input view carries no Capability contribution,
effective result, contributor identity, or absence policy. Capability state
cannot select a different semantic representation or layout algorithm through
this boundary.

## Backend Impact

None. A backend cannot import or consume the semantic layout view and cannot
use the proposed edge to evaluate declarations, inspect modifier scopes,
perform layout, remeasure text, or obtain action payloads.

## Static / Embedded Impact

The view must be usable as a synchronous borrow over generated or caller-owned
semantic storage. Static conformance may specialize generic traversal and
identity representations, but it cannot allocate, copy a complete tree merely
to cross the module edge, or retain borrowed semantic storage after layout
returns.

SPEC-007 must bound traversal depth, child access, modifier access, identity
representation, and layout workspace independently of this RFC. Cross-built
nRF52840 evidence must prove the selected declarations compile under Embedded
Swift with the required hard-float calling convention.

## Performance

The semantic-view traversal and layout input access must remain linear in the
admitted semantic occurrences and modifier applications. An occurrence,
modifier scope, or child edge must not be copied into a second complete
profile-neutral tree solely to satisfy the module boundary.

Conformance evidence must separately report semantic-view traversal work and
layout work so a direct import cannot hide an additional expansion or
materialization pass.

## Memory / Binary Size

The proposed direct dependency may add cross-module generic specialization and
metadata. It must not add a second retained semantic graph, duplicate identity
storage, or require a complete adapter-owned node array. SPEC-007 and the later
runtime-profile contract must report incremental code size, workspace bytes,
stack high-water, and any per-occurrence bridge storage for the Signal Analyzer
fixture.

If measured module or specialization cost makes the direct edge infeasible on
nRF52840, the architecture must return to RFC review rather than collapsing
semantic and layout ownership in implementation.

## Alternatives

### Alternative A — Keep the RFC-002 layout-owned adapter

`GiftUILayout` owns a consumer protocol and each runtime or recording producer
adapts semantic children into it. This keeps layout independent of Semantic
Core and preserves RFC-002's existing physical graph. It also makes layout's
input needs locally explicit.

The cost is a second contract representation for structural and modifier-scope
identity, plus adapter code in every producer. The adapter must either expose
Semantic Core's identities through a type parameter or reconstruct equivalent
scope identity and traversal meaning without introducing parallel identity.
This alternative would remain preferable if a narrow layout-owned protocol
could express the complete contract without identity translation or profile
duplication. Review did not select it because the adapter would duplicate the
Semantic Core-owned identity and traversal contract across recording, static,
and dynamic producers without satisfying a distinct MVP ownership need.

### Alternative B — Direct `GiftUISemanticCore` dependency

This RFC's proposal makes the existing owner of structural identity and
modifier scopes expose their immutable layout-facing view once. Layout consumes
the exact semantic meanings rather than requiring each runtime to reproduce an
adapter. It adds a source dependency from layout to Semantic Core and therefore
must keep the view narrower than runtime storage or behavior.

This alternative is selected because one sealed borrowed view avoids identity
translation, duplicated adapters, and profile drift while preserving the
accepted semantic/layout authority split and the Embedded Swift constraints.

### Alternative C — Add a neutral semantic-layout contract target

A new leaf target could own identity and the layout-facing view while Semantic
Core and layout both depend on it. This preserves sibling modules but moves
part of structural identity out of its current SPEC-006 owner and adds another
target, import boundary, metadata cost, and compatibility surface.

It becomes preferable only if Semantic Core and layout require a genuinely
independent shared contract whose ownership is coherent outside both modules.
No current requirement demonstrates that need.

### Alternative D — Keep the adapter inside runtime profiles

Each runtime could expose its own semantic-to-layout entry point. This reduces
shared SPI but makes the profile implementation the contract owner and risks
different layout input meaning across static and dynamic paths. It conflicts
with ADR-006's shared-semantics requirement and is not proposed.

## Rejected Approaches

- **Alternative A, the layout-owned adapter, is not selected.** It preserves
  RFC-002's original physical edge but requires every semantic producer to
  adapt or reproduce identity, scope, payload, and traversal meaning already
  owned by Semantic Core.
- **Alternative C, a neutral contract target, is not selected.** No current
  requirement justifies moving structural identity out of Semantic Core or
  paying for another target and compatibility surface.
- **Alternative D, runtime-owned adapters, is rejected.** It makes runtime
  profiles own or duplicate a shared semantic-to-layout contract and conflicts
  with ADR-006's profile-equivalent semantics.

Duplicated identity types, string or hash-only scope identity, backend access
to semantic input, and bidirectional imports remain outside the acceptable
option set because they conflict with existing accepted decisions.

## Compatibility

The proposal changes package-internal target dependencies and SPI only. It
does not change portable source syntax or establish ABI or serialized identity
compatibility.

Proof-of-concept runtime-local node traversal is evidence only. Migration must
not preserve a runtime-specific adapter as a second authoritative path after
the selected contract is implemented.

## Testing Strategy

- Import-graph tests prove the exact one-way
  `GiftUILayout -> GiftUISemanticCore -> GiftUI` edge and reject the reverse
  edge, runtime imports from either contract, and backend access.
- A Semantic Core recording fixture supplies the complete borrowed layout view
  without a runtime profile implementation.
- Static and dynamic producer fixtures expose identical occurrence kinds,
  child order, modifier-scope order, scope-identity equality, and typed layout
  payload meaning.
- Borrow instrumentation proves layout retains no semantic node, payload,
  identity view, text source, or declaration storage after return.
- Negative fixtures prove action payloads, state storage, runtime nodes,
  backend objects, and target identity cannot cross the view.
- Allocation and object-layout evidence proves static traversal adds no heap
  allocation or second retained semantic graph.
- nRF52840 cross-build evidence records compiler identity, hard-float ELF
  attributes, bridge-related linked code, workspace bytes, and stack use.

## Risks

- **Semantic Core becomes a broad dependency bucket.** Keep its layout-facing
  view closed to semantic facts already owned there and require SPEC-007 to
  reject any runtime, rendering, backend, or policy field.
- **The direct edge exposes storage representation.** Specify borrowed behavior
  and equality, not a retained node layout or profile-private bytes.
- **Generic specialization raises embedded code size.** Measure the exact
  Signal Analyzer fixture and return to architecture review if the cost is
  material.
- **Rendering acquires semantic authority by analogy.** This RFC changes only
  layout input; any Render Core dependency change requires its own authority.
- **Two adapter paths survive migration.** Dependency and conformance tests
  must fail if runtime-owned and Semantic-Core-owned layout inputs coexist.

## Open Questions

None remained at approval. Alternative B is the approved direction.

The resulting ADR should refine ADR-008 without superseding it. ADR-008 owns
the acyclic compiler-enforced multi-target topology, one-package MVP
distribution, and narrow portable `GiftUI` import surface; it does not freeze
every internal target edge. The selected one-way
`GiftUILayout -> GiftUISemanticCore` dependency preserves that decision while
refining RFC-002's more specific physical module graph. RFC approval establishes
the selected direction; the refinement becomes authoritative architecture only
when the resulting ADR is accepted.

## Deferred and Follow-up Work

None. Exact SPI spelling, limits, errors, and conformance commands are required
SPEC-007 work after the architecture gate and are not deferred architecture.

## Decision Summary

This approved RFC requires one ADR to record that
`GiftUISemanticCore` owns a narrow borrowed layout-facing semantic view and
that `GiftUILayout` may depend directly on it while semantic, layout, runtime,
rendering, and backend authorities remain unchanged. That ADR should refine
ADR-008 without superseding it.

## References

- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002: GiftUI MVP Layered Architecture](rfc-002-giftui-mvp-layered-architecture.md)
- [ADR-005: Semantic, Layout, and Render Boundary](../adrs/adr-005-semantic-layout-render-boundary.md)
- [ADR-008: Module Dependency Graph and MVP Package Topology](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
- [SPEC-006: Declarative View Semantics](../specs/spec-006-declarative-view-semantics.md)
- [SPEC-007: Proposal-Based Layout](../specs/spec-007-layout.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [MVP Specification Portfolio](../roadmap/MVP_SPECIFICATION_PORTFOLIO.md)
- Current proof-of-concept semantic and layout sources under `Sources/` —
  feasibility evidence only
