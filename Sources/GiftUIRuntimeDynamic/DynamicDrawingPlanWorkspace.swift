import GiftUI
import GiftUIDrawing
import GiftUIRenderCore

private struct DynamicDrawingPlanStroke {
    let canvas: DynamicSemanticIdentity
    let header: StraightLineStrokeHeader
    let points: [Point]
    let subpaths: [SubpathRange]
}

package struct DynamicDrawingPlanWorkspace: DrawingPlanConstructionWorkspace,
    DrawingPlanMutationStorage
{
    package let capacity: DrawingLimits
    package private(set) var isActive = false

    private var publishedSummary: DrawingPlanSummary?
    private var canvasIdentities: [DynamicSemanticIdentity] = []
    private var strokes: [DynamicDrawingPlanStroke] = []
    private var currentIdentity: DynamicSemanticIdentity?
    private var currentOrigin: Point?
    private var currentClip: Rect?
    private var contextGeneration: UInt32 = 0
    private var livePath: LivePathBuilder<DynamicLivePathStorage>?

    package init(capacity: DrawingLimits) {
        self.capacity = capacity
        canvasIdentities.reserveCapacity(Int(capacity.maximumCanvasOccurrences))
        strokes.reserveCapacity(Int(capacity.maximumPlanStrokes))
    }

    package var summary: DrawingPlanSummary {
        precondition(publishedSummary != nil)
        return publishedSummary!
    }

    package var limits: DrawingLimits { capacity }
    package var strokeCount: UInt16 { UInt16(strokes.count) }
    package var pointCount: UInt16 {
        UInt16(strokes.reduce(0) { $0 + $1.points.count })
    }

    package var subpathCount: UInt16 {
        UInt16(strokes.reduce(0) { $0 + $1.subpaths.count })
    }

    package var normalizedStrokeOperationCount: UInt16 { strokeCount }

    package mutating func acquire() -> Bool {
        guard !isActive, publishedSummary == nil else { return false }
        isActive = true
        return true
    }

    package mutating func withCanvasContext<Result>(
        identity: DynamicSemanticIdentity,
        surfaceOrigin: Point,
        inheritedClip: Rect,
        _ body: (inout GraphicsContext) throws(DrawingError) -> Result
    ) throws(DrawingError) -> Result {
        guard isActive,
            canvasIdentities.count < Int(capacity.maximumCanvasOccurrences),
            !canvasIdentities.contains(identity),
            currentIdentity == nil,
            livePath == nil
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
            livePath?.reset()
            livePath = nil
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
            livePath == nil,
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
        livePath?.reset()
        livePath = nil
        strokes.removeAll(keepingCapacity: true)
    }

    package mutating func reset() {
        discard()
        canvasIdentities.removeAll(keepingCapacity: true)
    }

    package func strokeCount(of canvas: DynamicSemanticIdentity) -> UInt16? {
        guard publishedSummary != nil, canvasIdentities.contains(canvas) else {
            return nil
        }
        return UInt16(strokes.filter { $0.canvas == canvas }.count)
    }

    package func strokeHeader(
        of canvas: DynamicSemanticIdentity,
        at index: UInt16
    ) -> StraightLineStrokeHeader? {
        stroke(of: canvas, at: index)?.header
    }

    package func point(
        of canvas: DynamicSemanticIdentity,
        stroke strokeIndex: UInt16,
        at index: UInt16
    ) -> Point? {
        guard let stroke = stroke(of: canvas, at: strokeIndex),
            Int(index) < stroke.points.count
        else { return nil }
        return stroke.points[Int(index)]
    }

    package func subpath(
        of canvas: DynamicSemanticIdentity,
        stroke strokeIndex: UInt16,
        at index: UInt16
    ) -> SubpathRange? {
        guard let stroke = stroke(of: canvas, at: strokeIndex),
            Int(index) < stroke.subpaths.count
        else { return nil }
        return stroke.subpaths[Int(index)]
    }

    package mutating func appendStroke<PathStorage>(
        header: StraightLineStrokeHeader,
        path: borrowing PathStorage
    ) -> Bool where PathStorage: LivePathStorage {
        guard let canvas = currentIdentity, let origin = currentOrigin,
            strokes.count < Int(capacity.maximumPlanStrokes)
        else { return false }
        var points: [Point] = []
        points.reserveCapacity(Int(path.pointCount))
        var pointIndex: UInt16 = 0
        while pointIndex < path.pointCount {
            guard let point = path.point(at: pointIndex) else { return false }
            let x = point.x.addingReportingOverflow(origin.x)
            let y = point.y.addingReportingOverflow(origin.y)
            guard !x.overflow, !y.overflow else { return false }
            points.append(Point(x: x.partialValue, y: y.partialValue))
            pointIndex += 1
        }
        var subpaths: [SubpathRange] = []
        subpaths.reserveCapacity(Int(path.subpathCount))
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
                points: points,
                subpaths: subpaths
            )
        )
        return true
    }

    fileprivate mutating func beginPath(
        contextGeneration: UInt32,
        pathGeneration: inout UInt32
    ) -> UInt8 {
        guard contextGeneration == self.contextGeneration, livePath == nil else {
            return _GiftUIDrawingStatus.reentrancyViolation.rawValue
        }
        livePath = LivePathBuilder(
            storage: DynamicLivePathStorage(
                maximumPointCount: capacity.maximumLivePathPoints,
                maximumSubpathCount: capacity.maximumLivePathSubpaths
            )
        )
        pathGeneration = 1
        return _GiftUIDrawingStatus.success.rawValue
    }

    fileprivate mutating func endPath(
        contextGeneration: UInt32,
        pathGeneration: UInt32
    ) -> UInt8 {
        guard contextGeneration == self.contextGeneration,
            pathGeneration == 1,
            var path = livePath
        else { return _GiftUIDrawingStatus.invalidScope.rawValue }
        path.reset()
        livePath = nil
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
            var path = livePath
        else { return _GiftUIDrawingStatus.invalidScope.rawValue }
        do {
            if move { try path.move(to: point) } else { try path.addLine(to: point) }
            livePath = path
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
            let path = livePath,
            let origin = currentOrigin,
            let clip = currentClip
        else { return _GiftUIDrawingStatus.invalidScope.rawValue }
        do {
            try StrokeSnapshotProducer.snapshot(
                path: path.storage,
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
        of canvas: DynamicSemanticIdentity,
        at index: UInt16
    ) -> DynamicDrawingPlanStroke? {
        guard publishedSummary != nil else { return nil }
        let matches = strokes.filter { $0.canvas == canvas }
        guard Int(index) < matches.count else { return nil }
        return matches[Int(index)]
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
    case .invalidPathState: _GiftUIDrawingStatus.invalidPathState.rawValue
    case .arithmeticOverflow: _GiftUIDrawingStatus.arithmeticOverflow.rawValue
    case .capacityExhausted: _GiftUIDrawingStatus.capacityExhausted.rawValue
    case .invalidScope: _GiftUIDrawingStatus.invalidScope.rawValue
    case .invalidPhase: _GiftUIDrawingStatus.invalidPhase.rawValue
    case .reentrancyViolation: _GiftUIDrawingStatus.reentrancyViolation.rawValue
    case .invariantViolation: _GiftUIDrawingStatus.invariantViolation.rawValue
    }
}
