import GiftUI
import GiftUIRenderCore
import Testing

@testable import GiftUIDrawing

@Test
func drawingPlanWorkspacePublishesExactTotalsAndTotalBoundedLookups() {
    var workspace = FixtureDrawingPlanWorkspace(capacity: fixturePlanLimits)
    #expect(workspace.state == .idle)
    #expect(!workspace.isPlanAccessible)
    let firstAcquire = workspace.acquire()
    #expect(firstAcquire)
    #expect(workspace.isActive)
    let activeAcquire = workspace.acquire()
    #expect(!activeAcquire)
    stageCanvas(11, into: &workspace)
    stageCanvas(29, into: &workspace)
    stageStroke(fixtureStroke(canvas: 29), into: &workspace)

    let summary = DrawingPlanSummary(
        canvasOccurrenceCount: 2,
        strokeCount: 1,
        pointCount: 2,
        subpathCount: 1,
        normalizedStrokeOperationCount: 1
    )
    #expect(workspace.seal(summary: summary) == .success(summary))
    #expect(!workspace.isActive)
    #expect(workspace.isPlanAccessible)
    #expect(workspace.summary == summary)
    #expect(workspace.strokeCount(of: 11) == 0)
    #expect(workspace.strokeCount(of: 29) == 1)
    #expect(workspace.strokeCount(of: 47) == nil)
    #expect(workspace.strokeHeader(of: 29, at: 0) == fixtureHeader())
    #expect(workspace.strokeHeader(of: 29, at: 1) == nil)
    #expect(workspace.point(of: 29, stroke: 0, at: 0) == Point(x: 3, y: 5))
    #expect(workspace.point(of: 29, stroke: 0, at: 1) == Point(x: 7, y: 11))
    #expect(workspace.point(of: 29, stroke: 0, at: 2) == nil)
    #expect(
        workspace.subpath(of: 29, stroke: 0, at: 0) == SubpathRange(firstPoint: 0, pointCount: 2))
    #expect(workspace.subpath(of: 29, stroke: 0, at: 1) == nil)

    workspace.discard()
    #expect(workspace.state == .discarded)
    #expect(!workspace.isPlanAccessible)
    #expect(workspace.strokeCount(of: 11) == nil)
    let discardedAcquire = workspace.acquire()
    #expect(!discardedAcquire)
    workspace.reset()
    #expect(workspace.state == .idle)
    let resetAcquire = workspace.acquire()
    #expect(resetAcquire)
}

@Test(arguments: FixtureMalformedPlan.allCases)
func drawingPlanWorkspaceRejectsEveryInconsistentCandidate(
    _ malformed: FixtureMalformedPlan
) {
    var workspace = FixtureDrawingPlanWorkspace(capacity: fixturePlanLimits)
    let acquired = workspace.acquire()
    #expect(acquired)
    malformed.stage(into: &workspace)
    let result = workspace.seal(summary: malformed.summary)
    #expect(result == .failure(.invariantViolation))
    #expect(workspace.isActive)
    #expect(!workspace.isPlanAccessible)
    workspace.discard()
    #expect(workspace.strokeCount(of: 11) == nil)
    workspace.reset()
    #expect(workspace.state == .idle)
}

@Test
func packagePlanValueInitializersCopyEveryFieldWithoutNormalization() {
    let header = fixtureHeader(lineWidth: -3, pointCount: 0, subpathCount: 0)
    #expect(header.color == Color(red: 1, green: 2, blue: 3))
    #expect(header.lineWidth == -3)
    #expect(header.lineCap == .round)
    #expect(header.lineJoin == .round)
    #expect(header.surfaceOrigin == Point(x: -13, y: 17))
    #expect(header.inheritedClip == fixtureClip)
    #expect(header.pointCount == 0)
    #expect(header.subpathCount == 0)

    let summary = DrawingPlanSummary(
        canvasOccurrenceCount: 8,
        strokeCount: 7,
        pointCount: 6,
        subpathCount: 5,
        normalizedStrokeOperationCount: 4
    )
    #expect(summary.canvasOccurrenceCount == 8)
    #expect(summary.strokeCount == 7)
    #expect(summary.pointCount == 6)
    #expect(summary.subpathCount == 5)
    #expect(summary.normalizedStrokeOperationCount == 4)
}

enum FixtureMalformedPlan: CaseIterable {
    case duplicateCanvas
    case missingCanvas
    case summaryCanvasCount
    case summaryStrokeCount
    case normalizedCount
    case headerPointCount
    case headerSubpathCount
    case subpathOutsidePoints

