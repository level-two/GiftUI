---
id: SPEC-014
feature: giftui-mvp-architecture
title: Raster Backend and Display Integration Contract
status: approved
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
  - SPEC-015
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

> **Approval status:** Explicitly approved by the maintainer after renewed
> approval of SPEC-009's focused-owner failure-carrier amendment. This
> contract is authoritative for implementation.

## Summary

This Specification defines the reusable boundary that consumes GiftUI's
normalized ordered render stream, rasterizes it into canonical opaque pixel
encodings, and transfers backend-owned derived payloads to a separately owned
display target. It supplies the concrete obligations behind SPEC-009's
synchronous one-shot endpoint while preserving Core's borrowed lifetimes and
keeping raster, surface, display, and transport concerns below the semantic
boundary.

The contract supports recording, full-surface RGBA8888/framebuffer, and
bounded operation-major RGB565 tiled realizations. It freezes capability-to-
configuration reconciliation, frame-session reservation, reusable bounded
region submission, responsibility transfer, payload ownership, clipping,
quantization, post-handoff health, and failure rules without selecting a
target platform or hardware driver.

## Scope

This Specification covers:

- normalized fill, positioned-glyph, and straight-line-stroke consumption;
- exact RGBA8888 and big-endian RGB565 opaque pixel encoding;
- full-surface and bounded tiled raster realizations;
- exact reconciliation with SPEC-004's effective extent, region, row, raster,
  payload, in-flight, encoding, lifetime, handoff, and realization values;
- surface extent, row stride, region, payload, region-submission, tile-visit,
  and in-flight bounds;
- frame-session reservation before operation consumption;
- one complete full-surface transfer or operation-major reusable tiled-region
  transfers under the same one-shot offer;
- borrowed Core resource consumption and backend-owned derived payloads;
- display-target reservation, submission, cancellation, and payload lifetime;
- post-acceptance operational health and input-eligibility projection;
- recording, framebuffer, and RGB565/tile conformance seams; and
- negative capability-contribution and failure fixtures.

It does not define a concrete macOS, Raspberry Pi, nRF52840, framebuffer file,
SPI, DMA, GPIO, touch, transport, or HAL implementation.

MVP inclusion is required by the Signal Analyzer's opaque backgrounds,
positioned labels, grid/trace strokes, clipping, and damage on macOS dynamic
and static full-surface configurations, Raspberry Pi/Linux PiScreen, and the
nRF52840 TFT static configuration. The reusable contract is the stack-
validation seam that keeps those target-specific display mechanisms below one
portable presentation.

## Goals

- Keep backends below and independent of semantic expansion and layout.
- Preserve refusal/abort only before irreversible effect and transfer accepted
  responsibility at the first submitted effect.
- Preserve exact logical operation order, geometry, clipping, resources, and
  opaque paint across full-surface and tiled paths.
- Prove bounded raster, payload, region, tile-visit, and in-flight ownership
  with no retained Core borrow.
- Expose explicit health after acceptance without reopening the logical frame.
- Support hardware-free golden and fault-injection conformance.

## Non-goals

- Backend-owned text shaping, layout, fallback, semantic traversal, client
  action invocation, state mutation, or Canvas closure execution.
- Alpha, antialiasing, gradients, curves, fills through Path, transforms,
  images, or effects.
- Replayable operation streams or asynchronous Core completion.
- Tile-major replay of the producer body or normalized operation stream.
- A universal display driver, shared delegated-service foundation, ambient
  device lookup, or platform-owned vertical stack.
- Host selection, product retry policy, configuration presets, or production
  capacities; those belong to Wave 7.
- Claiming connected hardware conformance from host fixtures.

## Dependencies

The governing Proposals are accepted, RFCs approved, and ADRs accepted.
SPEC-002 through SPEC-005, SPEC-008, SPEC-009, and SPEC-012 are approved. This
revision is reconciled to
SPEC-012's approved one-operation-
per-stroke, borrowed `StraightLineStrokeView`, checked surface-coordinate,
inherited-clip, canonical coverage, encoding, capacity, and failure contract.

SPEC-001 and SPEC-013 are approved downstream coordination contracts. Their
production Signal Analyzer capacities and host assembly do not redefine this
backend contract.

SPEC-004 owns capability vocabulary and resolution. SPEC-005 owns exact text
resource identity and compatible raster-resource views. SPEC-008 and SPEC-012
own normalized operation meaning. SPEC-009 owns the frame offer and logical
disposition. SPEC-003 owns outcomes, health vocabulary, and diagnostics.

## Related ADRs

- ADR-005 and ADR-006 keep semantic and layout authority above the normalized
  operation boundary and require equivalent results across runtime profiles.
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
- ADR-020 requires the composite `rasterPresentation` path to reconcile
  operation coverage, encoding, lifetime, extent, raster, payload, region,
  handoff, and in-flight bounds without a target-identity Boolean.
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
: The lower owner that reserves one bounded frame session and accepts one or
  more ordered backend-owned region payloads for physical presentation.

**Reservation**
: One target-owned frame session and its reusable bounded payload slot,
  secured before operation consumption or irreversible effect.

**Region payload**
: One bounded batch of nonempty horizontal opaque runs. It is no larger than
  SPEC-004's selected `requiredPayloadBytes` and is submitted while the
  current operation borrow is active.

**Operation-major tiled realization**
: A realization that visits every intersecting full-width row tile for the
  current operation, submits only owned encoded regions, and completes that
  operation before accepting the next borrowed operation.

**Responsibility transfer**
: The first successful region submission, ownership transfer, queued handoff,
  framebuffer write, or other irreversible presentation effect in a reserved
  frame session. From that point the SPEC-009 offer must be accepted.

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
`GiftUI`, `GiftUIRenderCore`, and `GiftUICapabilities` only for
`CanonicalPixelEncoding` and `RasterRealizationKind`. It MUST NOT import a
rasterizer, normalized render transport, runtime, backend integration,
display target, platform, driver, or host preset.

