import GiftUI
import GiftUILayout
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUISemanticCore
import GiftUITextResources
import Testing

@testable import GiftUIDrawing

@Test
func canvasPreflightCombinesOrdinaryAndStrokeCountsAndResetsItsWorkspace() {
    var workspace = CanvasRenderWorkspace()
    let result = CanvasRenderProducer.preflight(
        semantic: CanvasRenderSemantic(),
        layout: CanvasRenderLayout(),
        textMetrics: CanvasRenderMetrics(),
        drawingPlan: CanvasRenderPlan(),
        surfaceBounds: canvasRenderBounds,
        damageMode: .rootIntersection,
        rootForeground: .red,
        limits: canvasRenderLimits,
        configuredSinkCapacity: RenderSinkCapacity(
            maximumOperations: 2,
            maximumPositionedGlyphs: 0
        ),
        workspace: &workspace
    )

    #expect(
        result
            == .success(
                RenderPlanHeader(
                    surfaceBounds: canvasRenderBounds,
                    damageBounds: canvasRenderBounds,
                    operationCount: 2,
                    positionedGlyphCount: 0,
                    maximumObservedClipDepth: 1
                )
            )
    )
    #expect(workspace.acquireCount == 1)
    #expect(workspace.resetCount == 1)
    #expect(!workspace.isActive)
    #expect(workspace.semanticVisitCount == 3)
    #expect(workspace.layoutVisitCount == 3)
}

@Test(
    arguments: [
        CanvasRenderPlanFault.summaryCanvas,
        .summaryStroke,
        .summaryPoint,
        .summarySubpath,
        .summaryNormalized,
        .origin,
        .clip,
        .lineWidth,
        .missingPoint,
        .extraPoint,
        .subpathGap,
        .extraSubpath,
        .extraStroke,
        .unexpectedNonCanvas,
    ]
)
private func canvasPreflightRejectsEveryImmutablePlanDisagreement(
    _ fault: CanvasRenderPlanFault
) {
    var workspace = CanvasRenderWorkspace()
    let result = CanvasRenderProducer.preflight(
        semantic: CanvasRenderSemantic(),
        layout: CanvasRenderLayout(),
        textMetrics: CanvasRenderMetrics(),
        drawingPlan: CanvasRenderPlan(fault: fault),
        surfaceBounds: canvasRenderBounds,
        damageMode: .rootIntersection,
        rootForeground: .blue,
        limits: canvasRenderLimits,
        configuredSinkCapacity: RenderSinkCapacity(
            maximumOperations: 2,
            maximumPositionedGlyphs: 0
        ),
        workspace: &workspace
    )

    #expect(result == .failure(.invariantViolation))
    #expect(workspace.acquireCount == 1)
    #expect(workspace.resetCount == 1)
    #expect(!workspace.isActive)
}

@Test
func canvasPreflightFailsClosedForCombinedAndConfiguredCapacity() {
    var combinedShortWorkspace = CanvasRenderWorkspace()
    let combinedShort = CanvasRenderProducer.preflight(
        semantic: CanvasRenderSemantic(),
        layout: CanvasRenderLayout(),
        textMetrics: CanvasRenderMetrics(),
        drawingPlan: CanvasRenderPlan(),
        surfaceBounds: canvasRenderBounds,
        damageMode: .rootIntersection,
        rootForeground: .red,
        limits: RenderLimits(
            maximumOperations: 1,
            maximumPositionedGlyphs: 1,
            maximumClipDepth: 1
        )!,
        configuredSinkCapacity: RenderSinkCapacity(
            maximumOperations: 2,
            maximumPositionedGlyphs: 0
        ),
        workspace: &combinedShortWorkspace
    )
    #expect(combinedShort == .failure(.capacityExhausted))
    #expect(combinedShortWorkspace.resetCount == 1)

    var configuredShortWorkspace = CanvasRenderWorkspace()
    let configuredShort = CanvasRenderProducer.preflight(
        semantic: CanvasRenderSemantic(),
        layout: CanvasRenderLayout(),
        textMetrics: CanvasRenderMetrics(),
        drawingPlan: CanvasRenderPlan(),
        surfaceBounds: canvasRenderBounds,
        damageMode: .rootIntersection,
        rootForeground: .red,
        limits: canvasRenderLimits,
        configuredSinkCapacity: RenderSinkCapacity(
            maximumOperations: 1,
            maximumPositionedGlyphs: 0
        ),
        workspace: &configuredShortWorkspace
    )
    #expect(configuredShort == .failure(.capacityExhausted))
    #expect(configuredShortWorkspace.resetCount == 1)

    var activeWorkspace = CanvasRenderWorkspace()
    let acquired = activeWorkspace.acquire()
    #expect(acquired)
    let reentry = CanvasRenderProducer.preflight(
        semantic: CanvasRenderSemantic(),
        layout: CanvasRenderLayout(),
        textMetrics: CanvasRenderMetrics(),
        drawingPlan: CanvasRenderPlan(),
        surfaceBounds: canvasRenderBounds,
        damageMode: .rootIntersection,
        rootForeground: .red,
        limits: canvasRenderLimits,
        configuredSinkCapacity: RenderSinkCapacity(
            maximumOperations: 2,
            maximumPositionedGlyphs: 0
        ),
        workspace: &activeWorkspace
    )
    #expect(reentry == .failure(.reentrancyViolation))
    #expect(activeWorkspace.acquireCount == 1)
    #expect(activeWorkspace.resetCount == 0)
    #expect(activeWorkspace.isActive)
}

