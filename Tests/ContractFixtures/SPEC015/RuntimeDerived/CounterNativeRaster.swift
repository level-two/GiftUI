#if !hasFeature(Embedded) && !GIFTUI_COUNTER_TILED
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

// Finite native fixture backing. Both arrays are physically charged with the
// enclosing control; neither endpoint nor display constructs another health owner.
struct CounterNativeBackendStorage {
    var surface: InlineArray<48000, UInt8> = .init(repeating: 0)
    var payload: InlineArray<48000, UInt8> = .init(repeating: 0xA5)
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
    var submittedRows: UInt16 = 0
    init() { for index in 0..<12000 { surface[index * 4 + 3] = 255 } }
}
// Borrow only the original typed backend field and return owned scalar facts.
// No whole Control/backend copy, inout mutation or callback spans this read.
func counterObserveBackend(_ backend: borrowing CounterNativeBackendStorage) -> CounterBackendObservation {
    .init(active: backend.active, reservations: backend.reservations,
        submissions: backend.submissions, finishes: backend.finishes,
        cancellations: backend.cancellations, submittedBytes: backend.submittedBytes,
        submittedRows: UInt32(backend.submittedRows), health: backend.health,
        endpointHealthObservation: backend.endpointHealthObservation,
        constructedProjection: backend.constructedProjection,
        constructedEndpoints: backend.constructedEndpoints,
        projectionControls: backend.projectionControls, envelopeRejections: backend.envelopeRejections)
}

struct CounterRGBAStorage: FullSurfaceRGBA8888Storage {
    let control: UnsafeMutablePointer<CounterControl>
    var capacityBytes: UInt32 { 48000 }
    mutating func store(byte0: UInt8, byte1: UInt8, byte2: UInt8, byte3: UInt8, at offset: UInt32) -> Bool {
        guard offset <= capacityBytes - 4 else { return false }
        let index = Int(offset)
        control.pointee.backend.surface[index] = byte0
        control.pointee.backend.surface[index + 1] = byte1
        control.pointee.backend.surface[index + 2] = byte2
        control.pointee.backend.surface[index + 3] = byte3
        return true
    }
    borrowing func withBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        try withUnsafeBytes(of: &control.pointee.backend.surface, body)
    }
}
struct CounterNativePayloadWriter: DisplayPayloadWriter {
    let control: UnsafeMutablePointer<CounterControl>
    let capacityBytes: UInt32 = 48000
    let regionCapacity: UInt16 = 120
    var writtenBytes: UInt32 = 0
    var writtenRegionCount: UInt16 = 0
    var remaining: UInt32 = 0
    var completed = false
    mutating func beginRegion(origin: Point, pixelCount: UInt16, encoding: CanonicalPixelEncoding) -> Bool {
        guard !completed, remaining == 0, writtenRegionCount < regionCapacity,
            origin == Point(x: 0, y: GeometryScalar(writtenRegionCount)), pixelCount == 100,
            encoding == .rgba8888 else { return false }
        remaining = UInt32(pixelCount) * 4
        return writtenBytes + remaining <= capacityBytes
    }
    mutating func write(byte: UInt8) -> Bool {
        guard !completed, remaining > 0, writtenBytes < capacityBytes else { return false }
        control.pointee.backend.payload[Int(writtenBytes)] = byte
        writtenBytes += 1; remaining -= 1; return true
    }
    mutating func endRegion() -> Bool {
        guard !completed, remaining == 0 else { return false }
        writtenRegionCount += 1; return true
    }
    mutating func finish() -> Bool {
        guard !completed, remaining == 0, writtenBytes == capacityBytes, writtenRegionCount == regionCapacity else { return false }
        completed = true
        control.pointee.backend.submittedBytes = writtenBytes
        control.pointee.backend.submittedRows = writtenRegionCount
        return true
    }
    mutating func discard() { completed = false; remaining = 0; writtenBytes = 0; writtenRegionCount = 0 }
}
struct CounterNativeDisplayTarget: DisplayTarget {
    let control: UnsafeMutablePointer<CounterControl>
    let configuration: HostEndpointConfiguration
    let submissionLifetime: SubmissionLifetime = .synchronousBorrow
    let handoff: SubmissionHandoff = .synchronous
    let maximumInFlightPayloads: UInt8 = 1
    let maximumInFlightBytes: UInt32 = 48000
    mutating func reserveFrame(descriptor: RasterSurfaceDescriptor, payloadCapacityBytes: UInt32, regionCapacity: UInt16) -> DisplayReservationResult {
        guard !control.pointee.backend.active else { return .failure(.reentrancyViolation) }
        guard descriptor == configuration.descriptor, payloadCapacityBytes == maximumInFlightBytes,
            regionCapacity == 120 else { return .failure(.invalidDescriptor) }
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
        control.pointee.backend.active = true
        control.pointee.backend.submittedBytes = 0; control.pointee.backend.submittedRows = 0
        return .reserved(.init(rawValue: UInt32(control.pointee.backend.reservations)))
    }
    mutating func withWriter<R>(for reservation: DisplayReservationID, _ body: (inout CounterNativePayloadWriter) -> R) -> R? {
        guard control.pointee.backend.active, reservation.rawValue == UInt32(control.pointee.backend.reservations) else { return nil }
        var writer = CounterNativePayloadWriter(control: control)
        return body(&writer)
    }
    mutating func submitPayload(_ reservation: DisplayReservationID) -> DisplayTransferResult {
        guard control.pointee.backend.active, reservation.rawValue == UInt32(control.pointee.backend.reservations),
            control.pointee.backend.submittedBytes == 48000, control.pointee.backend.submittedRows == 120 else { return .failureBeforeAcceptance(.invalidReservation) }
        control.pointee.backend.submissions += 1; return .completed
    }
    mutating func finishFrame(_ reservation: DisplayReservationID) -> DisplayTransferResult {
        guard control.pointee.backend.active, reservation.rawValue == UInt32(control.pointee.backend.reservations) else { return .failureBeforeAcceptance(.invalidReservation) }
        control.pointee.backend.active = false; control.pointee.backend.finishes += 1; return .completed
    }
    mutating func cancelFrame(_ reservation: DisplayReservationID) {
        guard control.pointee.backend.active else { return }
        control.pointee.backend.active = false; control.pointee.backend.cancellations += 1
    }
    borrowing func health() -> GiftUIOperationalHealth { control.pointee.backend.health }
}

