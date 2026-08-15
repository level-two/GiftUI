---
id: RFC-006
feature: capability-system
title: GiftUI Capability System Architecture
status: draft
authors:
  - Yauheni Lychkouski
created: 2026-08-15
updated: 2026-08-15
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

This RFC proposes a typed, composition-root capability system that separates
three questions:

1. which implementation families and storage models exist in a build;
2. which semantic behavior the assembled stack can provide, with what bounds;
3. which conforming realization and operational policy the target selects.

Each logical layer contributes typed Traits through a downward-facing contract.
The target host assembles those contributions with application requirements
and policy. A deterministic resolver produces one immutable effective
capability snapshot before the semantic runtime begins. Portable framework
features consume semantic results and constraints; they do not inspect a
platform, backend, driver, or board identity.

The MVP uses domain-specific capability records and resolution rules rather
than one universal Boolean bag, string-keyed registry, or generic lattice.
Required behavior is either provided conformingly or makes the configuration
invalid. Policy may choose among conforming realizations but cannot create
support, weaken required semantics, or turn diagnostics into control flow.

The proposal is hybrid by design: package composition, SwiftPM traits, compiler
conditions, and generic specialization may remove structural implementation
families; typed values describe quantitative and initialization-time facts;
and the same logical contracts remain testable in dynamic and static profiles.

These are candidate architectural choices. This draft does not approve them,
define final Swift API spellings, authorize package or implementation changes,
or claim conformance for any target configuration.

## Context

[PROPOSAL-004](../proposals/proposal-004-capability-system.md) accepts the need
for an explicit Capability System so the portable Signal Analyzer can run on
macOS dynamic, macOS static, Raspberry Pi/Linux dynamic, and nRF52840 static
configurations without target-specific decisions entering its presentation.

The accepted [ADR-001](../adrs/adr-001-signal-analyzer-application-boundaries.md)
places target composition in the application host and prohibits concrete
backend, clock, scheduling, input, display, and hardware dependencies from the
portable Presentation layer. That application boundary is authoritative.

[RFC-002](rfc-002-giftui-mvp-layered-architecture.md) is a draft and therefore
non-authoritative. It proposes the logical layer and dependency seams this RFC
uses: portable semantics above a backend-neutral render boundary, separate
backend and device integration, and a target-host composition root. RFC-002
explicitly delegates capability vocabulary, resolution, propagation, policy,
absence behavior, and the MVP catalogue to this feature. The two RFCs must be
reconciled before either advances to approval.

[RFC-004](rfc-004-run-cycle-and-frame-transaction.md) and
[RFC-005](rfc-005-failure-diagnostics-propagation.md) are also draft,
non-authoritative context. This RFC aligns with their candidate immutable
cycle snapshot and structured failure boundaries while retaining ownership of
capability semantics.

[RFC-007](rfc-007-delegated-services-architecture.md) is the coordinated draft
for Clock, Scheduler, and diagnostic delivery. It owns delegated environmental
operations; RFC-006 consumes only explicit Service Traits supplied at
composition.

The maintainer-provided capability architecture draft supplied with the
Proposal request is the primary design source. This RFC adapts its hybrid
compile-time/value-level direction to the repository lifecycle, the current
MVP boundary, and the layer, run-cycle, and failure RFCs now under review.

### Terminology

- **Capability requirement:** A semantic behavior or constraint that an
  application, framework feature, or integration contract requires.
- **Capability:** An externally meaningful promise about the GiftUI semantics
  the configured stack can provide to client code.
- **Trait:** A typed fact owned by one selected runtime, renderer, backend,
  driver, transport, Service, or target profile. Traits are resolver inputs,
  not client-facing semantic promises.
- **Service:** An operation delegated to the environment through an injected
  contract, such as monotonic time, wake scheduling, or diagnostic delivery.
  A Service may expose Traits but is not itself a Capability.
- **Capability contribution:** A bounded set of typed Traits supplied by one
  selected component or adapted from explicit Service properties at the
  composition root.
- **Realization:** A conforming software or hardware path that can provide a
  semantic capability under stated constraints.
- **Effective capability:** The resolved statement that a semantic capability
  is available or unavailable, together with bounds, chosen realization, and
  stable provenance needed for validation.
- **Structural selection:** Build composition that determines whether an
  implementation family exists at all.
- **Policy:** Target-selected preference or operational disposition applied
  only within the set of conforming realizations.
- **Configuration:** The immutable MVP selection of runtime profile,
  components, capacities, requirements, and policy for one target.