@Test
func canvasProductionCompletesBothTraversalsAndStreamsOneCombinedTransaction() {
    var workspace = CanvasRenderWorkspace()
    var sink = CanvasRenderSink()
    let expectedHeader = RenderPlanHeader(
        surfaceBounds: canvasRenderBounds,
        damageBounds: canvasRenderBounds,
        operationCount: 2,
        positionedGlyphCount: 0,
        maximumObservedClipDepth: 1
    )

    let result = CanvasRenderProducer.produce(
        semantic: CanvasRenderSemantic(),
        layout: CanvasRenderLayout(),
        textMetrics: CanvasRenderMetrics(),
        drawingPlan: CanvasRenderPlan(),
        surfaceBounds: canvasRenderBounds,
        damageMode: .rootIntersection,
        rootForeground: .red,
        limits: canvasRenderLimits,
        expectedHeader: expectedHeader,
        workspace: &workspace,
        sink: &sink
    )

    #expect(result == .success(expectedHeader))
    #expect(
        sink.events
            == [
                .begin(expectedHeader),
                .fill(
                    FillRectOperation(
                        bounds: canvasRenderClip,
                        clip: canvasRenderClip,
                        color: .blue
                    )
                ),
                .stroke(
                    CanvasRecordedStroke(
                        header: StraightLineStrokeHeader(
                            color: .red,
                            lineWidth: 2,
                            lineCap: .round,
                            lineJoin: .miter,
                            surfaceOrigin: canvasRenderClip.origin,
                            inheritedClip: canvasRenderClip,
                            pointCount: 2,
                            subpathCount: 1
                        ),
                        points: [Point(x: 2, y: 2), Point(x: 8, y: 6)],
                        subpaths: [SubpathRange(firstPoint: 0, pointCount: 2)!]
                    )
                ),
                .finish,
            ]
    )
    #expect(sink.capacityReadCount == 1)
    #expect(sink.discardCount == 0)
    #expect(workspace.acquireCount == 1)
    #expect(workspace.resetCount == 1)
    #expect(!workspace.isActive)
}

@Test
func canvasProductionRejectsFinalPlanSummaryMismatchBeforeBegin() {
    var workspace = CanvasRenderWorkspace()
    var sink = CanvasRenderSink()
    let result = CanvasRenderProducer.produce(
        semantic: CanvasRenderSemantic(),
        layout: CanvasRenderLayout(),
        textMetrics: CanvasRenderMetrics(),
        drawingPlan: CanvasRenderPlan(fault: .summaryPoint),
        surfaceBounds: canvasRenderBounds,
        damageMode: .rootIntersection,
        rootForeground: .red,
        limits: canvasRenderLimits,
        expectedHeader: RenderPlanHeader(
            surfaceBounds: canvasRenderBounds,
            damageBounds: canvasRenderBounds,
            operationCount: 2,
            positionedGlyphCount: 0,
            maximumObservedClipDepth: 1
        ),
        workspace: &workspace,
        sink: &sink
    )

    #expect(result == .failure(.invariantViolation))
    #expect(sink.events.isEmpty)
    #expect(sink.discardCount == 0)
    #expect(workspace.resetCount == 1)
}

