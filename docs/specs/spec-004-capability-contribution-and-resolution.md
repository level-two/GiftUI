---
id: SPEC-004
feature: capability-system
title: Capability Contribution and Resolution
status: implementing
authors:
  - codex
created: 2026-08-22
updated: 2026-08-30
proposal:
  - PROPOSAL-004
related_rfcs:
  - RFC-002
  - RFC-004
  - RFC-005
  - RFC-006
related_adrs:
  - ADR-010
  - ADR-017
  - ADR-018
  - ADR-019
  - ADR-020
related_specs:
  - SPEC-002
  - SPEC-003
  - SPEC-012
  - SPEC-014
  - SPEC-015
related_future_work:
  - FW-006
  - FW-007
  - FW-008
  - FW-014
  - FW-015
  - FW-018
related_explorations: []
related_spikes:
  - SPIKE-001
  - SPIKE-002
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPEC-004: Capability Contribution and Resolution

> **Approval status:** Explicitly reapproved by the maintainer after the
> 2026-08-30 fixed-width raster-arithmetic and validation-only
> operation-stream corrections. The corrected contract is authoritative for
> continued implementation.

## Summary

This Specification defines the Wave 1 contract for typed capability
contributions, deterministic bounded host resolution, immutable effective
results, and the single MVP `rasterPresentation` capability family. It owns
capability contribution and resolution vocabulary. It references portable
value semantics owned by SPEC-002 and failure, outcome, and containment
vocabulary owned by SPEC-003; it does not redefine either set of concepts or
import their modules into the capability foundation.

The contract has an independent acceptance seam: normalized fixtures invoke a
pure resolver without a runtime or backend implementation, compare results
across every contribution order, exercise absence and incompatibility, and
prove that the static path performs no heap allocation.

## Scope

This Specification covers:

- the foundational `GiftUICapabilities` module and its import boundary;
- typed, contributor-owned inputs gathered by a target host;
- required and optional capability requirements and explicit absence
  behavior;
- deterministic initialization-time resolution into an immutable snapshot or
  stable validation failure;
- the exact MVP catalogue boundary of one family, `rasterPresentation`;
- the semantic fields and compatibility checks required by that family;
- equivalent normalized results for dynamic and static profiles; and
- hardware-free fixture, dependency, bounded-resource, and zero-allocation
  evidence.

The contract applies to the macOS dynamic, macOS static, Raspberry Pi 1/Linux
dynamic with PiScreen, and nRF52840 static with TFT MVP configurations. It
specifies capability semantics and their host-facing seams, not the concrete
backend, display, runtime, or board integrations that supply those seams.

## Goals

- Give every capability input, result, constraint, and absence case one
  unambiguous owner and meaning.
- Resolve the same effective result from the same normalized inputs regardless
  of contribution, discovery, or iteration order.
- Reject missing or incompatible required presentation behavior before the
  first run cycle.
- Keep the static contribution, resolution, result-construction, storage, and
  access path allocator-independent and explicitly bounded.
- Allow materially different full-surface and tiled realizations to satisfy
  one `rasterPresentation` semantic promise without exposing target identity.
- Keep operational health and failure disposition outside mutable capability
  state.

## Non-goals

- A general Trait system, string-keyed registry, open heterogeneous catalogue,
  universal capability lattice, plugin discovery mechanism, or service
  locator.
- Capability families other than `rasterPresentation` for MVP.
- Treating runtime profile, selected components, ordinary display
  configuration, input presence, observable state, backpressure, or device
  health as capability families.
- Defining portable geometry, scalar, encoding-storage, or other cross-module
  value semantics owned by SPEC-002.
- Defining cross-layer outcome, containment, failure-disposition, or
  diagnostic semantics owned by SPEC-003.
- Defining render operations, frame handoff, rasterization, display transfer,
  target-host assembly, or runtime startup beyond their capability-facing
  input and result seams.
- Live mutation, renegotiation, or replacement of a capability snapshot after
  runtime construction; live surface reconfiguration remains FW-018.
- A replayable or retained GiftUI operation-stream lifetime.
- A stable serialized snapshot, binary ABI, public portable-view query API, or
  concrete target/backend/device identifiers in capability values.

## Dependencies

- PROPOSAL-004 is accepted; RFC-004 and RFC-006 are approved; and ADR-010 and
  ADR-017 through ADR-020 are accepted. RFC-004 and ADR-010 directly govern
  the one-shot operation stream consumed by this capability family.
- SPEC-002 owns portable values and import rules. Because ADR-019 forbids
  `GiftUICapabilities` from importing `GiftUI`, component-local adapters map
  SPEC-002-owned concrete values into the closed capability-specific
  vocabulary. The mapping must preserve their approved meaning and bounds
  without making capability records a competing public geometry contract.
- SPEC-003 owns the bounded failure/outcome and containment vocabulary through
  which a host reports resolution failure. SPEC-004 owns the capability-domain
  reason mapped by that vocabulary, not the enclosing outcome semantics. For
  a required family, the downstream host adapter uses SPEC-003's exact
  capability condition catalogue and encloses the resulting fact in
  `GiftUIOutcome<CapabilitySnapshot>`.
- RFC-002 B2 structural validation and this Specification's capability
  resolution are distinct, conjunctive startup gates. Neither substitutes for
  the other.
- ADR-010 owns the synchronous one-shot operation handoff and borrowed-stream
  lifetime that `rasterPresentation` checks for compatibility.
- The four MVP configurations and the Signal Analyzer render vocabulary in
  `docs/MVP_SCOPE.md` bound the catalogue and fixture set.
- SPIKE-001 and SPIKE-002 are feasibility evidence only. They do not define
  production types, storage layouts, or budgets.

## Related ADRs

- ADR-010 requires synchronous one-shot frame handoff and forbids retaining or
  replaying the borrowed GiftUI operation stream. This Specification therefore
  treats that lifetime as a compatibility input and permits persistence only
  for backend-owned derived payload after synchronous consumption.
- ADR-017 requires separate structural-selection, immutable semantic
  capability, explicit policy/configuration, and mutable operational-state
  planes. This Specification therefore freezes the effective snapshot before
  the first run cycle and excludes runtime health mutation.
- ADR-018 requires fixture-justified, typed, domain-specific requirements,
  owned contributions, quantitative constraints, and explicit absence
  behavior. This Specification therefore admits no second MVP family and no
  target-identity or Boolean-bag shortcut.
- ADR-019 places capability vocabulary and pure resolution in the foundational
  `GiftUICapabilities` module and requires deterministic, bounded,
  allocator-independent static resolution at the target-host composition
  point.
- ADR-020 defines the single composite `rasterPresentation` family, its four
  contributor boundaries, compatibility dimensions, semantic promise, and
  stable unavailable result. This Specification elaborates only those
  accepted fields and checks.

## Terminology

- **Capability family:** A fixture-justified typed domain whose requirement,
  contributions, resolution rule, effective result, and unavailability
  reasons are owned by `GiftUICapabilities`.
- **Requirement:** The semantic behavior and quantitative bounds that an
  assembled stack must provide. A requirement declares whether absence is
  required or optional and the behavior for optional absence.
- **Contribution:** An immutable typed record containing only facts owned by
  one contributor boundary. A contribution never asserts end-to-end support.
- **Contributor role:** One of render producer, raster/backend adapter,
  surface/display adapter, or target-host resource policy for
  `rasterPresentation`.
- **Policy:** Explicit host input that selects only among otherwise conforming
  realizations. Policy cannot create support or weaken a requirement.