- **Operational state:** Device presence, link health, backpressure, and
  failures after initialization. Operational state is not a capability
  declaration.

## Requirements

### R1 — Explicit semantic capabilities

Capabilities MUST describe application- or framework-relevant behavior and
constraints. Portable code MUST NOT infer them from operating-system,
architecture, backend, driver, controller, transport, or board identity.

### R2 — Layered Trait contribution without dependency inversion

Every selected logical layer MUST be able to contribute Traits it owns without
importing a higher layer or a concrete integration package. A contribution
MUST NOT claim behavior outside the contributing component's responsibility.

### R3 — Deterministic resolution

The same configuration, contributions, requirements, and policy MUST produce
the same effective capabilities, selected realizations, validation failures,
and portable diagnostic identities independent of registration or discovery
order.

### R4 — Semantic support and realization separation

The system MUST distinguish whether GiftUI can provide a semantic behavior
from whether that behavior is realized in software, by hardware acceleration,
or through another conforming path. Hardware support alone MUST NOT define the
portable feature.

### R5 — Constraints over Boolean flags

A capability whose correctness depends on axes, formats, dimensions,
capacities, alignment, completion mode, or another bound MUST preserve those
values. It MUST NOT be reduced to a Boolean that permits an invalid use.

### R6 — Policy cannot manufacture support

Policy MAY select among conforming realizations or choose an allowed optional
behavior. It MUST NOT upgrade an unavailable capability, exceed a declared
bound, weaken a required semantic contract, or make an invalid configuration
valid.

### R7 — Explicit absence behavior

Every capability requirement MUST state whether it is required or optional
and define its absence behavior. Missing required MVP behavior MUST invalidate
the configuration before presentation begins when the target permits
initialization-time validation. Silent omission or approximation MUST NOT be
the default for required semantics.

### R8 — Static and dynamic equivalence

Static and dynamic profiles MAY use different composition, dispatch, storage,
and specialization mechanisms. They MUST agree on capability identity,
requirements, resolution results, absence semantics, and validation fixtures
for equivalent configurations.

### R9 — Bounded static representation

The static profile MUST support capability contribution, resolution,
propagation, and diagnostics without requiring heap allocation, reflection,
string lookup, exceptions, unrestricted existentials, or an unbounded
registry. Every collection or diagnostic representation MUST have an explicit
bound and deterministic overflow behavior.

### R10 — Immutable effective snapshot

Effective capabilities MUST be fixed after target initialization and before
the first semantic runtime cycle. Runtime device loss, transport failure, and
backpressure MUST enter through operational and failure contracts rather than
silently mutating configuration semantics.

### R11 — Inspectability without semantic cost

Tests and supported-configuration diagnostics MUST be able to report effective
support, relevant constraints, selected realization, policy, and stable
provenance. Removing rich strings or sinks from an embedded release MUST NOT
change resolution or semantics.

### R12 — Source-stable portable declarations

The portable GiftUI declaration surface required by the Signal Analyzer MUST
not change by target. Structural build selection may remove unused
implementation packages, but it MUST NOT require a second portable hierarchy
or target-specific branches in that hierarchy.

### R13 — MVP proportionality

The implemented MVP catalogue MUST contain only capability facts required by
the Signal Analyzer or validation of the four supported configurations. Future
rendering features and acceleration opportunities MAY influence extensible
boundaries but MUST NOT add speculative implementations to MVP.

## Constraints

- The Signal Analyzer requires composition, layout, text, opaque RGB fills and
  backgrounds, straight-line Canvas strokes, state invalidation, disabled
  interaction, and input dispatch across all claimed target configurations.
  Its monotonic time and wake-scheduling dependencies are delegated Services
  governed by RFC-007 rather than Capability families.
- macOS dynamic, macOS static, Raspberry Pi 1/Linux dynamic, and nRF52840
  static must exercise the same portable presentation concepts.
- Raspberry Pi validation targets `armv6-unknown-linux-gnueabihf`; nRF52840
  validation targets `nrf52840dk/nrf52840` with Embedded Swift and the required
  hard-float ABI.
- Alpha compositing, gradients, shadows, advanced transforms, generalized
  scrolling, readback, and speculative acceleration are outside MVP unless a
  separately accepted requirement brings them into scope.
- RFC-002's candidate dependency direction, RFC-004's cycle snapshot, and
  RFC-005's failure policy are not authority. Conflicts among these drafts
  MUST be resolved before review approval.
- Existing proof-of-concept flags, types, targets, and behavior are evidence,
  not compatibility or architectural authority.
