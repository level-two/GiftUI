---
id: SPEC-005
feature: giftui-mvp-architecture
title: Deterministic Text Resource Contract
status: draft
authors:
  - codex
created: 2026-08-25
updated: 2026-08-25
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

> **Draft gate:** The architecture and prerequisite Foundation contract are
> authoritative, but this Specification does not authorize implementation.
> Approval is blocked until the licensed reference resource and its generated
> integrity evidence are checked in and the SPEC-003 failure-origin ownership
> proof described under Open Issues is resolved.

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

### Approval evidence prerequisite

A complete reference package MUST be checked in before this Specification can
advance to `review`. Its source and every derived asset MUST have recorded
redistribution and derivation permission. The current proof-of-concept bitmap
table does not satisfy this prerequisite because no provenance or compatible
license record is presently linked to it.

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
: An immutable view used by an exact raster provider to borrow the payload for
  a selected glyph and raster realization.

**Exact raster realization**
: A raster data set generated and integrity-bound to the same resource set and
  instance as the canonical metrics. It may be a monochrome bitmap strike or
  packaged outline payload.

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
}

package struct FontResourceID: RawRepresentable, Equatable, Hashable, Sendable {
    package let rawValue: TextResourceDigest
    package init(rawValue: TextResourceDigest)
}

package struct FontInstanceID: Equatable, Hashable, Sendable {
    package let resource: FontResourceID
    package let instanceIndex: UInt16
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
}

package struct GlyphMetrics: Equatable, Sendable {
    package let advanceX: GeometryScalar
    package let offsetX: GeometryScalar
    package let offsetY: GeometryScalar
    package let inkSize: Size
}

package struct FontInstanceDescriptor: Equatable, Sendable {
    package let id: FontInstanceID
    package let lineMetrics: FontLineMetrics
    package let replacementGlyph: GlyphID
    package let glyphCount: UInt16
    package let mappingCount: UInt16
}

package struct RasterRealizationDescriptor: Equatable, Sendable {
    package let id: RasterRealizationID
    package let instance: FontInstanceID
    package let kind: TextRasterKind
    package let glyphCount: UInt16
    package let payloadByteCount: UInt32
    package let payloadDigest: TextResourceDigest
}

package struct TextResourceDescriptor: Equatable, Sendable {
    package let schemaVersion: UInt16
    package let resource: FontResourceID
    package let instanceCount: UInt16
    package let realizationCount: UInt16
    package let canonicalManifestByteCount: UInt32
}
```

`schemaVersion` MUST equal `1`. A valid resource contains `1...4` instances,
each instance contains `1...256` glyphs and `1...256` scalar mappings, and the
package contains `1...2` raster realizations. Each realization contains the
same `glyphCount` as its referenced instance and at most 65,536 payload bytes.
The canonical manifest is at most 16,384 bytes.

`ascent` MUST be positive. `descent` and `lineGap` MUST be non-negative. Their
checked sum MUST be positive and representable. `advanceX` and both ink
dimensions MUST be non-negative. Offsets may be negative. Every checked ink
edge and advance accumulation required by a consumer MUST be representable in
SPEC-002 geometry or the consumer rejects the operation.

### Compatible resource views

```swift
package enum GlyphMapping: Equatable, Sendable {
    case exact(GlyphID)
    case replacement(GlyphID)
}

package struct ScalarGlyphMappingRecord: Equatable, Sendable {
    package let scalarValue: UInt32
    package let glyph: GlyphID
}

package struct GlyphRasterRecord: Equatable, Sendable {
    package let glyph: GlyphID
    package let offset: UInt32
    package let byteCount: UInt32
    package let rowByteCount: UInt16
    package let pixelWidth: UInt16
    package let pixelHeight: UInt16
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
}
```

Every indexed accessor MUST return `nil` for an out-of-range index, mismatched
resource or instance identity, invalid scalar value, invalid glyph, or invalid
realization. It MUST NOT trap, clamp, wrap, substitute another instance, or
perform ambient lookup. A valid Unicode scalar value is `0...0x10_FFFF`
excluding `0xD800...0xDFFF`.

Every record struct in this section MUST provide a `package` initializer whose
parameter labels and order match its stored properties. Initializers perform
no repair; `TextResourceValidator` is the authority that admits or rejects a
complete package. Mapping records MUST be strictly ascending by scalar value,
contain valid Unicode scalar values other than U+000A and U+000D, contain no
duplicate scalar, and reference a valid glyph in the named instance.

`withPayload` calls `body` exactly once for a valid record and realization and
returns its result. The buffer is read-only, has exactly `record.byteCount`
bytes, and is valid only during `body`. It returns `nil` and does not invoke
`body` for invalid input. The implementation MUST NOT allocate merely to
produce the borrow.

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

For `.packagedOutline`, bytes are an immutable exact provider payload. This
Specification fixes only its digest, bounds, and borrowing contract; the
provider and concrete package Specification MUST name and validate the format
before that realization is used. No MVP configuration is required to select
an outline realization.

### Package validation

```swift
package enum TextResourceValidationError: UInt8, Equatable, Sendable {
    case unsupportedSchema = 0
    case invalidCount = 1
    case invalidIdentity = 2
    case incompatibleViews = 3
    case malformedMetrics = 4
    case malformedMapping = 5
    case malformedRasterRecord = 6
    case integrityMismatch = 7
    case capacityExceeded = 8
}

