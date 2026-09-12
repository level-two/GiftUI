import GiftUI
import GiftUIRenderCore
import Testing

@testable import GiftUIDrawing

@Test(arguments: FaultingLivePathStorage.Operation.allCases)
func everyPostValidationLivePathStorageRefusalIsInvariantAndUnchanged(
    _ operation: FaultingLivePathStorage.Operation
) {
    var builder = LivePathBuilder(storage: FaultingLivePathStorage(for: operation))
    let before = builder.storage
    let error = captureDrawingError { () throws(DrawingError) in
        switch operation {
        case .startFirst, .replaceStart, .startNext:
            try builder.move(to: Point(x: 101, y: 103))
        case .appendLine:
            try builder.addLine(to: Point(x: 101, y: 103))
        }
    }
    #expect(error == .invariantViolation)
    #expect(builder.storage == before)
}

@Test
func livePathArithmeticOverflowPrecedesStorageMutation() {
    var builder = LivePathBuilder(storage: FaultingLivePathStorage.overflowing)
    let before = builder.storage
    let error = captureDrawingError { () throws(DrawingError) in
        try builder.addLine(to: Point(x: 107, y: 109))
    }
    #expect(error == .arithmeticOverflow)
    #expect(builder.storage == before)
}

@Test
func strokeSnapshotFaultsPreserveTheEntireFormerPlan() throws {
    var path = LivePathBuilder(
        storage: DynamicLivePathStorage(maximumPointCount: 2, maximumSubpathCount: 1)
    )
    try path.move(to: Point(x: 1, y: 2))
    try path.addLine(to: Point(x: 3, y: 5))

    var normalizedMismatch = FaultingPlanStorage(limits: faultLimits)
    normalizedMismatch.reportedStrokeCount = 1
    normalizedMismatch.reportedNormalizedCount = 0
    #expect(
        snapshotError(path.storage, plan: &normalizedMismatch)
            == .invariantViolation
    )
    #expect(normalizedMismatch.appendCount == 0)

    var arithmeticOverflow = FaultingPlanStorage(limits: maximumFaultLimits)
    arithmeticOverflow.reportedStrokeCount = .max
    arithmeticOverflow.reportedNormalizedCount = .max
    #expect(
        snapshotError(path.storage, plan: &arithmeticOverflow)
            == .arithmeticOverflow
    )
    #expect(arithmeticOverflow.appendCount == 0)

    var pointCapacity = FaultingPlanStorage(limits: faultLimits)
    pointCapacity.reportedPointCount = faultLimits.maximumPlanPoints
    #expect(snapshotError(path.storage, plan: &pointCapacity) == .capacityExhausted)
    #expect(pointCapacity.appendCount == 0)

    var subpathCapacity = FaultingPlanStorage(limits: faultLimits)
    subpathCapacity.reportedSubpathCount = faultLimits.maximumPlanSubpaths
    #expect(snapshotError(path.storage, plan: &subpathCapacity) == .capacityExhausted)
    #expect(subpathCapacity.appendCount == 0)

    var appendRefusal = FaultingPlanStorage(limits: faultLimits)
    appendRefusal.acceptsAppend = false
    #expect(snapshotError(path.storage, plan: &appendRefusal) == .invariantViolation)
    #expect(appendRefusal.appendCount == 1)
    #expect(appendRefusal.committedCount == 0)
}

@Test
func invalidWidthStopsBeforePathOrPlanInspection() {
    let counters = DrawingWorkCounters()
    let path = CountingLivePathStorage(base: .onePoint, counters: counters)
    var plan = FaultingPlanStorage(limits: faultLimits)
    let error = captureDrawingError { () throws(DrawingError) in
        try StrokeSnapshotProducer.snapshot(
            path: path,
            shading: .color(.white),
            style: StrokeStyle(lineWidth: 0),
            surfaceOrigin: Point(x: 0, y: 0),
            inheritedClip: faultClip,
            plan: &plan
        )
    }
    #expect(error == .invalidValue)
    #expect(counters.pointLookups == 0)
    #expect(counters.subpathLookups == 0)
    #expect(plan.appendCount == 0)
}