- No stable GiftUI ABI exists for MVP; source migration remains possible but
  MUST be documented once contracts are specified.

## Proposed Design

### 1. Three decision planes

The capability system separates structural selection, semantic resolution,
and operational state:

```text
build and package composition
  selects runtime/backend/driver implementation families
                         |
                         v
target initialization and capability resolution
  combines typed requirements + contributions + policy
                         |
                         v
immutable EffectiveCapabilities + validation result
                         |
                         v
runtime cycles and operational outcomes
  device presence/failure/backpressure via RFC-004/RFC-005 contracts
```

Structural selection answers whether code and storage exist. Resolution
answers what the assembled stack can conformingly provide. Operational state
answers whether an already configured facility is currently healthy or able
to accept work. These planes are related but not interchangeable.

Build tools may use SwiftPM products, target dependencies, SwiftPM traits,
compilation conditions, architecture checks, or generic specialization for
large structural choices. Fine-grained semantic capabilities do not become
global compiler flags merely because one build path omits their implementation.

### 2. Typed, domain-specific vocabulary

Capability families use stable typed identities and family-specific payloads.
The conceptual shape is:

```text
CapabilityRequirement<Family> {
  importance: required | optional
  requiredSemantics
  requiredBounds
}

TraitContribution<Family> {
  realizationId
  providedSemantics
  constraints
  provenanceId
}

EffectiveCapability<Family> {
  support: unavailable | available
  selectedRealization
  effectiveConstraints
  provenance
}
```

These are architectural roles, not approved Swift declarations. A family may
be represented by an enum, struct, generic witness, fixed table entry, or
generated constant as long as static and dynamic implementations satisfy the
same contract.

Capability families define their own comparison and combination rules. An
ordered quality level may use minimum/intersection behavior; axes may use set
intersection; capacities may use checked minima; formats may require an exact
match or a declared converter; a semantic implementation may require several
facts together. A universal algebra is not required for MVP. RFC-006 uses only
the bounded Trait shapes required by its fixture-driven Capability families. A
generalized Trait subsystem is deferred to
[FW-008](../future-work/fw-008-generalized-component-traits.md).

### 3. Physical package ownership

One small foundational Swift package named `GiftUICapabilities` physically
owns both:

- the canonical GiftUI semantic Capability vocabulary and its typed
  requirements, Trait contributions, effective values, and validation IDs;
  and
- the pure generic resolver, domain-specific resolution rules, bounded
  snapshot contracts, and diagnostic projection seams.

GiftUI remains the conceptual owner of Capability meaning. The umbrella
`GiftUI` facade may re-export client-relevant vocabulary, but the vocabulary
does not physically live in that facade because lower contributors would then
need to import upward and create dependency cycles.

`GiftUICapabilities` is a leaf/foundation package. It imports no `GiftUI`
facade, semantic runtime, layout implementation, render core, backend,
platform, driver, OS, RTOS, HAL, or concrete Service implementation. It does
not discover contributors. Runtime, render, backend, and driver contract
packages may import `GiftUICapabilities` downward to construct typed values.
`GiftUIServices` remains an independent sibling; the target host adapts
explicit Service properties into Traits and hands all selected values to the
resolver.

```text
                         GiftUI facade
                              |
              semantic/runtime/render/backend contracts
                    \         |         /
                     \        v        /
                       GiftUICapabilities
                              ^
                              |
                    typed values supplied by
                    the target composition root
```

The cycle-prevention rule is: **Trait and requirement values flow toward the
composition root; package imports continue to point toward foundational
contracts.** The resolver coordinates values, not package discovery.

### 4. Trait contribution ownership

Each component reports only Traits it owns:

| Contributor | Candidate owned Traits | Must not decide |
| --- | --- | --- |
| Runtime profile | Allocation and language/runtime availability; fixed workspace and render-storage bounds | Display, transport, or application policy |
| Semantic/render core | Behaviors it can lower; software realization requirements; operation and resource bounds | Concrete backend or device selection |
| Backend | Surface/presentation modes, accepted operation forms, damage or replay constraints, software raster paths | Portable view semantics or board policy |
| Display/input driver | Device geometry, formats, update operations, input facilities, device-specific bounds | GiftUI semantic availability by itself |
| Transport/HAL adapter | Transfer size, alignment, concurrency, bandwidth class, completion mechanics | Rendering or UI fallback policy |
| Delegated Service adapter | Resolution, capacity, ordering, and other explicit Service properties adapted by the target host | Client-visible semantics or Capability policy |
| Target host | Required capability set, component selection, capacities, and policy | Reinterpretation of lower-layer facts |