`GiftUIRasterCore` owns raster payload limits, canonical pixel encoding
functions, normalized-operation raster sink contract, and golden raster
fixtures. It imports `GiftUI`, `GiftUITextResources`, `GiftUIRenderCore`,
`GiftUISurfaceCore`, and `GiftUICapabilities` only for the selected capability
value types named by this contract. It MUST NOT import semantic core, layout, render
lowering, drawing-plan production, a runtime profile, execution coordinator,
platform, driver, OS/RTOS, HAL, hardware, or host preset.

`GiftUIDisplayCore` owns reservation identity, display payload writer and
target protocols, transfer result, and target-local health facts. It imports
`GiftUI`, `GiftUISurfaceCore`, `GiftUICapabilities`, and the foundational
failure values needed by its own narrow adapter. It MUST NOT import semantic,
layout, runtime, render lowering, or a concrete raster backend.

`GiftUIBackendIntegration` owns the adapter that joins one raster realization,
surface adapter, exact text raster view, and display target into SPEC-009's
`SynchronousFrameEndpoint`. It imports `GiftUIRenderCore`, `GiftUIExecution`,
`GiftUITextResources`, `GiftUISurfaceCore`, `GiftUIRasterCore`, and
`GiftUIDisplayCore`.
Canvas-capable integrations use `DrawingOperationSink` from
`GiftUIRenderCore`; they MUST NOT import `GiftUIDrawing`.

`GiftUIBackendIntegration` also imports `GiftUICapabilities` for the immutable
`EffectiveRasterPresentation` and selected value enums only; it MUST NOT import
or invoke `RasterPresentationResolver`.

`GiftUIBackendIntegration` consumes one immutable
`EffectiveRasterPresentation`. It does not rerun capability resolution and
does not translate the selected value into a competing configuration model.

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
    package let regionWidth: UInt16
    package let regionHeight: UInt16
    package init?(bounds: Rect,
                  encoding: CanonicalPixelEncoding,
                  bytesPerRow: UInt32,
                  realization: RasterRealizationKind,
                  regionWidth: UInt16,
                  regionHeight: UInt16)
}

package protocol RasterSurface {
    borrowing var descriptor: RasterSurfaceDescriptor { get }
    borrowing var writableCapacityBytes: UInt32 { get }
    borrowing var presentationResponsibilityAccepted: Bool { get }
    mutating func beginFrame(_ header: RenderPlanHeader) -> Bool
    mutating func replacePixel(
        at point: Point,
        with pixel: CanonicalEncodedPixel
    ) -> Bool
    mutating func finishFrame() -> Bool
    mutating func discardFrame()
}