- **Resolution:** A pure, deterministic intersection and validation of a
  requirement, typed contributions, structural facts needed by the family,
  and policy.
- **Effective result:** The immutable capability-level realization properties
  and bounds produced by successful resolution. It contains no concrete
  target, backend, driver, or device identity.
- **Unavailable reason:** A stable capability-domain explanation that no
  conforming result exists. Its enclosing failure/outcome representation is
  owned by SPEC-003.
- **Capability snapshot:** The immutable collection of effective results for
  one assembled runtime. For MVP it contains at most the one admitted family.
- **Operational state:** Mutable health, backpressure, disconnection, or
  runtime failure after configuration. It is not a contribution and cannot
  mutate a snapshot.

Concrete portable extents and checked quantities have the semantics and
visibility established by SPEC-002. Where the closed capability vocabulary
needs the corresponding fact, a local adapter validates and maps that value
into a capability-specific bounded record; `GiftUICapabilities` does not
import or re-export the SPEC-002 type.

## Public Contract

Portable application and Presentation code MUST NOT need to import
`GiftUICapabilities`, branch on a target/backend/device identity, or query a
global capability registry to express the Signal Analyzer. `GiftUI` MUST NOT
re-export `GiftUICapabilities`.

A configuration that declares `rasterPresentation` required is eligible to
start only when resolution returns an effective result satisfying the entire
requirement. Optional absence, if used by a later approved host contract, MUST
remain explicit and MUST NOT be presented as support. The same normalized
inputs and policy MUST expose equivalent semantic results and absence reasons
in static and dynamic profiles.

Capability declarations are immutable for the lifetime of the assembled
runtime. A changed component graph, required extent, orientation, semantic
requirement, or capability declaration requires construction and validation
of a new runtime. Backpressure, refusal, disconnection, and post-handoff
failure use SPEC-003-owned outcome/failure vocabulary and MUST NOT alter the
snapshot.

## Module Contract

`GiftUICapabilities` exclusively owns:

- capability requirement, contribution, policy-input, effective-result,
  snapshot, and unavailability-reason vocabulary;
- pure family-specific resolution rules; and
- the `rasterPresentation` catalogue entry.

`GiftUICapabilities` MUST NOT import `GiftUI`, semantic, layout, render,
execution, failure, runtime, backend, platform, driver, OS/RTOS, HAL, or
concrete integration modules. Component-local adapters, not the foundational
module, MUST translate SPEC-002-owned values into the closed capability-
specific representation while preserving their meaning. Its pure resolver
returns a capability-domain effective-or-unavailable result; the target host
maps that result into SPEC-003-owned outcome vocabulary outside the
foundational module rather than recreating or importing failure concepts.

Contributor adapters MAY depend on their own component contract and
`GiftUICapabilities`; a component contract may expose SPEC-002-owned values
where its already-approved import direction permits that dependency. Each
adapter translates local facts into the closed capability vocabulary without
placing concrete types or identities in the contribution. Contributors MUST
NOT import a higher consumer or another concrete contributor merely to form a
contribution.

The target host is the composition root. It gathers typed inputs, supplies
policy, owns resolver workspace and snapshot storage, invokes resolution once
during bounded initialization, and passes the immutable effective result only
to approved consumers. Validation tooling may format or symbolize results but
has no resolution or semantic authority.

SPEC-004 MUST NOT duplicate portable-value definitions from SPEC-002 or the
failure/outcome and containment definitions from SPEC-003. Changes at either
shared boundary require reciprocal review of all three Wave 1 Specifications.

## Types / APIs

The declarations in this section are the normative source-level surface of
the `GiftUICapabilities` library product and target. All declarations are
`public` because target hosts and contributor adapters may live in sibling or
downstream packages. None is re-exported by `GiftUI`. Stored-property order,
padding, and source-file placement are not API, but the finite case sets, raw
widths, initializer validity, and size ceilings below are normative.

All records conform to `Equatable` and `Sendable`. Enumerations with raw values
use the exact unsigned width shown. `OptionSet`'s required raw initializer may
materialize unknown bits, but every validated record initializer and the
resolver reject them; unknown bits are not forward-compatible support.

### Common bounded values

```swift
public struct CapabilityExtent: Equatable, Sendable {
    public let width: UInt16
    public let height: UInt16
    public init?(width: UInt16, height: UInt16)
}

public struct CapabilityByteCount: Equatable, Comparable, Sendable {
    public let rawValue: UInt32
    public init(rawValue: UInt32)
}

public struct RasterOperationSet: OptionSet, Equatable, Sendable {
    public let rawValue: UInt8
    public init(rawValue: UInt8)
    public static let opaqueRectangles: Self
    public static let positionedText: Self
    public static let straightLineStrokes: Self
    public static let clipping: Self
    public static let damage: Self
}

public enum OperationStreamLifetime: UInt8, Equatable, Sendable {
    case synchronousBorrowedOneShot = 1
    case incompatibleWithSynchronousBorrowedOneShot = 2
}

public struct CanonicalPixelEncodingSet: OptionSet, Equatable, Sendable {
    public let rawValue: UInt8
    public init(rawValue: UInt8)
    public static let rgb565BigEndian: Self
    public static let rgba8888: Self
}

public struct SubmissionLifetimeSet: OptionSet, Equatable, Sendable {
    public let rawValue: UInt8
    public init(rawValue: UInt8)
    public static let synchronousBorrow: Self
    public static let synchronousCopy: Self
    public static let ownershipTransfer: Self
}

public struct SubmissionHandoffSet: OptionSet, Equatable, Sendable {
    public let rawValue: UInt8
    public init(rawValue: UInt8)
    public static let synchronous: Self
    public static let queued: Self
}
```

`OperationStreamLifetime.incompatibleWithSynchronousBorrowedOneShot` is a
validation-only negative fact, not an admitted operation-stream mode. It lets
a producer or raster candidate report that it cannot satisfy ADR-010 without
naming, retaining, or authorizing another lifetime. A requirement initializer
accepts only `.synchronousBorrowedOneShot`; contribution initializers accept
the negative fact so the typed resolver can return `.operationStreamMismatch`
and exercise its documented precedence. An available effective result always
contains `.synchronousBorrowedOneShot`. The negative case MUST NOT be selected,
forwarded as support, or interpreted as approval of FW-014 replayable delivery.

`CapabilityExtent.init` returns `nil` for a zero dimension. A valid SPEC-002
`Size` has non-negative `Int32` dimensions and maps to `CapabilityExtent` only
when both are in `1...UInt16.max`. The owning host adapter maps a zero source
dimension to `.malformedRequirement(field: .extent)` and a positive dimension
greater than `UInt16.max` to `.logicalExtentOverflow`. A negative raw dimension
is rejected earlier by SPEC-002 as `.invalidValue` with `.foundation` origin
and therefore never reaches this adapter as a `Size`. This mapping creates no
second public geometry model: `CapabilityExtent` is capability-domain input
inside `GiftUICapabilities` and is not re-exported to portable Presentation.
`CapabilityByteCount` permits zero. Byte-count
addition and multiplication inside the resolver MUST use checked `UInt32`
arithmetic and resolve unavailable on overflow.

The two canonical pixel encodings describe byte-level interchange:
`rgb565BigEndian` is one big-endian 5:6:5 word per pixel and `rgba8888` is four
bytes per pixel in R, G, B, A order. Native surface formats and conversion
details remain adapter-local.

The option-set bit assignments are fixed for build-local equality and fixture
comparison:

| Option set | Bit 0 | Bit 1 | Bit 2 | Bit 3 | Bit 4 |
| --- | --- | --- | --- | --- | --- |
| `RasterOperationSet` | opaque rectangles | positioned text | straight-line strokes | clipping | damage |
| `CanonicalPixelEncodingSet` | RGB565 big-endian | RGBA8888 | reserved | reserved | reserved |
| `SubmissionLifetimeSet` | synchronous borrow | synchronous copy | ownership transfer | reserved | reserved |
| `SubmissionHandoffSet` | synchronous | queued | reserved | reserved | reserved |

The union of all five declared `RasterOperationSet` bits therefore has raw
value `0x1f`.

### Requirement and contribution declarations

```swift
public enum CapabilityAbsence: UInt8, Equatable, Sendable {
    case required = 1
    case optional = 2
}

public struct RasterPresentationRequirement: Equatable, Sendable {
    public let operations: RasterOperationSet
    public let extent: CapabilityExtent
    public let operationStream: OperationStreamLifetime
    public let acceptedEncodings: CanonicalPixelEncodingSet
    public let acceptedSubmissionLifetimes: SubmissionLifetimeSet
    public let maximumRasterBytes: CapabilityByteCount
    public let maximumPayloadBytes: CapabilityByteCount
    public let maximumInFlightBytes: CapabilityByteCount
    public let absence: CapabilityAbsence
}

public struct RenderProducerContribution: Equatable, Sendable {
    public let operations: RasterOperationSet
    public let operationStream: OperationStreamLifetime
}

public enum RasterRealizationKind: UInt8, Equatable, Sendable {
    case fullSurface = 1
    case tiled = 2
}

public struct RasterRealizationKindSet: OptionSet, Equatable, Sendable {
    public let rawValue: UInt8
    public init(rawValue: UInt8)
    public static let fullSurface: Self
    public static let tiled: Self
}

public struct RasterRealizationContribution: Equatable, Sendable {
    public let kind: RasterRealizationKind
    public let operations: RasterOperationSet
    public let operationStream: OperationStreamLifetime
    public let encodings: CanonicalPixelEncodingSet
    public let producedSubmissionLifetimes: SubmissionLifetimeSet
    public let maximumExtent: CapabilityExtent
    public let maximumRegionWidth: UInt16
    public let maximumRegionHeight: UInt16
    public let rowByteAlignment: UInt16
    public let maximumRasterBytes: CapabilityByteCount
    public let maximumPayloadBytes: CapabilityByteCount
}

public struct RasterBackendContribution: Equatable, Sendable {
    public let primary: RasterRealizationContribution
    public let alternate: RasterRealizationContribution?
}

public struct SurfaceDisplayContribution: Equatable, Sendable {
    public let extent: CapabilityExtent
    public let encodings: CanonicalPixelEncodingSet
    public let acceptedSubmissionLifetimes: SubmissionLifetimeSet
    public let handoffs: SubmissionHandoffSet
    public let maximumRegionWidth: UInt16
    public let maximumRegionHeight: UInt16
    public let rowByteAlignment: UInt16
    public let maximumInFlightCount: UInt8
    public let maximumInFlightBytes: CapabilityByteCount
}

public struct RasterPresentationPolicy: Equatable, Sendable {
    public let maximumRasterBytes: CapabilityByteCount
    public let maximumPayloadBytes: CapabilityByteCount
    public let maximumInFlightBytes: CapabilityByteCount
    public let allowedRealizations: RasterRealizationKindSet
    public let allowedEncodings: CanonicalPixelEncodingSet
    public let preferredRealization: RasterRealizationKind
    public let preferredEncoding: CanonicalPixelEncodingSet
}
```

`RasterRealizationKindSet.fullSurface` is bit 0 and `.tiled` is bit 1.

Each record exposes a public initializer whose labels and parameter types
match its stored properties in declaration order. Initializers are failable,
return `nil` for the invalid cases below, and MUST NOT trap on caller data.
The owning adapter maps an invalid requirement to
`.malformedRequirement(field:)` and an invalid contribution to
`.malformedContribution(role:field:)` before insertion. Successful
construction proves these invariants; the typed resolver cannot receive a
record that failed them and does not recreate malformed records for testing:

- operation and encoding sets are non-empty and contain only declared bits;
- the requirement operation-stream lifetime is exactly
  `.synchronousBorrowedOneShot`; producer and realization contributions may
  carry the validation-only incompatible case for deterministic rejection;
- the requirement operation set contains exactly `.opaqueRectangles`,
  `.positionedText`, `.straightLineStrokes`, `.clipping`, and `.damage` for
  every supported host;
- allowed realization and encoding sets are non-empty and contain only
  declared bits;
- `preferredRealization` is allowed, and `preferredEncoding` contains exactly
  one allowed declared encoding bit;
- every row-byte alignment and `maximumInFlightCount` is nonzero;
- surface region limits are nonzero and no greater than the surface extent;
- a backend has one or two realizations, and two realizations have distinct
  `kind` values;
- every realization has non-empty encoding and produced-lifetime sets;
- every realization's region limits are nonzero and no greater than its
  maximum extent; and
- a tiled realization's payload describes at least one complete aligned row
  at `maximumRegionWidth` for each advertised encoding.

The optional `alternate` is the only MVP alternate-realization slot. Thus the
family has a compile-time maximum of two candidates. Policy may prefer one
candidate and one encoding, but the resolver evaluates both candidates and
both encoding bits for conformance before applying that preference.

#### Byte-bound and region arithmetic

Only fields of type `CapabilityByteCount` whose name begins with `maximum` are
available byte-capacity ceilings; zero is valid and provides no byte capacity.
The two byte-count fields on `RasterRealizationContribution` are backend-owned
available byte ceilings. All other `maximum...` fields are structural bounds:
`maximumExtent` is a valid nonzero `CapabilityExtent`, both contributor roles'
`maximumRegionWidth` and `maximumRegionHeight` values are nonzero, and
`maximumInFlightCount` is nonzero, as required by their failable initializers
above. Zero for one of those structural bounds is malformed input, not an
available result with no capacity.
`regionExtent`, `rowBytes`, and the four `required...`/`inFlightCount` fields
on `EffectiveRasterPresentation` are the exact geometry and usage selected by
the resolver, not spare capacity. No byte field includes the
inline capability records, resolver workspace, operation-stream storage, or
diagnostic storage.

For each candidate encoding the resolver performs the following checked
`UInt32` arithmetic. RGB565 has `bytesPerPixel = 2`; RGBA8888 has
`bytesPerPixel = 4`.

1. The effective row alignment is the least common multiple of the candidate
   and surface row alignments. The LCM and every following operation are
   checked.
2. `unalignedRowBytes = extent.width * bytesPerPixel` and `rowBytes` is the
   least multiple of the effective alignment greater than or equal to
   `unalignedRowBytes`.
3. The region width is always the full logical extent width. A candidate is
   incompatible when either contributor's `maximumRegionWidth` is smaller.
   For `fullSurface`, region height is the full logical extent height and both
   maximum-region heights must admit it. For `tiled`, region height is the
   minimum of logical height and the two nonzero maximum-region heights. This
   chooses the tallest admissible complete-row tile deterministically; the
   resolver does not search smaller tiles to evade an explicit byte ceiling.
   The result is stored as `regionExtent`, and the aligned row size from step
   2 is stored as `rowBytes`.
4. The resolver checks `rowBytes * regionHeight` once. On success it stores
   that same representable value as both `requiredRasterBytes` and
   `requiredPayloadBytes`. They remain separate usage domains because raster
   working storage and the derived submitted payload have different owners
   even though their MVP byte counts are equal.