Contributions use `GiftUICapabilities` contracts while their Trait payloads
remain limited to facts the contributor owns. Concrete controller types do not
enter the semantic Capability vocabulary.

### 5. Target-host resolution

The target host is the only composition root. It provides:

1. the selected component graph and structural profile;
2. target and application capability requirements;
3. typed Trait contributions from every selected component and Traits adapted
   from relevant delegated-Service properties;
4. explicit capacities and budgets; and
5. policy for choosing among conforming realizations.

Resolution proceeds by capability family in stable identity order:

1. validate that all contributions are well-formed and compatible with the
   selected structural profile;
2. derive candidate realizations that jointly satisfy their declared
   prerequisites;
3. discard candidates that violate required semantics, quantitative bounds,
   formats, or target budgets;
4. apply deterministic target policy among the remaining conforming
   candidates;
5. record the effective constraints and stable provenance of the result; and
6. fail configuration validation if a required family has no conforming
   realization.

Resolution is a pure logical operation over immutable inputs. Dynamic hosts
may construct erased collections for convenience. Static hosts may specialize
the same steps into generated switches, tuples, fixed tables, or direct generic
calls. Registration order cannot become selection priority.

### 6. Initialization boundary

Some target facts, such as a framebuffer's negotiated dimensions or an
attached display's verified mode, may become known only while the host opens
the selected device. MVP therefore permits one bounded initialization phase:

```text
structural composition
    -> device/resource initialization
    -> final typed contributions
    -> capability resolution and validation
    -> freeze effective snapshot
    -> begin runtime cycles
```

A failed required initialization prevents startup. Once frozen, capability
support does not mutate. A later disconnect, error, or exhausted transport is
operational state governed by structured outcome and policy. Recovery may
restore service, but it does not retroactively change the semantic contract
under which the runtime was assembled.

Reconfiguration to a materially different stack requires constructing a new
runtime/configuration rather than mutating the active snapshot in place.

### 7. Support, realization, and policy

Semantic support is binary at the contract boundary: the required behavior is
available conformingly or it is not. Realization metadata describes how that
support is supplied, for example by a portable software renderer, a backend
facility, or hardware acceleration. Quantitative constraints remain attached.

Policy selects only among conforming realizations. For MVP it is an explicit,
deterministic target value, not an optimizer. A target may prefer a bounded
streaming path over replay storage, for example, when both satisfy the same
render contract. It may not select a cheaper path that changes required
pixels, layout, input behavior, or failure semantics.

Optional behavior must be declared optional by its owning feature contract.
MVP has no general cosmetic degradation policy. Opaque rendering, text,
strokes, input, state propagation, and required timing either conform or make
the target unsupported. Future cost-aware planning is preserved in
[FW-007](../future-work/fw-007-cost-aware-capability-planning.md).

### 8. Propagation and consumption

The resolver emits a compact immutable snapshot with stable capability-family
ordering. The target host supplies it to the semantic runtime, render
preparation, backend policy, and validation tooling through their existing
configuration seams.

The snapshot is cycle-stable. A runtime cycle reads one snapshot revision and
does not perform discovery or mutate capability state while evaluating views,
layout, or rendering. A frame records the snapshot revision needed to validate
retry or completion compatibility if RFC-004 retains that concept.

Portable application views do not receive a general target-introspection API
for MVP. Framework implementations consume semantic capabilities internally;
target hosts and diagnostics may inspect the snapshot. A future client-facing
conditional feature must define its own semantic query and absence behavior
through its lifecycle rather than exposing raw backend or board facts.

### 9. Validation and failure boundary

Resolution produces either a complete effective snapshot or a bounded list of
configuration failures. There is no partially valid active runtime.

Validation failures use stable capability, requirement, contributor, and
reason identifiers. Dynamic tooling may attach rich explanations. Static
firmware may retain numeric identifiers, counters, and fixed detail fields
only. Both must agree on outcome and identity.

After startup, a component reports operational and failure facts through the
contracts governed by RFC-005. Failure policy may disable or quiesce an
optional facility only when that facility's semantic contract allows it. It
cannot mutate the effective declaration or silently continue after loss of a
required capability.

### 10. Minimum MVP vocabulary

The first vocabulary is derived from the Signal Analyzer and configuration
validation, not from a renderer wish list. Exact type and value contracts
belong in later Specifications. The architectural classification is:

| Kind | MVP examples | Role |
| --- | --- | --- |
| Capability | Opaque color/background semantics, deterministic text presentation, straight-line drawing, interactive controls with disabled behavior, and state-driven UI updates | Client-visible GiftUI promises required by the portable Signal Analyzer |
| Trait | Runtime storage bounds, allocation availability, render payload modes, surface geometry and formats, renderer paths, input event properties, transfer limits, and completion bounds | Component/environment facts used to determine whether and how Capabilities can be realized |
| Service | Monotonic clock, wake scheduling, and optional diagnostic delivery | Environmental operations injected through RFC-007 contracts rather than exposed as Capabilities |

Display dimensions, formats, capacities, and Service resolution/capacity
properties are quantitative Traits; they are not standalone Boolean
Capabilities. Damage, partial presentation, or replay Traits enter the MVP
vocabulary only when a selected backend or run-cycle policy actually requires
them.

Signal-source availability is application-host composition, as established by
RFC-001 and ADR-001, not a GiftUI rendering capability. Real acquisition
hardware remains a separate conformance obligation.

### 11. Capability evolution

Capability identities and payload schemas are source-versioned during MVP;
no stable ABI or wire format is promised. Adding a capability family requires
an accepted feature need and an owner. Adding an optional field must preserve
a conservative interpretation for older diagnostics and configuration
fixtures.

An unknown required capability invalidates a configuration. An unknown
optional diagnostic field may be ignored if its enclosing capability remains
understood. No implementation infers support from a newer version number.

Generated configuration may eventually make this evolution easier, but
[FW-006](../future-work/fw-006-generated-target-configuration.md) keeps that
work outside MVP.

## Module Responsibilities

These are logical responsibilities aligned with RFC-002, not approved package
or module names:

| Logical module | Responsibility | Dependency impact |
| --- | --- | --- |
| `GiftUICapabilities` | Canonical Capability vocabulary, requirements, Trait contributions, effective values, validation reasons, pure generic resolver, and bounded snapshot | Foundational leaf package; imports no higher GiftUI package or concrete integration |
| `GiftUIServices` (RFC-007) | Delegated environmental operation contracts such as clock, scheduler, and diagnostic sink | Independent sibling foundation; the target host adapts Service properties into Traits, and neither foundation imports the other |
| Semantic/runtime integration | Consume semantic results and cycle-stable constraints | Depends on effective contracts, not contributor identities |
| Render/backend integration | Contribute render and presentation facts; consume selected realization and bounds | Depends downward on render/backend and capability contracts |
| Driver/transport integration | Contribute device and transport facts through owned low-level contracts | Does not import semantic runtime or portable view types |
| Target host | Assemble components, requirements, capacities, resolver, policy, diagnostics, and failure handling | Only layer allowed to depend on the complete selected product graph |
| Validation tooling | Render stable configuration reports and compare fixtures | May enrich numeric records but cannot affect resolution |

RFC-002 must include these foundation packages in its final dependency graph,
but package ownership is no longer open in RFC-006: vocabulary and resolver
remain together in `GiftUICapabilities` for MVP.

## Public API Impact

The Signal Analyzer continues to use one `import GiftUI` declaration surface.
No platform or backend capability flags are added to its views.

Later Specifications are expected to define:

- target-host APIs for supplying requirements, contributions, capacities, and
  policy;
- component SPI for typed capability contribution;
- immutable effective snapshot and validation-result contracts;
- capability-specific internal consumption seams;
- bounded diagnostic projection for tests and tooling; and
- compile-time restrictions required by the static profile.

The RFC does not approve a public global registry, environment dictionary,
Service locator, or general `supports("feature")` query. Feature-specific
client adaptation remains possible only through a separately reviewed
semantic API that does not expose concrete target identity.

Unsupported target configurations fail composition or initialization rather
than changing which portable declarations parse. Large optional implementation
families may still be absent from a build through package and generic
composition.

## Capabilities Impact

This RFC defines the candidate capability-system architecture itself. It
replaces informal target inference with typed requirements, layered
contributions, deterministic resolution, immutable effective results, and
explicit absence behavior.

The system deliberately does not equate capability with acceleration. A
semantic behavior supplied in software and the same behavior accelerated by a
device have the same application contract but different realization and cost
facts. A hardware fact that no selected software path can use does not create
an effective semantic capability.

## Backend Impact

Backends gain a typed contribution seam and must state only the render and
presentation facts they own. They do not receive the semantic view graph and
do not decide product policy. Display drivers and transports contribute their
own device-facing facts without becoming GiftUI backends.

