---
id: SPEC-005
feature: giftui-mvp-architecture
title: Deterministic Text Resource Contract
status: approved
authors:
  - codex
created: 2026-08-25
updated: 2026-08-28
proposal:
  - PROPOSAL-003
related_rfcs:
  - RFC-002
  - RFC-003
  - RFC-004
  - RFC-005
related_adrs:
  - ADR-005
  - ADR-006
  - ADR-008
  - ADR-009
  - ADR-010
  - ADR-021
  - ADR-022
  - ADR-023
related_specs:
  - SPEC-002
  - SPEC-003
  - SPEC-007
  - SPEC-008
  - SPEC-014
  - SPEC-015
related_future_work:
  - FW-001
  - FW-002
  - FW-003
related_explorations: []
related_spikes:
  - SPIKE-005
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPEC-005: Deterministic Text Resource Contract

> **Approval status:** Approved by explicit maintainer authorization. The
> architecture and prerequisite Foundation contract are authoritative, and
> SPIKE-005 supplies the adopted licensed reference package, reproducible
> integrity evidence, and measured static-resource calibration.

## Summary

This Specification defines the exact, bounded text-resource contract shared by
layout, render operations, raster providers, concrete resource packages, host
assembly, and resource-generation tooling. It fixes the identity values,
canonical metrics and character-mapping view, raster-resource view, package
compatibility validation, MVP shaping envelope, resource lifetime, and the
resource-borrowing rules required when ADR-022 positioned-glyph operations
are consumed.

The contract gives all four MVP configurations identical logical glyph
selection and geometry while allowing an exact packaged outline realization
or an exact precompiled monochrome bitmap realization to produce different
raster coverage. It does not define `Text`, layout constraints, render
operation ordering, backend raster algorithms, or host capability policy.

## Scope

This Specification owns:

- the `GiftUITextResources` target/module and its import and visibility rules;
- exact font-resource-set, font-instance, glyph, and raster-realization
  identities;
- immutable package descriptors and integrity facts;
- compatible canonical metrics/mapping and raster-resource view contracts;
- deterministic validation of a concrete package before runtime start;
- the MVP scalar-to-glyph mapping and shaping-resource semantics;
- finite resource-table and payload bounds needed by static compositions;
- synchronous borrowing rules for resources referenced by positioned glyphs;
- deterministic local rejection and exact mapping into SPEC-003 outcomes; and
- hardware-free golden fixtures for identity, geometry, mismatch, malformed
  data, capacities, allocation behavior, and profile equivalence.

The contract applies to macOS dynamic, macOS static, Raspberry Pi 1/Linux
dynamic, and nRF52840/Zephyr static configurations.

## Goals

- Make incompatible metric and raster resources impossible to admit silently.
- Preserve one exact glyph selection and logical geometry result across all
  MVP configurations.
- Permit layout, render core, and raster providers to remain sibling consumers
  of one shared contract owner.
- Permit generated fixed tables and direct synchronous traversal without heap
  allocation on the static path.
- Give later LAYOUT, RENDERING, BACKEND-INTEGRATION, and HOST-CONFIGURATION
  Specifications stable declarations and lifetime terminology.

## Non-goals

- Define public `Text` initializers, dynamic text conveniences, modifiers,
  semantic expansion, layout proposals, line wrapping policy, truncation, or
  alignment.
- Define the complete positioned-glyph render operation, opaque paint, clip
  semantics, operation ordering, sink refusal, or frame disposition. The later
  RENDERING and EXECUTION contracts own those concerns.
- Select a rasterization library, cache, atlas, backend, platform font API,
  display format, antialiasing method, or pixel-quantization policy.
- Require an outline realization on every target or pixel-identical output
  across raster realizations.
- Support complex-script shaping, bidirectional or vertical layout, locale
  segmentation, rich text, variable fonts, color glyphs, editing, selection,
  runtime font discovery, or arbitrary runtime registration.
- Package multiple font sizes, weights, or styles. The MVP uses the one exact
  reference instance required by the Signal Analyzer; additional instances
  require a later contract revision justified by a concrete client need.
- Define a stable ABI, persistent run format, independently versioned font
  package, or general-purpose font-container format.
- Ratify `GiftUIBuiltinFont`, `BuiltinFont8x12`, `TextRun`, or the existing raw
  string render operation. Those are proof-of-concept evidence only.

## Dependencies

### Lifecycle prerequisites

- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
  is accepted.
- [RFC-002](../rfcs/rfc-002-giftui-mvp-layered-architecture.md) and
  [RFC-003](../rfcs/rfc-003-deterministic-text-rendering-architecture.md) are
  approved.
- ADR-021, ADR-022, and ADR-023 are accepted. ADR-005, ADR-006, ADR-008,
  ADR-009, and ADR-010 constrain their layer, profile, package, geometry, and
  borrowing boundaries.
- [SPEC-002](spec-002-portable-foundation.md) is approved and owns
  `GeometryScalar`, `Point`, `Size`, `Rect`, and checked arithmetic.
- The [MVP Scope](../MVP_SCOPE.md) requires text for the substantially shared
  Signal Analyzer presentation on all four configurations. SPEC-001 names the
  concrete title, subtitle, channel, level, status, control, visible-window,
  and error-text uses that make this contract necessary now.

### Coordinating contracts

- SPEC-003 exclusively owns cross-layer outcomes, failure facts,
  containment, disposition, health, and diagnostics. This Specification owns
  only text-resource-local rejection categories and their mandatory adapter
  mappings.
- SPEC-004 owns capability contribution and resolution. A later host contract
  may describe required text-resource availability using that system, but
  capability policy cannot change an exact resource identity or logical
  geometry.
- SPEC-006 is a parallel sibling. It owns declarative expansion and identity;
  neither sibling imports or redefines the other.

### Reference-package evidence

The checked-in SPIKE-005 Inter 4.1 Regular source and its derived
`GiftUI Reference Sans` assets are the adopted reference package for this
contract. The exact source, license, derivation, identity, and measurement
requirements are fixed under Behavior and Performance Requirements. The
existing proof-of-concept bitmap table remains non-authoritative and is not
part of the package.

## Related ADRs

- **ADR-005** keeps text layout above a normalized, streamable render boundary
  and prohibits backends from interpreting semantic text.
- **ADR-006** requires equal glyph selection, geometry, validation, and
  failure meaning across static and dynamic profiles while permitting
  different storage and raster realizations.
- **ADR-008** requires one package with compiler-visible target boundaries and
  keeps `GiftUI` as the sole portable Presentation import.
