---
id: SPEC-014
feature: giftui-mvp-architecture
title: Raster Backend and Display Integration Contract
status: draft
authors:
  - codex
created: 2026-08-27
updated: 2026-08-28
proposal:
  - PROPOSAL-003
  - PROPOSAL-004
  - PROPOSAL-006
related_rfcs:
  - RFC-002
  - RFC-003
  - RFC-004
  - RFC-005
  - RFC-006
  - RFC-009
related_adrs:
  - ADR-005
  - ADR-006
  - ADR-007
  - ADR-008
  - ADR-009
  - ADR-010
  - ADR-014
  - ADR-015
  - ADR-016
  - ADR-017
  - ADR-018
  - ADR-019
  - ADR-020
  - ADR-021
  - ADR-022
  - ADR-023
  - ADR-030
  - ADR-031
related_specs:
  - SPEC-001
  - SPEC-002
  - SPEC-003
  - SPEC-004
  - SPEC-005
  - SPEC-008
  - SPEC-009
  - SPEC-012
  - SPEC-013
related_future_work:
  - FW-010
  - FW-014
related_explorations: []
related_spikes:
  - SPIKE-001
  - SPIKE-002
  - SPIKE-004
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPEC-014: Raster Backend and Display Integration Contract

## Summary

This Specification defines the reusable boundary that consumes GiftUI's
normalized ordered render stream, rasterizes it into canonical opaque pixel
encodings, and transfers backend-owned derived payloads to a separately owned
display target. It supplies the concrete obligations behind SPEC-009's
synchronous one-shot endpoint while preserving Core's borrowed lifetimes and
keeping raster, surface, display, and transport concerns below the semantic
boundary.

The contract supports recording, full-surface RGBA8888/framebuffer, and
bounded RGB565 tiled realizations. It freezes reservation, consumption,
payload ownership, clipping, quantization, post-handoff health, and failure
rules without selecting a target platform or hardware driver.

## Scope

This Specification covers:

- normalized fill, positioned-glyph, and straight-line-stroke consumption;
- exact RGBA8888 and big-endian RGB565 opaque pixel encoding;
- full-surface and bounded tiled raster realizations;
- surface extent, row stride, tile, payload, and in-flight bounds;
- synchronous downstream reservation before frame acceptance;
- borrowed Core resource consumption and backend-owned derived payloads;
- display-target reservation, submission, cancellation, and payload lifetime;
- post-acceptance operational health and input-eligibility projection;
- recording, framebuffer, and RGB565/tile conformance seams; and
- negative capability-contribution and failure fixtures.

It does not define a concrete macOS, Raspberry Pi, nRF52840, framebuffer file,
SPI, DMA, GPIO, touch, transport, or HAL implementation.

## Goals

- Keep backends below and independent of semantic expansion and layout.
- Make every acceptance decision before irreversible presentation effect.
- Preserve exact logical operation order, geometry, clipping, resources, and
  opaque paint across full-surface and tiled paths.
- Prove bounded payload and in-flight ownership with no retained Core borrow.
- Expose explicit health after acceptance without reopening the logical frame.
- Support hardware-free golden and fault-injection conformance.

## Non-goals

- Backend-owned text shaping, layout, fallback, semantic traversal, client
  action invocation, state mutation, or Canvas closure execution.
- Alpha, antialiasing, gradients, curves, fills through Path, transforms,
  images, or effects.
- Replayable operation streams or asynchronous Core completion.
- A universal display driver, shared delegated-service foundation, ambient
  device lookup, or platform-owned vertical stack.
- Host selection, product retry policy, configuration presets, or production
  capacities; those belong to Wave 7.
- Claiming connected hardware conformance from host fixtures.

## Dependencies

The governing Proposals are accepted, RFCs approved, and ADRs accepted.
SPEC-002 through SPEC-005, SPEC-008 through SPEC-009, and SPEC-012 are
approved. This Specification was drafted against SPEC-012 before its approval
and MUST be reconciled to the approved drawing contract before this draft
advances.

SPEC-004 owns capability vocabulary and resolution. SPEC-005 owns exact text
resource identity and compatible raster-resource views. SPEC-008 and SPEC-012
own normalized operation meaning. SPEC-009 owns the frame offer and logical
disposition. SPEC-003 owns outcomes, health vocabulary, and diagnostics.