// Only an adapter: all pixel coverage, storage validation and payload transfer
// are performed by the existing maintained full-surface components.
struct CounterNativeRasterAdapter: RasterOfferSessionSink {
    let capacity = CounterRenderSink().capacity
    let descriptor: RasterSurfaceDescriptor
    let payloadLimits: RasterPayloadLimits
    var target: CounterNativeDisplayTarget
    var surface: FullSurfaceRGBA8888Buffer<CounterRGBAStorage>
    var recording = CounterRenderSink()
    var failure: RasterBackendError?
    var retainedProducerError: RenderProductionError?
    var streamCompleted = false
    var presentationResponsibilityAccepted = false
    var reservation: DisplayReservationID?
    var glyphHeader: PositionedGlyphOperationHeader?
    var isIdleForOffer: Bool { reservation == nil && recording.header == nil }
    init(configuration: HostEndpointConfiguration, control: UnsafeMutablePointer<CounterControl>) {
        descriptor = configuration.descriptor; payloadLimits = configuration.payloadLimits
        target = CounterNativeDisplayTarget(control: control, configuration: configuration)
        surface = FullSurfaceRGBA8888Buffer(descriptor: descriptor, storage: CounterRGBAStorage(control: control))!
    }
    mutating func retainProducerError(_ error: RenderProductionError) { if retainedProducerError == nil { retainedProducerError = error } }
    mutating func reserveFrame(descriptor: RasterSurfaceDescriptor, payloadCapacityBytes: UInt32, regionCapacity: UInt16) -> DisplayReservationResult {
        guard isIdleForOffer else { return .failure(.reentrancyViolation) }
        streamCompleted = false; presentationResponsibilityAccepted = false; failure = nil; retainedProducerError = nil
        recording = CounterRenderSink()
        let result = target.reserveFrame(descriptor: descriptor, payloadCapacityBytes: payloadCapacityBytes, regionCapacity: regionCapacity)
        if case .reserved(let id) = result { reservation = id }
        return result
    }
    mutating func cancelReservedFrame() { if let reservation { target.cancelFrame(reservation) }; self.reservation = nil; recording.header = nil; surface.discardFrame() }
    mutating func finishTransferredFrameIfNeeded() { if let reservation { _ = target.finishFrame(reservation) }; self.reservation = nil; recording.header = nil; _ = surface.finishFrame(); streamCompleted = true }
    borrowing func health() -> GiftUIOperationalHealth { target.health() }
    mutating func begin(_ header: RenderPlanHeader) -> Bool {
        guard reservation != nil, recording.header == nil, header.surfaceBounds == descriptor.bounds,
            header.operationCount <= capacity.maximumOperations, header.positionedGlyphCount <= capacity.maximumPositionedGlyphs,
            surface.beginFrame(header) else { return reject(.malformedStream) }
        return recording.begin(header)
    }
    mutating func fillRect(_ operation: FillRectOperation) -> Bool {
        guard let header = recording.header, glyphHeader == nil else { return reject(.malformedStream) }
        let result = RasterFillCoverage.rasterize(operation, descriptor: descriptor, damageBounds: header.damageBounds) { point, pixel in surface.replacePixel(at: point, with: pixel) }
        guard case .completed = result else { return reject(.rasterizationFailure) }
        return recording.fillRect(operation)
    }
    mutating func beginPositionedGlyphs(_ operation: PositionedGlyphOperationHeader) -> Bool {
        guard recording.header != nil, glyphHeader == nil else { return reject(.malformedStream) }
        glyphHeader = operation; return recording.beginPositionedGlyphs(operation)
    }
    mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool {
        guard let header = recording.header, let glyphHeader else { return reject(.malformedStream) }
        let result = RasterGlyphCoverage.rasterize(glyph, operation: glyphHeader, metrics: GiftUIReferenceTextMetricsView(), raster: GiftUIReferenceTextRasterView(), realization: GiftUIReferenceTextRasterView().realization(at: 0)!, descriptor: descriptor, damageBounds: header.damageBounds) { point, pixel in surface.replacePixel(at: point, with: pixel) }
        guard case .completed = result else { return reject(.rasterizationFailure) }
        return recording.positionedGlyph(glyph)
    }
    mutating func endPositionedGlyphs() -> Bool { guard glyphHeader != nil else { return reject(.malformedStream) }; glyphHeader = nil; return recording.endPositionedGlyphs() }
    mutating func straightLineStroke<S: StraightLineStrokeView>(_ stroke: borrowing S) -> Bool {
        guard let header = recording.header, glyphHeader == nil else { return reject(.malformedStream) }
        let result = RasterStrokeCoverage.rasterize(stroke, descriptor: descriptor, damageBounds: header.damageBounds) { point, pixel in surface.replacePixel(at: point, with: pixel) }
        guard case .completed = result else { return reject(.rasterizationFailure) }
        return recording.straightLineStroke(stroke)
    }
    mutating func finish() -> Bool {
        guard let header = recording.header, let reservation, glyphHeader == nil,
            recording.operations == header.operationCount, recording.glyphs == header.positionedGlyphCount else { return reject(.malformedStream) }
        let result = FullSurfacePayloadEmitter.finish(surface: &surface, header: header, reservation: reservation, target: &target)
        guard case .completed(let transferred) = result else { return reject(.rasterizationFailure) }
        presentationResponsibilityAccepted = transferred; streamCompleted = true; self.reservation = nil
        _ = recording.finish(); recording.header = nil
        return true
    }
    mutating func discard() { recording.discard(); recording.header = nil; glyphHeader = nil; surface.discardFrame() }
    private mutating func reject(_ error: RasterBackendError) -> Bool { failure = error; retainProducerError(.sinkRefused); return false }
}
struct CounterNativeEnvelope: RasterFrameEnvelopeValidator {
    let expected: FrameProvenance?
    borrowing func accepts(_ provenance: FrameProvenance) -> Bool { provenance == expected }
}
typealias CounterNativeEndpoint = OneShotRasterBackendEndpoint<CounterNativeRasterAdapter, GiftUIReferenceTextMetricsView, GiftUIReferenceTextRasterView, CounterNativeEnvelope>
struct CounterEndpoint: SynchronousFrameEndpoint {
    var actual: CounterNativeEndpoint
    var sink: CounterRenderSink { actual.sink.recording }
    init(configuration: HostEndpointConfiguration, control: UnsafeMutablePointer<CounterControl>) {
        let construction = CounterConstructionInputs.canonical
        let configuration = construction.endpointConfiguration.configuration(configuration)
        let control = construction.endpointBacking.control(control)
        let adapter = CounterNativeRasterAdapter(configuration: configuration, control: control)
        let constructed = HostEndpointConfiguration(effectivePresentation: configuration.effectivePresentation, descriptor: adapter.descriptor, payloadLimits: adapter.payloadLimits, surfaceWritableCapacityBytes: adapter.surface.writableCapacityBytes, displaySubmissionLifetime: adapter.target.submissionLifetime, displayHandoff: adapter.target.handoff, displayMaximumInFlightPayloads: adapter.target.maximumInFlightPayloads, displayMaximumInFlightBytes: adapter.target.maximumInFlightBytes, textRasterRealization: construction.text.realization, healthOwnerCount: 1, endpointAndDisplayShareHealthOwner: adapter.target.control == control)
        precondition(HostEndpointStartupValidation.validateConstructedProjection(constructed, equals: configuration) == nil)
        // Equality and both adjacent physical byte capacities reject precisely;
        // the exact actual projection remains the sole activation configuration.
        let capacities: InlineArray<3, UInt32> = [47999, 48000, 48001]
        for index in 0..<capacities.count {
            let capacity = capacities[index]
            let candidate = HostEndpointConfiguration(effectivePresentation: constructed.effectivePresentation, descriptor: constructed.descriptor, payloadLimits: constructed.payloadLimits, surfaceWritableCapacityBytes: capacity, displaySubmissionLifetime: constructed.displaySubmissionLifetime, displayHandoff: constructed.displayHandoff, displayMaximumInFlightPayloads: constructed.displayMaximumInFlightPayloads, displayMaximumInFlightBytes: constructed.displayMaximumInFlightBytes, textRasterRealization: constructed.textRasterRealization, healthOwnerCount: constructed.healthOwnerCount, endpointAndDisplayShareHealthOwner: constructed.endpointAndDisplayShareHealthOwner)
            precondition(HostEndpointStartupValidation.validateConstructedProjection(candidate, equals: configuration) == (capacity == 48000 ? nil : .invalidEndpointDescriptor))
            control.pointee.backend.projectionControls += 1
        }
        for shared in [true, false] {
            let candidate = HostEndpointConfiguration(effectivePresentation: constructed.effectivePresentation, descriptor: constructed.descriptor, payloadLimits: constructed.payloadLimits, surfaceWritableCapacityBytes: constructed.surfaceWritableCapacityBytes, displaySubmissionLifetime: constructed.displaySubmissionLifetime, displayHandoff: constructed.displayHandoff, displayMaximumInFlightPayloads: constructed.displayMaximumInFlightPayloads, displayMaximumInFlightBytes: constructed.displayMaximumInFlightBytes, textRasterRealization: constructed.textRasterRealization, healthOwnerCount: shared ? 2 : 1, endpointAndDisplayShareHealthOwner: shared)
            precondition(HostEndpointStartupValidation.validateConstructedProjection(candidate, equals: configuration) == .invalidEndpointDescriptor)
            control.pointee.backend.projectionControls += 1
        }
        control.pointee.backend.constructedProjection = constructed
        control.pointee.backend.constructedEndpoints += 1
        actual = CounterNativeEndpoint(effectivePresentation: configuration.effectivePresentation, descriptor: configuration.descriptor, payloadLimits: configuration.payloadLimits, textMetrics: construction.text.metrics(), textRaster: construction.text.raster(), textRasterRealization: construction.text.realization, envelopeValidator: CounterNativeEnvelope(expected: nil), sink: adapter, startupFailure: nil)!
    }
    // Pure typed field observations; no callback or whole-Control loan.
    mutating func captureBaselinePrefix(into baseline: inout CounterEndpointBaseline) {
        baseline.effectivePresentation = actual.effectivePresentation
        baseline.descriptor = actual.descriptor
        baseline.payloadLimits = actual.payloadLimits
        baseline.realization = actual.textRasterRealization
        baseline.bodyCalls = actual.bodyCallCount
        baseline.reservations = actual.reservationCallCount
        baseline.displayError = actual.lastDisplayError
        baseline.producerError = actual.retainedProducerError
        baseline.capacity = actual.sink.capacity
        baseline.sinkDescriptor = actual.sink.descriptor
        baseline.sinkLimits = actual.sink.payloadLimits
        baseline.sinkFailure = actual.sink.failure
        baseline.streamCompleted = actual.sink.streamCompleted
        baseline.presentationAccepted = actual.sink.presentationResponsibilityAccepted
        baseline.sinkProducerError = actual.sink.retainedProducerError
        baseline.idle = actual.sink.isIdleForOffer
    }
    borrowing func baselineHealth() -> GiftUIOperationalHealth { actual.health() }
    mutating func captureBaselineSuffix(into baseline: inout CounterEndpointBaseline) {
        baseline.recording.captureEndpoint(&self)
        baseline.targetConfiguration = actual.sink.target.configuration
        baseline.writer = nil
        baseline.nativeReservation = actual.sink.reservation
        baseline.nativeGlyphHeader = actual.sink.glyphHeader
    }
    mutating func matchesBaselinePrefix(_ baseline: inout CounterEndpointBaseline) -> Bool {
        let sameeffectivePresentation = baseline.effectivePresentation == actual.effectivePresentation
        guard sameeffectivePresentation else { return false }
        let samedescriptor = baseline.descriptor == actual.descriptor
        guard samedescriptor else { return false }
        let samepayloadLimits = baseline.payloadLimits == actual.payloadLimits
        guard samepayloadLimits else { return false }
        let samerealization = baseline.realization == actual.textRasterRealization
        guard samerealization else { return false }
        let samebodyCalls = baseline.bodyCalls == actual.bodyCallCount
        guard samebodyCalls else { return false }
        let samereservations = baseline.reservations == actual.reservationCallCount
        guard samereservations else { return false }
        let samedisplayError = baseline.displayError == actual.lastDisplayError
        guard samedisplayError else { return false }
        let sameproducerError = baseline.producerError == actual.retainedProducerError
        guard sameproducerError else { return false }
        let samecapacity = baseline.capacity == actual.sink.capacity
        guard samecapacity else { return false }
        let samesinkDescriptor = baseline.sinkDescriptor == actual.sink.descriptor
        guard samesinkDescriptor else { return false }
        let samesinkLimits = baseline.sinkLimits == actual.sink.payloadLimits
        guard samesinkLimits else { return false }
        let samesinkFailure = baseline.sinkFailure == actual.sink.failure
        guard samesinkFailure else { return false }
        let samestreamCompleted = baseline.streamCompleted == actual.sink.streamCompleted
        guard samestreamCompleted else { return false }
        let samepresentationAccepted = baseline.presentationAccepted == actual.sink.presentationResponsibilityAccepted
        guard samepresentationAccepted else { return false }
        let samesinkProducerError = baseline.sinkProducerError == actual.sink.retainedProducerError
        guard samesinkProducerError else { return false }
        let sameidle = baseline.idle == actual.sink.isIdleForOffer
        guard sameidle else { return false }
        return true
    }
    mutating func matchesBaselineSuffix(_ baseline: inout CounterEndpointBaseline) -> Bool {
        let samerecording = baseline.recording.matchesEndpoint(&self)
        guard samerecording else { return false }
        let sametargetConfiguration = baseline.targetConfiguration == actual.sink.target.configuration
        guard sametargetConfiguration else { return false }
        let samewriter = baseline.writer == nil
        guard samewriter else { return false }
        let samenativeReservation = baseline.nativeReservation == actual.sink.reservation
        guard samenativeReservation else { return false }
        let samenativeGlyphHeader = baseline.nativeGlyphHeader == actual.sink.glyphHeader
        guard samenativeGlyphHeader else { return false }
        return true
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
            targetConfiguration: actual.sink.target.configuration, writer: nil,
            nativeReservation: actual.sink.reservation, nativeGlyphHeader: actual.sink.glyphHeader)
    }
    var isIdleForRuntimeRelease: Bool { actual.sink.isIdleForOffer }
    mutating func offer(provenance: FrameProvenance, body: (inout CounterNativeRasterAdapter) -> FrameStreamResult) -> FrameOfferResult {
        offerAndObserve(provenance: provenance, body: body).result
    }
    mutating func offerAndObserve(provenance: FrameProvenance, body: (inout CounterNativeRasterAdapter) -> FrameStreamResult) -> CounterEndpointOfferObservation {
        precondition(actual.replaceEnvelopeValidator(CounterNativeEnvelope(expected: nil)))
        let reservations = actual.reservationCallCount
        let bodies = actual.bodyCallCount
        let invalid = actual.offer(provenance: provenance) { _ in preconditionFailure("invalid counter envelope invoked producer") }
        precondition(invalid == .init(disposition: .failed, failure: .invalidEnvelope)!)
        precondition(actual.reservationCallCount == reservations && actual.bodyCallCount == bodies)
        precondition(actual.replaceEnvelopeValidator(CounterNativeEnvelope(expected: provenance)))
        let result = actual.offer(provenance: provenance, body: body)
        return .init(result: result, invalidEnvelopeRejections: 1, health: actual.health(),
            acceptedRecording: result.disposition == .accepted ? sink : nil)
    }
}
#endif
