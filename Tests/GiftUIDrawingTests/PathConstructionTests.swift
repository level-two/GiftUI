import GiftUI
import GiftUIRenderCore
import Testing

@testable import GiftUIDrawing

@Test
func livePathMutationHasTheSameExactDynamicAndStaticTranscript() throws {
    var dynamic = LivePathBuilder(
        storage: DynamicLivePathStorage(maximumPointCount: 4, maximumSubpathCount: 2)
    )
    var fixed = LivePathBuilder(
        storage: StaticLivePathStorage(maximumPointCount: 4, maximumSubpathCount: 2)!
    )

    try exerciseLivePath(&dynamic)
    try exerciseLivePath(&fixed)
    #expect(transcript(dynamic.storage) == transcript(fixed.storage))
}

@Test
func livePathRejectsMissingCurrentPointAndEachFirstExcessAtomically() throws {
    var noCurrent = LivePathBuilder(
        storage: DynamicLivePathStorage(maximumPointCount: 2, maximumSubpathCount: 1)
    )
    #expect(throws: DrawingError.invalidPathState) {
        try noCurrent.addLine(to: Point(x: 1, y: 1))
    }
    #expect(noCurrent.storage.pointCount == 0)
    #expect(noCurrent.storage.subpathCount == 0)

    try noCurrent.move(to: Point(x: 2, y: 2))
    try noCurrent.addLine(to: Point(x: 3, y: 3))
    let beforePointExcess = transcript(noCurrent.storage)
    #expect(throws: DrawingError.capacityExhausted) {
        try noCurrent.addLine(to: Point(x: 4, y: 4))
    }
    #expect(transcript(noCurrent.storage) == beforePointExcess)

    var subpathLimited = LivePathBuilder(
        storage: DynamicLivePathStorage(maximumPointCount: 4, maximumSubpathCount: 1)
    )
    try subpathLimited.move(to: Point(x: 5, y: 5))
    try subpathLimited.addLine(to: Point(x: 6, y: 6))
    let beforeSubpathExcess = transcript(subpathLimited.storage)
    #expect(throws: DrawingError.capacityExhausted) {
        try subpathLimited.move(to: Point(x: 7, y: 7))
    }
    #expect(transcript(subpathLimited.storage) == beforeSubpathExcess)
}

private func exerciseLivePath<Storage>(
    _ builder: inout LivePathBuilder<Storage>
) throws where Storage: LivePathStorage {
    try builder.move(to: Point(x: 1, y: 1))
    try builder.move(to: Point(x: 2, y: 2))
    #expect(builder.storage.pointCount == 1)
    #expect(builder.storage.subpathCount == 1)
    #expect(builder.storage.point(at: 0) == Point(x: 2, y: 2))

    try builder.addLine(to: Point(x: 2, y: 2))
    let snapshotBeforeFurtherMutation = transcript(builder.storage)
    #expect(snapshotBeforeFurtherMutation.points.count == 2)
    #expect(snapshotBeforeFurtherMutation.subpaths == [SubpathRange(firstPoint: 0, pointCount: 2)!])

    try builder.move(to: Point(x: 3, y: 3))
    try builder.addLine(to: Point(x: 4, y: 4))
    #expect(builder.storage.pointCount == 4)
    #expect(builder.storage.subpathCount == 2)
    #expect(builder.storage.subpath(at: 0) == SubpathRange(firstPoint: 0, pointCount: 2))
    #expect(builder.storage.subpath(at: 1) == SubpathRange(firstPoint: 2, pointCount: 2))
    #expect(snapshotBeforeFurtherMutation.points.count == 2)

    builder.reset()
    #expect(builder.storage.pointCount == 0)
    #expect(builder.storage.subpathCount == 0)
    #expect(builder.storage.point(at: 0) == nil)
    #expect(builder.storage.subpath(at: 0) == nil)
}

private struct LivePathTranscript: Equatable {
    let points: [Point]
    let subpaths: [SubpathRange]
}

private func transcript<Storage>(
    _ storage: Storage
) -> LivePathTranscript where Storage: LivePathStorage {
    var points: [Point] = []
    var pointIndex: UInt16 = 0
    while pointIndex < storage.pointCount {
        if let point = storage.point(at: pointIndex) {
            points.append(point)
        }
        pointIndex += 1
    }
    var subpaths: [SubpathRange] = []
    var subpathIndex: UInt16 = 0
    while subpathIndex < storage.subpathCount {
        if let subpath = storage.subpath(at: subpathIndex) {
            subpaths.append(subpath)
        }
        subpathIndex += 1
    }
    return LivePathTranscript(points: points, subpaths: subpaths)
}

private struct DynamicLivePathStorage: LivePathStorage {
    let maximumPointCount: UInt16
    let maximumSubpathCount: UInt16
    private var points: [Point] = []
    private var subpaths: [SubpathRange] = []

    init(maximumPointCount: UInt16, maximumSubpathCount: UInt16) {
        self.maximumPointCount = maximumPointCount
        self.maximumSubpathCount = maximumSubpathCount
    }

    var pointCount: UInt16 { UInt16(points.count) }
    var subpathCount: UInt16 { UInt16(subpaths.count) }