## Related ADRs

- ADR-005 keeps semantic and layout authority above the normalized operation
  boundary.
- ADR-007 and ADR-008 require separate integration owners and acyclic module
  dependencies assembled only by a target host.
- ADR-009 requires checked integer geometry and deterministic overflow.
- ADR-010 fixes synchronous one-shot consumption, reservation before
  acceptance, and post-acceptance ownership transfer.
- ADR-014 through ADR-016 govern bounded outcomes, disposition layering,
  operational health, and non-authoritative diagnostics.
- ADR-017 through ADR-019 separate immutable capability from mutable health,
  require fixture-driven typed component contributions, and leave pure
  resolution at the bounded target-host composition point.
- ADR-020 requires the composite `rasterPresentation` contribution to include
  operation coverage, encoding, lifetime, extent, payload, and in-flight
  bounds.
- ADR-021 through ADR-023 forbid backend text remeasurement or substitution
  and require exact resource identity.
- ADR-030 fixes canonical complete straight-line-stroke meaning and borrowed
  synchronous consumption.
- ADR-031 requires pre-offer capacity validation and distinguishes backend
  capability from drawing-producer structural capacity.

## Terminology

**Raster backend**
: The owner that consumes normalized operations and derives target-encoding
  pixels, spans, tiles, or transfer payloads.

**Surface adapter**
: The owner of writable raster storage geometry and bounds, independent of a
  concrete display transport.

**Display target**
: The lower owner that reserves in-flight storage and accepts a complete
  backend-owned payload for ordered physical presentation.

**Reservation**
: Exclusive bounded downstream capacity secured before operation consumption
  or irreversible effect.

**Derived payload**
: Pixels, spans, tiles, or transfer bytes owned below the Core borrow and safe
  to retain after accepted handoff.

**Operational health**
: Explicit current post-handoff presentation state; it is neither capability
  resolution nor a diagnostic reconstruction.

## Public Contract

This Specification adds no public `GiftUI` API. Portable Presentation cannot
name a backend, pixel encoding, surface, display target, driver, platform, or
hardware device.

For the same valid normalized stream, exact resources, surface extent, damage,
and encoding, every conforming backend must produce the same opaque encoded
pixels inside the affected region. Physical timing and transport mechanism may
differ after accepted ownership transfer.

## Module Contract

`GiftUISurfaceCore` owns the surface descriptor, fixed encoded-pixel value,
writable surface contract, and surface recording fixtures. It imports
`GiftUI`, `GiftUIRenderCore`, and the approved SPEC-004 capability value module only for
`CanonicalPixelEncoding` and `RasterRealizationKind`. It MUST NOT import a
rasterizer, normalized render transport, runtime, backend integration,
display target, platform, driver, or host preset.

`GiftUIRasterCore` owns raster payload limits, canonical pixel encoding
functions, normalized-operation raster sink contract, and golden raster
fixtures. It imports `GiftUI`, `GiftUITextResources`, `GiftUIRenderCore`,
`GiftUISurfaceCore`, and the approved SPEC-004 capability value module only
for `SubmissionLifetime`. It MUST NOT import semantic core, layout, render
lowering, drawing-plan production, a runtime profile, execution coordinator,
platform, driver, OS/RTOS, HAL, hardware, or host preset.

`GiftUIDisplayCore` owns reservation identity, display payload writer and
target protocols, submission result, and target-local health facts. It imports
`GiftUI`, `GiftUISurfaceCore`, and the foundational failure values needed by its own narrow
adapter. It MUST NOT import semantic, layout, runtime, render lowering, or a
concrete raster backend.

`GiftUIBackendIntegration` owns the adapter that joins one raster realization,
surface adapter, exact text raster view, and display target into SPEC-009's
`SynchronousFrameEndpoint`. It imports `GiftUIRenderCore`, `GiftUIExecution`,
`GiftUITextResources`, `GiftUISurfaceCore`, `GiftUIRasterCore`, and
`GiftUIDisplayCore`.
Canvas-capable integrations use `DrawingOperationSink` from
`GiftUIRenderCore`; they MUST NOT import `GiftUIDrawing`.

