import GiftUI
import GiftUIExecution
import GiftUILayout
import GiftUIRenderCore
import Testing

@testable import GiftUIDrawing

@Test
func canvasPlanProducerValidatesOrderAndInvokesWithExactLayoutValues() {
    let identities: [UInt16] = [20, 40]
    var source = CanvasPlanSourceFixture(identities: identities)
    let layout = CanvasPlanLayoutFixture(
        records: [
            canvasLayoutRecord(identity: 10, x: 0, y: 0, width: 1, height: 1),
            canvasLayoutRecord(identity: 20, x: 2, y: 3, width: 5, height: 7),
            canvasLayoutRecord(identity: 30, x: 0, y: 0, width: 1, height: 1),
            canvasLayoutRecord(identity: 40, x: 11, y: 13, width: 17, height: 19),
        ]
    )
    var workspace = CanvasPlanConstructionFixture(capacity: canvasPlanLimits)

    let result = CanvasPlanProducer.derive(
        source: &source,
        layout: layout,
        executionContext: derivingContext,
        limits: canvasPlanLimits,
        workspace: &workspace
    )

    #expect(
        result
            == .success(
                DrawingPlanSummary(
                    canvasOccurrenceCount: 2,
                    strokeCount: 0,
                    pointCount: 0,
                    subpathCount: 0,
                    normalizedStrokeOperationCount: 0
                )
            )
    )
    #expect(source.invokedIdentities == identities)
    #expect(source.invokedSizes == [Size(width: 5, height: 7)!, Size(width: 17, height: 19)!])
    #expect(source.releasedIdentities == identities)
    #expect(workspace.contextIdentities == identities)
    #expect(workspace.surfaceOrigins == [Point(x: 2, y: 3), Point(x: 11, y: 13)])
    #expect(workspace.inheritedClips == [layout.records[1].clip, layout.records[3].clip])
    #expect(workspace.sealCount == 1)
    #expect(workspace.discardCount == 0)
    #expect(workspace.resetCount == 0)
}

@Test
func canvasPlanProducerAdmitsTheFirstDerivationWithoutAPublishedRevision() {
    var source = CanvasPlanSourceFixture(identities: [20])
    let layout = CanvasPlanLayoutFixture(
        records: [canvasLayoutRecord(identity: 20, x: 2, y: 3, width: 5, height: 7)]
    )
    var workspace = CanvasPlanConstructionFixture(capacity: canvasPlanLimits)
    let context = ExecutionContext(
        cycle: RunCycleID(rawValue: 1),
        semanticRevision: nil,
        candidateFrame: nil,
        phase: .deriving
    )

    let result = CanvasPlanProducer.derive(
        source: &source,
        layout: layout,
        executionContext: context,
        limits: canvasPlanLimits,
        workspace: &workspace
    )

    #expect(source.invokedIdentities == [20])
    #expect(source.releasedIdentities == [20])
    guard case .success(let summary) = result else {
        Issue.record("first derivation must accept a nil semantic revision")
        return
    }
    #expect(summary.canvasOccurrenceCount == 1)
}

@Test
func canvasPlanProducerSealsAnEmptyAttemptWithoutInvokingOrRetainingACallable() {
    var source = CanvasPlanSourceFixture(identities: [])
    let layout = CanvasPlanLayoutFixture(records: [])
    var workspace = CanvasPlanConstructionFixture(capacity: canvasPlanLimits)

    let result = CanvasPlanProducer.derive(
        source: &source,
        layout: layout,
        executionContext: derivingContext,
        limits: canvasPlanLimits,
        workspace: &workspace
    )

    #expect(
        result
            == .success(
                DrawingPlanSummary(
                    canvasOccurrenceCount: 0,
                    strokeCount: 0,
                    pointCount: 0,
                    subpathCount: 0,
                    normalizedStrokeOperationCount: 0
                )
            )
    )
    #expect(source.invokedIdentities.isEmpty)
    #expect(source.releasedIdentities.isEmpty)
    #expect(source.activeIdentities.isEmpty)
    #expect(workspace.contextBodyCount == 0)
    #expect(workspace.sealCount == 1)
}

