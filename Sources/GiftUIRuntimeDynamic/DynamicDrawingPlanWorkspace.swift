import GiftUI
import GiftUIDrawing
import GiftUIRenderCore
import GiftUISemanticCore

private struct DynamicDrawingPlanStroke {
    let canvas: SemanticRecordReference
    let header: StraightLineStrokeHeader
    let points: Range<Int>
    let subpaths: Range<Int>
}

package struct DynamicDrawingPlanWorkspace: DrawingPlanConstructionWorkspace,
    DrawingPlanMutationStorage
{
    package let capacity: DrawingLimits
    package private(set) var isActive = false

    private var publishedSummary: DrawingPlanSummary?
    private var canvasIdentities: [SemanticRecordReference] = []
    private var strokes: [DynamicDrawingPlanStroke] = []
    private var points: [Point] = []
    private var subpaths: [SubpathRange] = []
    private var currentIdentity: SemanticRecordReference?
    private var currentOrigin: Point?
    private var currentClip: Rect?
    private var contextGeneration: UInt32 = 0
    private var livePath: LivePathBuilder<DynamicLivePathStorage>
    private var pathActive = false

    package init(capacity: DrawingLimits) {
        self.capacity = capacity
        self.limits = capacity
        livePath = LivePathBuilder(
            storage: DynamicLivePathStorage(
                maximumPointCount: capacity.maximumLivePathPoints,
                maximumSubpathCount: capacity.maximumLivePathSubpaths))
        points.reserveCapacity(Int(capacity.maximumPlanPoints))
        subpaths.reserveCapacity(Int(capacity.maximumPlanSubpaths))
        canvasIdentities.reserveCapacity(Int(capacity.maximumCanvasOccurrences))
        strokes.reserveCapacity(Int(capacity.maximumPlanStrokes))
    }

    /// Reports the actual retained typed buffers; live occupancy is not capacity.
    package borrowing func visitRetainedPlanExtents(_ visit: (Int, Int, Int, Int) -> Void) {
        visit(
            canvasIdentities.capacity, MemoryLayout<SemanticRecordReference>.size,
            MemoryLayout<SemanticRecordReference>.stride,
            MemoryLayout<SemanticRecordReference>.alignment)
        visit(
            strokes.capacity, MemoryLayout<DynamicDrawingPlanStroke>.size,
            MemoryLayout<DynamicDrawingPlanStroke>.stride,
            MemoryLayout<DynamicDrawingPlanStroke>.alignment)
        visit(
            points.capacity, MemoryLayout<Point>.size, MemoryLayout<Point>.stride,
            MemoryLayout<Point>.alignment)
        visit(
            subpaths.capacity, MemoryLayout<SubpathRange>.size, MemoryLayout<SubpathRange>.stride,
            MemoryLayout<SubpathRange>.alignment)
    }

    package borrowing func visitRetainedPathExtents(_ visit: (Int, Int, Int, Int) -> Void) {
        livePath.storage.visitRetainedPayloadExtents(visit)
    }

    package var planReservedPayloadBytes: UInt64 {
        UInt64(canvasIdentities.capacity * MemoryLayout<SemanticRecordReference>.stride)
            + UInt64(strokes.capacity * MemoryLayout<DynamicDrawingPlanStroke>.stride)
            + UInt64(points.capacity * MemoryLayout<Point>.stride)
            + UInt64(subpaths.capacity * MemoryLayout<SubpathRange>.stride)
    }

    package var livePathReservedPayloadBytes: UInt64 { livePath.storage.reservedPayloadBytes }

    package var summary: DrawingPlanSummary {
        precondition(publishedSummary != nil)
        return publishedSummary!
    }

    package private(set) var limits: DrawingLimits
    package mutating func configure(limits: DrawingLimits) -> Bool {
        guard !isActive, capacity.coversStorage(for: limits) else { return false }
        self.limits = limits
        return livePath.withStorage {
            $0.configure(
                maximumPointCount: limits.maximumLivePathPoints,
                maximumSubpathCount: limits.maximumLivePathSubpaths)
        }
    }
    package var strokeCount: UInt16 { UInt16(strokes.count) }
    package var pointCount: UInt16 {
        UInt16(points.count)
    }

    package var subpathCount: UInt16 {
        UInt16(subpaths.count)
    }

    package var normalizedStrokeOperationCount: UInt16 { strokeCount }

    package mutating func acquire() -> Bool {
        guard !isActive, publishedSummary == nil else { return false }
        isActive = true
        return true
    }

    package mutating func withCanvasContext<Result>(
        identity: SemanticRecordReference,
        surfaceOrigin: Point,
        inheritedClip: Rect,
        _ body: (inout GraphicsContext) throws(DrawingError) -> Result
    ) throws(DrawingError) -> Result {
        guard isActive,
            canvasIdentities.count < Int(limits.maximumCanvasOccurrences),
            !canvasIdentities.contains(identity),
            currentIdentity == nil,
            !pathActive
        else { throw .invariantViolation }
        let nextGeneration = contextGeneration.addingReportingOverflow(1)
        guard !nextGeneration.overflow, nextGeneration.partialValue != 0 else {
            throw .capacityExhausted
        }
        contextGeneration = nextGeneration.partialValue
        canvasIdentities.append(identity)
        currentIdentity = identity
        currentOrigin = surfaceOrigin
        currentClip = inheritedClip
        let activeGeneration = contextGeneration
        defer {
            livePath.reset()
            pathActive = false
            currentIdentity = nil
            currentOrigin = nil
            currentClip = nil
        }

        do {
            return try withUnsafeMutablePointer(to: &self) { workspacePointer in
                var context = GraphicsContext(
                    storage: UnsafeMutableRawPointer(workspacePointer),
                    generation: activeGeneration,
                    operations: dynamicDrawingOperations
                )
                defer { context.invalidate() }
                return try body(&context)
            }
        } catch let error as DrawingError {
            throw error
        } catch {
            throw DrawingError.invariantViolation
        }
    }

    package mutating func seal(
        canvasOccurrenceCount: UInt16
    ) -> DrawingPlanResult {
        guard isActive,
            currentIdentity == nil,
            !pathActive,
            canvasOccurrenceCount == UInt16(canvasIdentities.count),
            normalizedStrokeOperationCount == strokeCount
        else { return .failure(.invariantViolation) }
        let summary = DrawingPlanSummary(
            canvasOccurrenceCount: canvasOccurrenceCount,
            strokeCount: strokeCount,
            pointCount: pointCount,
            subpathCount: subpathCount,
            normalizedStrokeOperationCount: normalizedStrokeOperationCount
        )
        publishedSummary = summary
        isActive = false
        return .success(summary)
    }

    package mutating func discard() {
        publishedSummary = nil
        isActive = false
        currentIdentity = nil
        currentOrigin = nil
        currentClip = nil
        livePath.reset()
        pathActive = false
        strokes.removeAll(keepingCapacity: true)
        points.removeAll(keepingCapacity: true)
        subpaths.removeAll(keepingCapacity: true)
    }

    package mutating func reset() {
        discard()
        canvasIdentities.removeAll(keepingCapacity: true)
    }

    package func strokeCount(of canvas: SemanticRecordReference) -> UInt16? {
        guard publishedSummary != nil, canvasIdentities.contains(canvas) else {
            return nil
        }
        return UInt16(strokes.lazy.filter { $0.canvas == canvas }.count)
    }

    package func strokeHeader(
        of canvas: SemanticRecordReference,
        at index: UInt16
    ) -> StraightLineStrokeHeader? {
        stroke(of: canvas, at: index)?.header
    }

    package func point(
        of canvas: SemanticRecordReference,
        stroke strokeIndex: UInt16,
        at index: UInt16
    ) -> Point? {
        guard let stroke = stroke(of: canvas, at: strokeIndex),
            Int(index) < stroke.points.count
        else { return nil }
        return points[stroke.points.lowerBound + Int(index)]
    }

    package func subpath(
        of canvas: SemanticRecordReference,
        stroke strokeIndex: UInt16,
        at index: UInt16
    ) -> SubpathRange? {
        guard let stroke = stroke(of: canvas, at: strokeIndex),
            Int(index) < stroke.subpaths.count
        else { return nil }
        return subpaths[stroke.subpaths.lowerBound + Int(index)]
    }

    package mutating func appendStroke<PathStorage>(
        header: StraightLineStrokeHeader,
        path: borrowing PathStorage
    ) -> Bool where PathStorage: LivePathStorage {
        guard let canvas = currentIdentity, let origin = currentOrigin else { return false }
        return appendSnapshot(header: header, path: path, canvas: canvas, origin: origin)
    }

    // The transaction is separate from the Canvas context so malformed storage
    // reads can be tested without aliasing the active GraphicsContext borrow.
    mutating func appendSnapshot<PathStorage>(
        header: StraightLineStrokeHeader,
        path: borrowing PathStorage,
        canvas: SemanticRecordReference,
        origin: Point
    ) -> Bool where PathStorage: LivePathStorage {
        guard isActive, canvasIdentities.contains(canvas),
            strokes.count < Int(limits.maximumPlanStrokes),
            points.count + Int(path.pointCount) <= Int(limits.maximumPlanPoints),
            subpaths.count + Int(path.subpathCount) <= Int(limits.maximumPlanSubpaths)
        else { return false }
        let pointStart = points.count
        let subpathStart = subpaths.count
        var committed = false
        defer {
            if !committed {
                points.removeLast(points.count - pointStart)
                subpaths.removeLast(subpaths.count - subpathStart)
            }
        }
        var pointIndex: UInt16 = 0
        while pointIndex < path.pointCount {
            guard let point = path.point(at: pointIndex) else { return false }
            let x = point.x.addingReportingOverflow(origin.x)
            let y = point.y.addingReportingOverflow(origin.y)
            guard !x.overflow, !y.overflow else { return false }
            points.append(Point(x: x.partialValue, y: y.partialValue))
            pointIndex += 1
        }
        var subpathIndex: UInt16 = 0
        while subpathIndex < path.subpathCount {
            guard let subpath = path.subpath(at: subpathIndex) else { return false }
            subpaths.append(subpath)
            subpathIndex += 1
        }
        strokes.append(
            DynamicDrawingPlanStroke(
                canvas: canvas,
                header: header,
                points: pointStart ..< points.count,
                subpaths: subpathStart ..< subpaths.count
            )
        )
        committed = true
        return true
    }

    fileprivate mutating func beginPath(
        contextGeneration: UInt32,
        pathGeneration: inout UInt32
    ) -> UInt8 {
        guard contextGeneration == self.contextGeneration, !pathActive else {
            return _GiftUIDrawingStatus.reentrancyViolation.rawValue
        }
        livePath.reset()
        livePath = LivePathBuilder(storage: livePath.storage)
        pathActive = true
        pathGeneration = 1
        return _GiftUIDrawingStatus.success.rawValue
    }

    fileprivate mutating func endPath(
        contextGeneration: UInt32,
        pathGeneration: UInt32
    ) -> UInt8 {
        guard contextGeneration == self.contextGeneration,
            pathGeneration == 1,
            pathActive
        else { return _GiftUIDrawingStatus.invalidScope.rawValue }
        livePath.reset()
        pathActive = false
        return _GiftUIDrawingStatus.success.rawValue
    }

    fileprivate mutating func mutatePath(
        contextGeneration: UInt32,
        pathGeneration: UInt32,
        point: Point,
        move: Bool
    ) -> UInt8 {
        guard contextGeneration == self.contextGeneration,
            pathGeneration == 1,
            pathActive
        else { return _GiftUIDrawingStatus.invalidScope.rawValue }
        do {
            if move { try livePath.move(to: point) } else { try livePath.addLine(to: point) }
            return _GiftUIDrawingStatus.success.rawValue
        } catch {
            return dynamicDrawingStatus(for: error)
        }
    }

    fileprivate mutating func strokePath(
        contextGeneration: UInt32,
        pathGeneration: UInt32,
        color: Color,
        style: StrokeStyle
    ) -> UInt8 {
        guard contextGeneration == self.contextGeneration,
            pathGeneration == 1,
            pathActive,
            let origin = currentOrigin,
            let clip = currentClip
        else { return _GiftUIDrawingStatus.invalidScope.rawValue }
        let path = livePath.storage
        do {
            try StrokeSnapshotProducer.snapshot(
                path: path,
                shading: .color(color),
                style: style,
                surfaceOrigin: origin,
                inheritedClip: clip,
                plan: &self
            )
            return _GiftUIDrawingStatus.success.rawValue
        } catch {
            return dynamicDrawingStatus(for: error)
        }
    }

    private func stroke(
        of canvas: SemanticRecordReference,
        at index: UInt16
    ) -> DynamicDrawingPlanStroke? {
        guard publishedSummary != nil else { return nil }
        var ordinal: UInt16 = 0
        for stroke in strokes where stroke.canvas == canvas {
            if ordinal == index { return stroke }
            ordinal += 1
        }
        return nil
    }
}