- **ADR-009** supplies the checked `Int32` geometry used by all metrics and
  positioned glyph values. This Specification introduces no second scalar.
- **ADR-010** bounds every borrowed operation and resource payload by the
  synchronous one-shot offer; no consumer may retain a borrow after return.
- **ADR-021** makes layout the sole authority for resource resolution,
  admitted shaping, glyph selection, measurement, and logical positioning.
- **ADR-022** requires complete explicit positioned glyphs at the render
  boundary and forbids backend reconstruction or retention.
- **ADR-023** requires one immutable resource-set identity to join metrics,
  shaping data, and every exact raster realization and makes
  `GiftUITextResources` their sole contract owner.

## Terminology

**Resource set**
: One immutable compatible unit containing canonical character mapping,
  metrics, admitted shaping facts, and one or more exact raster realizations.

**Resource-set identity**
: The 256-bit SHA-256 digest of the canonical resource manifest defined here.
  Equality means exact compatible resource meaning; it is not a display name.

**Font instance**
: One exact metrics-and-raster instance in a resource set. For MVP an instance
  fixes all size, scale, weight, and style choices at generation time.

**Glyph identity**
: A `UInt16` index interpreted only together with a `FontInstanceID`.

**Canonical metrics view**
: The immutable view used above the render boundary to map admitted Unicode
  scalar values and obtain line and glyph metrics.

**Raster-resource view**
: An immutable catalogue of exact raster-realization descriptors and records,
  plus the payloads linked by the assembled target. Every target sees the same
  catalogue identity, but a constrained target need not link an unselected
  payload.

**Exact raster realization**
: A raster data set generated and integrity-bound to the same resource set and
  instance as the canonical metrics. It may be a monochrome bitmap strike or
  packaged outline payload.

**Available realization**
: A catalogued exact raster realization whose payload bytes are present in the
  concrete target package. Availability does not change the resource-set
  identity. A realization is usable only after assembly validation requires
  and validates that available payload.

**Reference package**
: The licensed concrete package used by contract fixtures and required by all
  four MVP host fixtures. It is evidence, not client API.

**Admitted shaping envelope**
: The bounded MVP mapping of a left-to-right Unicode-scalar sequence to one
  positioned glyph per non-line-break scalar, with no contextual substitution,
  kerning, ligatures, combining, or reordering.

**Borrow**
: Synchronous read-only access whose validity ends when the supplying call or
  closure returns. A borrow is never ownership.

## Public Contract

Portable Presentation continues to use only `import GiftUI`. It MUST NOT name
`FontResourceID`, `FontInstanceID`, `GlyphID`, a resource view, a raster
realization, a package descriptor, or a platform font handle.

`GiftUITextResources` is Framework/Integration SPI within the one GiftUI
package. Its declarations are `package` unless this Specification explicitly
marks a value `public` for cross-product tooling. `GiftUI` MUST NOT import or
re-export `GiftUITextResources`.

The same admitted scalar sequence, exact package, instance, constraints, and
style MUST yield identical glyph IDs, advances, offsets, line metrics, and
logical positions in every MVP configuration. Raster coverage MAY differ;
logical values MUST NOT.

No ambient font lookup, fallback face, platform substitution, or backend
measurement is observable or permitted. Unsupported valid scalars map to the
package's exact replacement glyph as specified under Behavior.

## Module Contract

`GiftUITextResources` MUST be a distinct target named exactly
`GiftUITextResources`. It MUST depend only on `GiftUI`, and only for SPEC-002
portable values and checked geometry. It MUST NOT import layout, render core,
runtime, failure, capability, backend, raster provider, concrete resource,
platform, driver, OS/RTOS, HAL, or hardware modules.

The MVP package MUST NOT expose a standalone `GiftUITextResources` library
product. Package-internal targets backing host, tooling, resource, layout,
render, and raster products depend on the target directly, which preserves its
`package` SPI. Adding an externally consumable text-resource product or public
resource SPI requires a later contract and compatibility review.

The required direct dependency direction is:

```text
GiftUILayout -------------------> GiftUITextResources -> GiftUI
GiftUIRenderCore ---------------> GiftUITextResources -> GiftUI
exact raster providers ---------> GiftUITextResources -> GiftUI
concrete resource packages -----> GiftUITextResources -> GiftUI
target hosts -------------------> selected concrete package and consumers
```

The later owner Specifications may finalize `GiftUILayout` and
`GiftUIRenderCore` products, but they MUST use the identities and views in
this module. They MUST NOT create aliases with different nominal identity,
translation adapters, or duplicated metric/raster compatibility contracts.

Concrete packages own immutable assets and conforming views. A host owns the
selected concrete package from successful assembly validation until the last
runtime, layout, render, raster-provider, and backend consumer has been torn
down. `GiftUITextResources` owns no assets, registry, discovery, cache, layout
engine, rasterizer, or host selection policy.

## Types / APIs

The following logical declarations are normative in name, visibility,
raw-value width, cases, field meaning, and behavior. A static specialization
MAY replace protocol existential storage with concrete generic wiring, but it
MUST preserve the same calls, values, and validation results.

### Exact identities

```swift
package struct TextResourceDigest: Equatable, Hashable, Sendable {
    package let word0: UInt32
    package let word1: UInt32
    package let word2: UInt32
    package let word3: UInt32
    package let word4: UInt32
    package let word5: UInt32
    package let word6: UInt32
    package let word7: UInt32
    package init(
        word0: UInt32,
        word1: UInt32,
        word2: UInt32,
        word3: UInt32,
        word4: UInt32,
        word5: UInt32,
        word6: UInt32,
        word7: UInt32
    )
}

package struct FontResourceID: RawRepresentable, Equatable, Hashable, Sendable {
    package let rawValue: TextResourceDigest
    package init(rawValue: TextResourceDigest)
}

package struct FontInstanceID: Equatable, Hashable, Sendable {
    package let resource: FontResourceID
    package let instanceIndex: UInt16
    package init(resource: FontResourceID, instanceIndex: UInt16)
}

package struct GlyphID: RawRepresentable, Equatable, Hashable, Sendable {
    package let rawValue: UInt16
    package init(rawValue: UInt16)
}

package struct RasterRealizationID:
    RawRepresentable, Equatable, Hashable, Sendable
{
    package let rawValue: UInt16
    package init(rawValue: UInt16)
}
```

No bit pattern is reserved as an absent identity. Absence is represented by
an optional value. A `GlyphID` or `RasterRealizationID` becomes valid only
after range validation against the exact package descriptor. Identity values
MUST NOT contain a pointer, reference, string, existential, closure, or
platform-native handle.

