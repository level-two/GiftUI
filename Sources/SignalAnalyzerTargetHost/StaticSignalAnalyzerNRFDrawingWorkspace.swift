import GiftUI
import GiftUIDrawing
import GiftUIRenderCore

/// Scoped GraphicsContext bridge over the two audited Static Drawing regions.
package struct StaticSignalAnalyzerNRFDrawingWorkspace:
    DrawingPlanConstructionWorkspace, DrawingPlanMutationStorage
{
    package typealias Identity = UInt16

    private var plan: StaticSignalAnalyzerNRFDrawingPlanStorage
    private let pathRegion: UnsafeMutableRawBufferPointer
    private var livePath: LivePathBuilder<StaticSignalAnalyzerNRFLivePathStorage>?
    private var currentIdentity: UInt16?
    private var currentOrigin: Point?
    private var currentClip: Rect?
    private var contextGeneration: UInt32 = 0

    package init?(
        pathRegion: UnsafeMutableRawBufferPointer,
        planRegion: UnsafeMutableRawBufferPointer,
        capacity: DrawingLimits
    ) {
        guard pathRegion.count == StaticSignalAnalyzerNRFLivePathStorage.regionByteCount,
            let plan = StaticSignalAnalyzerNRFDrawingPlanStorage(
                region: planRegion, capacity: capacity
            )
        else { return nil }
        self.pathRegion = pathRegion
        self.plan = plan
    }

    package var capacity: DrawingLimits { plan.capacity }
    package var limits: DrawingLimits { plan.limits }
    package var isActive: Bool { plan.isActive }
    package var summary: DrawingPlanSummary { plan.summary }
    package var strokeCount: UInt16 { plan.strokeCount }
    package var pointCount: UInt16 { plan.pointCount }
    package var subpathCount: UInt16 { plan.subpathCount }
    package var normalizedStrokeOperationCount: UInt16 {
        plan.normalizedStrokeOperationCount
    }

    package mutating func acquire() -> Bool {
        plan.acquire()
    }

    package mutating func withCanvasContext<Result>(
        identity: UInt16,
        surfaceOrigin: Point,
        inheritedClip: Rect,
        _ body: (inout GraphicsContext) throws(DrawingError) -> Result
    ) throws(DrawingError) -> Result {
        guard plan.isActive, currentIdentity == nil, livePath == nil,
            plan.beginCanvas(identity: identity, origin: surfaceOrigin)
        else { throw .invariantViolation }
        let next = contextGeneration.addingReportingOverflow(1)
        guard !next.overflow, next.partialValue != 0 else {
            throw .capacityExhausted
        }
        contextGeneration = next.partialValue
        let activeGeneration = contextGeneration
        currentIdentity = identity
        currentOrigin = surfaceOrigin
        currentClip = inheritedClip
        defer {
            livePath?.reset()
            livePath = nil
            currentIdentity = nil
            currentOrigin = nil
            currentClip = nil
        }

        let result: Result
        do {
            result = try withUnsafeMutablePointer(to: &self) { pointer in
                var context = GraphicsContext(
                    storage: UnsafeMutableRawPointer(pointer),
                    generation: activeGeneration,
                    operations: staticNRFDrawingOperations
                )
                defer { context.invalidate() }
                return try body(&context)
            }
        } catch let error as DrawingError {
            throw error
        } catch {
            throw DrawingError.invariantViolation
        }
        guard plan.endCanvas() else { throw .invariantViolation }
        return result
    }

    package mutating func seal(canvasOccurrenceCount: UInt16) -> DrawingPlanResult {
        guard currentIdentity == nil, livePath == nil else {
            return .failure(.invariantViolation)
        }
        return plan.seal(canvasOccurrenceCount: canvasOccurrenceCount)
    }

    package mutating func discard() {
        livePath?.reset()
        livePath = nil
        currentIdentity = nil
        currentOrigin = nil
        currentClip = nil
        plan.discard()
    }

    package mutating func reset() {
        discard()
        pathRegion.initializeMemory(as: UInt8.self, repeating: 0)
    }

    package func strokeCount(of canvas: UInt16) -> UInt16? {
        plan.strokeCount(of: canvas)
    }

    package func strokeHeader(
        of canvas: UInt16, at index: UInt16
    ) -> StraightLineStrokeHeader? {
        plan.strokeHeader(of: canvas, at: index)
    }

    package func point(
        of canvas: UInt16, stroke: UInt16, at index: UInt16
    ) -> Point? {
        plan.point(of: canvas, stroke: stroke, at: index)
    }

    package func subpath(
        of canvas: UInt16, stroke: UInt16, at index: UInt16
    ) -> SubpathRange? {
        plan.subpath(of: canvas, stroke: stroke, at: index)
    }

    package mutating func appendStroke<PathStorage>(
        header: StraightLineStrokeHeader,
        path: borrowing PathStorage
    ) -> Bool where PathStorage: LivePathStorage {
        plan.appendStroke(header: header, path: path)
    }

    fileprivate mutating func beginPath(
        contextGeneration: UInt32,
        pathGeneration: inout UInt32
    ) -> UInt8 {
        guard contextGeneration == self.contextGeneration,
            currentIdentity != nil, livePath == nil,
            let storage = StaticSignalAnalyzerNRFLivePathStorage(region: pathRegion)
        else { return _GiftUIDrawingStatus.reentrancyViolation.rawValue }
        livePath = LivePathBuilder(storage: storage)
        pathGeneration = 1
        return _GiftUIDrawingStatus.success.rawValue
    }

    fileprivate mutating func endPath(
        contextGeneration: UInt32, pathGeneration: UInt32
    ) -> UInt8 {
        guard contextGeneration == self.contextGeneration,
            pathGeneration == 1, var path = livePath
        else { return _GiftUIDrawingStatus.invalidScope.rawValue }
        path.reset()
        livePath = nil
        return _GiftUIDrawingStatus.success.rawValue
    }

    fileprivate mutating func mutatePath(
        contextGeneration: UInt32, pathGeneration: UInt32,
        point: Point, move: Bool
    ) -> UInt8 {
        guard contextGeneration == self.contextGeneration,
            pathGeneration == 1, var path = livePath
        else { return _GiftUIDrawingStatus.invalidScope.rawValue }
        do {
            if move { try path.move(to: point) } else { try path.addLine(to: point) }
            livePath = path
            return _GiftUIDrawingStatus.success.rawValue
        } catch {
            return staticNRFDrawingStatus(for: error)
        }
    }

    fileprivate mutating func strokePath(
        contextGeneration: UInt32, pathGeneration: UInt32,
        color: Color, style: StrokeStyle
    ) -> UInt8 {
        guard contextGeneration == self.contextGeneration,
            pathGeneration == 1, let path = livePath,
            let origin = currentOrigin, let clip = currentClip
        else { return _GiftUIDrawingStatus.invalidScope.rawValue }
        do {
            try StrokeSnapshotProducer.snapshot(
                path: path.storage, shading: .color(color), style: style,
                surfaceOrigin: origin, inheritedClip: clip, plan: &self
            )
            return _GiftUIDrawingStatus.success.rawValue
        } catch {
            return staticNRFDrawingStatus(for: error)
        }
    }
}

