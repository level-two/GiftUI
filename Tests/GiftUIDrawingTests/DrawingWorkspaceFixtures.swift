import GiftUI
import GiftUIRenderCore

@testable import GiftUIDrawing

protocol CanvasIdentityFixtureStorage {
    var capacity: UInt16 { get }
    var count: UInt16 { get }
    mutating func append(_ identity: UInt16) -> Bool
    func identity(at index: UInt16) -> UInt16?
}

struct DynamicCanvasIdentityFixtureStorage: CanvasIdentityFixtureStorage {
    let capacity: UInt16
    private var identities: [UInt16] = []

    init(capacity: UInt16) {
        self.capacity = capacity
    }

    var count: UInt16 { UInt16(identities.count) }

    mutating func append(_ identity: UInt16) -> Bool {
        guard count < capacity else { return false }
        identities.append(identity)
        return true
    }

    func identity(at index: UInt16) -> UInt16? {
        guard Int(index) < identities.count else { return nil }
        return identities[Int(index)]
    }
}

struct StaticCanvasIdentityFixtureStorage: CanvasIdentityFixtureStorage {
    let capacity: UInt16
    private var storedCount: UInt16 = 0
    private var slots: (UInt16, UInt16, UInt16, UInt16) = (0, 0, 0, 0)

    init?(capacity: UInt16) {
        guard capacity > 0, capacity <= 4 else { return nil }
        self.capacity = capacity
    }

    var count: UInt16 { storedCount }

    mutating func append(_ identity: UInt16) -> Bool {
        guard storedCount < capacity else { return false }
        switch storedCount {
        case 0: slots.0 = identity
        case 1: slots.1 = identity
        case 2: slots.2 = identity
        case 3: slots.3 = identity
        default: return false
        }
        storedCount += 1
        return true
    }

    func identity(at index: UInt16) -> UInt16? {
        guard index < storedCount else { return nil }
        return switch index {
        case 0: slots.0
        case 1: slots.1
        case 2: slots.2
        case 3: slots.3
        default: nil
        }
    }
}

enum FixtureDrawingPlanState {
    case idle
    case active
    case sealed
    case discarded
}

struct FixtureDrawingStroke {
    let canvas: UInt16
    let header: StraightLineStrokeHeader
    let points: [Point]
    let subpaths: [SubpathRange]
}

struct FixtureDrawingPlanWorkspace: DrawingPlanWorkspace {
    let capacity: DrawingLimits
    private(set) var state = FixtureDrawingPlanState.idle
    private var canvases: [UInt16] = []
    private var strokes: [FixtureDrawingStroke] = []
    private var publishedSummary: DrawingPlanSummary?

    init(capacity: DrawingLimits) {
        self.capacity = capacity
    }

    var isActive: Bool { state == .active }
    var isPlanAccessible: Bool { state == .sealed }

    var summary: DrawingPlanSummary {
        precondition(state == .sealed)
        return publishedSummary!
    }

    mutating func acquire() -> Bool {
        guard state == .idle else { return false }
        state = .active
        return true
    }

    mutating func stageCanvas(_ identity: UInt16) -> Bool {
        guard state == .active,
            canvases.count < Int(capacity.maximumCanvasOccurrences)
        else { return false }
        canvases.append(identity)
        return true
    }

    mutating func stageStroke(_ stroke: FixtureDrawingStroke) -> Bool {
        guard state == .active,
            strokes.count < Int(capacity.maximumPlanStrokes)
        else { return false }
        strokes.append(stroke)
        return true
    }

    mutating func seal(
        summary candidate: DrawingPlanSummary
    ) -> DrawingPlanResult {
        guard state == .active, validates(candidate) else {
            return .failure(.invariantViolation)
        }
        publishedSummary = candidate
        state = .sealed
        return .success(candidate)
    }

    mutating func discard() {
        canvases.removeAll(keepingCapacity: true)
        strokes.removeAll(keepingCapacity: true)
        publishedSummary = nil
        state = .discarded
    }

    mutating func reset() {
        canvases.removeAll(keepingCapacity: true)
        strokes.removeAll(keepingCapacity: true)
        publishedSummary = nil
        state = .idle
    }

    func strokeCount(of canvas: UInt16) -> UInt16? {
        guard state == .sealed, canvases.contains(canvas) else { return nil }
        return UInt16(strokes.lazy.filter { $0.canvas == canvas }.count)
    }

    func strokeHeader(
        of canvas: UInt16,
        at index: UInt16
    ) -> StraightLineStrokeHeader? {
        stroke(of: canvas, at: index)?.header
    }

    func point(
        of canvas: UInt16,
        stroke strokeIndex: UInt16,
        at index: UInt16
    ) -> Point? {
        guard let stroke = stroke(of: canvas, at: strokeIndex),
            Int(index) < stroke.points.count
        else { return nil }
        return stroke.points[Int(index)]
    }

    func subpath(
        of canvas: UInt16,
        stroke strokeIndex: UInt16,
        at index: UInt16
    ) -> SubpathRange? {
        guard let stroke = stroke(of: canvas, at: strokeIndex),
            Int(index) < stroke.subpaths.count
        else { return nil }
        return stroke.subpaths[Int(index)]
    }

    private func stroke(
        of canvas: UInt16,
        at index: UInt16
    ) -> FixtureDrawingStroke? {
        guard state == .sealed, canvases.contains(canvas) else { return nil }
        let matches = strokes.lazy.filter { $0.canvas == canvas }
        guard Int(index) < matches.count else { return nil }
        return Array(matches)[Int(index)]
    }

    private func validates(_ candidate: DrawingPlanSummary) -> Bool {
        guard Set(canvases).count == canvases.count,
            candidate.canvasOccurrenceCount == UInt16(canvases.count),
            candidate.strokeCount == UInt16(strokes.count),
            candidate.normalizedStrokeOperationCount == candidate.strokeCount,
            candidate.canvasOccurrenceCount <= capacity.maximumCanvasOccurrences,
            candidate.strokeCount <= capacity.maximumPlanStrokes,
            candidate.pointCount <= capacity.maximumPlanPoints,
            candidate.subpathCount <= capacity.maximumPlanSubpaths,
            candidate.normalizedStrokeOperationCount
                <= capacity.maximumNormalizedStrokeOperations,
            strokes.allSatisfy({ canvases.contains($0.canvas) })
        else { return false }

        var pointCount = 0
        var subpathCount = 0
        for stroke in strokes {
            guard stroke.header.pointCount == UInt16(stroke.points.count),
                stroke.header.subpathCount == UInt16(stroke.subpaths.count),
                stroke.subpaths.allSatisfy({ range in
                    Int(range.firstPoint) + Int(range.pointCount) <= stroke.points.count
                })
            else { return false }
            pointCount += stroke.points.count
            subpathCount += stroke.subpaths.count
        }
        return candidate.pointCount == UInt16(pointCount)
            && candidate.subpathCount == UInt16(subpathCount)
    }
}
