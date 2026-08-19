---
id: RFC-006
feature: capability-system
title: GiftUI Capability System Architecture
status: draft
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-19
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
  - FW-014
  - FW-015
related_explorations: []
related_spikes:
  - SPIKE-001
  - SPIKE-002
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

The candidate direction uses RFC-004's single synchronous borrowed operation
stream for every first-party MVP raster path, including tiled paths; it does
not add a replayable or third GiftUI operation-payload lifetime mode. Canonical
pixel encoding and downstream submission lifetime remain required resolver
inputs because either mismatch can invalidate an otherwise plausible
producer/display pair.
The one-family resolver runs during bounded target initialization, including
on nRF52840, and must justify its incremental RAM, stack, and flash cost with
explicit evidence before this RFC advances.

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

The static capability-system path MUST remain valid when no heap allocator is
available. Contribution construction, initialization-time resolution,
validation-result construction, effective-result storage, and steady-state
access MUST use generated, fixed-capacity, caller-owned, or otherwise
explicitly bounded storage and MUST NOT perform heap allocation. The static
path also MUST NOT require reflection, string lookup, exceptions, unrestricted
existentials, or an unbounded registry.

Dynamic profiles MAY allocate for these operations, but their work, retained
state, and failure behavior MUST still be explicitly bounded and deterministic.

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
- conformance to RFC-004's synchronous borrowed one-shot operation-delivery
  contract;
- at least one pixel encoding accepted across raster output and display
  submission; and
- a compatible downstream submission lifetime; and
- bounded raster, payload, and in-flight storage within host policy.

Contributors report only facts they own:

| Contributor boundary | Owned contribution | Not contributed |
| --- | --- | --- |
| Render producer / RFC-004 execution adapter | Required operation-set identity and conformance to the synchronous borrowed one-shot stream contract | Pixel format, device identity, or presentation policy |
| Raster/backend adapter | Operation coverage, ability to consume the common stream contract, producible canonical pixel encodings, produced-buffer lifetime forms, extent limits, and required workspace | End-to-end support or display availability |
| Surface/display adapter | Logical extent, accepted canonical pixel encodings, region/row constraints, buffer borrowing or transfer lifetime, and handoff form | GiftUI semantics or raster selection |
| Target host resource policy | Allowed storage budget, in-flight bound, and preference among otherwise conforming paths | Missing support or weakened semantics |

The resolver validates the common operation-delivery contract and intersects
operation coverage, canonical pixel encoding, extent limits, downstream
submission lifetime, and resource bounds. It returns
either an unavailable result with a stable reason or one effective
`rasterPresentation` value naming capability-level realization properties and
their quantitative bounds. Concrete Swift types such as `RenderOperation`,
`Size`, backend classes, driver enums, and platform handles remain in their
RFC-002 owners; local adapters map them to the closed capability vocabulary.

Canonical pixel encoding and downstream submission lifetime are resolver
inputs as well as properties of the selected realization. Encoding must have a
non-empty producer/consumer intersection. Submission lifetime must prove that
the producer's storage remains valid for the surface or transport's accepted
borrowing, copying, or ownership-transfer contract within the configured
in-flight bound. Neither may be reduced to output-only metadata because either
mismatch defines a required negative configuration fixture.

These realization facts are not client-visible feature flags. The semantic
capability is the complete conforming presentation path. Runtime backpressure
or synchronous handoff refusal remains an RFC-004/RFC-005 outcome; device loss
and downstream failure after accepted handoff remain backend-local operational
health. Neither mutates this result.

Every first-party MVP raster path, including the RGB565 tiled paths, must
consume RFC-004's borrowed operation stream and complete or reserve all
backend-owned derived work before the synchronous offer returns. A backend may
retain only its own derived pixel, tile, transfer, or device data afterward.
It may not retain or replay the GiftUI operation stream. If fixture work shows
that a tiled path cannot satisfy this rule, the affected design must return to
RFC-004/RFC-006 review rather than adding a third payload-lifetime mode inside
a Specification.

### Normalized MVP fixtures and resolution evidence