Concrete raster, surface, display, platform, driver, and transport targets
implement the narrowest owner contract and depend only downward. A platform
preset may assemble them later but may not add semantic behavior. Capability
contributor adapters may import both a local component contract and
`GiftUICapabilities`; the components themselves do not perform resolution.

The backend owner adapter maps local failures into SPEC-003. Low-level display
and transport owners MUST NOT import `GiftUIFailureExecution` or execution
identities.

## Types / APIs

```swift
package struct CanonicalEncodedPixel: Equatable, Sendable {
    package let encoding: CanonicalPixelEncoding
    package let byteCount: UInt8
    package let byte0: UInt8
    package let byte1: UInt8
    package let byte2: UInt8
    package let byte3: UInt8
    package init(color: Color, encoding: CanonicalPixelEncoding)
}

package struct RasterSurfaceDescriptor: Equatable, Sendable {
    package let bounds: Rect
    package let encoding: CanonicalPixelEncoding
    package let bytesPerRow: UInt32
    package let realization: RasterRealizationKind
    package let tileWidth: UInt16
    package let tileHeight: UInt16
    package init?(bounds: Rect,
                  encoding: CanonicalPixelEncoding,
                  bytesPerRow: UInt32,
                  realization: RasterRealizationKind,
                  tileWidth: UInt16,
                  tileHeight: UInt16)
}

package protocol RasterSurface {
    borrowing var descriptor: RasterSurfaceDescriptor { get }
    borrowing var writableCapacityBytes: UInt32 { get }
    mutating func beginFrame(_ header: RenderPlanHeader) -> Bool
    mutating func replacePixel(
        at point: Point,
        with pixel: CanonicalEncodedPixel
    ) -> Bool
    mutating func finishFrame() -> Bool
    mutating func discardFrame()
}

package struct RasterPayloadLimits: Equatable, Sendable {
    package let maximumSurfaceBytes: UInt32
    package let maximumDerivedPayloadBytes: UInt32
    package let maximumDerivedRegions: UInt16
    package let maximumInFlightPayloads: UInt8
    package let maximumTilesPerFrame: UInt16
    package let maximumGlyphRasterBytes: UInt32
    package let maximumStrokeWorkspaceBytes: UInt32
    package init?(maximumSurfaceBytes: UInt32,
                  maximumDerivedPayloadBytes: UInt32,
                  maximumDerivedRegions: UInt16,
                  maximumInFlightPayloads: UInt8,
                  maximumTilesPerFrame: UInt16,
                  maximumGlyphRasterBytes: UInt32,
                  maximumStrokeWorkspaceBytes: UInt32)
}

package struct DisplayReservationID: Equatable, Hashable, Sendable {
    package let rawValue: UInt32
    package init(rawValue: UInt32)
}

package enum DisplayReservationResult: Equatable, Sendable {
    case reserved(DisplayReservationID)
    case backpressured
    case retryableRefusal
    case nonRetryableRefusal
    case failure(DisplayTargetError)
}

package enum DisplaySubmissionResult: UInt8, Equatable, Sendable {
    case accepted = 0
    case failureAfterAcceptance = 1
}

package enum DisplayTargetError: UInt8, Equatable, Sendable {
    case invalidDescriptor = 0
    case invalidReservation = 1
    case capacityExhausted = 2
    case arithmeticOverflow = 3
    case transportUnavailable = 4
    case reentrancyViolation = 5
    case invariantViolation = 6
}

package enum RasterBackendError: UInt8, Equatable, Sendable {
    case invalidEnvelope = 0
    case unsupportedOperation = 1
    case incompatibleResource = 2
    case invalidGeometry = 3
    case arithmeticOverflow = 4
    case capacityExhausted = 5
    case malformedStream = 6
    case rasterizationFailure = 7
    case displayFailure = 8
    case reentrancyViolation = 9
    case invariantViolation = 10
}

package protocol DisplayPayloadWriter {
    borrowing var capacityBytes: UInt32 { get }
    borrowing var writtenBytes: UInt32 { get }
    borrowing var regionCapacity: UInt16 { get }
    borrowing var writtenRegionCount: UInt16 { get }
    mutating func beginRegion(
        origin: Point,
        pixelCount: UInt16,
        encoding: CanonicalPixelEncoding
    ) -> Bool
    mutating func write(byte: UInt8) -> Bool
    mutating func endRegion() -> Bool
    mutating func finish() -> Bool
    mutating func discard()
}

package protocol DisplayTarget {
    associatedtype Writer: DisplayPayloadWriter
    mutating func reserve(
        descriptor: RasterSurfaceDescriptor,
        requiredPayloadBytes: UInt32,
        requiredRegionCount: UInt16
    ) -> DisplayReservationResult
    mutating func withWriter<Result>(
        for reservation: DisplayReservationID,
        _ body: (inout Writer) -> Result
    ) -> Result?
    mutating func submit(
        _ reservation: DisplayReservationID
    ) -> DisplaySubmissionResult
    mutating func cancel(_ reservation: DisplayReservationID)
    borrowing func health() -> GiftUIOperationalHealth
}

package protocol RasterFrameSink: DrawingOperationSink {
    borrowing var descriptor: RasterSurfaceDescriptor { get }
    borrowing var payloadLimits: RasterPayloadLimits { get }
    borrowing var failure: RasterBackendError? { get }
}

package protocol RasterBackendEndpoint: SynchronousFrameEndpoint
where Sink: RasterFrameSink {
    borrowing var descriptor: RasterSurfaceDescriptor { get }
    borrowing var payloadLimits: RasterPayloadLimits { get }
    borrowing func health() -> GiftUIOperationalHealth
}
```