5. MVP resolution selects exactly one derived payload in flight, so
   `inFlightCount = 1` and `requiredInFlightBytes = requiredPayloadBytes`.
   `SurfaceDisplayContribution.maximumInFlightCount` must admit that count.

The available ceiling for raster bytes is the minimum of the requirement,
candidate, and host-policy maximum-raster fields. Payload uses the analogous
three maximum-payload fields. In-flight bytes use the minimum of requirement,
surface, and host-policy maximum-in-flight fields. Required usage greater than
its available ceiling returns `insufficientCapacity` for that domain with the
exact computed usage and minimum ceiling.

All arithmetic remains checked even where the closed typed domain proves the
result representable. For nonzero `UInt16` alignments,
`lcm(a, b) <= a * b <= UInt16.max * UInt16.max < UInt32.max`. The largest
unaligned row is `UInt16.max * 4 = 262,140` bytes. If the LCM exceeds that row,
round-up produces the representable LCM; otherwise the rounded row is less
than twice the unaligned row. Therefore effective-alignment LCM,
`unalignedRowBytes`, and aligned-row round-up cannot overflow for a
constructible typed input. Boundary tests MUST prove those maxima and MUST NOT
manufacture wider private inputs as resolver fixtures.

The checked `rowBytes * regionHeight` usage multiplication can overflow. It
is shared by the raster and payload usage values and is assigned
`byteCountOverflow(domain: .raster)`, the lowest-raw-value affected capacity
domain. Once that multiplication succeeds, the resolver copies its exact
representable value to both usage fields; a payload-only arithmetic overflow
is not constructible. MVP `requiredInFlightBytes` is an exact copy of the
already representable `requiredPayloadBytes`, so it performs no further
arithmetic and cannot independently produce `.inFlight` overflow. The resolver
never reports `.resolverWorkspace`, `.payload`, or `.inFlight` for byte
arithmetic and never treats overflow as zero, saturation, or wrapping.

Consequently, the nRF52840 fixture's width `480`, height limit `4`, RGB565
encoding, and alignment `2` yield a 960-byte row and exactly 3,840 required
raster, payload, and in-flight bytes. A zero ceiling fails that positive usage.

### Role-addressed contribution buffer

```swift
public enum RasterPresentationContributorRole: UInt8, Equatable, Sendable {
    case renderProducer = 1
    case rasterBackend = 2
    case surfaceDisplay = 3
    case hostResourcePolicy = 4
}

public enum RasterPresentationContribution: Equatable, Sendable {
    case renderProducer(RenderProducerContribution)
    case rasterBackend(RasterBackendContribution)
    case surfaceDisplay(SurfaceDisplayContribution)
    case hostResourcePolicy(RasterPresentationPolicy)
}

public struct RasterPresentationContributions: Equatable, Sendable {
    public static let capacity: UInt8 = 4
    public init()
    public mutating func insert(
        _ contribution: RasterPresentationContribution
    ) -> RasterPresentationContributionInsertion
}

public enum RasterPresentationContributionInsertion: Equatable, Sendable {
    case inserted
    case rejected(RasterPresentationUnavailable)
}
```

`RasterPresentationContributions` owns four inline role-addressed slots, a
four-bit duplicate-role mask, and no collection allocation. Insertion order is
not observable in final buffer equality or resolution. Individual `insert`
return values still identify the call that encountered a duplicate. A second
value for an occupied role returns
`.duplicateContributor(role:)`, sets that role's bit, preserves the first
value, and leaves every other slot unchanged. Because the contribution enum is
closed over exactly four roles, a fifth insertion is necessarily a duplicate;
there is no separately constructible contribution-capacity failure. Resolution
reports the lowest-raw-value duplicated role whenever any duplicate bit is set,
even if the caller ignored insertion results. It otherwise reports the
lowest-raw-value missing role when fewer than four roles are occupied. The
preserved value in a duplicated slot is never examined because duplicate
validation precedes semantic resolution, so differing duplicate values cannot
make the final result order-dependent. For the declared `Equatable`
conformance, two buffers with duplicates compare their duplicate masks and
nonduplicated slots; values in duplicated slots are ignored. This makes buffer
comparison consistent with the resolver's invalid-input semantics.

### Resolution and immutable snapshot

```swift
public struct RasterPresentationResolverWorkspace: Equatable, Sendable {
    public static let candidateCapacity: UInt8 = 2
    public let usableCandidateCapacity: UInt8
    public init?(usableCandidateCapacity: UInt8 = 2)
}

public enum CanonicalPixelEncoding: UInt8, Equatable, Sendable {
    case rgb565BigEndian = 1
    case rgba8888 = 2
}

public enum SubmissionLifetime: UInt8, Equatable, Sendable {
    case synchronousBorrow = 1
    case synchronousCopy = 2
    case ownershipTransfer = 3
}

public enum SubmissionHandoff: UInt8, Equatable, Sendable {
    case synchronous = 1
    case queued = 2
}

public struct EffectiveRasterPresentation: Equatable, Sendable {
    public let operations: RasterOperationSet
    public let extent: CapabilityExtent
    public let regionExtent: CapabilityExtent
    public let rowBytes: CapabilityByteCount
    public let operationStream: OperationStreamLifetime
    public let encoding: CanonicalPixelEncoding
    public let submissionLifetime: SubmissionLifetime
    public let handoff: SubmissionHandoff
    public let realization: RasterRealizationKind
    public let requiredRasterBytes: CapabilityByteCount
    public let requiredPayloadBytes: CapabilityByteCount
    public let inFlightCount: UInt8
    public let requiredInFlightBytes: CapabilityByteCount
}

public enum RasterPresentationResolution: Equatable, Sendable {
    case available(EffectiveRasterPresentation)
    case unavailable(RasterPresentationUnavailable)
}

public struct CapabilitySnapshot: Equatable, Sendable {
    public let rasterPresentation: EffectiveRasterPresentation?
    public init(rasterPresentation: EffectiveRasterPresentation?)
}

public enum RasterPresentationResolver {
    public static func resolve(
        requirement: RasterPresentationRequirement,
        contributions: borrowing RasterPresentationContributions,
        workspace: inout RasterPresentationResolverWorkspace
    ) -> RasterPresentationResolution
}
```

The workspace has storage for exactly two normalized candidates and is
reusable after every return. Its initializer accepts `0...2` and returns `nil`
for a larger usable capacity; a deliberately smaller usable capacity supports
bounded-host and exhaustion tests without changing storage layout. Resolution
performs no allocation and retains no borrow of the requirement,
contributions, or workspace. The snapshot is constructed only from
`.available`; an optional unavailable result produces a snapshot whose
`rasterPresentation` is `nil`, while a required unavailable result prevents
snapshot construction and runtime start.

### Unavailable vocabulary

```swift
public enum RasterPresentationMalformedField: UInt8, Equatable, Sendable {
    case operationSet = 1
    case encodingSet = 2
    case submissionLifetimeSet = 3
    case handoffSet = 4
    case extent = 5
    case region = 6
    case rowByteAlignment = 7
    case inFlightCount = 8
    case byteCount = 9
    case alternateRealization = 10
    case policyPreference = 11
}

public enum RasterPresentationCapacity: UInt8, Equatable, Sendable {
    case resolverWorkspace = 1
    case raster = 2
    case payload = 3
    case inFlight = 4
}

public enum RasterPresentationUnavailable: Equatable, Sendable {
    case malformedRequirement(field: RasterPresentationMalformedField)
    case duplicateContributor(role: RasterPresentationContributorRole)
    case missingContributor(role: RasterPresentationContributorRole)
    case malformedContribution(
        role: RasterPresentationContributorRole,
        field: RasterPresentationMalformedField
    )
    case insufficientCapacity(
        domain: RasterPresentationCapacity,
        required: CapabilityByteCount,
        available: CapabilityByteCount
    )
    case operationSetMismatch
    case operationStreamMismatch
    case logicalExtentOverflow
    case unsupportedLogicalExtent
    case noCommonCanonicalPixelEncoding
    case incompatibleSubmissionLifetime
    case incompatibleSubmissionHandoff
    case byteCountOverflow(domain: RasterPresentationCapacity)
    case policyHasNoConformingRealization
}
```

