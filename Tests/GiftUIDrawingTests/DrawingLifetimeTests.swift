import GiftUI
import Testing

@testable import GiftUIDrawing

@Test
func planPublicationDiscardAndResetPoisonEveryPriorAccessPath() {
    let limits = DrawingLimits(
        maximumLineWidth: 1,
        maximumCanvasOccurrences: 1,
        maximumLivePathPoints: 1,
        maximumLivePathSubpaths: 1,
        maximumPlanStrokes: 1,
        maximumPlanPoints: 1,
        maximumPlanSubpaths: 1,
        maximumNormalizedStrokeOperations: 1
    )!
    var workspace = FixtureDrawingPlanWorkspace(capacity: limits)
    let acquired = workspace.acquire()
    #expect(acquired)
    let staged = workspace.stageCanvas(71)
    #expect(staged)
    let summary = DrawingPlanSummary(
        canvasOccurrenceCount: 1,
        strokeCount: 0,
        pointCount: 0,
        subpathCount: 0,
        normalizedStrokeOperationCount: 0
    )
    #expect(workspace.seal(summary: summary) == .success(summary))
    #expect(workspace.strokeCount(of: 71) == 0)

    workspace.discard()
    #expect(!workspace.isPlanAccessible)
    #expect(workspace.strokeCount(of: 71) == nil)
    #expect(workspace.strokeHeader(of: 71, at: 0) == nil)
    #expect(workspace.point(of: 71, stroke: 0, at: 0) == nil)
    #expect(workspace.subpath(of: 71, stroke: 0, at: 0) == nil)

    workspace.reset()
    #expect(workspace.state == .idle)
    #expect(!workspace.isPlanAccessible)
    #expect(workspace.strokeCount(of: 71) == nil)
}
