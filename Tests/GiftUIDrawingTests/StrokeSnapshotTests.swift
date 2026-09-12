import GiftUI
import GiftUIRenderCore
import Testing

@testable import GiftUIDrawing

@Test
func strokeSnapshotsAreOrderedImmutableAndPreserveExplicitSubpaths() throws {
    var path = LivePathBuilder(
        storage: DynamicLivePathStorage(maximumPointCount: 5, maximumSubpathCount: 2)
    )
    var plan = FixtureSnapshotPlanStorage(limits: snapshotLimits)
    try path.move(to: Point(x: 1, y: 2))
    try path.addLine(to: Point(x: 3, y: 4))

    try StrokeSnapshotProducer.snapshot(
        path: path.storage,
        shading: .color(Color(red: 5, green: 6, blue: 7)),
        style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .miter),
        surfaceOrigin: Point(x: 11, y: 13),
        inheritedClip: snapshotClip,
        plan: &plan
    )
    try path.move(to: Point(x: 17, y: 19))
    try path.addLine(to: Point(x: 23, y: 29))
    try StrokeSnapshotProducer.snapshot(
        path: path.storage,
        shading: .color(.red),
        style: StrokeStyle(lineWidth: 3, lineCap: .butt, lineJoin: .round),
        surfaceOrigin: Point(x: 31, y: 37),
        inheritedClip: snapshotClip,
        plan: &plan
    )

    #expect(plan.strokeCount == 2)
    #expect(plan.pointCount == 6)
    #expect(plan.subpathCount == 3)
    #expect(plan.normalizedStrokeOperationCount == 2)
    #expect(plan.records[0].points == [Point(x: 1, y: 2), Point(x: 3, y: 4)])
    #expect(plan.records[0].subpaths == [SubpathRange(firstPoint: 0, pointCount: 2)!])
    #expect(
        plan.records[1].points == [
            Point(x: 1, y: 2), Point(x: 3, y: 4),
            Point(x: 17, y: 19), Point(x: 23, y: 29),
        ])
    #expect(
        plan.records[1].subpaths == [
            SubpathRange(firstPoint: 0, pointCount: 2)!,
            SubpathRange(firstPoint: 2, pointCount: 2)!,
        ])
    #expect(plan.records[0].header.color == Color(red: 5, green: 6, blue: 7))
    #expect(plan.records[1].header.surfaceOrigin == Point(x: 31, y: 37))
}

@Test
func emptyAndOnePointPathsProduceCanonicalOrderedNoOpRecords() throws {
    var plan = FixtureSnapshotPlanStorage(limits: snapshotLimits)
    let empty = DynamicLivePathStorage(maximumPointCount: 2, maximumSubpathCount: 1)
    try StrokeSnapshotProducer.snapshot(
        path: empty,
        shading: .color(.white),
        style: StrokeStyle(),
        surfaceOrigin: Point(x: 0, y: 0),
        inheritedClip: snapshotClip,
        plan: &plan
    )

    var onePoint = LivePathBuilder(
        storage: DynamicLivePathStorage(maximumPointCount: 2, maximumSubpathCount: 1)
    )
    try onePoint.move(to: Point(x: 41, y: 43))
    try StrokeSnapshotProducer.snapshot(
        path: onePoint.storage,
        shading: .color(.blue),
        style: StrokeStyle(),
        surfaceOrigin: Point(x: 0, y: 0),
        inheritedClip: snapshotClip,
        plan: &plan
    )

    #expect(plan.strokeCount == 2)
    #expect(plan.records[0].header.pointCount == 0)
    #expect(plan.records[0].header.subpathCount == 0)
    #expect(plan.records[1].points == [Point(x: 41, y: 43)])
    #expect(plan.records[1].subpaths == [SubpathRange(firstPoint: 0, pointCount: 1)!])
}

@Test
func styleAndWholeSnapshotCapacityFailuresPrecedeMutation() throws {
    var path = LivePathBuilder(
        storage: DynamicLivePathStorage(maximumPointCount: 2, maximumSubpathCount: 1)
    )
    try path.move(to: Point(x: 1, y: 1))
    try path.addLine(to: Point(x: 2, y: 2))
    var plan = FixtureSnapshotPlanStorage(limits: oneStrokeLimits)

    for width: GeometryScalar in [0, -1] {
        #expect(throws: DrawingError.invalidValue) {
            try snapshot(path.storage, width: width, plan: &plan)
        }
        #expect(plan.records.isEmpty)
    }
    #expect(throws: DrawingError.capacityExhausted) {
        try snapshot(path.storage, width: 5, plan: &plan)
    }
    #expect(plan.records.isEmpty)

    try snapshot(path.storage, width: 4, plan: &plan)
    let accepted = plan.records
    #expect(throws: DrawingError.capacityExhausted) {
        try snapshot(path.storage, width: 4, plan: &plan)
    }
    #expect(plan.records == accepted)
}

