---
id: SPEC-002
feature: giftui-mvp-architecture
title: Portable Foundation Specification
status: draft
authors:
  - codex
created: 2026-08-22
updated: 2026-08-22
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
related_adrs:
  - ADR-005
  - ADR-006
  - ADR-007
  - ADR-008
  - ADR-009
related_specs:
  - SPEC-003
  - SPEC-004
related_future_work:
  - FW-005
  - FW-016
related_explorations: []
related_spikes: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPEC-002: Portable Foundation Specification

## Summary

This initial Wave 1 scaffold defines the ownership boundary for GiftUI's
portable foundation: shared portable values, checked integer geometry,
normalized input values, and the package, module, visibility, and import rules
that keep those values below their consumers. It deliberately leaves
declarative semantics, failure and containment semantics, and capability
contribution and resolution semantics to their owning Specifications.

This Specification is a `draft`. Its current acceptance criteria measure
whether the scaffold is complete and semantically coordinated; they do not
authorize implementation. Exact declarations, integer widths, capacities,
and access levels remain open until they can be specified without inventing
architecture.

## Scope

This Specification owns:

- portable value contracts shared across GiftUI's semantic, layout, render,
  execution, backend, and integration boundaries, plus the authoritative
  portable meanings to which failure and capability owner adapters map without
  making either dependency-free foundational target import `GiftUI`;
- one checked integer geometry model for MVP, including coordinate,
  dimension, proposal, point, size, and rectangle value categories;
- normalized backend-neutral pointer or touch input values, including the
  value fields needed to carry logical position, phase, bounded source and
  sequence identity, bounded ordering metadata, and eligible physical-
  presentation provenance;
- value-level invariants, copying and equality semantics, valid lifetimes,
  deterministic rejection seams, and static-profile representation bounds;
- the single-package, multiple-target MVP topology and the compiler-enforced
  import partial order;
- the stable `GiftUI` client module/product boundary and the visibility classes
  needed to prevent portable code from acquiring concrete integrations; and
- compile fixtures, dependency-graph tests, and value-semantic tests that form
  the independent acceptance seam for this contract.

The contract applies to macOS dynamic, macOS static, Raspberry Pi 1/Linux
dynamic, and nRF52840/Zephyr static configurations. The same portable value
meaning MUST hold in all four configurations.

## Goals

- Establish one owner for portable values consumed by more than one downstream
  GiftUI subsystem.
- Make geometry arithmetic deterministic and checked across both runtime
  profiles.
- Give input integrations backend-neutral values without granting them
  semantic admission or dispatch authority.
- Make forbidden dependency directions mechanically testable.
- Keep every foundational value usable without requiring heap allocation,
  reflection, runtime discovery, desktop concurrency, a backend, an operating
  system, or hardware.
- Provide stable producer/consumer terminology for downstream Specifications.

## Non-goals

- Define `View`, builders, primitives, containers, modifiers, semantic
  identity, action identity, hit testing, state, invalidation, or declarative
  expansion behavior. A later declarative contract owns those semantics even
  when its public declarations reside in `GiftUI`.
- Define failure facts, outcome cases, containment, disposition, recovery,
  health projection, diagnostics, or diagnostic delivery. SPEC-003 owns that
  vocabulary; this Specification only identifies where foundation operations
  require its outcomes.
- Define Traits, Capabilities, contribution, resolution, effective results,
  absence behavior, policy, or capability diagnostics. SPEC-004 owns that
  vocabulary; this Specification only constrains its imports and portable
  value dependencies.
- Define layout algorithms, render operations, frame transactions, pointer
  sequencing, event admission, hit routing, action dispatch, backend behavior,
  host assembly, or device mechanics.
- Define the separately governed public Canvas, Path, or stroke API.
- Require a general-purpose constraint solver, fractional geometry, multiple
  geometry scalar models, ambient platform lookup, a shared delegated-Service
  catalogue, or multiple independently distributed Swift packages.