    var summary: DrawingPlanSummary {
        switch self {
        case .duplicateCanvas, .missingCanvas, .headerPointCount,
            .headerSubpathCount, .subpathOutsidePoints:
            fixtureSummary
        case .summaryCanvasCount:
            DrawingPlanSummary(
                canvasOccurrenceCount: 2,
                strokeCount: 1,
                pointCount: 2,
                subpathCount: 1,
                normalizedStrokeOperationCount: 1
            )
        case .summaryStrokeCount:
            DrawingPlanSummary(
                canvasOccurrenceCount: 1,
                strokeCount: 2,
                pointCount: 2,
                subpathCount: 1,
                normalizedStrokeOperationCount: 2
            )
        case .normalizedCount:
            DrawingPlanSummary(
                canvasOccurrenceCount: 1,
                strokeCount: 1,
                pointCount: 2,
                subpathCount: 1,
                normalizedStrokeOperationCount: 0
            )
        }
    }

    func stage(into workspace: inout FixtureDrawingPlanWorkspace) {
        switch self {
        case .duplicateCanvas:
            stageCanvas(11, into: &workspace)
            stageCanvas(11, into: &workspace)
            stageStroke(fixtureStroke(canvas: 11), into: &workspace)
        case .missingCanvas:
            stageCanvas(11, into: &workspace)
            stageStroke(fixtureStroke(canvas: 29), into: &workspace)
        case .headerPointCount:
            stageCanvas(11, into: &workspace)
            stageStroke(
                fixtureStroke(canvas: 11, headerPointCount: 1),
                into: &workspace
            )
        case .headerSubpathCount:
            stageCanvas(11, into: &workspace)
            stageStroke(
                fixtureStroke(canvas: 11, headerSubpathCount: 2),
                into: &workspace
            )
        case .subpathOutsidePoints:
            stageCanvas(11, into: &workspace)
            stageStroke(
                fixtureStroke(
                    canvas: 11,
                    subpaths: [SubpathRange(firstPoint: 1, pointCount: 2)!]
                ),
                into: &workspace
            )
        case .summaryCanvasCount, .summaryStrokeCount, .normalizedCount:
            stageCanvas(11, into: &workspace)
            stageStroke(fixtureStroke(canvas: 11), into: &workspace)
        }
    }
}

private func stageCanvas(
    _ identity: UInt16,
    into workspace: inout FixtureDrawingPlanWorkspace
) {
    let accepted = workspace.stageCanvas(identity)
    #expect(accepted)
}

private func stageStroke(
    _ stroke: FixtureDrawingStroke,
    into workspace: inout FixtureDrawingPlanWorkspace
) {
    let accepted = workspace.stageStroke(stroke)
    #expect(accepted)
}

private let fixturePlanLimits = DrawingLimits(
    maximumLineWidth: 8,
    maximumCanvasOccurrences: 2,
    maximumLivePathPoints: 4,
    maximumLivePathSubpaths: 2,
    maximumPlanStrokes: 2,
    maximumPlanPoints: 4,
    maximumPlanSubpaths: 2,
    maximumNormalizedStrokeOperations: 2
)!

private let fixtureSummary = DrawingPlanSummary(
    canvasOccurrenceCount: 1,
    strokeCount: 1,
    pointCount: 2,
    subpathCount: 1,
    normalizedStrokeOperationCount: 1
)

private let fixtureClip = Rect(
    origin: Point(x: -2, y: -3),
    size: Size(width: 31, height: 37)!
)!

private func fixtureHeader(
    lineWidth: GeometryScalar = 2,
    pointCount: UInt16 = 2,
    subpathCount: UInt16 = 1
) -> StraightLineStrokeHeader {
    StraightLineStrokeHeader(
        color: Color(red: 1, green: 2, blue: 3),
        lineWidth: lineWidth,
        lineCap: .round,
        lineJoin: .round,
        surfaceOrigin: Point(x: -13, y: 17),
        inheritedClip: fixtureClip,
        pointCount: pointCount,
        subpathCount: subpathCount
    )
}

private func fixtureStroke(
    canvas: UInt16,
    headerPointCount: UInt16 = 2,
    headerSubpathCount: UInt16 = 1,
    subpaths: [SubpathRange] = [SubpathRange(firstPoint: 0, pointCount: 2)!]
) -> FixtureDrawingStroke {
    FixtureDrawingStroke(
        canvas: canvas,
        header: fixtureHeader(
            pointCount: headerPointCount,
            subpathCount: headerSubpathCount
        ),
        points: [Point(x: 3, y: 5), Point(x: 7, y: 11)],
        subpaths: subpaths
    )
}
