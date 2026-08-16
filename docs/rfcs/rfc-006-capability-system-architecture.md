---
id: RFC-006
feature: capability-system
title: GiftUI Capability System Architecture
status: draft
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-16
proposal:
  - PROPOSAL-004
related_rfcs:
  - RFC-002
  - RFC-004
  - RFC-005
  - RFC-007
related_adrs:
  - ADR-001
related_specs: []
related_future_work:
  - FW-006
  - FW-007
  - FW-008
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# RFC-006: GiftUI Capability System Architecture

## Summary

This RFC is the independently governed capability decision cluster authorized
by PROPOSAL-004. It proposes that GiftUI distinguish:

1. structural build selection — which implementation families exist;
2. semantic capability resolution — what behavior the assembled stack can
   promise under explicit constraints; and
3. operational state — whether an already configured facility is currently
   healthy or able to accept work.

The MVP architecture is catalogue-first. A capability family may enter the
implemented system only when a Signal Analyzer or target-validation fixture
demonstrates a real semantic difference or quantitative constraint. The RFC
does not authorize a general Trait framework, optimizer, plugin registry,
mutable capability store, or speculative feature catalogue.

## Context

The same portable Signal Analyzer presentation must run on macOS dynamic,
macOS static, Raspberry Pi/Linux dynamic, and nRF52840 static stacks. Those
stacks differ in storage, surface, transfer, input, and presentation mechanics.
A capability system is needed only where those differences affect a semantic
promise or a bound that determines conformance.

[ADR-001](../adrs/adr-001-signal-analyzer-application-boundaries.md) makes the
target host the application composition root and keeps concrete target
identity out of portable Presentation. RFC-002 proposes the framework layer
graph and contract seams. This RFC cannot be folded into RFC-002 because it has
its own accepted Proposal, alternatives, policy model, and future evolution.

The proof of concept's flags and target checks are evidence to classify, not a
catalogue to migrate automatically.

## Requirements

### R1 — Semantic, not target identity

A Capability MUST describe client- or framework-relevant behavior and bounds.
Portable code MUST NOT infer support from platform, backend, board, driver,
controller, transport, or device identity.

### R2 — Catalogue-first inclusion

Every MVP capability family and field MUST cite a concrete Signal Analyzer or
supported-configuration fixture. A fact with no such fixture MUST be removed
from the MVP catalogue or routed to deferred work.

### R3 — Owned contributions

Each selected component MAY contribute typed facts it owns without importing a
higher or concrete integration layer. A component MUST NOT independently claim
end-to-end semantic support outside its responsibility.

### R4 — Deterministic resolution

The same requirements, owned contributions, structural selection, and policy
MUST produce the same effective capability result independent of registration,
discovery, or iteration order.

### R5 — Support, realization, and policy separation

The system MUST distinguish whether behavior is conformingly available, which
software or hardware path realizes it, and which conforming path target policy
selects. Policy MUST NOT manufacture support or weaken required semantics.

### R6 — Preserve relevant constraints

Availability MUST NOT be reduced to a Boolean when dimensions, formats,
capacities, completion mode, alignment, or another bound determines whether a
use is valid.

### R7 — Explicit absence

Each requirement MUST state required or optional status and absence behavior.
Missing required MVP behavior MUST invalidate configuration before runtime
start when its facts are knowable during composition or initialization.

### R8 — Immutable declaration, separate health

Effective capability declarations MUST be frozen before the first runtime
cycle. Device loss, backpressure, disconnection, and later failure MUST enter
through operational outcomes rather than silently mutating the declaration.

### R9 — Static/dynamic equivalence

Static and dynamic profiles MAY use different storage and specialization, but
MUST agree on capability identity, effective results, absence behavior, and
normalized conformance fixtures for equivalent configurations.

### R10 — Bounded static representation

The static path MUST require no heap allocation, reflection, string lookup,
exceptions, unrestricted existentials, or unbounded registry. Catalogue,
contribution, resolver, validation, and snapshot storage MUST be explicit and
bounded.

## Constraints

- MVP capability work is limited by PROPOSAL-004 and `docs/MVP_SCOPE.md`.
- All four claimed configurations must still provide the complete required
  Signal Analyzer semantics; a different implementation alone is not
  necessarily a client-visible Capability.
- Runtime profile, component graph, and selected implementations are immutable
  for one assembled MVP runtime under RFC-002.
- Capability work must not create upward imports or expose concrete target
  identity to portable views.