private enum CanvasRenderIdentity: UInt8, Equatable, Sendable {
    case root
    case background
    case canvas
}

private let canvasRenderBounds = Rect(
    origin: Point(x: 0, y: 0),
    size: Size(width: 20, height: 10)!
)!
private let canvasRenderClip = Rect(
    origin: Point(x: 1, y: 1),
    size: Size(width: 18, height: 8)!
)!
private let canvasRenderLimits = RenderLimits(
    maximumOperations: 2,
    maximumPositionedGlyphs: 1,
    maximumClipDepth: 1
)!

private struct CanvasRenderSemantic: SemanticRenderView {
    let rootIdentity = CanvasRenderIdentity.root
    let semanticScopeCount: UInt16 = 3
    let renderSnapshotVersion: UInt32 = 7

    func semanticIdentity(at ordinal: UInt16) -> CanvasRenderIdentity? {
        switch ordinal {
        case 0: .root
        case 1: .background
        case 2: .canvas
        default: nil
        }
    }

    func semanticOrdinal(of identity: CanvasRenderIdentity) -> UInt16? {
        switch identity {
        case .root: 0
        case .background: 1
        case .canvas: 2
        }
    }

    func scope(at identity: CanvasRenderIdentity) -> SemanticRenderScope? {
        switch identity {
        case .root: .structural
        case .background: .background(.blue)
        case .canvas: .canvas
        }
    }

    func layoutIdentity(
        for identity: CanvasRenderIdentity
    ) -> CanvasRenderIdentity? {
        identity == .root ? .root : .canvas
    }

    func childCount(of identity: CanvasRenderIdentity) -> UInt16? {
        identity == .canvas ? 0 : 1
    }

    func child(
        of identity: CanvasRenderIdentity,
        at index: UInt16
    ) -> CanvasRenderIdentity? {
        guard index == 0 else { return nil }
        return switch identity {
        case .root: .background
        case .background: .canvas
        case .canvas: nil
        }
    }
}

private struct CanvasRenderLayout: ResolvedRenderLayoutView {
    let rootIdentity = CanvasRenderIdentity.root
    let layoutScopeCount: UInt16 = 2
    let renderSnapshotVersion: UInt32 = 7
    let rootBounds = canvasRenderBounds

    func layoutIdentity(at ordinal: UInt16) -> CanvasRenderIdentity? {
        switch ordinal {
        case 0: .root
        case 1: .canvas
        default: nil
        }
    }

    func layoutOrdinal(of identity: CanvasRenderIdentity) -> UInt16? {
        switch identity {
        case .root: 0
        case .canvas: 1
        case .background: nil
        }
    }

    func bounds(of identity: CanvasRenderIdentity) -> Rect? {
        identity == .root ? canvasRenderBounds : canvasRenderClip
    }

    func clip(of identity: CanvasRenderIdentity) -> Rect? {
        identity == .root ? canvasRenderBounds : canvasRenderClip
    }

    func textLineCount(of identity: CanvasRenderIdentity) -> UInt16? { 0 }
    func textLine(
        of identity: CanvasRenderIdentity,
        at index: UInt16
    ) -> ResolvedRenderTextLine? { nil }
    func glyph(
        of identity: CanvasRenderIdentity,
        at index: UInt16
    ) -> ResolvedRenderGlyph? { nil }
}

private enum CanvasRenderPlanFault: CaseIterable {
    case none
    case summaryCanvas
    case summaryStroke
    case summaryPoint
    case summarySubpath
    case summaryNormalized
    case origin
    case clip
    case lineWidth
    case missingPoint
    case extraPoint
    case subpathGap
    case extraSubpath
    case extraStroke
    case unexpectedNonCanvas
}

private struct CanvasRenderPlan: DrawingPlanView {
    let fault: CanvasRenderPlanFault

    init(fault: CanvasRenderPlanFault = .none) {
        self.fault = fault
    }