The 32 SHA-256 output bytes map to `TextResourceDigest.word0...word7` in that
order, four bytes per word, with each word decoded big-endian. Re-encoding a
digest emits each word big-endian in the same order. Host endianness and the
in-memory byte representation of the struct MUST NOT affect equality,
hashing, canonical serialization, or fixture output.

### Descriptors and metrics

```swift
package enum TextRasterKind: UInt8, Equatable, Sendable {
    case monochromeBitmap1 = 0
    case packagedOutline = 1
}

package struct FontLineMetrics: Equatable, Sendable {
    package let ascent: GeometryScalar
    package let descent: GeometryScalar
    package let lineGap: GeometryScalar
    package init(
        ascent: GeometryScalar,
        descent: GeometryScalar,
        lineGap: GeometryScalar
    )
}

package struct GlyphMetrics: Equatable, Sendable {
    package let advanceX: GeometryScalar
    package let offsetX: GeometryScalar
    package let offsetY: GeometryScalar
    package let inkSize: Size
    package init(
        advanceX: GeometryScalar,
        offsetX: GeometryScalar,
        offsetY: GeometryScalar,
        inkSize: Size
    )
}

package struct FontInstanceDescriptor: Equatable, Sendable {
    package let id: FontInstanceID
    package let lineMetrics: FontLineMetrics
    package let replacementGlyph: GlyphID
    package let glyphCount: UInt16
    package let mappingCount: UInt16
    package init(
        id: FontInstanceID,
        lineMetrics: FontLineMetrics,
        replacementGlyph: GlyphID,
        glyphCount: UInt16,
        mappingCount: UInt16
    )
}

package struct RasterRealizationDescriptor: Equatable, Sendable {
    package let id: RasterRealizationID
    package let instance: FontInstanceID
    package let kind: TextRasterKind
    package let glyphCount: UInt16
    package let payloadByteCount: UInt32
    package let payloadDigest: TextResourceDigest
    package init(
        id: RasterRealizationID,
        instance: FontInstanceID,
        kind: TextRasterKind,
        glyphCount: UInt16,
        payloadByteCount: UInt32,
        payloadDigest: TextResourceDigest
    )
}

package struct TextResourceDescriptor: Equatable, Sendable {
    package let schemaVersion: UInt16
    package let resource: FontResourceID
    package let instanceCount: UInt16
    package let realizationCount: UInt16
    package let canonicalManifestByteCount: UInt32
    package init(
        schemaVersion: UInt16,
        resource: FontResourceID,
        instanceCount: UInt16,
        realizationCount: UInt16,
        canonicalManifestByteCount: UInt32
    )
}
```

`schemaVersion` MUST equal `1`. An MVP resource contains exactly one font
instance, whose `instanceIndex` is `0`, with `1...256` glyphs and `1...256`
scalar mappings. The resource catalogue contains `1...2` raster realizations.
Realization IDs and glyph IDs MUST be the contiguous ranges beginning at zero
implied by their declared counts, and every realization MUST reference the
sole instance. Each realization contains the same `glyphCount` as that
instance and at most 65,536 payload bytes. The canonical manifest is at most
16,384 bytes. A concrete package MUST make at least one catalogued realization
payload available, but it MAY omit payloads that its target composition does
not select.

`ascent` MUST be positive. `descent` and `lineGap` MUST be non-negative. Their
checked sum MUST be positive and representable. `advanceX` and both ink
dimensions MUST be non-negative. Offsets may be negative. Every checked ink
edge and advance accumulation required by a consumer MUST be representable in
SPEC-002 geometry or the consumer rejects the operation.

Text geometry uses the SPEC-002 coordinate convention with positive x to the
right and positive y downward. A glyph origin is its baseline point.
`ascent` is the positive distance from the baseline to the line box's top,
`descent` is the non-negative distance from the baseline to its bottom, and
the next unconstrained baseline is exactly
`ascent + descent + lineGap` logical units below the current baseline. A
glyph's ink rectangle begins at
`baseline + Point(x: offsetX, y: offsetY)` and has `inkSize`. These meanings
define resource geometry only; the later LAYOUT contract still owns line
origins, wrapping, constraints, and placement.

### Compatible resource views

```swift
package enum GlyphMapping: Equatable, Sendable {
    case exact(GlyphID)
    case replacement(GlyphID)
}

package struct ScalarGlyphMappingRecord: Equatable, Sendable {
    package let scalarValue: UInt32
    package let glyph: GlyphID
    package init(scalarValue: UInt32, glyph: GlyphID)
}

package struct GlyphRasterRecord: Equatable, Sendable {
    package let glyph: GlyphID
    package let offset: UInt32
    package let byteCount: UInt32
    package let rowByteCount: UInt16
    package let pixelWidth: UInt16
    package let pixelHeight: UInt16
    package init(
        glyph: GlyphID,
        offset: UInt32,
        byteCount: UInt32,
        rowByteCount: UInt16,
        pixelWidth: UInt16,
        pixelHeight: UInt16
    )
}

package protocol CanonicalTextMetricsView {
    var descriptor: TextResourceDescriptor { get }
    func instance(at index: UInt16) -> FontInstanceDescriptor?
    func mapping(at index: UInt16, in instance: FontInstanceID)
        -> ScalarGlyphMappingRecord?
    func mapScalar(_ scalarValue: UInt32, in instance: FontInstanceID)
        -> GlyphMapping?
    func metrics(for glyph: GlyphID, in instance: FontInstanceID)
        -> GlyphMetrics?
}

package protocol TextRasterResourceView {
    var descriptor: TextResourceDescriptor { get }
    func realization(at index: UInt16) -> RasterRealizationDescriptor?
    func record(for glyph: GlyphID, realization: RasterRealizationID)
        -> GlyphRasterRecord?
    func isPayloadAvailable(for realization: RasterRealizationID) -> Bool
    func withPayload<Result>(
        for record: GlyphRasterRecord,
        realization: RasterRealizationID,
        _ body: (UnsafeRawBufferPointer) throws -> Result
    ) rethrows -> Result?
}

package struct TextResourcePackage<Metrics, Raster>
where Metrics: CanonicalTextMetricsView, Raster: TextRasterResourceView {
    package let metrics: Metrics
    package let raster: Raster
    package init(metrics: Metrics, raster: Raster)
}
```

