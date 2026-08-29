---
id: SPEC-002
feature: giftui-mvp-architecture
title: Portable Foundation Specification
status: implementing
authors:
  - codex
created: 2026-08-22
updated: 2026-08-29
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-004
  - RFC-011
related_adrs:
  - ADR-005
  - ADR-006
  - ADR-007
  - ADR-008
  - ADR-009
  - ADR-033
related_specs:
  - SPEC-003
  - SPEC-004
  - SPEC-005
  - SPEC-006
  - SPEC-007
  - SPEC-008
  - SPEC-009
  - SPEC-010
  - SPEC-011
  - SPEC-013
  - SPEC-014
  - SPEC-012
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

This Specification defines GiftUI's portable foundation: shared portable
values, checked 32-bit integer geometry, bounded normalized pointer values,
and the package, module, visibility, and import rules that keep those values
below their consumers. It deliberately leaves declarative semantics, failure
and containment semantics, capability contribution and resolution semantics,
and pointer admission behavior to their owning Specifications.

This Specification is `implementing`; its approved contract authorizes the
active implementation. The value representations, visibility classes, and
cross-layer mapping of local Foundation rejection into SPEC-003 outcomes are
fixed here.

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
- [RFC-004](../rfcs/rfc-004-run-cycle-and-frame-transaction.md) is approved
  and constrains the normalized input value carried across its admission seam.
- [ADR-005](../adrs/adr-005-semantic-layout-render-boundary.md) through
  [ADR-009](../adrs/adr-009-checked-integer-geometry.md), plus
  [ADR-033](../adrs/adr-033-bounded-application-actions-and-model-target-dispatch.md), are
  accepted.
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
- **ADR-033 — Bounded Application Actions and Model-Target Dispatch:**
  preserves the requirement that the
  normalized pointer value to carry bounded source and sequence identity plus
  the eligible physical-presentation revision. This Specification owns only
  those value representations; the later EXECUTION contract owns admission,
  ordering, wrap ambiguity, cancellation, hit testing, and activation.

## Terminology

**Portable foundation value**
: A value whose representation and meaning are independent of runtime profile,
  backend, platform, driver, transport, OS/RTOS, HAL, and hardware identity.
  This term excludes declarative and failure/capability semantics even when
  those contracts reference or receive adapter-mapped Foundation meanings.

**Geometry scalar**
: The one signed integer scalar model used for MVP logical coordinates,
  dimensions, proposals, layout results, hit geometry, and Canvas geometry.
  It is `Int32`, with the inclusive range `-2_147_483_648...2_147_483_647`.

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

**Input ordinal**
: A bounded opaque value supplied with a normalized pointer phase so the
  execution owner can detect duplicates and out-of-order delivery. Foundation
  owns only its `UInt32` representation and comparability.

**Presentation provenance**
: A bounded opaque value allowing execution to correlate presentation-coupled
  input with eligible physical presentation. For MVP the value form is the
  `UInt32`-backed `PresentationRevision`; execution and target integration own
  stamping, validation, cancellation, and fail-closed behavior.

**Import partial order**
: The acyclic dependency relation in which portable contracts may be imported
  by higher consumers while portable/foundational modules never import a
  concrete higher consumer or integration to describe their values.

## Public Contract

Portable Presentation code MUST require only `import GiftUI`. The `GiftUI`
product and module MUST expose the public portable values that client
declarations need, including the geometry declarations specified below.
Foundation-owned normalized pointer values MUST reside in `GiftUI` with
`package` visibility: they are Framework and Integration SPI, not Client API.
`GiftUI` MUST NOT re-export runtime,
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
the stable client-facing library product.

This Specification fixes the following visibility rule:

- geometry values used in portable Presentation are `public` Client API;
- normalized pointer values and their correlation fields are `package`
  Framework/Integration SPI;
- checked scalar helpers and Foundation-to-outcome adapters are `package` SPI;
  and
- implementation helpers that are not shared across targets remain
  `internal` or `private`.

Every later Specification that introduces a contract owner MUST assign that
owner a distinct target/module when combining it with another owner would
permit a prohibited import or make the boundary untestable. That owner’s
Specification fixes its non-`GiftUI` target and product names; SPEC-002 does
not pre-allocate names for contracts that do not yet have an approved
Specification. The package manifest and a checked-in dependency allow-list
MUST be the machine-readable source for the assembled DAG.

## Types / APIs

The declaration names, raw widths, visibility, and construction semantics in
this section are normative. Conformance does not require the exact source-file
layout shown by the proof of concept.

