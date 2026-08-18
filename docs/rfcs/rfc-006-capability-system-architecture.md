---
id: RFC-006
feature: capability-system
title: GiftUI Capability System Architecture
status: draft
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-18
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

The minimum catalogue contains one host/framework-facing family:
`rasterPresentation`. It validates that the assembled render producer, raster
realization, surface/display submission path, and resource policy can together
present the Signal Analyzer's required opaque render vocabulary at the target
extent. No single contributor can establish that result, so the four MVP
fixtures demonstrate a real need for shared resolution rather than direct
component-local configuration. The foundational `GiftUICapabilities` target
owns only capability-specific values and pure resolution and fits RFC-002's
partial order without an upward import.

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

RFC-002's module graph is the governing integration constraint for this draft.
This RFC does not require a second distribution package and does not move
portable geometry, render operations, frame identities, pixel encoders, or
device types into the capability foundation.

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
capacities, handoff or payload-lifetime form, alignment, or another bound
determines whether a use is valid.

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
- `GiftUICapabilities` must not import `GiftUI`, semantic, layout, render,
  execution, failure, runtime, backend, platform, driver, OS/RTOS, HAL, or
  concrete integration modules. Component-side adapters may import their own
  contract plus `GiftUICapabilities` and contribute capability-specific values
  downward.

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

### Minimum MVP catalogue: `rasterPresentation`

The minimum catalogue contains exactly one composite family. Its requirement
describes the framework-visible promise needed to present the Signal Analyzer:

- coverage of the required normalized opaque rectangles, positioned text,
  straight-line strokes, clipping, and damage semantics;
- the required logical surface extent;
- an operation-delivery form compatible with the selected raster path;
- at least one pixel encoding accepted across raster output and display
  submission; and
- bounded raster, payload, and in-flight storage within host policy.

Contributors report only facts they own:

| Contributor boundary | Owned contribution | Not contributed |
| --- | --- | --- |
| Render producer / RFC-004 execution adapter | Required operation-set identity and supported stable stream or replay forms | Pixel format, device identity, or presentation policy |
| Raster/backend adapter | Operation coverage, accepted delivery forms, producible canonical pixel encodings, extent limits, and required workspace | End-to-end support or display availability |
| Surface/display adapter | Logical extent, accepted canonical pixel encodings, region/row constraints, buffer borrowing or transfer lifetime, and handoff form | GiftUI semantics or raster selection |
| Target host resource policy | Allowed storage budget, in-flight bound, and preference among otherwise conforming paths | Missing support or weakened semantics |

The resolver intersects operation coverage, delivery compatibility, pixel
encoding, extent limits, submission lifetime, and resource bounds. It returns
either an unavailable result with a stable reason or one effective
`rasterPresentation` value naming capability-level realization properties and
their quantitative bounds. Concrete Swift types such as `RenderOperation`,
`Size`, backend classes, driver enums, and platform handles remain in their
RFC-002 owners; local adapters map them to the closed capability vocabulary.

Pixel encoding and delivery form are realization facts, not client-visible
feature flags. The semantic capability is the complete conforming presentation
path. Runtime backpressure or synchronous handoff refusal remains an RFC-004/
RFC-005 outcome; device loss and downstream failure after accepted handoff
remain backend-local operational health. Neither mutates this result.

### Normalized MVP fixtures and resolution evidence

The following fixtures define the minimum evidence. Proof-of-concept values
are feasibility evidence; later Specifications own exact declarations and
budgets.

| Fixture | Relevant owned facts | Required effective result |
| --- | --- | --- |
| macOS dynamic | Dynamic producer; complete MVP operation vocabulary; desktop raster and AppKit surface path; allocation permitted but explicitly bounded | Available desktop full-surface realization with a compatible delivery form and canonical host pixel encoding |
| macOS static | Static producer for the same portable presentation; bounded operation/payload storage; desktop raster and surface path | Same semantic coverage as macOS dynamic, with all static capacities explicit; runtime profile identity is not exposed as a Capability |
| Raspberry Pi 1/Linux dynamic + PiScreen | Dynamic producer; RGB565 tiled raster candidate within the supported 480 x 320 bound; 240 x 240 PiScreen fixture; Linux framebuffer accepting 16-, 24-, or 32-bit layouts; default 240 x 16 x 2-byte GiftUI tile | Available bounded tiled realization; resolver selects an encoding/conversion and delivery combination shared by renderer and framebuffer rather than probing a concrete display type |
| nRF52840 static + TFT | Static bounded producer; required MVP operations; RGB565 tile raster; 480 x 320 display path; synchronous borrowed SPI submission; maximum 480 x 4 x 2-byte (3,840-byte) tile; no full framebuffer | Available zero-heap RGB565 tiled realization within the configured storage bound; a full-surface RGBA realization is unavailable |

At least two effective realizations therefore differ materially: desktop may
use a bounded full surface, while the nRF52840 fixture requires bounded RGB565
tiles and synchronous borrowed submission. The portable presentation remains
unchanged.

Shared resolution is necessary, not merely convenient. The Raspberry Pi and
nRF52840 results depend simultaneously on facts owned by the render producer,
raster/backend, surface/display adapter, and host resource policy. None of
those modules may import all the others or claim end-to-end support under
RFC-002. Direct typed configuration in each host would duplicate the same
intersection and absence rules, make results incomparable, and let concrete
identity checks become the de facto capability model. A negative fixture that
pairs a required operation or extent with incompatible delivery forms, pixel
encodings, or storage bounds must resolve to unavailable independent of
contribution order.