Every optional-returning accessor MUST return `nil` for an out-of-range index, mismatched
resource or instance identity, invalid scalar value, invalid glyph, or invalid
realization. It MUST NOT trap, clamp, wrap, substitute another instance, or
perform ambient lookup. A valid Unicode scalar value is `0...0x10_FFFF`
excluding `0xD800...0xDFFF`.

`isPayloadAvailable` returns `false` for an invalid realization and otherwise
reports only whether that exact catalogued payload is linked into the concrete
package. It performs no discovery or fallback. `record` remains available for
every catalogued realization because record metadata participates in the
common resource identity even when that target omits the payload bytes.

Initializers perform no repair; `TextResourceValidator` is the authority that
admits or rejects a complete package. Mapping records MUST be strictly
ascending by scalar value,
contain valid Unicode scalar values other than U+000A and U+000D, contain no
duplicate scalar, and reference a valid glyph in the named instance.

`withPayload` calls `body` exactly once for a valid record in an available
realization and returns its result. The buffer is read-only, has exactly
`record.byteCount` bytes, and is valid only during `body`. It returns `nil`
and does not invoke `body` for invalid input or an unavailable realization.
The implementation MUST NOT allocate merely to produce the borrow. A valid
zero-byte record still invokes `body` exactly once with an empty buffer. The
method never throws for its own validation or availability result; `rethrows`
only preserves an error produced by `body`, and static conformance MUST use a
non-throwing body.

For `.monochromeBitmap1`, bits are row-major, most-significant bit first,
`rowByteCount == ceil(pixelWidth / 8)`, unused low bits in the final byte of a
row are zero, and `byteCount == rowByteCount * pixelHeight` under checked
arithmetic. The glyph's bitmap dimensions MUST equal its canonical
`inkSize`. The payload is coverage only; its record carries no advance or
logical position.

Within each realization, records in ascending `GlyphID` order MUST form a
non-overlapping, gap-free partition of `0..<payloadByteCount`. Validation
hashes the exact record payloads in that order, so a consumer never requires a
second whole-payload borrowing API.

For `.packagedOutline`, bytes are an immutable exact provider payload. The
reference package uses the evidence identifier `giftui-spike-outline-v1`:
each glyph payload begins with a `UInt8` version equal to `1`, a big-endian
`UInt16` units-per-em value, and a big-endian `UInt16` fixed pixel size. It is
followed by zero or more
commands and their operands: `moveTo = 1`, `lineTo = 2`, `qCurveTo = 3`,
`curveTo = 4`, `closePath = 5`, and `endPath = 6`. A point-bearing command
stores a `UInt8` operand count followed by big-endian signed `Int16` x/y pairs;
the implied quadratic point is encoded as the reserved pair
`(0x7FFF, 0x7FFF)`. Close and end commands have no operand-count byte. Every
coordinate MUST be representable as `Int16`, every command and operand count
MUST be structurally complete, and no bytes may remain after the final
command. Every outline record MUST have `rowByteCount == 0`; its
`pixelWidth` and `pixelHeight` MUST equal the canonical `inkSize`. This format
is required only for the outline-capable reference fixture; no MVP
configuration is required to select it or provide a production outline
rasterizer.

### Package validation

```swift
package enum TextResourceValidationError: UInt8, Equatable, Sendable {
    case unsupportedSchema = 0
    case capacityExceeded = 1
    case invalidCount = 2
    case invalidIdentity = 3
    case incompatibleViews = 4
    case malformedMetrics = 5
    case malformedMapping = 6
    case malformedRasterRecord = 7
    case integrityMismatch = 8
}

package enum TextResourceValidationResult: Equatable, Sendable {
    case valid
    case invalid(TextResourceValidationError)
}

package enum TextResourceValidator {
    package static func validate<M, R>(
        _ resourcePackage: borrowing TextResourcePackage<M, R>,
        requiring realization: RasterRealizationID
    ) -> TextResourceValidationResult
    where M: CanonicalTextMetricsView, R: TextRasterResourceView
}
```

Validation MUST be total and deterministic. It MUST evaluate the predicates
below in enum raw-value precedence and return the first applicable error,
independent of table declaration or traversal order:

1. `unsupportedSchema`: either view declares a schema other than `1`;
2. `capacityExceeded`: any declared or reconstructed instance, glyph, mapping,
   realization, manifest-byte, or payload-byte count exceeds its maximum in
   this contract;
3. `invalidCount`: `instanceCount`, `glyphCount`, `mappingCount`,
   `realizationCount`, or the manifest byte count is zero, two views disagree
   on a count, or an accessor cannot enumerate exactly the declared number of
   instances, mappings, metrics, realizations, or records; a zero payload byte
   count remains valid when its records form a valid empty partition;
4. `invalidIdentity`: an instance, glyph, or realization ID is outside or does
   not equal its required contiguous index, an identity references the wrong
   resource or instance, or an identity is duplicated;
5. `incompatibleViews`: the two `TextResourceDescriptor` values are unequal,
   the required realization is not catalogued, its payload is unavailable, or
   metric and raster metadata do not describe the same instances and glyphs,
   or availability claims a payload that cannot be borrowed completely;
6. `malformedMetrics`: line or glyph metrics violate their sign, checked-sum,
   size, replacement-glyph, or representability invariant;
7. `malformedMapping`: a mapping contains an invalid or line-break scalar, is
   not strictly scalar-ascending, is duplicated, references an invalid glyph,
   or otherwise violates the canonical table shape;
8. `malformedRasterRecord`: records overlap, leave a gap, exceed their payload
   range, disagree with glyph order or canonical ink size, violate the bitmap
   encoding, or violate the reference outline encoding; and
9. `integrityMismatch`: reconstructed canonical bytes do not equal the
   declared byte count or resource identity, or any available payload does not
   equal its declared byte count and digest.

Validation MUST validate every catalogued descriptor and record, every metric
and mapping, the reconstructed canonical manifest, and every available payload
before returning `.valid`. The `requiring` argument makes absence of the
target-selected realization an `incompatibleViews` failure; absence of an
unselected payload is valid and does not change `FontResourceID`. Build
tooling MUST make every catalogued payload available and call validation for
each realization. Host assembly MUST call it for the one realization selected
by that immutable composition. There is no partially valid metrics catalogue
or selected realization.

The canonical manifest is a tooling artifact, not a runtime parser format. Its
schema-version-1 byte serialization is exactly the following concatenation;
all multi-byte fields are big-endian, geometry fields are signed `Int32`, and
all other integer fields use the unsigned width named below:

1. the exact UTF-8 bytes `GiftUITextResources/v1`, then `schemaVersion: UInt16`
   and `instanceCount: UInt16`;