@Test(arguments: [1, 2, 4, 8])
func snapshotWorkIsLinearWithSeparateLiveAndPlanHighWater(_ admittedPoints: Int) throws {
    var base = DynamicLivePathStorage(
        maximumPointCount: UInt16(admittedPoints),
        maximumSubpathCount: 1
    )
    let started = base.startFirstSubpath(at: Point(x: 0, y: 0))
    #expect(started)
    if admittedPoints > 1 {
        for index in 1 ..< admittedPoints {
            let appended = base.appendLine(
                to: Point(x: Int32(index), y: Int32(index))
            )
            #expect(appended)
        }
    }
    let counters = DrawingWorkCounters()
    let path = CountingLivePathStorage(base: base, counters: counters)
    var plan = FixtureSnapshotPlanStorage(limits: workLimits)

    try StrokeSnapshotProducer.snapshot(
        path: path,
        shading: .color(.blue),
        style: StrokeStyle(),
        surfaceOrigin: Point(x: 0, y: 0),
        inheritedClip: faultClip,
        plan: &plan
    )

    #expect(counters.pointLookups == admittedPoints * 2)
    #expect(counters.subpathLookups == 2)
    #expect(path.pointCount == UInt16(admittedPoints))
    #expect(path.subpathCount == 1)
    #expect(plan.strokeCount == 1)
    #expect(plan.pointCount == UInt16(admittedPoints))
    #expect(plan.subpathCount == 1)
}

private func captureDrawingError(
    _ body: () throws(DrawingError) -> Void
) -> DrawingError? {
    do {
        try body()
        return nil
    } catch {
        return error
    }
}

private func snapshotError<PathStorage>(
    _ path: borrowing PathStorage,
    plan: inout FaultingPlanStorage
) -> DrawingError? where PathStorage: LivePathStorage {
    do {
        try StrokeSnapshotProducer.snapshot(
            path: path,
            shading: .color(.red),
            style: StrokeStyle(),
            surfaceOrigin: Point(x: 0, y: 0),
            inheritedClip: faultClip,
            plan: &plan
        )
        return nil
    } catch {
        return error
    }
}

struct FaultingLivePathStorage: LivePathStorage, Equatable {
    enum Operation: CaseIterable, Equatable {
        case startFirst
        case replaceStart
        case startNext
        case appendLine
    }

    let maximumPointCount: UInt16
    let maximumSubpathCount: UInt16
    let pointCount: UInt16
    let subpathCount: UInt16
    let current: SubpathRange?
    let refusedOperation: Operation?

    init(for operation: Operation) {
        maximumPointCount = 4
        maximumSubpathCount = 2
        refusedOperation = operation
        switch operation {
        case .startFirst:
            pointCount = 0
            subpathCount = 0
            current = nil
        case .replaceStart, .appendLine:
            pointCount = 1
            subpathCount = 1
            current = SubpathRange(firstPoint: 0, pointCount: 1)!
        case .startNext:
            pointCount = 2
            subpathCount = 1
            current = SubpathRange(firstPoint: 0, pointCount: 2)!
        }
    }

    private init(
        maximumPointCount: UInt16,
        maximumSubpathCount: UInt16,
        pointCount: UInt16,
        subpathCount: UInt16,
        current: SubpathRange?,
        refusedOperation: Operation?
    ) {
        self.maximumPointCount = maximumPointCount
        self.maximumSubpathCount = maximumSubpathCount
        self.pointCount = pointCount
        self.subpathCount = subpathCount
        self.current = current
        self.refusedOperation = refusedOperation
    }

    static let overflowing = FaultingLivePathStorage(
        maximumPointCount: .max,
        maximumSubpathCount: 1,
        pointCount: .max,
        subpathCount: 1,
        current: SubpathRange(firstPoint: 0, pointCount: .max)!,
        refusedOperation: nil
    )