- Ratify proof-of-concept declarations, filenames, access levels, or behavior
  merely because they exist.

## Dependencies

### Lifecycle prerequisites

- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
  is accepted.
- [RFC-002](../rfcs/rfc-002-giftui-mvp-layered-architecture.md) is approved.
- [ADR-005](../adrs/adr-005-semantic-layout-render-boundary.md) through
  [ADR-009](../adrs/adr-009-checked-integer-geometry.md) are accepted.
- The [MVP Scope](../MVP_SCOPE.md) requires one substantially shared portable
  Signal Analyzer presentation across the four supported configurations. This
  foundation is necessary now because those configurations must share values
  and semantics without importing target mechanics.

### Contract dependencies

This Wave 1 contract has no prerequisite Specification. It coordinates with:

- SPEC-003, which exclusively owns shared failure/outcome and containment
  vocabulary used when checked construction or arithmetic cannot succeed and
  preserves ADR-014's rule that `GiftUIFailureCore` does not import `GiftUI`;
  and
- SPEC-004, which exclusively owns capability contribution and resolution
  vocabulary, references portable Foundation meanings without redefining
  them, and preserves ADR-019's rule that `GiftUICapabilities` does not import
  `GiftUI`.

Downstream text, declarative, layout, rendering, execution, observable-state,
interaction, runtime-profile, backend-integration, host-configuration, and
future drawing Specifications depend on this contract where they exchange
portable values or claim a module/import relationship.

### Build and platform prerequisites

- SwiftPM MUST express one GiftUI distribution package with multiple targets
  and products.
- Portable foundation compile fixtures MUST cover an ordinary host toolchain
  and the supported static Embedded Swift configuration.
- Connected hardware is not required for this Specification's independent
  acceptance seam. Later integration conformance remains responsible for
  Raspberry Pi `armv6l` and nRF52840 hard-float hardware evidence.

## Related ADRs

- **ADR-005 — Semantic, Layout, and Render Boundary:** places shared portable
  values below semantic, layout, and render consumers and prohibits backend
  or integration knowledge in the portable boundary. This Specification does
  not specify the semantic-to-render pipeline itself.
- **ADR-006 — Shared Semantics Across Runtime Profiles:** requires static and
  dynamic profiles to observe identical portable value meaning and
  deterministic failure behavior while allowing different storage and
  specialization strategies.
- **ADR-007 — Integration Ownership and Host Composition:** requires concrete
  backend, platform, driver, transport, OS/RTOS, HAL, and hardware knowledge to
  remain below portable values and makes the host, not the foundation, the
  composition root.
- **ADR-008 — Module Dependency Graph and MVP Package Topology:** establishes
  one Swift package, compiler-visible acyclic target/module dependencies, the
  stable `GiftUI` client module/product, and `GiftUI` as the sole import needed
  by portable Presentation.
- **ADR-009 — Checked Integer Geometry for MVP:** requires checked integer
  coordinates, dimensions, and scalar arithmetic, with explicit deterministic
  handling of overflow and invalid dimensions. It leaves concrete widths,
  ranges, rounding, and API spellings to this drafting process.

## Terminology

**Portable foundation value**
: A value whose representation and meaning are independent of runtime profile,
  backend, platform, driver, transport, OS/RTOS, HAL, and hardware identity.
  This term excludes declarative and failure/capability semantics even when
  those contracts reference or receive adapter-mapped Foundation meanings.

**Geometry scalar**
: The one signed integer scalar model used for MVP logical coordinates,
  dimensions, proposals, layout results, hit geometry, and Canvas geometry.
  Its exact Swift representation and range remain an open issue in this draft.

**Coordinate**
: A checked geometry scalar locating a point in backend-neutral logical
  coordinate space. A coordinate may be negative when intermediate or clipped
  geometry requires it.

**Dimension**
: A checked geometry scalar representing an extent. A valid dimension MUST be
  non-negative.