The following fixtures define the minimum evidence. Proof-of-concept values
are feasibility evidence; later Specifications own exact declarations and
budgets.

| Fixture | Relevant owned facts | Required effective result |
| --- | --- | --- |
| macOS dynamic | Dynamic producer; complete MVP operation vocabulary; desktop raster and AppKit surface path; allocation permitted but explicitly bounded | Available desktop full-surface realization using the common stream contract, a compatible downstream submission lifetime, and a canonical host pixel encoding |
| macOS static | Static producer for the same portable presentation; bounded operation/payload storage; desktop raster and surface path | Same semantic coverage as macOS dynamic, with allocator-independent capability contribution, resolution, validation, and effective-result access plus all static capacities explicit; runtime profile identity is not exposed as a Capability |
| Raspberry Pi 1/Linux dynamic + PiScreen | Dynamic producer; RGB565 tiled raster candidate within the supported 480 x 320 bound; 240 x 240 PiScreen fixture; Linux framebuffer accepting 16-, 24-, or 32-bit layouts; default 240 x 16 x 2-byte GiftUI tile | Available bounded tiled realization using the common stream contract; resolver selects compatible encoding/conversion and downstream submission-lifetime inputs shared by renderer and framebuffer rather than probing a concrete display type |
| nRF52840 static + TFT | Static bounded producer; required MVP operations; RGB565 tile raster; 480 x 320 display path; synchronous borrowed SPI submission; maximum 480 x 4 x 2-byte (3,840-byte) tile; no full framebuffer | Available RGB565 tiled realization whose capability contribution, initialization-time resolution, validation result, effective-result storage, and steady-state access require no heap allocator; uses the common stream contract and compatible borrowed submission within the configured storage bound; a full-surface RGBA realization is unavailable |

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
The static capability path must remain valid when no heap allocator is
available. Contribution construction, initialization-time resolution,
validation-result construction, effective-result storage, and steady-state
access use generated, fixed-capacity, caller-owned, or otherwise explicitly
bounded storage and perform no heap allocation. The nRF52840 fixture must
demonstrate that behavior, deterministic malformed/duplicate/unsatisfied
handling, and absence of omitted implementation families from the linked
image.

Build-time specialization may reduce the work, but it does not replace bounded
initialization-time resolution because selected surface and device facts may
become known only while the target is initialized. This constraint does not
claim that every unrelated platform or device bootstrap implementation lacks
an allocator; it requires capability-system conformance to remain independent
of one.

## Performance

Resolution occurs during composition or bounded initialization, never in view
evaluation or per-pixel work. Specifications measure resolution time,
hot-path effective-value access, validation construction, and specialization
cost for the actual minimum catalogue. The nRF52840 evidence must separately
report the resolver's bounded initialization work and steady-state snapshot
access; neither may introduce per-frame resolution.

## Memory / Binary Size

Specifications budget the one family requirement, its four contributor
classes and bounded records, resolver workspace, one effective result,
validation result, provenance needed by fixtures, and specialization cost.
Rich names and reports may live in host tooling. Exact field widths and target
budgets remain Specification work. Before this RFC advances, a representative
nRF52840 build or bounded representation fixture must report incremental
linked RAM and flash plus worst-case resolver stack. The result must preserve
the established target limits of at most 192 KiB linked RAM, at most 16 KiB
default display staging, firmware within the 1 MiB device flash with the
896 KiB warning threshold, and zero capability-system heap allocation during
contribution assembly, initialization-time resolution, validation-result
construction, effective-result storage, and steady-state access. If the first
representation is too costly, the first remedy is to reduce record,
provenance, diagnostic, and adapter representation while preserving the same
architecture and normalized result.

## Alternatives

### Build flags only

Compile-time selection is effective for structural impossibility but cannot by
itself represent initialization-time dimensions, formats, quantitative bounds,
or one explainable semantic result.

**Rejected for MVP.** Structural build selection remains useful, but build
flags alone cannot satisfy the required initialization-time validation and
normalized capability result.

### Backend Boolean bag