All `RasterPayloadLimits` fields are positive. A count or byte total equal to
its limit succeeds. The next reservation fails before state change.
`maximumDerivedPayloadBytes` includes encoded pixel bytes and every
target-owned region descriptor or transport header retained for the frame;
metadata cannot be hidden in an uncounted side store.

`CanonicalEncodedPixel.byteCount` is exactly two for `.rgb565BigEndian` and
four for `.rgba8888`. Unused trailing byte fields are zero. Construction uses
the exact Encoding rules below and cannot fail for an admitted opaque
SPEC-008 `Color`.

For `.fullSurface`, `tileWidth` and `tileHeight` equal the surface width and
height. For `.tiled`, both are positive, no greater than the surface extent,
and their encoded checked byte product fits
`maximumDerivedPayloadBytes`. `bytesPerRow` is the exact encoded row stride,
is at least the checked packed row byte count, and has no implicit alignment
beyond the declared value. Empty surface bounds are invalid for an assembled
MVP backend.

`DisplayReservationID` is local to one display-target lifetime. Raw value zero
is allocated first; values advance by checked successor and are never reused.
Exhaustion fails reservation and never wraps.

`withWriter` supplies one nonescaping exclusive borrow for an active
reservation. `nil` means the reservation is absent or inactive and writes
nothing. A region is one nonempty horizontal run beginning at `origin`; it
must not cross the descriptor's row boundary. Between `beginRegion` and
`endRegion`, the writer accepts exactly `pixelCount * bytesPerPixel` bytes in
left-to-right pixel order and no nested region. Regions apply in call order,
so later opaque regions replace earlier pixels. This operation-major region
form is the canonical bounded tiled submission contract and carries the
coordinates that a sequential byte payload alone would lose.

`finish` succeeds only when every region has ended and the written payload
byte and region totals do not exceed the capacities reserved for this
submission. A failed body
must call `discard`; the owner
then calls `cancel`. `submit` consumes the active reservation logically and is
called exactly once only after successful writer finish.

Writer calls populate only display-target-owned staging covered by the active
reservation. They are reversible until `submit`, produce no physical display
effect, and are completely discarded by `cancel`. `submit` is the first point
at which irreversible presentation may begin.

`failureAfterAcceptance` means ownership and irreversible presentation
responsibility were already accepted. It updates health but cannot turn the
SPEC-009 offer into refusal or failure. A pre-acceptance problem is represented
by reservation refusal/failure or writer failure instead.

