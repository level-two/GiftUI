import GiftUI
import GiftUILayout
import GiftUIRenderCore
import GiftUISemanticCore
import GiftUITextResources

extension RenderProducer {
    package static func produce<Semantic, Layout, Metrics, Workspace, Sink>(
        semantic: borrowing Semantic,
        layout: borrowing Layout,
        textMetrics: borrowing Metrics,
        surfaceBounds: Rect,
        damageMode: RenderDamageMode,
        rootForeground: Color,
        limits: RenderLimits,
        workspace: inout Workspace,
        sink: inout Sink
    ) -> RenderProductionResult
    where
        Semantic: SemanticRenderView,
        Layout: ResolvedRenderLayoutView,
        Metrics: CanonicalTextMetricsView,
        Workspace: RenderProductionWorkspace,
        Sink: RenderOperationSink,
        Semantic.Identity == Layout.Identity,
        Semantic.Identity == Workspace.Identity
    {
        if workspace.isActive {
            return .failure(.reentrancyViolation)
        }
        guard workspace.acquire() else {
            return .failure(.invariantViolation)
        }
        defer { workspace.reset() }

        let preflightResult = preflight(
            semantic: semantic,
            layout: layout,
            textMetrics: textMetrics,
            surfaceBounds: surfaceBounds,
            damageMode: damageMode,
            limits: limits,
            workspace: &workspace,
            sink: &sink
        )
        guard case .success(let summary) = preflightResult else {
            if case .failure(let error) = preflightResult {
                return .failure(error)
            }
            return .failure(.invariantViolation)
        }
        return stream(
            preflight: summary,
            semantic: semantic,
            layout: layout,
            textMetrics: textMetrics,
            surfaceBounds: surfaceBounds,
            damageMode: damageMode,
            rootForeground: rootForeground,
            workspace: &workspace,
            sink: &sink
        )
    }

    package static func produce<
        Semantic, Layout, Metrics, Workspace,
        PreflightExtension, StreamingExtension, Sink
    >(
        semantic: borrowing Semantic,
        layout: borrowing Layout,
        textMetrics: borrowing Metrics,
        surfaceBounds: Rect,
        damageMode: RenderDamageMode,
        rootForeground: Color,
        limits: RenderLimits,
        expectedHeader: RenderPlanHeader,
        workspace: inout Workspace,
        preflightExtension: inout PreflightExtension,
        streamingExtension: inout StreamingExtension,
        sink: inout Sink
    ) -> RenderProductionResult
    where
        Semantic: SemanticRenderView,
        Layout: ResolvedRenderLayoutView,
        Metrics: CanonicalTextMetricsView,
        Workspace: RenderProductionWorkspace,
        PreflightExtension: RenderPreflightExtension,
        StreamingExtension: RenderStreamingExtension,
        Sink: RenderOperationSink,
        Semantic.Identity == Layout.Identity,
        Semantic.Identity == Workspace.Identity,
        Semantic.Identity == PreflightExtension.Identity,
        Semantic.Identity == StreamingExtension.Identity,
        StreamingExtension.Sink == Sink
    {
        if workspace.isActive {
            return .failure(.reentrancyViolation)
        }
        guard workspace.acquire() else {
            return .failure(.invariantViolation)
        }
        defer { workspace.reset() }

        let preflightResult = preflightTraversal(
            semantic: semantic,
            layout: layout,
            textMetrics: textMetrics,
            surfaceBounds: surfaceBounds,
            damageMode: damageMode,
            limits: limits,
            workspace: &workspace,
            extensionVisitor: &preflightExtension
        )
        guard case .success(let summary) = preflightResult else {
            if case .failure(let error) = preflightResult {
                return .failure(error)
            }
            return .failure(.invariantViolation)
        }
        let sinkCapacity = sink.capacity
        guard summary.header == expectedHeader,
            summary.header.operationCount <= sinkCapacity.maximumOperations,
            summary.header.positionedGlyphCount
                <= sinkCapacity.maximumPositionedGlyphs
        else {
            return .failure(.invariantViolation)
        }
        switch preflightExtension.complete() {
        case .success:
            break
        case .failure(let error):
            return .failure(error)
        }

        return stream(
            preflight: summary,
            semantic: semantic,
            layout: layout,
            textMetrics: textMetrics,
            surfaceBounds: surfaceBounds,
            damageMode: damageMode,
            rootForeground: rootForeground,
            workspace: &workspace,
            extensionVisitor: &streamingExtension,
            sink: &sink
        )
    }
}