2. for each instance in ascending index order: `instanceIndex: UInt16`,
   `ascent: Int32`, `descent: Int32`, `lineGap: Int32`,
   `replacementGlyph: UInt16`, `glyphCount: UInt16`, and
   `mappingCount: UInt16`;
3. for each instance mapping in ascending scalar order:
   `scalarValue: UInt32` and `glyph: UInt16`;
4. for each glyph in ascending ID order: `glyph: UInt16`, followed by
   `advanceX`, `offsetX`, `offsetY`, `inkSize.width`, and `inkSize.height` as
   five signed `Int32` values;
5. `realizationCount: UInt16`, then each realization in ascending ID order as
   `realizationID: UInt16`, `instanceIndex: UInt16`, `kind: UInt8`,
   `glyphCount: UInt16`, `payloadByteCount: UInt32`, and the exact 32 payload-
   digest bytes; and
6. each realization's records in ascending glyph order as `glyph: UInt16`,
   `offset: UInt32`, `byteCount: UInt32`, `rowByteCount: UInt16`,
   `pixelWidth: UInt16`, and `pixelHeight: UInt16`.

Thus signed geometry and every raster record participate in the resource
identity. `FontResourceID` is SHA-256 over those exact canonical-manifest
bytes. `payloadDigest` is SHA-256 over the exact borrowed realization bytes.
Generated Swift tables MUST embed both digests. Build tooling and host
validation MUST reproduce and compare them; there is no filename, timestamp,
locale, platform, table address, raw raster payload, or outline-format display
name directly in the manifest. Payload bytes are bound through their digest.

The canonical manifest is the complete resource-set catalogue and is
identical across target compositions. A target MAY omit unselected payload
bytes and their provider implementation, but it MUST retain the catalogued
descriptor, records, and digest. That omission changes availability, not the
manifest or `FontResourceID`. A target MUST NOT claim or select an omitted
realization.

### Positioned-glyph resource borrowing

This Specification does not declare the positioned-glyph operation, its
fields, traversal API, or capacity. The later RENDERING contract owns those
declarations. Any such operation MUST use the nominal `FontInstanceID` and
`GlyphID` values from this module and may borrow the validated package only
during ADR-010's synchronous one-shot offer.

A raster consumer MUST finish every lookup and nested `withPayload` call
before the render offer returns. It MUST NOT retain a package pointer, payload
pointer, positioned-glyph source, or borrowing operation after return. A
producer that cannot satisfy its RENDERING-declared capacity must reject
before offering partial resource references; its exact capacity and outcome
mapping remain with RENDERING.

## Behavior

### MVP shaping-resource semantics

The resource view admits horizontal left-to-right presentation text. For each
valid non-line-break Unicode scalar, `mapScalar` yields exactly one glyph.
Mappings are context-free and preserve scalar order. There is no ligature,
kerning, combining-mark attachment, normalization, case folding, reordering,
or locale-dependent behavior.

U+000A is a mandatory line-break control and is not a glyph mapping. A
U+000D immediately followed by U+000A is one line break; an isolated U+000D is
also one line break. The later LAYOUT contract owns constraint-based wrapping
and placement, but MUST use these explicit breaks and the exact metrics here.
`mapScalar` returns `nil` for U+000A and U+000D; the sequence consumer MUST
classify those controls before treating `nil` as an invalid lookup.

Every other valid scalar absent from the mapping table returns
`.replacement(instance.replacementGlyph)`. An invalid scalar value returns
`nil`. The replacement glyph is part of the exact package, has ordinary exact
metrics and raster payloads, and is used identically by all profiles. No
fallback face is consulted.

The reference package MUST contain exact mappings for U+0020...U+007E and
U+00B0. This 96-scalar set covers the fixed Signal Analyzer presentation
vocabulary and common bounded diagnostic punctuation. Other valid scalars in
SPEC-001's bounded diagnostic text remain presentationally deterministic
through the replacement glyph; this does not mutate the application string.

### Geometry

Layout applies `offsetX` and `offsetY` to its current checked logical glyph
origin to form the ink-rectangle origin; the rectangle size is `inkSize`.
Successive unwrapped origins advance by `advanceX`. Every add and rectangle
edge uses SPEC-002 checked arithmetic. Layout is the sole owner of line
origins, wrapping, measurement, and final position generation.

Raster providers receive final positions and MUST NOT apply advances,
kerning, fallback, line placement, or resource substitution. A raster
provider MAY produce different antialiasing or coverage for an exact outline
and bitmap realization, but its output dimensions and placement cannot feed
back into layout.

### Validation and assembly

Build tooling MUST validate generated resources before committing them. The
target host MUST validate the selected immutable package during structural
assembly and before the first run cycle. Layout, render, raster, and backend
consumers MUST receive no package reference until validation succeeds.

A host selects exactly one resource package and one available raster
realization for the MVP runtime. Every positioned glyph in one candidate
frame MUST refer to an instance in that validated package. Every raster
payload lookup MUST use the assembly-selected realization; another catalogued
realization is unusable unless it was also linked and validated. Live package
or realization replacement is outside MVP.

### Adopted reference package

The reference package is derived from official Inter 4.1
`extras/ttf/Inter-Regular.ttf`, whose SHA-256 is
`40d692fce188e4471e2b3cba937be967878f631ad3ebbbdcd587687c7ebe0c82`,
under the checked-in SIL Open Font License 1.1. The derivative name is
`GiftUI Reference Sans`, and generated assets MUST use that exact derived
family identity. The source, license, exact pinned tools, and reproduction
command are recorded in SPIKE-005
[`PROVENANCE.json`](../../experiments/spike-005-inter-reference-font/generated/PROVENANCE.json)
and
[`SHA256SUMS`](../../experiments/spike-005-inter-reference-font/evidence/SHA256SUMS).

The adopted package contains one Regular instance at 16 pixels, glyph zero as
both `.notdef` and the replacement glyph, exactly 96 scalar mappings for
U+0020...U+007E and U+00B0, 102 glyphs including five unencoded component
glyphs, one `.monochromeBitmap1` realization, and one reference-fixture
`.packagedOutline` realization. The canonical manifest is exactly 6,218 bytes
with SHA-256 and `FontResourceID`
`bd14de9ff2baaaf464c130d5e2d0554004a4055cc57a8c16a65fe2cc39394910`.
The bitmap payload is 1,911 bytes with SHA-256
`69cf6841d1ecd25079a63f3dcc6866c119cd11ca4c62115185af99781d13af68`;
the outline payload is 13,195 bytes with SHA-256
`3d05ced8a32b17a45569b6650ea4fe88b1f2f0dc93493e79631a628d56df4c5f`.
Any change to these inputs or derived bytes creates a different package and
MUST receive a new `FontResourceID`.