The associated payloads are bounded build-local facts, not stable serialized
codes. Human-readable text, source names, contributor identities, and richer
provenance are diagnostic projections outside `GiftUICapabilities`.

At the host boundary, an adapter maps `RasterPresentationUnavailable` into the
enclosing outcome vocabulary owned by SPEC-003 without changing the reason or
SPEC-003's containment and disposition semantics.

For a required family, that adapter MUST return the failure as
`GiftUIOutcome<CapabilitySnapshot>.failure` with `.capability` origin,
`.runtime` affected scope, and `.contained` containment. It MUST use this
exact one-to-one condition mapping:

| Unavailable case | SPEC-003 capability condition (raw value) |
| --- | --- |
| `malformedRequirement` | `rasterMalformedRequirement` (`12`) |
| `duplicateContributor` | `rasterDuplicateContributor` (`13`) |
| `missingContributor` | `rasterMissingContributor` (`14`) |
| `malformedContribution` | `rasterMalformedContribution` (`15`) |
| `insufficientCapacity` | `rasterInsufficientCapacity` (`16`) |
| `operationSetMismatch` | `rasterOperationSetMismatch` (`17`) |
| `operationStreamMismatch` | `rasterOperationStreamMismatch` (`18`) |
| `logicalExtentOverflow` | `rasterLogicalExtentOverflow` (`19`) |
| `unsupportedLogicalExtent` | `rasterUnsupportedLogicalExtent` (`20`) |
| `noCommonCanonicalPixelEncoding` | `rasterNoCommonCanonicalPixelEncoding` (`21`) |
| `incompatibleSubmissionLifetime` | `rasterIncompatibleSubmissionLifetime` (`22`) |
| `incompatibleSubmissionHandoff` | `rasterIncompatibleSubmissionHandoff` (`23`) |
| `policyHasNoConformingRealization` | `rasterPolicyHasNoConformingRealization` (`24`) |
| `byteCountOverflow` | `rasterByteCountOverflow` (`25`) |

Associated field, role, and capacity payloads remain available in the
capability-domain result and MAY be projected through SPEC-003's bounded
annotation or diagnostic seams; they MUST NOT select a different primary
condition. `GiftUICapabilities` does not import `GiftUIFailureCore`; the host
adapter is the first downstream boundary that imports and knows both
vocabularies.

## Behavior

The resolver MUST be pure with respect to runtime and contributor state. For
equal normalized requirements, contributions, policy, and declared capacities,
it MUST return an equal effective result or equal unavailable reason.

Resolution MUST:

1. return the lowest-role duplicate recorded by the contribution buffer;
2. validate that every required contributor role is present exactly once;
3. validate producer operation coverage and the ADR-010 one-shot-stream
   contract once for the family;
4. normalize the backend's one or two candidates into the caller-owned
   workspace, rejecting insufficient usable workspace before evaluating a
   partial candidate set;
5. for each candidate, validate operation coverage, stream lifetime, required
   extent, surface region and row-alignment compatibility, common canonical
   pixel encoding, submission lifetime/handoff compatibility, and all byte
   bounds;
6. discard only candidates that fail a candidate-specific compatibility
   check, retaining the typed reason for each rejected candidate;
7. choose among conforming candidates by the fixed policy order below; and
8. construct one immutable effective result, or the stable primary reason when
   no candidate conforms.

Submission compatibility is the following closed matrix:

| Selected lifetime | Permitted handoff | Required property |
| --- | --- | --- |
| `synchronousBorrow` | `synchronous` only | Producer storage remains valid until the call returns; the consumer retains no borrow |
| `synchronousCopy` | `synchronous` or `queued` | The consumer completes a copy into its own bounded storage before the producer borrow ends |
| `ownershipTransfer` | `synchronous` or `queued` | Ownership of the bounded payload transfers exactly once and is not used again by the producer |

The operation stream itself is always `synchronousBorrowedOneShot`; the table
governs backend-owned derived pixel payload only. It does not authorize a
queued or retained GiftUI operation stream.

Policy selection is deterministic and applies only after conformance:

1. prefer the conforming candidate whose kind equals `preferredRealization`;
2. within that candidate, prefer `preferredEncoding` when it is common;
3. otherwise choose encoding raw-value order (`rgb565BigEndian`, then
   `rgba8888`);
4. choose lifetime raw-value order (`synchronousBorrow`,
   `synchronousCopy`, then `ownershipTransfer`); and
5. choose handoff raw-value order (`synchronous`, then `queued`).

If the preferred realization or encoding is unavailable but another allowed
complete path conforms, selecting that complete path is not semantic
weakening. If at least one technically conforming candidate exists but every
candidate or common encoding is excluded by `allowedRealizations` or
`allowedEncodings`, resolution returns `.policyHasNoConformingRealization`.
If no technically conforming candidate exists, resolution retains its
specific primary reason.

The output MUST be independent of input ordering. Implementations MAY
canonicalize inputs or use role-addressed storage, but ordering cannot be a
tie-breaker. A duplicate, missing, malformed, or exhausted input MUST fail
deterministically and MUST NOT be ignored, partially accepted, or replaced by
the last observed value.

Lack of a common pixel encoding and incompatible submission lifetime MUST each
produce their own stable unavailable reason. Neither may be hidden as
effective-result metadata. All first-party tiled fixtures MUST consume the
borrowed GiftUI operation stream once and MUST NOT retain or replay it after
the synchronous offer returns; only backend-owned derived pixel, tile,
transfer, or device data may remain.

Resolution MUST occur during host composition or bounded initialization, never
during portable view evaluation, per-frame processing, or per-pixel work.
Snapshot access MUST NOT rerun the resolver.

## State / Lifecycle

For one assembled runtime, capability state follows this lifecycle:

1. The host selects an immutable component graph and initializes the selected
   components sufficiently to obtain owned facts.
2. The host constructs the requirement, four role-specific contributions
   (including host resource policy), fixed capacities, caller-owned resolver
   workspace, and result storage.
3. RFC-002 B2 structural validation and capability resolution both complete
   before the first run cycle. Their order may be host-defined, but runtime
   start requires both successes and neither result substitutes for the other.
4. Successful resolution freezes the effective snapshot. Failed resolution
   leaves no partially usable snapshot and prevents runtime start for a
   required family.
5. Approved consumers receive read-only effective values for the runtime
   lifetime.
6. Teardown releases host-owned storage only after all approved consumers are
   torn down. No consumer may outlive or mutate the snapshot.

Re-resolving into an active snapshot, changing contributor facts in place, or
using operational state to rewrite an effective value is illegal. A material
change requires teardown and construction of a new runtime. The exact host
assembly API and startup sequencing across all features belong to the later
HOST-CONFIGURATION Specification.

## Capability Requirements

The MVP catalogue MUST contain exactly `rasterPresentation`; adding a second
family or field requires a separately accepted fixture-backed architectural
change when it is not already entailed by ADR-017 through ADR-020.