    var summary: DrawingPlanSummary {
        DrawingPlanSummary(
            canvasOccurrenceCount: fault == .summaryCanvas ? 2 : 1,
            strokeCount: fault == .summaryStroke ? 2 : 1,
            pointCount: fault == .summaryPoint ? 3 : 2,
            subpathCount: fault == .summarySubpath ? 2 : 1,
            normalizedStrokeOperationCount: fault == .summaryNormalized ? 2 : 1
        )
    }

    func strokeCount(of canvas: CanvasRenderIdentity) -> UInt16? {
        if fault == .unexpectedNonCanvas, canvas == .root { return 0 }
        return canvas == .canvas ? 1 : nil
    }

    func strokeHeader(
        of canvas: CanvasRenderIdentity,
        at index: UInt16
    ) -> StraightLineStrokeHeader? {
        guard canvas == .canvas else { return nil }
        if index == 1, fault == .extraStroke { return validHeader }
        guard index == 0 else { return nil }
        return StraightLineStrokeHeader(
            color: .red,
            lineWidth: fault == .lineWidth ? 0 : 2,
            lineCap: .round,
            lineJoin: .miter,
            surfaceOrigin: fault == .origin
                ? Point(x: 99, y: 99) : canvasRenderClip.origin,
            inheritedClip: fault == .clip
                ? canvasRenderBounds : canvasRenderClip,
            pointCount: 2,
            subpathCount: 1
        )
    }

    func point(
        of canvas: CanvasRenderIdentity,
        stroke: UInt16,
        at index: UInt16
    ) -> Point? {
        guard canvas == .canvas, stroke == 0 else { return nil }
        if index == 2, fault == .extraPoint { return Point(x: 3, y: 3) }
        if index == 1, fault == .missingPoint { return nil }
        return switch index {
        case 0: Point(x: 2, y: 2)
        case 1: Point(x: 8, y: 6)
        default: nil
        }
    }

    func subpath(
        of canvas: CanvasRenderIdentity,
        stroke: UInt16,
        at index: UInt16
    ) -> SubpathRange? {
        guard canvas == .canvas, stroke == 0 else { return nil }
        if index == 1, fault == .extraSubpath {
            return SubpathRange(firstPoint: 1, pointCount: 1)
        }
        guard index == 0 else { return nil }
        return fault == .subpathGap
            ? SubpathRange(firstPoint: 1, pointCount: 1)
            : SubpathRange(firstPoint: 0, pointCount: 2)
    }

    private var validHeader: StraightLineStrokeHeader {
        StraightLineStrokeHeader(
            color: .red,
            lineWidth: 2,
            lineCap: .round,
            lineJoin: .miter,
            surfaceOrigin: canvasRenderClip.origin,
            inheritedClip: canvasRenderClip,
            pointCount: 2,
            subpathCount: 1
        )
    }
}

private struct CanvasRenderWorkspace: RenderProductionWorkspace {
    typealias Identity = CanvasRenderIdentity

    let capacity = canvasRenderLimits
    let structuralCapacity = RenderWorkspaceCapacity(
        maximumSemanticScopes: 3,
        maximumLayoutScopes: 2,
        maximumTraversalDepth: 3,
        maximumTextLines: 1
    )!
    private(set) var isActive = false
    private(set) var acquireCount: UInt16 = 0
    private(set) var resetCount: UInt16 = 0
    private(set) var semanticVisitCount: UInt16 = 0
    private(set) var layoutVisitCount: UInt16 = 0
    private var semanticVisits = [false, false, false]
    private var layoutVisits = [false, false]
    private var foregroundStack: [Color] = []

    var currentForeground: Color? { foregroundStack.last }

    mutating func acquire() -> Bool {
        guard !isActive else { return false }
        isActive = true
        acquireCount += 1
        return true
    }

    mutating func visitSemanticScope(at ordinal: UInt16) -> RenderWorkspaceVisit {
        semanticVisitCount += 1
        return visit(ordinal, in: &semanticVisits)
    }

    mutating func visitLayoutScope(at ordinal: UInt16) -> RenderWorkspaceVisit {
        layoutVisitCount += 1
        return visit(ordinal, in: &layoutVisits)
    }

    mutating func pushForeground(_ color: Color) -> Bool {
        guard isActive else { return false }
        foregroundStack.append(color)
        return true
    }