    func point(at index: UInt16) -> Point? {
        guard Int(index) < points.count else { return nil }
        return points[Int(index)]
    }

    func subpath(at index: UInt16) -> SubpathRange? {
        guard Int(index) < subpaths.count else { return nil }
        return subpaths[Int(index)]
    }

    mutating func startFirstSubpath(at point: Point) -> Bool {
        guard points.isEmpty, subpaths.isEmpty else { return false }
        points.append(point)
        subpaths.append(SubpathRange(firstPoint: 0, pointCount: 1)!)
        return true
    }

    mutating func replaceCurrentSubpathStart(with point: Point) -> Bool {
        guard subpaths.last?.pointCount == 1, !points.isEmpty else { return false }
        points[points.count - 1] = point
        return true
    }

    mutating func startNextSubpath(at point: Point) -> Bool {
        guard pointCount < maximumPointCount, subpathCount < maximumSubpathCount else {
            return false
        }
        let firstPoint = pointCount
        points.append(point)
        subpaths.append(SubpathRange(firstPoint: firstPoint, pointCount: 1)!)
        return true
    }

    mutating func appendLine(to point: Point) -> Bool {
        guard pointCount < maximumPointCount, let current = subpaths.last else {
            return false
        }
        points.append(point)
        subpaths[subpaths.count - 1] = SubpathRange(
            firstPoint: current.firstPoint,
            pointCount: current.pointCount + 1
        )!
        return true
    }

    mutating func reset() {
        points.removeAll(keepingCapacity: true)
        subpaths.removeAll(keepingCapacity: true)
    }
}

private struct StaticLivePathStorage: LivePathStorage {
    let maximumPointCount: UInt16
    let maximumSubpathCount: UInt16
    private var storedPointCount: UInt16 = 0
    private var storedSubpathCount: UInt16 = 0
    private var points = (
        Point(x: 0, y: 0), Point(x: 0, y: 0),
        Point(x: 0, y: 0), Point(x: 0, y: 0)
    )
    private var subpaths = (
        SubpathRange(firstPoint: 0, pointCount: 1)!,
        SubpathRange(firstPoint: 0, pointCount: 1)!
    )

    init?(maximumPointCount: UInt16, maximumSubpathCount: UInt16) {
        guard maximumPointCount > 0, maximumPointCount <= 4,
            maximumSubpathCount > 0, maximumSubpathCount <= 2
        else { return nil }
        self.maximumPointCount = maximumPointCount
        self.maximumSubpathCount = maximumSubpathCount
    }

    var pointCount: UInt16 { storedPointCount }
    var subpathCount: UInt16 { storedSubpathCount }

    func point(at index: UInt16) -> Point? {
        guard index < storedPointCount else { return nil }
        return switch index {
        case 0: points.0
        case 1: points.1
        case 2: points.2
        case 3: points.3
        default: nil
        }
    }

    func subpath(at index: UInt16) -> SubpathRange? {
        guard index < storedSubpathCount else { return nil }
        return switch index {
        case 0: subpaths.0
        case 1: subpaths.1
        default: nil
        }
    }

    mutating func startFirstSubpath(at point: Point) -> Bool {
        guard storedPointCount == 0, storedSubpathCount == 0 else { return false }
        setPoint(point, at: 0)
        setSubpath(SubpathRange(firstPoint: 0, pointCount: 1)!, at: 0)
        storedPointCount = 1
        storedSubpathCount = 1
        return true
    }

    mutating func replaceCurrentSubpathStart(with point: Point) -> Bool {
        guard storedPointCount > 0,
            subpath(at: storedSubpathCount - 1)?.pointCount == 1
        else { return false }
        setPoint(point, at: storedPointCount - 1)
        return true
    }

    mutating func startNextSubpath(at point: Point) -> Bool {
        guard storedPointCount < maximumPointCount,
            storedSubpathCount < maximumSubpathCount
        else { return false }
        setPoint(point, at: storedPointCount)
        setSubpath(
            SubpathRange(firstPoint: storedPointCount, pointCount: 1)!,
            at: storedSubpathCount
        )
        storedPointCount += 1
        storedSubpathCount += 1
        return true
    }

    mutating func appendLine(to point: Point) -> Bool {
        guard storedPointCount < maximumPointCount,
            let current = subpath(at: storedSubpathCount - 1)
        else { return false }
        setPoint(point, at: storedPointCount)
        setSubpath(
            SubpathRange(
                firstPoint: current.firstPoint,
                pointCount: current.pointCount + 1
            )!,
            at: storedSubpathCount - 1
        )
        storedPointCount += 1
        return true
    }

    mutating func reset() {
        storedPointCount = 0
        storedSubpathCount = 0
    }

    private mutating func setPoint(_ point: Point, at index: UInt16) {
        switch index {
        case 0: points.0 = point
        case 1: points.1 = point
        case 2: points.2 = point
        case 3: points.3 = point
        default: break
        }
    }

    private mutating func setSubpath(_ subpath: SubpathRange, at index: UInt16) {
        switch index {
        case 0: subpaths.0 = subpath
        case 1: subpaths.1 = subpath
        default: break
        }
    }
}