Every field MUST map to at least one assertion in a Signal Analyzer or one of
the four supported-configuration fixtures. A field without such evidence MUST
be removed from the MVP catalogue or routed through deferred work.

The normative fixture-to-field map is:

| Field group | Required fixture assertion |
| --- | --- |
| Operation coverage and stream lifetime | All four hosts require the complete Signal Analyzer opaque rectangle, positioned text, straight-line stroke, clipping, and damage vocabulary through ADR-010's one-shot stream |
| Logical and maximum extent | Each host requirement equals its initialized logical surface; Pi proves 240 x 240, and nRF52840 proves 480 x 320 |
| Canonical encodings | Desktop proves `rgba8888`; Pi and nRF52840 prove `rgb565BigEndian`; SPIKE-001's encoding negative/control pair proves the intersection is required |
| Submission lifetime and handoff | Pi and nRF52840 prove synchronous borrow; SPIKE-001's lifetime negative/control pair proves lifetime is an input rather than metadata |
| Realization kind | Desktop proves bounded full surface; Pi and nRF52840 prove bounded tiled presentation; nRF52840 rejects full-surface `rgba8888` |
| Region and row alignment | The Pi 240 x 16 RGB565 tile and nRF52840 480 x 4 RGB565 tile prove bounded region height, complete-row width, and two-byte row alignment |
| Raster and payload bytes | Pi permits a 7,680-byte default tile; nRF52840 permits at most a 3,840-byte tile and no full framebuffer |
| In-flight count and bytes | Synchronous borrowed Pi and nRF52840 submission requires exactly one active derived payload and storage for that payload |
| Required/optional absence | Every claimed Signal Analyzer host uses `required`; an optional negative fixture proves absence remains `nil` in the snapshot rather than becoming support |
| Policy allow/preference fields | Desktop-versus-tiled fixtures prove realization selection, and common-encoding controls prove policy selects only from technically conforming paths |

The macOS dynamic and static fixtures MUST resolve the same semantic coverage,
although their conforming realization and storage mechanisms may differ. The
Raspberry Pi fixture MUST support the 240 x 240 PiScreen case through a bounded
RGB565 tiled realization compatible with its Linux framebuffer path. The
nRF52840 fixture MUST support the 480 x 320 TFT path using no full framebuffer,
with a tile no larger than 480 x 4 x 2 bytes (3,840 bytes) and compatible
synchronous borrowed submission. A full-surface `rgba8888` realization for the
nRF52840 fixture MUST resolve unavailable.

Missing required behavior prevents runtime start. Optional absence, where an
approved consumer permits it, remains an explicit absence and cannot silently
select a semantically weaker path.

## Backend Requirements

No concrete backend is required to run the pure resolver conformance suite.
Backend, render-producer, and surface/display implementations MUST expose
their facts through local adapters that construct only their owned
contribution records. They MUST NOT probe another concrete component or claim
end-to-end support.

All first-party MVP raster paths, including RGB565 tiled paths, MUST accept the
same ADR-010 synchronous borrowed one-shot operation stream. Before the offer
returns, a backend MUST synchronously consume the stream and complete or
reserve all backend-owned derived work. After return it may retain only its
own derived data and the operational state governed outside this
Specification.

Platform and connected-hardware checks are later conformance evidence. They
MUST NOT replace normalized host fixtures, dependency tests, or static
resource/zero-allocation tests for this contract.

## Error Handling

Capability incompatibility is a deterministic initialization validation
failure, not mutable runtime health. SPEC-004 owns the closed capability-domain
unavailable reason. Outside `GiftUICapabilities`, the target-host adapter uses
the exact condition mapping in `Types / APIs` and, for a required family,
returns `GiftUIOutcome<CapabilitySnapshot>.failure`; SPEC-003 owns that
outcome, propagation, containment, policy-disposition, and diagnostic
behavior.

The host validation pipeline MUST fail closed for missing, duplicate,
malformed, out-of-range, incompatible, overflowing, or capacity-exhausted
input. It MUST NOT trap, allocate an
unbounded recovery structure, select a weakened realization, expose a partial
snapshot, or depend on diagnostic delivery.

Validation is staged at constructible API boundaries. Raw host adapters first
map an invalid requirement (lowest field), then a SPEC-002 extent conversion
overflow, then malformed contributions (lowest role, then field). These stages
short-circuit before typed insertion and resolution; their fixtures invoke the
adapter boundary and MUST NOT claim that `resolve` received an unconstructible
value. Among values the typed resolver can actually receive, simultaneous
conditions use this precedence, independent of insertion and candidate order:

1. lowest-raw-value duplicated contributor role;
2. lowest-raw-value missing contributor role;
3. insufficient resolver workspace;
4. producer operation-set mismatch;
5. producer operation-stream mismatch;
6. unsupported logical extent or region/alignment mismatch;
7. candidate operation-set mismatch;
8. candidate operation-stream mismatch;
9. no common canonical pixel encoding;
10. incompatible submission lifetime;
11. incompatible submission handoff;
12. shared raster/payload usage multiplication overflow, assigned to
    `raster`; the earlier row computations are proven representable by their
    typed widths and no payload-only or in-flight arithmetic overflow exists;
13. insufficient raster capacity;
14. insufficient payload capacity;
15. insufficient in-flight capacity; and
16. policy with no conforming realization.

For candidate-specific checks, the resolver evaluates realization kind raw
value order (`fullSurface`, then `tiled`) only to select the primary reason;
candidate declaration order remains irrelevant. Within one capacity domain,
the payload reports the exact required usage and the effective available
ceiling defined by `Byte-bound and region arithmetic`. Additional observations
may
be projected only through SPEC-003-owned bounded secondary/diagnostic
mechanisms and MUST NOT replace or change the primary reason.

Runtime refusal, backpressure, disconnection, transport error, and post-handoff
device failure are operational outcomes. They MUST follow SPEC-003 and their
own governing contracts without mutating the capability snapshot.

## Performance Requirements

- Resolution MUST execute once during bounded initialization and MUST NOT run
  in view evaluation, per-frame, or per-pixel paths.
- Resolver work MUST have a statically derivable finite upper bound from the
  closed family, four contributor roles, encoding/lifetime alternatives, and
  caller-declared capacities. One resolver invocation MUST perform no more
  than 96 counted primitive operations, where a primitive operation is one
  role visit, bit-set intersection/comparison, checked arithmetic operation,
  candidate compatibility check, or validation-result construction. Tests
  MUST report the measured count for success and every negative path.
- Steady-state effective-result access MUST be bounded direct lookup and MUST
  invoke the resolver zero times.
- On the static path, contribution construction, resolution,
  validation-result construction, snapshot storage, and steady-state access
  MUST perform zero heap allocations.
- On supported 32-bit and 64-bit compilers, `RasterPresentationRequirement`
  MUST occupy at most 32 bytes, `RasterRealizationContribution` at most 40
  bytes, `RasterBackendContribution` at most 88 bytes,
  `SurfaceDisplayContribution` at most 40 bytes,
  `RasterPresentationPolicy` at most 32 bytes,
  `RasterPresentationContributions` at most 192 bytes,
  `RasterPresentationResolverWorkspace` at most 96 bytes,
  `EffectiveRasterPresentation` at most 48 bytes,
  `RasterPresentationUnavailable` at most 16 bytes, and
  `CapabilitySnapshot` at most 56 bytes. Size, stride, and alignment MUST be
  recorded for each production compiler configuration.
- nRF52840 evidence MUST report incremental linked RAM, worst-case resolver
  stack, linked flash, initialization work, named capability storage, and
  default display staging separately. Total linked RAM MUST remain at or below
  192 KiB, default display staging at or below 16 KiB, and firmware within the
  1 MiB device flash; crossing the 896 KiB warning threshold requires explicit
  review evidence.