- Rich future effects and acceleration are examples for extensibility, not MVP
  catalogue entries.

## Proposed Design

### Fixture-driven workflow

Before defining a family, maintainers record:

1. the portable semantic requirement;
2. at least two relevant configuration fixtures or one negative fixture;
3. the exact component-owned facts that affect conformance;
4. whether the difference is structural selection, semantic capability,
   policy, ordinary configuration, or operational state; and
5. the smallest effective value needed by a consumer.

Only then may a typed family and its resolution rule enter the MVP catalogue.
This prevents the resolver shape from being designed around hypothetical
shadows, alpha, scrolling, or acceleration.

### Three decision planes

```text
build composition
    -> selected implementation families and storage models

bounded initialization
    -> owned facts + semantic requirements + explicit policy
    -> immutable effective capability snapshot or validation failure

runtime
    -> operational health, backpressure, and failure outcomes
```

Facts known only after opening a selected surface or device may be contributed
during one bounded initialization phase. Materially changing the component
graph or semantic declaration requires constructing a new runtime.

### Typed domain-specific families

Each admitted family defines only the values and combination rule its fixture
requires. A family may compare a level, intersect formats, take a checked
capacity minimum, or validate a composite realization. The MVP does not impose
one universal lattice or one open-ended heterogeneous registry.

Conceptually:

```text
requirement + owned contributions + explicit policy
    -> unavailable with reason
    | available with effective bounds and selected realization
```

Exact Swift generics, tables, IDs, layouts, and diagnostic forms belong in a
Specification after the minimum catalogue is accepted.

### Physical ownership

The candidate architecture places the admitted vocabulary and its pure
domain-specific resolution rules in a small foundational
`GiftUICapabilities` package. Contributors import that contract downward and
construct values they own; the package performs no discovery and imports no
higher GiftUI or concrete integration package. The target host assembles all
values and policy.

This package choice remains an RFC decision because it affects the physical
dependency graph. Its concrete targets, generic representation, access
control, and storage layout remain Specification work.

### Consumption

Portable views receive no general platform or backend query API for MVP.
Framework features consume the smallest semantic effective value at their
own boundary. Target hosts and tooling may inspect stable validation results.
Operational health remains separate from the immutable snapshot.

## Module Responsibilities

| Owner | Responsibility | Must not decide |
| --- | --- | --- |
| `GiftUICapabilities` candidate foundation | Admitted semantic vocabulary, typed owned facts, pure resolution rules, effective results | Discovery, concrete implementation selection, runtime health |
| Runtime/render/backend/driver contracts | Contribute only facts they own and consume approved semantic results | End-to-end support outside their boundary or product policy |
| Target host | Assemble requirements, selected components, contributions, capacities, and deterministic policy | Reinterpretation of missing semantics as support |
| Runtime consumers | Read immutable effective values | Contributor identity probing or live mutation |
| Validation tooling | Explain fixtures and normalized results | Resolution or semantic authority |

## Public API Impact

Portable Signal Analyzer declarations remain source-stable and do not gain
target branches. Later Specifications define host assembly, component
contribution SPI, immutable snapshots, validation failures, and any narrowly
reviewed client projection. A global `supports("feature")` registry or Service
locator is not proposed.

## Capabilities Impact

This RFC defines the capability architecture itself. Its first deliverable is
the minimum fixture-backed catalogue, not a reusable taxonomy. Structural
selection, policy, realization metadata, and operational state remain distinct
even when a target host represents them in one configuration source.

## Backend Impact

Backends and lower integrations report only their owned render, surface,
presentation, device, or transport facts. A backend cannot infer portable UI
semantics by itself, probe repeatedly during a frame, or silently switch to a
non-conforming realization.

## Static / Embedded Impact

Static composition may specialize tuples, generated switches, fixed tables, or
direct calls. Correctness cannot depend on optimizer removal of unused code.
The nRF52840 fixture must demonstrate bounded zero-heap resolution and snapshot
access, deterministic malformed/duplicate/unsatisfied handling, and absence of
omitted implementation families from the linked image.

## Performance

Resolution occurs during composition or bounded initialization, never in view
evaluation or per-pixel work. Specifications measure resolution time,
hot-path effective-value access, validation construction, and specialization
cost for the actual minimum catalogue.

## Memory / Binary Size

Specifications budget requirements, owned contributions, resolver workspace,
effective snapshot, validation results, provenance needed by fixtures, and
specialization cost. Rich names and reports may live in host tooling. Exact
bounds cannot be selected before the minimum catalogue is known.