private let dynamicDrawingOperations = _GiftUIDrawingOperations(
    beginPath: dynamicBeginPath,
    endPath: dynamicEndPath,
    movePath: dynamicMovePath,
    addLineToPath: dynamicAddLinePath,
    strokePath: dynamicStrokePath
)

private func dynamicBeginPath(
    storage: UnsafeMutableRawPointer,
    contextGeneration: UInt32,
    pathGeneration: UnsafeMutablePointer<UInt32>
) -> UInt8 {
    storage.assumingMemoryBound(to: DynamicDrawingPlanWorkspace.self).pointee
        .beginPath(
            contextGeneration: contextGeneration,
            pathGeneration: &pathGeneration.pointee
        )
}

private func dynamicEndPath(
    storage: UnsafeMutableRawPointer,
    contextGeneration: UInt32,
    pathGeneration: UInt32
) -> UInt8 {
    storage.assumingMemoryBound(to: DynamicDrawingPlanWorkspace.self).pointee
        .endPath(
            contextGeneration: contextGeneration,
            pathGeneration: pathGeneration
        )
}

private func dynamicMovePath(
    storage: UnsafeMutableRawPointer,
    contextGeneration: UInt32,
    pathGeneration: UInt32,
    x: GeometryScalar,
    y: GeometryScalar
) -> UInt8 {
    storage.assumingMemoryBound(to: DynamicDrawingPlanWorkspace.self).pointee
        .mutatePath(
            contextGeneration: contextGeneration,
            pathGeneration: pathGeneration,
            point: Point(x: x, y: y),
            move: true
        )
}