- For the nRF52840 `-Osize` image relative to the baseline defined below,
  capability-specific linked RAM MUST add no more than 768 bytes, named fixed
  capability storage no more than 512 bytes, conservative worst-case resolver
  stack no more than 256 bytes, and linked flash no more than 8 KiB. These
  ceilings provide headroom over SPIKE-002's feasibility measurements of 128,
  80, 72, and 1,104 bytes respectively while remaining small relative to the
  established device limits. Exceeding a capability-specific ceiling requires
  a Specification revision and renewed review; it cannot be waived merely
  because the total device image still fits.

The nRF52840 resource comparison MUST use the repository-pinned Swift 6.3.2
compiler, Zephyr 4.3.0 revision, Zephyr SDK 0.17.4, board
`nrf52840dk/nrf52840`, and hard-float `armv7em-none-none-eabi` configuration in
`scripts/nrf52840/toolchain.env`. Both images MUST use whole-module `-Osize`,
Embedded Swift, function sections, the same Cortex-M4F and VFP ABI flags,
Zephyr configuration, Swift runtime and C library, linker script, section
layout, and linker garbage collection. Evidence MUST record the compiler
executable hash and complete `swiftc --version`, every compiler and linker
argument, repository revision and dirty state, and baseline/candidate source
lists, source hashes, map files, and ELF hashes.

The baseline and candidate are separate pristine firmware fixtures with the
same Swift entry path, fixed-width observable sink, Zephyr bootstrap, and
no-op initialization and steady-state-read call sites. The baseline MUST NOT
import or link `GiftUICapabilities`. The candidate MUST differ only by linking
the production `GiftUICapabilities` objects and observably executing
contribution construction, every resolver success and required negative path,
validation-result construction, snapshot storage, and steady-state access.
Both heaps remain disabled. Measurement-only stack instrumentation MUST use a
separate like-for-like pair and MUST NOT be subtracted from the resource pair.

Linked RAM is the sum of final ELF `PT_LOAD` memory sizes mapped to RAM;
`.data`, `.bss`, no-init storage, and named capability symbols MUST also be
reported separately. Linked flash is the sum of final ELF `PT_LOAD` file
sizes mapped to nonvolatile storage, including executable text and read-only
data; debug, symbol-table, string-table, and other non-loadable sections are
excluded. Capability-specific linked RAM and flash are the signed
`candidate - baseline` deltas and MUST NOT be clamped. Named fixed capability
storage is the sum of the candidate's requirement, contributions, workspace,
validation result, snapshot, and fixed trace/sink symbols absent from the
baseline; display staging is reported separately and is not counted as named
capability storage.

Worst-case resolver stack MUST use conservative disassembly and complete
call-graph summation over every success and negative resolver path. The report
MUST list each function's stack adjustment and saved-register bytes, every
callee edge, the maximum acyclic path sum, and any indirect call. An indirect
call without a finite enumerated target set fails the stack criterion. The
256-byte ceiling applies to the resolver entry-through-return path only; the
complete fixture-driver stack is reported separately. Two pristine rebuilds
MUST produce identical normalized metrics and ELF hashes.

## Compatibility

- Static and dynamic profiles MAY use distinct storage and specialization but
  MUST produce equivalent normalized semantic results, absence behavior, and
  stable reasons.
- Portable Signal Analyzer declarations MUST remain source-compatible and
  substantially shared across all four configurations; they gain no
  target/backend/device branches from this contract.
- `GiftUICapabilities` is not re-exported by `GiftUI`, and no concrete
  contributor type crosses into portable Presentation.
- No serialized capability format, stable ABI, plugin protocol, or migration
  guarantee for legacy proof-of-concept flags is established.
- Existing flags and concrete-type probes are migration evidence only. They
  MUST be classified and replaced at approved boundaries rather than treated
  as compatibility authority.
- Any later change to operation-stream or submission-lifetime meaning requires
  reconciliation with its governing ADRs and this Specification before use.

## Testing Requirements

The contract suite MUST include:

- pure resolver fixtures for macOS dynamic, macOS static, Raspberry Pi
  1/Linux with PiScreen, and nRF52840 with TFT;
- every permutation of the four contributor-role inputs for each positive and
  representative negative fixture, proving equal results independent of
  order;
- missing and duplicate typed-input cases, plus adapter-level malformed,
  out-of-range, and logical-extent-overflow cases, optional absence, required
  absence, and resolver-workspace exhaustion;
- independent negative/control pairs for operation-set mismatch, one-shot
  incompatibility, extent overflow, no common pixel encoding, incompatible
  submission lifetime, insufficient raster/payload storage, and in-flight
  bound violation;
- policy permutations proving policy chooses only among conforming results and
  cannot manufacture support;
- a table-driven resolver precedence corpus that creates every constructible
  pair of simultaneous typed-input incompatibilities and verifies the
  documented primary reason, plus separate raw-adapter tests for every earlier
  short-circuit stage;
- boundary fixtures proving maximum typed LCM, unaligned-row, and aligned-row
  values remain representable without wrapping, plus a constructible usage-
  multiplication overflow fixture returning
  `byteCountOverflow(domain: .raster)` and a fixed-domain proof that no
  payload-only or in-flight arithmetic overflow is constructible;
- the complete submission-lifetime/handoff matrix, including rejection of a
  queued synchronous borrow and proof that a synchronous copy owns its queued
  bytes before the producer borrow ends;
- cross-profile comparison of normalized static and dynamic results;
- dependency-graph tests proving the `GiftUICapabilities` import boundary,
  `GiftUI` non-re-export, and absence of concrete identity in portable code;
- static allocation instrumentation or an allocator-free linked fixture that
  fails any allocation attempt across the complete capability-system path;
- steady-state tests proving snapshot access performs no resolver invocation;
- bounded resource evidence reporting linked RAM, named storage, stack, flash,
  initialization work, and staging independently; and
- one-shot tiled-stream tests proving exact-once synchronous consumption and
  no retained or replayed operation stream after offer return.

Host, cross-build, simulator, and connected-hardware evidence MUST be labeled
separately. A successful build or simulator test is not connected-board
evidence.

## Acceptance Criteria

- [ ] **CR-001:** The document identifies SPEC-004 as `approved` and the
  manifest registers it for `capability-system`; the document directly links
  PROPOSAL-004, RFC-004, RFC-006, ADR-010, and ADR-017 through ADR-020 and
  reciprocally relates SPEC-002 and SPEC-003.
- [ ] **CR-002:** A dependency test proves `GiftUICapabilities` imports none of the
  prohibited higher or concrete modules, `GiftUI` does not re-export it, and a
  portable Signal Analyzer presentation contains zero target/backend/device
  identity checks.
- [ ] **CR-003:** The implemented MVP catalogue contains exactly one family named
  `rasterPresentation`, and every field maps to at least one named assertion
  in the four normalized fixtures.
- [ ] **CR-004:** The public declarations, raw widths, finite cases including
  the validation-only incompatible operation-stream fact, failable
  construction rules, fixed four-role contribution capacity, two-candidate
  workspace capacity, and record-size ceilings match `Types / APIs`.
- [ ] **CR-005:** All 24 permutations of the four contributor roles produce byte-for-byte
  or value-equal effective results for each positive fixture and the same
  stable primary unavailable reason for each representative negative fixture.
