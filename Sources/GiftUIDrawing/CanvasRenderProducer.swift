import GiftUI
import GiftUILayout
import GiftUIRenderCore
import GiftUIRenderLowering
import GiftUISemanticCore
import GiftUITextResources

package enum CanvasRenderProducer {
    package static func preflight<Semantic, Layout, Metrics, Plan, Workspace>(
        semantic: borrowing Semantic,
        layout: borrowing Layout,
        textMetrics: borrowing Metrics,
        drawingPlan: borrowing Plan,
        surfaceBounds: Rect,
        damageMode: RenderDamageMode,
        rootForeground: Color,
        limits: RenderLimits,
        configuredSinkCapacity: RenderSinkCapacity,
        workspace: inout Workspace
    ) -> RenderProductionResult
    where
        Semantic: SemanticRenderView,
        Layout: ResolvedRenderLayoutView,
        Metrics: CanonicalTextMetricsView,
        Plan: DrawingPlanView,
        Workspace: RenderProductionWorkspace,
        Semantic.Identity == Layout.Identity,
        Semantic.Identity == Plan.Identity,
        Semantic.Identity == Workspace.Identity
    {
        _ = rootForeground
        if workspace.isActive {
            return .failure(.reentrancyViolation)
        }
        var extensionVisitor = CanvasPreflightExtension(
            drawingPlan: copy drawingPlan
        )
        let result = RenderProducer.preflight(
            semantic: semantic,
            layout: layout,
            textMetrics: textMetrics,
            surfaceBounds: surfaceBounds,
            damageMode: damageMode,
            limits: limits,
            configuredSinkCapacity: configuredSinkCapacity,
            workspace: &workspace,
            extensionVisitor: &extensionVisitor
        )
        guard case .success = result else { return result }
        guard extensionVisitor.summary == drawingPlan.summary else {
            return .failure(.invariantViolation)
        }
        return result
    }
}

private struct CanvasPreflightExtension<Plan>: RenderPreflightExtension
where Plan: DrawingPlanView {
    typealias Identity = Plan.Identity

    let drawingPlan: Plan
    private(set) var canvasOccurrenceCount: UInt16 = 0
    private(set) var strokeCount: UInt16 = 0
    private(set) var pointCount: UInt16 = 0
    private(set) var subpathCount: UInt16 = 0

    var summary: DrawingPlanSummary {
        DrawingPlanSummary(
            canvasOccurrenceCount: canvasOccurrenceCount,
            strokeCount: strokeCount,
            pointCount: pointCount,
            subpathCount: subpathCount,
            normalizedStrokeOperationCount: strokeCount
        )
    }

    mutating func visit(
        scope: SemanticRenderScope,
        identity: Identity,
        bounds: Rect,
        clip: Rect
    ) -> RenderExtensionVisitResult {
        guard scope == .canvas else {
            guard drawingPlan.strokeCount(of: identity) == nil else {
                return .failure(.invariantViolation)
            }
            return .success(RenderExtensionVisit(operationCount: 0))
        }

        guard let canvasStrokeCount = drawingPlan.strokeCount(of: identity),
            let nextCanvasCount = checkedAdd(canvasOccurrenceCount, 1),
            let nextStrokeCount = checkedAdd(strokeCount, canvasStrokeCount)
        else {
            return .failure(.invariantViolation)
        }

        var canvasPointCount: UInt16 = 0
        var canvasSubpathCount: UInt16 = 0
        var strokeIndex: UInt16 = 0
        while strokeIndex < canvasStrokeCount {
            guard
                let header = drawingPlan.strokeHeader(
                    of: identity,
                    at: strokeIndex
                ),
                header.lineWidth > 0,
                header.surfaceOrigin == bounds.origin,
                header.inheritedClip == clip,
                validatePoints(
                    canvas: identity,
                    stroke: strokeIndex,
                    count: header.pointCount
                ),
                validateSubpaths(
                    canvas: identity,
                    stroke: strokeIndex,
                    pointCount: header.pointCount,
                    subpathCount: header.subpathCount
                ),
                let nextPointCount = checkedAdd(
                    canvasPointCount,
                    header.pointCount
                ),
                let nextSubpathCount = checkedAdd(
                    canvasSubpathCount,
                    header.subpathCount
                )
            else {
                return .failure(.invariantViolation)
            }
            canvasPointCount = nextPointCount
            canvasSubpathCount = nextSubpathCount
            strokeIndex += 1
        }
        guard
            drawingPlan.strokeHeader(
                of: identity,
                at: canvasStrokeCount
            ) == nil,
            let nextTotalPoints = checkedAdd(pointCount, canvasPointCount),
            let nextTotalSubpaths = checkedAdd(subpathCount, canvasSubpathCount)
        else {
            return .failure(.invariantViolation)
        }

        canvasOccurrenceCount = nextCanvasCount
        strokeCount = nextStrokeCount
        pointCount = nextTotalPoints
        subpathCount = nextTotalSubpaths
        return .success(RenderExtensionVisit(operationCount: canvasStrokeCount))
    }

    private func validatePoints(
        canvas: Identity,
        stroke: UInt16,
        count: UInt16
    ) -> Bool {
        var pointIndex: UInt16 = 0
        while pointIndex < count {
            guard
                drawingPlan.point(
                    of: canvas,
                    stroke: stroke,
                    at: pointIndex
                ) != nil
            else { return false }
            pointIndex += 1
        }
        return drawingPlan.point(
            of: canvas,
            stroke: stroke,
            at: count
        ) == nil
    }

    private func validateSubpaths(
        canvas: Identity,
        stroke: UInt16,
        pointCount: UInt16,
        subpathCount: UInt16
    ) -> Bool {
        if pointCount == 0 || subpathCount == 0 {
            guard pointCount == 0, subpathCount == 0 else { return false }
        }

        var expectedFirstPoint: UInt16 = 0
        var subpathIndex: UInt16 = 0
        while subpathIndex < subpathCount {
            guard
                let subpath = drawingPlan.subpath(
                    of: canvas,
                    stroke: stroke,
                    at: subpathIndex
                ),
                subpath.firstPoint == expectedFirstPoint,
                let end = checkedAdd(subpath.firstPoint, subpath.pointCount),
                end <= pointCount
            else { return false }
            expectedFirstPoint = end
            subpathIndex += 1
        }
        return expectedFirstPoint == pointCount
            && drawingPlan.subpath(
                of: canvas,
                stroke: stroke,
                at: subpathCount
            ) == nil
    }

    private func checkedAdd(_ lhs: UInt16, _ rhs: UInt16) -> UInt16? {
        let result = lhs.addingReportingOverflow(rhs)
        return result.overflow ? nil : result.partialValue
    }
}