### Geometry declarations

`Int32` gives the 32-bit and 64-bit MVP targets the same arithmetic range,
comfortably covers every required 480 x 320-or-smaller surface and its checked
layout intermediates, and avoids making host word size observable. The unit is
one backend-neutral logical integer step; this contract does not define a
fractional scale or pixel conversion.

```swift
public typealias GeometryScalar = Int32

public struct Point: Equatable, Hashable, Sendable {
    public let x: GeometryScalar
    public let y: GeometryScalar
    public init(x: GeometryScalar, y: GeometryScalar)
}

public struct Size: Equatable, Hashable, Sendable {
    public let width: GeometryScalar
    public let height: GeometryScalar
    public init?(width: GeometryScalar, height: GeometryScalar)
}

public struct Rect: Equatable, Hashable, Sendable {
    public let origin: Point
    public let size: Size
    public init?(origin: Point, size: Size)
    public var minX: GeometryScalar { get }
    public var minY: GeometryScalar { get }
    public var maxX: GeometryScalar { get }
    public var maxY: GeometryScalar { get }
    public func contains(_ point: Point) -> Bool
}

public struct ProposedSize: Equatable, Hashable, Sendable {
    public let width: GeometryScalar?
    public let height: GeometryScalar?
    public init?(width: GeometryScalar? = nil, height: GeometryScalar? = nil)
}
```

`Size.init` returns `nil` when either dimension is negative. `Rect.init`
returns `nil` when either exclusive maximum edge cannot be represented as a
`GeometryScalar`; therefore all four published edges are total after valid
construction. `ProposedSize.init` returns `nil` when a present dimension is
negative. Zero dimensions are valid. An absent proposal is represented only
by `nil`; no scalar value is reserved as infinity or absence.

The following package SPI is required. Each function returns `nil` on
overflow and returns no partial arithmetic result:

```swift
package enum GeometryArithmetic {
    package static func add(
        _ lhs: GeometryScalar,
        _ rhs: GeometryScalar
    ) -> GeometryScalar?
    package static func subtract(
        _ lhs: GeometryScalar,
        _ rhs: GeometryScalar
    ) -> GeometryScalar?
    package static func multiply(
        _ lhs: GeometryScalar,
        _ rhs: GeometryScalar
    ) -> GeometryScalar?
}
```

Local optional failure is not a competing cross-layer outcome taxonomy. The
first producer or coordinator boundary that must report the rejection outside
Foundation MUST map `nil` to the corresponding SPEC-003-owned failure fact;
it MUST NOT expose a partial value, trap as its only behavior, or substitute a
different numeric result.

The owner adapter at that first cross-layer boundary MUST construct exactly
the following `GiftUIFailureFact`. These names and values are owned by
SPEC-003; Foundation itself neither imports `GiftUIFailureCore` nor constructs
the fact.

| Foundation rejection | `condition` | `origin` | `affectedScope` | `containment` |
| --- | --- | --- | --- | --- |
| Negative `Size` dimension or negative present `ProposedSize` dimension | `.invalidValue` | `.foundation` | `.operation` | `.contained` |
| `GeometryArithmetic` addition, subtraction, or multiplication overflow | `.arithmeticOverflow` | `.foundation` | `.operation` | `.contained` |
| Unrepresentable `Rect` exclusive maximum edge | `.arithmeticOverflow` | `.foundation` | `.operation` | `.contained` |
| Physical-to-logical input conversion outside `GeometryScalar` | `.arithmeticOverflow` | `.foundation` | `.operation` | `.contained` |

### Normalized pointer declarations

The following `package` declarations are owned by `GiftUI` and are available
only as Framework and Integration SPI:

```swift
package enum PointerPhase: UInt8, Equatable, Sendable {
    case down = 0
    case move = 1
    case up = 2
}

package struct InputSourceID: Equatable, Hashable, Sendable {
    package let rawValue: UInt16
    package init(rawValue: UInt16)
}

package struct PointerSequenceID: Equatable, Hashable, Sendable {
    package let rawValue: UInt32
    package init(rawValue: UInt32)
}

package struct InputOrdinal: Equatable, Hashable, Sendable {
    package let rawValue: UInt32
    package init(rawValue: UInt32)
}

package struct PresentationRevision: Equatable, Hashable, Sendable {
    package let rawValue: UInt32
    package init(rawValue: UInt32)
}

package struct NormalizedPointerEvent: Equatable, Sendable {
    package let phase: PointerPhase
    package let position: Point
    package let source: InputSourceID
    package let sequence: PointerSequenceID
    package let ordinal: InputOrdinal
    package let presentationRevision: PresentationRevision
    package init(
        phase: PointerPhase,
        position: Point,
        source: InputSourceID,
        sequence: PointerSequenceID,
        ordinal: InputOrdinal,
        presentationRevision: PresentationRevision
    )
}
```