private let staticNRFDrawingOperations = _GiftUIDrawingOperations(
    beginPath: staticNRFBeginPath,
    endPath: staticNRFEndPath,
    movePath: staticNRFMovePath,
    addLineToPath: staticNRFAddLinePath,
    strokePath: staticNRFStrokePath
)

private func staticNRFBeginPath(
    storage: UnsafeMutableRawPointer,
    contextGeneration: UInt32,
    pathGeneration: UnsafeMutablePointer<UInt32>
) -> UInt8 {
    storage.assumingMemoryBound(to: StaticSignalAnalyzerNRFDrawingWorkspace.self)
        .pointee.beginPath(
            contextGeneration: contextGeneration,
            pathGeneration: &pathGeneration.pointee
        )
}

private func staticNRFEndPath(
    storage: UnsafeMutableRawPointer,
    contextGeneration: UInt32,
    pathGeneration: UInt32
) -> UInt8 {
    storage.assumingMemoryBound(to: StaticSignalAnalyzerNRFDrawingWorkspace.self)
        .pointee.endPath(
            contextGeneration: contextGeneration,
            pathGeneration: pathGeneration
        )
}

private func staticNRFMovePath(
    storage: UnsafeMutableRawPointer,
    contextGeneration: UInt32,
    pathGeneration: UInt32,
    x: GeometryScalar, y: GeometryScalar
) -> UInt8 {
    storage.assumingMemoryBound(to: StaticSignalAnalyzerNRFDrawingWorkspace.self)
        .pointee.mutatePath(
            contextGeneration: contextGeneration,
            pathGeneration: pathGeneration,
            point: Point(x: x, y: y), move: true
        )
}

private func staticNRFAddLinePath(
    storage: UnsafeMutableRawPointer,
    contextGeneration: UInt32,
    pathGeneration: UInt32,
    x: GeometryScalar, y: GeometryScalar
) -> UInt8 {
    storage.assumingMemoryBound(to: StaticSignalAnalyzerNRFDrawingWorkspace.self)
        .pointee.mutatePath(
            contextGeneration: contextGeneration,
            pathGeneration: pathGeneration,
            point: Point(x: x, y: y), move: false
        )
}

private func staticNRFStrokePath(
    storage: UnsafeMutableRawPointer,
    contextGeneration: UInt32,
    pathGeneration: UInt32,
    red: UInt8, green: UInt8, blue: UInt8,
    lineWidth: GeometryScalar,
    lineCap: UInt8, lineJoin: UInt8
) -> UInt8 {
    guard let cap = LineCap(rawValue: lineCap),
        let join = LineJoin(rawValue: lineJoin)
    else { return _GiftUIDrawingStatus.invariantViolation.rawValue }
    return storage.assumingMemoryBound(to: StaticSignalAnalyzerNRFDrawingWorkspace.self)
        .pointee.strokePath(
            contextGeneration: contextGeneration,
            pathGeneration: pathGeneration,
            color: Color(red: red, green: green, blue: blue),
            style: StrokeStyle(lineWidth: lineWidth, lineCap: cap, lineJoin: join)
        )
}

private func staticNRFDrawingStatus(for error: any Error) -> UInt8 {
    guard let error = error as? DrawingError else {
        return _GiftUIDrawingStatus.invariantViolation.rawValue
    }
    return switch error {
    case .invalidValue: _GiftUIDrawingStatus.invalidValue.rawValue
    case .invalidPathState: _GiftUIDrawingStatus.invalidPathState.rawValue
    case .arithmeticOverflow: _GiftUIDrawingStatus.arithmeticOverflow.rawValue
    case .capacityExhausted: _GiftUIDrawingStatus.capacityExhausted.rawValue
    case .invalidScope: _GiftUIDrawingStatus.invalidScope.rawValue
    case .invalidPhase: _GiftUIDrawingStatus.invalidPhase.rawValue
    case .reentrancyViolation: _GiftUIDrawingStatus.reentrancyViolation.rawValue
    case .invariantViolation: _GiftUIDrawingStatus.invariantViolation.rawValue
    }
}
