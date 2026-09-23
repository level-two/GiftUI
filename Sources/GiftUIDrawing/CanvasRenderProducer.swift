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
        return result
    }

    #if !GIFTUI_NRF_EMBEDDED
        package static func produce<
            Semantic, Layout, Metrics, Plan, Workspace, Sink
        >(
            semantic: borrowing Semantic,
            layout: borrowing Layout,
            textMetrics: borrowing Metrics,
            drawingPlan: borrowing Plan,
            surfaceBounds: Rect,
            damageMode: RenderDamageMode,
            rootForeground: Color,
            limits: RenderLimits,
            expectedHeader: RenderPlanHeader,
            workspace: inout Workspace,
            sink: inout Sink
        ) -> RenderProductionResult
        where
            Semantic: SemanticRenderView,
            Layout: ResolvedRenderLayoutView,
            Metrics: CanonicalTextMetricsView,
            Plan: DrawingPlanView,
            Workspace: RenderProductionWorkspace,
            Sink: DrawingOperationSink,
            Semantic.Identity == Layout.Identity,
            Semantic.Identity == Plan.Identity,
            Semantic.Identity == Workspace.Identity
        {
            var preflightExtension = CanvasPreflightExtension(
                drawingPlan: copy drawingPlan
            )
            var streamingExtension = CanvasStreamingExtension<Plan, Sink>(
                drawingPlan: copy drawingPlan
            )
            return RenderProducer.produce(
                semantic: semantic,
                layout: layout,
                textMetrics: textMetrics,
                surfaceBounds: surfaceBounds,
                damageMode: damageMode,
                rootForeground: rootForeground,
                limits: limits,
                expectedHeader: expectedHeader,
                workspace: &workspace,
                preflightExtension: &preflightExtension,
                streamingExtension: &streamingExtension,
                sink: &sink
            )
        }
    #endif
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

    mutating func complete() -> RenderExtensionCompletionResult {
        summary == drawingPlan.summary
            ? .success
            : .failure(.invariantViolation)
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

#if !GIFTUI_NRF_EMBEDDED
    private struct CanvasStreamingExtension<Plan, Sink>: RenderStreamingExtension
    where Plan: DrawingPlanView, Sink: DrawingOperationSink {
        typealias Identity = Plan.Identity

        private var validation: CanvasPreflightExtension<Plan>

        init(drawingPlan: Plan) {
            validation = CanvasPreflightExtension(drawingPlan: drawingPlan)
        }

        mutating func visit(
            scope: SemanticRenderScope,
            identity: Identity,
            bounds: Rect,
            clip: Rect,
            sink: inout Sink
        ) -> RenderExtensionVisitResult {
            let result = validation.visit(
                scope: scope,
                identity: identity,
                bounds: bounds,
                clip: clip
            )
            guard case .success(let visit) = result else { return result }
            guard scope == .canvas else { return result }

            var strokeIndex: UInt16 = 0
            while strokeIndex < visit.operationCount {
                guard
                    let header = validation.drawingPlan.strokeHeader(
                        of: identity,
                        at: strokeIndex
                    )
                else {
                    return .failure(.invariantViolation)
                }
                let stroke = CanvasStreamingStrokeView(
                    drawingPlan: validation.drawingPlan,
                    canvas: identity,
                    stroke: strokeIndex,
                    header: header
                )
                guard sink.straightLineStroke(stroke) else {
                    return .failure(.invariantViolation)
                }
                strokeIndex += 1
            }
            return result
        }

        mutating func complete() -> RenderExtensionCompletionResult {
            validation.complete()
        }
    }

    private struct CanvasStreamingStrokeView<Plan>: StraightLineStrokeView
    where Plan: DrawingPlanView {
        let drawingPlan: Plan
        let canvas: Plan.Identity
        let stroke: UInt16
        let header: StraightLineStrokeHeader

        func point(at index: UInt16) -> Point? {
            drawingPlan.point(of: canvas, stroke: stroke, at: index)
        }

        func subpath(at index: UInt16) -> SubpathRange? {
            drawingPlan.subpath(of: canvas, stroke: stroke, at: index)
        }
    }
#endif