A backend may offer several realization paths when each path is conforming and
its prerequisites and bounds are explicit. The resolver and target policy
select one before runtime. Backends must not probe the target repeatedly or
silently change realization during a frame.

Runtime device loss and asynchronous completion remain backend operational
outcomes. They do not rewrite the effective capability snapshot.

## Static / Embedded Impact

Static composition may encode requirements and contributions in generic
types, fixed tuples, generated switches, or caller-owned tables. Whole-program
specialization should remove unused implementations, but correctness must not
depend on optimization succeeding.

The nRF52840 path must support:

- zero-heap resolution and snapshot access;
- explicit bounds on every family, contribution, failure, and diagnostic
  collection;
- no required strings, reflection, exception handling, or unrestricted
  existential storage;
- deterministic failure for duplicate, malformed, or unsatisfied entries;
- read-only effective data after initialization; and
- link-map evidence that omitted implementation families are not retained.

Static and dynamic fixtures must produce equivalent normalized snapshots for
equivalent logical inputs. Mechanically different representations are allowed.

## Performance

Resolution occurs once during initialization, not in view evaluation, layout,
render-operation emission, or per-pixel loops. Capability lookup on hot paths
should compile to direct field access, generic specialization, or a bounded
indexed lookup by stable family ID.

Review and later Specifications must define fixtures that measure:

- total initialization resolution time per configuration;
- capability access overhead in run-cycle and render preparation hot paths;
- cost of validation-failure construction and diagnostic projection;
- effect of generic specialization versus table lookup on build and execution;
  and
- any realization-specific overhead compared with direct target wiring.

No universal optimization planner is in MVP. Selection cost is linear or
otherwise explicitly bounded by the small configured family and contribution
counts.

## Memory / Binary Size

The static representation must account for requirement records, contribution
records, the effective snapshot, resolver workspace, policy code, provenance,
and validation failures. Storage may overlap across initialization and runtime
when lifetimes permit, but the snapshot itself remains immutable and valid for
the runtime lifetime.

Static builds should retain only configured families and selected
realizations. Rich names, messages, and full provenance paths may live in host
tooling keyed by stable numeric IDs. Dynamic profiles may allocate enriched
reports, but disabling them must not change outcomes.

Exact byte, stack, flash, and family-count budgets remain open until the
minimum catalogue and representation are prototyped. Approval requires a
measurement plan; Specification approval requires concrete bounds and
cross-compiled size evidence for the static target.

## Alternatives

### Compilation conditions as the capability system

Global flags and `#if` checks can remove code cheaply and are appropriate for
structural impossibility. They are preferable for a small, closed firmware
with one owner and no quantitative or initialization-time facts. They do not
compose dependency-owned constraints, represent bounds well, explain software
fallbacks, or provide one inspectable effective result.

### Backend-owned Boolean capability bag

A backend struct with flags such as `supportsAlpha` is simple and cheap. It is
preferable when the backend alone owns every relevant behavior. GiftUI's
runtime, renderer, driver, transport, and target constraints are independent;
Boolean backend flags lose provenance, bounds, and software realizations.

### String-keyed runtime registry

A dictionary of names to dynamically typed values is extensible and convenient
for plugins. It is preferable in an allocation-rich system with runtime-loaded
components. It introduces string identity, casting, order, schema, and bounded
storage problems that are unnecessary for the closed MVP stacks and unsuitable
as the Embedded Swift common contract.

### Generic types for every capability value

Encoding the entire profile in nested generic parameters can reject invalid
combinations early and enable specialization. It is preferable for a tiny
compile-time-only matrix. Quantitative values, initialization-time facts,
diagnostics, and a growing capability set would create large type surfaces and
specialization cost. This RFC uses type-level structure selectively and
value-level typed records where values are the clearer contract.

### One universal capability lattice

A common meet operation is mathematically attractive and can simplify generic
resolution. It is preferable when all families share one ordered domain.
Formats, axes, capacities, composite prerequisites, semantic realizations, and
policy choices do not naturally share one order. Domain-specific rules are
more explicit for MVP.

### Mutable runtime capability registry

Live capability mutation can represent hot-plug devices directly. It is
preferable for applications designed around dynamic device discovery and view
adaptation. For MVP it would destabilize a run cycle, complicate static
storage, and blur the distinction between promised semantics and temporary
operational health. This RFC freezes the snapshot and routes runtime change
through operational contracts.

### Feature-local probing and fallback