This is small when the backend owns every relevant behavior, but it loses
cross-component prerequisites, quantitative constraints, and software
realizations outside the backend.

**Rejected for MVP.** No single backend owns the complete presentation path,
and Boolean flags cannot preserve the bounds and cross-component compatibility
needed by `rasterPresentation`.

### String-keyed runtime registry

This is convenient for dynamic plugins but introduces allocation, casting,
ordering, identity, and bounded-storage problems unnecessary for the closed
MVP stacks.

**Rejected for MVP.** Its dynamic discovery and storage costs conflict with
the closed, bounded static configuration required on nRF52840.

### Encode everything in generic types

This can reject static combinations early but creates large type surfaces for
quantitative and initialization-time facts. Selective specialization plus
typed values is the candidate direction.

**Rejected for MVP.** Encoding every fact in generic types cannot represent
all initialization-time values proportionately and would impose excessive type
and specialization surface on the shared architecture.

### Build-time-only resolution

Precomputing every result could minimize device initialization work, but it
cannot validate facts learned only while opening the selected surface or
device. The candidate direction permits specialization of build-known facts
while retaining one explicit bounded initialization-time resolver and the same
normalized result across profiles.

**Rejected for MVP.** Some required surface and device facts are not available
until bounded initialization, so build-time resolution cannot be the sole
conformance mechanism.

### Replayable tiled payload mode

A separate retained or replayable operation payload could simplify some tiled
implementations, but it would add another lifetime contract, storage shape,
failure matrix, and static cost. The candidate direction instead requires all
first-party tiled paths to consume RFC-004's common synchronous borrowed
stream and retain only backend-owned derived data after handoff.

**Rejected for MVP.** No current fixture justifies a second operation-payload
lifetime, and its additional retention and failure obligations would conflict
with the bounded common handoff direction. FW-014 preserves reconsideration
under a future measured requirement.

### Feature-local probing

This delays shared machinery but leaks identity, duplicates policy, and allows
features to interpret the same stack inconsistently.

**Rejected for MVP.** The four target fixtures require one comparable result
from facts owned across several components; local probing would duplicate that
resolution and make concrete identity the implicit capability model.

### Mutable capability registry

This models hot plug directly but conflates promised semantics with temporary
health and destabilizes cycle behavior. MVP uses immutable declaration plus
operational outcomes.

**Rejected for MVP.** Runtime health must not silently rewrite the configured
semantic promise; device loss and backpressure remain explicit operational
state under RFC-004 and RFC-005.

## Rejected Approaches

All alternatives above are rejected for the proposed MVP direction:

- build flags alone cannot represent initialization-time facts or one
  normalized result;
- a backend Boolean bag loses cross-component ownership and quantitative
  constraints;
- a string-keyed registry does not satisfy bounded static requirements;
- encoding every fact in generic types creates disproportionate type and
  specialization cost while still not owning initialization-time facts;
- build-time-only resolution cannot validate facts learned during target
  initialization;
- replayable tiled payloads add an unevidenced second lifetime and storage
  contract;
- feature-local probing duplicates policy and leaks concrete identity; and
- a mutable capability registry conflates an immutable semantic promise with
  operational health.

These rejections select the RFC's proposed architecture but do not close its
explicit evidence and dependency gates or advance its `draft` lifecycle
status.

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
  encoding, incompatible downstream submission lifetime, extent overflow, and
  insufficient raster or in-flight storage.
- Assert independently that no common canonical pixel encoding and an
  incompatible downstream submission lifetime each resolve to unavailable;
  neither failure may be hidden as selected-realization metadata.
- Exercise every first-party tiled fixture through the synchronous borrowed
  one-shot operation stream and verify that no backend retains or replays that
  stream after `offer` returns.
- Enforce dependency direction and absence of target checks in portable views.
- Verify omitted implementation families are not linked into static firmware.
- Exercise static capability fixtures with no allocator linked or with
  allocation instrumentation that fails any allocation attempt from
  contribution construction through initialization-time resolution,
  validation-result construction, effective-result storage, and steady-state
  access. Unrelated platform bootstrap allocation is outside this RFC's
  evidence boundary.