All four host fixtures MUST use that complete catalogue and identity. The
nRF52840 fixture MUST link the generated metrics, records, digests, and bitmap
payload needed to reconstruct or certify the canonical manifest, and MUST omit
the raw outline payload and any outline provider. It need not store a second
copy of the canonical-manifest bytes. An outline-capable fixture MUST link and
validate both payloads. The different linked payload sets MUST preserve the
same `FontResourceID` because the catalogue already binds both exact payload
digests.

## State / Lifecycle

A generated concrete package transitions only through:

```text
generated catalogue and payloads -> build-validated complete package
    -> target payload subset linked -> selected payload assembly-validated
    -> borrowed by runtime -> all consumers torn down -> released with host
```

Failure at either validation step leaves the catalogue and selected payload
inadmissible. Validation does not repair, substitute, truncate, or partially
expose them. An omitted unselected payload is not partial validity: it remains
catalogued but unavailable and cannot be selected or borrowed.

Resource descriptors, metrics, mappings, records, and payload bytes are
immutable for the complete host-owned lifetime. Dynamic caches are derived
backend state and do not modify a package. A cache entry may outlive one
operation only when it owns its derived bytes and exact identity; it MUST NOT
retain a borrowed package pointer or positioned-glyph source.

An operation's resource borrow begins during the synchronous render offer and
ends before that offer returns. A raster
payload borrow is nested within that interval and ends when `withPayload`
returns. No asynchronous, queued-borrow, replay, or retained-run state exists
in this contract.

## Capability Requirements

This Specification introduces no capability family and does not modify
SPEC-004's sole MVP `rasterPresentation` catalogue. Text-resource validation
is structural assembly validation, not capability resolution.

A later host or backend contract MAY require one of the exact raster kinds,
but a capability result MUST NOT select an identity other than the package
validated for layout, claim support for an unavailable realization, weaken an
integrity failure, or change logical metrics. Structural assembly MUST verify
the selected realization's availability before capability resolution can
claim a conforming raster path. Runtime loss after successful assembly is an
operational failure and does not mutate a capability snapshot.

## Backend Requirements

Backends and raster providers MUST:

- consume exact `FontInstanceID`, `GlyphID`, and explicit `Point` values;
- obtain payloads only from the matching validated raster view;
- finish consuming borrowed positioned glyphs and payloads synchronously;
- apply clip and paint behavior supplied by the later render operation;
- avoid raw-string layout, platform fallback, position reconstruction, and
  identity translation; and
- keep cache state and raster measurements from influencing logical geometry.

Framebuffer, RGB565, simulator, platform, and connected-display behavior are
downstream integration evidence. No backend or hardware is needed for the
independent contract suite.

## Error Handling

Resource-view accessors report invalid identity, range, or record input as
`nil`; validation returns `TextResourceValidationResult`. These local forms
are not cross-layer outcome, containment, health, or diagnostic vocabularies.
They produce no partial value and do not trap.

`GiftUIFailureOrigin` intentionally has no text-resource case. In alignment
with SPEC-003's detecting-owner seam, `GiftUITextResources` returns only its
local validation result or `nil`; it never constructs `GiftUIFailureFact` or
imports failure vocabulary. The first owner adapter that knows both contracts
MUST perform the exact mapping below:

| Detecting owner adapter | Local condition | Condition | Origin | Scope | Containment |
| --- | --- | --- | --- | --- | --- |
| Target host's text-resource assembly adapter | `unsupportedSchema`, `invalidCount`, `malformedMetrics`, `malformedMapping`, or `malformedRasterRecord` returned while admitting the selected package | `invalidValue` | `hostComposition` | `runtime` | `contained` |
| Target host's text-resource assembly adapter | `invalidIdentity`, `incompatibleViews`, or `integrityMismatch` returned while admitting the selected package | `invalidIdentity` | `hostComposition` | `runtime` | `contained` |
| Target host's text-resource assembly adapter | `capacityExceeded` returned while admitting the selected package | `capacityExhausted` | `hostComposition` | `runtime` | `contained` |
| Layout's validated-resource adapter | A lookup in the already validated package unexpectedly returns `nil` during candidate-frame construction | `invariantViolation` | `layout` | `candidateFrame` | `safetyNotProven` |
| Render core's validated-resource adapter | A lookup in the already validated package unexpectedly returns `nil` during candidate-frame construction | `invariantViolation` | `rendering` | `candidateFrame` | `safetyNotProven` |
| Layout's Foundation adapter | SPEC-002 `GeometryArithmetic` returns `nil` while calculating text metric, ink, advance, or positioned geometry | `arithmeticOverflow` | `foundation` | `operation` | `contained` |
| Render core's exact-raster adapter | A required exact raster realization becomes unavailable after otherwise valid assembly | `requiredFacilityUnavailable` | `rendering` | `runtime` | `contained` |

The target-host adapter is the truthful `hostComposition` producer because it
owns structural admission of the selected package before runtime start. The
shared resource module only computes a pure local validation result. After
successful admission, layout and rendering are truthful producers for failures
inside their respective consuming operations; neither may relabel an
assembly-time validation rejection.

U+000A and U+000D intentionally produce no glyph mapping, and invalid caller
input is rejected before validated lookup. Those expected `nil` results MUST
NOT be mapped as invariant failures. The Foundation arithmetic row exactly
preserves SPEC-002's required first-boundary fact; a later execution adapter
MAY correlate that unchanged fact with its candidate frame but MUST NOT
replace `.foundation` with `.layout` or widen `.operation` inside the fact.

The adapter encloses the fact in `GiftUIOutcome` as specified by SPEC-003.
Policy disposition, retry, runtime health, diagnostics, wake behavior, and
failed-frame rescheduling remain outside this contract. Diagnostic delivery
failure MUST NOT change resource validation or lookup behavior.

The independent contract suite MUST fixture every row against the named owner
adapter and prove that the adapter imports `GiftUIFailureCore` while
`GiftUITextResources` does not. No SPEC-003 origin extension is required by
this contract.

## Performance Requirements

- Static package validation, scalar mapping, metric lookup, raster-record
  lookup, payload borrowing, and positioned-glyph resource lookup MUST allocate zero
  heap bytes and require no reflection, runtime discovery, Objective-C,
  `Task`, `MainActor`, unrestricted existential storage, or desktop
  concurrency.