package enum TextResourceValidationResult: Equatable, Sendable {
    case valid
    case invalid(TextResourceValidationError)
}

package enum TextResourceValidator {
    package static func validate<M, R>(
        _ resourcePackage: borrowing TextResourcePackage<M, R>
    ) -> TextResourceValidationResult
    where M: CanonicalTextMetricsView, R: TextRasterResourceView
}
```

Validation MUST be total and deterministic. It MUST evaluate in enum raw-value
precedence and return the first applicable error. It MUST validate every
declared instance, mapping, glyph metric, realization, raster record, payload
range, payload digest, and cross-view identity before returning `.valid`.
There is no partially valid package.

The canonical manifest is a tooling artifact, not a runtime parser format. It
uses schema version 1; fixed-width unsigned integers encoded big-endian;
instances, scalar mappings, glyphs, and realizations in ascending raw-value
order; and raw raster bytes in realization order. `FontResourceID` is SHA-256
over the version tag `GiftUITextResources/v1`, all canonical metrics and
mapping records, all realization descriptors, and each realization payload
digest. `payloadDigest` is SHA-256 over the exact borrowed realization bytes.
Generated Swift tables MUST embed both digests. Build tooling and host
validation MUST reproduce and compare them; there is no filename, timestamp,
locale, platform, or table-address input to identity.

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

A host selects exactly one resource package for the MVP runtime. Every
positioned glyph in one candidate frame MUST refer to an instance in that
validated package. Live package replacement is outside MVP.

## State / Lifecycle

A generated concrete package transitions only through:

```text
generated -> build-validated -> assembly-validated -> borrowed by runtime
          -> all consumers torn down -> released with host