`RasterSurface.beginFrame` is called once with the exact validated header. It
returns `false` without mutation only when the idle surface cannot cover the
complete declared damage under its configured bounds. After success, every
`replacePixel` point is inside the descriptor bounds and frame damage; an
out-of-range point, wrong encoding, capacity refusal, or a `false`
`finishFrame` is an invariant failure and causes exactly one `discardFrame`.
`finishFrame` is called once after the complete stream. A surface may write
through to an already reserved display payload, retain a complete bounded
surface, or buffer bounded regions according to its declared realization, but
it may not retain a normalized operation or resource borrow.

## Behavior

### Startup validation and contribution

Before first offer, the assembled integration validates:

1. surface extent, packed width, stride, tile geometry, and every checked byte
   product;
2. exact text resource compatibility and raster-view availability;
3. operation coverage for fill, positioned glyph, and straight-line stroke;
4. full-surface or tile workspace plus derived region records against payload
   limits;
5. maximum glyph and stroke intermediate storage;
6. in-flight display reservation count and submission lifetime; and
7. absence of any replay or retained Core-resource requirement.

The capability adapter contributes these proven facts to SPEC-004. It reports
exactly `.rgba8888` or `.rgb565BigEndian`,
`.synchronousBorrowedOneShot`, the selected
realization, extent, operation set, payload/in-flight bounds, and downstream
submission lifetime. It MUST NOT report support inferred from target name or
repair an invalid local configuration. Runtime health never changes the
contribution.

SPEC-012 point, Path, plan, and producer-operation capacities are not backend
capability fields. The host later requires both the producer structural gate
and this presentation capability.

### Offer, reservation, and consumption

For each candidate, the endpoint verifies the envelope and exact immutable
configuration, then attempts one display reservation large enough for the
complete bounded derived bytes, region records, and any declared in-flight
ownership. It performs no
operation consumption before successful reservation.

Reservation results map exactly:

| Display reservation | SPEC-009 offer behavior |
| --- | --- |
| `reserved` | call body exactly once |
| `backpressured` | return `.backpressured` without body |
| `retryableRefusal` | return `.retryableRefusal` without body |
| `nonRetryableRefusal` | return `.nonRetryableRefusal` without body |
| `failure` | return `.failed` without body and preserve local error |

During the one body call, the sink validates the header before mutation,
calls its selected `RasterSurface.beginFrame`, consumes every operation in
painter order, and derives pixels or target bytes only into the active surface,
storage covered by the reservation, or backend-owned bounded workspace. It
borrows glyph-resource and stroke views only during their calls. Every covered
logical pixel is passed to `replacePixel` as one exact
`CanonicalEncodedPixel`.

On `.complete`, it calls `finishFrame`, finalizes the exact payload, submits the reservation, and
returns `.accepted`. Once submission or any other irreversible effect begins,
the endpoint must consume or safely drain the stream and return `.accepted`.
Later failure updates health. On every non-complete body result before
irreversible effect, it discards the surface and derived work, cancels the reservation, retains
no candidate data, and applies SPEC-009's exact result mapping.

The endpoint never calls the body twice, escapes it, retains the sink borrow,
or retains any RenderOperation, glyph, resource view, Path snapshot, stroke
view, or Core address. Only encoded backend/display-owned bytes and local
operational state survive acceptance.

### Raster semantics

The sink applies the header's half-open surface and damage bounds. Every
operation is intersected with its resolved half-open clip and surface bounds;
Canvas bounds are never an additional clip. Empty intersections write no
pixel but preserve stream order and validity.

`fillRect` replaces every covered pixel with the operation's opaque color.
Positioned glyphs use the exact `FontInstanceID`, `GlyphID`, baseline, clip,
and compatible SPEC-005 raster resource. The backend may not remeasure,
reshape, substitute, or reposition glyphs. Bitmap and outline realizations may
differ only in coverage expressly permitted by SPEC-005; the checked-in MVP
golden resource view is exact.

Straight-line strokes use SPEC-012's canonical binary pixel-center coverage,
caps, joins, miter limit, subpath boundaries, width, origin metadata, inherited
clip, and zero-length behavior. Duplicate points never imply a new subpath.
Full-surface and tiled implementations must yield the same final pixel set.

Opaque painter order is replacement order across all operation types. Tiling
may revisit an immutable operation only while that operation's synchronous
borrow is active; it may not retain the operation for a later tile. Therefore
a tiled sink must rasterize the operation across every affected resident tile,
or derive bounded owned spans/tile data, before returning from that operation
call.