@Test
func canvasPlanProducerReleasesEachCallableOnceOnLaterThrowAndInvokesNoSuffix() {
    var source = CanvasPlanSourceFixture(
        identities: [20, 40, 60],
        errorAtIndex: 1,
        error: .invalidValue
    )
    let layout = CanvasPlanLayoutFixture(
        records: [20, 40, 60].map {
            canvasLayoutRecord(identity: $0, x: 0, y: 0, width: 1, height: 1)
        }
    )
    var workspace = CanvasPlanConstructionFixture(capacity: canvasPlanWideLimits)

    let result = CanvasPlanProducer.derive(
        source: &source,
        layout: layout,
        executionContext: derivingContext,
        limits: canvasPlanWideLimits,
        workspace: &workspace
    )

    #expect(result == .failure(.invalidValue))
    #expect(source.invokedIdentities == [20, 40])
    #expect(source.releasedIdentities == [20, 40, 60])
    #expect(source.releaseCounts == [20: 1, 40: 1, 60: 1])
    #expect(source.activeIdentities.isEmpty)
    #expect(workspace.discardCount == 1)
    #expect(workspace.resetCount == 1)
}

@Test
func canvasPlanProducerTranslatesSnapshotsOnceAndPreservesOriginAndClip() {
    var source = CanvasPlanSourceFixture(identities: [20], drawing: .stroke)
    let record = canvasLayoutRecord(identity: 20, x: 10, y: 20, width: 30, height: 40)
    let layout = CanvasPlanLayoutFixture(records: [record])
    var workspace = CanvasPlanConstructionFixture(capacity: canvasPlanLimits)

    let result = CanvasPlanProducer.derive(
        source: &source,
        layout: layout,
        executionContext: derivingContext,
        limits: canvasPlanLimits,
        workspace: &workspace
    )

    guard case .success(let summary) = result else {
        Issue.record("translated drawing plan must succeed")
        return
    }
    #expect(summary.strokeCount == 1)
    #expect(summary.pointCount == 2)
    #expect(summary.subpathCount == 1)
    #expect(summary.normalizedStrokeOperationCount == 1)
    #expect(workspace.strokeHeader(of: 20, at: 0)?.surfaceOrigin == Point(x: 10, y: 20))
    #expect(workspace.strokeHeader(of: 20, at: 0)?.inheritedClip == record.clip)
    #expect(workspace.point(of: 20, stroke: 0, at: 0) == Point(x: 11, y: 22))
    #expect(workspace.point(of: 20, stroke: 0, at: 1) == Point(x: 13, y: 24))
    #expect(
        workspace.subpath(of: 20, stroke: 0, at: 0) == SubpathRange(firstPoint: 0, pointCount: 2))
}

@Test
func canvasPlanProducerDiscardsTheWholePlanOnTranslationOverflow() {
    var source = CanvasPlanSourceFixture(identities: [20], drawing: .overflow)
    let bounds = Rect(
        origin: Point(x: GeometryScalar.max, y: 0),
        size: Size(width: 0, height: 0)!
    )!
    let layout = CanvasPlanLayoutFixture(
        records: [CanvasPlanLayoutRecord(identity: 20, bounds: bounds, clip: zeroRect)]
    )
    var workspace = CanvasPlanConstructionFixture(capacity: canvasPlanLimits)

    let result = CanvasPlanProducer.derive(
        source: &source,
        layout: layout,
        executionContext: derivingContext,
        limits: canvasPlanLimits,
        workspace: &workspace
    )

    #expect(result == .failure(.arithmeticOverflow))
    #expect(source.releasedIdentities == [20])
    #expect(workspace.discardCount == 1)
    #expect(workspace.resetCount == 1)
    #expect(workspace.strokeCount(of: 20) == nil)
}

@Test(arguments: CanvasPlanEntryFailure.allCases)
private func canvasPlanProducerRejectsInvalidEntryBeforeClientInvocation(
    _ failure: CanvasPlanEntryFailure
) {
    var source = CanvasPlanSourceFixture(identities: [20])
    let layout = CanvasPlanLayoutFixture(
        records: [canvasLayoutRecord(identity: 20, x: 2, y: 3, width: 5, height: 7)]
    )
    var workspace = CanvasPlanConstructionFixture(capacity: canvasPlanLimits)
    if failure == .workspaceReentry {
        _ = workspace.acquire()
    }

    let result = CanvasPlanProducer.derive(
        source: &source,
        layout: layout,
        executionContext: failure.context,
        limits: canvasPlanLimits,
        workspace: &workspace
    )

    #expect(result == .failure(failure.expectedError))
    #expect(source.invokedIdentities.isEmpty)
    #expect(source.releasedIdentities.isEmpty)
}