**Proposed dimension**
: Either a non-negative dimension or the profile-neutral absence of a concrete
  proposal. Absence is not infinity and does not authorize a sentinel integer.

**Normalized input value**
: A backend-neutral value produced by an input or platform adapter. It carries
  only logical input facts needed by later execution admission; it owns no
  admission, ordering, hit-testing, pointer-sequence, or action semantics.

**Source identity**
: A bounded opaque value distinguishing normalized input producers for later
  sequencing. Its representation MUST NOT reveal a concrete platform, device,
  driver, or hardware type.

**Sequence identity**
: A bounded opaque value correlating phases of one physical pointer/touch
  sequence. This Specification owns only its value representation and
  comparability; execution owns sequence behavior.

**Presentation provenance**
: A bounded opaque value allowing execution to correlate presentation-coupled
  input with eligible physical presentation. Foundation owns the value form;
  execution and target integration own stamping, validation, cancellation,
  and fail-closed behavior.

**Import partial order**
: The acyclic dependency relation in which portable contracts may be imported
  by higher consumers while portable/foundational modules never import a
  concrete higher consumer or integration to describe their values.

## Public Contract

Portable Presentation code MUST require only `import GiftUI`. The `GiftUI`
product and module MUST expose the public portable values that client
declarations need, including approved public geometry. Foundation-owned
normalized input values MUST reside in `GiftUI`, but their exact Client API or
SPI visibility remains an open issue. `GiftUI` MUST NOT re-export runtime,
layout, render, failure, capability implementation, backend, platform, driver,
OS/RTOS, HAL, or hardware modules.

Foundation values MUST have the same observable construction, copying,
equality, arithmetic, and rejection behavior in dynamic and static builds.
Their public meaning MUST NOT vary according to the selected backend, pixel
format, display geometry, platform, or runtime storage strategy.

Public values MUST NOT expose concrete implementation references, ambient
lookups, heap-backed storage as a correctness requirement, or an unbounded
collection. Any dynamic-only convenience MUST require an explicit import
other than `GiftUI` and MUST preserve the portable value meaning.

This draft establishes no public ABI or serialized-data compatibility.

## Module Contract

### Ownership

`GiftUI` exclusively owns the portable value definitions in this
Specification. Downstream modules MUST import and reuse those definitions;
they MUST NOT create adapter geometry, input, source-identity, sequence-
identity, or presentation-provenance types that duplicate the same boundary.

The fact that `GiftUI` also physically contains client declaration vocabulary
does not make that vocabulary part of this Specification. Declarative
semantics remain owned by their later contract.

SPEC-003's failure modules exclusively own failure and outcome concepts.
`GiftUI` MUST NOT define a competing failure taxonomy or containment policy.
`GiftUIFailureCore` MUST NOT import `GiftUI`; a producer-side owner adapter
MUST map any relevant Foundation value or condition into its closed failure
vocabulary at the first boundary that knows both concepts.
SPEC-004's capability modules exclusively own contribution and resolution
concepts. `GiftUI` MUST NOT define a competing Trait, Capability, resolver, or
effective-result vocabulary.

### Required import direction

The maintained target graph MUST preserve these foundation-level rules:

| Consumer family | May depend on foundation values | Foundation may depend on consumer |
| --- | --- | --- |
| Semantic, layout, text, render, and execution contracts | Yes | No |
| `GiftUIFailureCore` and `GiftUIFailureExecution` contracts | No; producer/coordinator adapters map relevant Foundation conditions into their closed failure vocabulary | No |
| `GiftUICapabilities` foundational contract | No; capability adapters map approved Foundation meanings into its closed domain vocabulary | No |
| Dynamic and static runtime implementations | Yes | No |
| Backend, raster, surface, platform, input, driver, and transport integrations | Yes, through their narrow contracts | No |
| Target hosts and presets | Yes, as composition roots | No |
| Concrete font/resource contributors | Yes where their owning contract requires it | No |
| Concrete capability-contributor adapters | Yes, when mapping local Foundation values into the closed `GiftUICapabilities` vocabulary | No |