### Encoding

RGBA8888 stores four bytes per pixel in red, green, blue, alpha order, with
alpha exactly `255`.

RGB565 computes with widened checked integer arithmetic:

```text
r5 = (red * 31 + 127) / 255
g6 = (green * 63 + 127) / 255
b5 = (blue * 31 + 127) / 255
word = (r5 << 11) | (g6 << 5) | b5
```

It stores the most-significant byte first. There is no alpha, dithering,
gamma transform, premultiplication, color-space conversion, tolerance, or
ambient native format substitution.

Padding bytes in a row are initialized deterministically to zero and are not
part of the logical pixel comparison. Payload descriptors must preserve the
declared stride so a consumer never infers packed storage.

### Operational health and input eligibility

The display target owns current health for its presentation facility. A
successful accepted transfer makes or keeps the facility `.available` as
defined by SPEC-003. A post-acceptance failure transitions health through the
allowed bounded state machine and may be projected diagnostically.

Health transitions do not modify capability results, semantic publication, or
the accepted frame disposition. The host consumes health to quiesce affected
presentation-coupled input according to SPEC-009 and total Wave 7 policy. The
backend does not invoke actions or mutate application state.

## State / Lifecycle

```text
idle
  -> reserved -> consuming -> payload complete -> submitted/accepted
       |            |                 |
       +------------+-----------------> cancelled/refused -> idle

accepted -> presenting -> available
                       \-> degraded/unavailable (operational health only)
```

Only one transition from a candidate reaches `accepted`. Cancellation is
legal only before irreversible effect. Every reservation ends in exactly one
submit or cancel. Teardown waits for or safely abandons only display-owned
in-flight payloads; no Core borrow participates.

## Capability Requirements

The integration supplies contributor-owned facts, not a resolved Boolean. The
adapter must cover:

- `.fillRect`, `.positionedGlyphs`, and `.straightLineStroke` operations;
- synchronous one-shot operation lifetime;
- exact RGBA8888 or RGB565 encoding;
- logical extent and clip/damage behavior;
- full-surface or tiled realization;
- derived payload and glyph/stroke workspace bounds;
- maximum in-flight payloads;
- submission lifetime and handoff compatibility; and
- no retained Core-resource requirement.

Any absent operation, incompatible resource, encoding mismatch, insufficient
extent/bound, or incompatible lifetime contributes the stable SPEC-004
unavailable reason. Health and diagnostics are excluded.

## Backend Requirements

Every backend conforms to `RasterBackendEndpoint` and uses a sink conforming
to `RasterFrameSink`. Canvas-capable MVP backends must accept
`straightLineStroke`; an ordinary SPEC-008-only backend cannot satisfy the
Signal Analyzer capability requirement.

Recording conformance may store normalized value transcripts because it is a
test endpoint and never claims physical presentation. Production backends may
retain only derived payloads. Framebuffer mapping, SPI/DMA ownership, and
device-specific completion are implementation contracts below
`DisplayTarget` and cannot affect Core semantics.

## Error Handling

| Local error | condition | origin | scope | containment |
| --- | --- | --- | --- | --- |
| invalid descriptor/envelope/geometry | `.invalidValue` | `.backend` | `.candidateFrame` | `.contained` |
| incompatible text resource after startup | `.invariantViolation` | `.backend` | `.runtime` | `.safetyNotProven` |
| unsupported normalized operation after startup | `.invariantViolation` | `.backend` | `.runtime` | `.safetyNotProven` |
| checked arithmetic overflow | `.arithmeticOverflow` | `.foundation` | `.candidateFrame` | `.contained` |
| pre-consumption workspace/payload exhaustion | `.capacityExhausted` | `.backend` | `.candidateFrame` | `.contained` |
| malformed stream or post-begin sink refusal | `.invariantViolation` | `.backend` | `.runtime` | `.safetyNotProven` |
| reentrant offer/reservation/writer use | `.reentrancyViolation` | `.backend` | `.runtime` | `.safetyNotProven` |
| pre-acceptance display transport failure | `.requiredFacilityUnavailable` | `.presentationIntegration` | `.component` | `.contained` |
| post-acceptance display/transport failure | `.requiredFacilityUnavailable` | `.presentationIntegration` | `.component` | `.contained` |