Every raw identity bit pattern is a valid opaque value at the Foundation
boundary. The producing integration owns allocation; the later EXECUTION
contract owns phase order, ordinal progression, identity reuse, wrap
ambiguity, admission, cancellation, and resynchronization. No raw value is a
sentinel for absence or invalidity. `NormalizedPointerEvent` is always a
presentation-coupled pointer event; any future presentation-independent input
family requires its own approved contract rather than an absent-provenance
sentinel. `UInt16` bounds the source namespace to 65,536 representable values;
actual active-source capacity is a smaller host/runtime contract. The `UInt32`
sequence, ordinal, and revision namespaces are finite; ADR-033 governs the
consumer's fail-closed behavior when reuse or wrap cannot be proven safe. A
non-activating cancellation fact, if used by EXECUTION, is not a fourth
`PointerPhase` and does not change this event representation.

All owned values MUST be value-semantic and usable in caller-owned or inline
static storage. Their correctness MUST NOT depend on reference identity,
allocation, reflection, unrestricted existential storage, or runtime target
discovery.

## Behavior

### Geometry

- Geometry arithmetic MUST detect overflow and MUST NOT silently wrap,
  saturate, trap as the only specified behavior, or expose partial geometry as
  complete.
- Construction or derivation of a negative dimension MUST return `nil`.
- Rectangle construction MUST calculate both exclusive maximum edges through
  checked addition and return `nil` on either overflow. After successful
  construction, `maxX` and `maxY` MUST return those mathematically exact
  exclusive edges and `contains` MUST implement the half-open region
  `[minX, maxX) x [minY, maxY)` without unchecked arithmetic.
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
  a local `nil` result that the producing adapter maps into the SPEC-003-owned
  outcome seam; it MUST NOT clamp or wrap.

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
- a rectangle whose exclusive maximum edge is unrepresentable; and
- physical-to-logical input conversion outside the scalar range.

Every raw source, sequence, ordinal, and revision bit pattern is representable;
whether a value is stale, out of order, ambiguously reused, or otherwise
inadmissible belongs to EXECUTION rather than Foundation construction.

Foundation reports its local rejection as `nil`. These failures MUST be
deterministic for identical inputs and MUST NOT produce a partially valid
value. The first boundary that reports the condition cross-layer MUST map it
to the exact `GiftUIFailureFact` row in `Types / APIs`; it MUST NOT collapse
`.invalidValue` into `.arithmeticOverflow`, change `.foundation` origin,
widen `.operation` scope, or weaken `.contained` containment. Foundation MUST
NOT define containment, recovery, health,
diagnostics, diagnostic delivery, retry, drop/cancel, or host policy.
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
- `GeometryScalar` MUST occupy 4 bytes; `InputSourceID` MUST occupy 2 bytes;
  `PointerSequenceID`, `InputOrdinal`, and `PresentationRevision` MUST each
  occupy 4 bytes.
- `Point` and `Size` MUST each occupy no more than 8 bytes, `Rect` no more than
  16 bytes, `ProposedSize` no more than 16 bytes, and
  `NormalizedPointerEvent` no more than 32 bytes under the supported host and
  Embedded Swift compilers.
- Release and Embedded Swift evidence MUST report `MemoryLayout<T>.size`,
  `stride`, and `alignment` for every owned value, the incremental linked
  section contribution defined below, and evidence that construction and
  arithmetic introduce no allocation. A value-size regression above any limit
  is non-conforming even when source behavior is unchanged.

### Reproducible evidence configuration

The supported measurement compilers are fixed for this review baseline:

| Fixture | Compiler and target | Optimization |
| --- | --- | --- |
| macOS dynamic/static | Apple Swift 6.3.3 (`swiftlang-6.3.3.1.3`), `arm64-apple-macosx26.0` | release `-O`, whole-module optimization |
| Raspberry Pi 1 | Swift 6.3.2, `armv6-unknown-linux-gnueabihf`, Raspios Bookworm SDK pinned by `scripts/raspberry-pi/toolchain.env` | release `-O`, whole-module optimization |
| nRF52840 | Swift 6.3.2, `armv7em-none-none-eabi`, Zephyr 4.3.0 and SDK 0.17.4 pinned by `scripts/nrf52840/toolchain.env` | `-Osize`, whole-module optimization, Embedded Swift enabled |