No portable or foundational target MAY import a runtime, layout, render,
backend, platform, driver, OS/RTOS, HAL, hardware, or concrete capability
implementation. A contributor MUST NOT import a higher consumer merely to
construct a foundation value.

### Package and visibility boundary

MVP distribution MUST use one Swift package containing multiple targets and
products. `GiftUI` MUST remain both the stable portable declaration target and
the stable client-facing library product. Exact names for other targets and
products and exact `public`/`package`/`internal` assignments are unresolved
contract details, but their eventual selection MUST preserve the ownership
and dependency rules above and keep each boundary independently testable.

## Types / APIs

This scaffold fixes API seams, not final Swift spellings.

| Owned value family | Required semantic surface | Explicitly not owned here |
| --- | --- | --- |
| Geometry scalar and checked arithmetic | One integer scalar model; checked addition, subtraction, multiplication, coordinate translation, and extent calculations; deterministic detection of overflow | Failure/outcome case names, layout algorithms, rounding for future non-integer models |
| Point | Two logical coordinates with value semantics | Pixel mapping, calibration, hit testing |
| Size | Two non-negative dimensions with value semantics | Measurement policy, surface allocation |
| Rectangle | Origin plus size; overflow-safe containment and derived-edge operations | Clipping policy, damage policy, hit precedence |
| Proposed size | Independently present or absent non-negative proposed dimensions | Parent/child proposal algorithms and infinity semantics |
| Normalized input event | Phase and logical position, plus the bounded correlation fields required by its owning execution boundary | Admission, coalescing, dropping, cancellation, routing, dispatch |
| Source, sequence, ordering, and provenance identities | Opaque, bounded, copyable, equality-comparable value forms | Identity allocation policy, ordering policy, lifecycle state machine |

All owned values MUST be value-semantic and usable in caller-owned or inline
static storage. Their correctness MUST NOT depend on reference identity,
allocation, reflection, unrestricted existential storage, or runtime target
discovery.

Final declarations MUST specify visibility, initializer validity, scalar and
identity widths/ranges, and every checked operation before this Specification
can advance to `review`. Checked operations that can fail MUST use SPEC-003's
canonical outcome vocabulary rather than introduce a Foundation-owned error
domain. This cross-reference does not allow SPEC-003 to redefine the values or
arithmetic invariants above.

## Behavior

### Geometry

- Geometry arithmetic MUST detect overflow and MUST NOT silently wrap,
  saturate, trap as the only specified behavior, or expose partial geometry as
  complete.
- Construction or derivation of a negative dimension MUST be rejected
  deterministically through the SPEC-003-owned outcome seam selected during
  completion of this draft.
- Rectangle containment and derived-edge operations MUST remain correct when
  origins or dimensions approach the selected scalar limits; implementations
  MUST NOT rely on an unchecked `origin + dimension` intermediate.
- An absent proposed dimension MUST remain distinguishable from every concrete
  integer dimension.
- Geometry behavior MUST be independent of pixel format, display rotation,
  surface stride, raster quantization, controller write windows, and physical
  transfer regions.

### Normalized input values

- An integration producer MUST normalize physical coordinates into logical
  checked geometry before constructing the value passed upward.
- A normalized value MUST NOT contain a platform handle, raw OS record,
  controller sample, device pointer, backend object, or concrete target name.
- Foundation MUST preserve the supplied phase and bounded correlation values
  without deciding whether the event is admitted, stale, malformed, ordered,
  dropped, cancelled, hit tested, or dispatched.
- Conversion that exceeds the geometry scalar range MUST fail explicitly via
  the SPEC-003-owned outcome seam; it MUST NOT clamp or wrap unless a later
  accepted architecture decision explicitly authorizes such behavior.

### Dependency enforcement

- Every target dependency and source import MUST conform to the approved
  partial order.
- Static specialization and final-image link-time flattening MAY erase runtime
  overhead but MUST NOT reverse the source-level import graph or move ownership
  into a target that permits a forbidden import.