- Lookup work MUST be bounded by 256 mapping or glyph records and two raster
  realizations. Generated direct tables MAY provide constant lookup; a linear
  implementation MUST perform no more than 256 record comparisons per lookup.
- Full validation MUST visit each declared record and each available payload
  byte at most once per digest pass and MUST execute only during build
  validation or host assembly, never per frame or per glyph. Build validation
  visits every catalogued payload; a target host visits only payloads linked
  by that target and requires its selected one.
- `TextResourceDigest` and `FontResourceID` MUST each occupy 32 bytes,
  `GlyphID` and
  `RasterRealizationID` 2 bytes each, `FontInstanceID` at most 36 bytes,
  `FontLineMetrics` at most 12 bytes, `GlyphMetrics` at most 24 bytes, and each
  descriptor or raster record at most 80 bytes on every supported compiler.
- Every MVP package MUST contain exactly one instance, at most 256 glyphs, at
  most 256 mappings, at most two realizations, 65,536 payload bytes per
  realization, and 16,384 canonical-manifest bytes.
- The reference nRF52840 composition MUST use a precompiled
  `.monochromeBitmap1` realization and MUST NOT link the reference outline
  payload or an outline provider. Text-resource-specific linked flash,
  fixed RAM, worst-case validation stack, and per-frame text workspace MUST be
  measured separately. The adopted SPIKE-005 hardware-free fixture measured
  9,224 bytes of incremental linked flash, zero incremental fixed writable
  RAM, and a conservative 568-byte validation call-chain stack. The contract
  ceilings remain 96 KiB linked flash, 512 bytes fixed writable RAM, and 1 KiB
  worst-case validation stack so later Swift implementation and type overhead
  remain bounded; the later LAYOUT and RENDERING contracts own text and
  operation workspace ceilings.
- Representative and maximum admitted Signal Analyzer text processing and
  raster consumption MUST fit inside the established 250-millisecond
  presentation interval while capture continues. Evidence MUST report layout,
  raster, cache, and transfer time separately; this Specification claims only
  resource lookup and borrow measurements.

Resource evidence MUST use the compiler/toolchain identities fixed by
SPEC-002. A checked-in driver `scripts/contracts/run-spec-005.sh` MUST expose:

```text
scripts/contracts/run-spec-005.sh --profile macos-dynamic
scripts/contracts/run-spec-005.sh --profile macos-static
scripts/contracts/run-spec-005.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-005.sh --profile nrf52840-embedded
```

Each run records compiler identity, target, flags, repository revision and
dirty state, generated-manifest hash, source-resource hash, generated-table
hash, linked section sizes, owned-value size/stride/alignment, allocation
count, maximum lookup comparisons, validation stack method, selected and
available realization IDs, and symbol/section evidence that target-omitted
payloads and providers are not linked. Cross-build evidence is not
connected-hardware evidence.

## Compatibility

- Static and dynamic profiles MAY use generated or allocation-backed storage,
  but MUST expose equal identities, validation results, mappings, metrics,
  catalogued resource lookups, and failures for equal inputs. Payload
  availability MAY differ only according to the immutable target composition.
- All four MVP configurations MUST use one compatible reference resource-set
  identity and catalogue for the shared Signal Analyzer fixtures. They MAY
  link and select different raster realizations under that identity; absence
  of an unselected payload MUST NOT change logical results or identity.
- Portable Presentation gains no resource, backend, platform, or device
  imports or conditional branches.
- The proof-of-concept 8x12 metrics, lowercase folding, fallback behavior,
  raw-string operation, and font target create no compatibility presumption.
- This contract establishes no ABI, serialized run compatibility, stable
  digest across a changed resource, or runtime package-registration API.
- Changing canonical metrics, mappings, replacement glyph, raster payloads,
  or integrity metadata creates a new `FontResourceID`; it MUST NOT reuse the
  preceding identity.

## Testing Requirements

The independent contract suite MUST include:

- canonical-manifest golden vectors proving stable SHA-256 resource and
  payload identities across host and cross-built tooling;
- a one-realization package, the complete reference catalogue with both
  payloads available, and target packages that retain that catalogue while
  making only the bitmap or only the outline payload available;
- one isolated fixture for every validation error and a pairwise corpus
  proving the exact error predicates and raw-value precedence are independent
  of table declaration and traversal order;
- every boundary count: zero, one, maximum, and maximum plus one for instances,
  mappings, glyphs, realizations, manifest bytes, and payload bytes;
- every scalar boundary, surrogate, U+000A, U+000D, CRLF, ASCII printable
  scalar, U+00B0, and unsupported valid scalar;
- golden line and glyph metrics, mapping results, advances, ink rectangles,
  and checked-overflow cases;
- mismatched metric/raster resource, instance, glyph, realization, descriptor,
  payload range, payload digest, and manifest digest fixtures;
- bitmap bit order, padding bits, row width, dimensions, and byte-count tests;
- `withPayload` tests proving exactly-once invocation for valid input, zero
  invocation for invalid or unavailable input, exact buffer count, and no
  retained borrow;
- a contract-local test-only synchronous-offer adapter carrying only the
  nominal instance and glyph identities needed to prove that resource lookup
  occurs during the offer and no package or payload borrow survives return;
  this fixture MUST NOT define the production positioned-glyph operation,
  paint, clip, capacity, or ordering owned by the later RENDERING contract;
- cross-profile value equality for all normalized results and rejection maps;
- dependency tests proving `GiftUITextResources` imports only `GiftUI`,
  `GiftUI` does not re-export it, no standalone text-resource product is
  exposed, every consumer uses its nominal identities, and no concrete
  resource target is imported upward;
- static allocation traps covering validation, mapping, lookup, payload
  borrowing, and positioned-glyph resource lookup; and
- licensed-resource evidence tying source, license, derivation command,
  canonical manifest, generated tables, and all digests together.

Backend pixel tests and connected Raspberry Pi or nRF52840 checks are later
conformance evidence and MUST be labeled separately.

## Acceptance Criteria

- [ ] **TR-001:** The document registers SPEC-005 as `approved`, the manifest
  registers it under `giftui-mvp-architecture`, and traceability links
  PROPOSAL-003, all four related approved RFCs, all eight accepted ADRs,
  approved SPEC-002/SPEC-003, SPIKE-005, and the three text Future Work items
  without treating non-authoritative evidence as a decision.
- [ ] **TR-002:** Dependency fixtures prove the exact module graph and show
  zero parallel or translated resource, instance, glyph, or realization
  identity types in layout, render, raster, backend, platform, and concrete
  package boundaries.