The condition, origin, scope, and containment values above are the exact
SPEC-003 vocabulary. Adapters preserve the local `RasterBackendError` or
`DisplayTargetError` for correlation; this Specification introduces no new
failure identity.

Detection order is descriptor, resource, operation coverage, workspace,
payload/in-flight lifetime, reservation, envelope/header, stream grammar,
operation-local validation, payload completion, then submission. A later
check cannot replace an earlier detected failure or begin irreversible output.

Ordinary backpressure and retryable/non-retryable refusal are operational
offer dispositions, not `.failed`. Post-acceptance failure updates health and
diagnostics only. Diagnostics never determine reservation, raster output,
offer result, retry, or input admission.

## Performance Requirements

All storage and work are bounded by surface, operation, glyph, stroke, tile,
payload, and in-flight limits. Full-surface raster cost is linear in affected
pixels plus operation/resource work. Tiled cost is linear in the intersections
between admitted operations and resident tiles; the host must declare a finite
maximum tile count.

The RGB565 tiled static fixture allocates zero heap bytes and links no task,
thread, exception, reflection, Objective-C, or hidden complete-frame buffer.
The framebuffer realization owns exactly its declared mapped surface plus
bounded raster workspace. Neither path retains a complete normalized display
list.

Evidence must report separately surface bytes, tile bytes, glyph workspace,
stroke workspace, derived payload bytes, in-flight bytes, display/transport
bytes, stack high-water, heap allocation, flash/text/rodata/data/BSS deltas,
and per-frame raster/submit time under the pinned toolchains.

## Compatibility

This contract is package SPI, not public ABI or a persisted wire format.
RGBA8888 and RGB565 encoded bytes and golden fixture outputs are normative.
Changing byte order, quantization, stroke coverage, clip rules, or resource
identity requires a revised or successor Specification and, if architectural,
upstream lifecycle work.

New pixel encodings, asynchronous Core payloads, replayable streams, or
backend semantic authority are outside this contract. Concrete transports may
change when they preserve reservation, ownership, health, and encoded-payload
semantics.

## Testing Requirements

The contract suite MUST provide one normalized fixture corpus that runs
through:

- a canonical recording endpoint;
- a recording `RasterSurface` that checks exact
  begin/replace/finish/discard grammar;
- a full-surface RGBA8888 buffer;
- a full-surface/framebuffer RGB565 adapter; and
- a bounded RGB565 tiled target with at least two tile sizes.

Tests must cover:

- exact fills, glyph resource identity/positions, clips, damage, painter order,
  and every SPEC-012 stroke vector;
- RGB boundary values `0`, `1`, `127`, `128`, `254`, and `255`;
- odd strides, partial edge tiles, empty intersections, negative logical
  geometry, every clip edge, and checked byte overflow;
- exact limit and first-excess for surface, tile, glyph, stroke, payload bytes,
  derived regions, tiles-per-frame, and in-flight capacity;
- backpressure and each refusal/failure mapping before body invocation;
- complete, producer-failed, capacity, endpoint-refused, and contract-violation
  body mappings;
- reservation submit/cancel totality and checked identity exhaustion;
- writer underflow, overflow, double finish, double submit, stale reservation,
  and reentrancy;
- borrow poisoning and address capture proving no Core value or resource view
  survives offer;
- post-acceptance failure leaving the logical frame committed while updating
  health;
- capability negative matrices for operation, resource, encoding, extent,
  bound, lifetime, and handoff incompatibility; and
- dependency tests rejecting semantic/layout/runtime imports below the
  backend boundary and concrete integrations above it.

Golden pixel masks and encoded bytes have zero tolerance. Hardware-free tests
are required for approval. Connected framebuffer, PiScreen, nRF52840 TFT, and
transport evidence belongs to later conformance and must identify actual
hardware separately.

## Acceptance Criteria

- [ ] The module graph preserves separate surface, raster, display,
  backend-integration, runtime, and host ownership with no prohibited import.
- [ ] Every valid candidate reserves all required downstream capacity before
  body consumption or irreversible effect.