@Test
func malformedLivePathFailsBeforePlanMutation() {
    let malformed = MissingPointLivePathStorage()
    var plan = FixtureSnapshotPlanStorage(limits: snapshotLimits)
    #expect(throws: DrawingError.invariantViolation) {
        try snapshot(malformed, width: 1, plan: &plan)
    }
    #expect(plan.records.isEmpty)
}

private struct FixtureSnapshotRecord: Equatable {
    let header: StraightLineStrokeHeader
    let points: [Point]
    let subpaths: [SubpathRange]
}

private struct FixtureSnapshotPlanStorage: DrawingPlanMutationStorage {
    let limits: DrawingLimits
    private(set) var records: [FixtureSnapshotRecord] = []

    var strokeCount: UInt16 { UInt16(records.count) }
    var pointCount: UInt16 { UInt16(records.reduce(0) { $0 + $1.points.count }) }
    var subpathCount: UInt16 { UInt16(records.reduce(0) { $0 + $1.subpaths.count }) }
    var normalizedStrokeOperationCount: UInt16 { strokeCount }

    mutating func appendStroke<PathStorage>(
        header: StraightLineStrokeHeader,
        path: borrowing PathStorage
    ) -> Bool where PathStorage: LivePathStorage {
        var points: [Point] = []
        var pointIndex: UInt16 = 0
        while pointIndex < path.pointCount {
            guard let point = path.point(at: pointIndex) else { return false }
            points.append(point)
            pointIndex += 1
        }
        var subpaths: [SubpathRange] = []
        var subpathIndex: UInt16 = 0
        while subpathIndex < path.subpathCount {
            guard let subpath = path.subpath(at: subpathIndex) else { return false }
            subpaths.append(subpath)
            subpathIndex += 1
        }
        records.append(
            FixtureSnapshotRecord(header: header, points: points, subpaths: subpaths)
        )
        return true
    }
}

private struct MissingPointLivePathStorage: LivePathStorage {
    let maximumPointCount: UInt16 = 2
    let maximumSubpathCount: UInt16 = 1
    let pointCount: UInt16 = 2
    let subpathCount: UInt16 = 1

    func point(at index: UInt16) -> Point? { index == 0 ? Point(x: 0, y: 0) : nil }
    func subpath(at index: UInt16) -> SubpathRange? {
        index == 0 ? SubpathRange(firstPoint: 0, pointCount: 2) : nil
    }
    mutating func startFirstSubpath(at point: Point) -> Bool { false }
    mutating func replaceCurrentSubpathStart(with point: Point) -> Bool { false }
    mutating func startNextSubpath(at point: Point) -> Bool { false }
    mutating func appendLine(to point: Point) -> Bool { false }
    mutating func reset() {}
}

private let snapshotClip = Rect(
    origin: Point(x: -5, y: -7),
    size: Size(width: 101, height: 103)!
)!

private let snapshotLimits = DrawingLimits(
    maximumLineWidth: 4,
    maximumCanvasOccurrences: 2,
    maximumLivePathPoints: 5,
    maximumLivePathSubpaths: 2,
    maximumPlanStrokes: 4,
    maximumPlanPoints: 12,
    maximumPlanSubpaths: 6,
    maximumNormalizedStrokeOperations: 4
)!

private let oneStrokeLimits = DrawingLimits(
    maximumLineWidth: 4,
    maximumCanvasOccurrences: 1,
    maximumLivePathPoints: 2,
    maximumLivePathSubpaths: 1,
    maximumPlanStrokes: 1,
    maximumPlanPoints: 2,
    maximumPlanSubpaths: 1,
    maximumNormalizedStrokeOperations: 1
)!

private func snapshot<PathStorage>(
    _ path: borrowing PathStorage,
    width: GeometryScalar,
    plan: inout FixtureSnapshotPlanStorage
) throws where PathStorage: LivePathStorage {
    try StrokeSnapshotProducer.snapshot(
        path: path,
        shading: .color(.white),
        style: StrokeStyle(lineWidth: width),
        surfaceOrigin: Point(x: 0, y: 0),
        inheritedClip: snapshotClip,
        plan: &plan
    )
}