The implementation MUST provide one checked-in driver at
`scripts/contracts/run-spec-002.sh`. The reproducible commands are exactly:

```text
scripts/contracts/run-spec-002.sh --profile macos-dynamic
scripts/contracts/run-spec-002.sh --profile macos-static
scripts/contracts/run-spec-002.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-002.sh --profile nrf52840-embedded
```

The driver MUST fail when the active compiler identity differs from the table
or pinned environment, and MUST record the complete compiler version, target,
SDK identity, optimization flags, command line, and repository revision. The
ARMv6 and nRF invocations are cross-build/inspection seams and require no
connected hardware or flash operation.

“Incremental linked section contribution” replaces the ambiguous phrase
“GiftUI object size.” For each profile, the driver builds two minimal
executables from the same source template and link inputs. The baseline has an
empty entry point; the candidate additionally references every SPEC-002-owned
public or SPI value and checked operation so dead stripping cannot omit them.
The evidence reports candidate minus baseline bytes for executable code,
read-only data, initialized writable data, zero-initialized data, and total
file size using the toolchain's section-size utility. It also preserves both
link maps. This delta is descriptive evidence; the normative pass/fail limits
remain the per-value layout maxima and zero-allocation rules above unless a
later approved revision adds linked-section ceilings.

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

- Table-driven tests MUST cover zero, ordinary, `Int32.min`, and `Int32.max`
  plus every overflow edge for `GeometryArithmetic.add`, `subtract`, and
  `multiply`.
- Construction tests MUST cover valid zero dimensions, invalid negative
  dimensions, independently absent proposed dimensions, and maximum valid
  extents.
- Rectangle tests MUST exercise successful and rejected construction near both
  scalar limits, exact exclusive edges, empty rectangles, and half-open
  containment without unchecked intermediate overflow.
- Copy and equality tests MUST demonstrate value semantics and absence of
  shared mutable state.

### Normalized input tests

- Fixtures MUST construct every normalized phase with minimum and
  maximum valid coordinates and bounded correlation values.
- Raw-field fixtures MUST cover minimum and maximum values for every identity,
  ordinal, and revision wrapper. Negative conversion fixtures MUST prove that
  out-of-range physical coordinates produce local `nil` and the owner adapter
  maps that rejection to the SPEC-003-owned outcome without a partial event.
- Compile and type-inspection fixtures MUST prove that normalized values expose
  no concrete backend, platform, OS, driver, transport, HAL, or hardware type.
- These tests MUST NOT assert admission, stale-event, cancellation, hit-test,
  or dispatch semantics owned by execution and interaction contracts.

### Dependency and profile tests

- `Tests/ContractFixtures/SPEC002/target-dependencies.yaml` MUST be the
  checked-in direct-dependency allow-list. It MUST contain one entry for every
  library, executable, system, and test target returned by
  `swift package dump-package`, including targets with an empty dependency
  list. The contract driver compares the two target-name sets for exact
  equality, compares every declared direct target dependency, rejects an
  omitted or unknown target or edge, and performs an independent cycle check.
  This exact-set rule makes newly added targets fail closed until reviewed.
- The same driver MUST inspect exported declarations and compiled module
  dependencies to prove that `GiftUI` does not depend on or re-export
  prohibited higher or concrete modules; the manifest allow-list alone is not
  evidence of non-re-export.
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
- The Embedded Swift compile fixture MUST use the project-local nRF toolchain,
  `armv7em-none-none-eabi`, `-enable-experimental-feature Embedded`, `-Osize`,
  and whole-module optimization. It MUST compile only the Foundation source
  set and its measurement fixture; it does not require a connected board.

The complete runtime, backend, host, and connected-hardware suites are
downstream conformance evidence and MUST NOT be required to execute this
Specification's independent tests.

## Acceptance Criteria

- [ ] **PF-001:** `GeometryScalar` is `Int32` in all four MVP configurations,
  and the public `Point`, `Size`, `Rect`, and `ProposedSize` declarations and
  visibility match this contract.
- [ ] **PF-002:** Every invalid dimension, invalid proposal, overflowing edge,
  and overflowing arithmetic operation returns `nil`, produces no partial
  value, and maps at the first cross-layer owner boundary to the exact
  condition, `.foundation` origin, `.operation` scope, and `.contained`
  containment fixed in `Types / APIs`.