- [ ] Every reservation ends in exactly one submit or cancel.
- [ ] Accepted handoff retains only backend/display-owned derived payload and
  no Core borrow or address.
- [ ] Recording, full-surface, framebuffer, and tiled fixtures produce exact
  equivalent logical pixels and canonical encoded bytes.
- [ ] Backends never reshape, remeasure, substitute, or reposition text.
- [ ] Straight-line strokes satisfy the complete canonical vector corpus with
  zero pixel tolerance.
- [ ] Backpressure, refusal, body result, and failure mappings match SPEC-009.
- [ ] Post-acceptance failure cannot reopen the frame and updates explicit
  health independently from capability.
- [ ] Exact-limit succeeds and first-excess fails deterministically for every
  owned bound.
- [ ] Static RGB565 tiled evidence shows zero heap allocation and no retained
  display list or complete-frame buffer.
- [ ] Capability contributions cover every required fact and negative matrix
  without target-identity probing.
- [ ] Fault injection, borrow poisoning, dependency, resource, and timing
  evidence is reproducible under pinned MVP toolchains.
- [ ] SPEC-012 is approved and this Specification is reconciled to its final
  stroke declarations before approval is requested.

## Implementation Notes

A tile-major implementation is permitted only if each operation is fully
consumed while borrowed. A practical bounded realization may keep a fixed set
of resident tile buffers and immediately derive owned transfer bytes or spans
for all intersecting tiles before returning from the operation call.

The recording endpoint should record normalized logical payloads rather than
pixels; the raster fixtures should consume the same operation source and
compare final encoded surfaces.

## Open Issues

- SPEC-012 is approved; reconciliation of this draft to its approved normalized
  stroke contract remains required before review.
- Production surface, tile, payload, and in-flight values are Wave 7
  HOST-CONFIGURATION inputs and are intentionally not selected here.

These are contract-reconciliation or downstream configuration issues, not
unresolved architecture.

## Deferred and Follow-up Work

- [FW-010](../future-work/fw-010-backend-transport-submission-retry.md)
  remains outside MVP Core semantics; revisit only on its recorded transport
  recovery trigger.
- [FW-014](../future-work/fw-014-replayable-operation-delivery.md) remains
  outside this one-shot contract; revisit only when a measured raster path
  cannot meet requirements with owned derived data.

No new deferred artifact was needed and current MVP scope is unchanged.

## References

- [GiftUI MVP Specification Portfolio](../roadmap/MVP_SPECIFICATION_PORTFOLIO.md)
- [GiftUI MVP Scope](../MVP_SCOPE.md)
- [PROPOSAL-003](../proposals/proposal-003-giftui-mvp-architecture-establishment.md)
- [PROPOSAL-004](../proposals/proposal-004-capability-system.md)
- [PROPOSAL-006](../proposals/proposal-006-canvas-path-stroke-drawing.md)
- [RFC-002](../rfcs/rfc-002-giftui-mvp-layered-architecture.md)
- [RFC-003](../rfcs/rfc-003-deterministic-text-rendering-architecture.md)
- [RFC-004](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [RFC-005](../rfcs/rfc-005-failure-diagnostics-propagation.md)
- [RFC-006](../rfcs/rfc-006-capability-system-architecture.md)
- [RFC-009](../rfcs/rfc-009-canvas-path-stroke-drawing-architecture.md)
- [ADR index](../adrs/README.md)
- [SPEC-002](spec-002-portable-foundation.md)
- [SPEC-003](spec-003-failure-outcomes-and-containment.md)
- [SPEC-004](spec-004-capability-contribution-and-resolution.md)
- [SPEC-005](spec-005-text-resources.md)
- [SPEC-008](spec-008-rendering.md)
- [SPEC-009](spec-009-execution-cycle-and-frame-handoff.md)
- [SPEC-012](spec-012-canvas-path-stroke-drawing.md)
- [SPIKE-001](../spikes/spike-001-tiled-one-shot-capability-fixtures.md)
- [SPIKE-002](../spikes/spike-002-nrf52840-capability-path-resource-evidence.md)
- [SPIKE-004](../spikes/spike-004-canvas-path-plan-feasibility.md)