- Report incremental resolver/snapshot RAM, worst-case resolver stack, linked
  flash, initialization work, and steady-state access for nRF52840 against the
  established device and firmware budgets.
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

No architectural direction remains open among the alternatives previously
listed here. The draft selects:

1. RFC-004's single synchronous borrowed one-shot operation stream for all
   first-party MVP raster paths, including tiled paths, with no third
   GiftUI operation-payload lifetime mode;
2. canonical pixel encoding and downstream submission lifetime as required
   resolver inputs, not output-only realization metadata; and
3. one bounded initialization-time resolver on nRF52840, with representation
   reduction as the first remedy if measured cost is excessive rather than a
   build-time-only or target-local replacement.

SPIKE-001 completed the normalized host-semantic evidence gate: both bounded
RGB565 tiled fixtures consumed the borrowed stream exactly once with no
retained lease, matched their reference images, and stayed within their tile
bounds. The encoding and submission-lifetime negative/control pairs also
returned independent stable reasons for every contributor permutation. This
is feasibility evidence only; it does not establish production types and did
not itself supply the separate target evidence.

SPIKE-002 completed the nRF52840 evidence gate with one reproducible bounded
representation. Relative to its equivalent baseline it added 128 linked RAM
bytes and 1,104 linked flash bytes; its named fixed capability storage was 80
bytes, its conservative worst-case resolver stack bound was 72 bytes, and its
success and worst negative initialization paths each performed 14 counted
operations. Total linked RAM, flash, and 3,840-byte staging remained within
the established limits. Both heaps were disabled, no prohibited allocator
entry point was linked, steady-state access made no resolver invocation, and
omitted implementation families were absent. This is feasibility evidence,
not a production representation or resource budget; the image was inspected
but not executed on target hardware.

The following dependency gate remains open and blocks advancement:

1. RFC-004 must be approved with compatible operation-stream and handoff
   meanings, or the two RFCs must be reconciled before either conflicting
   decision is treated as settled.

Family counts, contribution counts, storage layouts, provenance representation,
diagnostic fields, and byte budgets are Specification questions after the
catalogue and resolution need are established.

## Deferred and Follow-up Work

- [SPIKE-001](../spikes/spike-001-tiled-one-shot-capability-fixtures.md)
  records positive bounded one-shot tiled-path evidence and independent
  pixel-encoding and submission-lifetime compatibility rejection. Its
  disposable host prototype satisfies the normalized semantic gate but does
  not supply nRF52840 resource or zero-heap evidence.
- [SPIKE-002](../spikes/spike-002-nrf52840-capability-path-resource-evidence.md)
  records the completed baseline/candidate nRF52840 comparison, complete-path
  zero-heap proof, and positive RAM, stack, flash, and initialization-work
  evidence for the target gate.
- [FW-006](../future-work/fw-006-generated-target-configuration.md) preserves
  generated target composition.
- [FW-007](../future-work/fw-007-cost-aware-capability-planning.md) preserves a
  general measured realization planner.
- [FW-008](../future-work/fw-008-generalized-component-traits.md) preserves an
  open generalized Trait subsystem.
- [FW-014](../future-work/fw-014-replayable-operation-delivery.md) preserves a
  possible replayable operation contract for a future measured raster need;
  it does not add another MVP payload-lifetime mode.
- [FW-015](../future-work/fw-015-capability-resolver-input-minimization.md)
  preserves later simplification of resolver inputs if ownership or
  measurements prove that compatibility rejection remains enforceable
  elsewhere without target-specific probing.
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
   the minimum catalogue requires such resolution;
4. one common synchronous borrowed operation stream across first-party MVP
   raster paths, with canonical pixel encoding and downstream submission
   lifetime resolved as compatibility inputs; and
5. allocator-independent bounded initialization-time capability resolution on
   static and constrained targets, subject to explicit incremental RAM, stack,
   flash, initialization-work, and zero-allocation evidence across the complete
   capability-system path.

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