```

Failure at either validation step leaves the package inadmissible. Validation
does not repair, substitute, truncate, or partially expose it.

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
validated for layout, claim support for a missing realization, weaken an
integrity failure, or change logical metrics. Runtime loss after successful
assembly is an operational failure and does not mutate a capability snapshot.

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

`GiftUIFailureOrigin` intentionally has no text-resource case. A rejection is
therefore mapped only by the existing owner that detects it in context, never
by relabeling `GiftUITextResources` itself as another layer. Subject to the
ownership proof required under Open Issues, the first assembly or consumer
boundary that reports a rejection outside `GiftUITextResources` MUST map it
to SPEC-003 exactly:

| Local condition | Condition | Origin | Scope | Containment |
| --- | --- | --- | --- | --- |
| `unsupportedSchema`, `invalidCount`, `malformedMetrics`, `malformedMapping`, or `malformedRasterRecord` | `invalidValue` | `hostComposition` | `runtime` | `contained` |
| `invalidIdentity`, `incompatibleViews`, or `integrityMismatch` | `invalidIdentity` | `hostComposition` | `runtime` | `contained` |
| `capacityExceeded` | `capacityExhausted` | `hostComposition` | `runtime` | `contained` |
| Validated-package lookup unexpectedly returns `nil` | `invariantViolation` | owning consumer (`layout` or `rendering`) | `candidateFrame` | `safetyNotProven` |
| Checked metric or positioned-geometry arithmetic overflows | `arithmeticOverflow` | `layout` | `candidateFrame` | `contained` |
| Required exact raster realization is unavailable after otherwise valid assembly | `requiredFacilityUnavailable` | `rendering` | `runtime` | `contained` |

The adapter encloses the fact in `GiftUIOutcome` as specified by SPEC-003.
Policy disposition, retry, runtime health, diagnostics, wake behavior, and
failed-frame rescheduling remain outside this contract. Diagnostic delivery
failure MUST NOT change resource validation or lookup behavior.

Before this Specification can advance to `review`, each row MUST have a
fixture naming the concrete detecting adapter and proving that its existing
SPEC-003 origin is truthful. If package validation must originate inside the
shared resource module or no existing owner can report a row truthfully,
SPEC-005 MUST NOT invent an origin or silently mislabel it; SPEC-003 must be
revised and re-approved first.

## Performance Requirements

- Static package validation, scalar mapping, metric lookup, raster-record
  lookup, payload borrowing, and positioned-glyph resource lookup MUST allocate zero
  heap bytes and require no reflection, runtime discovery, Objective-C,
  `Task`, `MainActor`, unrestricted existential storage, or desktop
  concurrency.
- Lookup work MUST be bounded by 256 mapping or glyph records and two raster
  realizations. Generated direct tables MAY provide constant lookup; a linear
  implementation MUST perform no more than 256 record comparisons per lookup.
- Full validation MUST visit each declared record and payload byte at most
  once per digest pass and MUST execute only during build validation or host
  assembly, never per frame or per glyph.
- `TextResourceDigest` and `FontResourceID` MUST each occupy 32 bytes,
  `GlyphID` and
  `RasterRealizationID` 2 bytes each, `FontInstanceID` at most 36 bytes,
  `FontLineMetrics` at most 12 bytes, `GlyphMetrics` at most 24 bytes, and each
  descriptor or raster record at most 80 bytes on every supported compiler.
- The complete reference package MUST contain at most four instances, 256
  glyphs per instance, 256 mappings per instance, two realizations, 65,536
  payload bytes per realization, and 16,384 canonical-manifest bytes.
- The reference nRF52840 composition MUST use a precompiled
  `.monochromeBitmap1` realization. Text-resource-specific linked flash,
  fixed RAM, worst-case validation stack, and per-frame text workspace MUST be
  measured separately. This draft fixes ceilings of 96 KiB linked flash,
  512 bytes fixed writable RAM, and 1 KiB worst-case validation stack; the
  later LAYOUT and RENDERING contracts own text and operation workspace
  ceilings.
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
count, maximum lookup comparisons, and validation stack method. Cross-build
evidence is not connected-hardware evidence.

## Compatibility

- Static and dynamic profiles MAY use generated or allocation-backed storage,
  but MUST expose equal identities, validation results, mappings, metrics,
  resource lookups, and failures.
- All four MVP configurations MUST use one compatible reference resource-set
  identity for the shared Signal Analyzer fixtures. They MAY select different
  raster realizations under that identity.
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
- valid packages with bitmap-only and bitmap-plus-outline descriptors;
- one isolated fixture for every validation error and a pairwise corpus
  proving raw-value precedence is independent of table declaration order;
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
  invocation for invalid input, exact buffer count, and no retained borrow;
- a minimal recording-operation adapter fixture supplied by the later
  RENDERING contract proving nominal identities resolve only during the offer
  and no package or payload borrow survives return;
- cross-profile value equality for all normalized results and rejection maps;
- dependency tests proving `GiftUITextResources` imports only `GiftUI`,
  `GiftUI` does not re-export it, every consumer uses its nominal identities,
  and no concrete resource target is imported upward;
- static allocation traps covering validation, mapping, lookup, payload
  borrowing, and positioned-glyph resource lookup; and
- licensed-resource evidence tying source, license, derivation command,
  canonical manifest, generated tables, and all digests together.

Backend pixel tests and connected Raspberry Pi or nRF52840 checks are later
conformance evidence and MUST be labeled separately.

## Acceptance Criteria

- [ ] **TR-001:** The document and manifest register SPEC-005 as `draft`, link
  PROPOSAL-003, RFC-002/003, ADR-021/022/023, approved SPEC-002, and the three
  text Future Work items without treating any non-authoritative artifact as a
  decision.
- [ ] **TR-002:** Dependency fixtures prove the exact module graph and show
  zero parallel or translated resource, instance, glyph, or realization
  identity types in layout, render, raster, backend, platform, and concrete
  package boundaries.
- [ ] **TR-003:** Identity declarations, widths, descriptors, count limits,
  canonical serialization, SHA-256 inputs, and identity-change rule match
  `Types / APIs`, with identical golden digests in all four profile fixtures.
- [ ] **TR-004:** The checked-in reference package has reviewed source and
  derived-asset licensing, maps U+0020...U+007E and U+00B0 exactly, contains a
  replacement glyph, passes every integrity check, and is assembly-valid.
- [ ] **TR-005:** Every scalar and explicit-line-break fixture produces the
  exact mapping behavior in this contract; unsupported valid scalars use only
  the package replacement glyph and no ambient fallback.
- [ ] **TR-006:** Golden fixtures prove equal line metrics, glyph metrics,
  glyph selection, advances, ink geometry, and explicit positioned points in
  macOS dynamic, macOS static, ARMv6, and nRF52840 builds.
- [ ] **TR-007:** Every malformed, mismatched, unsupported-schema, integrity,
  overflow, and capacity fixture returns the exact deterministic local result
  and SPEC-003 mapping without trap, partial package, substitution, or
  diagnostic dependence.
- [ ] **TR-008:** Bitmap and outline-capable fixtures share one exact resource
  identity and canonical geometry; raster coverage may differ but no raster
  result changes a metric, selection, advance, line, or position.
- [ ] **TR-009:** Payload and positioned-glyph lifetime instrumentation proves
  exact-once synchronous traversal and zero retained pointers, sources,
  operations, or borrowed bytes after their supplying call returns.
- [ ] **TR-010:** All static-path operations allocate zero heap bytes, every
  type meets its layout ceiling, every table/payload meets its finite count,
  and the nRF52840 reference composition meets the flash, fixed-RAM, and stack
  ceilings under the recorded SPEC-002 toolchain configuration.
- [ ] **TR-011:** The four exact contract-driver commands reproduce hashes,
  validation results, layout values, allocation evidence, and resource
  measurements from a clean checkout; cross-build results make no hardware
  claim.
- [ ] **TR-012:** Review finds no public `Text` semantics, layout constraint or
  wrapping policy, render-operation order, backend raster algorithm, cache
  policy, capability family, host product policy, or deferred typography
  feature introduced by this Specification.

## Implementation Notes

This section is non-authoritative. Generated sorted arrays or switch tables
can satisfy the accessors without existential storage on Embedded Swift. A
host implementation can perform digest validation in build tooling and retain
a generated validation certificate, but the assembly fixture must still prove
that the embedded descriptors and digests match the certified package.

The existing 5x7-in-8x12 bitmap code is useful for estimating table and raster
cost. It should not be migrated as the reference package until its glyph
provenance and license are resolved or it is replaced by a clean,
documented resource.

## Open Issues

1. **Approval blocker — licensed reference resource adoption.**
   [SPIKE-005](../spikes/spike-005-inter-reference-font-resource.md) now
   preserves a checked-in Inter 4.1 source and OFL license, renamed derived
   assets, reproducible commands, exact hashes, coverage, and hardware-free
   resource measurements. The Spike is evidence rather than authority. Before
   moving this Specification to `review`, maintainers must review the license
   obligations and decide whether to adopt or replace the Spike's candidate
   canonical serialization and outline format in the complete reference
   package. Replace this issue with authoritative package links and hashes
   only after that review; do not treat completion of the Spike as approval.
2. **Approval blocker — failure-origin ownership proof.** SPEC-003 has no
   text-resource origin. Before review, every Error Handling row must name and
   test an existing `hostComposition`, `layout`, or `rendering` adapter that
   genuinely detects the condition. If validation necessarily originates in
   `GiftUITextResources`, route the missing origin or mapping through a
   SPEC-003 revision and approval rather than silently assigning another
   layer's identity.
3. **Review calibration — concrete nRF52840 ceilings.** The 96 KiB flash,
   512-byte writable-RAM, and 1 KiB validation-stack ceilings are conservative
   draft bounds, not measured evidence. If the licensed reference package
   cannot meet them, revise the representation or submit measured evidence for
   a contract revision; do not waive a ceiling because the total image fits.

Neither issue permits identity substitution, geometry tolerance, an upward
import, or backend-owned layout. Such a proposal would require RFC/ADR review.

## Deferred and Follow-up Work

- [SPIKE-005](../spikes/spike-005-inter-reference-font-resource.md) preserves
  the licensed Inter 4.1 source, derived reference assets, integrity evidence,
  and hardware-free resource measurements needed to prepare this draft for
  review. Its generator and formats remain disposable evidence until adopted
  through this Specification.

- [FW-001](../future-work/fw-001-international-and-rich-text-layout.md)
  preserves complex scripts, bidirectional/vertical layout, rich text,
  variable fonts, color glyphs, and locale-aware shaping.
- [FW-002](../future-work/fw-002-text-interaction-and-accessibility-geometry.md)
  preserves selection, editing, carets, text hit testing, and accessibility
  geometry.
- [FW-003](../future-work/fw-003-advanced-font-delivery-and-glyph-rasterization.md)
  preserves runtime registration, resampling, distance fields, compression,
  generalized outline delivery, and shared caches.

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
