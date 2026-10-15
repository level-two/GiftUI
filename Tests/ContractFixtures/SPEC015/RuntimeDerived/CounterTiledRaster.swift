#if hasFeature(Embedded) || GIFTUI_COUNTER_TILED
import GiftUI
import GiftUICapabilities
import GiftUIBackendIntegration
import GiftUIDisplayCore
import GiftUIExecution
import GiftUIFailureCore
import GiftUIHostConfiguration
import GiftUIRasterCore
import GiftUIReferenceTextResources
import GiftUIRenderCore
import GiftUISurfaceCore
import GiftUITextResources

// The existing control owns one tile and coverage bank. No payload copy is kept.
// Native validation alone retains a display observation, excluded from firmware.
struct CounterTiledBackendStorage {
    var tile: InlineArray<800, UInt8> = .init(repeating: 0)
    var coverage: InlineArray<50, UInt8> = .init(repeating: 0)
    #if !hasFeature(Embedded)
    var displayed: InlineArray<24000, UInt8> = .init(repeating: 0)
    #endif
    var write: CounterTiledPixelWrite?
    var health = GiftUIOperationalHealth()
    var endpointHealthObservation = GiftUIOperationalHealth()
    var constructedProjection: HostEndpointConfiguration?
    var constructedEndpoints = 0
    var projectionControls = 0
    var envelopeRejections = 0
    var reservations = 0
    var submissions = 0
    var finishes = 0
    var cancellations = 0
    var active = false
    var submittedBytes: UInt32 = 0
    var submittedRows: UInt32 = 0
}
// Borrow only the original typed backend field and return owned scalar facts.
// No whole Control/backend copy, inout mutation or callback spans this read.
func counterObserveBackend(_ backend: borrowing CounterTiledBackendStorage) -> CounterBackendObservation {
    .init(active: backend.active, reservations: backend.reservations,
        submissions: backend.submissions, finishes: backend.finishes,
        cancellations: backend.cancellations, submittedBytes: backend.submittedBytes,
        submittedRows: backend.submittedRows, health: backend.health,
        endpointHealthObservation: backend.endpointHealthObservation,
        constructedProjection: backend.constructedProjection,
        constructedEndpoints: backend.constructedEndpoints,
        projectionControls: backend.projectionControls, envelopeRejections: backend.envelopeRejections)
}