## State / Lifecycle

Foundation values are immutable values or independently mutable value copies;
they have no framework-owned runtime lifecycle. Copying a value MUST NOT create
shared mutable state, extend a borrowed integration lifetime, or retain a
platform resource.

Borrowed storage is not required for the value families currently in scope.
If final API work introduces a borrowed view, its owner, validity interval,
copying rules, and prohibition on retention MUST be stated before review.

Source, sequence, ordering, and provenance identities are opaque data in this
contract. Their creation, rollover, invalidation, admission, and teardown
lifecycles belong to their execution or integration owners and MUST NOT be
inferred from Foundation representation.

Package assembly is complete before runtime use. The selected target graph is
immutable for the assembled stack lifetime; operational device presence or
failure MUST NOT mutate Foundation types or imports.

## Capability Requirements

This Specification defines no Capability and no Trait. `GiftUICapabilities`
MUST NOT import `GiftUI`. A concrete contributor adapter MAY import both its
own component/Foundation contract and `GiftUICapabilities` to map a Foundation
value's meaning into the closed capability vocabulary. That mapping MUST NOT
redefine the Foundation value or expose a concrete contributor, backend,
platform, driver, OS/RTOS, HAL, or hardware identity in the contribution.

Capability absence, compatibility, resolution failure, effective-result
lifetime, and the `rasterPresentation` catalogue are exclusively SPEC-004
concerns. They MUST NOT change the meaning of a foundation value or create a
second target-specific representation of it.

## Backend Requirements

Backends and input integrations MAY consume Foundation geometry and normalized
input values through their owning SPIs. Foundation MUST remain usable in
recording and checking fixtures without a concrete backend.

A backend MAY translate logical geometry to pixels or physical regions after
the Foundation boundary, but it MUST NOT feed pixel quantization, rotation,
stride, surface format, or device limits back into Foundation value meaning.
An input adapter MAY normalize device samples into Foundation values, but raw
sampling, calibration, interrupts, evdev/mouse records, and controller details
remain outside this contract.

No connected hardware is needed to prove this Specification independently.

## Error Handling

Foundation owns rejection conditions, not their cross-layer vocabulary or
disposition. At minimum, the completed contract MUST route these conditions
through SPEC-003's bounded outcome seam:

- scalar arithmetic overflow;
- negative or otherwise invalid dimensions;
- physical-to-logical input conversion outside the scalar range;
- malformed or unrepresentable bounded identity/provenance fields; and
- any explicit Foundation construction bound selected during drafting.

These failures MUST be deterministic for identical inputs and MUST NOT produce
a partially valid value. Foundation MUST NOT define containment, recovery,
health, diagnostics, diagnostic delivery, retry, drop/cancel, or host policy.
Diagnostic exhaustion MUST NOT alter Foundation value behavior; that rule is
specified by SPEC-003.

## Performance Requirements

- Foundation value construction, copying, comparison, and checked arithmetic
  MUST have statically bounded work and storage for the selected scalar and
  identity representations.
- The static profile MUST be able to use every required Foundation value and
  checked operation without heap allocation, reflection, runtime discovery,
  Objective-C, `Task`, or `MainActor`.
- Foundation values MUST NOT own dynamically growing collections or large
  inline arenas.
- The completed draft MUST state concrete byte widths/ranges for scalar and
  identity fields and identify the build or test evidence that verifies them.
- Release and embedded evidence MUST report the linked-code and value-size
  impact of the final target split; this draft sets no universal byte budget
  before those declarations are chosen.

## Compatibility

- Static and dynamic profiles MUST observe identical Foundation value and
  failure semantics.
- The four MVP configurations MUST compile against the same portable
  Foundation declarations.
- `import GiftUI` MUST remain the sole import required by portable
  Presentation; hosts MUST import selected runtime and integration products
  explicitly.
- Existing proof-of-concept names, `Int` representations, preconditions,
  access levels, and source placement are evidence only and create no source
  or behavioral compatibility presumption.