Each feature can inspect its backend and choose a fallback close to use. This
minimizes central machinery at first. It duplicates policy, leaks identity,
makes deterministic diagnostics difficult, and allows different features to
interpret the same stack inconsistently.

## Rejected Approaches

No approach is formally rejected while this RFC remains a draft. Review is
expected to accept, revise, or reject the candidates above before ADR
extraction.

## Compatibility

### Source compatibility

Portable Signal Analyzer declarations should not gain target branches. Target
hosts, runtimes, backends, and drivers will require migration to explicit
requirements and contribution contracts. Current proof-of-concept flags and
configuration types are not presumed stable.

### Behavioral compatibility

Equivalent supported configurations must preserve portable layout, rendered
semantics, action dispatch, state invalidation, timing contracts, and failure
identity even when realization differs. Pixel-format conversion or physical
presentation mechanics may differ within approved semantic tolerances.

### Package and ABI compatibility

RFC-002 owns final package boundaries. This RFC requires only a non-inverting
contract seam at each logical layer. No stable ABI, serialized capability
format, or plugin protocol is proposed for MVP.

### Migration

Migration should inventory existing `#if`, backend flags, device parameters,
runtime-profile assumptions, and fallback branches. Each item must be
classified as structural selection, capability contribution, requirement,
policy, operational state, or unrelated configuration before replacement.
Unclassified flags must not be copied into the new catalogue.

## Testing Strategy

### Resolver unit tests

Use table-driven fixtures for each family covering compatible contributions,
incompatible formats, quantitative intersections, composite prerequisites,
duplicate identities, malformed values, unavailable required behavior,
optional absence, deterministic selection, and unknown identifiers.

### Cross-profile conformance

Feed logically equivalent fixtures into static and dynamic representations and
compare normalized effective snapshots, selected realizations, validation
reasons, and stable provenance IDs byte-for-byte where representation permits.

### Dependency and source checks

Reject imports from portable layers to concrete backends, platforms, drivers,
OS/RTOS modules, or HALs. Scan portable Signal Analyzer presentation for
platform, backend, board, and device identity branches. Verify that static
builds do not link omitted implementation families.

### Supported-configuration fixtures

Define one checked configuration fixture for each MVP target:

1. macOS dynamic;
2. macOS static;
3. Raspberry Pi 1/Linux dynamic with framebuffer and PiScreen; and
4. nRF52840 static with TFT display.

Each fixture records structural selections, requirements, contributions,
policy, effective snapshot, and expected validation result. At least one
capability must have different realization or bounds across configurations
while preserving the portable Signal Analyzer contract.

### Failure and operational tests

Inject missing required contributions, initialization failure, device loss,
transport failure, capacity exhaustion, and diagnostic-sink absence. Confirm
that pre-start invalidity prevents runtime activation, post-start conditions
follow RFC-005's eventual approved contract, and diagnostics do not affect
semantics.

### Hardware evidence

Host and cross-compile tests prove representation and build viability only.
Final conformance still requires Raspberry Pi `armv6l` execution and connected
nRF52840 display/input evidence. No hardware operation is authorized by this
RFC.

## Risks

- **The catalogue becomes a speculative framework taxonomy.** Require every
  MVP family and field to cite a Signal Analyzer or supported-configuration
  fixture.
- **Typed records become an allocation-heavy dynamic registry.** Make bounded
  static fixtures a first-order conformance target and forbid strings or
  reflection in the common contract.
- **Generic specialization creates code-size explosion.** Specialize only
  structural decisions and measure flash contribution per family and
  realization.
- **Policy hides semantic divergence.** Permit policy to choose only among
  conforming candidates; required semantics never degrade silently.
- **Operational state is mistaken for capability mutation.** Freeze the
  snapshot before runtime and route device health through structured outcomes.
- **Resolution order changes results.** Use stable family and realization
  identity with explicit tie-breaking independent of discovery order.
- **The RFC conflicts with RFC-002, RFC-004, or RFC-005.** Reconcile ownership,
  snapshot lifetime, failure, and policy boundaries before any of these RFCs
  advances to approval.
- **Diagnostics add embedded cost.** Keep portable numeric identity and allow
  rich projection to be removed without semantic change.
- **Traits grow into a second public Capability system.** Keep MVP Traits
  internal, typed, and owned by contributors; defer generalized Trait
  namespaces and discovery to FW-008.

## Open Questions

1. Which presentation facts from RFC-004 are true Capabilities versus Traits,
   policy inputs, or operational state, and what stable snapshot revision must
   a frame retain? RFC-004 and RFC-006 must use one classification.