- [ ] **CR-006:** Missing, duplicate, adapter-malformed, optional-absence,
  required-absence, and workspace-exhaustion fixtures complete without traps,
  partial snapshots, or order-dependent results; every fifth typed insertion
  reports a duplicate role rather than a distinct capacity outcome.
- [ ] **CR-007:** Every constructible pair in the typed resolver's
  simultaneous-incompatibility corpus returns the primary reason defined by
  the 16-step precedence, independent of role and candidate declaration order;
  raw-adapter fixtures separately cover every pre-resolution validation stage.
- [ ] **CR-008:** No-common-encoding and incompatible-submission-lifetime negative/control
  pairs resolve independently to distinct stable unavailable reasons.
- [ ] **CR-009:** The complete lifetime/handoff matrix passes, and no queued or
  retained GiftUI operation stream is admitted.
- [ ] **CR-010:** The macOS dynamic and static fixtures expose equal semantic coverage;
  the Raspberry Pi 240 x 240 fixture resolves to a bounded RGB565 tiled path;
  the nRF52840 480 x 320 fixture resolves with a tile no larger than 3,840
  bytes; and nRF52840 full-surface `rgba8888` resolves unavailable.
- [ ] **CR-010A:** Formula fixtures cover both encodings, full-surface and
  tiled geometry, unequal alignments, all three capacity minima, zero
  byte-count ceilings, malformed zero structural maximums, maximum typed
  LCM/row boundary values, the constructible shared-usage overflow assigned to
  `.raster`, the fixed-domain proof excluding payload-only/in-flight
  arithmetic overflow, and the exact nRF52840 result of one 3,840-byte
  in-flight payload.
- [ ] **CR-011:** Allocation instrumentation reports zero heap allocations for the static
  path from contribution construction through resolution, validation-result
  construction, snapshot storage, and repeated steady-state access.
- [ ] **CR-012:** Repeated steady-state snapshot access invokes the resolver zero times,
  and every measured success and negative path performs at most 96 counted
  primitive operations.
- [ ] **CR-013:** nRF52840 resource evidence reports incremental and total linked RAM,
  worst-case resolver stack, linked flash, named capability storage, and
  display staging; it satisfies every aggregate and capability-specific budget
  under the fixed baseline/candidate, toolchain, section-accounting, and stack
  method in `Performance Requirements` and records size, stride, and alignment
  for every named capability record.
- [ ] **CR-014:** Every first-party tiled fixture consumes the borrowed operation stream
  exactly once synchronously and retains or replays zero GiftUI operations
  after the offer returns.
- [ ] **CR-015:** Fault-injection tests prove runtime backpressure, refusal,
  disconnection, and post-handoff failure leave the effective snapshot
  unchanged and are expressed only through SPEC-003-owned outcome/failure
  seams.
- [ ] **CR-016:** Structural-validation-negative fixtures fail RFC-002 B2 independently
  of capability resolution, and capability-negative fixtures fail resolution
  independently of an otherwise valid B2 graph; runtime start occurs only
  when both gates succeed.

## Implementation Notes

This section is non-authoritative. A role-addressed fixed record or canonical
sort can make order independence straightforward. Reuse the normalized inputs
from SPIKE-001 and the measurement harness shape from SPIKE-002, but do not
copy their disposable layouts into production by implication.

Keep capability-domain records compact and move human-readable names and
expanded reports to host tooling where possible. Representation reduction is
the first remedy if measurements are too costly, provided all normative
semantics and normalized results remain unchanged.

## Open Issues

Implementation of `T2.2` exposed that the previously single-case
`OperationStreamLifetime` made `.operationStreamMismatch`, its two typed
precedence positions, and the required one-shot incompatibility fixture
unconstructible. The 2026-08-30 correction adds one validation-only negative
fact without admitting another stream mode or changing ADR-010. The maintainer
explicitly reapproved the corrected public vocabulary before `T2.2`
implementation resumed.

The 2026-08-30 arithmetic correction preserves the accepted architecture,
public widths, checked-operation requirement, and failure vocabulary while
limiting overflow fixtures to constructible typed inputs. The maintainer
explicitly reapproved the corrected contract before `T2.1` implementation
resumed.

The remaining capability-domain contract and reciprocal Wave 1 terminology
are closed. SPEC-003 fixes the enclosing required-family carrier and
the one-to-one capability condition catalogue. The approved SPEC-002
extent adapter accepts only valid non-negative `Size` values, maps zero and
positive overflow distinctly, and exposes no capability geometry to portable
Presentation.

The later HOST-CONFIGURATION Specification remains responsible for naming the
assembly API that owns B2 structural validation, capability resolution,
snapshot storage, and the first-cycle gate. This is a downstream ownership
obligation, not a prerequisite for review or approval of SPEC-004's pure
resolver contract; SPEC-004 already fixes that both gates must succeed before
runtime start.

If any issue requires a new capability family, mutable snapshot, new
operation-payload lifetime, target-local resolution, upward import, or changed
failure ownership, SPEC-004 must pause and route that choice through RFC/ADR
review.

## Deferred and Follow-up Work

- [FW-006](../future-work/fw-006-generated-target-configuration.md) preserves
  generated target composition.
- [FW-007](../future-work/fw-007-cost-aware-capability-planning.md) preserves a
  generalized measured realization planner.
- [FW-008](../future-work/fw-008-generalized-component-traits.md) preserves a
  general Trait subsystem.
- [FW-014](../future-work/fw-014-replayable-operation-delivery.md) preserves a
  possible future replayable operation contract.
- [FW-015](../future-work/fw-015-capability-resolver-input-minimization.md)
  preserves later input reduction under explicit compatibility evidence.
- [FW-018](../future-work/fw-018-live-surface-reconfiguration.md) preserves
  live extent/orientation reconfiguration and snapshot replacement.

None of these items changes MVP scope, this contract, or its acceptance
criteria.

## Implementation Records

- [SPEC-004 Implementation Plan](../implementation-plans/spec-004-implementation-plan.md)
- [Checked Raster Arithmetic Implementation Design](../implementation-designs/spec-004-raster-arithmetic.md)

## References

- [PROPOSAL-004: GiftUI Capability System](../proposals/proposal-004-capability-system.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-005: Failure and Diagnostics Propagation Architecture](../rfcs/rfc-005-failure-diagnostics-propagation.md)
- [RFC-006: GiftUI Capability System Architecture](../rfcs/rfc-006-capability-system-architecture.md)
- [ADR-010: Synchronous One-Shot Frame Handoff](../adrs/adr-010-synchronous-one-shot-frame-handoff.md)
- [ADR-017: Capability and Operational-State Decision Planes](../adrs/adr-017-capability-and-operational-state-planes.md)
- [ADR-018: Fixture-Driven Typed Capability Model](../adrs/adr-018-fixture-driven-typed-capabilities.md)
- [ADR-019: Bounded Target-Host Capability Resolution](../adrs/adr-019-bounded-host-capability-resolution.md)
- [ADR-020: Composite Raster Presentation Capability](../adrs/adr-020-raster-presentation-capability.md)
- [SPEC-002: Portable Foundation Specification](spec-002-portable-foundation.md)
- [SPEC-003: Failure Outcomes and Containment](spec-003-failure-outcomes-and-containment.md)
- [GiftUI MVP Specification Portfolio](../roadmap/MVP_SPECIFICATION_PORTFOLIO.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [SPIKE-001: Tiled One-Shot Stream and Capability Compatibility Fixtures](../spikes/spike-001-tiled-one-shot-capability-fixtures.md)
- [SPIKE-002: nRF52840 Capability Path Resource Evidence](../spikes/spike-002-nrf52840-capability-path-resource-evidence.md)