- The MVP establishes no public ABI or persistent serialized representation.
- Any migration from proof-of-concept declarations MUST identify renamed,
  moved, restricted, or behaviorally changed APIs before approval.

## Testing Requirements

### Value and arithmetic tests

- Table-driven tests MUST cover zero, ordinary, minimum, and maximum valid
  scalar values plus every overflow edge for each published checked operation.
- Construction tests MUST cover valid zero dimensions, invalid negative
  dimensions, independently absent proposed dimensions, and maximum valid
  extents.
- Rectangle tests MUST exercise containment and derived edges near both scalar
  limits without unchecked intermediate overflow.
- Copy and equality tests MUST demonstrate value semantics and absence of
  shared mutable state.

### Normalized input tests

- Fixtures MUST construct every admitted normalized phase with minimum and
  maximum valid coordinates and bounded correlation values.
- Negative fixtures MUST prove that out-of-range conversion and malformed
  bounded fields yield the SPEC-003-owned outcome without partial values.
- Compile and type-inspection fixtures MUST prove that normalized values expose
  no concrete backend, platform, OS, driver, transport, HAL, or hardware type.
- These tests MUST NOT assert admission, stale-event, cancellation, hit-test,
  or dispatch semantics owned by execution and interaction contracts.

### Dependency and profile tests

- A machine-checked target graph MUST prove that the package is acyclic and
  that `GiftUI` does not depend on or re-export prohibited higher or concrete
  modules.
- Dependency fixtures MUST prove that neither `GiftUIFailureCore` nor
  `GiftUICapabilities` imports `GiftUI`; their producer-side owner adapters are
  the only locations that map Foundation conditions or values into those
  closed vocabularies.
- Negative compile fixtures MUST fail when a portable/foundation target imports
  a runtime, layout, render, backend, platform, driver, OS/RTOS, HAL, hardware,
  or concrete capability implementation.
- Positive compile fixtures MUST use the same Foundation source surface in
  dynamic and static configurations.
- Static evidence MUST verify that required Foundation operations perform no
  heap allocation and do not link omitted optional dynamic conveniences.

The complete runtime, backend, host, and connected-hardware suites are
downstream conformance evidence and MUST NOT be required to execute this
Specification's independent tests.

## Acceptance Criteria

The following are scaffold acceptance criteria. They MUST all be satisfied
before this draft is considered structurally ready for completion into a
review contract; they do not claim implementation conformance.

- [ ] **PF-SCAF-001:** Every accepted governing decision in ADR-005 through
  ADR-009 is mapped in `Related ADRs` to an owned Foundation obligation or an
  explicit exclusion.
- [ ] **PF-SCAF-002:** Every owned value family in `Types / APIs` names its
  producer/consumer seam, invariant category, visibility decision still
  required, and non-owned semantics; no family is defined by SPEC-003 or
  SPEC-004 with conflicting meaning.
- [ ] **PF-SCAF-003:** SPEC-002, SPEC-003, and SPEC-004 contain reciprocal
  `related_specs` metadata and use the same ownership rule: FOUNDATION owns
  portable values/import boundaries, FAILURE owns outcome/containment
  vocabulary, and CAPABILITY owns contribution/resolution vocabulary.
- [ ] **PF-SCAF-004:** The dependency section names all Wave 2 and later
  consumer families from the portfolio and gives Foundation an independent
  compile/value-test seam that imports no downstream implementation.
- [ ] **PF-SCAF-005:** The completed API table replaces every unresolved
  scalar, identity, event-field, visibility, and construction-outcome item
  listed in `Open Issues` with one exact declaration or an explicit upstream
  architecture blocker.
- [ ] **PF-SCAF-006:** The completed test matrix contains at least one positive
  and one boundary/negative case for each published constructor and checked
  operation, plus one positive and one forbidden-import fixture for every
  protected dependency boundary.