2. Which failure actions in RFC-005 may disable an optional Capability without
   reconstructing the runtime, and must the effective snapshot remain a
   declaration while separate availability state records temporary loss?
3. What exact fixed family count, contribution count, resolver workspace,
   validation-failure capacity, and provenance representation fit the
   nRF52840 configuration? A bounded representation sketch and cross-compiled
   size measurements are needed before review closes.
4. What is the smallest concrete catalogue demonstrated by all four fixtures?
   Fields without a fixture requirement must be removed or moved to deferred
   work before approval.

## Deferred and Follow-up Work

- [FW-006](../future-work/fw-006-generated-target-configuration.md) preserves
  declarative board/product configuration and generated Swift composition.
  It is outside MVP until repeated target wiring, configuration drift, or
  measured specialization benefit meets a recorded trigger.
- [FW-007](../future-work/fw-007-cost-aware-capability-planning.md) preserves a
  general planner for choosing among measured realizations under resource
  budgets. MVP uses deterministic explicit policy over its small catalogue;
  re-evaluation requires an accepted feature with competing conforming paths.
- [FW-008](../future-work/fw-008-generalized-component-traits.md) preserves a
  generalized Trait subsystem with independent namespaces, discovery, and
  tooling. MVP uses only bounded typed Trait contributions required by its
  Capability fixtures.
- [RFC-007](rfc-007-delegated-services-architecture.md) owns Clock, Scheduler,
  diagnostic delivery, and the common rules for environmental Services. Their
  availability and quantitative properties may contribute Traits, but the
  Service instances are not Capability values.
- Rich rendering capabilities such as alpha, shadows, transforms, generalized
  scrolling, and advanced compositing require their own accepted feature need.
  They are examples that test extensibility, not entries in the MVP catalogue.
- Exact Swift declarations, storage layouts, capacities, diagnostics, and
  configuration fixtures belong in Specifications after approved RFC decisions
  are extracted into accepted ADRs.

## Decision Summary

If this RFC is approved in substantially its proposed form, the following
architecturally significant choices should be extracted into separate ADRs:

1. GiftUI separates structural build selection, immutable semantic capability
   resolution, and mutable operational state.
2. Capability families use typed domain-specific requirements, Trait
   contributions, constraints, and resolution rather than a Boolean backend
   bag, string registry, or universal lattice.
3. One foundational `GiftUICapabilities` package physically owns both the
   canonical semantic vocabulary and the pure generic resolver; the `GiftUI`
   facade remains the conceptual owner and may re-export client-facing names.
4. The target host resolves the selected stack once before runtime and owns
   policy; policy cannot manufacture support or weaken required semantics.
5. Semantic support is distinct from software or hardware realization and
   acceleration.
6. Static and dynamic profiles use the same logical capability contracts and
   normalized results while permitting different bounded representations.
7. Required capability absence invalidates the configuration; effective
   capabilities are immutable and runtime health enters through operational
   and failure contracts.
8. Portable views receive no general target-introspection API for MVP;
   capability consumption occurs through semantic framework contracts.
9. Clock, wake scheduling, and diagnostic delivery are delegated Services
   governed by RFC-007 rather than Capabilities.
10. The MVP catalogue remains fixture-driven and limited to the Signal Analyzer
   and four supported configurations.

## References

- [PROPOSAL-004: GiftUI Capability System](../proposals/proposal-004-capability-system.md)
- [PROPOSAL-001: GiftUI MVP Baseline Charter](../proposals/proposal-001-giftui-mvp-baseline-charter.md)
- [PROPOSAL-002: Signal Analyzer Reference Application](../proposals/proposal-002-signal-analyzer-reference-application.md)
- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-001: Signal Analyzer Application Architecture](rfc-001-signal-analyzer-application-architecture.md)
- [RFC-002: GiftUI MVP Layered Architecture](rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-004: Run Cycle and Frame Transaction Architecture](rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-005: Failure and Diagnostics Propagation Architecture](rfc-005-failure-diagnostics-propagation.md)
- [RFC-007: GiftUI Delegated Services Architecture](rfc-007-delegated-services-architecture.md)
- [FW-008: Generalized Component Trait System](../future-work/fw-008-generalized-component-traits.md)
- [ADR-001: Signal Analyzer Application Boundaries](../adrs/adr-001-signal-analyzer-application-boundaries.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI Project Glossary](../GLOSSARY.md)
- [MVP Milestones](../roadmap/MVP_MILESTONES.md)
- [GiftUI Vision](../VISION.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md) — legacy implementation and design provenance