@Test(arguments: CanvasPlanIdentityFailure.allCases)
private func canvasPlanProducerRejectsIncompleteOrNonPainterOrderedIdentityCoverage(
    _ failure: CanvasPlanIdentityFailure
) {
    var source = CanvasPlanSourceFixture(identities: failure.sourceIdentities)
    source.reportedCountOverride = failure.reportedCount
    let layout = CanvasPlanLayoutFixture(records: failure.layoutRecords)
    var workspace = CanvasPlanConstructionFixture(capacity: canvasPlanLimits)

    let result = CanvasPlanProducer.derive(
        source: &source,
        layout: layout,
        executionContext: derivingContext,
        limits: canvasPlanLimits,
        workspace: &workspace
    )

    #expect(result == .failure(failure.expectedError))
    #expect(source.invokedIdentities.isEmpty)
    #expect(workspace.discardCount == 1)
    #expect(workspace.resetCount == 1)
    #expect(!workspace.isActive)
}

@Test(arguments: CanvasClientViolation.allCases)
private func canvasPlanProducerStopsAfterTheFirstDetectableClientViolation(
    _ violation: CanvasClientViolation
) {
    var source = CanvasPlanSourceFixture(
        identities: [20, 40],
        errorAtIndex: 0,
        error: violation.error
    )
    let layout = CanvasPlanLayoutFixture(
        records: [
            canvasLayoutRecord(identity: 20, x: 0, y: 0, width: 1, height: 1),
            canvasLayoutRecord(identity: 40, x: 0, y: 0, width: 1, height: 1),
        ]
    )
    var workspace = CanvasPlanConstructionFixture(capacity: canvasPlanLimits)

    let result = CanvasPlanProducer.derive(
        source: &source,
        layout: layout,
        executionContext: derivingContext,
        limits: canvasPlanLimits,
        workspace: &workspace
    )

    #expect(result == .failure(violation.expectedError))
    #expect(source.invokedIdentities == [20])
    #expect(source.releasedIdentities == [20, 40])
    #expect(workspace.contextBodyCount == 1)
    #expect(workspace.discardCount == 1)
    #expect(workspace.resetCount == 1)
}

private enum CanvasClientViolation: CaseIterable {
    case observedStateMutation
    case actionDispatch
    case factSubmission
    case wakeRequest
    case capabilityQuery
    case backendQuery
    case cycleStart
    case cycleReentry

    var error: DrawingError {
        self == .cycleReentry ? .reentrancyViolation : .invalidPhase
    }

    var expectedError: DrawingProductionError {
        self == .cycleReentry ? .reentrancyViolation : .invalidPhase
    }
}

private enum CanvasPlanEntryFailure: CaseIterable, Equatable {
    case workspaceReentry
    case wrongPhase
    case absentCycle
    case existingCandidate

    var context: ExecutionContext {
        switch self {
        case .workspaceReentry:
            derivingContext
        case .wrongPhase:
            ExecutionContext(
                cycle: RunCycleID(rawValue: 1),
                semanticRevision: nil,
                candidateFrame: nil,
                phase: .publishing
            )
        case .absentCycle:
            ExecutionContext(
                cycle: nil,
                semanticRevision: nil,
                candidateFrame: nil,
                phase: .deriving
            )
        case .existingCandidate:
            ExecutionContext(
                cycle: RunCycleID(rawValue: 1),
                semanticRevision: SemanticRevision(rawValue: 4),
                candidateFrame: CandidateFrameID(rawValue: 2),
                phase: .deriving
            )
        }
    }

    var expectedError: DrawingProductionError {
        self == .workspaceReentry ? .reentrancyViolation : .invalidPhase
    }
}

private enum CanvasPlanIdentityFailure: CaseIterable, Equatable {
    case duplicate
    case missingLayout
    case reversePainterOrder
    case missingInRangeIdentity
    case overLimit