- [ ] **PF-SCAF-007:** No normative clause in this Specification defines
  declarative behavior, failure disposition, diagnostics, capability
  contribution/resolution, layout policy, frame/input admission, backend
  policy, or host composition behavior.
- [ ] **PF-SCAF-008:** Review evidence identifies the exact Foundation
  declarations used unchanged by both a dynamic and a static compile fixture
  and records their selected representation sizes and allocation behavior.

## Implementation Notes

This section is non-authoritative guidance. The current proof of concept has
`Point`, `Size`, `Rect`, `ProposedSize`, `InputEvent`, and package-scoped
checked layout arithmetic in `Sources/GiftUI/`. Existing unit tests already
provide evidence for integer retention, arithmetic overflow detection, and
overflow-safe rectangle containment. These names and behaviors should be
inventoried against the completed contract; they are not ratified by this
scaffold.

Draft completion can proceed in two narrow passes: first settle value
representations and the SPEC-003 outcome seam; then finalize target names,
visibility, and dependency fixtures. Downstream Specifications should consume
the resulting declarations rather than copy provisional signatures from this
draft.

## Open Issues

These are non-architectural contract details that must be resolved before the
Specification advances to `review`:

1. Select the concrete geometry scalar Swift type, width, range, and public or
   SPI spelling while preserving one checked integer model.
2. Specify the exact checked arithmetic surface, including which operations
   are public versus package SPI and how derived edges and translations expose
   SPEC-003 outcomes.
3. Specify constructor behavior for negative dimensions and invalid proposed
   dimensions; the current proof-of-concept preconditions are not authority.
4. Specify exact normalized input phases and the concrete bounded widths and
   representations of source, sequence, ordering, and presentation-provenance
   fields required by the accepted execution boundary.
5. Decide which normalized input values are Client API versus Framework or
   Integration SPI without exposing execution semantics in Foundation.
6. Finalize non-`GiftUI` target/product names and access levels necessary to
   enforce the accepted partial order. Candidate names in RFC-002 are not yet
   fixed.
7. Define the reproducible static no-allocation and value-size measurement
   procedure used as review and conformance evidence.

If resolving any item would change ownership, introduce another geometry
model, expose target identity, reverse the import graph, or define a new
failure/capability architecture, Specification work MUST pause and the issue
MUST return to RFC/ADR review.

## Deferred and Follow-up Work

- [FW-005](../future-work/fw-005-alternative-geometry-scalars.md) preserves
  fractional, floating-point, or fixed-point geometry. It is outside MVP and
  does not weaken the checked integer requirement.
- [FW-016](../future-work/fw-016-post-mvp-package-distribution-topology.md)
  preserves reconsideration of multiple packages or another distribution
  topology when concrete consumption, versioning, toolchain, dependency, or
  measured build evidence meets its revisit trigger.
- Declarative, text, layout, rendering, execution, observable-state,
  interaction, runtime-profile, backend-integration, host-configuration, and
  drawing contracts remain downstream work in the coordinated portfolio; none
  may redefine the Foundation values established here.

## References

- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [ADR-005: Semantic, Layout, and Render Boundary](../adrs/adr-005-semantic-layout-render-boundary.md)
- [ADR-006: Shared Semantics Across Runtime Profiles](../adrs/adr-006-shared-semantics-runtime-profiles.md)
- [ADR-007: Integration Ownership and Host Composition](../adrs/adr-007-integration-ownership-and-host-composition.md)
- [ADR-008: Module Dependency Graph and MVP Package Topology](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
- [ADR-009: Checked Integer Geometry for MVP](../adrs/adr-009-checked-integer-geometry.md)
- [SPEC-003: Failure Outcomes and Containment](spec-003-failure-outcomes-and-containment.md)
- [SPEC-004: Capability Contribution and Resolution](spec-004-capability-contribution-and-resolution.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI MVP Specification Portfolio](../roadmap/MVP_SPECIFICATION_PORTFOLIO.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Project Glossary](../GLOSSARY.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md)