private func dynamicAddLinePath(
    storage: UnsafeMutableRawPointer,
    contextGeneration: UInt32,
    pathGeneration: UInt32,
    x: GeometryScalar,
    y: GeometryScalar
) -> UInt8 {
    storage.assumingMemoryBound(to: DynamicDrawingPlanWorkspace.self).pointee
        .mutatePath(
            contextGeneration: contextGeneration,
            pathGeneration: pathGeneration,
            point: Point(x: x, y: y),
            move: false
        )
}

private func dynamicStrokePath(
    storage: UnsafeMutableRawPointer,
    contextGeneration: UInt32,
    pathGeneration: UInt32,
    red: UInt8,
    green: UInt8,
    blue: UInt8,
    lineWidth: GeometryScalar,
    lineCap: UInt8,
    lineJoin: UInt8
) -> UInt8 {
    guard let cap = LineCap(rawValue: lineCap),
        let join = LineJoin(rawValue: lineJoin)
    else { return _GiftUIDrawingStatus.invariantViolation.rawValue }
    return storage.assumingMemoryBound(
        to: DynamicDrawingPlanWorkspace.self
    ).pointee.strokePath(
        contextGeneration: contextGeneration,
        pathGeneration: pathGeneration,
        color: Color(red: red, green: green, blue: blue),
        style: StrokeStyle(lineWidth: lineWidth, lineCap: cap, lineJoin: join)
    )
}

private func dynamicDrawingStatus(for error: any Error) -> UInt8 {
    guard let error = error as? DrawingError else {
        return _GiftUIDrawingStatus.invariantViolation.rawValue
    }
    return switch error {
    case .invalidValue: _GiftUIDrawingStatus.invalidValue.rawValue
    case .invalidModelAccess: _GiftUIDrawingStatus.invalidModelAccess.rawValue
    case .invalidPathState: _GiftUIDrawingStatus.invalidPathState.rawValue
    case .arithmeticOverflow: _GiftUIDrawingStatus.arithmeticOverflow.rawValue
    case .capacityExhausted: _GiftUIDrawingStatus.capacityExhausted.rawValue
    case .invalidScope: _GiftUIDrawingStatus.invalidScope.rawValue
    case .invalidPhase: _GiftUIDrawingStatus.invalidPhase.rawValue
    case .reentrancyViolation: _GiftUIDrawingStatus.reentrancyViolation.rawValue
    case .invariantViolation: _GiftUIDrawingStatus.invariantViolation.rawValue
    }
}