    mutating func popForeground() -> Bool {
        guard isActive, !foregroundStack.isEmpty else { return false }
        foregroundStack.removeLast()
        return true
    }

    mutating func reset() {
        isActive = false
        resetCount += 1
        semanticVisits = [false, false, false]
        layoutVisits = [false, false]
        foregroundStack.removeAll(keepingCapacity: true)
    }

    private func visit(
        _ ordinal: UInt16,
        in visits: inout [Bool]
    ) -> RenderWorkspaceVisit {
        guard isActive, Int(ordinal) < visits.count else { return .invalid }
        if visits[Int(ordinal)] { return .repeated }
        visits[Int(ordinal)] = true
        return .first
    }
}

private struct CanvasRecordedStroke: Equatable {
    let header: StraightLineStrokeHeader
    let points: [Point]
    let subpaths: [SubpathRange]
}

private enum CanvasRenderEvent: Equatable {
    case begin(RenderPlanHeader)
    case fill(FillRectOperation)
    case stroke(CanvasRecordedStroke)
    case finish
}

private final class CanvasRenderSinkCounter {
    var capacityReads: UInt16 = 0
}

private struct CanvasRenderSink: DrawingOperationSink {
    private let counter = CanvasRenderSinkCounter()
    private(set) var events: [CanvasRenderEvent] = []
    private(set) var discardCount: UInt16 = 0

    var capacityReadCount: UInt16 { counter.capacityReads }

    var capacity: RenderSinkCapacity {
        counter.capacityReads += 1
        return RenderSinkCapacity(
            maximumOperations: 2,
            maximumPositionedGlyphs: 0
        )
    }

    mutating func begin(_ header: RenderPlanHeader) -> Bool {
        events.append(.begin(header))
        return true
    }

    mutating func fillRect(_ operation: FillRectOperation) -> Bool {
        events.append(.fill(operation))
        return true
    }

    mutating func beginPositionedGlyphs(
        _ operation: PositionedGlyphOperationHeader
    ) -> Bool { false }

    mutating func positionedGlyph(_ glyph: PositionedGlyph) -> Bool { false }
    mutating func endPositionedGlyphs() -> Bool { false }

    mutating func straightLineStroke<Stroke: StraightLineStrokeView>(
        _ stroke: borrowing Stroke
    ) -> Bool {
        var points: [Point] = []
        var pointIndex: UInt16 = 0
        while pointIndex < stroke.header.pointCount {
            guard let point = stroke.point(at: pointIndex) else { return false }
            points.append(point)
            pointIndex += 1
        }

        var subpaths: [SubpathRange] = []
        var subpathIndex: UInt16 = 0
        while subpathIndex < stroke.header.subpathCount {
            guard let subpath = stroke.subpath(at: subpathIndex) else {
                return false
            }
            subpaths.append(subpath)
            subpathIndex += 1
        }
        events.append(
            .stroke(
                CanvasRecordedStroke(
                    header: stroke.header,
                    points: points,
                    subpaths: subpaths
                )
            )
        )
        return true
    }

    mutating func finish() -> Bool {
        events.append(.finish)
        return true
    }

    mutating func discard() {
        discardCount += 1
        events.removeAll(keepingCapacity: true)
    }
}

private struct CanvasRenderMetrics: CanonicalTextMetricsView {
    let descriptor = TextResourceDescriptor(
        schemaVersion: 1,
        resource: FontResourceID(
            rawValue: TextResourceDigest(
                word0: 1,
                word1: 2,
                word2: 3,
                word3: 4,
                word4: 5,
                word5: 6,
                word6: 7,
                word7: 8
            )
        ),
        instanceCount: 0,
        realizationCount: 0,
        canonicalManifestByteCount: 0
    )

    func instance(at index: UInt16) -> FontInstanceDescriptor? { nil }
    func mapping(
        at index: UInt16,
        in instance: FontInstanceID
    ) -> ScalarGlyphMappingRecord? { nil }
    func mapScalar(_ scalarValue: UInt32, in instance: FontInstanceID) -> GlyphMapping? {
        nil
    }
    func metrics(for glyph: GlyphID, in instance: FontInstanceID) -> GlyphMetrics? {
        nil
    }
}