Other observed differences are deliberately not catalogue entries: runtime
profile and selected modules are structural composition; surface dimensions
and rotation alone are ordinary configuration facts used by the family;
backpressure and device health are operational state; hardware acceleration is
a realization detail unless a later semantic requirement depends on it.

### Physical ownership

The candidate architecture places the admitted vocabulary and its pure
domain-specific resolution rules in a small foundational
`GiftUICapabilities` target within the GiftUI distribution package.
Contributors import that contract downward and construct values they own; the
target performs no discovery and imports no `GiftUI` or higher/concrete
integration target. The target host imports all selected components, gathers
their values, supplies policy, and calls the pure resolver.

The ownership and import direction are RFC decisions. Concrete generic
representation, access control, and storage layout remain Specification work.
An arrow means "depends on":

```text
target host -------------------------------> GiftUICapabilities
    |-> runtime/execution contribution ----> GiftUICapabilities
    |-> raster/backend contribution -------> GiftUICapabilities
    \-> surface/display contribution ------> GiftUICapabilities

GiftUICapabilities --X--> GiftUI / execution / backend / integration
```

Effective values flow from the host to selected consumers through host
assembly. `GiftUI` does not re-export the capability target, and portable
Presentation imports only `GiftUI`. This is RFC-002 B12-B13 with no reversed
edge and no new shared boundary.

### Consumption

Portable views receive no general platform or backend query API for MVP.
Framework features consume the smallest semantic effective value at their
own boundary. Target hosts and tooling may inspect stable validation results.
Operational health remains separate from the immutable snapshot.

## Module Responsibilities

| Owner | Responsibility | Must not decide |
| --- | --- | --- |
| `GiftUICapabilities` foundational target | `rasterPresentation` requirement/contribution vocabulary, pure resolution rule, effective result, and stable unavailability reasons | GiftUI/render/execution types, discovery, concrete implementation identity, selected product policy, or runtime health |
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
the single fixture-backed `rasterPresentation` family, not a reusable taxonomy.
Structural selection, policy, realization metadata, and operational state
remain distinct even when a target host represents them in one configuration
source.

## Backend Impact

Backends and lower integrations report only their owned render, surface,
presentation, device, or transport facts through local downward adapters. A
backend cannot infer portable UI semantics by itself, probe repeatedly during
a frame, or silently switch to a non-conforming realization. Existing
concrete-type probing between the Linux presenter and tiled renderer is
feasibility evidence to replace with host assembly and normalized resolution,
not an approved dependency pattern.

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

Specifications budget the one family requirement, its four contributor
classes and bounded records, resolver workspace, one effective result,
validation result, provenance needed by fixtures, and specialization cost.
Rich names and reports may live in host tooling. Exact field widths and target
budgets remain Specification work.

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
- Require every `rasterPresentation` field to cite at least one fixture
  assertion, and reject any second family without new accepted fixture need.
- Compare equivalent static and dynamic resolution results.
- Test order independence, missing required behavior, optional absence,
  incompatible constraints, duplicates, malformed values, and workspace
  exhaustion.
- Include negative matrices for operation-set mismatch, no common pixel
  encoding, incompatible delivery/submission lifetime, extent overflow, and
  insufficient raster or in-flight storage.
- Enforce dependency direction and absence of target checks in portable views.
- Verify omitted implementation families are not linked into static firmware.
- Keep host, cross-build, simulator, and connected-hardware claims distinct.

## Risks

- `rasterPresentation` could collapse into ordinary host validation if review
  shows one owner can establish every effective result without duplicated
  cross-component rules; the four contribution matrix and negative fixtures
  must remain review evidence.
- Typed contributions may grow into a generalized Trait framework; FW-008
  preserves that work outside MVP.
- Policy may hide semantic degradation; it may select only conforming paths.
- Generic specialization may increase code size; measure the concrete
  catalogue before choosing representation.
- RFC-004 still owns operation-delivery and handoff semantics, and RFC-005
  owns pre-handoff operational failure plus optional post-handoff diagnostics;
  this RFC only resolves their immutable
  capability-level compatibility facts. Any change to those meanings requires
  coordinated reconciliation before approval.

## Open Questions

The minimum catalogue, need for shared resolution, and acyclic placement are
resolved in the proposed direction above: one `rasterPresentation` family in a
foundational leaf target, resolved from four independently owned contribution
classes. The remaining RFC blockers are:

1. Does RFC-004 approve operation-delivery and handoff meanings sufficient
   to populate the immutable compatibility fields used here, including the
   first-party tiled paths, without adding a third payload-lifetime mode?
2. Do review fixtures confirm that canonical pixel-encoding identity and
   submission lifetime are required resolver inputs, or can either be reduced
   to realization output without weakening a negative configuration test?
3. Does the bounded nRF52840 representation and linked-image evidence show
   that the one-family foundation and its contribution adapters impose an
   acceptable RAM, stack, and flash cost?

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
   with static and dynamic profiles; the four MVP fixtures demonstrate that
   the minimum catalogue requires such resolution.

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
- [GiftUI Runtime Profile Migration Plan](../GiftUI_Runtime_Profile_Migration_Plan.md) — legacy static/dynamic feasibility evidence only
- [GiftUI Raspberry Pi Platform](../GiftUI_Raspberry_Pi_Platform.md) — legacy PiScreen, framebuffer-format, and RGB565 tile evidence only
- [GiftUI Embedded Layer Inventory](../GiftUI_Embedded_Layer_Inventory.md) — legacy bounded RGB565 and linked-resource evidence only
- [GiftUI nRF52840-DK Platform Specification](../GiftUI_nRF52840_DK_Platform_Spec.md) — legacy embedded-stack feasibility evidence only