- [ ] **PF-003:** Valid rectangles expose exact exclusive edges and half-open
  containment for the complete boundary corpus, including both scalar limits
  and empty rectangles.
- [ ] **PF-004:** `NormalizedPointerEvent` and its phase, source, sequence,
  ordinal, and revision values have the exact package-SPI declarations and raw
  widths in this contract and expose no concrete integration type or absent-
  provenance sentinel.
- [ ] **PF-005:** A checked-in package dependency allow-list proves the graph
  acyclic, covers exactly every current package target and direct target edge,
  `GiftUI` re-exports no prohibited module, and every protected owner has both
  a positive-import and forbidden-import fixture.
- [ ] **PF-006:** The same Foundation declarations compile in macOS dynamic,
  macOS static, Raspberry Pi ARMv6, and nRF52840 Embedded Swift configurations;
  host and Embedded Swift value-semantic fixtures produce equal results.
- [ ] **PF-007:** Recorded size, stride, alignment, allocation, and linked-section
  evidence satisfies every Performance Requirement, uses the four exact
  contract-driver commands and compiler identities, and reports the defined
  baseline/candidate linked-section deltas and link maps.
- [ ] **PF-008:** Migration evidence enumerates every proof-of-concept `Int`,
  precondition, mutable field, source location, and input case that changed,
  and no compatibility shim weakens the checked or bounded contract.
- [ ] **PF-009:** SPEC-002, SPEC-003, and SPEC-004 preserve their reciprocal
  ownership rule, and RFC-004/RFC-011/ADR-033 traceability remains
  bidirectional.
- [ ] **PF-010:** Review finds no declarative behavior, failure disposition,
  diagnostics, capability resolution, layout policy, input admission,
  backend policy, or host product policy defined normatively by SPEC-002.

## Implementation Notes

This section is non-authoritative guidance. The current proof of concept has
`Point`, `Size`, `Rect`, `ProposedSize`, `InputEvent`, and package-scoped
checked layout arithmetic in `Sources/GiftUI/`. Existing unit tests already
provide evidence for integer retention, arithmetic overflow detection, and
overflow-safe rectangle containment. These names and behaviors should be
inventoried against the completed contract; `Int`, mutable stored properties,
precondition-only invalid-dimension handling, the three-case `InputEvent`, and
the existing package graph are migration evidence rather than authority.

Implementation should encode the fixed compiler checks, exact-set dependency
comparison, link-map capture, and layout/allocation probes behind the single
contract driver named above. Downstream Specifications should consume these
declarations rather than copy signatures.

## Implementation Records

- [SPEC-002 Implementation Plan](../implementation-plans/spec-002-implementation-plan.md)
  is the derived, non-authoritative ordering and evidence strategy for this
  approved contract.

## Open Issues

No contract issue remains open. Reciprocal terminology coordination with
SPEC-003 and the SPEC-004 extent adapter is complete, and this approved contract fixes
the compiler identities, commands, linked-size baseline, and exact dependency
allow-list coverage needed to produce PF-005/PF-007 evidence. Producing that
evidence is implementation/conformance work, not an unresolved pre-review
contract choice.

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
- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [ADR-005: Semantic, Layout, and Render Boundary](../adrs/adr-005-semantic-layout-render-boundary.md)
- [ADR-006: Shared Semantics Across Runtime Profiles](../adrs/adr-006-shared-semantics-runtime-profiles.md)
- [ADR-007: Integration Ownership and Host Composition](../adrs/adr-007-integration-ownership-and-host-composition.md)
- [ADR-008: Module Dependency Graph and MVP Package Topology](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
- [ADR-009: Checked Integer Geometry for MVP](../adrs/adr-009-checked-integer-geometry.md)
- [ADR-033: Bounded Application Actions and Model-Target Dispatch](../adrs/adr-033-bounded-application-actions-and-model-target-dispatch.md)
- [SPEC-003: Failure Outcomes and Containment](spec-003-failure-outcomes-and-containment.md)
- [SPEC-004: Capability Contribution and Resolution](spec-004-capability-contribution-and-resolution.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [GiftUI MVP Specification Portfolio](../roadmap/MVP_SPECIFICATION_PORTFOLIO.md)
- [GiftUI Principles](../PRINCIPLES.md)
- [GiftUI Project Glossary](../GLOSSARY.md)
- [GiftUI Framework Proof-of-Concept Specification](../GiftUI_Framework_Spec.md)
