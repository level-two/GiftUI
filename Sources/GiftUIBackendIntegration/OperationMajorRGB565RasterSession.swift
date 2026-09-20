import GiftUI
import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIExecution
import GiftUIFailureCore
import GiftUIRasterCore
import GiftUIRenderCore
import GiftUISurfaceCore
import GiftUITextResources

/// Owns one bounded operation-major RGB565 offer session. It consumes every
/// borrowed operation synchronously and retains only tile, payload, target,
/// counter, and failure state permitted by SPEC-014.
package struct OperationMajorRGB565RasterSession<Storage, Target, Metrics, Raster>:
    RasterOfferSessionSink
where
    Storage: RGB565TileStorage,
    Target: DisplayTarget,
    Metrics: CanonicalTextMetricsView,
    Raster: TextRasterResourceView
{
    private enum Phase: UInt8 {
        case idle
        case reserved
        case streaming
        case positionedGlyphs
    }

    package let capacity: RenderSinkCapacity
    package let descriptor: RasterSurfaceDescriptor
    package let payloadLimits: RasterPayloadLimits
    package private(set) var target: Target
    package private(set) var failure: RasterBackendError?
    package private(set) var streamCompleted = false
    package private(set) var retainedProducerError: RenderProductionError?

    private let metrics: Metrics
    private let raster: Raster
    private let realization: RasterRealizationDescriptor
    private var workspace: RGB565TileWorkspace<Storage>
    private var work: RasterWorkTracker
    private var phase: Phase = .idle
    private var reservation: DisplayReservationID?
    private var header: RenderPlanHeader?
    private var glyphHeader: PositionedGlyphOperationHeader?
    private var consumedOperations: UInt16 = 0
    private var consumedGlyphs: UInt16 = 0
    private var consumedPositionedGlyphs: UInt16 = 0

    package init?(
        capacity: RenderSinkCapacity,
        descriptor: RasterSurfaceDescriptor,
        payloadLimits: RasterPayloadLimits,
        metrics: consuming Metrics,
        raster: consuming Raster,
        realization: RasterRealizationID,
        storage: consuming Storage,
        target: consuming Target
    ) {
        guard descriptor.realization == .tiled,
            descriptor.encoding == .rgb565BigEndian,
            target.handoff == .synchronous,
            target.submissionLifetime == .synchronousBorrow
                || target.submissionLifetime == .synchronousCopy,
            target.maximumInFlightPayloads
                >= payloadLimits.maximumInFlightPayloads,
            target.maximumInFlightBytes >= payloadLimits.maximumInFlightBytes,
            let selectedRealization = raster.realization(
                at: realization.rawValue
            ),
            selectedRealization.id == realization,
            let workspace = RGB565TileWorkspace(
                descriptor: descriptor,
                storage: storage
            ),
            RasterFrameWorkAdmission.constructionFailure(
                descriptor: descriptor,
                sinkCapacity: capacity,
                limits: payloadLimits
            ) == nil
        else { return nil }
        self.capacity = capacity
        self.descriptor = descriptor
        self.payloadLimits = payloadLimits
        self.metrics = metrics
        self.raster = raster
        self.realization = selectedRealization
        self.workspace = workspace
        self.target = target
        work = RasterWorkTracker(limits: payloadLimits)
    }

    package var isIdleForOffer: Bool { phase == .idle }

    package var presentationResponsibilityAccepted: Bool {
        work.presentationResponsibilityAccepted
    }

    package mutating func retainProducerError(_ error: RenderProductionError) {
        if retainedProducerError == nil { retainedProducerError = error }
    }

    package mutating func reserveFrame(
        descriptor: RasterSurfaceDescriptor,
        payloadCapacityBytes: UInt32,
        regionCapacity: UInt16
    ) -> DisplayReservationResult {
        guard phase == .idle, reservation == nil else {
            return .failure(.reentrancyViolation)
        }
        guard descriptor == self.descriptor,
            payloadCapacityBytes == payloadLimits.maximumPayloadBytes,
            regionCapacity == payloadLimits.maximumRegionsPerPayload
        else { return .failure(.invalidDescriptor) }
        streamCompleted = false
        retainedProducerError = nil
        failure = nil
        work.reset()
        let result = target.reserveFrame(
            descriptor: descriptor,
            payloadCapacityBytes: payloadCapacityBytes,
            regionCapacity: regionCapacity
        )
        if case .reserved(let reservation) = result {
            self.reservation = reservation
            phase = .reserved
        }
        return result
    }

    package mutating func cancelReservedFrame() {
        if let reservation { target.cancelFrame(reservation) }
        resetSession()
    }

    package mutating func finishTransferredFrameIfNeeded() {
        guard let reservation else { return }
        _ = RGB565TilePayloadEmitter.finish(
            reservation: reservation,
            target: &target,
            work: &work
        )
        failure = work.failure
        streamCompleted = true
        resetGrammar()
        self.reservation = nil
        phase = .idle
    }

    package borrowing func health() -> GiftUIOperationalHealth {
        target.health()
    }

    package mutating func begin(_ header: RenderPlanHeader) -> Bool {
        guard phase == .reserved,
            header.surfaceBounds == descriptor.bounds,
            header.operationCount <= capacity.maximumOperations,
            header.positionedGlyphCount <= capacity.maximumPositionedGlyphs,
            RasterFrameWorkAdmission.headerFailure(
                header,
                descriptor: descriptor,
                sinkCapacity: capacity,
                limits: payloadLimits
            ) == nil
        else { return reject(.malformedStream) }
        self.header = header
        consumedOperations = 0
        consumedPositionedGlyphs = 0
        phase = .streaming
        return true
    }

    package mutating func fillRect(_ operation: FillRectOperation) -> Bool {
        guard phase == .streaming, let header, let reservation,
            consumedOperations < header.operationCount
        else {
            return reject(.malformedStream)
        }
        var localWorkspace = workspace
        var localTarget = target
        var localWork = work
        let traversal = OperationMajorTileTraversal.visit(
            operationClip: operation.clip,
            damageBounds: header.damageBounds,
            workspace: &localWorkspace,
            { damage, replace in
                switch RasterFillCoverage.rasterize(
                    operation,
                    descriptor: descriptor,
                    damageBounds: damage,
                    replace
                ) {
                case .completed(let pixelCount):
                    return localWork.recordPixelVisits(pixelCount)
                case .invalidGeometry:
                    _ = localWork.recordFailure(.invalidGeometry)
                case .arithmeticOverflow:
                    _ = localWork.recordFailure(.arithmeticOverflow)
                case .replacementRefused:
                    _ = localWork.recordFailure(.rasterizationFailure)
                }
                return localWork.presentationResponsibilityAccepted
            },
            { tile in
                if case .completed = RGB565TilePayloadEmitter.submit(
                    &tile,
                    reservation: reservation,
                    target: &localTarget,
                    work: &localWork
                ) {
                    return true
                }
                return localWork.presentationResponsibilityAccepted
            }
        )
        workspace = localWorkspace
        target = localTarget
        work = localWork
        failure = work.failure
        guard case .completed = traversal else {
            return reject(work.failure ?? .rasterizationFailure)
        }
        consumedOperations += 1
        return true
    }

    package mutating func beginPositionedGlyphs(
        _ operation: PositionedGlyphOperationHeader
    ) -> Bool {
        guard phase == .streaming, let header, operation.glyphCount > 0,
            consumedOperations < header.operationCount
        else {
            return reject(.malformedStream)
        }
        let glyphTotal = consumedPositionedGlyphs.addingReportingOverflow(
            operation.glyphCount
        )
        guard !glyphTotal.overflow,
            glyphTotal.partialValue <= header.positionedGlyphCount
        else { return reject(.malformedStream) }
        glyphHeader = operation
        consumedGlyphs = 0
        phase = .positionedGlyphs
        return true
    }

    package mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool {
        guard phase == .positionedGlyphs, let glyphHeader,
            consumedGlyphs < glyphHeader.glyphCount,
            let header, let reservation
        else { return reject(.malformedStream) }

        var localWorkspace = workspace
        var localTarget = target
        var localWork = work
        let access = RasterGlyphCoverage.withValidatedPayload(
            glyph,
            operation: glyphHeader,
            metrics: metrics,
            raster: raster,
            realization: realization,
            descriptor: descriptor,
            damageBounds: header.damageBounds
        ) { inkBounds, record, bytes in
            guard localWork.observeGlyphBytes(record.byteCount) else {
                return OperationMajorTileTraversalResult.rasterFailure
            }
            return OperationMajorTileTraversal.visit(
                operationClip: glyphHeader.clip,
                damageBounds: header.damageBounds,
                workspace: &localWorkspace,
                { damage, replace in
                    switch RasterGlyphCoverage.rasterizeValidatedPayload(
                        inkBounds: inkBounds,
                        record: record,
                        bytes: bytes,
                        operation: glyphHeader,
                        descriptor: descriptor,
                        damageBounds: damage,
                        replace
                    ) {
                    case .completed(let pixelCount, _):
                        return localWork.recordPixelVisits(pixelCount)
                    case .incompatibleResource:
                        _ = localWork.recordFailure(.incompatibleResource)
                    case .invalidGeometry:
                        _ = localWork.recordFailure(.invalidGeometry)
                    case .arithmeticOverflow:
                        _ = localWork.recordFailure(.arithmeticOverflow)
                    case .replacementRefused:
                        _ = localWork.recordFailure(.rasterizationFailure)
                    }
                    return localWork.presentationResponsibilityAccepted
                },
                { tile in
                    if case .completed = RGB565TilePayloadEmitter.submit(
                        &tile,
                        reservation: reservation,
                        target: &localTarget,
                        work: &localWork
                    ) {
                        return true
                    }
                    return localWork.presentationResponsibilityAccepted
                }
            )
        }
        workspace = localWorkspace
        target = localTarget
        work = localWork
        let succeeded: Bool
        switch access {
        case .payload(.completed):
            succeeded = true
        case .empty:
            succeeded = true
        case .incompatibleResource:
            succeeded = record(.incompatibleResource)
        case .invalidGeometry:
            succeeded = record(.invalidGeometry)
        case .arithmeticOverflow:
            succeeded = record(.arithmeticOverflow)
        case .payload:
            succeeded = record(work.failure ?? .rasterizationFailure)
        }
        guard succeeded else { return rejectRecordedFailure() }
        consumedGlyphs += 1
        consumedPositionedGlyphs += 1
        return true
    }

    package mutating func endPositionedGlyphs() -> Bool {
        guard phase == .positionedGlyphs, let glyphHeader,
            consumedGlyphs == glyphHeader.glyphCount
        else { return reject(.malformedStream) }
        self.glyphHeader = nil
        consumedGlyphs = 0
        consumedOperations += 1
        phase = .streaming
        return true
    }

    package mutating func straightLineStroke<Stroke: StraightLineStrokeView>(
        _ stroke: borrowing Stroke
    ) -> Bool {
        guard phase == .streaming, let header, let reservation,
            consumedOperations < header.operationCount
        else {
            return reject(.malformedStream)
        }
        guard work.observeStrokeWorkspaceBytes(1) else {
            return rejectRecordedFailure()
        }
        let operation = copy stroke
        var localWorkspace = workspace
        var localTarget = target
        var localWork = work
        let traversal = OperationMajorTileTraversal.visit(
            operationClip: stroke.header.inheritedClip,
            damageBounds: header.damageBounds,
            workspace: &localWorkspace,
            { damage, replace in
                switch RasterStrokeCoverage.rasterize(
                    operation,
                    descriptor: descriptor,
                    damageBounds: damage,
                    replace
                ) {
                case .completed(let pixelCount):
                    return localWork.recordPixelVisits(pixelCount)
                case .invalidGeometry:
                    _ = localWork.recordFailure(.invalidGeometry)
                case .invalidStroke, .replacementRefused:
                    _ = localWork.recordFailure(.rasterizationFailure)
                case .arithmeticOverflow:
                    _ = localWork.recordFailure(.arithmeticOverflow)
                }
                return localWork.presentationResponsibilityAccepted
            },
            { tile in
                if case .completed = RGB565TilePayloadEmitter.submit(
                    &tile,
                    reservation: reservation,
                    target: &localTarget,
                    work: &localWork
                ) {
                    return true
                }
                return localWork.presentationResponsibilityAccepted
            }
        )
        workspace = localWorkspace
        target = localTarget
        work = localWork
        failure = work.failure
        guard case .completed = traversal else {
            return reject(work.failure ?? .rasterizationFailure)
        }
        consumedOperations += 1
        return true
    }

    package mutating func finish() -> Bool {
        guard phase == .streaming, let header, let reservation,
            consumedOperations == header.operationCount,
            consumedPositionedGlyphs == header.positionedGlyphCount
        else {
            return reject(.malformedStream)
        }
        let result = RGB565TilePayloadEmitter.finish(
            reservation: reservation,
            target: &target,
            work: &work
        )
        failure = work.failure
        switch result {
        case .completed:
            streamCompleted = true
            self.reservation = nil
            resetGrammar()
            phase = .idle
            return true
        case .frameEnd:
            self.reservation = nil
            resetGrammar()
            phase = .idle
            return presentationResponsibilityAccepted
        }
    }

    package mutating func discard() {
        resetGrammar()
        if phase != .idle { phase = .reserved }
    }

    private mutating func record(_ error: RasterBackendError) -> Bool {
        let mayDrain = work.recordFailure(error)
        failure = work.failure
        return mayDrain
    }

    private mutating func reject(_ error: RasterBackendError) -> Bool {
        _ = record(error)
        retainProducerError(.sinkRefused)
        return presentationResponsibilityAccepted
    }

    private mutating func rejectRecordedFailure() -> Bool {
        failure = work.failure
        retainProducerError(.sinkRefused)
        return presentationResponsibilityAccepted
    }

    private mutating func resetGrammar() {
        header = nil
        glyphHeader = nil
        consumedOperations = 0
        consumedGlyphs = 0
        consumedPositionedGlyphs = 0
    }

    private mutating func resetSession() {
        resetGrammar()
        reservation = nil
        phase = .idle
    }
}