struct CounterTileStorage: RGB565TileStorage {
    let control: UnsafeMutablePointer<CounterControl>
    var byteCapacity: UInt32 { 800 }
    var pixelCapacity: UInt32 { 400 }
    mutating func reset(byteCount: UInt32, pixelCount: UInt32) -> Bool {
        guard byteCount <= byteCapacity, pixelCount <= pixelCapacity else { return false }
        for index in 0..<Int(byteCount) { control.pointee.backend.tile[index] = 0 }
        for index in 0..<50 { control.pointee.backend.coverage[index] = 0 }
        return true
    }
    mutating func store(mostSignificantByte: UInt8, leastSignificantByte: UInt8, byteOffset: UInt32, pixelIndex: UInt32) -> Bool {
        guard byteOffset <= byteCapacity - 2, pixelIndex < pixelCapacity else { return false }
        control.pointee.backend.tile[Int(byteOffset)] = mostSignificantByte
        control.pointee.backend.tile[Int(byteOffset) + 1] = leastSignificantByte
        control.pointee.backend.coverage[Int(pixelIndex / 8)] |= UInt8(1) << UInt8(pixelIndex % 8)
        return true
    }
    borrowing func isAffected(pixelIndex: UInt32) -> Bool {
        guard pixelIndex < pixelCapacity else { return false }
        return control.pointee.backend.coverage[Int(pixelIndex / 8)] & (UInt8(1) << UInt8(pixelIndex % 8)) != 0
    }
    borrowing func byte(at offset: UInt32) -> UInt8? { offset < byteCapacity ? control.pointee.backend.tile[Int(offset)] : nil }
    borrowing func withBorrowedRun<R>(byteOffset: UInt32, byteCount: UInt32, _ body: (UnsafeRawBufferPointer) -> R) -> R? {
        guard byteCount > 0, byteOffset < byteCapacity, byteCount <= byteCapacity - byteOffset else { return nil }
        return withUnsafeBytes(of: &control.pointee.backend.tile) { bytes in
            body(UnsafeRawBufferPointer(rebasing: bytes[Int(byteOffset)..<Int(byteOffset + byteCount)]))
        }
    }
}
struct CounterTileWriter: DisplayPayloadWriter {
    let control: UnsafeMutablePointer<CounterControl>
    let capacityBytes: UInt32 = 800
    let regionCapacity: UInt16 = 1
    var writtenBytes: UInt32 = 0
    var writtenRegionCount: UInt16 = 0
    var origin: Point?
    var pixels: UInt16 = 0
    var remaining: UInt32 = 0
    var completed = false
    mutating func beginRegion(origin: Point, pixelCount: UInt16, encoding: CanonicalPixelEncoding) -> Bool {
        guard !completed, self.origin == nil, remaining == 0, writtenRegionCount == 0,
            encoding == .rgb565BigEndian, pixelCount > 0, origin.x >= 0, origin.y >= 0,
            origin.x < 100, origin.y < 120, Int32(pixelCount) <= 100 - origin.x else { return false }
        self.origin = origin; pixels = pixelCount; remaining = UInt32(pixelCount) * 2
        return remaining <= capacityBytes
    }
    mutating func write(byte: UInt8) -> Bool {
        guard !completed, remaining > 0, writtenBytes < capacityBytes else { return false }
        control.pointee.backend.tile[Int(writtenBytes)] = byte
        writtenBytes += 1; remaining -= 1; return true
    }
    mutating func endRegion() -> Bool {
        guard !completed, origin != nil, remaining == 0, writtenBytes == UInt32(pixels) * 2 else { return false }
        writtenRegionCount = 1; return true
    }
    mutating func finish() -> Bool {
        guard !completed, writtenRegionCount == 1, remaining == 0 else { return false }
        completed = true; return true
    }
    mutating func discard() { writtenBytes = 0; writtenRegionCount = 0; origin = nil; pixels = 0; remaining = 0; completed = false }
}
struct CounterTiledDisplayTarget: DisplayTarget {
    let control: UnsafeMutablePointer<CounterControl>
    let configuration: HostEndpointConfiguration
    var writer: CounterTileWriter
    let submissionLifetime: SubmissionLifetime = .synchronousBorrow
    let handoff: SubmissionHandoff = .synchronous
    let maximumInFlightPayloads: UInt8 = 1
    let maximumInFlightBytes: UInt32 = 800
    mutating func reserveFrame(descriptor: RasterSurfaceDescriptor, payloadCapacityBytes: UInt32, regionCapacity: UInt16) -> DisplayReservationResult {
        guard !control.pointee.backend.active else { return .failure(.reentrancyViolation) }
        guard descriptor == configuration.descriptor, payloadCapacityBytes == maximumInFlightBytes, regionCapacity == 1 else { return .failure(.invalidDescriptor) }
        control.pointee.backend.reservations += 1
        switch control.pointee.offer {
        case .backpressured:
            control.pointee.backend.health.recordOperational(.init(kind: .backpressured, origin: .displayDriver, affectedScope: .candidateFrame), resultingState: .degraded)
            return .backpressured
        case .retryableRefusal: return .retryableRefusal
        case .nonRetryableRefusal: return .nonRetryableRefusal
        case .failed: return .failure(.invalidDescriptor)
        case .accepted: break
        }
        writer.discard(); control.pointee.backend.active = true
        control.pointee.backend.submittedBytes = 0; control.pointee.backend.submittedRows = 0
        return .reserved(.init(rawValue: UInt32(control.pointee.backend.reservations)))
    }
    mutating func withWriter<R>(for reservation: DisplayReservationID, _ body: (inout CounterTileWriter) -> R) -> R? {
        guard control.pointee.backend.active, reservation.rawValue == UInt32(control.pointee.backend.reservations) else { return nil }
        return body(&writer)
    }
    mutating func submitPayload(_ reservation: DisplayReservationID) -> DisplayTransferResult {
        guard control.pointee.backend.active, reservation.rawValue == UInt32(control.pointee.backend.reservations), writer.completed, let origin = writer.origin else { return .failureBeforeAcceptance(.invalidReservation) }
        #if !hasFeature(Embedded)
        let offset = (Int(origin.y) * 100 + Int(origin.x)) * 2
        for index in 0..<Int(writer.writtenBytes) { control.pointee.backend.displayed[offset + index] = control.pointee.backend.tile[index] }
        #endif
        if let write = control.pointee.backend.write {
            let result = withUnsafeBytes(of: &control.pointee.backend.tile) { bytes in
                write(UInt16(origin.x), UInt16(origin.y), writer.pixels, 1, bytes.baseAddress!.assumingMemoryBound(to: UInt8.self), Int(writer.writtenBytes))
            }
            if result != 0 {
                control.pointee.backend.health.recordFailure(.init(condition: .requiredFacilityUnavailable, origin: .presentationIntegration, affectedScope: .component, containment: .contained), resultingState: .unavailable)
                writer.discard()
                return .failureAfterAcceptance(.transportUnavailable)
            }
        }
        control.pointee.backend.submittedBytes += writer.writtenBytes
        control.pointee.backend.submittedRows += 1; control.pointee.backend.submissions += 1
        writer.discard(); return .completed
    }
    mutating func finishFrame(_ reservation: DisplayReservationID) -> DisplayTransferResult {
        guard control.pointee.backend.active, reservation.rawValue == UInt32(control.pointee.backend.reservations), !writer.completed else { return .failureBeforeAcceptance(.invalidReservation) }
        control.pointee.backend.active = false; control.pointee.backend.finishes += 1; return .completed
    }
    mutating func cancelFrame(_ reservation: DisplayReservationID) { writer.discard(); control.pointee.backend.active = false; control.pointee.backend.cancellations += 1 }
    borrowing func health() -> GiftUIOperationalHealth { control.pointee.backend.health }
}
typealias CounterTiledSession = OperationMajorRGB565RasterSession<CounterTileStorage, CounterTiledDisplayTarget, GiftUIReferenceTextMetricsView, GiftUIReferenceTextRasterView>
struct CounterTiledRasterAdapter: RasterOfferSessionSink {
    var session: CounterTiledSession
    var recording = CounterRenderSink()
    var capacity: RenderSinkCapacity { session.capacity }
    var descriptor: RasterSurfaceDescriptor { session.descriptor }
    var payloadLimits: RasterPayloadLimits { session.payloadLimits }
    var failure: RasterBackendError? { session.failure }
    var streamCompleted: Bool { session.streamCompleted }
    var presentationResponsibilityAccepted: Bool { session.presentationResponsibilityAccepted }
    var retainedProducerError: RenderProductionError? { session.retainedProducerError }
    var isIdleForOffer: Bool { session.isIdleForOffer }
    mutating func retainProducerError(_ error: RenderProductionError) { session.retainProducerError(error) }
    mutating func reserveFrame(descriptor: RasterSurfaceDescriptor, payloadCapacityBytes: UInt32, regionCapacity: UInt16) -> DisplayReservationResult { session.reserveFrame(descriptor: descriptor, payloadCapacityBytes: payloadCapacityBytes, regionCapacity: regionCapacity) }
    mutating func cancelReservedFrame() { session.cancelReservedFrame() }
    mutating func finishTransferredFrameIfNeeded() { session.finishTransferredFrameIfNeeded() }
    borrowing func health() -> GiftUIOperationalHealth { session.health() }
    mutating func begin(_ header: RenderPlanHeader) -> Bool { recording = CounterRenderSink(); return session.begin(header) && recording.begin(header) }
    mutating func fillRect(_ operation: FillRectOperation) -> Bool { session.fillRect(operation) && recording.fillRect(operation) }
    mutating func beginPositionedGlyphs(_ operation: PositionedGlyphOperationHeader) -> Bool { session.beginPositionedGlyphs(operation) && recording.beginPositionedGlyphs(operation) }
    mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool { session.positionedGlyph(glyph) && recording.positionedGlyph(glyph) }
    mutating func endPositionedGlyphs() -> Bool { session.endPositionedGlyphs() && recording.endPositionedGlyphs() }
    mutating func straightLineStroke<S: StraightLineStrokeView>(_ stroke: borrowing S) -> Bool {
        guard session.straightLineStroke(stroke) else { return false }
        return recording.straightLineStroke(stroke)
    }
    mutating func finish() -> Bool { session.finish() && recording.finish() }
    mutating func discard() { session.discard(); recording.discard() }
}
struct CounterTiledEnvelope: RasterFrameEnvelopeValidator {
    let expected: FrameProvenance?
    borrowing func accepts(_ provenance: FrameProvenance) -> Bool { expected == provenance }
}
typealias CounterTiledEndpoint = OneShotRasterBackendEndpoint<CounterTiledRasterAdapter, GiftUIReferenceTextMetricsView, GiftUIReferenceTextRasterView, CounterTiledEnvelope>
struct CounterEndpoint: SynchronousFrameEndpoint {
    var actual: CounterTiledEndpoint
    let control: UnsafeMutablePointer<CounterControl>
    var sink: CounterRenderSink { actual.sink.recording }
    init(configuration: HostEndpointConfiguration, control: UnsafeMutablePointer<CounterControl>) {
        let construction = CounterConstructionInputs.canonical
        let configuration = construction.endpointConfiguration.configuration(configuration)
        let control = construction.endpointBacking.control(control)
        self.control = control
        let target = CounterTiledDisplayTarget(control: control, configuration: configuration, writer: CounterTileWriter(control: control))
        let session = CounterTiledSession(capacity: CounterRenderSink().capacity, descriptor: configuration.descriptor, payloadLimits: configuration.payloadLimits, metrics: construction.text.metrics(), raster: construction.text.raster(), realization: construction.text.realization, storage: CounterTileStorage(control: control), target: target)!
        let constructed = HostEndpointConfiguration(effectivePresentation: configuration.effectivePresentation, descriptor: session.descriptor, payloadLimits: session.payloadLimits, surfaceWritableCapacityBytes: 800, displaySubmissionLifetime: target.submissionLifetime, displayHandoff: target.handoff, displayMaximumInFlightPayloads: target.maximumInFlightPayloads, displayMaximumInFlightBytes: target.maximumInFlightBytes, textRasterRealization: construction.text.realization, healthOwnerCount: 1, endpointAndDisplayShareHealthOwner: target.control == control)
        precondition(HostEndpointStartupValidation.validateConstructedProjection(constructed, equals: configuration) == nil)
        let capacities: InlineArray<3, UInt32> = [799,800,801]
        for index in 0..<capacities.count {
            let capacity = capacities[index]
            let candidate = HostEndpointConfiguration(effectivePresentation: constructed.effectivePresentation, descriptor: constructed.descriptor, payloadLimits: constructed.payloadLimits, surfaceWritableCapacityBytes: capacity, displaySubmissionLifetime: constructed.displaySubmissionLifetime, displayHandoff: constructed.displayHandoff, displayMaximumInFlightPayloads: constructed.displayMaximumInFlightPayloads, displayMaximumInFlightBytes: constructed.displayMaximumInFlightBytes, textRasterRealization: constructed.textRasterRealization, healthOwnerCount: 1, endpointAndDisplayShareHealthOwner: true)
            precondition(HostEndpointStartupValidation.validateConstructedProjection(candidate, equals: configuration) == (capacity == 800 ? nil : .invalidEndpointDescriptor)); control.pointee.backend.projectionControls += 1
        }
        for shared in [true,false] {
            let candidate = HostEndpointConfiguration(effectivePresentation: constructed.effectivePresentation, descriptor: constructed.descriptor, payloadLimits: constructed.payloadLimits, surfaceWritableCapacityBytes: 800, displaySubmissionLifetime: constructed.displaySubmissionLifetime, displayHandoff: constructed.displayHandoff, displayMaximumInFlightPayloads: constructed.displayMaximumInFlightPayloads, displayMaximumInFlightBytes: constructed.displayMaximumInFlightBytes, textRasterRealization: constructed.textRasterRealization, healthOwnerCount: shared ? 2 : 1, endpointAndDisplayShareHealthOwner: shared)
            precondition(HostEndpointStartupValidation.validateConstructedProjection(candidate, equals: configuration) == .invalidEndpointDescriptor); control.pointee.backend.projectionControls += 1
        }
        control.pointee.backend.constructedProjection = constructed; control.pointee.backend.constructedEndpoints += 1
        actual = CounterTiledEndpoint(effectivePresentation: configuration.effectivePresentation, descriptor: configuration.descriptor, payloadLimits: configuration.payloadLimits, textMetrics: construction.text.metrics(), textRaster: construction.text.raster(), textRasterRealization: construction.text.realization, envelopeValidator: CounterTiledEnvelope(expected: nil), sink: CounterTiledRasterAdapter(session: session), startupFailure: nil)!
    }
    var ownedObservation: CounterEndpointObservation {
        .init(effectivePresentation: actual.effectivePresentation, descriptor: actual.descriptor,
            payloadLimits: actual.payloadLimits, realization: actual.textRasterRealization,
            bodyCalls: actual.bodyCallCount, reservations: actual.reservationCallCount,
            displayError: actual.lastDisplayError, producerError: actual.retainedProducerError,
            capacity: actual.sink.capacity, sinkDescriptor: actual.sink.descriptor,
            sinkLimits: actual.sink.payloadLimits, sinkFailure: actual.sink.failure,
            streamCompleted: actual.sink.streamCompleted,
            presentationAccepted: actual.sink.presentationResponsibilityAccepted,
            sinkProducerError: actual.sink.retainedProducerError, idle: actual.sink.isIdleForOffer,
            health: actual.health(), recording: CounterRecordingObservation(sink),
            targetConfiguration: actual.sink.session.target.configuration, writer: CounterWriterObservation(bytes: actual.sink.session.target.writer.writtenBytes,
                regions: actual.sink.session.target.writer.writtenRegionCount,
                origin: actual.sink.session.target.writer.origin, pixels: actual.sink.session.target.writer.pixels,
                remaining: actual.sink.session.target.writer.remaining, completed: actual.sink.session.target.writer.completed),
            nativeReservation: nil, nativeGlyphHeader: nil)
    }
    var isIdleForRuntimeRelease: Bool { actual.sink.isIdleForOffer }
    mutating func offer(provenance: FrameProvenance, body: (inout CounterTiledRasterAdapter) -> FrameStreamResult) -> FrameOfferResult {
        offerAndObserve(provenance: provenance, body: body).result
    }
    mutating func offerAndObserve(provenance: FrameProvenance, body: (inout CounterTiledRasterAdapter) -> FrameStreamResult) -> CounterEndpointOfferObservation {
        precondition(actual.replaceEnvelopeValidator(CounterTiledEnvelope(expected: nil)))
        let reservations = actual.reservationCallCount; let bodies = actual.bodyCallCount
        let invalid = actual.offer(provenance: provenance) { _ in preconditionFailure("invalid counter envelope invoked producer") }
        precondition(invalid == .init(disposition: .failed, failure: .invalidEnvelope)!)
        precondition(actual.reservationCallCount == reservations && actual.bodyCallCount == bodies)
        precondition(actual.replaceEnvelopeValidator(CounterTiledEnvelope(expected: provenance)))
        let result = actual.offer(provenance: provenance, body: body)
        return .init(result: result, invalidEnvelopeRejections: 1, health: actual.health(),
            acceptedRecording: result.disposition == .accepted ? sink : nil)
    }
}
#endif