    var sourceIdentities: [UInt16] {
        switch self {
        case .duplicate: [20, 20]
        case .missingLayout: [20, 40]
        case .reversePainterOrder: [40, 20]
        case .missingInRangeIdentity: [20]
        case .overLimit: [10, 20, 30]
        }
    }

    var reportedCount: UInt16? {
        self == .missingInRangeIdentity ? 2 : nil
    }

    var layoutRecords: [CanvasPlanLayoutRecord] {
        switch self {
        case .missingLayout, .missingInRangeIdentity:
            [canvasLayoutRecord(identity: 20, x: 0, y: 0, width: 1, height: 1)]
        default:
            [
                canvasLayoutRecord(identity: 10, x: 0, y: 0, width: 1, height: 1),
                canvasLayoutRecord(identity: 20, x: 0, y: 0, width: 1, height: 1),
                canvasLayoutRecord(identity: 30, x: 0, y: 0, width: 1, height: 1),
                canvasLayoutRecord(identity: 40, x: 0, y: 0, width: 1, height: 1),
            ]
        }
    }

    var expectedError: DrawingProductionError {
        self == .overLimit ? .capacityExhausted : .invariantViolation
    }
}

private struct CanvasPlanSourceFixture: CanvasInvocationSource {
    let identities: [UInt16]
    var reportedCountOverride: UInt16?
    let errorAtIndex: UInt16?
    let error: DrawingError?
    let drawing: CanvasPlanDrawing
    var invokedIdentities: [UInt16] = []
    var invokedSizes: [Size] = []
    var releasedIdentities: [UInt16] = []
    var releaseCounts: [UInt16: Int] = [:]
    var activeIdentities: Set<UInt16>

    init(
        identities: [UInt16],
        reportedCountOverride: UInt16? = nil,
        errorAtIndex: UInt16? = nil,
        error: DrawingError? = nil,
        drawing: CanvasPlanDrawing = .none
    ) {
        self.identities = identities
        self.reportedCountOverride = reportedCountOverride
        self.errorAtIndex = errorAtIndex
        self.error = error
        self.drawing = drawing
        activeIdentities = Set(identities)
    }

    var canvasOccurrenceCount: UInt16 {
        reportedCountOverride ?? UInt16(identities.count)
    }

    func canvasIdentity(at index: UInt16) -> UInt16? {
        guard Int(index) < identities.count else { return nil }
        return identities[Int(index)]
    }

    mutating func invokeCanvas(
        at identity: UInt16,
        context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError) {
        guard activeIdentities.contains(identity) else {
            throw DrawingError.invariantViolation
        }
        let index = UInt16(invokedIdentities.count)
        invokedIdentities.append(identity)
        invokedSizes.append(size)
        if index == errorAtIndex, let error {
            throw error
        }
        switch drawing {
        case .none:
            break
        case .stroke:
            try context.withPath { (context, path) throws(DrawingError) in
                try path.move(to: Point(x: 1, y: 2))
                try path.addLine(to: Point(x: 3, y: 4))
                try context.stroke(
                    path,
                    with: .color(.blue),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                )
            }
        case .overflow:
            try context.withPath { (context, path) throws(DrawingError) in
                try path.move(to: Point(x: 1, y: 0))
                try context.stroke(path, with: .color(.red), lineWidth: 1)
            }
        }
    }

    mutating func releaseCanvas(at identity: UInt16) {
        releasedIdentities.append(identity)
        releaseCounts[identity, default: 0] += 1
        activeIdentities.remove(identity)
    }
}

private enum CanvasPlanDrawing {
    case none
    case stroke
    case overflow
}

private struct CanvasPlanLayoutRecord {
    let identity: UInt16
    let bounds: Rect
    let clip: Rect
}

private struct CanvasPlanLayoutFixture: ResolvedRenderLayoutView {
    let records: [CanvasPlanLayoutRecord]
    var rootIdentity: UInt16 { records.first?.identity ?? 0 }
    var layoutScopeCount: UInt16 { UInt16(records.count) }
    let renderSnapshotVersion: UInt32 = 1
    var rootBounds: Rect { records.first?.bounds ?? zeroRect }