    func point(at index: UInt16) -> Point? {
        index < pointCount ? Point(x: 0, y: 0) : nil
    }
    func subpath(at index: UInt16) -> SubpathRange? { index == 0 ? current : nil }
    mutating func startFirstSubpath(at point: Point) -> Bool {
        refusedOperation != .startFirst
    }
    mutating func replaceCurrentSubpathStart(with point: Point) -> Bool {
        refusedOperation != .replaceStart
    }
    mutating func startNextSubpath(at point: Point) -> Bool {
        refusedOperation != .startNext
    }
    mutating func appendLine(to point: Point) -> Bool {
        refusedOperation != .appendLine
    }
    mutating func reset() {}
}

private struct FaultingPlanStorage: DrawingPlanMutationStorage {
    let limits: DrawingLimits
    var reportedStrokeCount: UInt16 = 0
    var reportedPointCount: UInt16 = 0
    var reportedSubpathCount: UInt16 = 0
    var reportedNormalizedCount: UInt16 = 0
    var acceptsAppend = true
    private(set) var appendCount = 0
    private(set) var committedCount = 0

    var strokeCount: UInt16 { reportedStrokeCount }
    var pointCount: UInt16 { reportedPointCount }
    var subpathCount: UInt16 { reportedSubpathCount }
    var normalizedStrokeOperationCount: UInt16 { reportedNormalizedCount }

    mutating func appendStroke<PathStorage>(
        header: StraightLineStrokeHeader,
        path: borrowing PathStorage
    ) -> Bool where PathStorage: LivePathStorage {
        appendCount += 1
        guard acceptsAppend else { return false }
        committedCount += 1
        return true
    }
}

private final class DrawingWorkCounters {
    var pointLookups = 0
    var subpathLookups = 0
}

private struct CountingLivePathStorage: LivePathStorage {
    var base: DynamicLivePathStorage
    let counters: DrawingWorkCounters

    var maximumPointCount: UInt16 { base.maximumPointCount }
    var maximumSubpathCount: UInt16 { base.maximumSubpathCount }
    var pointCount: UInt16 { base.pointCount }
    var subpathCount: UInt16 { base.subpathCount }

    func point(at index: UInt16) -> Point? {
        counters.pointLookups += 1
        return base.point(at: index)
    }
    func subpath(at index: UInt16) -> SubpathRange? {
        counters.subpathLookups += 1
        return base.subpath(at: index)
    }
    mutating func startFirstSubpath(at point: Point) -> Bool {
        base.startFirstSubpath(at: point)
    }
    mutating func replaceCurrentSubpathStart(with point: Point) -> Bool {
        base.replaceCurrentSubpathStart(with: point)
    }
    mutating func startNextSubpath(at point: Point) -> Bool {
        base.startNextSubpath(at: point)
    }
    mutating func appendLine(to point: Point) -> Bool {
        base.appendLine(to: point)
    }
    mutating func reset() { base.reset() }
}

private extension DynamicLivePathStorage {
    static var onePoint: Self {
        var storage = Self(maximumPointCount: 1, maximumSubpathCount: 1)
        _ = storage.startFirstSubpath(at: Point(x: 0, y: 0))
        return storage
    }
}

private let faultClip = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 8, height: 8)!
)!

private let faultLimits = DrawingLimits(
    maximumLineWidth: 1,
    maximumCanvasOccurrences: 1,
    maximumLivePathPoints: 4,
    maximumLivePathSubpaths: 2,
    maximumPlanStrokes: 2,
    maximumPlanPoints: 4,
    maximumPlanSubpaths: 2,
    maximumNormalizedStrokeOperations: 2
)!

private let maximumFaultLimits = DrawingLimits(
    maximumLineWidth: 1,
    maximumCanvasOccurrences: 1,
    maximumLivePathPoints: .max,
    maximumLivePathSubpaths: .max,
    maximumPlanStrokes: .max,
    maximumPlanPoints: .max,
    maximumPlanSubpaths: .max,
    maximumNormalizedStrokeOperations: .max
)!

private let workLimits = DrawingLimits(
    maximumLineWidth: 1,
    maximumCanvasOccurrences: 1,
    maximumLivePathPoints: 8,
    maximumLivePathSubpaths: 1,
    maximumPlanStrokes: 1,
    maximumPlanPoints: 8,
    maximumPlanSubpaths: 1,
    maximumNormalizedStrokeOperations: 1
)!
