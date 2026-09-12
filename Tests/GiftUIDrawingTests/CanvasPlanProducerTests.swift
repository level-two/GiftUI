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
    var invokedIdentities: [UInt16] = []
    var invokedSizes: [Size] = []
    var releasedIdentities: [UInt16] = []
    var releaseCounts: [UInt16: Int] = [:]
    var activeIdentities: Set<UInt16>

    init(
        identities: [UInt16],
        reportedCountOverride: UInt16? = nil,
        errorAtIndex: UInt16? = nil,
        error: DrawingError? = nil
    ) {
        self.identities = identities
        self.reportedCountOverride = reportedCountOverride
        self.errorAtIndex = errorAtIndex
        self.error = error
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
        context _: inout GraphicsContext,
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
    }

    mutating func releaseCanvas(at identity: UInt16) {
        releasedIdentities.append(identity)
        releaseCounts[identity, default: 0] += 1
        activeIdentities.remove(identity)
    }
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

private struct CanvasPlanConstructionFixture: DrawingPlanConstructionWorkspace {
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

    init(capacity: DrawingLimits) {
        self.capacity = capacity
    }

    var summary: DrawingPlanSummary {
        publishedSummary!
    }

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
        var storage: UInt8 = 0
        do {
            return try withUnsafeMutablePointer(to: &storage) { storagePointer in
                var context = GraphicsContext(
                    storage: UnsafeMutableRawPointer(storagePointer),
                    generation: UInt32(contextBodyCount),
                    operations: noOpDrawingOperations
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
            canvasOccurrenceCount == UInt16(contextIdentities.count)
        else { return .failure(.invariantViolation) }
        let summary = DrawingPlanSummary(
            canvasOccurrenceCount: canvasOccurrenceCount,
            strokeCount: 0,
            pointCount: 0,
            subpathCount: 0,
            normalizedStrokeOperationCount: 0
        )
        publishedSummary = summary
        isActive = false
        return .success(summary)
    }

    mutating func discard() {
        discardCount += 1
        publishedSummary = nil
        isActive = false
    }

    mutating func reset() {
        resetCount += 1
        publishedSummary = nil
        isActive = false
        contextIdentities.removeAll(keepingCapacity: true)
        surfaceOrigins.removeAll(keepingCapacity: true)
        inheritedClips.removeAll(keepingCapacity: true)
    }

    func strokeCount(of canvas: UInt16) -> UInt16? {
        publishedSummary != nil && contextIdentities.contains(canvas) ? 0 : nil
    }

    func strokeHeader(of _: UInt16, at _: UInt16) -> StraightLineStrokeHeader? { nil }
    func point(of _: UInt16, stroke _: UInt16, at _: UInt16) -> Point? { nil }
    func subpath(of _: UInt16, stroke _: UInt16, at _: UInt16) -> SubpathRange? { nil }
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

private let noOpDrawingOperations = _GiftUIDrawingOperations(
    beginPath: canvasPlanBeginPath,
    endPath: canvasPlanEndPath,
    movePath: canvasPlanMutatePath,
    addLineToPath: canvasPlanMutatePath,
    strokePath: canvasPlanStrokePath
)

private func canvasPlanBeginPath(
    _: UnsafeMutableRawPointer,
    _: UInt32,
    pathGeneration: UnsafeMutablePointer<UInt32>
) -> UInt8 {
    pathGeneration.pointee = 1
    return _GiftUIDrawingStatus.success.rawValue
}

private func canvasPlanEndPath(
    _: UnsafeMutableRawPointer,
    _: UInt32,
    _: UInt32
) -> UInt8 {
    _GiftUIDrawingStatus.success.rawValue
}

private func canvasPlanMutatePath(
    _: UnsafeMutableRawPointer,
    _: UInt32,
    _: UInt32,
    _: GeometryScalar,
    _: GeometryScalar
) -> UInt8 {
    _GiftUIDrawingStatus.success.rawValue
}

private func canvasPlanStrokePath(
    _: UnsafeMutableRawPointer,
    _: UInt32,
    _: UInt32,
    _: UInt8,
    _: UInt8,
    _: UInt8,
    _: GeometryScalar,
    _: UInt8,
    _: UInt8
) -> UInt8 {
    _GiftUIDrawingStatus.success.rawValue
}