package struct RasterPayloadLimits: Equatable, Sendable {
    package let maximumRasterBytes: UInt32
    package let maximumPayloadBytes: UInt32
    package let maximumRegionsPerPayload: UInt16
    package let maximumRegionSubmissionsPerFrame: UInt32
    package let maximumTileVisitsPerFrame: UInt32
    package let maximumInFlightPayloads: UInt8
    package let maximumGlyphRasterBytes: UInt32
    package let maximumStrokeWorkspaceBytes: UInt32
    package init?(maximumRasterBytes: UInt32,
                  maximumPayloadBytes: UInt32,
                  maximumRegionsPerPayload: UInt16,
                  maximumRegionSubmissionsPerFrame: UInt32,
                  maximumTileVisitsPerFrame: UInt32,
                  maximumInFlightPayloads: UInt8,
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

package enum DisplayTransferResult: Equatable, Sendable {
    case completed
    case failureBeforeAcceptance(DisplayTargetError)
    case failureAfterAcceptance(DisplayTargetError)
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
    borrowing var submissionLifetime: SubmissionLifetime { get }
    borrowing var handoff: SubmissionHandoff { get }
    borrowing var maximumInFlightPayloads: UInt8 { get }
    borrowing var maximumInFlightBytes: UInt32 { get }
    mutating func reserveFrame(
        descriptor: RasterSurfaceDescriptor,
        payloadCapacityBytes: UInt32,
        regionCapacity: UInt16
    ) -> DisplayReservationResult
    mutating func withWriter<Result>(
        for reservation: DisplayReservationID,
        _ body: (inout Writer) -> Result
    ) -> Result?
    mutating func submitPayload(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult
    mutating func finishFrame(
        _ reservation: DisplayReservationID
    ) -> DisplayTransferResult
    mutating func cancelFrame(_ reservation: DisplayReservationID)
    borrowing func health() -> GiftUIOperationalHealth
}

package protocol RasterFrameSink: DrawingOperationSink {
    borrowing var descriptor: RasterSurfaceDescriptor { get }
    borrowing var payloadLimits: RasterPayloadLimits { get }
    borrowing var failure: RasterBackendError? { get }
}

package protocol RasterBackendEndpoint: SynchronousFrameEndpoint
where Sink: RasterFrameSink {
    associatedtype TextRaster: TextRasterResourceView
    borrowing var effectivePresentation: EffectiveRasterPresentation { get }
    borrowing var descriptor: RasterSurfaceDescriptor { get }
    borrowing var payloadLimits: RasterPayloadLimits { get }
    borrowing var textRaster: TextRaster { get }
    borrowing var textRasterRealization: RasterRealizationID { get }
    borrowing func health() -> GiftUIOperationalHealth
}
```

All `RasterPayloadLimits` fields are positive. A count or byte total equal to
its limit succeeds. The first excess fails before `body` or, for a violated
startup invariant, before irreversible effect. `maximumRasterBytes` and
`maximumPayloadBytes` count encoded pixel storage only and map to SPEC-004's
raster and payload byte domains. Region descriptors, counters,
transport headers, and driver storage are separate owned domains and MUST be
bounded and reported; they MUST NOT be hidden inside either capability byte
field.

The checked product `maximumPayloadBytes * maximumInFlightPayloads` is the
local available in-flight byte ceiling. Overflow makes the limits invalid; the
product must admit the selected `requiredInFlightBytes`.

`CanonicalEncodedPixel.byteCount` is exactly two for `.rgb565BigEndian` and
four for `.rgba8888`. Unused trailing byte fields are zero. Construction uses
the exact Encoding rules below and cannot fail for an admitted opaque
SPEC-008 `Color`.

`RasterSurfaceDescriptor` is valid only when `bounds` has origin `(0, 0)` and
positive width and height representable by `CapabilityExtent`.
`regionWidth` MUST equal the full surface width for both realizations, as
required by SPEC-004. For `.fullSurface`, `regionHeight` equals the surface
height. For `.tiled`, `regionHeight` is positive and no greater than surface
height. `bytesPerRow` is exactly SPEC-004's selected `rowBytes`; it is at least
the checked packed full-width row byte count and contains every declared
alignment byte. The checked product `bytesPerRow * regionHeight` is the exact
selected per-region raster and payload byte requirement.

The assembled endpoint MUST prove exact equality between its descriptor and
the immutable `EffectiveRasterPresentation`: bounds size equals `extent`,
region size equals `regionExtent`, `bytesPerRow` equals `rowBytes`, and
encoding and realization equal the selected values. The corresponding limits
must admit `requiredRasterBytes`, `requiredPayloadBytes`, `inFlightCount`, and
`requiredInFlightBytes`, and `RasterSurface.writableCapacityBytes` MUST equal
`requiredRasterBytes.rawValue`. The display target's lifetime and handoff MUST
equal the selected values and its in-flight count/byte maxima must admit the
selected exact requirements. A mismatch rejects startup; the endpoint never
clamps or recomputes the effective value.

`DisplayReservationID` is local to one display-target lifetime. Raw value zero
is allocated first; values advance by checked successor and are never reused.
Exhaustion fails reservation and never wraps.

`reserveFrame` secures one frame session and one reusable payload slot before
the operation body is called. It does not reserve storage for a whole-frame
display list. `payloadCapacityBytes` MUST equal the selected
`requiredPayloadBytes`; `regionCapacity` MUST equal
`maximumRegionsPerPayload`. A successful reservation promises that the
selected realization can complete its bounded submission sequence without
mid-frame backpressure. A target that cannot make that promise refuses before
`body`.

`withWriter` supplies one nonescaping exclusive borrow for an active idle
payload slot. `nil` means the reservation is absent, inactive, already has a
finished payload awaiting submission, or has ended; it writes nothing. A
region is one nonempty horizontal run beginning at `origin`; it must be inside
the surface and current damage and must not cross the row boundary. Between
`beginRegion` and `endRegion`, the writer accepts exactly
`pixelCount * bytesPerPixel` bytes in left-to-right pixel order and no nested
region. Region bytes are packed; `bytesPerRow` governs full-width raster
storage and tile capacity, not padding inside a horizontal run. Regions apply
in call order, so later opaque regions replace earlier pixels. Coordinates
are mandatory; a sequential byte payload without them is nonconforming.

`finish` succeeds only when every region has ended, at least one region was
written, and byte and region totals do not exceed the slot capacities. A
failed writer body calls `discard`; the payload slot becomes reusable and no
submission occurs. `submitPayload` is called exactly once for each successful
writer `finish`, consumes that payload, and leaves the frame reservation
active for a later payload or `finishFrame`.

Writer calls populate only display-target-owned staging covered by the active
reservation. They are reversible until `submitPayload`, produce no physical
display effect, and are completely discarded by writer `discard` or
`cancelFrame`. The first successful `submitPayload` is the responsibility-
transfer point, even when a concrete synchronous target completes the physical
write before returning.

`DisplayTransferResult.completed` means the requested payload or frame-end
marker was accepted under the selected lifetime and handoff. For
`submitPayload`, it always transfers presentation responsibility.
`failureBeforeAcceptance` is legal only when this reservation has completed no
payload, transferred no ownership, queued no work, and made no irreversible
effect. Once responsibility has transferred, the target MUST return
`failureAfterAcceptance` for every later transport/device failure and update
health before returning. `finishFrame` ends the reservation exactly once; it
may be called with no submitted payload for empty damage.

The surface sets `presentationResponsibilityAccepted` to `true` before
returning from any `submitPayload` that produces `.completed` or
`.failureAfterAcceptance`, and from a zero-payload `finishFrame` that produces
`.failureAfterAcceptance`. A `.failureBeforeAcceptance` result never changes
the property. This transition is recorded before any health projection and
cannot be rolled back.

`failureAfterAcceptance` from `submitPayload` moves the reservation into a
draining state: no later writer or payload submission occurs, but the target
retains the frame session until the sink calls `finishFrame` exactly once after
the stream ends. `failureBeforeAcceptance` leaves the reservation cancellable
and exposes no submitted payload.

`RasterSurface.beginFrame` is called once with the exact validated header. It
returns `false` without mutation only when the idle surface cannot cover the
complete declared damage under its configured bounds and prevalidated work
limits. After success, every `replacePixel` point is inside descriptor bounds
and frame damage and uses the descriptor encoding. An out-of-range point,
wrong encoding, or capacity refusal before responsibility transfer is an
invariant failure and causes exactly one `discardFrame` and `cancelFrame`.

After `presentationResponsibilityAccepted` becomes `true`, it remains true
until frame reset. A later display fault is recorded in health, but
`replacePixel` and `finishFrame` MUST continue to return `true` so the producer
can complete or safely drain the one-shot stream. The surface may stop
rasterizing after such a fault, but it must continue validating stream grammar
and borrows. `finishFrame` is called once after the complete stream. A full-
surface implementation may retain one bounded encoded surface until final
submission. A tiled implementation submits owned regions while each operation
borrow is active. Neither may retain a normalized operation or resource
borrow.

`RasterFrameSink.descriptor` and `payloadLimits` are immutable for the endpoint
lifetime. `failure` is `nil` when idle and at successful `begin`; the first
local error in an attempt becomes sticky and later observations cannot replace
it. Attempt reset clears it only after all mapping/correlation has completed.
`RasterBackendEndpoint.health()` returns the same authoritative value owned by
its selected display target, not a cached reconstruction.

The endpoint's text raster view and realization ID are immutable for its
lifetime. Their descriptor and realization must equal the exact package and
selected realization admitted by SPEC-005 validation. During each positioned-
glyph call, the sink resolves that exact glyph record and invokes
`withPayload` at most once; the payload borrow ends before the call returns.
Missing lookup or payload after successful startup is
`incompatibleResource` and a runtime invariant, never substitution.

For a reserved writer, `capacityBytes` and `regionCapacity` equal the values
passed to `reserveFrame`. `writtenBytes` and `writtenRegionCount` begin at zero
for each payload and return to zero after `discard` or successful
`submitPayload`. A failed `finish`, failed submission before responsibility,
or inactive/stale writer never exposes partial bytes to the physical target.

For selected `.synchronousBorrow`, `submitPayload` finishes consuming the
writer bytes before it returns and retains no writer borrow. For
`.synchronousCopy`, it completes a bounded copy into lower-owned storage before
return. For `.ownershipTransfer`, it transfers the one payload slot exactly
once and the backend never accesses it again. A `.queued` handoff likewise
retains only lower-owned bytes after return. Because the latter two forms do
not promise reusable one-slot storage during the body, this contract permits
them only for the zero-or-one-payload full-surface path.

## Behavior

### Startup validation and contribution

Before first offer, the assembled integration validates:

1. exact equality with the selected SPEC-004 effective extent, region extent,
   row bytes, encoding, realization, submission lifetime, and handoff;
2. surface extent, packed width, stride, region geometry, and every checked
   byte product;
3. `requiredRasterBytes`, `requiredPayloadBytes`, `inFlightCount`, and
   `requiredInFlightBytes` against their corresponding local stores;
4. exact text resource compatibility and raster-view availability;
5. operation coverage for opaque rectangles, positioned text,
   straight-line strokes, clipping, and damage;
6. maximum per-payload region records, per-frame region submissions, tile
   visits, the greatest selected SPEC-005 glyph record byte count against
   `maximumGlyphRasterBytes`, and the selected canonical stroke algorithm's
   workspace for the B2-admitted maximum line width and surface extent against
   `maximumStrokeWorkspaceBytes`;
7. the display target's ability to hold one frame reservation and complete
   the selected bounded payload sequence without mid-frame backpressure; and
8. absence of any replay or retained Core-resource requirement.

The raster-backend contributor adapter reports only
`RasterBackendContribution` facts owned by its realization. The
surface/display adapter reports only `SurfaceDisplayContribution` facts owned
by its target. They use SPEC-004's exact vocabulary and failable initializers;
neither reports an end-to-end Boolean, probes the other concrete component, or
uses target identity. The host resolves them with the producer and policy
contributions and passes the immutable effective value back to this
integration for the exact equality checks above. Runtime health never changes
a contribution or effective value.

Every conforming backend contribution includes all five SPEC-004 operation
bits and `.synchronousBorrowedOneShot`. It advertises only encodings,
realizations, submission lifetimes, extents, regions, alignments, and byte
bounds the local implementation proves. A tiled realization under this
contract MUST advertise a synchronous handoff and either
`.synchronousBorrow` or `.synchronousCopy`; it MUST NOT advertise queued or
ownership-transfer tiled operation-major submission with one in-flight slot.
A full-surface realization may advertise any SPEC-004 lifetime/handoff pair
that its target implements.

For one offered header, checked pre-consumption work bounds are:

```text
damagedRows = header.damageBounds.size.height
damagedPixels = header.damageBounds.size.width * damagedRows
tileRows = ceil(damagedRows / descriptor.regionHeight)
tileVisits = header.operationCount * tileRows
regionSubmissions = header.operationCount * damagedPixels
```

The arithmetic uses nonnegative checked `UInt32` values. The final expression
is a conservative one-horizontal-run-per-covered-pixel ceiling, not a mandate
to emit single-pixel regions. Zero damage yields zero for all four values.
Because every submitted payload contains at least one region, the same
`maximumRegionSubmissionsPerFrame` also bounds payload submissions.
Construction evaluates the formula using
`RasterFrameSink.capacity.maximumOperations` and full-surface damage. Overflow
or a result above
`maximumTileVisitsPerFrame` or `maximumRegionSubmissionsPerFrame` rejects
construction. Before each `body`, the endpoint repeats it for the exact header;
because the header is already bounded by the constructed configuration, an
overflow or excess at that point is `.contractViolation`, not ordinary runtime
capacity exhaustion. A conforming implementation MAY prove a smaller
algorithm-specific upper bound from the immutable header and selected resource
package, but that proof and its tests become normative for that implementation
and may not inspect future borrowed operation values.

SPEC-012 point, Path, plan, and producer-operation capacities remain B2
structural facts and are not added to SPEC-004 or `RasterPayloadLimits`. The
host requires both that independent producer gate and the resolved
presentation path.

### Offer, reservation, and consumption

For each candidate, the endpoint verifies provenance/envelope, equality with
the immutable effective configuration, the checked header work bounds above,
and idle state. It then calls `reserveFrame` for exactly one selected payload
slot and its configured per-payload region records. It performs no operation
consumption before successful reservation.

Reservation results map exactly:

| Display reservation | SPEC-009 offer behavior |
| --- | --- |
| `reserved` | call body exactly once |
| `backpressured` | return `.backpressured` without body |
| `retryableRefusal` | return `.retryableRefusal` without body |
| `nonRetryableRefusal` | return `.nonRetryableRefusal` without body |
| `failure` | return `.failed(.contractViolation)` without body and preserve the exact display error; envelope validation has already completed |

During the one body call, the sink validates the exact header before mutation,
calls its selected `RasterSurface.beginFrame`, consumes every operation in
painter order, and derives pixels only into the active surface, the reusable
reserved payload slot, or backend-owned bounded workspace. It borrows glyph-
resource and stroke views only during their calls. Every covered logical pixel
is encoded exactly once per operation and is either written to the full
surface or coalesced into ordered horizontal regions.

The full-surface realization makes no irreversible effect while operations are
being consumed. On sink `finish`, it emits every affected full-width row from
the retained surface as regions in exactly one payload; zero damage emits no
payload. Startup therefore requires `maximumRegionsPerPayload` to admit the
maximum damaged row count. This one-payload rule supports every SPEC-004
compatible selected lifetime/handoff without a mid-frame slot-reuse question.

The tiled realization is operation-major. Before returning from each fill,
glyph, or stroke call, it visits every full-width row tile intersecting that
operation and the damage/clip, coalesces covered pixels into left-to-right
horizontal runs, and submits each finished bounded payload synchronously. It
clears or discards the reusable slot before the next payload. It never calls
the producer body again, revisits a prior borrowed operation, or retains a
glyph/stroke view. Later operations submit later regions and therefore replace
earlier pixels in exact painter order.

On `.complete`, producer `finish` has caused exactly one
`RasterSurface.finishFrame` and exactly one `DisplayTarget.finishFrame`; the
endpoint performs no second frame-end call and returns `.accepted`. If no
responsibility transferred and the body returns anything else, the endpoint
discards the surface and payload, calls `cancelFrame` exactly once, retains no
candidate data, and applies SPEC-009's exact body-result mapping. If
responsibility transferred at any point, all later local display/transport
failure is recorded as health; the sink continues accepting and validating
calls, the body is allowed to complete, and the endpoint returns `.accepted`
regardless of the later local fault.

Before responsibility transfer, the five `FrameStreamResult` values map
exactly as specified by SPEC-009. After responsibility transfer, every body
result maps to `.accepted`. A non-`.complete` result in that state preserves
its exact producer error, records the corresponding runtime-scoped
`.safetyNotProven` failure, quiesces before return, and safely abandons any
remaining physical work; it cannot be reported as refusal or frame failure.

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

Padding bytes in raster rows and the reusable payload slot are initialized
deterministically to zero and are not part of logical pixel comparison or a
horizontal region's `writtenBytes`. The descriptor preserves the selected
stride for storage accounting. Submitted regions are explicitly packed and
carry origin and pixel count, so their consumer never infers a row stride.

### Operational health and input eligibility

The display target owns current health for its presentation facility and
starts `.available` only after successful target initialization. Successful
frame sessions leave the current state unchanged. The first post-acceptance
transport/device failure in a frame records exactly one
`requiredFacilityUnavailable` failure with `.presentationIntegration` origin,
`.component` scope, and `.contained` containment and requests resulting state
`.unavailable`. A post-acceptance contract/invariant failure records exactly
one `.invariantViolation` with `.backend` origin, `.runtime` scope, and
`.safetyNotProven` containment and requests `.quiesced` before the offer
returns. Later faults in the same drained frame do not increment health again.
Recovery from `.degraded` or `.unavailable` is an explicit target-host
reinitialization decision outside this contract; an accepted frame alone does
not claim recovery. Any transition may then be projected diagnostically.

Health transitions do not modify capability results, semantic publication, or
the accepted frame disposition. The host consumes health to quiesce affected
presentation-coupled input according to SPEC-009 and total Wave 7 policy. The
backend does not invoke actions or mutate application state.

## State / Lifecycle

```text
idle
  -> reserved -> consuming <-> payload ready -> payload submitted
       |            |                               |
       |            +-------------------------------+
       |                    (zero or more payloads)
       +-> cancelled/refused -> idle

consuming -> frame finished/accepted -> idle
payload submitted -> responsibility transferred -> frame finished/accepted
                                           \-> degraded/unavailable health
```

Only one transition from a candidate reaches the SPEC-009 `accepted`
disposition. `cancelFrame` is legal only before responsibility transfer. Every
reservation ends in exactly one `finishFrame` or `cancelFrame`; it may contain
zero or more `submitPayload` calls. Every successful writer finish has exactly
one matching payload submission before the writer is reused. Teardown waits
for or safely abandons only display-owned in-flight payloads; no Core borrow
participates.

## Capability Requirements

The integration supplies contributor-owned facts, not a resolved Boolean. Its
raster-backend adapter must cover:

- `.opaqueRectangles`, `.positionedText`, `.straightLineStrokes`, `.clipping`,
  and `.damage` operation facts;
- synchronous one-shot operation lifetime;
- exact RGBA8888 or RGB565 encoding;
- logical extent and clip/damage behavior;
- full-surface or tiled realization;
- derived payload and glyph/stroke workspace bounds;
- maximum in-flight payloads;
- submission lifetime and handoff compatibility; and
- no retained Core-resource requirement.

The render producer, raster backend, surface/display, and host policy remain
four distinct SPEC-004 contributor roles. This contract owns only the raster
backend and surface/display adapters. Every adapter must construct the exact
approved contribution record and let SPEC-004 select the stable unavailable
reason. Any absent operation, incompatible resource, encoding mismatch,
insufficient extent/bound, or incompatible lifetime fails through that
resolver; no adapter repairs another role. Health and diagnostics are
excluded.

At integration construction, the selected effective value maps one-to-one:

| Effective field | Integration obligation |
| --- | --- |
| `operations` | all five required bits equal the sink's proven coverage |
| `extent` | descriptor bounds size |
| `regionExtent` | descriptor region width and height |
| `rowBytes` | descriptor stride |
| `operationStream` | `.synchronousBorrowedOneShot` |
| `encoding` | exact `CanonicalEncodedPixel` encoding |
| `submissionLifetime`, `handoff` | target session behavior |
| `realization` | full-surface or operation-major tiled strategy |
| `requiredRasterBytes` | writable raster/tile capacity required now |
| `requiredPayloadBytes` | capacity of the reusable payload slot |
| `inFlightCount`, `requiredInFlightBytes` | target-owned active-slot bound |

No field may be ignored, widened, or replaced with target identity. The macOS
dynamic and static fixtures must produce equal logical output. The Raspberry
Pi/Linux 240 x 240 fixture must admit a full-width 16-row RGB565 region. The
nRF52840 480 x 320 fixture must admit exactly a full-width four-row RGB565
region with 960-byte rows and 3,840-byte raster, payload, and in-flight
requirements and no full framebuffer.

## Backend Requirements

Every backend conforms to `RasterBackendEndpoint` and uses a sink conforming
to `RasterFrameSink`. Canvas-capable MVP backends must accept
`straightLineStroke`; an ordinary SPEC-008-only backend cannot satisfy the
Signal Analyzer capability requirement.

A full-surface backend owns one complete bounded encoded surface, applies all
operations there, and submits only after successful stream completion. An
operation-major tiled backend owns at most the selected full-width row-tile
workspace and one selected payload slot, processes all intersecting tiles
inside each operation call, and submits ordered horizontal regions
synchronously. A backend that invokes the producer once per tile, replays a
normalized operation, retains a glyph or stroke view for a later tile, or
requires a complete-frame display list is nonconforming.

For tiled submission, the target must support idempotence only at the payload-
writer staging boundary, not at the physical display. Earlier operation
regions may become visible before later ones. Once the first is submitted, any
later failure is accepted operational state and never a refusal. A target
whose selected transport can backpressure between tiled payloads cannot claim
this realization with one in-flight slot.

Recording conformance may store normalized value transcripts because it is a
test endpoint and never claims physical presentation. Production backends may
retain only derived payloads. Framebuffer mapping, SPI/DMA ownership, and
device-specific completion are implementation contracts below
`DisplayTarget` and cannot affect Core semantics.

## Error Handling

| Local error | condition | origin | scope | containment |
| --- | --- | --- | --- | --- |
| effective-value/component mismatch during construction | `.invariantViolation` | `.hostComposition` | `.runtime` | `.safetyNotProven` |
| construction-time checked bound overflow | `.arithmeticOverflow` | `.foundation` | `.runtime` | `.contained` |
| construction-time insufficient configured store/work limit | `.capacityExhausted` | `.hostComposition` | `.runtime` | `.contained` |
| `invalidEnvelope` or pre-body `invalidGeometry` | `.invalidValue` | `.backend` | `.candidateFrame` | `.contained` |
| `unsupportedOperation` or `incompatibleResource` after startup | `.invariantViolation` | `.backend` | `.runtime` | `.safetyNotProven` |
| operation-local geometry, arithmetic, or capacity failure after successful `begin` | `.invariantViolation` | `.backend` | `.runtime` | `.safetyNotProven` |
| `malformedStream`, `rasterizationFailure`, or post-begin sink refusal | `.invariantViolation` | `.backend` | `.runtime` | `.safetyNotProven` |
| `reentrancyViolation` during offer/reservation/writer use | `.reentrancyViolation` | `.backend` | `.runtime` | `.safetyNotProven` |
| post-acceptance `displayFailure` / `transportUnavailable` | `.requiredFacilityUnavailable` | `.presentationIntegration` | `.component` | `.contained` |
| display reservation/writer invariant | `.invariantViolation` | `.backend` | `.runtime` | `.safetyNotProven` |

The condition, origin, scope, and containment values above are the exact
SPEC-003 vocabulary. Adapters preserve the local `RasterBackendError` or
`DisplayTargetError` for correlation; this Specification introduces no new
failure identity.

At `reserveFrame`, `.backpressured`, `.retryableRefusal`, and
`.nonRetryableRefusal` are the only legal operational facility results.
Every constructible `failure` case maps to direct
`.failed(.contractViolation)` before `body` because successful construction
has already proven descriptor, arithmetic, capacity, and idle grammar. A
reservation MUST NOT return `failure(.transportUnavailable)`; it classifies
that current condition as the appropriate bounded refusal before `body`.

After a successful reservation, a transport/device fault from the first or a
later `submitPayload` or from `finishFrame` is always
`failureAfterAcceptance`; the reservation already promised a complete bounded
session, so the target may not reinterpret such a fault as pre-acceptance
refusal. `failureBeforeAcceptance` is reserved for writer/reservation grammar,
descriptor, or capacity invariants before the first submitted payload and
causes the sink to fail before output. Returning it after a completed payload
is itself `.invariantViolation` and cannot reopen disposition.

Detection order is: descriptor construction; exact effective-value equality;
resource compatibility; operation coverage; raster/payload/in-flight stores;
glyph/stroke workspace; per-frame checked work ceilings; reservation; envelope
and header equality; stream grammar; operation-local geometry/resource
validation; writer region grammar; payload completion; payload submission; and
frame completion. A later check cannot replace an earlier detected failure.
Once responsibility transfers, later checks only update health while the sink
continues to consume or safely drain.

Ordinary backpressure and retryable/non-retryable refusal are offer
dispositions, not `.failed`. Any runtime-scoped `safetyNotProven` fact
quiesces health before return as required by SPEC-003. Post-acceptance failure
updates health and diagnostics only. Diagnostics never determine reservation,
raster output, offer result, retry, or input admission.

## Performance Requirements

All storage and work are bounded by surface, operation, glyph, stroke, region,
tile-visit, region-submission, payload, and in-flight limits. Full-surface
raster cost is linear in affected pixels plus operation/resource work. Tiled
cost is linear in the admitted operation/tile intersections plus emitted
horizontal regions; startup rejects a configuration whose conservative or
implementation-proven ceilings exceed either per-frame limit.

The RGB565 tiled static fixture allocates zero heap bytes and links no task,
thread, exception, reflection, Objective-C, or hidden complete-frame buffer.
The framebuffer realization owns exactly its declared mapped surface plus
bounded raster workspace. Neither path retains a complete normalized display
list.

On every supported 32-bit and 64-bit compiler,
`CanonicalEncodedPixel` MUST occupy no more than 8 bytes,
`RasterSurfaceDescriptor` no more than 32 bytes,
`RasterPayloadLimits` no more than 40 bytes,
`DisplayReservationID` exactly 4 bytes, and each raw-value error enumeration
exactly 1 byte. No value may contain a reference, existential, closure,
dynamically growing collection, or pointer whose lifetime contributes to its
meaning. Protocol conformers and their caller-owned workspaces are excluded
from these value ceilings and are measured directly.

Evidence must report separately surface bytes, tile bytes, glyph workspace,
stroke workspace, region-record bytes, derived payload bytes, in-flight bytes,
display/transport bytes, tile visits, submitted regions, submitted payloads,
stack high-water, heap allocation, flash/text/rodata/data/BSS deltas, and
per-frame raster/submit time under the pinned toolchains. Reports identify the
header, damage, resource set, region geometry, compiler, optimization, and
warm-up/sample method. Static measurements include construction and one worst-
case frame and must record zero allocator calls.

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

The legacy `RGB565TileRenderer.renderTiles` closure-per-tile shape is not a
compatible implementation of this contract because it replays producer work.
Migration must replace that behavior with the operation-major region path; it
must not wrap the replay behind `RasterBackendEndpoint` or claim conformance
from existing tests. Existing framebuffer and ILI9341 adapters may be retained
only through narrow conformers that satisfy the exact descriptor, reservation,
region, lifetime, failure, and health rules above.

## Testing Requirements

The repository MUST provide `scripts/contracts/run-spec-014.sh`. From the
repository root it runs the same hardware-free corpus for macOS dynamic,
macOS static, Raspberry Pi ARMv6 compile/link, and nRF52840 Embedded Swift
compile/link modes, exits nonzero on any failed assertion, and writes generated
evidence only under `.build/spec-014/`.

`Tests/ContractFixtures/SPEC014/` MUST contain:

- `raster.yaml` for exact fills, glyphs, strokes, clipping, damage, encoding,
  strides, region segmentation, and cross-realization golden output;
- `transactions.yaml` for reservation, writer, payload, responsibility-
  transfer, body-result, cancellation, and identity-lifetime scripts;
- `capabilities.yaml` for exact SPEC-004 contribution/effective mappings and
  all four MVP configuration fixtures;
- `failures.yaml` for detection precedence, local-to-SPEC-003 mappings,
  health transitions, drain-after-transfer, and diagnostic isolation; and
- `resources.yaml` for limits, value layouts, storage ownership, allocation,
  stack, linked symbols, and timing conditions.

Every case records a stable fixture ID, descriptor, effective capability,
header, operation/resource input, injected target events, expected ordered
region transcript, expected encoded image, expected offer/body result,
expected health, and every high-water counter. Inapplicable fields use an
explicit `none`; omitted shared fields are invalid fixture data.

The corpus runs through:

- a canonical recording endpoint;
- a recording `RasterSurface` that checks exact
  begin/replace/finish/discard grammar;
- a full-surface RGBA8888 buffer;
- a full-surface/framebuffer RGB565 adapter; and
- bounded operation-major RGB565 tiled targets using the Pi 240 x 16 and
  nRF52840 480 x 4 selected regions.

Tests must cover:

- exact fills, glyph resource identity/positions, clips, damage, painter order,
  and every SPEC-012 stroke vector;
- RGB boundary values `0`, `1`, `127`, `128`, `254`, and `255`;
- odd strides, partial edge tiles, empty intersections, negative logical
  geometry, every clip edge, and checked byte overflow;
- exact limit and first-excess for surface, region/tile, glyph, stroke, payload
  bytes, regions per payload, region submissions per frame, tile visits per
  frame, and in-flight capacity;
- exact descriptor/effective-value equality and one-field mismatch for every
  SPEC-004 field;
- backpressure and each refusal/failure mapping before body invocation;
- complete, producer-failed, capacity, endpoint-refused, and contract-violation
  body mappings;
- zero-, one-, and multiple-payload sessions; exact one finish-or-cancel per
  reservation; checked identity exhaustion; and slot reuse only after submit;
- writer underflow, overflow, empty finish, double finish, double submit,
  submit-without-finish, stale reservation, region row crossing, wrong
  encoding, and reentrancy;
- tiled operation-major ordering with exactly one producer-body call and one
  call per borrowed fill/glyph/stroke, including later-operation overwrite
  across region and tile boundaries;
- borrow poisoning and address capture proving no Core value or resource view
  survives offer;
- failure before the first payload preserving abortability; failure on the
  first and later payload leaving the logical frame committed, draining the
  stream, and updating health exactly once;
- capability negative matrices for operation, resource, encoding, extent,
  bound, lifetime, and handoff incompatibility; and
- dependency tests rejecting semantic/layout/runtime imports below the
  backend boundary and concrete integrations above it.

Golden pixel masks and encoded bytes have zero tolerance. Hardware-free tests
are required for approval. Connected framebuffer, PiScreen, nRF52840 TFT, and
transport evidence belongs to later conformance and must identify actual
hardware separately.

## Acceptance Criteria

- [ ] **BI-001:** Import-graph fixtures preserve separate surface, raster,
  display, backend-integration, runtime, and host ownership and reject every
  prohibited edge named in Module Contract.
- [ ] **BI-002:** Each of the four MVP configuration fixtures constructs the
  exact SPEC-004 contributions and selected effective value; every one-field
  mismatch rejects construction before the first offer without target probing.
- [ ] **BI-003:** The nRF52840 fixture reports a 480 x 320 surface, 480 x 4
  region, 960-byte stride, and exactly 3,840 raster, payload, and in-flight
  bytes with one slot and no full framebuffer.
- [ ] **BI-004:** Every valid candidate completes all checked header bounds and
  reserves one complete frame session before `body`; every reservation ends in
  exactly one `finishFrame` or `cancelFrame`.
- [ ] **BI-005:** Transaction fixtures prove zero-, one-, and multi-payload
  grammar, one submit per successful writer finish, exact slot reuse, and
  rejection of every stale, duplicate, underflow, overflow, row-crossing,
  encoding, and reentrancy case.
- [ ] **BI-006:** The tiled Pi and nRF52840 fixtures call the producer body
  exactly once, call each borrowed operation exactly once, retain no borrowed
  address, use no replay/display list/full framebuffer, and remain within the
  selected region and payload high-water marks.
- [ ] **BI-007:** Recording, RGBA8888 full-surface, RGB565 framebuffer, Pi
  tiled, and nRF52840 tiled fixtures produce identical logical affected pixels
  and exact canonical bytes with zero differing pixels or channels.
- [ ] **BI-008:** Exact SPEC-005 resource fixtures prove that no backend
  reshapes, remeasures, substitutes, repositions, or retains text resources.
- [ ] **BI-009:** Every SPEC-012 canonical stroke vector produces the exact
  approved coverage and encoding across full-surface and tiled realizations
  with zero pixel or byte tolerance.
- [ ] **BI-010:** Every pre-body backpressure/refusal/failure and every body
  result produces the exact SPEC-009 call count, `FrameOfferResult`, retained
  local error, discard/cancel behavior, and logical disposition.
- [ ] **BI-011:** Faults before responsibility transfer produce no irreversible
  effect; faults on or after the first submitted payload force accepted
  disposition, drain the one-shot stream, record health exactly once, and
  never mutate the immutable capability result.
- [ ] **BI-012:** Equality succeeds and first excess fails deterministically
  for every byte, count, identity, region, tile-visit, submission, glyph,
  stroke, and in-flight limit in the stated detection order.
- [ ] **BI-013:** All normative value sizes meet their ceilings; static RGB565
  construction and worst-case-frame evidence records zero heap allocations and
  links no forbidden runtime facility.
- [ ] **BI-014:** Borrow-poisoning and post-offer address scans find no retained
  operation, glyph, resource view, Path snapshot, stroke view, producer
  closure, sink borrow, or Core address after accepted, refused, and failed
  attempts.
- [ ] **BI-015:** `scripts/contracts/run-spec-014.sh` reproduces the complete
  fixture, dependency, resource, and timing evidence under the pinned MVP
  toolchains and writes no generated artifact outside `.build/spec-014/`.

## Implementation Notes

The tiled realization is operation-major, not producer-replay tile-major. A
practical implementation may keep one selected full-width row-tile workspace,
coalesce covered pixels into the longest convenient horizontal runs, and
flush the reusable payload slot whenever its byte or region capacity would be
exceeded. Segmentation is non-observable when region order and final pixels
remain exact and the declared bounds are honored.

The recording endpoint should record normalized logical payloads rather than
pixels; the raster fixtures should consume the same operation source and
compare final encoded surfaces.

## Open Issues

No unresolved contract or architectural issue remains in this Specification.
Production surface, region, payload, per-frame work, and in-flight values are
Wave 7 HOST-CONFIGURATION inputs and are intentionally not selected here.

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
- [ADR-005](../adrs/adr-005-semantic-layout-render-boundary.md)
- [ADR-006](../adrs/adr-006-shared-semantics-runtime-profiles.md)
- [ADR-007](../adrs/adr-007-integration-ownership-and-host-composition.md)
- [ADR-008](../adrs/adr-008-module-dependency-graph-and-package-topology.md)
- [ADR-009](../adrs/adr-009-checked-integer-geometry.md)
- [ADR-010](../adrs/adr-010-synchronous-one-shot-frame-handoff.md)
- [ADR-014](../adrs/adr-014-bounded-cross-layer-outcomes.md)
- [ADR-015](../adrs/adr-015-layered-failure-disposition.md)
- [ADR-016](../adrs/adr-016-non-authoritative-diagnostics.md)
- [ADR-017](../adrs/adr-017-capability-and-operational-state-planes.md)
- [ADR-018](../adrs/adr-018-fixture-driven-typed-capabilities.md)
- [ADR-019](../adrs/adr-019-bounded-host-capability-resolution.md)
- [ADR-020](../adrs/adr-020-raster-presentation-capability.md)
- [ADR-021](../adrs/adr-021-canonical-text-geometry.md)
- [ADR-022](../adrs/adr-022-positioned-glyph-render-operation.md)
- [ADR-023](../adrs/adr-023-exact-font-resource-identity.md)
- [ADR-030](../adrs/adr-030-canonical-normalized-straight-line-stroke-operation.md)
- [ADR-031](../adrs/adr-031-bounded-canvas-failure-and-startup-gate-integration.md)
- [SPEC-001](spec-001-signal-analyzer-reference-application.md) (`approved`;
  downstream coordination)
- [SPEC-002](spec-002-portable-foundation.md)
- [SPEC-003](spec-003-failure-outcomes-and-containment.md)
- [SPEC-004](spec-004-capability-contribution-and-resolution.md)
- [SPEC-005](spec-005-text-resources.md)
- [SPEC-008](spec-008-rendering.md)
- [SPEC-009](spec-009-execution-cycle-and-frame-handoff.md)
- [SPEC-012](spec-012-canvas-path-stroke-drawing.md)
- [SPEC-013](spec-013-runtime-profiles.md) (coordination only)
- [SPIKE-001](../spikes/spike-001-tiled-one-shot-capability-fixtures.md)
- [SPIKE-002](../spikes/spike-002-nrf52840-capability-path-resource-evidence.md)
- [SPIKE-004](../spikes/spike-004-canvas-path-plan-feasibility.md)