- [ ] **TR-003:** Identity declarations, widths, digest word/byte order,
  contiguous-index rules, descriptors, count limits, canonical serialization,
  SHA-256 inputs, and identity-change rule match `Types / APIs`, with identical
  golden digests in all four profile fixtures.
- [ ] **TR-004:** The checked-in reference package has reviewed source and
  derived-asset licensing, maps U+0020...U+007E and U+00B0 exactly, contains a
  replacement glyph, passes complete build validation, and is assembly-valid
  when each target requires its selected available payload.
- [ ] **TR-005:** Every scalar and explicit-line-break fixture produces the
  exact mapping behavior in this contract; unsupported valid scalars use only
  the package replacement glyph and no ambient fallback.
- [ ] **TR-006:** Golden fixtures prove equal line metrics, glyph metrics,
  glyph selection, advances, ink geometry, and explicit positioned points in
  macOS dynamic, macOS static, ARMv6, and nRF52840 builds.
- [ ] **TR-007:** Every malformed, mismatched, unavailable-selected,
  unsupported-schema, integrity, overflow, and capacity fixture returns the
  exact deterministic local result and SPEC-002/SPEC-003 mapping without trap,
  partial selected realization, substitution, or diagnostic dependence.
- [ ] **TR-008:** Bitmap-only-linked and outline-capable target fixtures retain
  one exact catalogue and resource identity; each rejects selection of an
  unavailable payload, and raster coverage changes no metric, selection,
  advance, line, or position.
- [ ] **TR-009:** Payload and contract-local offer lifetime instrumentation
  proves exact-once synchronous traversal and zero retained pointers, sources,
  test operations, or borrowed bytes after their supplying call returns,
  without requiring the later RENDERING contract.
- [ ] **TR-010:** All static-path operations allocate zero heap bytes, every
  type meets its layout ceiling, every table/payload meets its finite count,
  and the nRF52840 bitmap-only-linked reference composition omits outline bytes
  and meets the flash, fixed-RAM, and stack ceilings under the recorded
  SPEC-002 toolchain configuration.
- [ ] **TR-011:** The four exact contract-driver commands reproduce hashes,
  validation results, canonical geometry values, allocation evidence, linked
  payload availability/omission evidence, and resource measurements from a
  clean checkout; cross-build results make no hardware claim.
- [ ] **TR-012:** Review finds no public `Text` semantics, layout constraint or
  wrapping policy, render-operation order, backend raster algorithm, cache
  policy, capability family, host product policy, or deferred typography
  feature introduced by this Specification.
- [ ] **TR-013:** Baseline, ascent/descent, line-gap, ink-rectangle, explicit
  line-break, unavailable-payload, and post-validation lookup fixtures prove
  that an implementer needs no unstated geometry, availability, or failure
  rule and that SPEC-002 facts are preserved unchanged when correlated later.

## Implementation Notes

This section is non-authoritative. Generated sorted arrays or switch tables
can satisfy the accessors without existential storage on Embedded Swift. A
host implementation can perform digest validation in build tooling and retain
a generated validation certificate, but the assembly fixture must still prove
that the embedded descriptors and digests match the certified package.

The existing 5x7-in-8x12 bitmap code remains useful only for historical cost
comparison. It is not the adopted reference package and creates no migration
or compatibility requirement.

## Open Issues

None. Review resolved target-specific payload availability under the common
resource identity, validation precedence, digest byte order, baseline geometry,
and the exact SPEC-002/SPEC-003 detecting-owner alignment.

## Deferred and Follow-up Work

- [SPIKE-005](../spikes/spike-005-inter-reference-font-resource.md) preserves
  the licensed Inter 4.1 source, derived reference assets, integrity evidence,
  and hardware-free resource measurements adopted as the reference-package
  evidence for this contract. Its generator and firmware fixtures remain
  disposable evidence and do not authorize production implementation.

- [FW-001](../future-work/fw-001-international-and-rich-text-layout.md)
  preserves complex scripts, bidirectional/vertical layout, rich text,
  variable fonts, color glyphs, and locale-aware shaping.
- [FW-002](../future-work/fw-002-text-interaction-and-accessibility-geometry.md)
  preserves selection, editing, carets, text hit testing, and accessibility
  geometry.
- [FW-003](../future-work/fw-003-advanced-font-delivery-and-glyph-rasterization.md)
  preserves additional packaged instances, runtime registration, resampling,
  distance fields, compression, generalized outline delivery, and shared
  caches.

These items are optional to this contract and do not change MVP scope or its
acceptance criteria.

## References

- [PROPOSAL-003: GiftUI MVP Architecture Establishment](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [RFC-002: GiftUI MVP Layered Architecture](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-003: Deterministic Text Rendering Architecture](../rfcs/rfc-003-deterministic-text-rendering-architecture.md)
- [RFC-004: Run Cycle and Frame Transaction Architecture](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-005: Failure and Diagnostics Propagation Architecture](../rfcs/rfc-005-failure-diagnostics-propagation.md)
- [ADR-005: Semantic, Layout, and Render Boundary](../adrs/adr-005-semantic-layout-render-boundary.md)
- [ADR-006: Shared Semantics Across Runtime Profiles](../adrs/adr-006-shared-semantics-runtime-profiles.md)
- [ADR-008: Module Dependency Graph and MVP Package Topology](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
- [ADR-009: Checked Integer Geometry for MVP](../adrs/adr-009-checked-integer-geometry.md)
- [ADR-010: Synchronous One-Shot Frame Handoff](../adrs/adr-010-synchronous-one-shot-frame-handoff.md)
- [ADR-021: Canonical Text Geometry Ownership](../adrs/adr-021-canonical-text-geometry.md)
- [ADR-022: Positioned-Glyph Render Operation](../adrs/adr-022-positioned-glyph-render-operation.md)
- [ADR-023: Exact Font Resource Identity and Ownership](../adrs/adr-023-exact-font-resource-identity.md)
- [SPEC-001: Signal Analyzer Reference Application](spec-001-signal-analyzer-reference-application.md)
- [SPEC-002: Portable Foundation](spec-002-portable-foundation.md)
- [SPEC-003: Failure Outcomes and Containment](spec-003-failure-outcomes-and-containment.md)
- [SPEC-004: Capability Contribution and Resolution](spec-004-capability-contribution-and-resolution.md)
- [GiftUI MVP Specification Portfolio](../roadmap/MVP_SPECIFICATION_PORTFOLIO.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [`Package.swift`](../../Package.swift) and existing text/font sources and tests — proof-of-concept evidence only