## Alternatives

### Build flags only

Compile-time selection is effective for structural impossibility but cannot by
itself represent initialization-time dimensions, formats, quantitative bounds,
or one explainable semantic result.

### Backend Boolean bag

This is small when the backend owns every relevant behavior, but it loses
cross-component prerequisites, quantitative constraints, and software
realizations outside the backend.

### String-keyed runtime registry

This is convenient for dynamic plugins but introduces allocation, casting,
ordering, identity, and bounded-storage problems unnecessary for the closed
MVP stacks.

### Encode everything in generic types

This can reject static combinations early but creates large type surfaces for
quantitative and initialization-time facts. Selective specialization plus
typed values is the candidate direction.

### Feature-local probing

This delays shared machinery but leaks identity, duplicates policy, and allows
features to interpret the same stack inconsistently.

### Mutable capability registry

This models hot plug directly but conflates promised semantics with temporary
health and destabilizes cycle behavior. MVP uses immutable declaration plus
operational outcomes.

## Rejected Approaches

No alternative is formally rejected while this RFC remains `draft`. The
minimum fixtures must exist before review can judge whether the proposed typed
resolver and foundation package are proportionate.

## Compatibility

Portable views should not change. Target flags and configuration checks will
be inventoried and classified before migration. No stable capability ABI,
serialized snapshot, plugin protocol, or public generic representation is
proposed for MVP.

## Testing Strategy

- Define one normalized configuration fixture for each MVP target.
- Require every family and field to cite at least one fixture assertion.
- Compare equivalent static and dynamic resolution results.
- Test order independence, missing required behavior, optional absence,
  incompatible constraints, duplicates, malformed values, and workspace
  exhaustion.
- Enforce dependency direction and absence of target checks in portable views.
- Verify omitted implementation families are not linked into static firmware.
- Keep host, cross-build, simulator, and connected-hardware claims distinct.

## Risks

- The catalogue may remain empty because implementation differences do not
  alter required semantics; that is evidence to simplify, not a reason to add
  speculative families.
- Typed contributions may grow into a generalized Trait framework; FW-008
  preserves that work outside MVP.
- Policy may hide semantic degradation; it may select only conforming paths.
- Generic specialization may increase code size; measure the concrete
  catalogue before choosing representation.
- RFC-002, RFC-004, and RFC-005 may classify shared facts differently;
  reconcile the coordinated drafts before approval.

## Open Questions

The following are RFC blockers:

1. What is the smallest concrete capability catalogue demonstrated by the four
   MVP fixtures, and which apparent differences are only structure, policy,
   ordinary configuration, or operational state?
2. Does that catalogue actually require cross-component resolution, or would
   direct typed configuration satisfy every demonstrated semantic need?
3. If resolution is required, can one foundational vocabulary-and-resolver
   package participate in RFC-002's acyclic dependency graph without forcing
   unused machinery into the static image?
4. Which presentation facts shared with RFC-004 and failure facts shared with
   RFC-005 belong in the immutable snapshot rather than policy or operational
   state?

Family counts, contribution counts, storage layouts, provenance representation,
diagnostic fields, and byte budgets are Specification questions after the
catalogue and resolution need are established.

## Deferred and Follow-up Work

- [FW-006](../future-work/fw-006-generated-target-configuration.md) preserves
  generated target composition.
- [FW-007](../future-work/fw-007-cost-aware-capability-planning.md) preserves a
  general measured realization planner.
- [FW-008](../future-work/fw-008-generalized-component-traits.md) preserves an
  open generalized Trait subsystem.
- Rich rendering capabilities require their own accepted feature need; they
  are not placeholder MVP catalogue entries.

## Decision Summary

If approved after fixture evidence exists, this RFC is expected to yield
candidate ADRs for:

1. separation of structural selection, immutable semantic capability
   declaration, explicit realization policy, and mutable operational state;
2. a fixture-driven typed capability model with explicit constraints and
   absence behavior rather than target checks or Boolean backend bags;
3. target-host resolution through an acyclic bounded foundation compatible
   with static and dynamic profiles, if the minimum catalogue demonstrates
   that such resolution is necessary.

## References

- [PROPOSAL-004](../proposals/proposal-004-capability-system.md)
- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002](rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-004](rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-005](rfc-005-failure-diagnostics-propagation.md)
- [ADR-001](../adrs/adr-001-signal-analyzer-application-boundaries.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md) — legacy evidence only