    func layoutIdentity(at ordinal: UInt16) -> UInt16? {
        guard Int(ordinal) < records.count else { return nil }
        return records[Int(ordinal)].identity
    }

    func layoutOrdinal(of identity: UInt16) -> UInt16? {
        records.firstIndex(where: { $0.identity == identity }).map(UInt16.init)
    }

    func bounds(of identity: UInt16) -> Rect? {
        records.first(where: { $0.identity == identity })?.bounds
    }

    func clip(of identity: UInt16) -> Rect? {
        records.first(where: { $0.identity == identity })?.clip
    }

    func textLineCount(of _: UInt16) -> UInt16? { 0 }
    func textLine(of _: UInt16, at _: UInt16) -> ResolvedRenderTextLine? { nil }
    func glyph(of _: UInt16, at _: UInt16) -> ResolvedRenderGlyph? { nil }
}

private struct CanvasPlanConstructionFixture: DrawingPlanConstructionWorkspace,
    DrawingPlanMutationStorage
{
    let capacity: DrawingLimits
    private(set) var isActive = false
    private var publishedSummary: DrawingPlanSummary?
    private(set) var contextIdentities: [UInt16] = []
    private(set) var surfaceOrigins: [Point] = []
    private(set) var inheritedClips: [Rect] = []
    private(set) var contextBodyCount = 0
    private(set) var sealCount = 0
    private(set) var discardCount = 0
    private(set) var resetCount = 0
    private var currentIdentity: UInt16?
    private var currentOrigin: Point?
    private var currentClip: Rect?
    private var livePath: LivePathBuilder<DynamicLivePathStorage>?
    private var strokes: [CanvasPlanStrokeFixture] = []

    init(capacity: DrawingLimits) {
        self.capacity = capacity
    }

    var summary: DrawingPlanSummary {
        publishedSummary!
    }

    var limits: DrawingLimits { capacity }
    var strokeCount: UInt16 { UInt16(strokes.count) }
    var pointCount: UInt16 { UInt16(strokes.reduce(0) { $0 + $1.points.count }) }
    var subpathCount: UInt16 { UInt16(strokes.reduce(0) { $0 + $1.subpaths.count }) }
    var normalizedStrokeOperationCount: UInt16 { strokeCount }

    mutating func acquire() -> Bool {
        guard !isActive, publishedSummary == nil else { return false }
        isActive = true
        return true
    }

    mutating func withCanvasContext<Result>(
        identity: UInt16,
        surfaceOrigin: Point,
        inheritedClip: Rect,
        _ body: (inout GraphicsContext) throws(DrawingError) -> Result
    ) throws(DrawingError) -> Result {
        guard isActive, !contextIdentities.contains(identity) else {
            throw DrawingError.invariantViolation
        }
        contextIdentities.append(identity)
        surfaceOrigins.append(surfaceOrigin)
        inheritedClips.append(inheritedClip)
        contextBodyCount += 1
        currentIdentity = identity
        currentOrigin = surfaceOrigin
        currentClip = inheritedClip
        let contextGeneration = UInt32(contextBodyCount)
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
                    generation: contextGeneration,
                    operations: canvasPlanDrawingOperations
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

    mutating func seal(canvasOccurrenceCount: UInt16) -> DrawingPlanResult {
        sealCount += 1
        guard isActive,
            canvasOccurrenceCount == UInt16(contextIdentities.count),
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

    mutating func discard() {
        discardCount += 1
        publishedSummary = nil
        isActive = false
        strokes.removeAll(keepingCapacity: true)
    }

    mutating func reset() {
        resetCount += 1
        publishedSummary = nil
        isActive = false
        contextIdentities.removeAll(keepingCapacity: true)
        surfaceOrigins.removeAll(keepingCapacity: true)
        inheritedClips.removeAll(keepingCapacity: true)
        strokes.removeAll(keepingCapacity: true)
    }

    func strokeCount(of canvas: UInt16) -> UInt16? {
        guard publishedSummary != nil, contextIdentities.contains(canvas) else { return nil }
        return UInt16(strokes.filter { $0.canvas == canvas }.count)
    }

    func strokeHeader(of canvas: UInt16, at index: UInt16) -> StraightLineStrokeHeader? {
        stroke(of: canvas, at: index)?.header
    }

    func point(of canvas: UInt16, stroke strokeIndex: UInt16, at index: UInt16) -> Point? {
        guard let stroke = stroke(of: canvas, at: strokeIndex), Int(index) < stroke.points.count
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

    mutating func appendStroke<PathStorage>(
        header: StraightLineStrokeHeader,
        path: borrowing PathStorage
    ) -> Bool where PathStorage: LivePathStorage {
        guard let canvas = currentIdentity, let origin = currentOrigin else { return false }
        var points: [Point] = []
        var pointIndex: UInt16 = 0
        while pointIndex < path.pointCount {
            guard let point = path.point(at: pointIndex) else { return false }
            let translatedX = point.x.addingReportingOverflow(origin.x)
            let translatedY = point.y.addingReportingOverflow(origin.y)
            guard !translatedX.overflow, !translatedY.overflow else { return false }
            points.append(Point(x: translatedX.partialValue, y: translatedY.partialValue))
            pointIndex += 1
        }
        var subpaths: [SubpathRange] = []
        var subpathIndex: UInt16 = 0
        while subpathIndex < path.subpathCount {
            guard let subpath = path.subpath(at: subpathIndex) else { return false }
            subpaths.append(subpath)
            subpathIndex += 1
        }
        strokes.append(
            CanvasPlanStrokeFixture(
                canvas: canvas,
                header: header,
                points: points,
                subpaths: subpaths
            )
        )
        return true
    }

    mutating func beginPath(
        contextGeneration: UInt32,
        pathGeneration: inout UInt32
    ) -> UInt8 {
        guard contextGeneration == UInt32(contextBodyCount), livePath == nil else {
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

    mutating func endPath(contextGeneration: UInt32, pathGeneration: UInt32) -> UInt8 {
        guard contextGeneration == UInt32(contextBodyCount), pathGeneration == 1,
            var path = livePath
        else { return _GiftUIDrawingStatus.invalidScope.rawValue }
        path.reset()
        livePath = nil
        return _GiftUIDrawingStatus.success.rawValue
    }

    mutating func mutatePath(
        contextGeneration: UInt32,
        pathGeneration: UInt32,
        point: Point,
        move: Bool
    ) -> UInt8 {
        guard contextGeneration == UInt32(contextBodyCount), pathGeneration == 1,
            var path = livePath
        else { return _GiftUIDrawingStatus.invalidScope.rawValue }
        do {
            if move { try path.move(to: point) } else { try path.addLine(to: point) }
            livePath = path
            return _GiftUIDrawingStatus.success.rawValue
        } catch {
            return drawingStatus(for: error)
        }
    }

    mutating func strokePath(
        contextGeneration: UInt32,
        pathGeneration: UInt32,
        color: Color,
        style: StrokeStyle
    ) -> UInt8 {
        guard contextGeneration == UInt32(contextBodyCount), pathGeneration == 1,
            let path = livePath, let origin = currentOrigin, let clip = currentClip
        else { return _GiftUIDrawingStatus.invalidScope.rawValue }
        var index: UInt16 = 0
        while index < path.storage.pointCount {
            guard let point = path.storage.point(at: index) else {
                return _GiftUIDrawingStatus.invariantViolation.rawValue
            }
            guard !point.x.addingReportingOverflow(origin.x).overflow,
                !point.y.addingReportingOverflow(origin.y).overflow
            else { return _GiftUIDrawingStatus.arithmeticOverflow.rawValue }
            index += 1
        }
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
            return drawingStatus(for: error)
        }
    }

    private func stroke(of canvas: UInt16, at index: UInt16) -> CanvasPlanStrokeFixture? {
        guard publishedSummary != nil else { return nil }
        let matches = strokes.filter { $0.canvas == canvas }
        guard Int(index) < matches.count else { return nil }
        return matches[Int(index)]
    }
}

private struct CanvasPlanStrokeFixture {
    let canvas: UInt16
    let header: StraightLineStrokeHeader
    let points: [Point]
    let subpaths: [SubpathRange]
}

private let derivingContext = ExecutionContext(
    cycle: RunCycleID(rawValue: 1),
    semanticRevision: SemanticRevision(rawValue: 4),
    candidateFrame: nil,
    phase: .deriving
)

private let canvasPlanLimits = DrawingLimits(
    maximumLineWidth: 8,
    maximumCanvasOccurrences: 2,
    maximumLivePathPoints: 4,
    maximumLivePathSubpaths: 2,
    maximumPlanStrokes: 2,
    maximumPlanPoints: 4,
    maximumPlanSubpaths: 2,
    maximumNormalizedStrokeOperations: 2
)!

private let canvasPlanWideLimits = DrawingLimits(
    maximumLineWidth: 8,
    maximumCanvasOccurrences: 3,
    maximumLivePathPoints: 4,
    maximumLivePathSubpaths: 2,
    maximumPlanStrokes: 2,
    maximumPlanPoints: 4,
    maximumPlanSubpaths: 2,
    maximumNormalizedStrokeOperations: 2
)!

private let zeroRect = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 0, height: 0)!
)!

private func canvasLayoutRecord(
    identity: UInt16,
    x: GeometryScalar,
    y: GeometryScalar,
    width: GeometryScalar,
    height: GeometryScalar
) -> CanvasPlanLayoutRecord {
    CanvasPlanLayoutRecord(
        identity: identity,
        bounds: Rect(origin: Point(x: x, y: y), size: Size(width: width, height: height)!)!,
        clip: Rect(
            origin: Point(x: x - 1, y: y - 1),
            size: Size(width: width + 2, height: height + 2)!
        )!
    )
}

private let canvasPlanDrawingOperations = _GiftUIDrawingOperations(
    beginPath: canvasPlanBeginPath,
    endPath: canvasPlanEndPath,
    movePath: canvasPlanMovePath,
    addLineToPath: canvasPlanAddLinePath,
    strokePath: canvasPlanStrokePath
)

private func canvasPlanBeginPath(
    storage: UnsafeMutableRawPointer,
    contextGeneration: UInt32,
    pathGeneration: UnsafeMutablePointer<UInt32>
) -> UInt8 {
    storage.assumingMemoryBound(to: CanvasPlanConstructionFixture.self).pointee.beginPath(
        contextGeneration: contextGeneration,
        pathGeneration: &pathGeneration.pointee
    )
}

private func canvasPlanEndPath(
    storage: UnsafeMutableRawPointer,
    contextGeneration: UInt32,
    pathGeneration: UInt32
) -> UInt8 {
    storage.assumingMemoryBound(to: CanvasPlanConstructionFixture.self).pointee.endPath(
        contextGeneration: contextGeneration,
        pathGeneration: pathGeneration
    )
}

private func canvasPlanMovePath(
    storage: UnsafeMutableRawPointer,
    contextGeneration: UInt32,
    pathGeneration: UInt32,
    x: GeometryScalar,
    y: GeometryScalar
) -> UInt8 {
    storage.assumingMemoryBound(to: CanvasPlanConstructionFixture.self).pointee.mutatePath(
        contextGeneration: contextGeneration,
        pathGeneration: pathGeneration,
        point: Point(x: x, y: y),
        move: true
    )
}

private func canvasPlanAddLinePath(
    storage: UnsafeMutableRawPointer,
    contextGeneration: UInt32,
    pathGeneration: UInt32,
    x: GeometryScalar,
    y: GeometryScalar
) -> UInt8 {
    storage.assumingMemoryBound(to: CanvasPlanConstructionFixture.self).pointee.mutatePath(
        contextGeneration: contextGeneration,
        pathGeneration: pathGeneration,
        point: Point(x: x, y: y),
        move: false
    )
}

private func canvasPlanStrokePath(
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
    guard let cap = LineCap(rawValue: lineCap), let join = LineJoin(rawValue: lineJoin) else {
        return _GiftUIDrawingStatus.invariantViolation.rawValue
    }
    return storage.assumingMemoryBound(to: CanvasPlanConstructionFixture.self).pointee
        .strokePath(
            contextGeneration: contextGeneration,
            pathGeneration: pathGeneration,
            color: Color(red: red, green: green, blue: blue),
            style: StrokeStyle(lineWidth: lineWidth, lineCap: cap, lineJoin: join)
        )
}

private func drawingStatus(for error: any Error) -> UInt8 {
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
